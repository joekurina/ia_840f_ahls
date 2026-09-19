import pathlib,json,hashlib,tarfile,subprocess,os,sys
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01');A=json.loads((R/'repair-analysis.json').read_text());M=json.loads((R/'rollback-manifest.json').read_text());H=pathlib.Path.home()
with tarfile.open(R/'rollback-user-packages.tar.gz') as t:
 for n in t.getmembers():
  assert hashlib.sha256(t.extractfile(n).read()).hexdigest()==M[str(H/n.name)]['sha256']
 assert len(t.getmembers())==len(M)
D=json.loads((R/'distributions-before.json').read_text());affected=set(M);unrelated={}
for d in D:
 if d['name'] not in A['remove']+A['current']:
  for f in d['files']:
   p=pathlib.Path(os.path.abspath(f))
   if str(p) not in affected and p.is_file(): unrelated[str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
(R/'unrelated-hashes-before.json').write_text(json.dumps(unrelated,indent=2))
print('Rollback verified',len(M),'unrelated files',len(unrelated),flush=True)
env=dict(os.environ,PIP_NO_INDEX='1',PIP_DISABLE_PIP_VERSION_CHECK='1',PIP_NO_CACHE_DIR='1',PYTHONDONTWRITEBYTECODE='1')
def run(args,name):
 print('RUN',args,flush=True);x=subprocess.run(args,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,env=env,timeout=180);(R/(name+'.txt')).write_text(x.stdout+'\nRC='+str(x.returncode));print(x.stdout,flush=True);assert x.returncode==0
run([sys.executable,'-m','pip','uninstall','-y',*A['remove']],'uninstall')
env['PIP_USER']='1'
run(['/usr/share/bittware-sdk/bin/bw_pip','--python-exec',sys.executable,'install','--bittware-only'],'vendor-reinstall')
run([sys.executable,'-m','pip','check'],'pip-check-after')
print('DONE',flush=True)
