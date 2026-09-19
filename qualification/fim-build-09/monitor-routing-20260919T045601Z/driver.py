import pathlib, subprocess, datetime, json, shlex, base64, zlib, time, hashlib, io, tarfile
P=pathlib.Path
D=P(__file__).parent
source=(D/'monitor.py').read_text()
host='uwb_student00@100.101.227.97'; session='ia840f_mailbox_monitored_01'; window='work09_routing_20260919T045601Z'
encoded=base64.b64encode(zlib.compress(source.encode())).decode()
bootstrap="import os,base64,zlib; s=zlib.decompress(base64.b64decode("+repr(encoded)+")).decode(); os.environ['MONITOR_SOURCE']=s; exec(compile(s,'work09-placement-monitor','exec'))"
command='cd /home/uwb_student00/ahls/new_BSP/qualification/fim-build-09 && python3 -u -c '+shlex.quote(bootstrap)+'; sleep 300'
remote=['tmux','new-window','-d','-P','-F','#{window_id}','-t',session,'-n',window,command]
(D/'ssh-invocation.json').write_text(json.dumps({'host':host,'argv':remote},indent=2))
def ssh(args):
 return subprocess.run(['ssh','-o','BatchMode=yes','-o','ConnectTimeout=12',host,shlex.join(args)],capture_output=True,check=True,timeout=30).stdout
wid=ssh(remote).decode().strip(); print('OWN_WINDOW '+wid,flush=True)
transfer=None
for i in range(30):
 time.sleep(10)
 text=ssh(['tmux','capture-pane','-p','-J','-S','-200','-t',session+':'+window]).decode()
 (D/'pane.log').write_text(text)
 if 'TRANSFER ' in text:
  transfer=json.loads(next(x.split('TRANSFER ',1)[1] for x in text.splitlines() if x.startswith('TRANSFER ')));break
 if 'Traceback' in text: raise RuntimeError(text)
if not transfer: raise RuntimeError('No final transfer within 300 seconds; see pane.log')
assert transfer['buffer'].startswith('work09-') and '/monitor-routing-' in transfer['evidence']
archive=ssh(['tmux','save-buffer','-b',transfer['buffer'],'-'])
assert len(archive)==transfer['size'] and hashlib.sha256(archive).hexdigest()==transfer['sha256']
(D/'evidence.tar.gz').write_bytes(archive); (D/'transfer.json').write_text(json.dumps(transfer,indent=2))
R=D/'verified';R.mkdir(exist_ok=False)
with tarfile.open(fileobj=io.BytesIO(archive),mode='r:gz') as t:
 for m in t.getmembers():
  assert m.isfile() and not P(m.name).is_absolute() and '..' not in P(m.name).parts
  p=R/m.name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(t.extractfile(m).read())
manifest=json.loads((R/'manifest.json').read_text())
for name,meta in manifest.items():
 data=(R/name).read_bytes();assert len(data)==meta['size'] and hashlib.sha256(data).hexdigest()==meta['sha256']
assert (R/'monitor.py').read_text()==source
summary=json.loads((R/'summary.json').read_text());assert summary['evidence']==transfer['evidence']
verification={'verified_files':len(manifest),'archive_size':len(archive),'archive_sha256':transfer['sha256'],'remote_evidence':transfer['evidence'],'window':session+':'+window}
(D/'verification.json').write_text(json.dumps(verification,indent=2))
print(json.dumps(verification,indent=2)); print(json.dumps(summary,indent=2))
last=json.loads(sorted(R.glob('sample-*.json'))[-1].read_text())
print('FINAL_MILESTONES '+json.dumps(last['milestones']))
print('FINAL_DIAGNOSTICS '+json.dumps(last['diagnostics']))
