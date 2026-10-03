"""Invoke the reviewed admitted assembly runner once; collect its actual result."""
import base64,datetime,gzip,hashlib,json,os,subprocess,sys,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01');P=ROOT/'control07';R=ROOT/'asm01';J=ROOT/'base01/build/syn/board/ia840f/syn_top';BATCH=sys.argv[1];L=ROOT/'launch19'
EXPECTED='d9466be2aa039c5160bbf4082fc241ff431387ccb14564fa06ade03ee54d3549'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
out={'batch':BATCH,'scope':'one admitted CMake-native persona assembly and ordinary-file result collection only','success':False,'hardware_access':False,'exports':{}};owned=False
try:
    assert __debug__ and os.environ.get('TMUX') and not L.exists() and not R.exists()
    assert sha(P/'asm-inputs.admitted.json')==EXPECTED
    assert sha(P/'runtime/run-asm07.py')=='1e90a0b24b92824edd616f129fc14f34594c23a17525117f21e30f14f225db1d'
    L.mkdir(exist_ok=False);owned=True
    argv=['/usr/bin/python3','-I','-B',str(P/'runtime/run-asm07.py'),EXPECTED]
    out.update(runner_argv=argv,runner_cwd=str(J),started=datetime.datetime.now(datetime.timezone.utc).isoformat(),window_pane=subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#{window_id} #{pane_id}'],text=True).strip())
    with (L/'invocation.json').open('x') as stream:json.dump({k:v for k,v in out.items() if k!='exports'},stream,indent=2)
    with (L/'runner.log').open('xb') as log:
        child=subprocess.Popen(argv,cwd=J,stdout=log,stderr=subprocess.STDOUT)
        out['runner_pid']=child.pid
        subprocess.run(['tmux','set-buffer','-b',BATCH+'_runner_pid',str(child.pid)],check=True)
        rc=child.wait();out['runner_outer_rc']=rc
    with (L/'runner-exit.json').open('x') as stream:json.dump({'argv':argv,'rc':rc,'ended':datetime.datetime.now(datetime.timezone.utc).isoformat()},stream,indent=2)
    assert (R/'result.json').is_file(),'runner did not persist a terminal result; do not relaunch'
    result=json.loads((R/'result.json').read_text());out['native_result']=result
    for name,path in {'result.json':R/'result.json','assembly.log':R/'assembly.log','configure.log':R/'configure.log','runner.log':L/'runner.log','gate-events.jsonl':R/'gate-events.jsonl','output_files/ofs_pr_afu.asm.rpt':J/'output_files/ofs_pr_afu.asm.rpt','output_files/ofs_pr_afu.flow.rpt':J/'output_files/ofs_pr_afu.flow.rpt','output_files/user_clock_freq.txt':J/'output_files/user_clock_freq.txt','build_env_db.txt':J/'build_env_db.txt','ofs_top.qpf':J/'ofs_top.qpf','qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.asm.model':J/'qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.asm.model','qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.asm.rdb':J/'qdb/_compiler/ofs_pr_afu/_flat/26.1.1/_all/1/report.asm.rdb','qdb/_compiler/ofs_pr_afu/_flat/26.1.1/legacy/1/ofs_pr_afu.asm.qmsgdb':J/'qdb/_compiler/ofs_pr_afu/_flat/26.1.1/legacy/1/ofs_pr_afu.asm.qmsgdb'}.items():
        if not path.is_file():continue
        stat=path.stat();assert stat.st_size<=16*1024**2
        data=path.read_bytes();after=path.stat();assert len(data)==stat.st_size==after.st_size and stat.st_mtime_ns==after.st_mtime_ns
        out['exports'][name]={'source':str(path),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
    out['success']=rc==0 and result.get('execution_clean') is True
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
out['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat()
if owned:
    with (L/'collection-result19.json').open('x') as stream:json.dump({k:v for k,v in out.items() if k not in ['exports','native_result']},stream,indent=2)
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success'],'runner_outer_rc':out.get('runner_outer_rc')}),flush=True)
if not out['success']:raise SystemExit(1)
