#!/usr/bin/env python3
"""Inert known32/T mapping regression, not native association proof."""
from pathlib import Path
import ctypes
import ctypes.util
import hashlib
import json
ROOT=Path(__file__).resolve().parent
L=ctypes.CDLL(ctypes.util.find_library('tcl8.6'))
L.Tcl_CreateInterp.restype=ctypes.c_void_p
L.Tcl_Eval.argtypes=[ctypes.c_void_p,ctypes.c_char_p];L.Tcl_Eval.restype=ctypes.c_int
L.Tcl_GetStringResult.argtypes=[ctypes.c_void_p];L.Tcl_GetStringResult.restype=ctypes.c_char_p
L.Tcl_DeleteInterp.argtypes=[ctypes.c_void_p]
MOCK=r'''
set fault {};set variant baseline;set serial 0;set pool [dict create];set audit_records {};set flushes 0
set H H;set D {H|DIV};set C {H|avmm_clock0};set K {H|DIV~div_reg}
set T "$H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg"
set rows {};set conservative [list $T];set groups [dict create];set names [dict create TILE $T KEEP $K OUT "$D|clock_div2"]
set P "$H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif"
set fifos {u_pciess_cplto_if|cplto_fifo_avmm_inst u_pciess_cplto_if|cplto_fifo_lite_inst EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo}
set chains {rs_dgwp ws_dgrp rs_dgwp ws_dgrp}
for {set g 0} {$g<4} {incr g} {
 set ids {}
 for {set j 0} {$j<8} {incr j} {
  set i [expr {$g*8+$j}];set name "$P|[lindex $fifos $g]|auto_generated|[lindex $chains $g]|dffpipe\[$j\]|dffe0"
  set pin "$name|clk";lappend rows [list $g $name $pin];lappend conservative $name;lappend ids CELL$i
  dict set names CELL$i $name;dict set names REG$i $name;dict set names PIN$i $pin;dict set names DATA$i "$name|d"
 }
 dict set groups "$P|[lindex $fifos $g]|auto_generated|[lindex $chains $g]|dffpipe*|dffe*" $ids
}
proc collection {items} {set id COL[incr ::serial];dict set ::pool $id $items;return $id}
proc get_collection_size {id} {return [llength [dict get $::pool $id]]}
proc foreach_in_collection {var id body} {uplevel 1 [list foreach $var [dict get $::pool $id] $body]}
proc puts {channel text} {
 if {$channel ne "AUDIT"} {error channel};lappend ::audit_records $text
 if {[lindex $text 0] eq "RECEIVERS_COMPLETE"} {set ::array_state [uplevel 2 {array get pins}]}
}
proc flush {channel} {if {$channel ne "AUDIT"} {error channel};incr ::flushes}
proc get_node_info {opt id} {if {$opt ne "-name"} {error property};return [dict get $::names $id]}
proc get_cells {args} {
 if {[llength $args]!=2 || [lindex $args 0] ne "-nowarn"} {error cells_grammar}
 set items [dict get $::groups [lindex [lindex $args end] 0]]
 if {$::fault eq "group_missing" && [lindex $items 0] eq "CELL0"} {set items [lrange $items 1 end]}
 if {$::fault eq "group_extra" && [lindex $items 0] eq "CELL0"} {lappend items CELL8}
 if {$::fault eq "group_duplicate" && [lindex $items 0] eq "CELL0"} {lappend items CELL0}
 return [collection $items]
}
proc get_cell_info {opt id} {
 if {![regexp {^CELL([0-9]+)$} $id -> i]} {error physical_ID_expected}
 switch -- $opt {
  -name {return [dict get $::names $id]}
  -wysiwyg_type {return [expr {$i==0 && $::fault eq "cell_type" ? "wrong" : "tennm_ff"}]}
  -pins {
   # Synthetic caller-frame collision; no vendor array may be overwritten.
   uplevel 1 {array set pins {vendor sentinel}}
   if {$i==0 && $::fault eq "pin_cap"} {return [collection [lrepeat 33 PIN0]]}
   return [collection [list PIN$i DATA$i]]
  }
  -buried_regs {
   if {$i==0 && $::fault eq "buried_empty"} {return [collection {}]}
   if {$i==0 && $::fault eq "buried_multiple"} {return [collection {REG0 REG1}]}
   if {$i==0 && $::fault eq "buried_alias"} {return [collection {REG1}]}
   return [collection [list REG$i]]
  }
 }
 error cell_property
}
proc get_pin_info {opt id} {
 if {![regexp {^(PIN|DATA)([0-9]+)$} $id -> cls i]} {error pin_ID_expected}
 switch -- $opt {
  -name {return [dict get $::names $id]}
  -is_in_pin {return [expr {!($i==0 && $::fault eq "pin_direction")}]}
  -is_clock_pin {return [expr {$cls eq "PIN" && !($i==0 && $::fault eq "pin_not_clock")}]}
 }
 error pin_property
}
proc get_register_info {opt id} {
 if {![regexp {^REG([0-9]+)$} $id -> i]} {error register_ID_expected}
 if {$opt eq "-name"} {return [dict get $::names $id]}
 if {$opt eq "-type"} {return [expr {$i==0 && $::fault eq "register_type" ? "port" : "reg"}]}
 error register_property
}
proc get_fanins {args} {
 if {[lrange $args 0 1] ne {-clock -stop_at_clocks} || ![regexp {^PIN[0-9]+$} [lindex $args 2]]} {error reverse_grammar}
 if {$::fault eq "reverse_empty"} {return [collection {}]}
 if {$::fault eq "reverse_wrong"} {return [collection {TILE}]}
 if {$::fault eq "reverse_multiple"} {return [collection {KEEP OUT}]}
 return [collection [expr {$::fault eq "candidate_target_reverse" ? {OUT} : {KEEP}}]]
}
proc get_keepers {args} {
 if {$args ne [list -nowarn [list $::T]]} {error unexpected_raw_roundtrip}
 if {$::fault eq "tile_missing"} {return [collection {}]}
 if {$::fault eq "tile_multiple"} {return [collection {TILE TILE}]}
 return [collection {TILE}]
}
proc get_clocks {args} {
 if {[llength $args]!=3 || [lrange $args 0 1] ne {-nowarn -of_objects}} {error clocks_grammar}
 set objects [dict get $::pool [lindex $args end]]
 if {[llength $objects]!=1 || ![regexp {^(REG[0-9]+|TILE)$} [lindex $objects 0]]} {error actual_buried_or_tile_collection_required}
 set id [lindex $objects 0]
 if {$::fault eq "clock_cap" && $id eq "REG0"} {return [collection [lrepeat 257 CLK_C]]}
 if {$::fault eq "extra_clock" && $id eq "REG0"} {return [collection {CLK_C CLK_X}]}
 if {$::fault eq "baseline_clock" && $id eq "REG0"} {return [collection {CLK_X}]}
 if {$::fault eq "candidate_no_clock" && $id eq "REG0"} {return [collection {}]}
 if {$::fault eq "tile_wrong_clock" && $id eq "TILE"} {return [collection {CLK_X}]}
 return [collection [expr {$::variant eq "candidate" ? {CLK_C} : {}}]]
}
proc get_clock_info {opt id} {
 if {$opt ne "-name"} {error clock_property};return [dict get [dict create CLK_C $::C CLK_X OTHER] $id]
}
'''

