import base64, datetime, gzip, hashlib, json, os, shutil, socket, subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP'); E=B/'qualification/fim19-tool-preflight02'; Q=Path('/opt/altera/25.1/quartus')
assert os.environ.get('TMUX') and socket.gethostname()=='Agilex7Workstation'
E.mkdir(); os.chdir(E)
env=dict(os.environ,QUARTUS_ROOTDIR_OVERRIDE=str(Q),PATH=f'{Q}/bin:{Q}/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin',LM_LICENSE_FILE='/home/uwb_student00/quartus_25/LR-191011_License.dat',PYTHONDONTWRITEBYTECODE='1')
s='puts "INNER_VERSION=$quartus(version)"\nforeach t {quartus_sh quartus_ipgenerate ip-deploy qsys-script PACSign packager afu_json_mgr afu_synth_setup} {puts "INNER_TOOL=$t:[auto_execok $t]"}\n'
(E/'probe.tcl').write_text(s)
commands=[[str(Q/'bin/quartus_sh'),'--version'],[str(Q/'bin/quartus_sh'),'-t',str(E/'probe.tcl')]]
r={'batch':'ia840f_fim19_toolpreflight02','utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'commands':[],'files':{},'flow_hashes':{},'outer_tools':{}}
for cmd in commands:
 p=subprocess.run(cmd,env=env,cwd=E,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=45);r['commands'].append({'argv':cmd,'rc':p.returncode,'output':p.stdout.decode(errors='replace')})
for t in ['quartus_sh','quartus_ipgenerate','ip-deploy','qsys-script','PACSign','packager','afu_json_mgr','afu_synth_setup']:
 p=Path(shutil.which(t,path=env['PATH'])).resolve();r['outer_tools'][t]={'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
flow=Q/'common/tcl/internal/flow'
files=[p for p in flow.glob('*.tcl') if p.name in ('compile_flow.tcl','dni_compile_flow.tcl','ipgenerate_task.tcl','dni_ipgenerate_task.tcl','synthesis_task.tcl','dni_analysis_and_synthesis_task.tcl','fitter_plan_task.tcl','fitter_place_task.tcl','fitter_route_task.tcl','fitter_retime_task.tcl','fitter_finalize_task.tcl','sta_signoff_task.tcl','assembler_task.tcl')]
for p in flow.glob('*.tcl'):r['flow_hashes'][str(p)]=hashlib.sha256(p.read_bytes()).hexdigest()
for p in files+[B/'ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/build_top.sh',B/'ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/build_fim_compile.sh',B/'ofs-agx7-pcie-attach/syn/shared_config/post_module_hook.tcl']:
 b=p.read_bytes();r['files'][str(p)]={'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest(),'base64':base64.b64encode(b).decode()}
for name in ['libsys_flow.so','libda_flng.so']:
 p=Q/'linux64'/name;b=p.read_bytes();r['flow_hashes'][str(p)]=hashlib.sha256(b).hexdigest()
 r[name+'_ipc_strings']=[x.decode(errors='replace') for x in b.split(b'\0') if b'--ipc_' in x and len(x)<1000]
raw=gzip.compress(json.dumps(r,sort_keys=True).encode(),mtime=0);(E/'result.json.gz').write_bytes(raw)
subprocess.run(['tmux','load-buffer','-b',r['batch'],'-'],input=raw,check=True)
print('TOOL_PREFLIGHT02_COMPLETE',hashlib.sha256(raw).hexdigest(),flush=True)
