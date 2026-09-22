import os,socket,json,datetime,hashlib,gzip,subprocess
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
b=subprocess.check_output(['tmux','save-buffer','-b','ia840f_fim15_postflight01_inputs','-']);assert hashlib.sha256(b).hexdigest()=='2e5c62d4a13fd02e4db4fef1d052a574f4cfc690bd31f24ba04b0a3ea9e65036'
v=json.loads(gzip.decompress(b));B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-15';C=B/'ofs-agx7-pcie-attach';W=B/'work_ia840f_fim_15'
state=json.loads((E/'run/status.json').read_text());assert state['state']=='finished'
assert hashlib.sha256((E/'compile-authorization.json').read_bytes()).hexdigest()=='c691e5faa2a0260397f3683d88fd4fb1c8814d195ee028997d6c812a535d49b2'
ps=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True);active=[x for x in ps.splitlines()[1:] if x.split(None,3)[2].startswith(('quartus_','qsys-'))];assert not active
r={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'baseline_archive_sha256':v['baseline_archive_sha256'],'payload_sha256':'2e5c62d4a13fd02e4db4fef1d052a574f4cfc690bd31f24ba04b0a3ea9e65036','native_tools_active':active,'inventories':{},'deltas':{},'work_input_deltas':{}}
def sha(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for chunk in iter(lambda:f.read(1048576),b''):h.update(chunk)
 return h.hexdigest()
for root,old in v['baseline'].items():
 rootp=Path(root);assert rootp.parent==B;expected=json.loads(json.dumps(old))
 if rootp==C:
  for rel,item in v['source_delta'].items():assert expected[rel]=={'sha256':item['old']};expected[rel]={'sha256':item['new']}
 actual={}
 for p in sorted(rootp.rglob('*')):
  rel=str(p.relative_to(rootp))
  if p.is_symlink():assert p.resolve(strict=True).is_relative_to(rootp);actual[rel]={'link':os.readlink(p)}
  elif p.is_file():actual[rel]={'sha256':sha(p)}
 r['inventories'][root]=actual
 r['deltas'][root]={k:{'expected':expected.get(k),'actual':actual.get(k)} for k in sorted(set(expected)|set(actual)) if expected.get(k)!=actual.get(k)}
for rel,old in v['draft']['work_inventory'].items():
 p=W/rel
 now=({'symlink':os.readlink(p)} if p.is_symlink() else {'sha256':sha(p)}) if p.exists() or p.is_symlink() else None
 if old!=now:r['work_input_deltas'][rel]={'before':old,'after':now}
r['original_work14_unchanged']=not r['deltas'][str(B/'work_ia840f_fim_14')]
r['pim_full_unchanged']=not r['deltas'][str(B/'ofs-platform-afu-bbb')]
r['source_full_matches_prelaunch_three_file_delta']=not r['deltas'][str(C)]
blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim15_postflight01','-'],input=blob,check=True)
print('POSTFLIGHT01',hashlib.sha256(blob).hexdigest(),flush=True)
