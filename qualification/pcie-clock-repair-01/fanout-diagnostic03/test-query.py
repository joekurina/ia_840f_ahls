#!/usr/bin/env python3
"""Inert full-entry Tcl tests. Separate mock cells/pins/registers/collections.
These are control-flow/representation scenarios, not emulation of Quartus.
"""
from pathlib import Path
import ctypes,ctypes.util,hashlib,json,sys
ROOT=Path(__file__).resolve().parent
REMOTE='/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic03'
lib=ctypes.CDLL(ctypes.util.find_library('tcl8.6'))
lib.Tcl_CreateInterp.restype=ctypes.c_void_p
lib.Tcl_Eval.argtypes=[ctypes.c_void_p,ctypes.c_char_p];lib.Tcl_Eval.restype=ctypes.c_int
lib.Tcl_GetStringResult.argtypes=[ctypes.c_void_p];lib.Tcl_GetStringResult.restype=ctypes.c_char_p
lib.Tcl_DeleteInterp.argtypes=[ctypes.c_void_p]
def ev(p,s):
    rc=lib.Tcl_Eval(p,s.encode());return rc,lib.Tcl_GetStringResult(p).decode()
def literal(s):
    assert not any(x in str(s) for x in '{}\\\n');return '{'+str(s)+'}'
