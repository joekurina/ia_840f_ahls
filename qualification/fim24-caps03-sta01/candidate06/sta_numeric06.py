"""Whole-record STA screening; never grants timing/coverage acceptance."""
import collections
from decimal import Decimal, InvalidOperation
import re

DASH = '-' * 60
HEADER = [DASH, 'Timing Analyzer Summary', DASH]
FOOTER = [DASH, 'Info: see the "DDR report" for DDR timing results', DASH, DASH]
TIMING_FAMILIES = ('Setup', 'Hold', 'Recovery', 'Removal', 'Minimum Pulse Width')
HOOK_FAMILIES = {'setup': 'Setup', 'hold': 'Hold', 'recovery': 'Recovery', 'removal': 'Removal', 'mpw': 'Minimum Pulse Width'}
CORNER_TOKENS = {
    'Slow vid2 100C Model': '2_slow_vid2_100c',
    'Slow vid2b 100C Model': '2_slow_vid2b_100c',
    'Fast vid2a 0C Model': 'MIN_fast_vid2a_0c',
    'Fast vid2a 100C Model': 'MIN_fast_vid2a_100c',
    'Fast vid2 100C Model': 'MIN_fast_vid2_100c',
}
NUMBER = re.compile(r'[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?\Z')
APPLICATION_CLOCK = 'local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk'


def exact_number(token):
    if not NUMBER.fullmatch(token):
        raise ValueError('invalid complete numeric token: '+repr(token))
    try:
        value = Decimal(token)
    except InvalidOperation as exc:
        raise ValueError('unrepresentable decimal token') from exc
    if not value.is_finite():
        raise ValueError('nonfinite decimal token')
    return value


