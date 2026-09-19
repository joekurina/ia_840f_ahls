from pathlib import Path
import os,sys,json,subprocess,time,hashlib
b=Path('/home/uwb_student00/ahls/new_BSP');c=b/'ofs-agx7-pcie-attach';w=b/'work_ia840f_ipgen_04';r=b/'qualification/ipgen-04';project=w/'syn/board/ia840f/syn_top'
assert json.loads((r/'setup-result.json').read_text())['returncode']==0
s=(r/'setup-full.log').read_text()
assert not any(x in s for x in ['IA840F_GATE_REJECTED','IA840F NOT READY','IA840F EXPERIMENTAL GATE:','Critical Warning (125091)'])
env=os.environ.copy();env.update({'OFS_ROOTDIR':str(w),'OFS_PLATFORM_AFU_BBB':str(b/'ofs-platform-afu-bbb'),'PYTHONDONTWRITEBYTECODE':'1'})
gate=c/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'
stages=[('project-ip','quartus_ipgenerate',['-t',str(w/'ofs-common/scripts/common/syn/emit_project_ip.tcl'),'--project=ofs_top','--revision=ofs_top','--output=project_ip_for_generation.tcl']),('generate','quartus_ipgenerate',['ofs_top','-c','ofs_top','--generate_project_ip_files','--synthesis=verilog','--simulation=verilog','--simulator=modelsim','--parallel=off']),('headers','quartus_sh',['-t',str(w/'ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl'),'--project=ofs_top','--revision=ofs_top'])]
for name,tool,args in stages:
 cmd=['python3','-B',str(gate),'run-post-setup-quartus',tool]+args
 receipt={'argv':cmd,'cwd':str(project),'started_unix':time.time(),'environment':{k:env.get(k) for k in ['OFS_ROOTDIR','OFS_PLATFORM_AFU_BBB','QUARTUS_ROOTDIR_OVERRIDE','PATH','LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER']}}
 for suffix in ('invocation.json','full.log','result.json'):
  assert not (r/(name+'-'+suffix)).exists(), 'Stage already used'
 with (r/(name+'-stage.claim')).open('x') as f:f.write('reserved\n')
 with (r/(name+'-invocation.json')).open('x') as f:json.dump(receipt,f,indent=2)
 print(name.upper()+'_STARTED',flush=True)
 with (r/(name+'-full.log')).open('xb') as f:p=subprocess.run(cmd,cwd=project,env=env,stdout=f,stderr=subprocess.STDOUT)
 receipt.update({'returncode':p.returncode,'finished_unix':time.time()})
 with (r/(name+'-result.json')).open('x') as f:json.dump(receipt,f,indent=2)
 print(name.upper()+'_EXIT',p.returncode,flush=True)
 if p.returncode:sys.exit(p.returncode)
 if name=='project-ip':
  src=project/'project_ip_for_generation.tcl';text=src.read_text();paths=[line.split(maxsplit=3)[3] for line in text.splitlines() if line.startswith('set_global_assignment -name ')]
  missing=[p for p in paths if not (project/p).is_file()];assert paths and not missing,missing
  (r/'enumerated-ip-files.json').write_text(json.dumps({'files':[{'path':p,'sha256':hashlib.sha256((project/p).read_bytes()).hexdigest()} for p in paths]},indent=2))
print('POST_SETUP_SEQUENCE_COMPLETE_NOT_QUALIFIED',flush=True)
