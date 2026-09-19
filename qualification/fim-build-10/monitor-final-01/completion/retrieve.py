from pathlib import Path
import subprocess,json,hashlib,zlib,base64
P=Path(__file__).parent
host='uwb_student00@100.101.227.97'
commands=[]
def call(remote):
 argv=['ssh',host,remote];commands.append(argv)
 return subprocess.check_output(argv)
pane=(P/'monitor.pane').read_text().strip()
text=call('tmux capture-pane -p -J -S -2000 -t '+pane).decode()
(P/'pane-capture.txt').write_text(text)
exports=[json.loads(x[7:]) for x in text.splitlines() if x.startswith('EXPORT ')]
assert len(exports)==1,'Monitor export not yet available'
meta=exports[0]
blob=call('tmux save-buffer -b '+meta['buffer']+' -')
sha=lambda b:hashlib.sha256(b).hexdigest()
assert len(blob)==meta['size'] and sha(blob)==meta['sha256']
(P/'export.json.zlib').write_bytes(blob)
obj=json.loads(zlib.decompress(blob));assert obj['batch']=='monitor-final-01/completion'
D=P/'readback';D.mkdir(exist_ok=False)
verified=[]
for rel,info in obj['files'].items():
 target=D/rel;assert not Path(rel).is_absolute() and '..' not in Path(rel).parts
 data=base64.b64decode(info['base64']);assert len(data)==info['size'] and sha(data)==info['sha256']
 target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
 assert sha(target.read_bytes())==info['sha256'] and target.stat().st_size==info['size']
 verified.append({'path':rel,'size':len(data),'sha256':sha(data)})
assert (D/'monitor.py').read_bytes()==(P/'monitor.py').read_bytes()
samples=[json.loads(x) for x in (D/'samples.jsonl').read_text().splitlines()]
a,b=samples[0],samples[-1]
progress=[]
for last in b['processes']:
 first=next((p for p in a['processes'] if (p['pid'],p['start_ticks'])==(last['pid'],last['start_ticks'])),None)
 if first:progress.append({'pid':last['pid'],'exe':last.get('exe'),'start_ticks':last['start_ticks'],'cpu_ticks_delta':last['utime']+last['stime']-first['utime']-first['stime']})
summary={'transfer':meta,'verified_file_count':len(verified),'verified_files':verified,'commands':commands,'first_utc':a['utc'],'last_utc':b['utc'],'process_progress':progress,'last_sample':b}
(P/'transfer-verification.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({'verified_file_count':len(verified),'transfer_sha256':sha(blob),'result':json.loads((D/'result.json').read_text()),'process_progress':progress,'last_sample':b},indent=2))