MOCK=r'''
set events {};set stdout {};set fanout_calls {};set opened {};set projects 0;set seq 0
array set collections {}
proc col {items} {set id COL[incr ::seq];set ::collections($id) $items;return $id}
proc items {id} {if {![info exists ::collections($id)]} {error "NOT_A_COLLECTION $id"};return $::collections($id)}
proc get_collection_size {id} {return [llength [items $id]]}
proc foreach_in_collection {v id body} {uplevel 1 [list foreach $v [items $id] $body]}
proc load_package {p} {if {$p ni {sta report}} {error BAD_PACKAGE}}
proc pwd {} {return $::cwd}
rename file real_file
proc file {op args} {
 switch -- $op {
  join - dirname {return [real_file $op {*}$args]}
  exists {if {$args ne [list "$::root/reports"]} {error BAD_REPORT_PATH};return [expr {$::case eq "spent"}]}
  mkdir {if {$args ne [list "$::root/reports"]} {error BAD_REPORT_PATH}}
  default {error "FORBIDDEN_FILE $op"}
 }
}
proc open {p mode} {
 if {$p ne "$::root/reports/audit.tcllist" || $mode ne {WRONLY CREAT EXCL}} {error BAD_OPEN}
 lappend ::opened $p;return MOCK_AUDIT
}
proc puts {args} {
 if {[llength $args]==1} {lappend ::stdout [lindex $args 0];return}
 if {[lindex $args 0] ne "MOCK_AUDIT"} {error BAD_CHANNEL}
 lappend ::events [lindex $args 1]
}
proc flush {p} {if {$p ne "MOCK_AUDIT"} {error BAD_FLUSH}}
proc close {p} {if {$p ne "MOCK_AUDIT"} {error BAD_CLOSE}}
proc project_open {args} {
 if {$args ne {-revision ofs_top ofs_top}} {error BAD_PROJECT}
 incr ::projects
 if {$::case eq "project_error"} {error MOCK_PROJECT_ERROR}
 if {$::case eq "gate_sentinel"} {set ::ia840f_gate_result 1}
}
proc create_timing_netlist {} {}
proc read_sdc {args} {if {[llength $args]} {error NOT_NORMAL_SDC_ORDER}}
proc update_timing_netlist {} {}
proc delete_timing_netlist {} {}
proc project_close {} {}
proc create_generated_clock {args} {error FORBIDDEN_CLOCK}
proc use_timing_analyzer_style_escaping {args} {error FORBIDDEN_MODE_CHANGE}
proc cname {i} {return [lindex [lindex $::ia840f_known_receivers $i] 1]}
proc pname {i} {return [lindex [lindex $::ia840f_known_receivers $i] 2]}
proc rname {i} {if {$::case eq "same_names"} {return [cname $i]};return "[cname $i]~MOCK_TIMING_REG"}
proc tile_name {} {return "$::ia840f_clock_repair::H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg"}
proc get_node_info {o node} {
 if {$o ne "-name"} {error BAD_NODE_OPTION}
 if {$node eq "K"} {return "$::ia840f_clock_repair::D~div_reg"}
 if {$node eq "T"} {return [tile_name]}
 if {$node eq "X"} {return outside_pcie_mock_port}
 if {$node eq "PLLSOURCE"} {return mock_pll_source}
 if {[regexp {^R([0-9]+)$} $node -> i]} {return [rname $i]}
 if {$node eq "Rextra"} {return extra_mock_buried_reg}
 error "NOT_NODE $node"
}
proc get_pin_info {o pin} {
 if {$pin eq "O"} {set n "$::ia840f_clock_repair::D|clock_div2";set input 0} elseif {[regexp {^PIN([0-9]+)$} $pin -> i]} {set n [pname $i];set input 1} else {error NOT_PIN}
 switch -- $o {-name {return $n} -is_in_pin {return $input} -is_out_pin {return [expr {!$input}]} -is_clock_pin {return 1} default {error BAD_PIN_OPTION}}
}
proc get_pins {args} {
 if {[lindex $args end] ne [list "$::ia840f_clock_repair::D|clock_div2"]} {error UNPLANNED_PIN_LOOKUP}
 return [col O]
}
proc get_cells {args} {
 if {[lindex $args 0] ne "-nowarn" || [llength $args]!=2} {error BAD_CELL_LOOKUP}
 set pat [lindex [lindex $args end] 0];set first [cname 0]
 if {$pat eq $first} {if {$::case eq "dialect_tcl"} {return [col {}]};return [col C0]}
 if {[string first {[[]} $pat]>=0} {if {$::case eq "dialect_tcl"} {return [col C0]};return [col {}]}
 if {[string first {dffpipe*|dffe*} $pat]<0} {error BROAD_CELL_LOOKUP}
 set result {};set i 0
 foreach row $::ia840f_known_receivers {
  if {[string match $pat [lindex $row 1]]} {lappend result C$i};incr i
 }
 if {$::case eq "group_missing"} {return [col {}]}
 if {$::case eq "group_over"} {return [col [lrepeat 129 C0]]}
 return [col $result]
}
proc get_cell_info {o cell} {
 if {![regexp {^C([0-9]+)$} $cell -> i]} {error NOT_CELL}
 switch -- $o {
  -name {return [cname $i]}
  -wysiwyg_type {if {$::case eq "wrong_cell_type" && $i==0} {return bad_type};return tennm_ff}
  -pins {if {$::case eq "pins_over" && $i==0} {return [col [lrepeat 33 PIN0]]};return [col [list PIN$i]]}
  -buried_regs {
   if {$::case eq "buried_error" && $i==0} {error MOCK_BURIED_ERROR}
   if {$::case eq "buried_zero" && $i==0} {return [col {}]}
   if {$::case eq "buried_multiple" && $i==0} {return [col [list R$i Rextra]]}
   if {$::case eq "buried_over" && $i==0} {return [col [lrepeat 33 R0]]}
   return [col [list R$i]]
  }
  default {error BAD_CELL_OPTION}
 }
}
proc get_keepers {args} {
 if {[lindex $args 0] ne "-nowarn"} {error BAD_KEEPER_LOOKUP}
 set pat [lindex [lindex $args end] 0]
 if {$pat eq "$::ia840f_clock_repair::D~div_reg"} {if {$::case eq "root_missing"} {return [col {}]};return [col K]}
 if {$pat eq [tile_name]} {if {$::case eq "tile_missing"} {return [col {}]};return [col T]}
 if {$pat eq [cname 0] && $::case eq "same_names"} {return [col R0]}
 if {$pat eq [cname 0] || [string first {[[]} $pat]>=0} {return [col {}]}
 error UNPLANNED_KEEPER_LOOKUP
}
proc get_registers {args} {return [get_keepers {*}$args]}
proc get_register_info {o reg} {
 if {$o eq "-name"} {return [get_node_info -name $reg]}
 if {$o eq "-type"} {return register}
 error BAD_REGISTER_OPTION
}
proc get_fanins {args} {
 if {[lrange $args 0 1] ne {-clock -stop_at_clocks} || ![regexp {^PIN([0-9]+)$} [lindex $args 2] -> i]} {error BAD_REVERSE_PIN_ID}
 if {$::case eq "reverse_wrong" && $i==0} {return [col X]}
 if {$::case eq "reverse_over" && $i==0} {return [col [lrepeat 33 K]]}
 return [col K]
}
proc get_fanouts {args} {
 set root [items [lindex $args end]];set filtered [expr {[llength $args]==2}]
 if {$filtered && [lindex $args 0] ne "-clock"} {error BAD_FANOUT_OPTIONS}
 if {$root ni {O K}} {error BAD_FORWARD_ROOT}
 lappend ::fanout_calls [list $root $filtered]
 if {$::case eq "fanout_error" && $root eq "O" && !$filtered} {error MOCK_FANOUT_ERROR}
 if {$filtered || $::case eq "all_zero"} {return [col {}]}
 set result {};for {set i 0} {$i<32} {incr i} {lappend result R$i};lappend result T X
 if {$::case eq "forward_duplicate" && $root eq "O"} {lappend result R0}
 if {$::case eq "forward_over" && $root eq "O"} {return [col [lrepeat 4097 R0]]}
 return [col $result]
}
proc get_clocks {args} {
 if {$args eq "*"} {return [col M]}
 if {[lsearch -exact $args -of_objects]>=0} {items [lindex $args end];return [col M]}
 if {[lindex $args end] eq [list $::ia840f_clock_repair::C]} {if {$::case eq "preexisting_clock"} {return [col M]};return [col {}]}
 error BAD_CLOCK_LOOKUP
}
proc get_clock_info {o clock} {
 if {$clock ne "M"} {error BAD_CLOCK_ID}
 switch -- $o {-name {return $::ia840f_clock_repair::M} -type {return base} -period {return 9.929} -waveform {return {0.000 4.964}} -targets {return [col PLLSOURCE]} default {error GENERATED_PROPERTY_ON_BASE}}
}
proc count_event {tag} {set n 0;foreach e $::events {if {[lindex $e 0] eq $tag} {incr n}};return $n}
'''
def run(case,d):
    p=lib.Tcl_CreateInterp()
    try:
        cwd=REMOTE+'/scratch/syn/board/ia840f/syn_top'
        if case=='wrong_cwd':cwd+='_WRONG'
        if case=='old_cwd':cwd=cwd.replace('fanout-diagnostic03','fanout-diagnostic02')
        for s in [f'set case {literal(case)};set root {literal(REMOTE)};set cwd {literal(cwd)}',MOCK]:
            rc,msg=ev(p,s);assert rc==0,msg
        rc,msg=ev(p,'source '+literal(d/'query.tcl'))
        def val(s):
            r,t=ev(p,s);assert r==0,t;return t
        ok=case in {'aliases','same_names','dialect_tcl','all_zero','buried_zero','buried_multiple'}
        assert (rc==0)==ok,(case,rc,msg)
        marker=val('expr {[lsearch -exact $stdout IA840F_FANOUT_CONTRAST_COMPLETE]>=0}')
        assert marker==str(int(ok)),(case,marker)
        counts={tag:int(val('count_event '+tag)) for tag in ['FANOUT_COUNT','LOOKUP_INPUT','CELL_REGISTER_MAP','REGISTER','CLOCK_INPUT','DIAGNOSTIC_STATUS','INCOMPLETE','TILE']}
        if ok:
            assert counts['FANOUT_COUNT']==4 and counts['LOOKUP_INPUT']==6 and counts['CELL_REGISTER_MAP']==32 and counts['CLOCK_INPUT']==32 and counts['TILE']==1,counts
            supported=val('set out {};foreach e $events {if {[lindex $e 0] eq "DIAGNOSTIC_STATUS"} {set out [lindex $e 4]}};set out')
            assert supported==str(int(case not in {'buried_zero','buried_multiple'})),(case,supported)
        if case in {'forward_over','forward_duplicate','group_missing','group_over','tile_missing','wrong_cell_type','pins_over','buried_over','reverse_wrong','reverse_over'}:
            assert counts['FANOUT_COUNT']==4 and counts['LOOKUP_INPUT']==6 and counts['DIAGNOSTIC_STATUS']==1 and counts['INCOMPLETE']>0,counts
        if case in {'old_cwd','wrong_cwd'}:assert val('set projects')=='0' and val('llength $opened')=='0'
        if case=='all_zero':assert val('set n 0;foreach e $events {if {[lindex $e 0] eq "FANOUT_COUNT"} {incr n [lindex $e 2]}};set n')=='0'
        if case=='aliases':assert val('set n 0;foreach e $events {if {[lindex $e 0] eq "CELL_REGISTER_MAP" && [lindex $e 2] ne [lindex [lindex $e 4] 0]} {incr n}};set n')=='32'
        return {'case':case,'pass':True,'tcl_rc':rc,'message':msg,'records':counts}
    finally:lib.Tcl_DeleteInterp(p)
