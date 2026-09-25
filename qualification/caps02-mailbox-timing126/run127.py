#!/usr/bin/env python3
"""Single-use local Icarus qualification; no vendor/remote/device operations."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

E = Path(__file__).resolve().parent
N = E.parents[1]
Q = N/'qualification/caps02-afu-publication09'
C = N/'afu/ahls_memory/control'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def dump(p, obj):
    with p.open('x') as f:
        json.dump(obj, f, indent=2)
        f.write('\n')


def run_step(argv, path):
    with path.open('x') as f:
        try:
            p = subprocess.run(argv, cwd=E, stdout=f, stderr=subprocess.STDOUT, timeout=60, check=False)
            rc, timed_out = p.returncode, False
        except subprocess.TimeoutExpired:
            rc, timed_out = 124, True
    return {'argv': list(map(str, argv)), 'returncode': rc, 'timeout': timed_out, 'log_sha256': sha(path)}


def main():
    prov = json.loads((Q/'simulator-tools50/PROVISION.json').read_text())
    compiler, runtime = Path(prov['iverilog']), Path(prov['vvp'])
    assert sha(compiler) == prov['iverilog_sha256'] and sha(runtime) == prov['vvp_sha256']
    backend = Path(prov['ivl_backend_directory'])
    source = C/'ia840f_ahls_observer_mailbox_timing126.sv'
    observer = C/'ia840f_ahls_write_observer_timing46.sv'
    baseline = C/'ia840f_ahls_observer_mailbox_csr.sv'
    source_pin = json.loads((E/'source126.json').read_text())
    assert sha(source) == source_pin['candidate_sha256'] and sha(baseline) == source_pin['original_sha256']
    assert sha(E/'tb_mailbox_timing127.sv') == source_pin['fixture_candidate_sha256']
    inputs = [source, observer, baseline, E/'tb_mailbox_timing127.sv', E/'tb_staging127.sv', E/'source126.json', Path(__file__), compiler, runtime]
    inputs += [p for p in sorted(backend.iterdir()) if p.is_file()]
    before = {str(p): sha(p) for p in inputs}
    out = E/'run127'
    out.mkdir(exist_ok=False)
    dump(out/'inputs.json', before)
    tests = []

    def one(label, top, dut, tb, parameters, expected_metrics=None, failure=None):
        d = out/label
        d.mkdir()
        argv = [str(compiler), '-B', str(backend), '-g2012', '-Wall', '-s', top]
        argv += [f'-P{top}.{k}={v}' for k, v in parameters.items()]
        argv += ['-o', str(d/'test.vvp'), str(observer), str(dut), str(tb)]
        compile_result = run_step(argv, d/'compile.log')
        record = {'label': label, 'kind': 'synthetic_broken_RTL_mutant' if failure else 'real_candidate_functional_simulation',
                  'dut_sha256': sha(dut), 'fixture_sha256': sha(tb), 'compile': compile_result}
        if compile_result['returncode'] != 0 or compile_result['timeout']:
            record['accepted'] = False
            dump(d/'result.json', record)
            raise AssertionError(f'{label}: compilation failed')
        sim = run_step([str(runtime), str(d/'test.vvp')], d/'simulation.log')
        text = (d/'simulation.log').read_text()
        record['simulation'] = sim
        if failure:
            record['expected_failure'] = failure
            record['accepted'] = sim['returncode'] != 0 and not sim['timeout'] and failure in text and 'TEST PASSED' not in text
        else:
            pattern = r'MAILBOX TEST PASSED seq_bits=(\d+) cases=(\d+) checks=(\d+) native_commands=(\d+)' if expected_metrics else r'STAGING TEST PASSED cases=(\d+) checks=(\d+) req_install=(\d+) req_publish=(\d+) req_cancel=(\d+) rsp_install=(\d+) rsp_publish=(\d+) rsp_cancel=(\d+) commands=(\d+) completions=(\d+)'
            matches = re.findall(pattern, text)
            record['metrics'] = [int(x) for x in matches[0]] if len(matches) == 1 else None
            record['accepted'] = sim['returncode'] == 0 and not sim['timeout'] and len(matches) == 1 and not re.search(r'\b(?:FATAL|ERROR)\b', text)
            if expected_metrics:
                record['reference_metrics'] = expected_metrics
                record['accepted'] &= record['metrics'] == expected_metrics
        record['artifact_hashes'] = {p.name: sha(p) for p in sorted(d.iterdir()) if p.is_file()}
        dump(d/'result.json', record)
        tests.append(record)
        assert record['accepted'], f'{label}: qualification failed; preserved {d}'
        print(label, 'PASS', record.get('metrics', record.get('expected_failure')), flush=True)

    for seq, core, bank in ((64,5,7), (64,7,3), (64,5,17), (8,5,7)):
        label = f'{seq}-{core}-{bank}'
        ref = json.loads((N/f'qualification/caps02-observer-timing48/run56/{label}/result.json').read_text())
        assert ref['accepted'] and sha(observer) == ref['inputs'][str(observer)]
        one(label, 'tb_mailbox_timing127', source, E/'tb_mailbox_timing127.sv',
            {'SEQ_BITS': seq, 'CORE_HALF': core, 'BANK_HALF': bank}, ref['metrics'])
    one('staging', 'tb_staging127', source, E/'tb_staging127.sv', {})
    text = source.read_text()
    mutations = [
        ('missing-pending-guard', 'core_busy && !request_pending && core_link_reset_n', 'core_busy && core_link_reset_n', 'F_PENDING_GUARD'),
        ('early-request', 'request_pending<=1;core_busy<=1;core_valid<=0;', 'request_toggle<=~request_toggle;request_pending<=1;core_busy<=1;core_valid<=0;', 'F_REQUEST_EARLY'),
        ('early-response', '                response_pending<=1;', '                ack_toggle<=request_sync[1];response_pending<=1;', 'F_RESPONSE_EARLY')]
    for label, old, new, failure in mutations:
        assert text.count(old) == 1
        mutant = out/f'{label}.sv'
        with mutant.open('x') as f:
            f.write(text.replace(old, new))
        one(label, 'tb_staging127', mutant, E/'tb_staging127.sv', {}, failure=failure)
    after = {str(p): sha(p) for p in inputs}
    assert before == after
    summary = {'accepted_parent_local_functional': True, 'independent_result_acceptance': False,
               'native_quartus_or_questa_run': False, 'timing_accepted': False, 'hardware_access': False,
               'inputs_unchanged': before == after, 'inputs': before, 'tests': tests}
    dump(out/'summary.json', summary)
    print(json.dumps({'local_functional_pass': True, 'positive_tests': sum(t['kind']=='real_candidate_functional_simulation' for t in tests),
                      'mutants_rejected': sum(t['kind']=='synthetic_broken_RTL_mutant' for t in tests), 'inputs_unchanged': before == after}))


if __name__ == '__main__':
    main()
