from pathlib import Path
import json,re,hashlib,os
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_12';E=B/'qualification/fim-build-12';M=W/'ipss/mem/qip/mem_ss'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
root=M/'mem_ss/mem_ss.qip';visited=set();edges=[]
pattern=re.compile(r'-name (\w+) \[file join \$::quartus\(qip_path\) "([^"\n]+)"\]')
def walk(qip):
 qip=qip.resolve(strict=True)
 if qip in visited:return
 visited.add(qip)
 for n,line in enumerate(qip.read_text().splitlines(),1):
  if not re.search(r'-name (?:QIP_FILE|SYSTEMVERILOG_FILE|VERILOG_FILE|SDC_FILE|HEX_FILE|MIF_FILE|SOURCE_TCL_SCRIPT_FILE|OCS_IP_FILE|SOPCINFO_FILE|MISC_FILE) ',line):continue
  m=pattern.search(line);assert m,('unrecognized dependency',qip,n,line)
  kind,value=m.groups();p=(qip.parent/value).resolve(strict=True);assert p.is_file() and p.is_relative_to(W),(qip,value)
  edges.append(dict(from_qip=str(qip.relative_to(W)),line=n,kind=kind,path=str(p.relative_to(W)),sha256=sha(p)))
  if kind=='QIP_FILE':walk(p)
walk(root)
assert visited==set(p.resolve() for p in M.rglob('*.qip'))
# Project selects the saved IP; Quartus derives the sibling generated QIP.
project_refs=[]
for p in [W/'syn/board/ia840f/syn_top/project_ip_for_generation.tcl',W/'ipss/mem/mem_ss.tcl',W/'syn/board/ia840f/syn_top/ofs_top_sources.tcl']:
 if p.exists():
  project_refs.extend(dict(path=str(p.relative_to(W)),line=n,text=l,sha256=sha(p)) for n,l in enumerate(p.read_text().splitlines(),1) if 'mem_ss' in l or 'emif_loc.tcl' in l)
result=dict(qips=len(visited),edges=edges,project_refs=project_refs,scope='Static complete generated memory QIP graph, not native project loading; no Tcl or vendor execution',ready_for_build=False)
with (E/'memory-closure.json').open('x') as f:json.dump(result,f,indent=2)
print(json.dumps(dict(qips=len(visited),edges=len(edges),kinds=sorted(set(e['kind'] for e in edges)),project_refs=project_refs)))
