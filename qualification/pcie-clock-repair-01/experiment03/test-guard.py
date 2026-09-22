#!/usr/bin/env python3
"""Inert local Tcl guard tests; no Quartus/API implementation is executed."""
from pathlib import Path
import ctypes, ctypes.util, json, hashlib
ROOT=Path(__file__).resolve().parent
lib=ctypes.CDLL(ctypes.util.find_library('tcl8.6'))
lib.Tcl_CreateInterp.restype=ctypes.c_void_p
lib.Tcl_Eval.argtypes=[ctypes.c_void_p,ctypes.c_char_p];lib.Tcl_Eval.restype=ctypes.c_int
lib.Tcl_GetStringResult.argtypes=[ctypes.c_void_p];lib.Tcl_GetStringResult.restype=ctypes.c_char_p
lib.Tcl_DeleteInterp.argtypes=[ctypes.c_void_p]
lib.Tcl_CommandComplete.argtypes=[ctypes.c_char_p];lib.Tcl_CommandComplete.restype=ctypes.c_int
MOCK=r'''
set fault {}
set calls 0
proc puts {args} {}
proc foreach_in_collection {var coll body} {uplevel 1 [list foreach $var $coll $body]}
proc get_collection_size {c} {llength $c}
proc get_pins {args} {
    set n [lindex [lindex $args end] 0]
    if {[string first {|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|} $n] < 0} {return {}}
    set side [expr {[string match *inclk $n] ? "input" : "output"}]
    if {$::fault eq "${side}_missing"} {return {}}
    if {$::fault eq "${side}_multiple"} {return [list $n $n]}
    return [list $n]
}
proc get_pin_info {opt p} {
    switch -- $opt {
        -name {return $p}
        -is_clock_pin {return [expr {$::fault ne "not_clock_pin"}]}
        -is_in_pin {return [expr {[string match *inclk $p]}]}
        -is_out_pin {return [expr {![string match *inclk $p]}]}
    }
    error "unmocked pin option $opt"
}
proc get_cells {args} {
    if {$::fault eq "divider_missing"} {return {}}
    if {$::fault eq "divider_multiple"} {return [list $::ia840f_clock_repair::D $::ia840f_clock_repair::D]}
    return [list $::ia840f_clock_repair::D]
}
proc get_cell_info {opt c} {
    if {$opt eq "-name"} {return $c}
    if {$opt eq "-wysiwyg_type"} {return [expr {$::fault eq "wrong_divider" ? "tennm_ff" : "tennm_clk_divider"}]}
    error "unmocked cell option $opt"
}
proc get_fanins {args} {
    if {$::fault eq "wrong_fanin"} {return wrong_clock}
    return [list {sys_pll|iopll_0|tennm_pll|outclk[2]}]
}
proc get_node_info {opt id} {if {$opt ne "-name"} {error "unmocked node option"};return $id}
proc get_clocks {args} {
    set M $::ia840f_clock_repair::M;set C $::ia840f_clock_repair::C
    if {[lsearch -exact $args -of_objects]>=0} {
        set n [lindex [lindex $args end] 0]
        if {[string match *inclk $n]} {return [expr {$::fault eq "wrong_incoming" ? "wrong_clock" : [list $M]}]}
        if {$::calls || $::fault eq "existing_output"} {return [list $C]}
        return {}
    }
    set pattern [lindex [lindex $args end] 0]
    if {$pattern eq $M} {
        if {$::fault eq "master_missing"} {return {}}
        if {$::fault eq "master_multiple"} {return [list $M $M]}
        return [list $M]
    }
    if {$pattern eq $C} {return [expr {$::calls || $::fault eq "existing_name" ? [list $C] : {}}]}
    if {$pattern eq "*"} {return [expr {$::fault eq "existing_target" ? [list $M $C] : [list $M]}]}
    error "unmocked clock pattern $pattern"
}
proc get_clock_info {opt c} {
    set M $::ia840f_clock_repair::M;set D $::ia840f_clock_repair::D
    switch -- $opt {
        -name {return $c}
        -type {return generated}
        -master_clock {return $M}
        -targets {return [expr {$c eq $M ? [list {sys_pll|iopll_0|tennm_pll|outclk[2]}] : [list "$D|clock_div2"]}]}
        -master_clock_pin {return "$D|inclk"}
        -period {return 19.858}
        -waveform {return {0 9.929}}
        -divide_by {return 2}
        -multiply_by {return 1}
    }
    error "unmocked clock info $opt"
}
proc create_generated_clock {args} {
    if {[llength [lindex $args end]]!=1} {error "inert old selector failure"}
    if {[lsearch -exact $args -add]>=0} {error "blind add forbidden"}
    if {[lindex $args 0] ne "-name" || [lindex $args 1] ne $::ia840f_clock_repair::C} {error "clock name"}
    if {[lindex $args 4] ne "-master_clock" || [lindex $args 5] ne $::ia840f_clock_repair::M} {error "master"}
    if {[lindex $args 6] ne "-divide_by" || [lindex $args 7] ne "2"} {error "ratio"}
    incr ::calls
}
'''
def evaluate(interp,script):
    rc=lib.Tcl_Eval(interp,script.encode());return rc,lib.Tcl_GetStringResult(interp).decode()
