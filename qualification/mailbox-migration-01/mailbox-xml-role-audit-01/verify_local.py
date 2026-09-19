#!/usr/bin/env python3
"""Local Python-only verification; write exclusively below this audit deliverable."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.parent.resolve() != HERE:
        parser.error('verification output must be a fresh direct child of audit directory')
    args.output.mkdir(mode=0o700, exist_ok=False)
    out = args.output
    records = json.loads((HERE / 'evidence/reference-inputs.json').read_text())
    before = {r['path']: digest(Path(r['path'])) for r in records}
    for name in ('audit.py', 'test_audit.py', 'verify_local.py'):
        (out / name).write_bytes((HERE / name).read_bytes())
    results = dict(started_utc=datetime.now(timezone.utc).isoformat(), cwd='/home/joe',
                   python=sys.version, executable=sys.executable,
                   executable_sha256=digest(Path(sys.executable).resolve()),
                   source_snapshots={name: digest(out / name) for name in ('audit.py', 'test_audit.py', 'verify_local.py')},
                   original_input_hashes=before, runs=[], flags=dict(authorized=False,
                   ready_for_build=False, migration_approved=False, diagnostic_execution=False,
                   vendor_execution=False, rtl_backpressure_certified=False))

    def run(label, argv):
        r = subprocess.run(argv, cwd='/home/joe', capture_output=True, text=True, timeout=120)
        (out / (label + '.stdout')).write_text(r.stdout)
        (out / (label + '.stderr')).write_text(r.stderr)
        results['runs'].append(dict(label=label, argv=argv, returncode=r.returncode))
        return r

    test = run('tests', [sys.executable, '-B', str(HERE / 'test_audit.py')])
    paths = {Path(r['path']).name: r['path'] for r in records}
    argv = [sys.executable, '-B', str(HERE / 'audit.py'),
            '--leaf', paths['sdm_mailbox.ip'], '--child', paths['bmc_spi_sub.qsys'],
            '--parent', paths['bw_840_support.qsys'], '--output', str(out / 'baseline')]
    baseline = run('baseline', argv)
    report = json.loads((out / 'baseline/report.json').read_text())
    baseline_hashes = {p.name: digest(p) for p in (out / 'baseline').iterdir()}
    collision = run('exclusive-reuse-rejected', argv)
    results['exclusive_reuse_unchanged'] = baseline_hashes == {p.name: digest(p) for p in (out / 'baseline').iterdir()}
    results['sources_unchanged'] = all(digest(Path(path)) == value for path, value in before.items())
    results['sources_match_initial_reference'] = all(before[r['path']] == r['sha256'] for r in records)
    findings = [f for source in report['inputs'] for f in source['findings']]
    results['baseline_finding_counts'] = dict(Counter(f['code'] for f in findings))
    results['coverage'] = {r['kind']: r['coverage'] for r in report['inputs']}
    results['baseline_summary'] = [dict(kind=r['kind'], parse_complete=r['parse_complete'],
        required_coverage_complete=r['required_coverage_complete'], representations=len(r['representations']),
        embedded_documents=len(r['embedded']), parsed_nodes=r['parsed_nodes'],
        findings=dict(Counter(f['code'] for f in r['findings']))) for r in report['inputs']]
    missing = [f for f in findings if f['code'] == 'missing_required_role']
    expected = len(missing) == 4 and all(f['detail'] == 'waitrequest' for f in missing)
    results['expected_baseline_missing_waitrequest'] = expected
    results['verified'] = (test.returncode == 0 and baseline.returncode == 2 and
        collision.returncode != 0 and results['exclusive_reuse_unchanged'] and
        results['sources_unchanged'] and results['sources_match_initial_reference'] and expected and
        all(r['parse_complete'] and r['required_coverage_complete'] for r in report['inputs']) and
        not any(f['code'] in ('duplicate_avalon_role', 'physical_name_collision') for f in findings) and
        not any(report['flags'].values()))
    results['finished_utc'] = datetime.now(timezone.utc).isoformat()
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    manifest = {str(p.relative_to(out)): digest(p) for p in sorted(out.rglob('*')) if p.is_file()}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(dict(verified=results['verified'], baseline_summary=results['baseline_summary'],
                          baseline_finding_counts=results['baseline_finding_counts']), indent=2))
    return 0 if results['verified'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
