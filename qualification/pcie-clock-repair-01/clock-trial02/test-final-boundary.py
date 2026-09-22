#!/usr/bin/env python3
"""Focused insertion/final-boundary regression using existing inert guard mocks."""
from pathlib import Path
import importlib.util
import json
import hashlib

ROOT = Path(__file__).resolve().parent
V = ROOT.parent / 'experiment04/guard02'
spec = importlib.util.spec_from_file_location('guard_fixture', V / 'test-guard-v2.py')
if spec is None or spec.loader is None:
    raise RuntimeError('missing saved guard fixture')
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)
EXTRA = r'''
set late 0
set extra_count 78
set mutate_late 0
rename get_clocks fixture_get_clocks
proc get_clocks {args} {
    set result [fixture_get_clocks {*}$args]
    if {[llength $args] == 1 && [lindex $args 0] eq "*"} {
        set ids [dict get $::collections $result]
        for {set i 0} {$i < $::extra_count} {incr i} {
            if {$i < 75 || $::late} {lappend ids EXTRA_$i}
        }
        return [collection $ids]
    }
    return $result
}
rename get_clock_info fixture_get_clock_info
proc get_clock_info {option id} {
    if {[string match EXTRA_* $id]} {
        switch -- $option {
            -name {return INERT_$id}
            -type {return base}
            -period {return [expr {$::mutate_late && $id eq "EXTRA_75" ? "125.000" : "100.000"}]}
            -waveform {return {0.000 50.000}}
            -targets {return [collection {PIN_BASE}]}
        }
        error "unexpected extra-clock property $option"
    }
    return [fixture_get_clock_info $option $id]
}
'''


def main():
    rows = []
    cases = [
        ('old_final_rejects_late_clocks', '', True, 'verify_created_v2'),
        ('new_final_accepts_pinned_late_clocks', '', False, 'verify_created_final_v3 $expected'),
        ('unlisted_late_clock', 'set extra_count 79', True, 'verify_created_final_v3 $expected'),
        ('missing_late_clock', 'set extra_count 77', True, 'verify_created_final_v3 $expected'),
        ('changed_late_clock', 'set mutate_late 1', True, 'verify_created_final_v3 $expected'),
        ('wrong_generated_source', 'set fault wrong_source', True, 'verify_created_final_v3 $expected'),
        ('wrong_generated_ratio', 'set fault wrong_divide', True, 'verify_created_final_v3 $expected'),
        ('lost_output_propagation', 'set fault wrong_propagation', True, 'verify_created_final_v3 $expected'),
        ('missing_post_output_pin', 'set fault post_output_missing', True, 'verify_created_final_v3 $expected'),
    ]
    helper = (ROOT / 'clock-repair.tcl').read_text()
    prefix = (V / 'clock-repair.tcl').read_text()
    assert helper.startswith(prefix)
    for name, mutation, reject, verifier in cases:
        interp = g.LIB.Tcl_CreateInterp()
        try:
            for source in [g.MOCK, EXTRA, (ROOT / 'scope-collections.tcl').read_text(),
                           (ROOT / 'clock-inventory.tcl').read_text(), helper]:
                rc, msg = g.evaluate(interp, source)
                assert rc == 0, (name, rc, msg)
            # Independent synthetic final baseline first; candidate cannot set it.
            rc, msg = g.evaluate(interp, '''set ::ia840f_compare04::audit AUDIT
set late 1
set expected [::ia840f_clock_repair::snapshot_v2]
set late 0
::ia840f_clock_repair::apply_v2
set insertion_snapshot $::ia840f_clock_repair::before_v2
set late 1''')
            assert rc == 0, (name, rc, msg)
            if mutation:
                rc, msg = g.evaluate(interp, mutation)
                assert rc == 0, (name, rc, msg)
            rc, msg = g.evaluate(interp, '::ia840f_clock_repair::' + verifier)
            assert (rc == 1 and '_REJECT' in msg) if reject else rc == 0, (name, rc, msg)
            rr, rm = g.evaluate(interp, 'expr {$::calls == 1 && $::ia840f_clock_repair::created && $insertion_snapshot eq $::ia840f_clock_repair::before_v2 && [dict size $expected] == 80 && [dict size $insertion_snapshot] == 77}')
            assert rr == 0 and rm == '1', (name, rr, rm)
            retry_rc, retry_msg = g.evaluate(interp, '::ia840f_clock_repair::apply_v2')
            assert retry_rc == 1 and 'second invocation' in retry_msg
            rows.append({'case': name, 'pass': True, 'rc': rc, 'message': msg,
                         'insertion_snapshot_unchanged': True, 'retry_rejected': True})
        finally:
            g.LIB.Tcl_DeleteInterp(interp)
    print(json.dumps({'scope': 'synthetic late-clock boundary only, not native evidence',
                      'count': len(rows), 'tests': rows,
                      'helper_sha256': hashlib.sha256((ROOT / 'clock-repair.tcl').read_bytes()).hexdigest()}, indent=2))


if __name__ == '__main__':
    main()
