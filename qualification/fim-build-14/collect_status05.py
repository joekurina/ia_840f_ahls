#!/usr/bin/env python3
"""One finite ordinary-file/OS snapshot; no device or vendor command."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14')
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX')
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
r=dict(batch='ia840f_fim14_status05',time=datetime.datetime.now(datetime.timezone.utc).isoformat(),pane=os.environ['TMUX_PANE'],files={},missing=[],logs={},processes=[])
paths=['compile-authorization.json','native-compile.claim.json','compile-spec-review01.md','compile-quality-review01.md','COMPILE-PACKAGE-ACCEPTANCE.md','parent-consumption01.json','compile-candidate-01/consumed-reviews.json','launch04/resource-preflight.json','launch04/issuer-result.json','launch04/issuance-readback.json','launch04/runner-handoff.json','launch04/launch-error.json','run/status.json','run/invocation.json','run/native-status.json']
for rel in paths:
 p=E/rel
 if not p.exists():r['missing'].append(rel);continue
 assert p.is_file() and not p.is_symlink() and p.resolve().is_relative_to(E)
 b=p.read_bytes();assert len(b)<2000000
 r['files'][rel]=dict(size=len(b),sha256=hashlib.sha256(b).hexdigest(),base64=base64.b64encode(b).decode())
for rel in ['launch04/launch.log','run/native.log']:
 p=E/rel
 if not p.exists():continue
 with p.open('rb') as f:
  size=f.seek(0,2);f.seek(max(0,size-32768));b=f.read()
 r['logs'][rel]=dict(size=size,excerpt_offset=max(0,size-32768),excerpt_sha256=hashlib.sha256(b).hexdigest(),text=b.decode(errors='replace'))
ps=subprocess.check_output(['ps','-eo','pid,ppid,stat,pcpu,rss,comm,args'],text=True).splitlines()
for line in ps[1:]:
 fields=line.split(None,6)
 if len(fields)==7 and (fields[5].startswith(('quartus_','qsys-')) or 'work_ia840f_fim_14' in fields[6] or 'fim-build-14/compile-candidate-01/launch_native_compile.py' in fields[6]):
  pid=fields[0];entry=dict(ps=line)
  try:
   entry.update(exe=os.readlink('/proc/'+pid+'/exe'),cwd=os.readlink('/proc/'+pid+'/cwd'),argv=Path('/proc/'+pid+'/cmdline').read_bytes().decode(errors='replace').rstrip('\0').split('\0'),stat=Path('/proc/'+pid+'/stat').read_text())
  except OSError as e:entry['process_read_error']=repr(e)
  r['processes'].append(entry)
raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
subprocess.run(['tmux','load-buffer','-b',r['batch'],'-'],input=blob,check=True)
print('STATUS05 JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),flush=True)