def parse_summary(text, source, kind):
    """Retain every record/line, with family-specific field requirements."""
    if kind not in ('main', 'hook_pass', 'hook_fail'):
        raise ValueError('unrecognized summary role')
    lines = text.splitlines()
    records, invalid, errors, outside = [], [], [], []
    current = []
    seen = 0
    i = 0
    while i < len(lines) and not lines[i].strip():
        outside.append({'line': i+1, 'role': 'blank'})
        i += 1
    if kind == 'main':
        if lines[i:i+3] == HEADER:
            outside.extend({'line': j+1, 'role': 'header'} for j in range(i, i+3))
            i += 3
        else:
            errors.append({'source': source, 'line': i+1, 'error': 'missing exact native summary header'})

    def finish():
        nonlocal current
        if not current:
            return
        record = {'source': source, 'ordinal': seen, 'line': current[0]['line'], 'raw_lines': current[:], 'kind': kind}
        fields = []
        try:
            for row in current:
                match = re.fullmatch(r'\s*(Type|Slack|TNS|Corner)\s*:\s*(.*?)\s*', row['text'])
                if match is None:
                    raise ValueError('unknown/orphan field inside record')
                key, value = match.groups()
                if key in dict(fields):
                    raise ValueError('duplicate field: '+key)
                fields.append((key, value))
            values = dict(fields)
            typ = values.get('Type', '')
            record['fields'] = values
            record['field_order'] = [k for k, _ in fields]
            if kind == 'main':
                clock = re.fullmatch(r"(Setup|Hold|Recovery|Removal|Minimum Pulse Width) '([^'\r\n]+)'", typ)
                skew = re.fullmatch(r"(.+ Model) Max Skew '(set_max_skew)'", typ)
                delay = re.fullmatch(r"Net Delay '(set_net_delay)'", typ)
                if clock:
                    family, label = clock.groups()
                    expected = ['Type', 'Slack', 'TNS', 'Corner']
                    corner = values.get('Corner', '')
                    if not corner or not re.fullmatch(r'(?:Slow|Fast) .+ Model', corner):
                        raise ValueError('invalid native corner field')
                    record.update(family=family, clock=label, corner=corner, constraint=False)
                elif skew:
                    corner, label = skew.groups()
                    expected = ['Type', 'Slack']
                    record.update(family='Max Skew', label=label, corner=corner, constraint=True)
                elif delay:
                    expected = ['Type', 'Slack']
                    record.update(family='Net Delay', label=delay.group(1), corner=None, constraint=True)
                else:
                    raise ValueError('unknown native Type shape/family')
            else:
                hook = re.fullmatch(r"(\S+) (setup|hold|recovery|removal|mpw) '([^'\r\n]+)'", typ)
                if hook is None:
                    raise ValueError('unknown hook Type shape/family')
                corner, short, label = hook.groups()
                expected = ['Type', 'Slack', 'TNS']
                record.update(family=HOOK_FAMILIES[short], clock=label, corner=corner, constraint=False)
            if record['field_order'] != expected:
                raise ValueError('missing, extra or reordered fields')
            slack = exact_number(values['Slack'])
            record['slack'] = values['Slack']
            if 'TNS' in values:
                exact_number(values['TNS'])
                record['tns'] = values['TNS']
            if kind == 'hook_pass' and slack < 0:
                record['placement_error'] = 'negative slack in pass summary'
            if kind == 'hook_fail' and slack >= 0:
                record['placement_error'] = 'nonnegative slack in fail summary'
            records.append(record)
        except (ValueError, KeyError, InvalidOperation) as exc:
            record['error'] = str(exc)
            invalid.append(record)
        current = []

    while i < len(lines):
        raw = lines[i]
        if not raw.strip():
            finish()
            outside.append({'line': i+1, 'role': 'blank'})
            i += 1
            continue
        if kind == 'main' and raw == DASH:
            finish()
            if lines[i:i+4] == FOOTER and all(not s.strip() for s in lines[i+4:]):
                outside.extend({'line': j+1, 'role': 'DDR footer'} for j in range(i, i+4))
                outside.extend({'line': j+1, 'role': 'blank'} for j in range(i+4, len(lines)))
                i = len(lines)
                break
            errors.append({'source': source, 'line': i+1, 'error': 'unexpected separator/footer position or body', 'text': raw})
            outside.append({'line': i+1, 'role': 'rejected'})
            i += 1
            continue
        if re.match(r'\s*Type\b', raw):
            finish()
            seen += 1
            current = [{'line': i+1, 'text': raw}]
        elif current:
            current.append({'line': i+1, 'text': raw})
        else:
            errors.append({'source': source, 'line': i+1, 'error': 'orphan/unrecognized line', 'text': raw})
            outside.append({'line': i+1, 'role': 'rejected'})
        i += 1
    finish()
    if seen == 0 and kind != 'hook_fail':
        errors.append({'source': source, 'line': 1, 'error': 'empty required record population'})
    accounted = [r['line'] for record in records+invalid for r in record['raw_lines']] + [r['line'] for r in outside]
    if sorted(accounted) != list(range(1, len(lines)+1)) or seen != len(records)+len(invalid):
        raise AssertionError('internal complete-line/record accounting defect')
    return {'source': source, 'kind': kind, 'line_count': len(lines), 'type_occurrences': seen,
            'records': records, 'invalid_records': invalid, 'errors': errors,
            'line_accounting_complete': True, 'outside_record_lines': outside,
            'parse_valid': not invalid and not errors}


def report_corners(lines):
    """Use actual per-model panels, not worst-corner aggregate cells."""
    panels = {'Max Skew Summary': [], 'Metastability Summary': []}
    for i, raw in enumerate(lines, 1):
        line = raw.rstrip('\r\n')
        if not line.startswith(';') or not line.rstrip().endswith(';'):
            continue
        cells = [c.strip() for c in line.strip()[1:-1].split(';')]
        if len(cells) != 1:
            continue
        for family in panels:
            prefix = family+' '
            if cells[0].startswith(prefix):
                panels[family].append({'line': i, 'corner': cells[0][len(prefix):]})
    sets = {k: set(x['corner'] for x in rows) for k, rows in panels.items()}
    unresolved = []
    if not all(sets.values()):
        unresolved.append('missing per-model corner panel family')
    if sets['Max Skew Summary'] != sets['Metastability Summary']:
        unresolved.append('per-model panel corner sets disagree')
    corners = sorted(set().union(*sets.values()))
    unknown = sorted(set(corners)-set(CORNER_TOKENS))
    if unknown:
        unresolved.append('unrecognized observed corner labels: '+repr(unknown))
    return {'corners': corners, 'panels': panels, 'unresolved': unresolved,
            'hook_tokens': {c: CORNER_TOKENS[c] for c in corners if c in CORNER_TOKENS}}


