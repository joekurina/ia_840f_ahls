from pathlib import Path
import base64,zlib,hashlib,sys
B=Path('/home/uwb_student00/ahls/new_BSP');S=B/'ofs-agx7-pcie-attach';E=B/'qualification/msa-bank-spreading-integration-01';G=E/'generation-candidate';W=B/'work_ia840f_msa_generation_01'
raw=subprocess.check_output(['tmux','save-buffer','-b','msa-generation-package-6e3462348c44458c83dfd3ca421ab273','-']);assert hashlib.sha256(raw).hexdigest()=='6c8dfd27d19a8d2e5e66a9b8b6c889271f7281dc1517a5f1be6225d81d4f930f'
files=json.loads(zlib.decompress(raw));assert not G.exists() and not W.exists()
for rel,e in files.items():
 data=base64.b64decode(e['data']);assert hashlib.sha256(data).hexdigest()==e['sha256'];assert not Path(rel).is_absolute() and '..' not in Path(rel).parts
G.mkdir()
for rel,e in files.items():
 p=G/rel;p.parent.mkdir(parents=True,exist_ok=True)
 with p.open('xb') as out:out.write(base64.b64decode(e['data']))
for rel,e in files.items():assert hashlib.sha256((G/rel).read_bytes()).hexdigest()==e['sha256']
env=dict(os.environ);env.pop('PYTHONOPTIMIZE',None);env['PYTHONDONTWRITEBYTECODE']='1'
results=[]
for label,args,expected in [('pure-python-tests',['test_candidate.py'],0),('live-dependency-verification',['-c','import run_generation as r; b=r.check_source_and_dependencies(); print("LIVE_BINDINGS_VERIFIED",len(b["dependencies"]))'],0),('missing-review-rejection',['run_generation.py','--preflight'],1)]:
 argv=[sys.executable,'-B']+args
 run=subprocess.run(argv,cwd=G,env=env,capture_output=True,text=True)
 text=run.stdout+run.stderr
 with (E/(label+'.log')).open('x') as f:f.write(text)
 results.append({'label':label,'argv':argv,'cwd':str(G),'returncode':run.returncode,'log_sha256':hashlib.sha256(text.encode()).hexdigest(),'tail':text[-1200:]})
 assert run.returncode==expected,(label,run.returncode,text)
assert not W.exists() and not (G/'run').exists() and not (G/'consumed-review.json').exists()
for rel,e in files.items():assert hashlib.sha256((G/rel).read_bytes()).hexdigest()==e['sha256']
result={'package_files':len(files),'package_manifest_sha256':hashlib.sha256((G/'package-manifest.json').read_bytes()).hexdigest(),'verified':True,'work_absent':not W.exists(),'run_absent':not (G/'run').exists(),'review_absent':True,'tests':results,'vendor_launched':False,'execution_ready':False}
with (E/'generation-package-receipt.json').open('x') as f:json.dump(result,f,indent=2)
