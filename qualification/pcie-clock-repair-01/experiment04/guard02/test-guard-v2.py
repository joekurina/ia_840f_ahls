#!/usr/bin/env python3
"""Inert Tcl guard differential; distinct mock objects/collections, no vendor calls."""
from pathlib import Path
import ctypes
import ctypes.util
import hashlib
import json

ROOT = Path(__file__).resolve().parent
LIB = ctypes.CDLL(ctypes.util.find_library('tcl8.6'))
LIB.Tcl_CreateInterp.restype = ctypes.c_void_p
LIB.Tcl_Eval.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
LIB.Tcl_Eval.restype = ctypes.c_int
LIB.Tcl_GetStringResult.argtypes = [ctypes.c_void_p]
LIB.Tcl_GetStringResult.restype = ctypes.c_char_p
LIB.Tcl_DeleteInterp.argtypes = [ctypes.c_void_p]
MOCK = r'''
set fault {}
set calls 0
set serial 0
set collections [dict create]
set events {}
proc puts {args} {lappend ::events [list puts [lindex $args end]]}
proc flush {args} {lappend ::events [list flush {*}$args]}
proc collection {objects} {
    set key COL[incr ::serial];dict set ::collections $key $objects;return $key
}
proc get_collection_size {key} {llength [dict get $::collections $key]}
proc foreach_in_collection {var key body} {
    uplevel 1 [list foreach $var [dict get $::collections $key] $body]
}
proc node_name {id} {
    set D $::ia840f_clock_repair::D
    switch -- $id {
        PIN_I {return "$D|inclk"}
        PIN_O {return "$D|clock_div2"}
        PIN_MASTER {return {sys_pll|iopll_0|tennm_pll|outclk[2]}}
        PIN_BASE {return INERT_BASE_PORT}
        CELL_D {return $D}
    }
    error "not a mock node ID: $id"
}
proc get_node_info {option id} {
    if {$option ne "-name"} {error "unsupported node option"};return [node_name $id]
}
proc get_pins {args} {
    set name [lindex [lindex $args end] 0]
    foreach {id side} {PIN_I input PIN_O output} {
        if {$name eq [node_name $id]} {
            if {$side eq "output" && $::calls && $::fault eq "post_output_missing"} {return [collection {}]}
            if {$side eq "output" && $::calls && $::fault eq "post_output_multiple"} {return [collection {PIN_O PIN_O}]}
            if {$::fault eq "${side}_missing"} {return [collection {}]}
            if {$::fault eq "${side}_multiple"} {return [collection [list $id $id]]}
            return [collection [list $id]]
        }
    }
    return [collection {}]
}
proc get_pin_info {option id} {
    switch -- $option {
        -name {return [node_name $id]}
        -is_clock_pin {return [expr {$::fault ne "not_clock_pin"}]}
        -is_in_pin {return [expr {$id eq "PIN_I"}]}
        -is_out_pin {return [expr {$id eq "PIN_O"}]}
    }
    error "unsupported pin option $option"
}
proc get_cells {args} {
    if {$::fault eq "divider_missing"} {return [collection {}]}
    if {$::fault eq "divider_multiple"} {return [collection {CELL_D CELL_D}]}
    return [collection {CELL_D}]
}
proc get_cell_info {option id} {
    if {$option eq "-name"} {return [node_name $id]}
    if {$option eq "-wysiwyg_type"} {return [expr {$::fault eq "wrong_divider" ? "tennm_ff" : "tennm_clk_divider"}]}
    error "unsupported cell option"
}
proc get_fanins {args} {
    return [collection [expr {$::fault eq "wrong_fanin" ? {PIN_BASE} : {PIN_MASTER}}]]
}
proc get_clocks {args} {
    set M $::ia840f_clock_repair::M;set C $::ia840f_clock_repair::C
    if {[lsearch -exact $args -of_objects]>=0} {
        set objects [dict get $::collections [lindex $args end]]
        if {$objects eq {PIN_I}} {
            return [collection [expr {$::fault eq "wrong_incoming" ? {CLK_B} : {CLK_M}}]]
        }
        if {$objects ne {PIN_O}} {error "unexpected association collection $objects"}
        if {$::calls} {return [collection [expr {$::fault eq "wrong_propagation" ? {CLK_M} : {CLK_C}}]]}
        if {$::fault eq "empty_output_association"} {return [collection {}]}
        if {$::fault eq "extra_output_association"} {return [collection {CLK_M CLK_B}]}
        return [collection {CLK_M}]
    }
    set name [lindex [lindex $args end] 0]
    if {$name eq $M} {
        if {$::fault eq "master_missing"} {return [collection {}]}
        if {$::fault eq "master_multiple"} {return [collection {CLK_M CLK_M}]}
        return [collection {CLK_M}]
    }
    if {$name eq $C} {
        if {$::calls || $::fault eq "existing_name"} {return [collection {CLK_C}]}
        return [collection {}]
    }
    if {$name eq "*"} {
        if {$::fault eq "clock_cap"} {return [collection [lrepeat 257 CLK_M]]}
        set clocks {CLK_B CLK_M}
        if {$::fault eq "duplicate_clock"} {lappend clocks CLK_M}
        if {$::calls || $::fault eq "existing_name"} {lappend clocks CLK_C}
        return [collection $clocks]
    }
    error "unexpected mock clock selector"
}
proc get_clock_info {option id} {
    set M $::ia840f_clock_repair::M;set C $::ia840f_clock_repair::C
    if {$id ni {CLK_B CLK_M CLK_C}} {error "not a clock ID $id"}
    if {$id eq "CLK_B" && $option in {-master_clock -master_clock_pin -divide_by -multiply_by -edges -edge_shifts -is_inverted}} {error "generated-only property queried on base"}
    switch -- $option {
        -name {return [dict get [dict create CLK_B INERT_BASE CLK_M $M CLK_C $C] $id]}
        -type {return [expr {$id eq "CLK_B" || ($id eq "CLK_C" && $::fault eq "wrong_type") ? "base" : "generated"}]}
        -targets {
            if {$id eq "CLK_B"} {return [collection {PIN_BASE}]}
            if {$id eq "CLK_M"} {return [collection [expr {$::fault eq "existing_target" ? {PIN_O} : {PIN_MASTER}}]]}
            if {$::fault eq "multiple_targets"} {return [collection {PIN_O PIN_I}]}
            return [collection [expr {$::fault eq "wrong_target" ? {PIN_I} : {PIN_O}}]]
        }
        -master_clock {return [expr {$id eq "CLK_M" || $::fault eq "wrong_master" ? "INERT_BASE" : $M}]}
        -master_clock_pin {return [expr {$id eq "CLK_M" || $::fault eq "wrong_source" ? "INERT_BASE_PORT" : [node_name PIN_I]}]}
        -period {
            if {$id eq "CLK_B"} {return 100.000}
            if {$id eq "CLK_M"} {return [expr {$::calls && $::fault eq "other_clock_mutation" ? "10.000" : "9.929"}]}
            if {$::fault eq "wrong_period"} {return 19.870}
            return [expr {$::fault eq "rounded_period" ? "19.857" : "19.858"}]
        }
        -waveform {
            if {$id eq "CLK_B"} {return {0.000 50.000}}
            if {$id eq "CLK_M"} {return {0.000 4.964}}
            if {$::fault eq "wrong_waveform"} {return {0.000 9.940}}
            if {$::fault eq "wrong_phase"} {return {0.010 9.939}}
            return {0.000 9.929}
        }
        -divide_by {return [expr {$id eq "CLK_M" ? 14 : ($::fault eq "wrong_divide" ? 3 : 2)}]}
        -multiply_by {return [expr {$id eq "CLK_M" ? 141 : ($::fault eq "wrong_multiply" ? 2 : 1)}]}
        -is_inverted {return [expr {$id eq "CLK_C" && $::fault eq "inverted"}]}
        -edges {return {1 3 5}}
        -edge_shifts {return {0.000 0.000 0.000}}
    }
    error "unsupported mock clock property $option"
}
proc create_generated_clock {args} {
    if {[llength $args]!=9 || [lrange $args 0 1] ne [list -name $::ia840f_clock_repair::C] || [lindex $args 2] ne "-source" || [lindex $args 4] ne "-master_clock" || [lindex $args 5] ne $::ia840f_clock_repair::M || [lrange $args 6 7] ne {-divide_by 2}} {error "wrong creation grammar $args"}
    if {[dict get $::collections [lindex $args 3]] ne {PIN_I} || [dict get $::collections [lindex $args 8]] ne {PIN_O}} {error "wrong creation collections"}
    incr ::calls
}
'''


