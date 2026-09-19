from pathlib import Path
import json,os,subprocess,sys,hashlib,shutil,time,importlib.util
P=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02');Q=P.parent/'ddr-library-import-01'
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(8*1024*1024),b''):h.update(b)
 return h.hexdigest()
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
review=json.loads((Q/'accepted-review.json').read_text());assert review['runner_sha256']==sha(__file__) and review['ready_for_build'] is False and review['review_accepted'] is True
for p,h in review['bound_files'].items():assert sha(p)==h,p
m=json.loads((P/'manifest.json').read_text());old=json.loads((P/'run-02/result.json').read_text());r3=json.loads((P/'run-03/result.json').read_text());imports=json.loads((Q/'import-manifest.json').read_text())['imports']
spec=importlib.util.spec_from_file_location('smoke',P/'run_smoke.py');s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
assert not s.check_inputs(m)
for n,h in old['package_hashes'].items():assert sha(P/n)==h
for n,h in old['tool_hashes'].items():assert sha(s.TOOLS/n)==h
for x in imports:assert sha(x['source'])==sha(x['copy'])==x['sha256']
expected=[['vlog','-sv','-work','work',m['dpi_source']]]+m['commands']+[['vlog','-sv','-work','work',str(P/'tb_mem_ss_smoke.sv')]]
compiled=[x for x in old['steps'] if x['log'].startswith('compile-')];assert len(compiled)==len(expected)==144
for step,cmd in zip(compiled,expected):
 assert step['rc']==0 and step['argv']==[str(s.TOOLS/cmd[0])]+cmd[1:]
 assert not s.ERROR.search((P/'run-02'/step['log']).read_text())
assert (P/'run-03/modelsim.ini').read_text()==(P/'run-02/modelsim.ini').read_text()==s.ini_text(m)
before=inventory(P/'run-03/libraries');assert before==r3['reuse']['library_sha256']
O=Q/'run-04';O.mkdir(exist_ok=False)
result={'pass':False,'ready_for_build':False,'hardware_qualified':False,'started':time.time(),'change':'23.1 whole tennm_ver simulation source trio compiled with current 26.1.1 Questa; no other device library mapping changed','reused_compile_commands':144,'steps':[],'before_inputs_match':True,'imports':imports,'reuse':{'source':str(P/'run-03'),'library_sha256':before,'source_result_sha256':sha(P/'run-03/result.json'),'package_hashes':old['package_hashes'],'tool_hashes':old['tool_hashes']}}
rc=1
try:
 shutil.copytree(P/'run-03/libraries',O/'libraries');assert inventory(O/'libraries')==before
 ini=s.ini_text(m);oldline='tennm_ver = '+m['device_libraries']['tennm_ver'];assert ini.count(oldline)==1
 (O/'modelsim.ini').write_text(ini.replace(oldline,'tennm_ver = libraries/tennm_ver'));shutil.copyfile(P/'run-03/run.do',O/'run.do')
 for f in m['hex_files']:
  dst=O/Path(f['path']).name;shutil.copyfile(f['path'],dst);assert sha(dst)==f['sha256']
 env=os.environ.copy();env.update({'MODELSIM':str(O/'modelsim.ini'),'SALT_LICENSE_SERVER':s.LICENSE,'LM_LICENSE_FILE':s.LICENSE,'MGLS_LICENSE_FILE':s.LICENSE,'PATH':str(s.TOOLS)+':'+os.environ.get('PATH','')})
 def step(argv,name,limit):
  global rc
  result['steps'].append({'argv':argv,'timeout_s':limit,'log':name+'.log','started':time.time()});rc=s.run_child(argv,O,env,O/(name+'.log'),limit);result['steps'][-1].update(rc=rc,finished=time.time())
  if rc or s.ERROR.search((O/(name+'.log')).read_text(errors='replace')):raise RuntimeError('failed '+name+' rc='+str(rc))
 step([str(s.TOOLS/'vlog'),'-version'],'vlog-version',15)
 step([str(s.TOOLS/'vlib'),'libraries/tennm_ver'],'vlib-import',15)
 deadline=time.monotonic()+600
 for i,x in enumerate(imports):
  remaining=deadline-time.monotonic();assert remaining>0,'compile budget exhausted'
  step([str(s.TOOLS/'vlog'),'-sv',x['copy'],'-work','tennm_ver'],'compile-import-%02d'%i,min(120,remaining))
 result['candidate_compile_pass']=True
 argv=r3['steps'][-1]['argv'][:];step(argv,'elaborate-run',120)
 text=(O/'elaborate-run.log').read_text(errors='replace');result['pass']=s.accepted(rc,text)
except Exception as e:result['error']=str(e)
finally:
 result['native_rc']=rc;result['source_libraries_unchanged']=inventory(P/'run-03/libraries')==before
 result['after_input_mismatches']=s.check_inputs(m);result['donor_and_import_hashes_unchanged']=all(sha(x['source'])==sha(x['copy'])==x['sha256'] for x in imports)
 if not result['source_libraries_unchanged'] or result['after_input_mismatches'] or not result['donor_and_import_hashes_unchanged']:result['pass']=False
 if (O/'elaborate-run.log').exists():
  text=(O/'elaborate-run.log').read_text(errors='replace');result['channel_completion_markers']=text.count('DDR_SMOKE_CHANNEL_DONE');result['pass_markers']=text.count(s.PASS)
 result['finished']=time.time();(O/'result.json').write_text(json.dumps(result,indent=2)+'\n')
 (O/'output-hashes.json').write_text(json.dumps({f.name:sha(f) for f in O.iterdir() if f.is_file()},indent=2))
 print(json.dumps({k:v for k,v in result.items() if k not in ['reuse','steps','imports']},indent=2),flush=True)
sys.exit(0 if result['pass'] else 1)
