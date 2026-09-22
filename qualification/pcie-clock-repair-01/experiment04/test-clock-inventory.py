#!/usr/bin/env python3
"""Local data-comparison tests on captured clocks; no vendor API execution."""
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
L.Tcl_Merge.argtypes=[ctypes.c_int,ctypes.POINTER(ctypes.c_char_p)];L.Tcl_Merge.restype=ctypes.c_void_p
L.Tcl_Free.argtypes=[ctypes.c_void_p]

def merge(items):
 raw=[str(x).encode() for x in items];a=(ctypes.c_char_p*len(raw))(*raw);p=L.Tcl_Merge(len(raw),a)
 try:return ctypes.string_at(p).decode()
 finally:L.Tcl_Free(p)

def ev(p,s):
 r=L.Tcl_Eval(p,s.encode());return r,L.Tcl_GetStringResult(p).decode()

def main():
 inp=ROOT.parent/'native-baseline-clock-inventory03.json'
 data=json.loads(inp.read_text());assert data['clock_count']==len(data['clock_definitions'])==80
 state=[]
 for c in data['clock_definitions']:
  extra=c['extra_native_properties'];gen=merge(extra[1:]) if extra[0]=='generated_properties' else 'not_applicable'
  value=merge(['type',c['type'],'period',c['period_text'],'waveform',c['raw_tcl_list_fields'][4],
               'targets',merge(c['definition_targets']),'generated',gen]);state.extend([c['name'],value])
 setup=merge(['set','native_data_state',merge(state)])+'\n'+merge(['set','C',data['new_clock_name_absent']])
 setup+='\nset state $native_data_state;set expected $::ia840f_compare04_expect::clocks\n'
 setup+='set new_definition [dict create type generated period 19.857 waveform {0.000 9.929} targets INERT_O generated {INERT_M INERT_I 2 1}]\n'
 setup+='proc puts {channel text} {if {$channel ne "AUDIT"} {error channel};lappend ::records $text}\nproc flush {channel} {}\nset records {};set ::ia840f_compare04::audit AUDIT\n'
 sources=[(ROOT/n).read_text() for n in ['scope-collections.tcl','clock-inventory.tcl','expected-baseline.tcl']]
 cases=[('native_raw_waveform_data','baseline','',False),('new_C_identity_only','candidate','dict set state $C $new_definition',False),
        ('wrong_variant','wrong','',True),('clock_removed','baseline','dict unset state PCIE_REFCLK0',True),
        ('unexpected_clock','baseline','dict set state OTHER [dict get $state PCIE_REFCLK0]',True),
        ('C_in_baseline','baseline','dict set state $C $new_definition',True),('C_missing','candidate','',True),
        ('period_changed','baseline','dict set state PCIE_REFCLK0 period 10.001',True),
        ('waveform_changed','baseline','dict set state PCIE_REFCLK0 waveform {0.000 4.000}',True),
        ('target_changed','baseline','dict set state PCIE_REFCLK0 targets WRONG',True),
        ('generated_changed','baseline','dict set state PCIE_REFCLK0 generated {M I 2 1}',True),
        ('unknown_field','baseline','dict set state PCIE_REFCLK0 extra value',True),
        ('wrong_type','baseline','dict set state PCIE_REFCLK0 type other',True),
        ('waveform_width','baseline','dict set state PCIE_REFCLK0 waveform {0 1 2}',True),
        ('negative_period','baseline','dict set state PCIE_REFCLK0 period -10.000',True),
        ('reference_count','baseline','dict unset expected PCIE_REFCLK0',True),
        ('duplicate_target','baseline','dict set state PCIE_REFCLK0 targets {PCIE_REFCLK0 PCIE_REFCLK0}',True),
        ('clock_cap','baseline','for {set i 0} {$i<177} {incr i} {dict set state EXTRA$i [dict get $state PCIE_REFCLK0]}',True)]
 out=[]
 for case,variant,mutation,reject in cases:
  p=L.Tcl_CreateInterp()
  try:
   for s in sources+[setup,mutation]:
    rc,msg=ev(p,s)
    if rc:raise RuntimeError(('setup',case,rc,msg))
   if case=='native_raw_waveform_data':
    rc,msg=ev(p,'expr {[dict get $state PCIE_REFCLK0 waveform] ne [dict get $expected PCIE_REFCLK0 waveform]}')
    if rc or msg!='1':raise RuntimeError('native raw list-format discrepancy not reproduced')
   rc,msg=ev(p,'::ia840f_compare04::verify_clock_inventory '+variant+' $state $expected $C')
   if (reject and (rc!=1 or 'COMPARE04_REJECT' not in msg)) or (not reject and rc):raise RuntimeError((case,rc,msg))
   out.append({'case':case,'pass':True,'expected_rejection':reject})
  finally:L.Tcl_DeleteInterp(p)
 print(json.dumps({'scope':'local captured-data comparison only, not native snapshot/insertion/new-clock validation','count':len(out),'tests':out,
                   'source_clock_count':len(data['clock_definitions']),'source_sha256':hashlib.sha256(inp.read_bytes()).hexdigest(),
                   'sha256':{n:hashlib.sha256((ROOT/n).read_bytes()).hexdigest() for n in ['scope-collections.tcl','clock-inventory.tcl','expected-baseline.tcl','test-clock-inventory.py']}},indent=2))
if __name__=='__main__':main()
