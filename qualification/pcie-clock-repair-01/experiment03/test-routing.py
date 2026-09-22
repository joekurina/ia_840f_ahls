#!/usr/bin/env python3
"""Actual Tcl query entry in an INERT interpreter, stopped at project_open.

Vendor packages, pwd, report file operations and project_open are mocked.
No native executable, report writes, remote command, or authorization.
--prepared uses exact prepared query/helper and candidate.json cwd/argv.
"""
from pathlib import Path
import hashlib,json,runpy,sys
ROOT=Path(__file__).resolve().parent
support=runpy.run_path(str(ROOT/'test-guard.py'))
lib=support['lib'];evaluate=support['evaluate']
BASE='/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/'
SUFFIX='/scratch/syn/board/ia840f/syn_top'
MOCK=r'''
set packages {};set mkdirs {};set opens {};set emitted {};set project_calls {}
proc load_package {name} {
 if {$name ni {sta report}} {error "unexpected package"}
 lappend ::packages $name
}
proc pwd {} {return $::fixture_cwd}
rename file real_file
proc file {op args} {
 switch -- $op {
  join - dirname {return [real_file $op {*}$args]}
  exists {
   if {$args ne [list $::expected_reports]} {error "wrong exists path"}
   return $::spent
  }
  mkdir {
   if {$args ne [list $::expected_reports]} {error "wrong mkdir path"}
   lappend ::mkdirs {*}$args
  }
  default {error "unexpected file operation $op"}
 }
}
proc open {path mode} {
 if {$path ne "$::expected_reports/audit.tcllist" || $mode ne {WRONLY CREAT EXCL}} {error "wrong audit open"}
 lappend ::opens [list $path $mode]
 return INERT_AUDIT
}
proc puts {channel text} {
 if {$channel ne "INERT_AUDIT"} {error "wrong puts channel"}
 lappend ::emitted $text
}
proc flush {channel} {
 if {$channel ne "INERT_AUDIT"} {error "wrong flush channel"}
}
proc project_open {args} {
 lappend ::project_calls $args
 error INERT_PROJECT_OPEN_STOP
}
proc unknown {args} {error "FORBIDDEN_NATIVE_COMMAND $args"}
'''

def literal(value):
    if any(x in str(value) for x in '{}\\\n'):raise ValueError('unsupported fixture literal')
    return '{'+str(value)+'}'

def route(query,cwd,phase,root,case,expected,spent=False):
    p=lib.Tcl_CreateInterp()
    try:
        script='set fixture_cwd '+literal(cwd)+'\nset expected_reports '+literal(root+'/'+phase+'/reports')+'\nset spent '+('1' if spent else '0')+'\n'+MOCK
        rc,msg=evaluate(p,script)
        if rc:raise RuntimeError(msg)
        rc,msg=evaluate(p,'source '+literal(query))
        assert rc==1,(case,rc,msg)
        assert evaluate(p,'set packages')==(0,'sta report')
        checks={'mkdirs':evaluate(p,'llength $mkdirs')[1],'opens':evaluate(p,'llength $opens')[1],'emitted':evaluate(p,'llength $emitted')[1],'project_calls':evaluate(p,'llength $project_calls')[1]}
        if expected=='reached':
            assert msg=='INERT_PROJECT_OPEN_STOP',(case,msg)
            assert all(v=='1' for v in checks.values()),checks
            assert evaluate(p,'lindex $mkdirs 0')[1]==root+'/'+phase+'/reports'
            assert evaluate(p,'lindex [lindex $opens 0] 0')[1]==root+'/'+phase+'/reports/audit.tcllist'
            assert evaluate(p,'lindex $emitted 0')[1]=='BEGIN '+phase+' no_fit no_hardware no_timing_acceptance'
            assert evaluate(p,'lindex $project_calls 0')[1]=='-revision ofs_top ofs_top'
        else:
            error='spent reports directory' if expected=='spent' else 'unexpected project path'
            assert msg=='CLOCK_REPAIR_REJECT '+error,(case,msg)
            assert all(v=='0' for v in checks.values()),checks
        return {'case':case,'phase':phase,'cwd':cwd,'query_sha256':hashlib.sha256(query.read_bytes()).hexdigest(),'outcome':expected,'side_effect_calls':checks,'pass':True}
    finally:lib.Tcl_DeleteInterp(p)

def main():
    if sys.flags.optimize:raise RuntimeError('optimized fixtures forbidden')
    prepared=sys.argv[1:]==['--prepared']
    assert not sys.argv[1:] or prepared,'only --prepared accepted'
    rows=[];bindings={};root=BASE+ROOT.name
    for phase in ('baseline','candidate'):
        old=ROOT.parent/'experiment02'/phase/'prepared-readback01'
        oldrec=json.loads((old/'candidate.json').read_text())
        rows.append(route(old/'query.tcl',oldrec['cwd'],phase,BASE+'experiment02','S1_old_query_rejected_own_record','wrong'))
        D=ROOT/phase/('prepared-readback01' if prepared else '')
        if prepared:
            r=json.loads((D/'candidate.json').read_text());cwd=r['cwd']
            assert cwd==root+'/'+phase+SUFFIX
            assert r['argv']==['/opt/altera/26.1.1/quartus/bin/quartus_sta','-t',root+'/'+phase+'/query.tcl']
            assert r['files'][r['argv'][-1]]==hashlib.sha256((D/'query.tcl').read_bytes()).hexdigest()
            assert r['callback_files'][r['argv'][-1]]==r['files'][r['argv'][-1]]
            bindings[phase]={'candidate_sha256':hashlib.sha256((D/'candidate.json').read_bytes()).hexdigest(),'argv':r['argv'],'cwd':cwd}
        else:cwd=root+'/'+phase+SUFFIX
        assert (D/'query.tcl').read_bytes()==(ROOT/'query.tcl').read_bytes()
        assert (D/'clock-repair.tcl').read_bytes()==(ROOT/'clock-repair.tcl').read_bytes()
        rows.append(route(D/'query.tcl',cwd,phase,root,'current_bound_path','reached'))
        rows.append(route(D/'query.tcl',cwd,phase,root,'spent_reports','spent',True))
        for case,wrong in [('old01',BASE+'experiment01/'+phase+SUFFIX),('old02',BASE+'experiment02/'+phase+SUFFIX),('wrong_phase',root+'/other'+SUFFIX),('wrong_project',cwd+'_wrong')]:
            rows.append(route(D/'query.tcl',wrong,phase,root,case,'wrong'))
    print(json.dumps({'scope':'INERT actual Tcl source/main to mocked project_open sentinel; no vendor or filesystem report writes','prepared_readbacks':prepared,'count':len(rows),'tests':rows,'candidate_bindings':bindings,'helper_sha256':hashlib.sha256((ROOT/'clock-repair.tcl').read_bytes()).hexdigest()},indent=2))
if __name__=='__main__':main()
