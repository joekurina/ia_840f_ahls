import pathlib, subprocess, datetime, uuid, json, shlex, base64, time, hashlib, io, tarfile, os
root=pathlib.Path(__file__).parent
tag='monitor-'+datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'-'+uuid.uuid4().hex[:6]
local=root/tag
local.mkdir()
remote='/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/'+tag
code=(root/'monitor-code.py').read_text().replace("/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T033051Z-01e73a",remote)
code=code.replace("    if fatal:\n        S['stop_reason']='fatal_or_gate_125091'\n        break\n    if not any('quartus' in p for p in procs):\n        S['stop_reason']='quartus_processes_finished'\n        break\n    if time.monotonic()-start>=180: break", "    status=S['samples'][-1]['status']\n    if status.get('status') not in ('running',None) and not any('quartus' in p for p in procs):\n        S['stop_reason']='native_status_terminal_and_quartus_finished'\n        break\n    if time.monotonic()-start>=150:\n        S['stop_reason']='bounded_next_status'\n        break")
code=code.replace("S['images']=", "S['timing_outcome']='FAILED'\nS['programming_performed']=False\nS['images']=")
code=code.replace("'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in W.iterdir()", "'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'mtime_ns':p.stat().st_mtime_ns} for p in W.iterdir()")
code=code.replace("with tarfile.open(str(D)+'.tar.gz','w:gz') as t:", "for name in ['snapshot.json','receipt.json']:\n    p=D/name\n    print('META_HASH',name,hashlib.sha256(p.read_bytes()).hexdigest(),flush=True)\nwith tarfile.open(str(D)+'.tar.gz','w:gz') as t:")
(local/'monitor-code.py').write_text(code)
commands=[]
def ssh(args):
    commands.append(args)
    return subprocess.check_output(['ssh','-o','BatchMode=yes','-o','ConnectTimeout=10','uwb_student00@100.101.227.97',shlex.join(args)],timeout=35)
cmd='python3 -c '+shlex.quote('import base64;exec(base64.b64decode('+repr(base64.b64encode(code.encode()).decode())+'))')+'; exec bash'
pane=ssh(['tmux','new-window','-d','-P','-F','#{pane_id}','-t','ia840f_mailbox_monitored_01','-n',tag,cmd]).decode().strip()
meta={'pane':pane,'remote':remote,'local':str(local),'local_pid':os.getpid(),'commands':commands}
(local/'monitor-metadata.json').write_text(json.dumps(meta,indent=2))
print('MONITOR',str(local),pane,flush=True)
for _ in range(20):
    time.sleep(10)
    capture=ssh(['tmux','capture-pane','-p','-t',pane,'-S','-40']).decode()
    if 'DONE '+remote in capture: break
else: raise RuntimeError('Collector did not finish; evidence remains remote')
(local/'collector-output.txt').write_text(capture)
buf='evidence_'+uuid.uuid4().hex[:8]
ssh(['tmux','load-buffer','-b',buf,remote+'.tar.gz'])
data=ssh(['tmux','save-buffer','-b',buf,'-'])
(local/'evidence.tar.gz').write_bytes(data)
with tarfile.open(fileobj=io.BytesIO(data),mode='r:gz') as t: t.extractall(local,filter='data')
receipt=json.loads((local/'receipt.json').read_text())
checks=[{'name':r['name'],'verified':hashlib.sha256((local/r['name']).read_bytes()).hexdigest()==r['sha256'] and (local/r['name']).stat().st_size==r['bytes']} for r in receipt]
assert all(r['verified'] for r in checks)
(local/'verification.json').write_text(json.dumps(checks,indent=2))
(local/'monitor-metadata.json').write_text(json.dumps(meta,indent=2))
s=json.loads((local/'snapshot.json').read_text())
last=s['samples'][-1]
print(json.dumps({'local':str(local),'verified_files':len(checks),'stop_reason':s.get('stop_reason'),'status':last['status'],'processes':last['processes'],'tail':last['tail'],'images':s['images'],'fatal_diagnostics':s['fatal_diagnostics']},indent=2),flush=True)
