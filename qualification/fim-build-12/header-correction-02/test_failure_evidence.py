"""Local inert-only regression driver; no vendor executable is imported or run."""
from pathlib import Path
from unittest.mock import patch
import contextlib, hashlib, importlib.util, json, os, subprocess, sys, tempfile, types

def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def worker(runner, root, native, fault):
    root = Path(root); work = root/'work'; work.mkdir()
    child = ('from pathlib import Path; import os,signal; '
             'Path("fresh.txt").write_text("inert output"); '
             'Path("other.txt").write_text("other evidence"); print("inert diagnostic",flush=True); ')
    child += 'os.kill(os.getpid(),signal.SIGTERM)' if native == -15 else f'raise SystemExit({native})'
    record = dict(work_inventory={},required_outputs=['fresh.txt','other.txt'],tools={'quartus_sh':{'path':sys.executable}})
    common = types.SimpleNamespace(PIM=work,REJECTION_MARKERS=['INERT_REJECTION'])
    gate = types.SimpleNamespace(common=common,PROJECT=work,RECORD=root/'auth.json',PYTHON_EXE=sys.executable,
        TOP_ARGS=[],HEADER_ARGS=['python','-c',child],environment=lambda:None,start_time=lambda p:'inert',sha=sha)
    common.process=lambda p:(gate.PYTHON_EXE,gate.TOP_ARGS,str(work))
    counts={'record':0,'inventory':0}
    def load():
        counts['record']+=1
        if counts['record']>1 and (root/'header-run/native-status.json').exists():
            checkpoint=json.loads((root/'header-run/native-status.json').read_text())
            assert checkpoint['native_returncode']==native and checkpoint['native_exit_accepted'] is False
            counts['checkpoint_before_postflight']=True
        if counts['record']>1 and fault=='postflight':
            raise ValueError('inert postflight dependency mismatch')
        return record
    def inventory():
        counts['inventory']+=1
        if counts['inventory']==1:return {}
        if fault=='inventory':raise OSError('inert inventory failure')
        return {p.name:{'sha256':sha(p)} for p in work.iterdir() if p.is_file()}
    def digest(p):
        if Path(p)==gate.RECORD:return 'INERT'
        if fault=='hash' and Path(p)==work/'fresh.txt':raise OSError('inert output hash failure')
        return sha(p)
    gate.load_record=load; gate.work_inventory=inventory; gate.sha=digest
    realstat=Path.stat; realread=Path.read_text
    def stat(p,*a,**k):
        if fault=='stat' and p==work/'fresh.txt' and (work/'other.txt').exists():raise OSError('inert output stat failure')
        return realstat(p,*a,**k)
    def read(p,*a,**k):
        if fault=='diagnostics' and p==root/'header-run/native.log':raise OSError('inert diagnostics read failure')
        return realread(p,*a,**k)
    with contextlib.ExitStack() as s:
        s.enter_context(patch.dict(sys.modules,ia840f_header_gate=gate))
        spec=importlib.util.spec_from_file_location('inert_runner',runner); mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
        mod.E=root;mod.W=work
        s.enter_context(patch.object(mod.socket,'gethostname',return_value='Agilex7Workstation'))
        s.enter_context(patch.object(mod.os,'getuid',return_value=1000))
        s.enter_context(patch.object(mod.subprocess,'check_output',return_value='ia840f_mailbox_monitored_01'))
        s.enter_context(patch.object(sys,'argv',[str(root/'run_headers.py')]))
        s.enter_context(patch.dict(os.environ,TMUX='INERT'))
        s.enter_context(patch.object(Path,'stat',stat));s.enter_context(patch.object(Path,'read_text',read))
        os.chdir(work)
        try:
            rc=mod.run()
        finally:
            before={str((Path(d)/n).relative_to(root)):sha(Path(d)/n) for d,_,names in os.walk(root) for n in names}
            try:mod.run()
            except Exception:pass
            else:raise AssertionError('rerun was accepted')
            after={str((Path(d)/n).relative_to(root)):sha(Path(d)/n) for d,_,names in os.walk(root) for n in names}
            assert before==after,'rerun mutated evidence'
            (root/'rerun-check.json').write_text(json.dumps({'immutable':True}))
        return rc

def main():
    runner=Path(sys.argv[1]).resolve(); destination=Path(sys.argv[2]); destination.mkdir()
    results=[]
    for native,fault in [(17,'postflight'),(0,'postflight'),(17,'hash'),(0,'hash'),(17,'stat'),(0,'stat'),(17,'inventory'),(0,'inventory'),(17,'diagnostics'),(0,'diagnostics'),(0,'none'),(17,'none'),(-15,'postflight'),(-15,'none')]:
        root=Path(tempfile.mkdtemp(prefix=f'work12-inert-{native}-{fault}-'))
        cmd=[sys.executable,'-B',__file__,'--worker',str(runner),str(root),str(native),fault]
        child=subprocess.run(cmd,capture_output=True,text=True)
        (destination/f'{native}-{fault}.log').write_text(child.stdout+child.stderr)
        problems=[]; run=root/'header-run'
        status=json.loads((run/'result.json').read_text()) if (run/'result.json').exists() else {}
        expected=128-native if native<0 else native if native else (1 if fault!='none' else 0)
        if child.returncode!=expected:problems.append(f'exit {child.returncode} != {expected}')
        if status.get('native_returncode')!=native:problems.append('native rc missing')
        for name in ['outputs.json','postheader-work-inventory.json','native-status.json']:
            if not (run/name).exists():problems.append('missing '+name)
        if fault!='none':
            if status.get('native_exit_accepted') is not False:problems.append('not rejected')
            if not status.get('collection_errors'):problems.append('missing explicit errors')
            if not (run/'failure.json').exists():problems.append('missing failure')
        if (run/'outputs.json').exists():
            outputs=json.loads((run/'outputs.json').read_text())
            if 'sha256' not in outputs.get('other.txt',{}):problems.append('lost available output')
            if fault=='stat' and 'sha256' not in outputs.get('fresh.txt',{}):problems.append('stat failure lost hash')
            if fault=='hash' and 'bytes' not in outputs.get('fresh.txt',{}):problems.append('hash failure lost stat')
        if fault=='inventory' and (run/'postheader-work-inventory.json').exists():
            if 'other.txt' not in json.loads((run/'postheader-work-inventory.json').read_text()):problems.append('no best effort inventory')
        if not json.loads((root/'rerun-check.json').read_text())['immutable']:problems.append('rerun changed')
        results.append(dict(native=native,fault=fault,exit=child.returncode,expected_exit=expected,fixture=str(root),problems=problems,command=cmd))
    (destination/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print(json.dumps(results,indent=2));return int(any(r['problems'] for r in results))

if __name__=='__main__':
    if sys.argv[1]=='--worker':sys.exit(worker(sys.argv[2],sys.argv[3],int(sys.argv[4]),sys.argv[5]))
    sys.exit(main())