def main():
    source=(ROOT/'clock-repair.tcl').read_text();query=(ROOT/'query.tcl').read_text()
    for name,text in [('guard',source),('query',query)]:
        if lib.Tcl_CommandComplete(text.encode())!=1:raise RuntimeError('incomplete '+name)
    records=[]
    faults=['','input_missing','input_multiple','output_missing','output_multiple','not_clock_pin','divider_missing','divider_multiple','wrong_divider','master_missing','master_multiple','wrong_fanin','wrong_incoming','existing_output','existing_name','existing_target']
    for fault in faults:
        p=lib.Tcl_CreateInterp()
        try:
            for text in (MOCK,source,'set fault {'+fault+'}'):
                rc,msg=evaluate(p,text)
                if rc:raise RuntimeError(msg)
            rc,msg=evaluate(p,'::ia840f_clock_repair::apply')
            if fault:
                if rc!=1 or 'CLOCK_REPAIR_REJECT' not in msg:raise RuntimeError((fault,rc,msg))
                if evaluate(p,'set calls')[1]!='0':raise RuntimeError('created before rejection')
            else:
                if rc:raise RuntimeError(msg)
                if evaluate(p,'::ia840f_clock_repair::verify_created')[0]:raise RuntimeError('positive postcheck')
                if evaluate(p,'::ia840f_clock_repair::apply')[0]!=1:raise RuntimeError('second application')
            records.append({'fixture':fault or 'positive_and_rerun_rejection','pass':True})
        finally:lib.Tcl_DeleteInterp(p)
    p=lib.Tcl_CreateInterp()
    try:
        definitions=query.removeprefix('# Fresh A/B analysis of the unchanged Work14 fit; never a fit or FPGA run.\n')
        definitions=definitions.replace('load_package sta\n','').replace('load_package report\n','')
        definitions='\n'.join(l for l in definitions.splitlines() if not l.startswith('source '))
        definitions=definitions.rsplit('::ia840f_constraint_compare::main',1)[0]
        rc,msg=evaluate(p,source+'\n'+definitions)
        if rc:raise RuntimeError(msg)
        for name in ['abc[0]|x','abc[15]|x','a*b?c']:
            rc,msg=evaluate(p,'set n {'+name+'};string match [::ia840f_constraint_compare::literal $n] $n')
            if rc or msg!='1':raise RuntimeError(('literal lookup',name,rc,msg))
        records.append({'fixture':'query_definitions_and_literal_globs','pass':True})
    finally:lib.Tcl_DeleteInterp(p)
    print(json.dumps({'scope':'inert Tcl guard/control tests only, not vendor API/netlist validation','tests':records,'count':len(records),'hashes':{n:hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in ('clock-repair.tcl','query.tcl')}},indent=2))
if __name__=='__main__':main()
