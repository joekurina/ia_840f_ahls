import base64,datetime,gzip,hashlib,json,os,shutil,socket,subprocess,sys,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/sld25-regeneration01';W=B/'work_sld25_regeneration01';Q=Path('/opt/altera/25.1/quartus');batch='ia840f_sld25_generate01'
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX') and not sys.flags.optimize
assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
assert not W.exists();W.mkdir()
source=B/'work_ia840f_fim_20/ofs-common/src/fpga_family/agilex/remote_stp/AFU_debug/scjio_agilex.ip'
input_record=json.loads(gzip.decompress((E/'inputs01.json.gz').read_bytes()));expected=input_record['files'][str(source)]['sha256'];data=source.read_bytes();assert hashlib.sha256(data).hexdigest()==expected
p=W/'scjio_agilex.ip';p.write_bytes(data)
cmd=[str(Q/'sopc_builder/bin/qsys-generate'),str(p),'--synthesis=VERILOG','--part=AGFB027R25A2E2V','--parallel=off']
env=dict(os.environ,QUARTUS_ROOTDIR_OVERRIDE=str(Q),PATH=f'{Q}/bin:{Q}/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',LM_LICENSE_FILE='/home/uwb_student00/quartus_25/LR-191011_License.dat')
r={'batch':batch,'started':datetime.datetime.now(datetime.timezone.utc).isoformat(),'argv':cmd,'cwd':str(W),'input_sha256':expected,'tool_sha256':hashlib.sha256(Path(cmd[0]).read_bytes()).hexdigest(),'source_modified':False,'files':{}}
try:
 with (E/'generate01.log').open('xb') as log:
  pr=subprocess.run(cmd,cwd=W,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=180)
 r['native_rc']=pr.returncode
except BaseException as exc:r.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 r['ended']=datetime.datetime.now(datetime.timezone.utc).isoformat();r['original_ip_unchanged']=hashlib.sha256(source.read_bytes()).hexdigest()==expected;r['copied_saved_ip_unchanged']=hashlib.sha256(p.read_bytes()).hexdigest()==expected
 for f in sorted(W.rglob('*')):
  if f.is_file():
   b=f.read_bytes();assert len(b)<2000000;r['files'][str(f.relative_to(W))]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
 b=(E/'generate01.log').read_bytes();r['log']=b.decode(errors='replace');r['log_sha256']=hashlib.sha256(b).hexdigest()
 blob=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0);(E/'generation01.json.gz').write_bytes(blob)
 subprocess.run(['tmux','load-buffer','-b',batch,'-'],input=blob,check=True);print('SLD25_GENERATION01',r.get('native_rc'),hashlib.sha256(blob).hexdigest(),flush=True)
sys.exit(0 if r.get('native_rc')==0 and r['original_ip_unchanged'] and r['copied_saved_ip_unchanged'] else 1)
