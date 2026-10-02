"""Analyze captured STA data only. Does not invoke vendor or remote tools."""
import datetime
import hashlib
import importlib.util
import json
import re
from collections import Counter
from decimal import Decimal
from pathlib import Path

E = Path(__file__).resolve().parent
D = E / 'completion24-readback'
R = json.loads((D / 'operation/result.json').read_text())
M = json.loads((D / 'control/sta-inputs.admitted.json').read_text())
report = D / 'reports/ofs_pr_afu.sta.rpt'
lines = report.read_text().splitlines()
drc_path = D / 'reports/ofs_pr_afu.tq.drc.signoff.rpt'
drc_lines = drc_path.read_text().splitlines()

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def table(source_lines, title, occurrence=0):
    starts = [i for i, line in enumerate(source_lines)
              if line.startswith(';') and line.count(';') == 2
              and line.split(';')[1].strip() == title]
    start = starts[occurrence]
    border = source_lines[start + 1]
    assert border.startswith('+')
    positions = [i for i, char in enumerate(border) if char == '+']
    assert len(positions) > 2
    def cells(line):
        assert len(line) == len(border), (title, len(line), len(border))
        assert all(line[p] == ';' for p in positions)
        return [line[a + 1:b].strip() for a, b in zip(positions, positions[1:])]
    header = cells(source_lines[start + 2])
    assert source_lines[start + 3] == border
    rows = []
    cursor = start + 4
    while source_lines[cursor] != border:
        row = cells(source_lines[cursor])
        rows.append({'line': cursor + 1, 'cells': row})
        cursor += 1
    return {'title': title, 'heading_line': start + 1, 'end_line': cursor + 1,
            'header': header, 'count': len(rows), 'rows': rows}

# Recompute the reviewed screen from exact captured raw bodies.
module_path = E / 'candidate06/sta_numeric06.py'
assert sha(module_path) == M['numeric_module_sha256']
spec = importlib.util.spec_from_file_location('captured_numeric25', module_path)
assert spec and spec.loader
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
values = [(D / 'reports' / name).read_text() for name in (
    'ofs_pr_afu.sta.summary', 'clocks.sta.pass.summary',
    'clocks.sta.fail.summary', 'user_clock_freq.txt')]
with report.open() as stream:
    corners = module.report_corners(stream)
screen = module.screen(*values, corners)
assert screen == R['numerical_screen']
assert R['numeric_parse_valid'] and R['numeric_screen_pass'] and R['execution_clean']
assert not R['timing_accepted'] and not screen['timing_accepted']
counts = {}
for name in ('main', 'hook_pass', 'hook_fail'):
    group = screen[name]
    assert group['line_accounting_complete'] and not group['invalid_records'] and not group['errors']
    assert group['type_occurrences'] == len(group['records'])
    for row in group['records']:
        slack = Decimal(row['slack'])
        assert slack.is_finite() and slack >= 0
        if row.get('tns') is not None:
            tns = Decimal(row['tns'])
            assert tns.is_finite() and tns == 0
    counts[name] = {'records': len(group['records']),
                    'families': dict(Counter(x['family'] for x in group['records']))}

panels = {}
for title in ('Clocks', 'Clock Status Summary', 'Unconstrained Paths Summary',
              'SDC File List', 'Setup Summary', 'Hold Summary', 'Recovery Summary',
              'Removal Summary', 'Minimum Pulse Width Summary'):
    panels[title] = table(lines, title)
for title in ('Unconstrained Input Ports', 'Unconstrained Output Ports'):
    for occurrence in range(2):
        panels[title + str(occurrence)] = table(lines, title, occurrence)
clock_panel = panels['Clocks']
clock_rows = [dict(zip(clock_panel['header'], x['cells']), line=x['line']) for x in clock_panel['rows']]
app_rows = [x for x in clock_rows if x['Clock Name'] == module.APPLICATION_CLOCK]
assert len(app_rows) == 1 and app_rows[0]['Period'] == '3.000'
app_records = {name: [x for x in screen[name]['records'] if x.get('clock') == module.APPLICATION_CLOCK]
               for name in ('main', 'hook_pass', 'hook_fail')}
assert len(app_records['main']) == 5 and len(app_records['hook_pass']) == 25 and not app_records['hook_fail']

headings = [{'line': i, 'title': line.split(';')[1].strip()}
            for i, line in enumerate(lines, 1) if line.startswith(';') and line.count(';') == 2]
