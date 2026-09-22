#!/usr/bin/env python3
"""Inert native-collection contract tests; no Quartus or remote operations."""
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
set serial 0
set pool [dict create]
set nodes [dict create PIN_O {DIV|clock_div2} REG_K {DIV~div_reg}]
set clocks [dict create CLK_M MASTER CLK_X OTHER]
set events {}
set forward_calls {}
set clock_arguments {}
proc puts {channel text} {
    if {$channel ne "AUDIT"} {error "unexpected fixture channel"}
    lappend ::events [list puts $text]
}
proc flush {channel} {lappend ::events [list flush $channel]}
proc collection {items} {set id COL[incr ::serial];dict set ::pool $id $items;return $id}
proc range_nodes {begin count} {
    set items {}
    for {set i $begin} {$i < $begin+$count} {incr i} {
        set id N$i;dict set ::nodes $id "node\[$i\]";lappend items $id
    }
    return $items
}
proc get_collection_size {id} {
    set n [llength [dict get $::pool $id]]
    if {$::fault eq "wrong_raw_count" && $n == 459} {return 458}
    return $n
}
proc foreach_in_collection {var id body} {uplevel 1 [list foreach $var [dict get $::pool $id] $body]}
proc get_node_info {option id} {
    if {$option ne "-name"} {error "unsupported node property"};return [dict get $::nodes $id]
}
proc get_pin_info {option id} {
    if {$option ne "-name" || $id ne "PIN_O"} {error "wrong pin property/ID"};return [dict get $::nodes $id]
}
proc get_clock_info {option id} {
    if {$option ne "-name"} {error "unsupported clock property"};return [dict get $::clocks $id]
}
proc get_pins {args} {
    if {$args ne [list -nowarn [list {DIV|clock_div2}]]} {error "wrong output selector"}
    if {$::fault eq "output_missing"} {return [collection {}]}
    if {$::fault eq "output_multiple"} {return [collection {PIN_O PIN_O}]}
    if {$::fault eq "output_wrong_name"} {dict set ::nodes PIN_O wrong}
    return [collection {PIN_O}]
}
proc get_keepers {args} {
    if {$args ne [list -nowarn [list {DIV~div_reg}]]} {error "unexpected name reconstruction"}
    if {$::fault eq "keeper_missing"} {return [collection {}]}
    if {$::fault eq "keeper_multiple"} {return [collection {REG_K REG_K}]}
    return [collection {REG_K}]
}
proc get_fanouts {args} {
    if {[llength $args] != 1} {error "edge filtering or altered native forward grammar"}
    set members [dict get $::pool [lindex $args 0]]
    if {$members ni {{PIN_O} {REG_K}}} {error "wrong forward root collection"}
    lappend ::forward_calls $members
    if {$::fault eq "union_cap"} {return [collection [range_nodes [expr {$members eq {PIN_O} ? 0 : 3000}] 3000]]}
    if {$::fault eq "pin_cap" && $members eq {PIN_O}} {return [collection [range_nodes 0 4097]]}
    if {$::fault eq "keeper_cap" && $members eq {REG_K}} {return [collection [range_nodes 0 4097]]}
    if {$::fault eq "empty_forward"} {return [collection {}]}
    set items [range_nodes 0 459]
    if {$::fault in {changed_set root_difference} && $members eq {REG_K}} {set items [concat [lrange $items 1 end] [range_nodes 459 1]]}
    if {$::fault eq "duplicate_member"} {lappend items N0}
    return [collection $items]
}
proc add_to_collection {left right} {
    set a [dict get $::pool $left];set b [dict get $::pool $right]
    if {$::fault eq "bad_union"} {return [collection [lrange $a 1 end]]}
    return [collection [lsort -unique [concat $a $b]]]
}
proc get_clocks {args} {
    if {[llength $args]!=3 || [lrange $args 0 1] ne {-nowarn -of_objects}} {error "wrong association grammar"}
    set members [dict get $::pool [lindex $args 2]]
    if {[llength $members]<2} {error "association query lost retained union"}
    lappend ::clock_arguments [lindex $args 2]
    if {$::fault eq "clock_cap"} {return [collection [lrepeat 257 CLK_M]]}
    if {$::fault eq "duplicate_clock"} {return [collection {CLK_M CLK_M}]}
    if {$::fault eq "empty_clocks"} {return [collection {}]}
    if {$::fault eq "mixed_clocks"} {return [collection {CLK_M CLK_X}]}
    return [collection {CLK_M}]
}
set expected {}
foreach n [range_nodes 0 459] {lappend expected [dict get $nodes $n]}
set expected [lsort $expected]
'''


def evaluate(p, text):
    rc = LIB.Tcl_Eval(p, text.encode())
    return rc, LIB.Tcl_GetStringResult(p).decode()


def main():
    source = (ROOT/'scope-collections.tcl').read_text()
    cases = [('baseline', '', False), ('candidate', '', False), ('candidate', 'mixed_clocks', False),
             ('baseline', 'empty_clocks', False), ('candidate', 'changed_set', False),
             ('baseline', 'changed_set', True)]
    for fault in ['output_missing','output_multiple','output_wrong_name','keeper_missing','keeper_multiple',
                  'pin_cap','keeper_cap','union_cap','empty_forward','duplicate_member','wrong_raw_count',
                  'bad_union','clock_cap','duplicate_clock']:
        cases.append(('baseline', fault, True))
    cases.append(('invalid', '', True))
    records = []
    for variant, fault, reject in cases:
        p = LIB.Tcl_CreateInterp()
        try:
            for s in [source, MOCK, 'set ::ia840f_compare04::audit AUDIT', 'set fault {'+fault+'}']:
                rc,msg=evaluate(p,s)
                if rc: raise RuntimeError(('fixture setup',rc,msg))
            rc,msg=evaluate(p,'set result [::ia840f_compare04::capture_scope {'+variant+'} DIV $expected]')
            if (reject and (rc!=1 or 'COMPARE04_REJECT' not in msg)) or (not reject and rc):
                raise RuntimeError((variant,fault,rc,msg))
            if not reject:
                checks = [
                    'expr {$::forward_calls eq [list [list PIN_O] [list REG_K]]}',
                    'expr {[lindex $::clock_arguments 0] eq [dict get $result union_collection]}',
                    'expr {[dict get $result union_names] eq [lsort -unique [concat [dict get $result pin_names] [dict get $result keeper_names]]]}',
                    'expr {[dict get $result association_scope] eq "aggregate_only_not_per_node"}',
                ]
                if fault == 'changed_set':
                    checks += ['expr {[llength [dict get $result keeper_delta baseline_only]] == 1 && [llength [dict get $result keeper_delta observed_only]] == 1}']
                for check in checks:
                    cr,cm=evaluate(p,check)
                    if cr or cm!='1': raise RuntimeError((variant,fault,'invariant',check,cr,cm))
            if fault in ('pin_cap','keeper_cap','union_cap'):
                label={'pin_cap':'pin_all','keeper_cap':'keeper_all','union_cap':'union'}[fault]
                expected_count=6000 if fault=='union_cap' else 4097
                check=('expr {[lindex $events end-1] eq [list puts [list COUNT '+label+' '+str(expected_count)+' cap 4096]] && [lindex $events end] eq {flush AUDIT}}')
                cr,cm=evaluate(p,check)
                if cr or cm!='1': raise RuntimeError((fault,'count/flush before rejection',cr,cm))
            records.append({'variant':variant,'fault':fault or 'none','pass':True,'expected_rejection':reject})
        finally: LIB.Tcl_DeleteInterp(p)
    p=LIB.Tcl_CreateInterp()
    try:
        rc,msg=evaluate(p,source)
        if rc: raise RuntimeError(msg)
        for variant in ('baseline','candidate'):
            rc,msg=evaluate(p,'::ia840f_compare04::select_variant "$::ia840f_compare04::E/'+variant+'/scratch/syn/board/ia840f/syn_top"')
            if rc or msg!=variant: raise RuntimeError(('route',variant,rc,msg))
            records.append({'route':variant,'pass':True})
        for suffix in ('../experiment03/baseline/scratch/syn/board/ia840f/syn_top','baseline/scratch/syn/board/ia840f/syn_top/extra','candidate/scratch/syn/board/ia840f'):
            rc,msg=evaluate(p,'::ia840f_compare04::select_variant "$::ia840f_compare04::E/'+suffix+'"')
            if rc!=1 or 'COMPARE04_REJECT' not in msg: raise RuntimeError(('bad route',suffix,rc,msg))
            records.append({'rejected_route':suffix,'pass':True})
    finally: LIB.Tcl_DeleteInterp(p)
    print(json.dumps({'scope':'inert collection/selection component only; not complete query entry or native matcher proof',
                      'count':len(records),'tests':records,'hashes':{n:hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in ('scope-collections.tcl','test-scope.py')}},indent=2))


if __name__=='__main__': main()
