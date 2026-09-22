#!/usr/bin/env python3
"""One-shot transport/issuance handoff to the already reviewed native runner."""
import base64,datetime,hashlib,json,os,shutil,socket,subprocess,sys,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-14';P=E/'compile-candidate-01';D=E/'launch04'
def req(value,message):
    if not value:raise RuntimeError(message)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def newjson(p,value):
    with p.open('x') as f:json.dump(value,f,indent=2)
req(not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX'),'wrong execution context')
req(subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01','wrong owned session')
D.mkdir();out=(D/'launch.log').open('xb',buffering=0);os.dup2(out.fileno(),1);os.dup2(out.fileno(),2)
try:
    raw=subprocess.check_output(['tmux','save-buffer','-b','ia840f_fim14_launch04_payload','-'])
    req(len(sys.argv)==2 and hashlib.sha256(raw).hexdigest()==sys.argv[1],'payload changed')
    packet=json.loads(raw)
    req(set(packet)=={'compile-spec-review01.md','compile-quality-review01.md','COMPILE-PACKAGE-ACCEPTANCE.md','parent-consumption01.json'},'unexpected payload members')
    req(sha(P/'review-package-sha256.json')=='d6323f8f243d1fceefb233680fa851a25676889b761348b0760de23b3602dc8b','package changed')
    for p in (E/'compile-authorization.json',E/'native-compile.claim.json',E/'run',P/'authorization-issuance.lock',P/'consumed-reviews.json'):
        req(not p.exists() and not p.is_symlink(),'already consumed '+str(p))
    mem={k:int(v.split()[0])*1024 for k,v in (line.split(':',1) for line in Path('/proc/meminfo').read_text().splitlines())}
    free=shutil.disk_usage(B).free
    ps=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True).splitlines()[1:]
    competing=[line for line in ps if len(line.split())>=3 and (line.split()[2].startswith(('quartus_','qsys-')) or line.split()[2] in ('aoc','ahls','vsim','vopt','vlog'))]
    preflight=dict(time=datetime.datetime.now(datetime.timezone.utc).isoformat(),hostname=socket.gethostname(),pane=os.environ['TMUX_PANE'],pid=os.getpid(),available_memory=mem['MemAvailable'],swap_used=mem['SwapTotal']-mem['SwapFree'],free_disk=free,competing=competing,minimum_available_memory=96*1024**3,minimum_free_disk=100*1024**3)
    newjson(D/'resource-preflight.json',preflight)
    req(not competing and mem['MemAvailable']>=96*1024**3 and free>=100*1024**3,'resource/ownership preflight failed')
    for name,item in packet.items():
        data=base64.b64decode(item['base64'],validate=True);req(hashlib.sha256(data).hexdigest()==item['sha256'],'member mismatch')
        with (E/name).open('xb') as f:f.write(data)
        req(sha(E/name)==item['sha256'],'readback mismatch')
    reviews=json.loads((E/'parent-consumption01.json').read_text())
    req(reviews['parent_acceptance_explicit'] is True and reviews['parent_acceptance_sha256']==sha(E/'COMPILE-PACKAGE-ACCEPTANCE.md'),'parent acceptance mismatch')
    cmd=[sys.executable,'-B',str(P/'issue_authorization.py'),str(E/'parent-consumption01.json')]
    result=subprocess.run(cmd,cwd=B)
    newjson(D/'issuer-result.json',dict(argv=cmd,returncode=result.returncode))
    req(result.returncode==0,'issuer failed; no retry')
    issued=json.loads((E/'compile-authorization.json').read_text());draft=json.loads((P/'compile-authorization.draft.json').read_text())
    expected=dict(draft);expected.update(approved=True,accepted_execution=True,source_review_consumed=True,gate_review_consumed=True)
    expected['dependency_sha256']=dict(draft['dependency_sha256'])
    for p in (P/'consumed-reviews.json',P/'review-package-sha256.json',P/'compile-authorization.draft.json',E/'parent-consumption01.json',E/'compile-spec-review01.md',E/'compile-quality-review01.md'):expected['dependency_sha256'][str(p)]=sha(p)
    req(issued==expected,'issued record differs from exact expected readback')
    req(json.loads((P/'consumed-reviews.json').read_text())==reviews,'consumed reviews mismatch')
    newjson(D/'issuance-readback.json',dict(authorization_sha256=sha(E/'compile-authorization.json'),expected_record_equal=True,package_manifest_sha256=reviews['package_manifest_sha256'],review_reports_verified=True,ready_for_build=issued['ready_for_build'],permissions=issued['permissions']))
    # Only this existing manifest-bound runner starts the native compile.
    manifest=json.loads((P/'review-package-sha256.json').read_text())
    runner=P/'launch_native_compile.py';req(sha(runner)==manifest['launch_native_compile.py'],'runner changed')
    argv=[sys.executable,'-B',str(runner)]
    newjson(D/'runner-handoff.json',dict(argv=argv,pid=os.getpid(),pane=os.environ['TMUX_PANE'],cwd=str(B),time=datetime.datetime.now(datetime.timezone.utc).isoformat()))
    print('AUTHORIZATION_READBACK_PASS; EXEC_REVIEWED_RUNNER',flush=True)
    os.chdir(B);os.execv(sys.executable,argv)
except BaseException as error:
    newjson(D/'launch-error.json',dict(error=repr(error),traceback=traceback.format_exc()))
    traceback.print_exc();raise