def main():
    d=ROOT/'prepared-readback01' if sys.argv[1:]==['--prepared'] else ROOT
    assert sys.argv[1:] in ([],['--prepared'])
    hashes={n:hashlib.sha256((d/n).read_bytes()).hexdigest() for n in ['query.tcl','clock-repair.tcl','known-receivers.tcl']}
    if d!=ROOT:
        c=json.loads((d/'candidate.json').read_text());assert c['cwd']==REMOTE+'/scratch/syn/board/ia840f/syn_top'
        for n,h in hashes.items():assert c['files'][REMOTE+'/'+n]==c['callback_files'][REMOTE+'/'+n]==h
    cases=['aliases','same_names','dialect_tcl','all_zero','buried_zero','buried_multiple','forward_over','forward_duplicate','group_missing','group_over','tile_missing','wrong_cell_type','pins_over','buried_over','reverse_wrong','reverse_over','buried_error','fanout_error','root_missing','preexisting_clock','wrong_cwd','old_cwd','spent','project_error','gate_sentinel']
    rows=[run(c,d) for c in cases]
    print(json.dumps({'scope':'INERT API scenarios; not Quartus matcher/graph/representation proof','source_sha256':hashes,'test_source_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'count':len(rows),'tests':rows},indent=2))
if __name__=='__main__':main()
