from pathlib import Path
import base64,zlib,hashlib,sys,importlib.util,datetime,xml.etree.ElementTree as ET
B=Path('/home/uwb_student00/ahls/new_BSP');S=B/'ofs-agx7-pcie-attach';E=B/'qualification/msa-bank-spreading-integration-01'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
raw=subprocess.check_output(['tmux','save-buffer','-b','msa-integration-payload-91da560848354202b13ee2de7e0694b3','-'])
assert hashlib.sha256(raw).hexdigest()=='e5bfa59e60315e0f88e507464bd2e914b36a134d2a30a1762452f7f96644c25d'
p=json.loads(zlib.decompress(raw))
sys.path.insert(0,str(S/'ofs-common/tools/ofss_config'));import ia840f_experimental_gate as g
record=B/'qualification/fim-build-11/compile-authorization.json';a=json.loads(record.read_text())
before={t:g.inventory(S/t) for t in g.TREES}
assert before==a['source_sha256'] and g.inventory(g.PIM)==a['pim_sha256']
for e in p['baseline_checked'].values():assert sha(Path(e['source']))==e['sha256'],e['source']
assert not E.exists() and not (B/'reference/quartus-26.1.1-pcie').exists()
E.mkdir()
def put(path,data):
 path.parent.mkdir(parents=True,exist_ok=True)
 with path.open('xb') as f:f.write(data)
 assert path.read_bytes()==data
put(E/'source-before.json',json.dumps(before,indent=2).encode())
put(E/'source_manifest.before.json',(S/'syn/board/ia840f/source_manifest.json').read_bytes())
for n,data in p['reviews'].items():put(E/'reviews'/n,base64.b64decode(data))
# Immutable existing reviewed dependency fixture, no fetching or pin relaxation.
deps={}
for rel,data in p['reference'].items():
 data=base64.b64decode(data);target=B/'reference'/rel
 put(target,data);deps[str(target)]=sha(target)
# Run reviewed derivation in memory against actual SOURCE/donor/reference layout.
module=type(sys)('reviewed_derivation');exec(compile(base64.b64decode(p['source']['ipss/ia840f/derive_presets.py']),'<reviewed-derive>','exec'),module.__dict__)
outputs=module.derive(S,Path('/home/uwb_student00/IA-840f/IOFS_BUILD_ROOT/ofs-ia840f'))
for rel,data in outputs.items():
 key='ipss/ia840f/'+rel
 expected=base64.b64decode(p['source'][key]) if key in p['source'] else (S/key).read_bytes()
 assert data==expected,'derivation mismatch '+key
old=ET.fromstring((S/'ipss/ia840f/presets/ia840f_mem.qprs').read_bytes());new=ET.fromstring(outputs['presets/ia840f_mem.qprs'])
def params(root):
 nodes=root.findall('.//parameter');d={n.attrib['name']:n.attrib['value'] for n in nodes};assert len(d)==len(nodes)==2930;return d
old,new=params(old),params(new);assert old.keys()==new.keys()
delta={k:[old[k],new[k]] for k in old if old[k]!=new[k]}
assert delta=={'mem_ss|msa_0|NUM_BANK_FIFOS':['8','0'],'mem_ss|msa_1|NUM_BANK_FIFOS':['8','0']}
assert new['mem_ss|msa_0|NUM_COPIES']==new['mem_ss|msa_1|NUM_COPIES']=='1'
assert before=={t:g.inventory(S/t) for t in g.TREES}
changes=[]
for rel,data in p['source'].items():
 target=S/rel;data=base64.b64decode(data);put(E/'source-before'/rel,target.read_bytes())
 changes.append({'path':rel,'before':sha(target),'after':hashlib.sha256(data).hexdigest()})
for rel,data in p['source'].items():(S/rel).write_bytes(base64.b64decode(data))
after={t:g.inventory(S/t) for t in g.TREES}
changed=[t+'/'+rel for t in before for rel in set(before[t])|set(after[t]) if before[t].get(rel)!=after[t].get(rel)]
assert sorted(changed)==sorted(p['source'])
for e in changes:assert sha(S/e['path'])==e['after']
argv=[sys.executable,'-B',str(S/'ipss/ia840f/derive_presets.py'),'--vendor-root','/home/uwb_student00/IA-840f/IOFS_BUILD_ROOT/ofs-ia840f']
env=dict(os.environ);env.pop('PYTHONOPTIMIZE',None);env['PYTHONDONTWRITEBYTECODE']='1'
run=subprocess.run(argv,cwd=S,env=env,capture_output=True,text=True)
put(E/'production-compare.log',(run.stdout+run.stderr).encode());assert run.returncode==0
receipt={'integrated':True,'time':datetime.datetime.now(datetime.timezone.utc).isoformat(),'hostname':socket.gethostname(),'uid':os.getuid(),'source':str(S),'changed_files':changes,'parameter_count':len(new),'parameter_delta':delta,'dependencies':deps,'compare':{'argv':argv,'cwd':str(S),'returncode':run.returncode,'python_optimize':sys.flags.optimize},'source_manifest_policy':'Preserved historical manifest unchanged; four pre-existing differences verified against issued Work11. This receipt plus source-after.json supersedes exactly the three correction identities for future review; no old authorization reusable.','preexisting_manifest_differences':p['prior_manifest_conflicts'],'execution_ready':False,'timing_ready':False,'constraint_ready':False,'functional_ready':False,'vendor_launched':False}
put(E/'source-after.json',json.dumps(after,indent=2).encode());put(E/'integration-receipt.json',json.dumps(receipt,indent=2).encode())
result={'receipt':receipt,'receipt_sha256':sha(E/'integration-receipt.json'),'remote_evidence':str(E)}
