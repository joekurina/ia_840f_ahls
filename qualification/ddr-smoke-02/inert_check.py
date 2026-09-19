#!/usr/bin/env python3
"""Inert structural/control tests. Does not compile or simulate HDL."""
import importlib.util,json,pathlib,re,subprocess,sys,tempfile,os
P=pathlib.Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('runner',P/'run_smoke.py');r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
m=json.loads((P/'manifest.json').read_text());s=(P/'tb_mem_ss_smoke.sv').read_text();ports=json.loads((P/'ports.json').read_text())
assert len(ports)==128
wired=re.findall(r'\.(\w+)\((\w+)\)',s.split('mem_ss dut (',1)[1].split(');',1)[0]);assert len(wired)==128 and all(a==b for a,b in wired)
assert set(a for a,b in wired)=={x[2] for x in ports}
for c,model in enumerate(['ed_sim_mem','ed_sim_mem_group1']):
    declared={n:(d,w) for d,w,n in ports}
    model_ports=re.findall(r'\b(input|output|inout)\s+wire\s*(\[[^\]]+\])?\s*(\w+)',(P/f'evidence/{model}.v').read_text().split(');',1)[0])
    for d,w,n in model_ports:
        dut_d,dut_w=declared[f'mem{c}_ddr4_{n[4:]}'];assert w==dut_w
        assert (d,dut_d) in [('input','output'),('output','input'),('inout','inout')]
    for d,w,n in ports:
        if d=='input' and n.startswith(f'i{c}_'):assert re.search(r'\b'+n+r'=',s)
    assert f'write_{c}(0); write_{c}(1);' in s and f'read_{c}(0); read_{c}(1);' in s
    assert f'done[{c}]=1' in s
assert len(m['commands'])==142 and len(m['hex_files'])==5 and len(m['design_libraries'])==27
assert len({pathlib.Path(x['path']).name for x in m['hex_files']})==5
for cmd in m['commands']:
    assert cmd[0]=='vlog' and cmd[cmd.index('-work')+1] in m['design_libraries']
    sources=[x for x in cmd if x.endswith(('.v','.sv'))];assert len(sources)==1
    assert os.path.normpath(sources[0]) in {x['path'] for x in m['inputs']}
assert not re.search(r'\b(force|release|defparam)\b',re.sub(r'//[^\n]*','',s))
assert 'VoptFlow = 1' in r.ini_text(m)
fixture='\n'.join(['# '+r.PASS]+['# DDR_SMOKE_CHANNEL_DONE channel=%d writes=2 reads=2'%c for c in range(2)])
assert r.accepted(0,fixture)
for rc,text in [(1,fixture),(124,fixture),(0,''),(0,r.PASS),(0,fixture+'\n** Error: bad'),(0,fixture+'\n** Fatal: bad'),(0,fixture+'\nDDR_SMOKE_FAIL mismatch'),(0,fixture+'\n'+r.PASS)]:assert not r.accepted(rc,text)
with tempfile.TemporaryDirectory() as tmp:
    q=pathlib.Path(tmp)
    assert r.run_child([sys.executable,'-c','raise SystemExit(7)'],q,os.environ.copy(),q/'nonzero.log',2)==7
    assert r.run_child([sys.executable,'-c','import time;time.sleep(5)'],q,os.environ.copy(),q/'timeout.log',0.05)==124
    out=q/'must-not-exist'
    rejected=subprocess.run([sys.executable,str(P/'run_smoke.py'),'--execute','--output',str(out)],capture_output=True,text=True)
    assert rejected.returncode==2 and not out.exists()
    reject_reason=rejected.stderr.strip()
result={'inert_checks_passed':True,'hdl_compilation_executed':False,'hdl_simulation_executed':False,'ready_for_build':False,'dut_port_connections_checked':128,'model_pin_connections_checked':32,'ip_compile_commands_checked':142,'ordered_design_libraries':27,'hex_files':5,'scoreboard_parser_positive_and_negative_fixtures':'pass (synthetic parser strings only, NOT HDL results)','child_nonzero_and_timeout':'pass (Python children only)','review_rejection':reject_reason,'reset_source_acceptance':False}
(P/'inert-check.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
