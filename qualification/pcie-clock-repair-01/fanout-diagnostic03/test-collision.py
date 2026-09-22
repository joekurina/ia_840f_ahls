#!/usr/bin/env python3
"""Full-entry INERT old-fail/new-pass Tcl scalar/array differential.

Synthetic caller-frame injections are not recovered Quartus internals.
Imports only the existing inert fixture definitions. No vendor, remote,
real project opening, authorization, source writes or array cleanup.
"""
from pathlib import Path
import hashlib,json,re,runpy,sys
ROOT=Path(__file__).resolve().parent
OLD=ROOT.parent/'fanout-diagnostic02'/'prepared-readback01'
EXPECTED_OLD='de849ce56c3ae6db993a1e27d427c574cf6cccb7b7d68272a1c0ca8ab2468e5c'
fixture=runpy.run_path(str(ROOT/'test-query.py'))
lib=fixture['lib'];ev=fixture['ev'];literal=fixture['literal']

# Observe the caller array before its procedure frame disappears, on both
# successful and exceptional body exits. Never unset/change the sentinel.
LOOP=r'''
proc foreach_in_collection {v id body} {
 if {$::case eq "loop_array" && $v eq "cell"} {
  uplevel 1 {array set pins {fixture_guard unchanged}}
 }
 set code [catch {uplevel 1 [list foreach $v [items $id] $body]} result options]
 if {[uplevel 1 {array exists pins}]} {
  lappend ::array_snapshots [list $v [uplevel 1 {array get pins}]]
 }
 return -options $options $result
}
'''


def execute(case,directory,old):
    query=(directory/'query.tcl').read_text()
    roots=re.findall(r'^    variable E (\S+)$',query,re.M)
    assert len(roots)==1
    remote=roots[0]
    expected_root='/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic'+('02' if old else '03')
    assert remote==expected_root
    mock=fixture['MOCK']
    replacements=[
        ('proc foreach_in_collection {v id body} {uplevel 1 [list foreach $v [items $id] $body]}',LOOP.strip()),
        ('proc read_sdc {args} {if {[llength $args]} {error NOT_NORMAL_SDC_ORDER}}',
         'proc read_sdc {args} {if {[llength $args]} {error NOT_NORMAL_SDC_ORDER};if {$::case eq "sdc_array"} {uplevel 1 {array set pins {fixture_guard unchanged}}}}'),
        ('-pins {if {$::case eq "pins_over"',
         '-pins {if {$::case eq "api_array"} {uplevel 1 {array set pins {fixture_guard unchanged}}};if {$::case eq "pins_over"'),
    ]
    for a,b in replacements:
        assert mock.count(a)==1
        mock=mock.replace(a,b)
    p=lib.Tcl_CreateInterp()
    try:
        setup=f'set case {literal(case)};set root {literal(remote)};set cwd {literal(remote+"/scratch/syn/board/ia840f/syn_top")};set array_snapshots {{}}'
        for s in [setup,mock]:
            rc,msg=ev(p,s);assert rc==0,msg
        if case=='global_array':
            rc,msg=ev(p,'array set ::pins {fixture_guard unchanged}');assert rc==0,msg
        rc,msg=ev(p,'source '+literal(directory/'query.tcl'))
        def val(s):
            code,text=ev(p,s);assert code==0,text;return text
        failed=old and case in {'sdc_array','loop_array','api_array'}
        assert rc==(1 if failed else 0),(case,old,rc,msg)
        if failed:assert msg=='can\'t set "pins": variable is array',(case,msg)
        marker=int(val('expr {[lsearch -exact $stdout IA840F_FANOUT_CONTRAST_COMPLETE]>=0}'))
        assert marker==int(not failed)
        tags=['FANOUT_COUNT','LOOKUP_INPUT','TILE','CELL','CLOCK_INPUT','CELL_REGISTER_MAP','REGISTER','DIAGNOSTIC_STATUS','COMPLETE','INCOMPLETE']
        counts={tag:int(val('count_event '+tag)) for tag in tags}
        assert counts['FANOUT_COUNT']==4 and counts['LOOKUP_INPUT']==6 and counts['TILE']==1 and counts['INCOMPLETE']==0,counts
        if failed:
            assert counts['CELL']==1 and all(counts[t]==0 for t in ['CLOCK_INPUT','CELL_REGISTER_MAP','REGISTER','DIAGNOSTIC_STATUS','COMPLETE']),counts
        else:
            assert all(counts[t]==32 for t in ['CELL','CLOCK_INPUT','CELL_REGISTER_MAP','REGISTER']) and counts['DIAGNOSTIC_STATUS']==counts['COMPLETE']==1,counts
            assert val('set s {};foreach e $events {if {[lindex $e 0] eq "DIAGNOSTIC_STATUS"} {set s [lrange $e 1 4]}};set s')=='complete 1 mapping_single_register_each 1'
        snapshots=int(val('llength $array_snapshots'))
        preserved=val('set ok 1;foreach row $array_snapshots {if {[lindex $row 1] ne {fixture_guard unchanged}} {set ok 0}};set ok')=='1'
        assert preserved
        if case in {'sdc_array','loop_array','api_array'}:assert snapshots>0
        else:assert snapshots==0
        if case=='global_array':assert val('array get ::pins')=='fixture_guard unchanged'
        else:assert val('array exists ::pins')=='0'
        return {'version':'old' if old else 'successor','case':case,'pass':True,'tcl_rc':rc,'message':msg,'completion_markers':marker,'records':counts,'caller_array_snapshots':snapshots,'caller_array_unchanged':preserved,'global_control_unchanged':case=='global_array'}
    finally:lib.Tcl_DeleteInterp(p)


