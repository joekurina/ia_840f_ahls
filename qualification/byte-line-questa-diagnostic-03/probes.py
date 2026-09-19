import os,json,hashlib,socket,subprocess,time,tempfile
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.environ.get('TMUX')
root=Path('/opt/altera/26.1.1/questa_fe')
qual=Path('/home/uwb_student00/ahls/new_BSP/qualification')
def pin(p):
 b=p.read_bytes();return {'size':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def inventory():
 return {str(p):pin(p) for n in ('byte-line-questa-run-01','byte-line-questa-run-02','byte-line-questa-package-01','byte-line-questa-package-02') for p in sorted((qual/n).rglob('*')) if p.is_file()}
before=inventory()
scratch=Path(tempfile.mkdtemp(prefix='byte-line-questa-diagnostic-03-',dir='/tmp'))
(scratch/'home').mkdir()
license='/home/uwb_student00/quartus_26/LR-191011_License.dat'
env={'PATH':str(root/'bin')+':/usr/bin:/bin','HOME':str(scratch/'home'),'TMPDIR':str(scratch),'LANG':'C','LC_ALL':'C','TMUX':os.environ['TMUX'],'LM_LICENSE_FILE':license,'MGLS_LICENSE_FILE':license,'SALT_LICENSE_SERVER':license,'QUARTUS_ROOTDIR_OVERRIDE':'/opt/altera/26.1.1/quartus'}
configs={'minimal':'[Library]\nwork = work\n', 'empty-vsim':'[Library]\nwork = work\n\n[vsim]\n', 'vopt-on':'[Library]\nwork = work\n\n[vsim]\nVoptFlow = 1\n', 'vopt-off':'[Library]\nwork = work\n\n[vsim]\nVoptFlow = 0\n'}
r={'scratch':str(scratch),'hostname':socket.gethostname(),'tmux':os.environ['TMUX'],'probes':[],'protected_before':before,'tools_before':{str(p):pin(p) for p in (root/'vco',root/'modelsim.ini',root/'questa.ini',root/'linux_x86_64/vlog',root/'linux_x86_64/vsim')}}
for name in ['minimal','empty-vsim','vopt-on','vopt-off','installed-ini','no-explicit-ini']:
 cwd=scratch/name;cwd.mkdir()
 e=env.copy()
 if name in configs:
  p=cwd/'modelsim.ini';p.write_text(configs[name]);e['MODELSIM']=str(p)
 elif name=='installed-ini':e['MODELSIM']=str(root/'modelsim.ini')
 for tool in (['vlog','vsim'] if name=='vopt-on' else ['vlog']):
  cmd=[str(root/'bin'/tool),'-version'];t=time.monotonic()
  q=subprocess.run(cmd,cwd=cwd,env=e,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=15)
  log=cwd/(tool+'-version.log');log.write_bytes(q.stdout)
  entry={'case':name,'argv':cmd,'cwd':str(cwd),'env':e,'rc':q.returncode,'elapsed_seconds':time.monotonic()-t,'output':q.stdout.decode(errors='replace'),'output_pin':pin(log),'ini':{'content':configs[name],**pin(cwd/'modelsim.ini')} if name in configs else None}
  (cwd/(tool+'-invocation.json')).write_text(json.dumps(entry,indent=2));r['probes'].append(entry)
after=inventory();r['protected_unchanged']=before==after
r['tools_unchanged']=r['tools_before']=={p:pin(Path(p)) for p in r['tools_before']}
r['scratch_inventory']={str(p.relative_to(scratch)):pin(p) for p in scratch.rglob('*') if p.is_file()}
(scratch/'evidence.json').write_text(json.dumps(r,indent=2))
assert json.loads((scratch/'evidence.json').read_text())==r
print(json.dumps(r))
