from pathlib import Path
import os,sys,json,hashlib,base64,collections
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12';C=B/'ofs-agx7-pcie-attach';OLD=B/'work_ia840f_ipgen_04';G=B/'work_ia840f_msa_generation_01'
sys.dont_write_bytecode=True;sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'));import ia840f_header_gate as gate
sha=gate.sha
for name,data in FINAL_ARTIFACTS.items():
 with (E/name).open('xb') as f:f.write(base64.b64decode(data))
# Reverify all preserved live inputs and historical evidence.
pre=json.loads((E/'preflight.json').read_text());staged=json.loads((E/'staging-receipt.json').read_text())
assert {t:gate.common.inventory(C/t) for t in gate.common.TREES}==pre['source']
assert gate.common.inventory(gate.common.PIM)==pre['pim']
for p,h in pre['dependencies'].items():assert sha(p)==h,p
for p,h in staged['work11_preserved'].items():assert sha(p)==h,p
def inv(root):
 return {str(p.relative_to(root)):({'symlink':os.readlink(p)} if p.is_symlink() else {'sha256':sha(p)}) for p in sorted(root.rglob('*')) if p.is_symlink() or p.is_file()}
old=json.loads((E/'work04-before.json').read_text());assert inv(OLD)==old and inv(G)==pre['memory']
now=gate.work_inventory();reloc={r['path']:r for r in json.loads((E/'relocations.json').read_text())};overlay=json.loads((E/'overlay-sha256.json').read_text())
archived=['ipss/mem/qip/mem_ss','syn/board/ia840f/syn_top/qdb','syn/board/ia840f/syn_top/output_files','syn/board/ia840f/syn_top/ofs_ip_cfg_db','syn/board/ia840f/setup/experimental-authorization.json']
def archived_path(r):return any(r==p or r.startswith(p+'/') for p in archived)
unchanged=[];deviations=[]
for r,v in old.items():
 if archived_path(r):continue
 assert r in now,('unexpected nonmemory removal',r)
 if r in overlay:assert now[r]=={'sha256':overlay[r]}
 elif r in reloc:
  entry=reloc[r]
  assert now[r]==({'symlink':entry['after']} if entry['kind']=='symlink' else {'sha256':entry['after_sha256']})
 else:assert now[r]==v,('unexpected nonmemory drift',r);unchanged.append(r)
 if now[r]!=v:deviations.append(dict(path=r,before=v,after=now[r]))
new=set(now)-set(old)
assert new <= set(overlay) | {r for r in now if r.startswith('ipss/mem/qip/mem_ss/')},sorted(new)
memroot=W/'ipss/mem/qip/mem_ss';memory=inv(memroot);expected={r:v for r,v in pre['memory'].items() if r!='first-save.ip'}
assert set(memory)==set(expected)
for r,v in expected.items():
 full='ipss/mem/qip/mem_ss/'+r
 if full in reloc:assert memory[r]=={'sha256':reloc[full]['after_sha256']}
 else:assert memory[r]==v,r
q='syn/board/ia840f/syn_top/ofs_top.qsf';assert sha(W/q)==sha(C/q)=='ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c'
assert not any((E/p).exists() for p in ['header-run','run','header-authorization.json','compile-authorization.json','compile-authorization.draft.json','native-compile.claim.json','header-issuance.lock'])
assert not (C/'build_fim_work_ia840f_fim_12.log').exists()
# Header script and all board/project hook bytes are bound through source/work inventories.
refs={}
for r in ['ipss/mem/mem_design_files.tcl','syn/board/ia840f/syn_top/ofs_top_sources.tcl','syn/board/ia840f/syn_top/ofs_top.qsf','syn/board/ia840f/setup/build_gate.tcl','ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl','ofs-common/scripts/common/syn/ip_get_cfg/ofs_ip_cfg_db.tcl']:
 refs[r]=dict(sha256=sha(W/r),text=(W/r).read_text())
assert '/ipss/mem/qip/mem_ss/mem_ss.ip' in refs['ipss/mem/mem_design_files.tcl']['text']
assert 'local_mem mem_ss_get_cfg.tcl' in refs['ipss/mem/mem_design_files.tcl']['text']
with (E/'project-header-source-evidence.json').open('x') as f:json.dump(refs,f,indent=2)
with (E/'nonmemory-provenance.json').open('x') as f:json.dump(dict(unchanged_entries=unchanged,explicit_deviations=deviations,new_paths=sorted(new),archived_prefixes=archived),f,indent=2)
with (E/'inherited-output-inventory.json').open('x') as f:json.dump(inv(E/'inherited-output'),f,indent=2)
with (E/'final-work-preheader-inventory.json').open('x') as f:json.dump(now,f,indent=2)
# Finalize the still-unapproved header draft; no future compile inventory is asserted.
p=E/'header-authorization.draft.json';record=json.loads(p.read_text());assert record['approved'] is False and record['work_inventory']==now
for name in FINAL_ARTIFACTS:record['dependency_sha256'][str(E/name)]=sha(E/name)
for name in ['memory-closure-complete.json','project-header-source-evidence.json','nonmemory-provenance.json','final-work-preheader-inventory.json','test_header_dispatch.py','test_header_runner_inert.py']:
 record['dependency_sha256'][str(E/name)]=sha(E/name)
record['dependency_sha256'][gate.PYTHON_EXE]=sha(gate.PYTHON_EXE)
record['dependency_sha256']['/home/uwb_student00/quartus_26/instructions.md']=sha('/home/uwb_student00/quartus_26/instructions.md')
p.write_text(json.dumps(record,indent=2));assert json.loads(p.read_text())==record
summary=dict(source_files=sum(map(len,pre['source'].values())),pim_entries=len(pre['pim']),baseline_dependencies=len(pre['dependencies']),work_entries=len(now),memory_project_files=len(memory),accepted_original_work_files=len(pre['memory']),unchanged_nonmemory_entries=len(unchanged),explicit_nonmemory_deviations=len(deviations),qsf_sha256=sha(W/q),header_contexts=1,compile_contexts=135,header_required_outputs=8,source_unchanged=True,pim_unchanged=True,baseline_dependencies_unchanged=True,work04_unchanged=True,work11_evidence_unchanged=True,accepted_memory_original_unchanged=True,header_launched=False,compile_launched=False,authorization_issued=False,independent_reviews='PENDING PARENT SPEC THEN QUALITY',ready_for_build=False,compile_inventory='DEFERRED UNTIL REVIEWED HEADER RESULT',header_binding_sha256=sha(p))
with (E/'final-verification.json').open('x') as f:json.dump(summary,f,indent=2)
print(json.dumps(summary,indent=2))