drc_titles = [line.split(';')[1].strip() for line in drc_lines
              if line.startswith(';') and line.count(';') == 2
              and 'Design Assistant (Signoff) Results - ' in line]
assert len(drc_titles) == 1
drc_summary = table(drc_lines, drc_titles[0])
log = (D / 'operation/timing.log').read_text().splitlines()
diagnostics = [{'line': i, 'severity': m[1], 'code': m[2], 'text': line}
               for i, line in enumerate(log, 1)
               if (m := re.match(r'^(Critical Warning|Warning|Error) \((\d+)\):', line))]
footers = [{'line': i, 'text': line} for i, line in enumerate(log, 1)
           if 'Timing Analyzer was successful.' in line]
assert len(footers) == 1
footer_counts = re.search(r'(\d+) errors, (\d+) warnings', footers[0]['text'])
assert footer_counts and int(footer_counts[1]) == 0
assert int(footer_counts[2]) == len(diagnostics) == 379
runtime = {'unchanged': [], 'changed': [], 'removed': []}
for name, row in R['runtime_outputs_after'].items():
    before, after = row['before'], row['after']
    if not after['exists']:
        runtime['removed'].append(name)
    elif all(after.get(k) == v for k, v in before.items()):
        runtime['unchanged'].append(name)
    else:
        runtime['changed'].append({'path': name, **row})
assert sum(map(len, runtime.values())) == 26
assert all(c['cmake_rc'] == c['effective_rc'] == 0 and not c['owned_group_live_after'] for c in R['commands'])
assert all(c['native_rc'] == 0 for c in R['commands'] if c['label'] != 'configure')
assert R['qpf_changed'] is False and not R['postflight_errors'] and not R['diagnostics']
result = {
    'scope': 'completed STA acquisition and initial numerical verification; independent coverage review pending',
    'execution_clean': True, 'screen_recomputed_equal': True, 'screen_pass': True, 'timing_accepted': False,
    'hardware_access': False, 'result_sha256': sha(D / 'operation/result.json'),
    'manifest_sha256': sha(D / 'control/sta-inputs.admitted.json'),
    'report_sha256': sha(report), 'drc_report_sha256': sha(drc_path),
    'started': R['started'], 'ended': R['ended'],
    'elapsed_seconds': (datetime.datetime.fromisoformat(R['ended']) - datetime.datetime.fromisoformat(R['started'])).total_seconds(),
    'counts': counts, 'family_summaries': screen['family_summaries'],
    'corner_evidence': screen['corner_evidence'], 'unresolved': screen['unresolved'],
    'frequencies': screen['frequencies'], 'clock_count': len(clock_rows),
    'application_clock': app_rows[0], 'application_records': app_records,
    'diagnostic_counts': dict(Counter(x['severity'] for x in diagnostics)),
    'diagnostic_codes': dict(Counter(x['code'] for x in diagnostics)), 'footer': footers[0],
    'qdb_files': len(R['qdb_outputs']), 'qdb_bytes': sum(x['bytes'] for x in R['qdb_outputs'].values()),
    'runtime_counts': {k: len(v) for k, v in runtime.items()}, 'qpf_byte_identical': True,
    'limits': ['zero hold/MPW is nonnegative, not positive margin',
               'whole-record screen is not complete endpoint/exception/CDC/reset/electrical acceptance',
               'one setup path per clock and summary populations do not prove every passing path',
               'user-clock metadata100/200 is distinct from bank0 application3.000ns']}
outputs = {'native-result-verification25.json': result, 'diagnostics25.json': diagnostics,
           'report-panels25.json': {'source': str(report.relative_to(E)), 'sha256': sha(report), 'panels': panels,
                                    'drc_source': str(drc_path.relative_to(E)), 'drc_sha256': sha(drc_path), 'drc': drc_summary},
           'report-sections25.json': headings, 'runtime-output-deltas25.json': runtime}
assert all(not (E / name).exists() for name in outputs)
for name, data in outputs.items():
    with (E / name).open('x') as stream:
        json.dump(data, stream, indent=2)
        stream.write('\n')
print(json.dumps({k: result[k] for k in ('execution_clean', 'screen_pass', 'timing_accepted', 'elapsed_seconds',
                                       'counts', 'clock_count', 'application_clock', 'diagnostic_counts',
                                       'qdb_files', 'qdb_bytes', 'runtime_counts')}, indent=2))