def main():
    assert not sys.flags.optimize and sys.argv[1:] in ([],['--prepared'])
    d=ROOT/'prepared-readback01' if sys.argv[1:] else ROOT
    before={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for directory in [OLD,d] for p in (directory/'query.tcl',directory/'clock-repair.tcl',directory/'known-receivers.tcl')}
    assert before[str(OLD/'query.tcl')]==EXPECTED_OLD
    original=(OLD/'query.tcl').read_text()
    expected=original.replace('fanout-diagnostic02','fanout-diagnostic03')
    for a,b in [('set pins [get_cell_info -pins $cell]','set ia840f_fc_cell_pin_collection [get_cell_info -pins $cell]'),('[observe "pins:$name" $pins 32 pin]','[observe "pins:$name" $ia840f_fc_cell_pin_collection 32 pin]'),('foreach_in_collection pin $pins {','foreach_in_collection pin $ia840f_fc_cell_pin_collection {')]:
        assert expected.count(a)==1;expected=expected.replace(a,b)
    assert (d/'query.tcl').read_text()==expected
    for n in ['clock-repair.tcl','known-receivers.tcl']:assert (d/n).read_bytes()==(OLD/n).read_bytes()
    if d!=ROOT:
        c=json.loads((d/'candidate.json').read_text())
        remote='/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic03'
        assert c['cwd']==remote+'/scratch/syn/board/ia840f/syn_top'
        for n in ['query.tcl','clock-repair.tcl','known-receivers.tcl']:
            assert before[str(d/n)]==c['files'][remote+'/'+n]==c['callback_files'][remote+'/'+n]
    rows=[execute(case,directory,old) for case in ['none','global_array','sdc_array','loop_array','api_array'] for directory,old in [(OLD,True),(d,False)]]
    assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==h for p,h in before.items())
    print(json.dumps({'scope':'INERT full-entry differential; synthetic scope mechanisms, not native origin proof; no vendor/project/hardware/authorization','prepared':d!=ROOT,'source_sha256':before,'fixture_sha256':hashlib.sha256((ROOT/'test-query.py').read_bytes()).hexdigest(),'test_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'count':len(rows),'tests':rows},indent=2))
if __name__=='__main__':main()
