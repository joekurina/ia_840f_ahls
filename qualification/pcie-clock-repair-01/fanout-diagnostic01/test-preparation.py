#!/usr/bin/env python3
"""INERT preparation-root and unowned-existing-leaf rejection regressions."""
from pathlib import Path
import ast,hashlib,json,os,runpy,socket,subprocess,sys,tempfile
from unittest.mock import patch
ROOT=Path(__file__).resolve().parent
EXPECTED=Path('/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01')
def existing_leaf(script,legacy):
    ns=runpy.run_path(str(script));g=ns['main'].__globals__
    with tempfile.TemporaryDirectory(prefix='ia840f-preparer-fixture-',dir='/home/joe/.hermes/cache/scratch') as tmp:
        leaf=Path(tmp)/'existing';leaf.mkdir();(leaf/'sentinel').write_bytes(b'PRESERVE')
        g['E']=leaf;g['__name__']='__main__'
        payload=json.dumps({k:{} for k in ('query.tcl','run-query.py','ia840f_clock_fanout01_gate.py','AUTHORITY.md','SPEC.md','clock-repair.tcl','known-receivers.tcl')}).encode()
        calls=[]
        def output(args,**kwargs):
            calls.append(args)
            if args[:2]==['tmux','display-message']:return 'ia840f_mailbox_monitored_01\n'
            if args[:2]==['tmux','save-buffer']:return payload
            raise AssertionError('unexpected subprocess '+repr(args))
        entry=ast.Module(body=[ast.parse(script.read_text()).body[-1]],type_ignores=[])
        with patch.object(socket,'gethostname',return_value='Agilex7Workstation'),patch.object(os,'getuid',return_value=1000),patch.dict(os.environ,{'TMUX':'INERT','TMUX_PANE':'INERT'}),patch.object(sys,'argv',[str(script),hashlib.sha256(payload).hexdigest()]),patch.object(subprocess,'check_output',side_effect=output):
            try:exec(compile(entry,'inert-actual-preparer-entry','exec'),g);raise AssertionError('existing leaf allowed')
            except RuntimeError as exc:assert str(exc)=='attempt already exists'
        assert (leaf/'sentinel').read_bytes()==b'PRESERVE' and len(calls)==2
        assert (leaf/'preparation-error.json').exists() is legacy
        assert len(list(leaf.iterdir()))==(2 if legacy else 1)
        return {'case':'old_unowned_error_append_reproduced' if legacy else 'new_unowned_leaf_unchanged','pass':True}
def main():
    assert not sys.flags.optimize
    rows=[]
    old=runpy.run_path(str(ROOT/'prepare01.py'));new=runpy.run_path(str(ROOT/'prepare02.py'))
    assert old['E']!=EXPECTED and new['E']==EXPECTED and new['OWNED'] is False
    rows.append({'case':'old_stale_relative_root_reproduced_and_successor_root_correct','pass':True})
    sys.path.insert(0,str(ROOT));sys.dont_write_bytecode=True
    for name in ('run-query.py','ia840f_clock_fanout01_gate.py'):
        ns=runpy.run_path(str(ROOT/name));assert ns['E']==EXPECTED
    rows.append({'case':'preparer_runner_gate_roots_equal','pass':True})
    rows.extend((existing_leaf(ROOT/'prepare01.py',True),existing_leaf(ROOT/'prepare02.py',False)))
    for f in ROOT.glob('*.py'):ast.parse(f.read_text(),feature_version=(3,9))
    print(json.dumps({'scope':'INERT real preparation rejection entry; all OS/session/transport identity mocked; no remote/vendor/authorization','count':len(rows),'tests':rows,'prepare02_sha256':hashlib.sha256((ROOT/'prepare02.py').read_bytes()).hexdigest(),'test_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},indent=2))
if __name__=='__main__':main()
