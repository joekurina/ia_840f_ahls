import base64, datetime, gzip, hashlib, json, os, socket, subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_20';E=B/'qualification/fim-build-20';batch='ia840f_fim20_elab_failure01'
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX')
r={'batch':batch,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{},'source_hits':{},'report_hits':{},'libraries_listing':{}}
def export(p):
 b=p.read_bytes();assert len(b)<2000000;r['files'][str(p)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
for p in [E/'run/status.json',E/'run/native-status.json',E/'run/native.log',E/'compile-authorization.json',W/'syn/board/ia840f/syn_top/output_files/ofs_top.flow.rpt']:
 export(p)
for version in ['25.1','26.1.1']:
 lib=Path('/opt/altera')/version/'quartus/libraries'
 for sub in ['megafunctions','primitives','vhdl','verilog']:
  root=lib/sub
  if root.exists():
   for p in root.rglob('*sld*host*'):
    if p.is_file() and p.stat().st_size<2000000:export(p)
for p in W.rglob('*'):
 if p.is_file() and p.suffix in ('.v','.sv','.vhd','.vhdl','.qip','.tcl') and not {'qdb','db','output_files','incremental_db'}&set(p.parts) and p.stat().st_size<2000000:
  text=p.read_text(errors='replace');lines=text.splitlines();hits=[[i,l] for i,l in enumerate(lines,1) if 'altera_sld_host_endpoint' in l or 'CLTAP_CONNECTION' in l]
  if hits:r['source_hits'][str(p)]={'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'hits':hits};export(p)
for name in ['ofs_top.syn.rpt','ofs_top.syn.ae.rpt']:
 p=W/'syn/board/ia840f/syn_top/output_files'/name;data=p.read_bytes();lines=data.decode(errors='replace').splitlines();selected=set()
 for i,l in enumerate(lines):
  if 'altera_sld_host_endpoint' in l or 'CLTAP_CONNECTION' in l:
   selected.update(range(max(0,i-3),min(len(lines),i+5)))
 r['report_hits'][name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'selected_lines':[[i+1,lines[i]] for i in sorted(selected)]}
r['processes']=subprocess.check_output(['ps','-eo','pid,ppid,stat,comm,args'],text=True)
raw=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0)
(E/'elab-failure01.json.gz').write_bytes(raw)
subprocess.run(['tmux','load-buffer','-b',batch,'-'],input=raw,check=True)
print('ELAB_FAILURE01',hashlib.sha256(raw).hexdigest(),flush=True)
