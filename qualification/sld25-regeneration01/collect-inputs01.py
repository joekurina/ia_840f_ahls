import base64,datetime,gzip,hashlib,json,os,socket,subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');batch='ia840f_sld25_inputs01';Q=Path('/opt/altera/25.1/quartus');E=B/'qualification/sld25-regeneration01';E.mkdir()
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX')
r={'batch':batch,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'files':{},'listings':{},'help':{}}
def export(p):
 b=p.read_bytes();assert len(b)<2000000;r['files'][str(p)]={'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
for tree in [B/'work_ia840f_fim_20/ofs-common/src/fpga_family/agilex/remote_stp/AFU_debug',B/'ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/remote_stp/AFU_debug']:
 r['listings'][str(tree)]=[str(p.relative_to(tree)) for p in tree.iterdir()]
 for p in tree.glob('*'):
  if p.is_file() and p.suffix in ('.ip','.qsys','.tcl'):export(p)
for rel in ['logs/mmhost_ia840f_report.log','board_spec.xml','ipinterfaces.xml']:
 export(B/'work_ahls_memory_01/build/mmhost_ia840f.report.prj'/rel)
root=Path('/opt/altera/25.1/ip/altera');r['listings'][str(root)]=[p.name for p in root.iterdir()]
for p in root.glob('*sld*'):
 if p.is_dir():
  for f in p.rglob('*'):
   if f.is_file() and f.suffix in ('.tcl','.sv','.v') and ('host_endpoint' in str(f) or 'soft_core_jtag_io' in str(f)):export(f)
env=dict(os.environ,QUARTUS_ROOTDIR_OVERRIDE=str(Q),PATH=f'{Q}/bin:{Q}/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin')
for name in ['qsys-generate','qsys-script']:
 p=subprocess.run([str(Q/'sopc_builder/bin'/name),'--help'],cwd=E,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=45)
 r['help'][name]={'rc':p.returncode,'text':p.stdout.decode(errors='replace')}
blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0);(E/'inputs01.json.gz').write_bytes(blob)
subprocess.run(['tmux','load-buffer','-b',batch,'-'],input=blob,check=True);print('SLD25_INPUTS01',hashlib.sha256(blob).hexdigest(),flush=True)