def evaluate(interp, source):
    rc = LIB.Tcl_Eval(interp, source.encode())
    return rc, LIB.Tcl_GetStringResult(interp).decode()


def main():
    helper = (ROOT / 'clock-repair.tcl').read_text()
    records = []
    cases = [('old_measured_association', '', 'apply', True, 0)]
    cases += [('new_positive', '', 'apply_v2', False, 1), ('rounding_bound', 'rounded_period', 'apply_v2', False, 1)]
    pre = ['input_missing', 'input_multiple', 'output_missing', 'output_multiple', 'not_clock_pin', 'divider_missing', 'divider_multiple', 'wrong_divider', 'master_missing', 'master_multiple', 'wrong_fanin', 'wrong_incoming', 'empty_output_association', 'extra_output_association', 'existing_name', 'existing_target', 'clock_cap', 'duplicate_clock']
    post = ['wrong_propagation', 'wrong_type', 'multiple_targets', 'wrong_target', 'wrong_master', 'wrong_source', 'wrong_period', 'wrong_waveform', 'wrong_phase', 'wrong_divide', 'wrong_multiply', 'inverted', 'other_clock_mutation']
    cases += [(f, f, 'apply_v2', True, 0) for f in pre]
    cases += [(f, f, 'apply_v2', True, 1) for f in post]
    cases += [(f, f, 'apply_v2', True, 1) for f in ['post_output_missing', 'post_output_multiple']]
    for name, fault, entry, reject, calls in cases:
        interp = LIB.Tcl_CreateInterp()
        try:
            for source in (MOCK, helper, 'set fault {' + fault + '}'):
                rc, msg = evaluate(interp, source)
                if rc:
                    raise RuntimeError((name, rc, msg))
            command = '::ia840f_clock_repair::' + entry
            if entry == 'apply_v2':
                command += '; ::ia840f_clock_repair::verify_created_v2'
            rc, msg = evaluate(interp, command)
            actual_calls = int(evaluate(interp, 'set calls')[1])
            ok = (rc == 1 and 'CLOCK_REPAIR_REJECT' in msg) if reject else rc == 0
            if not ok or actual_calls != calls:
                raise RuntimeError((name, rc, msg, actual_calls, calls))
            if not reject:
                rr, rm = evaluate(interp, '::ia840f_clock_repair::apply_v2')
                if rr != 1 or 'second invocation' not in rm or int(evaluate(interp, 'set calls')[1]) != 1:
                    raise RuntimeError('rerun was not rejected')
            ordered = False
            if fault in ('post_output_missing', 'post_output_multiple'):
                count = 0 if fault == 'post_output_missing' else 2
                check = ('expr {[lindex $::events end-1] eq [list puts [list CLOCK_REPAIR_COUNT_V2 post-output-pin '
                         + str(count) + ' cap 32]] && [lindex $::events end] eq {flush stdout}'
                         + ' && $::ia840f_clock_repair::created == 1}')
                rr, rm = evaluate(interp, check)
                if rr or rm != '1':
                    raise RuntimeError((name, 'missing count/flush ordering or created flag', rm))
                rr, rm = evaluate(interp, '::ia840f_clock_repair::apply_v2')
                if rr != 1 or 'second invocation' not in rm or int(evaluate(interp, 'set calls')[1]) != 1:
                    raise RuntimeError('postfailure rerun was not rejected')
                ordered = True
            records.append({'case': name, 'pass': True, 'expected_rejection': reject,
                            'create_calls': actual_calls, 'post_pin_count_flush_order': ordered})
        finally:
            LIB.Tcl_DeleteInterp(interp)
    print(json.dumps({'scope': 'inert control/guard tests, not native semantics or insertion-state proof', 'count': len(records), 'tests': records, 'helper_sha256': hashlib.sha256((ROOT/'clock-repair.tcl').read_bytes()).hexdigest(), 'test_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}, indent=2))


if __name__ == '__main__':
    main()
