#!/usr/bin/env python3
"""Capture native Fitter help only, in a fresh empty evidence directory."""
import base64, datetime, gzip, hashlib, json, os, pathlib, socket, subprocess
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX') and not __debug__ is False
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#{session_name}'],text=True).strip()=='ia840f_mailbox_monitored_01'
BATCH='ia840f_emif_fit_help02'
ROOT=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/emif-hold-objective-01/fit-help02')
TOOLS=['/opt/altera/26.1.1/quartus/bin/quartus_fit','/opt/altera/26.1.1/quartus/linux64/quartus_fit']
# No project is opened and no synthesis/fitting command is issued.
argv=[TOOLS[0],'--tcl_eval','set rc [catch {load_package sta} msg]; puts "LOAD_STA_RC=$rc MSG=$msg"; if {$rc == 0} { foreach c {create_timing_netlist read_sdc report_sdc get_timequest_info get_clock_info get_clocks} { puts "BEGIN_HELP $c"; puts [help -cmd $c]; puts "END_HELP $c" }; puts "TIMEQUEST_APP [array get ::TimeQuestInfo nameofexecutable]" }']
EXPECTED={'/opt/altera/26.1.1/quartus/bin/quartus_fit': '06c1bd805bc078d9636015c472e09a054160c405f3f06b7c555e7a4b6f7d3f14', '/opt/altera/26.1.1/quartus/linux64/quartus_fit': '31e90c7dcdaee32f0dea50d633e2b6edc8bac075b44bc5caa278a9aaf016d35c'}
assert all(hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()==EXPECTED[p] for p in TOOLS),'tool binding changed'
ps=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
assert not any(len(x.split(None,3))>=3 and x.split(None,3)[2].startswith(('quartus_','qsys-')) for x in ps.splitlines()[1:]),'competing native process'
mem=dict((a,b.strip()) for a,b in (line.split(':',1) for line in pathlib.Path('/proc/meminfo').read_text().splitlines()))
assert int(mem['MemAvailable'].split()[0])*1024>=80000000000
ROOT.mkdir(parents=True,exist_ok=False)
record={'batch':BATCH,'started':datetime.datetime.now(datetime.timezone.utc).isoformat(),'argv':argv,'cwd':str(ROOT),'scope':'native Fitter Tcl API help/load_package sta only; no project or fitted database opened','tools':{p:hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest() for p in TOOLS},'ready_for_build':False}
(ROOT/'invocation.json').write_text(json.dumps(record,indent=2)+'\n')
env=os.environ.copy();env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus';env['PATH']='/opt/altera/26.1.1/quartus/bin:/usr/bin:/bin'
for k in list(env):
    if k.startswith('OFS_') or k in ('PYTHONOPTIMIZE','PYTHONPATH'):env.pop(k,None)
with (ROOT/'help.log').open('xb') as out:
    child=subprocess.Popen(argv,cwd=ROOT,env=env,stdout=out,stderr=subprocess.STDOUT,start_new_session=True)
    record['pid']=child.pid
    record['native_returncode']=child.wait()
record['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat()
output=(ROOT/'help.log').read_bytes();assert len(output)<=2000000
record['output_sha256']=hashlib.sha256(output).hexdigest();record['output_base64']=base64.b64encode(output).decode()
record['post_processes']=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True)
(ROOT/'result.json').write_text(json.dumps(record,indent=2)+'\n')
blob=gzip.compress(json.dumps(record,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH,'-'],input=blob,check=True)
print('EMIF_FIT_HELP02_COMPLETE',record['native_returncode'],hashlib.sha256(blob).hexdigest(),flush=True)
