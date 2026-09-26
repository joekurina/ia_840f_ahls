"""Read-only finite inventory of completed synth141, for a fresh fitter copy."""
import base64, hashlib, json, os, socket, stat, subprocess, traceback
from datetime import datetime, timezone
from pathlib import Path
assert __debug__ and socket.gethostname() == 'Agilex7Workstation' and os.getuid() == 1000 and os.environ.get('TMUX')
R = Path('/home/uwb_student00/ahls/new_BSP/work_caps03_completion01/synth01')
EXPECTED = 'd9d3b6b7bf52b518b4a2f26a114e557022865309a8e180db253beac760ccf017'
result = {'run':'caps03-fitprep01','started':datetime.now(timezone.utc).isoformat(),'hardware_access':False,'success':False}
def digest(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for block in iter(lambda:f.read(8*1024*1024),b''): h.update(block)
    return h.hexdigest()
try:
    assert digest(R/'result.json') == EXPECTED
    record=json.loads((R/'result.json').read_text())
    assert record['success'] and record['complete'] and len(record['commands']) == 2
    command=record['commands'][-1]
    assert command['native_rc'] == command['effective_rc'] == 0 and not command['timeout'] and not command['owned_group_live_after']
    assert not record['postflight_errors'] and not record['diagnostics']
    assert all(record[k] is True for k in ('setup_unchanged','release_unchanged','tools_unchanged','bound_inputs_unchanged'))
    result['source_result_sha256']=EXPECTED
    result['source_root']=str(R)
    total=0; inventory={}
    for p in sorted((R/'persona').rglob('*')):
        if not p.is_file(): continue
        before=p.stat(); assert stat.S_ISREG(before.st_mode)
        total+=before.st_size
        assert len(inventory)<10000 and total<20*1024**3
        item={'bytes':before.st_size,'sha256':digest(p)}
        if p.is_symlink(): item['symlink']=os.readlink(p)
        after=p.stat(); assert (before.st_size,before.st_mtime_ns)==(after.st_size,after.st_mtime_ns),str(p)
        inventory[str(p.relative_to(R/'persona'))]=item
    result['persona_inventory']=inventory
    result['inventory_count']=len(inventory); result['inventory_bytes']=total
    qprefix='build/syn/board/ia840f/syn_top/'
    for name,entry in record['qdb_outputs'].items():
        assert {k:inventory[qprefix+name][k] for k in ('bytes','sha256')} == entry
    result['qdb_members_reverified']=len(record['qdb_outputs'])
    result['input_hashes_reverified']=0
    for name,sha in record['input_hashes'].items():
        assert digest(Path(name)) == sha,name
        result['input_hashes_reverified']+=1
    result['overlays']={}
    for name,entry in record['source_delta']['overlay_sources'].items():
        path=R/'afu_overlay'/name
        assert path.stat().st_size==entry['bytes'] and digest(path)==entry['sha256']
        result['overlays'][name]=entry
    assert digest(R/'result.json') == EXPECTED
    result['success']=True
except Exception:
    result['error']=traceback.format_exc()
result['ended']=datetime.now(timezone.utc).isoformat()
data=json.dumps(result,sort_keys=True).encode()
envelope=json.dumps({'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}).encode()
subprocess.run(['tmux','load-buffer','-b','caps03_fitprep01_result','-'],input=envelope,check=True)
raise SystemExit(0 if result['success'] else 1)
