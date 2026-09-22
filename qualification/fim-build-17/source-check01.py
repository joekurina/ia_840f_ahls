import os,sys,socket,subprocess,datetime,hashlib,json,base64
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');C=B/'ofs-agx7-pcie-attach';W=B/'work_ia840f_fim_16';E=B/'qualification/fim-build-16'
assert not sys.flags.optimize and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
assert not (B/'work_ia840f_fim_17').exists() and not (B/'qualification/fim-build-17').exists()
a=(E/'compile-authorization.json').read_bytes();assert hashlib.sha256(a).hexdigest()=='1c2326b7814574e4039e155a7fcb3ed2578ba9cfb827cb39295d89da6c1bea84';record=json.loads(a)
state=json.loads((E/'run/status.json').read_bytes());assert state['state']=='finished' and state['native_returncode']==0 and not state['gate_rejection']
ps=subprocess.check_output(['ps','-eo','pid,ppid,comm,args'],text=True);active=[x for x in ps.splitlines()[1:] if len(x.split())>=3 and x.split()[2].startswith(('quartus_','qsys-'))];assert not active
exports={}
for root,key in ((C,'source'),(W,'work16')):
 for rel in ('syn/board/ia840f/syn_top/ofs_top.qsf','syn/shared_config/top.sdc'):
  p=root/rel;assert p.is_file() and not p.is_symlink() and p.resolve().is_relative_to(root);b=p.read_bytes();h=hashlib.sha256(b).hexdigest()
  expected=record['source_sha256']['syn'][rel[4:]] if key=='source' else record['work_inventory'][rel]['sha256'];assert h==expected
  exports[key+'/'+rel]={'bytes':len(b),'sha256':h,'base64':base64.b64encode(b).decode()}
v={'batch':'ia840f_fim17_sourcecheck01','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':exports,'native_tools_active':active,'work16_status':state,'mem_available_bytes':int(next(x.split()[1] for x in Path('/proc/meminfo').read_text().splitlines() if x.startswith('MemAvailable:')))*1024,'future_roots_absent':True}
b=json.dumps(v,sort_keys=True).encode();subprocess.run(['tmux','load-buffer','-b',v['batch'],'-'],input=b,check=True);print('WORK17_SOURCECHECK01',hashlib.sha256(b).hexdigest(),flush=True)
