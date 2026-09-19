from pathlib import Path
import os,sys,json,hashlib,base64,difflib
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-12';W=B/'work_ia840f_fim_12';C=B/'ofs-agx7-pcie-attach'
sys.dont_write_bytecode=True
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
for name,data in ARTIFACTS.items():
 with (E/name).open('xb') as f:f.write(base64.b64decode(data))
for root in [W,E/'source-overlay']:
 p=root/'ofs-common/tools/ofss_config/ia840f_header_gate.py'
 with p.open('xb') as f:f.write((E/'ia840f_header_gate.py').read_bytes())
 p=root/'ofs-common/tools/ofss_config/ia840f_experimental_gate.py'
 text=p.read_text();old="""            import ia840f_compile_gate
            ia840f_compile_gate.quartus_context()"""
 new="""            import ia840f_header_gate
            if process(os.getppid())[1] == ia840f_header_gate.HEADER_ARGS:
                ia840f_header_gate.quartus_context()
            else:
                import ia840f_compile_gate
                ia840f_compile_gate.quartus_context()"""
 assert text.count(old)==1;p.write_text(text.replace(old,new))
overlays=json.loads((E/'overlay-sha256.json').read_text())
for name in ['ia840f_experimental_gate.py','ia840f_header_gate.py']:
 rel='ofs-common/tools/ofss_config/'+name;overlays[rel]=sha(W/rel)
(E/'overlay-sha256.json').write_text(json.dumps(overlays,indent=2))
changes={r:h for r,h in overlays.items() if not (C/r).exists() or sha(C/r)!=h}
(E/'header-source-changes.json').write_text(json.dumps(changes,indent=2))
(E/'candidate.patch').write_text(''.join(''.join(difflib.unified_diff((C/r).read_text().splitlines(True) if (C/r).exists() else [],(W/r).read_text().splitlines(True),fromfile='a/'+r,tofile='b/'+r)) for r in changes))
sys.path.insert(0,str(W/'ofs-common/tools/ofss_config'));import ia840f_header_gate as gate;import ia840f_compile_gate as cg
baseline=json.loads((E/'preflight.json').read_text());prior=json.loads((B/'qualification/fim-build-11/compile-authorization.json').read_text())
assert {t:gate.common.inventory(C/t) for t in gate.common.TREES}==baseline['source']
source=json.loads(json.dumps(baseline['source']))
for rel,h in changes.items():
 tree,rest=rel.split('/',1);source[tree][rest]=h
ctx=dict(executable=gate.common.RUNTIME_EXES['quartus_sh'],sha256=sha(gate.common.RUNTIME_EXES['quartus_sh']),argv=gate.HEADER_ARGS,cwd=str(gate.PROJECT))
deps=dict(baseline['dependencies'])
for name in ARTIFACTS:deps[str(E/name)]=sha(E/name)
for name in ['overlay-sha256.json','header-source-changes.json','preflight.json','staging-receipt.json','memory-closure.json']:
 if (E/name).exists():deps[str(E/name)]=sha(E/name)
mem='ipss/mem/qip/mem_ss/sv_wrapper/'
proj='syn/board/ia840f/syn_top/ofs_ip_cfg_db/'
outputs=[mem+s for s in ['mem_ss_sv.sv','mem_ss_param_pkg.sv','mem_ss_if_info.vh','mem_ss_ip_params.vh']]+[proj+s for s in ['ip_gen_sv_wrapper_inc.tcl','ofs_ip_cfg_db.vh','ofs_ip_cfg_local_mem.vh','ofs_ip_cfg_local_mem_asp.qprs']]
assert not any((W/p).exists() for p in outputs)
record=dict(schema=1,approved=False,accepted_execution=False,source_review_consumed=False,gate_review_consumed=False,ready_for_build=False,target='ia840f',part=gate.common.PART,toolchain=gate.common.VERSION,source=str(C),work=str(W),pim=str(gate.common.PIM),permissions=['native-headers'],source_sha256=source,pim_sha256=baseline['pim'],tools=prior['tools'],quartus_tools=prior['quartus_tools'],contexts=[ctx],native_argv=gate.TOP_ARGS,native_cwd=str(gate.PROJECT),work_inventory=gate.work_inventory(),dependency_sha256=deps,required_outputs=outputs,compile_authorized=False)
with (E/'header-authorization.draft.json').open('x') as f:json.dump(record,f,indent=2)
# This is NOT a future compile input binding. Only an inert pre-header test fixture.
fixture=dict(record);fixture.update(permissions=['native-full-compile'],native_argv=cg.TOP_ARGS,native_cwd=str(C),contexts=json.loads(json.dumps(prior['contexts']).replace('work_ia840f_fim_11','work_ia840f_fim_12')))
assert len(fixture['contexts'])==135 and [r['argv'] for r in fixture['contexts']]==cg.allowed_commands()
fixture['fixture_only']='PREHEADER INERT TEST; NOT ISSUABLE; FINAL COMPILE INVENTORY MUST FOLLOW HEADER RESULT'
with (E/'compile-context-fixture.json').open('x') as f:json.dump(fixture,f,indent=2)
with (E/'compile-contexts.json').open('x') as f:json.dump(fixture['contexts'],f,indent=2)
print(json.dumps(dict(header_contexts=1,compile_contexts=135,source_changes=changes,header_outputs=len(outputs),source_unchanged=True,ready_for_build=False)))