def ev(p,s):
 r=L.Tcl_Eval(p,s.encode());return r,L.Tcl_GetStringResult(p).decode()

def main():
 sources=[(ROOT/n).read_text() for n in ['scope-collections.tcl','receiver-mapping.tcl']]
 cases=[('baseline','',False),('candidate','',False),('candidate','candidate_target_reverse',False)]
 faults=['group_missing','group_extra','group_duplicate','cell_type','pin_cap','pin_direction','pin_not_clock','buried_empty','buried_multiple','buried_alias','register_type','reverse_empty','reverse_wrong','reverse_multiple','tile_missing','tile_multiple','clock_cap','extra_clock','candidate_no_clock','tile_wrong_clock','manifest_missing','manifest_duplicate','manifest_bad_pin','not_in_union']
 cases += [('candidate',f,True) for f in faults]
 cases += [('baseline','baseline_clock',True),('baseline','candidate_target_reverse',True)]
 out=[]
 for variant,fault,reject in cases:
  p=L.Tcl_CreateInterp()
  try:
   for s in sources+[MOCK,'set ::ia840f_compare04::audit AUDIT','set variant '+variant,'set fault {'+fault+'}']:
    rc,msg=ev(p,s)
    if rc:raise RuntimeError(('fixture',rc,msg))
   extra={'manifest_missing':'set rows [lrange $rows 1 end]','manifest_duplicate':'lset rows 1 [lindex $rows 0]','manifest_bad_pin':'lset rows 0 2 WRONG_PIN','not_in_union':'set conservative [lrange $conservative 2 end]'}
   if fault in extra:
    rc,msg=ev(p,extra[fault])
    if rc:raise RuntimeError(msg)
   rc,msg=ev(p,'set result [::ia840f_compare04::capture_receivers $variant $H $D $C $conservative $rows]')
   if (reject and (rc!=1 or 'COMPARE04_REJECT' not in msg)) or (not reject and rc):raise RuntimeError((variant,fault,rc,msg))
   if not reject:
    for check in ['expr {[dict size [dict get $result receivers]]==32}', 'expr {[dict get $result group_counts] eq {8 8 8 8}}','expr {$::array_state eq {vendor sentinel}}','expr {[dict get $result tile name] eq $T}','expr {$flushes == [llength $audit_records]}']:
     cr,cm=ev(p,check)
     if cr or cm!='1':raise RuntimeError((fault,check,cr,cm))
   out.append({'variant':variant,'fault':fault or 'none','pass':True,'expected_rejection':reject})
  finally:L.Tcl_DeleteInterp(p)
 print(json.dumps({'scope':'inert known32/T mapping only; no native/vendor API proof','count':len(out),'tests':out,'sha256':{n:hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in ['scope-collections.tcl','receiver-mapping.tcl','test-receivers.py']}},indent=2))
if __name__=='__main__':main()
