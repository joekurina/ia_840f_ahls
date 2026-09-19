import pathlib,json,hashlib,zipfile,subprocess,sys,os,importlib.metadata as m
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01');S=pathlib.Path('/usr/share/bittware-sdk');site=pathlib.Path.home()/'.local/lib/python3.9/site-packages';A=json.loads((R/'repair-analysis.json').read_text());result={}
for name in ['sdk','unrelated']:
 before=json.loads((R/(name+'-hashes-before.json')).read_text());after={f:hashlib.sha256(pathlib.Path(f).read_bytes()).hexdigest() if pathlib.Path(f).is_file() else None for f in before};(R/(name+'-hashes-after.json')).write_text(json.dumps(after,indent=2));assert before==after;result[name+'_files_unchanged']=len(before)
wheel_checks=[];csp=[]
for w in sorted((S/'python').glob('bw*.whl')):
 with zipfile.ZipFile(w) as z:
  checked=0
  for n in z.namelist():
   if n.endswith('/') or '.dist-info/' in n or '.data/' in n or not n.startswith('bw_'):continue
   p=site/n;assert p.is_file(),str(p);a=hashlib.sha256(z.read(n)).hexdigest();b=hashlib.sha256(p.read_bytes()).hexdigest();assert a==b,str(p);checked+=1
   if '/data/IA-840F/' in n or n=='bw_agilex/products/ia840f_product.py':csp.append(dict(path=str(p),wheel=str(w),member=n,sha256=b))
  wheel_checks.append(dict(wheel=str(w),files_verified=checked,sha256=hashlib.sha256(w.read_bytes()).hexdigest()))
(R/'wheel-file-verification.json').write_text(json.dumps(wheel_checks,indent=2));(R/'csp-resources.json').write_text(json.dumps(csp,indent=2));result['wheels_verified']=len(wheel_checks);result['csp_files_verified']=len(csp)
D=[dict(name=d.metadata['Name'],version=d.version,location=str(d._path),entry_points=[dict(name=e.name,group=e.group,value=e.value) for e in d.entry_points]) for d in m.distributions()];(R/'distributions-after.json').write_text(json.dumps(D,indent=2));assert not set(A['remove'])&{d['name'] for d in D}
for d in D:
 if d['name'] in A['current']:
  for ep in d['entry_points']:
   if ep['group']=='console_scripts':
    p=pathlib.Path.home()/'.local/bin'/ep['name'];assert p.is_file();assert ep['value'].split(':')[0] in p.read_text(),str(p)
print('INTEGRITY',result)
env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1',PIP_NO_INDEX='1',PIP_DISABLE_PIP_VERSION_CHECK='1')
for name,cmd in [('bw-pip-list',[str(S/'bin/bw_pip'),'--python-exec',sys.executable,'list']),('pip-check-final',[sys.executable,'-m','pip','check']),('pip-freeze-after',[sys.executable,'-m','pip','freeze','--all'])]:
 x=subprocess.run(cmd,capture_output=True,text=True,env=env,timeout=60);(R/(name+'.txt')).write_text(x.stdout+x.stderr+'\nRC='+str(x.returncode));assert x.returncode==0
print('CSP');print(json.dumps(csp,indent=2));(R/'integrity-result.json').write_text(json.dumps(result,indent=2));print('DONE')