def parse_frequencies(text, source='user_clock_freq.txt'):
    values, errors, locations = {}, [], {}
    for i, raw in enumerate(text.splitlines(), 1):
        if not raw.strip():
            continue
        if raw == '# Generated by Platform Interface Manager user_clock_config.tcl' and not values and not locations:
            locations['header'] = i
            continue
        match = re.fullmatch(r'afu-image/clock-frequency-(low|high):([^\s]+)', raw)
        if match is None:
            errors.append({'source': source, 'line': i, 'error': 'unknown frequency metadata line', 'text': raw})
            continue
        key, token = match.groups()
        if key in values:
            errors.append({'source': source, 'line': i, 'error': 'duplicate frequency field', 'field': key})
            continue
        try:
            value = exact_number(token)
            if value < 0:
                raise ValueError('negative frequency')
            values[key] = token
            locations[key] = i
        except ValueError as exc:
            errors.append({'source': source, 'line': i, 'error': str(exc), 'field': key})
    if set(values) != {'low', 'high'}:
        errors.append({'source': source, 'line': 1, 'error': 'missing low/high frequency value'})
    return {'source': source, 'values': values, 'locations': locations, 'errors': errors, 'parse_valid': not errors}


def screen(main_text, pass_text, fail_text, frequency_text, corner_evidence, expected_clock=APPLICATION_CLOCK):
    main = parse_summary(main_text, 'ofs_pr_afu.sta.summary', 'main')
    passed = parse_summary(pass_text, 'clocks.sta.pass.summary', 'hook_pass')
    failed = parse_summary(fail_text, 'clocks.sta.fail.summary', 'hook_fail')
    freq = parse_frequencies(frequency_text)
    main_rows = main['records']
    hook_rows = passed['records']+failed['records']
    all_rows = main_rows+hook_rows
    violations, unresolved, duplicates = [], list(corner_evidence['unresolved']), []
    for row in all_rows:
        where = {k: row[k] for k in ('source', 'line', 'ordinal', 'family')}
        if exact_number(row['slack']) < 0:
            violations.append({**where, 'field': 'Slack', 'value': row['slack']})
        if 'tns' in row and exact_number(row['tns']) != 0:
            violations.append({**where, 'field': 'TNS', 'value': row['tns']})
        if 'placement_error' in row:
            unresolved.append({**where, 'error': row['placement_error']})
    main_domains = [r for r in main_rows if not r['constraint']]
    for label, rows, keyfn in (
        ('native_domain', main_domains, lambda r: (r['family'], r['clock'])),
        ('hook_domain', hook_rows, lambda r: (r['corner'], r['family'], r['clock'])),
    ):
        keyed = collections.defaultdict(list)
        for row in rows:
            keyed[keyfn(row)].append({'source': row['source'], 'line': row['line'], 'ordinal': row['ordinal']})
        for key, places in keyed.items():
            if len(places) > 1:
                duplicates.append({'kind': label, 'key': list(key), 'occurrences': places})
    if duplicates:
        unresolved.append('duplicate timing-domain identities require disposition')
    native_families = collections.Counter(r['family'] for r in main_rows)
    hook_families = collections.Counter(r['family'] for r in hook_rows)
    for name, counts in [('native', native_families), ('hook', hook_families)]:
        missing = sorted(set(TIMING_FAMILIES)-set(counts))
        if missing:
            unresolved.append({'source': name, 'missing_timing_families': missing})
    for family in ('Max Skew', 'Net Delay'):
        if native_families[family] == 0:
            unresolved.append({'source': 'native', 'missing_constraint_family': family})
    observed_corners = set(corner_evidence['corners'])
    hook_tokens = set(corner_evidence['hook_tokens'].values())
    unknown_native = sorted({r['corner'] for r in main_rows if r.get('corner')}-observed_corners)
    unknown_hook = sorted({r['corner'] for r in hook_rows}-hook_tokens)
    missing_hook = sorted(hook_tokens-{r['corner'] for r in hook_rows})
    if unknown_native or unknown_hook or missing_hook:
        unresolved.append({'native_corner_not_in_panels': unknown_native, 'hook_unknown_corners': unknown_hook, 'hook_missing_corners': missing_hook})
    native_keys = {(r['family'], r['clock']) for r in main_domains}
    hook_union = {(r['family'], r['clock']) for r in hook_rows}
    if native_keys != hook_union:
        unresolved.append({'native_only_domains': sorted(native_keys-hook_union), 'hook_only_domains': sorted(hook_union-native_keys), 'note': 'analysis-state/applicability review required; no assumed identical slack values'})
    critical_missing = []
    for family in TIMING_FAMILIES:
        if (family, expected_clock) not in native_keys:
            critical_missing.append(['native', family, expected_clock])
        for corner in sorted(hook_tokens):
            if not any(r['corner'] == corner and r['family'] == family and r['clock'] == expected_clock for r in hook_rows):
                critical_missing.append([corner, family, expected_clock])
    if critical_missing:
        unresolved.append({'missing_expected_application_domain': critical_missing})
    # Aggregate rows are not a Cartesian coverage oracle. Preserve per-corner
    # deltas for later applicability review rather than inventing missing paths.
    corner_domain_deltas = []
    for corner in sorted(hook_tokens):
        keys = {(r['family'], r['clock']) for r in hook_rows if r['corner'] == corner}
        delta = {'corner': corner, 'native_aggregate_only': sorted(native_keys-keys), 'hook_only': sorted(keys-native_keys), 'interpretation': 'applicability/analysis-state evidence required; not an automatic Cartesian requirement on worst-corner aggregates'}
        corner_domain_deltas.append(delta)
        if keys != native_keys:
            unresolved.append({'corner_population_requires_disposition': delta})
    summaries = {}
    for label, rows in [('native', main_rows), ('hook', hook_rows)]:
        by_family = {}
        for family in sorted({r['family'] for r in rows}):
            selected = [r for r in rows if r['family'] == family]
            minimum = min(selected, key=lambda r: exact_number(r['slack']))
            by_family[family] = {'count': len(selected), 'minimum_slack': minimum['slack'], 'minimum_location': {k: minimum[k] for k in ('source', 'line', 'ordinal')}}
        summaries[label] = by_family
    parse_valid = all(x['parse_valid'] for x in (main, passed, failed, freq))
    return {'scope': 'initial whole-record numerical screen, not timing/coverage acceptance',
            'timing_accepted': False, 'parse_valid': parse_valid,
            'numeric_pass': parse_valid and not violations,
            'screen_pass': parse_valid and not violations and not unresolved,
            'main': main, 'hook_pass': passed, 'hook_fail': failed, 'frequencies': freq,
            'corner_evidence': corner_evidence, 'violations': violations,
            'unresolved': unresolved, 'duplicate_domains': duplicates,
            'per_corner_domain_deltas': corner_domain_deltas,
            'family_summaries': summaries,
            'coverage_review_required': ['realized3.000ns and endpoint propagation', 'all-corner applicability', 'CDC/synchronizers/pointer skew/net-delay', 'effective exceptions/overwrites/unconstrained paths', 'signoffDRC/reset/electrical/entry sequence']}
