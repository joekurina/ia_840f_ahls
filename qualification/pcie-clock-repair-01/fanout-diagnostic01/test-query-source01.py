#!/usr/bin/env python3
"""Full actual Tcl entry in INERT libtcl mocks; no vendor or report writes."""
from pathlib import Path
import ctypes,ctypes.util,hashlib,json,sys
ROOT=Path(__file__).resolve().parent
REMOTE='/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01'
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
set events {};set stdout {};set opened {};set mkdirs {};set projects 0;set fanout_calls {}
proc load_package {p} {if {$p ni {sta report}} {error BAD_PACKAGE}}
proc pwd {} {return $::cwd}
rename file real_file
proc file {op args} {
 switch -- $op {
  join - dirname {return [real_file $op {*}$args]}
  exists - mkdir {
   if {$args ne [list "$::root/reports"]} {error BAD_REPORT_PATH}
   if {$op eq "exists"} {return [expr {$::case eq "spent"}]}
   lappend ::mkdirs {*}$args
  }
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
 if {$::case eq "project_sentinel"} {error INERT_PROJECT_OPEN_STOP}
}
proc create_timing_netlist {} {}
proc read_sdc {args} {if {[llength $args]} {error NOT_NORMAL_SDC_ORDER}}
proc update_timing_netlist {} {}
proc delete_timing_netlist {} {}
proc project_close {} {}
proc create_generated_clock {args} {error FORBIDDEN_CLOCK_CREATION}
proc foreach_in_collection {v c body} {uplevel 1 [list foreach $v $c $body]}
proc get_collection_size {c} {return [llength $c]}
proc get_node_info {o n} {if {$o ne "-name"} {error BAD_NODE_OPTION};return $n}
proc all_names {} {
 set H $::ia840f_clock_repair::H
 set out {}
 foreach row $::ia840f_known_receivers {lappend out [lindex $row 1]}
 lappend out "$H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg"
 lappend out fixture_external_receiver
 return $out
}
proc get_keepers {args} {
 if {[lindex $args 0] ne "-nowarn"} {error BAD_KEEPER_OPTIONS}
 set pattern [lindex [lindex $args end] 0];set K "$::ia840f_clock_repair::D~div_reg"
 set result {}
 foreach n [concat [list $K] [all_names]] {if {[string match $pattern $n]} {lappend result $n}}
 if {$::case eq "keeper_missing" && $pattern eq $K} {return {}}
 if {$::case eq "keeper_duplicate" && $pattern eq $K} {return [list $K $K]}
 if {$::case eq "group_wrong" && [string first dffpipe* $pattern]>=0} {return [lrange $result 1 end]}
 return $result
}
proc get_registers {args} {return [get_keepers {*}$args]}
proc get_pins {args} {
 set pattern [lindex [lindex $args end] 0]
 set all [list "$::ia840f_clock_repair::D|clock_div2"]
 foreach row $::ia840f_known_receivers {lappend all [lindex $row 2]}
 set result {};foreach n $all {if {[string match $pattern $n]} {lappend result $n}}
 return $result
}
proc get_pin_info {o p} {
 switch -- $o {
  -name {return $p}
  -is_clock_pin {return 1}
  -is_in_pin {return [expr {![string match *clock_div2 $p]}]}
  -is_out_pin {return [expr {[string match *clock_div2 $p]}]}
  default {error BAD_PIN_OPTION}
 }
}
proc get_clocks {args} {
 if {$args eq "*"} {return {base virtual_base generated virtual_generated}}
 if {[lsearch -exact $args -of_objects]>=0} {return {}}
 if {$::case eq "existing_clock"} {return [list $::ia840f_clock_repair::C]}
 return {}
}
proc get_clock_info {o c} {
 switch -- $o {
  -name - -type {return $c}
  -period {return 10}
  -waveform {return {0 5}}
  -targets {return {}}
  -master_clock - -master_clock_pin - -divide_by - -multiply_by {
   if {$c in {base virtual_base}} {error GENERATED_PROPERTY_ON_BASE}
   return MOCK_GENERATED_PROPERTY
  }
  default {error BAD_CLOCK_OPTION}
 }
}
proc get_fanouts {args} {
 if {[lindex $args 0] ne "-clock" || [llength $args]!=2} {error BAD_FANOUT_OPTIONS}
 set node [lindex [lindex $args 1] 0]
 set label [expr {[string match *clock_div2 $node] ? "pin" : "keeper"}]
 lappend ::fanout_calls $label
 if {$::case eq "api_error"} {error INERT_NATIVE_API_ERROR}
 set full [all_names]
 if {$::case eq "both_zero"} {return {}}
 if {$::case eq "both_equal"} {return $full}
 if {$::case eq "pin_subset" && $label eq "pin"} {return [lrange $full 0 1]}
 if {$::case eq "pin_cap" && $label eq "pin"} {return [lrepeat 4097 CAPPED_UNENUMERATED]}
 if {$::case eq "keeper_cap" && $label eq "keeper"} {return [lrepeat 4097 CAPPED_UNENUMERATED]}
 if {$label eq "pin"} {return {}}
 if {$::case eq "duplicate_load"} {lappend full [lindex $full 0]}
 if {$::case eq "missing_known"} {return [lrange $full 1 end]}
 return $full
}
proc get_fanins {args} {
 if {[lrange $args 0 1] ne {-clock -stop_at_clocks}} {error BAD_FANIN_OPTIONS}
 if {$::case eq "wrong_reverse"} {return wrong_divider}
 return [list "$::ia840f_clock_repair::D~div_reg"]
}
proc unknown {args} {error "FORBIDDEN_UNMOCKED $args"}
'''
def run_case(D,case):
    p=lib.Tcl_CreateInterp()
    try:
        cwd=REMOTE+'/scratch/syn/board/ia840f/syn_top'
        if case=='old_root':cwd=cwd.replace('fanout-diagnostic01','experiment03/baseline')
        if case=='wrong_root':cwd+='bad'
        setup='set root '+literal(REMOTE)+';set cwd '+literal(cwd)+';set case '+literal(case)+'\n'+MOCK
        assert ev(p,setup)[0]==0
        rc,msg=ev(p,'source '+literal(D/'query.tcl'))
        def value(s):
            r,v=ev(p,s);assert r==0,(s,v);return v
        errors={'old_root':'unexpected project path','wrong_root':'unexpected project path','spent':'spent reports directory','project_sentinel':'INERT_PROJECT_OPEN_STOP','existing_clock':'baseline clock changed','keeper_missing':'identity count','keeper_duplicate':'identity count','pin_cap':'fanout enumeration incomplete','keeper_cap':'fanout enumeration incomplete','duplicate_load':'fanout enumeration incomplete','group_wrong':'known group cardinality','wrong_reverse':'known reverse clock changed','api_error':'INERT_NATIVE_API_ERROR'}
        if case in errors:assert rc==1 and errors[case] in msg,(case,rc,msg)
        else:assert rc==0,(case,rc,msg)
        complete=value('llength $stdout')
        assert complete==('0' if case in errors else '1'),(case,complete)
        if case not in errors:assert value('lindex $stdout 0')=='IA840F_FANOUT_DIAGNOSTIC_COMPLETE'
        fanouts=value('lsearch -all -inline -exact -index 0 $events FANOUT_COUNT')
        if case in ('pin_cap','keeper_cap','duplicate_load'):
            assert value('set fanout_calls')=='pin keeper'
            assert value('llength [lsearch -all -inline -exact -index 0 $events FANOUT_COUNT]')=='2'
        if case=='pin_cap':assert 'pin 4097 cap 4096' in fanouts
        if case=='keeper_cap':assert 'keeper 4097 cap 4096' in fanouts
        if case in ('old_root','wrong_root','spent'):
            assert value('llength $opened')==value('llength $mkdirs')==value('set projects')=='0'
        if case=='project_sentinel':assert value('set projects')=='1'
        status=value('lsearch -all -inline -exact -index 0 $events DIAGNOSTIC_STATUS')
        if case=='normal':assert 'pin_supported_by_known 0 keeper_supported_by_known 1' in status
        if case in ('both_zero','missing_known'):assert 'pin_supported_by_known 0 keeper_supported_by_known 0' in status
        if case=='both_equal':assert 'pin_supported_by_known 1 keeper_supported_by_known 1' in status
        if case not in errors:
            assert value('llength [lsearch -all -inline -exact -index 0 $events KNOWN_RECEIVER]')=='32'
            assert value('llength [lsearch -all -inline -exact -index 0 $events NAMED_TILE_LOAD]')=='1'
        return {'case':case,'rc':rc,'diagnostic_marker_count':int(complete),'fanout_records':fanouts,'status':status,'pass':True}
    finally:lib.Tcl_DeleteInterp(p)
def main():
    assert not sys.flags.optimize
    assert sys.argv[1:] in ([],['--prepared'])
    D=ROOT/('prepared-readback01' if sys.argv[1:] else '')
    if sys.argv[1:]:
        r=json.loads((D/'candidate.json').read_text());assert r['cwd']==REMOTE+'/scratch/syn/board/ia840f/syn_top'
        for n in ('query.tcl','known-receivers.tcl','clock-repair.tcl'):
            h=hashlib.sha256((D/n).read_bytes()).hexdigest();assert r['files'][REMOTE+'/'+n]==r['callback_files'][REMOTE+'/'+n]==h
    cases=('normal','both_zero','both_equal','pin_subset','missing_known','pin_cap','keeper_cap','duplicate_load','keeper_missing','keeper_duplicate','group_wrong','wrong_reverse','api_error','existing_clock','old_root','wrong_root','spent','project_sentinel')
    rows=[run_case(D,c) for c in cases]
    print(json.dumps({'scope':'INERT full actual Tcl entry and mocked API semantics; no native validation','prepared':bool(sys.argv[1:]),'count':len(rows),'tests':rows,'query_sha256':hashlib.sha256((D/'query.tcl').read_bytes()).hexdigest(),'test_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},indent=2))
if __name__=='__main__':main()
