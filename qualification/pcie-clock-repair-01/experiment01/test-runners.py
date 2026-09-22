#!/usr/bin/env python3
"""Real inert child checks for the phase runners; never vendor execution."""
from pathlib import Path
import ast, hashlib, json, os, re, runpy, subprocess, sys, tempfile, types
ROOT=Path(__file__).resolve().parent

def main():
    rows=[]
    with tempfile.TemporaryDirectory(prefix='ia840f-constraint-runner-',dir='/home/joe/.hermes/cache/scratch') as tmp:
        scratch=Path(tmp)
        for phase in ('baseline','candidate'):
            module='ia840f_clock_'+phase+'01_gate'
            fake=types.ModuleType(module);setattr(fake,'validate',lambda **kw:None);setattr(fake,'identity',lambda pid:None)
            sys.modules[module]=fake
            path=ROOT/phase/'run-query.py';source=path.read_text()
            tree=ast.parse(source,feature_version=(3,9));env=runpy.run_path(str(path));wait=env['wait_bounded']
            for node in ast.walk(tree):
                if isinstance(node,ast.Call) and isinstance(node.func,ast.Attribute) and node.func.attr=='search' and isinstance(node.args[0],ast.Constant):
                    pattern=node.args[0].value
                    if not isinstance(pattern,str):raise RuntimeError('non-string error pattern')
                    if not re.search(pattern,'Error (23035): deliberately inert diagnostic'):raise RuntimeError('regex did not catch native error')
            for label,code,wall,limit,expected in (
                ('success','pass',30,1024,(0,None)),
                ('nonzero','raise SystemExit(7)',30,1024,(7,None)),
                ('wall','import time;time.sleep(30)',0.05,1024,(None,'wall-time cap')),
                ('output-cap','import time;time.sleep(30)',30,1,(None,'report-total cap'))):
                report=scratch/(phase+'-'+label);report.mkdir()
                if label=='output-cap':(report/'fixture').write_bytes(b'xx')
                child=subprocess.Popen([sys.executable,'-B','-c',code],start_new_session=True)
                rc,reason=wait(child,report,wall_seconds=wall,bytes_limit=limit)
                if reason!=expected[1] or (expected[0] is not None and rc!=expected[0]) or (reason is not None and rc>=0):raise RuntimeError((phase,label,rc,reason))
                rows.append({'phase':phase,'case':label,'rc':rc,'reason':reason,'pass':True})
            rows.append({'phase':phase,'case':'AST39_inert_import_and_native_error_regex','pass':True})
        # TERM-exiting leader with a TERM-resistant child in the owned PGID.
        report=scratch/'descendant';report.mkdir();pidfile=report/'child-pid'
        program='import os,signal,time; p=os.fork();\nif p==0:\n signal.signal(signal.SIGTERM,signal.SIG_IGN);open('+repr(str(pidfile))+',"w").write(str(os.getpid()));time.sleep(30)\nelse: time.sleep(30)'
        child=subprocess.Popen([sys.executable,'-B','-c',program],start_new_session=True)
        rc,reason=wait(child,report,wall_seconds=0.05,bytes_limit=1024)
        if reason!='wall-time cap':raise RuntimeError('descendant watchdog failed')
        pid=int(pidfile.read_text());stat=Path('/proc')/str(pid)/'stat'
        state=stat.read_text().rsplit(')',1)[1].split()[0] if stat.exists() else 'absent'
        if state not in ('Z','absent'):raise RuntimeError('live descendant after runner returned: '+state)
        rows.append({'phase':'candidate','case':'TERM-resistant_descendant','leader_rc':rc,'descendant_state':state,'pass':True})
    print(json.dumps({'scope':'actual inert Python children and mocked gate import; no vendor process or authorization','count':len(rows),'tests':rows,'runner_sha256':{p:hashlib.sha256((ROOT/p/'run-query.py').read_bytes()).hexdigest() for p in ('baseline','candidate')}},indent=2))
if __name__=='__main__':main()
