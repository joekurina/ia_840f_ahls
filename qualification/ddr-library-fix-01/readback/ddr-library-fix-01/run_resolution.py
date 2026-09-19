from pathlib import Path
import json,os,subprocess,sys,hashlib,shutil,time,importlib.util
P=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02');Q=P.parent/'ddr-library-fix-01'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def inventory(p):return {str(f.relative_to(p)):sha(f) for f in p.rglob('*') if f.is_file()}
assert subprocess.check_output(['tmux','display-message','-p','#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
review=json.loads((Q/'accepted-review.json').read_text());assert review['runner_sha256']==sha(__file__) and review['ready_for_build'] is False
m=json.loads((P/'manifest.json').read_text());old=json.loads((P/'run-02/result.json').read_text())
spec=importlib.util.spec_from_file_location('smoke',P/'run_smoke.py');s=importlib.util.module_from_spec(spec);spec.loader.exec_module(s)
assert not s.check_inputs(m)
for n,h in old['package_hashes'].items():assert sha(P/n)==h
for n,h in old['tool_hashes'].items():assert sha(s.TOOLS/n)==h
expected=[['vlog','-sv','-work','work',m['dpi_source']]]+m['commands']+[['vlog','-sv','-work','work',str(P/'tb_mem_ss_smoke.sv')]]
compiled=[x for x in old['steps'] if x['log'].startswith('compile-')]
assert len(compiled)==len(expected)==144
for step,cmd in zip(compiled,expected):
 assert step['rc']==0 and step['argv']==[str(s.TOOLS/cmd[0])]+cmd[1:]
 assert not s.ERROR.search((P/'run-02'/step['log']).read_text())
assert (P/'run-02/modelsim.ini').read_text()==s.ini_text(m)
O=P/'run-03';O.mkdir(exist_ok=False)
result={'pass':False,'ready_for_build':False,'started':time.time(),'diagnostic_only_change':'documented -libverbose resolution logging','reused_compile_commands':144,'steps':[]}
try:
 before=inventory(P/'run-02/libraries');shutil.copytree(P/'run-02/libraries',O/'libraries');assert inventory(O/'libraries')==before
 result['reuse']={'source':str(P/'run-02'),'source_result_sha256':sha(P/'run-02/result.json'),'copied_library_files':len(before),'library_sha256':before,'inputs_match':True,'package_hashes':old['package_hashes'],'tool_hashes':old['tool_hashes'],'compile_argv_match':True,'ini_match':True}
 for n in ['modelsim.ini','run.do']:shutil.copyfile(P/'run-02'/n,O/n)
 for f in m['hex_files']:
  dst=O/Path(f['path']).name;shutil.copyfile(f['path'],dst);assert sha(dst)==f['sha256']
 env=os.environ.copy();env.update({'MODELSIM':str(O/'modelsim.ini'),'SALT_LICENSE_SERVER':s.LICENSE,'LM_LICENSE_FILE':s.LICENSE,'MGLS_LICENSE_FILE':s.LICENSE,'PATH':str(s.TOOLS)+':'+os.environ.get('PATH','')})
 argv=old['steps'][-1]['argv'][:];assert old['steps'][-1]['log']=='elaborate-run.log';argv[1:1]=['-libverbose','-voptargs=-libverbose']
 result['steps'].append({'argv':argv,'timeout_s':120,'log':'elaborate-run.log'});rc=s.run_child(argv,O,env,O/'elaborate-run.log',120);result['steps'][-1]['rc']=rc
 text=(O/'elaborate-run.log').read_text(errors='replace');result.update(pass_=s.accepted(rc,text),native_rc=rc)
 result['pass']=result.pop('pass_');result['channel_completion_markers']=text.count('DDR_SMOKE_CHANNEL_DONE');result['pass_markers']=text.count(s.PASS)
 result['source_libraries_unchanged']=inventory(P/'run-02/libraries')==before
 result['after_input_mismatches']=s.check_inputs(m)
 if not result['source_libraries_unchanged'] or result['after_input_mismatches']:result['pass']=False
except Exception as e:result['error']=str(e)
finally:
 result['finished']=time.time();(O/'result.json').write_text(json.dumps(result,indent=2)+'\n')
 (O/'output-hashes.json').write_text(json.dumps({f.name:sha(f) for f in O.iterdir() if f.is_file()},indent=2))
 print(json.dumps({k:v for k,v in result.items() if k not in ['reuse','steps']},indent=2));print('LAST_STEP',result['steps'])
sys.exit(0 if result['pass'] else 1)
