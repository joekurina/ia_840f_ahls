from pathlib import Path
import sys,json,hashlib,shutil,subprocess,urllib.request
B=Path('/home/uwb_student00/ahls/new_BSP');R=B/'qualification/goal-initial-preflight';C=B/'ofs-agx7-pcie-attach'
sys.path.insert(0,str(C/'ofs-common/tools/ofss_config'))
import ia840f_experimental_gate as g
expected=json.loads((R/'authorization-expected-sources.json').read_text())
sources={t:g.inventory(C/t) for t in g.TREES};pim=g.inventory(g.PIM)
def without_git(d):return {k:v for k,v in d.items() if '.git' not in Path(k).parts}
assert all(without_git(sources[t])==without_git(expected['source'][t]) for t in g.TREES),'source parity mismatch'
assert without_git(pim)==without_git(expected['pim']),'PIM parity mismatch'
assert not g.WORK.exists() and not g.claim_path().exists()
assert not (C/g.RECORD_REL).exists()
tools={}
for name in g.TOOLS:
 p=shutil.which(name);assert p,name;tools[name]={'path':str(Path(p).resolve()),'sha256':g.sha(p)}
commands=[('quartus_sh',['--prepare','-r','ofs_top','ofs_top']),('quartus_sh',['--prepare','-r','ofs_pr_afu','ofs_top']),('quartus_ipgenerate',['-t',str(C/'ofs-common/scripts/common/syn/emit_project_ip.tcl'),'--project=ofs_top','--revision=ofs_top','--mode=ip_lib']),('quartus_sh',['-t',str(C/'ofs-common/scripts/common/syn/emit_project_macros.tcl'),'--project=ofs_top','--revision=ofs_top','--mode=txt','--output='+str(g.WORK/'src/top/ofs_agilex.macros')]),('quartus_ipgenerate',['-t',str(g.WORK/'ofs-common/scripts/common/syn/emit_project_ip.tcl'),'--project=ofs_top','--revision=ofs_top','--output=project_ip_for_generation.tcl']),('quartus_ipgenerate',['ofs_top','-c','ofs_top','--generate_project_ip_files','--synthesis=verilog','--simulation=verilog','--simulator=modelsim','--parallel=off']),('quartus_sh',['-t',str(g.WORK/'ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl'),'--project=ofs_top','--revision=ofs_top'])]
contexts=[{'executable':g.RUNTIME_EXES[name],'sha256':g.sha(g.RUNTIME_EXES[name]),'argv':[name]+args,'cwd':str(g.PROJECT),'kind':g.command_kind(name,args)} for name,args in commands]
r={'schema':1,'approved':True,'ready_for_build':False,'target':'ia840f','part':g.PART,'toolchain':g.VERSION,'source':str(C),'work':str(g.WORK),'pim':str(g.PIM),'permissions':['setup','generate','headers'],'source_sha256':sources,'pim_sha256':pim,'tools':tools,'quartus_contexts':contexts}
p=C/g.RECORD_REL
with p.open('x') as f:json.dump(r,f,indent=2)
assert json.loads(p.read_text())==r
g.load_record()
(R/'authorization-issued.json').write_text(json.dumps({'record':str(p),'sha256':g.sha(p),'source_file_counts':{t:len(v) for t,v in sources.items()},'pim_files':len(pim),'contexts':contexts,'qualification':False},indent=2))
print('AUTHORIZATION_ISSUED_AND_VERIFIED',g.sha(p))
