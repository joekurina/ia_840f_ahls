import os,sys,pathlib,subprocess,json,importlib.metadata as m,hashlib,shutil
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01');R.mkdir(exist_ok=False)
assert os.getuid()==1000 and os.uname().nodename=='Agilex7Workstation'
print('identity',os.uname().nodename,os.getuid(),sys.executable,sys.version)
p=pathlib.Path(shutil.which('bw_pip'));print('bw_pip',p,p.resolve());print(p.read_text());(R/'bw_pip-source.txt').write_text(p.read_text())
for args,name in [([sys.executable,'-m','pip','check'],'pip-check-before'),([sys.executable,'-m','pip','freeze','--all'],'pip-freeze-before')]:
 x=subprocess.run(args,text=True,capture_output=True);(R/(name+'.txt')).write_text(x.stdout+x.stderr+'\nRC='+str(x.returncode)); print(name,x.returncode,x.stdout)
dists=[]
for d in m.distributions():
 row=dict(name=d.metadata['Name'],version=d.version,location=str(d._path),requires=d.requires or [],files=[str(d.locate_file(f).absolute()) for f in (d.files or [])],entry_points=[str(e) for e in d.entry_points]);dists.append(row)
(R/'distributions-before.json').write_text(json.dumps(dists,indent=2))
for d in dists:
 if d['name'].lower().startswith('bw') or d['name']=='grpcio-tools': print(json.dumps({k:v for k,v in d.items() if k!='files'}))
hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in pathlib.Path('/usr/share/bittware-sdk').rglob('*') if p.is_file()};(R/'sdk-hashes-before.json').write_text(json.dumps(hashes,indent=2));print('SDK files',len(hashes));print('DONE')
