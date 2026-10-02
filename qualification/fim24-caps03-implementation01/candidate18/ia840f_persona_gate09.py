"""Copied-project synthesis callback; no deployment or reusable authority."""
import hashlib,json,os,sys
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_implementation01')
D=ROOT/'base01';P=ROOT/'control19';R=ROOT/'synth01';J=D/'build/syn/board/ia840f/syn_top'
MANIFEST=P/'synthesis-inputs.admitted.json'
GATE=D/'build/syn/board/ia840f/setup/ia840f_persona_gate09.py'
CONTEXT={'exe':'/opt/altera/26.1.1/quartus/linux64/quartus_syn','cwd':str(J),'argv':['--read_settings_files=on','--write_settings_files=off','ofs_top','-c','ofs_pr_afu']}

def sha(path):
    h=hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda:f.read(1048576),b''):h.update(block)
    return h.hexdigest()

def proc(pid):
    p=Path('/proc')/str(pid);s=(p/'stat').read_text().rsplit(') ',1)[1].split()
    return {'pid':int(pid),'ppid':int(s[1]),'start_ticks':s[19],'state':s[0],'exe':os.readlink(p/'exe'),'cwd':os.readlink(p/'cwd'),'argv':(p/'cmdline').read_bytes().decode().rstrip(chr(0)).split(chr(0))}

def owner_live(authority):
    expected=authority['runner'];observed=proc(expected['pid'])
    assert observed['state'] not in ('Z','X')
    assert all(observed[k]==expected[k] for k in ('pid','start_ticks','exe','cwd','argv'))
    return observed

def check_binding(path,entry):
    path=Path(path)
    if entry.get('kind')=='symlink':
        assert path.is_symlink() and os.readlink(path)==entry['target'],str(path)
        assert str(path.resolve(strict=True))==entry['resolved'],str(path)
        if 'sha256_of_target' in entry:assert sha(path)==entry['sha256_of_target'],str(path)
    else:
        assert path.is_file() and not path.is_symlink(),str(path)
        assert path.stat().st_size==entry['bytes'] and sha(path)==entry['sha256'],str(path)

def append_owned(name,record,authority):
    owner_live(authority)
    assert R.is_dir() and not R.is_symlink()
    with (R/name).open('a') as stream:stream.write(json.dumps(record,sort_keys=True)+'\n')

def validate():
    assert __debug__ and sys.argv[1:]==['quartus']
    assert Path(__file__).resolve()==GATE
    assert R.is_dir() and not R.is_symlink()
    authority=json.loads((R/'authority.json').read_text())
    assert authority['scope']=='persona-mapped-synthesis-only' and authority['ready_for_build'] is False and authority['hardware_ready'] is False
    assert authority['manifest']==str(MANIFEST) and authority['project']==str(J)
    assert sha(MANIFEST)==authority['manifest_sha256'];m=json.loads(MANIFEST.read_text())
    assert m['scope']=='persona-mapped-synthesis-only' and m['parent_execution_accepted'] is True and m['ready_for_build'] is False and m['hardware_ready'] is False
    assert m['project']==str(J) and m['design_root']==str(D) and m['operation_root']==str(R) and m['control_root']==str(P)
    assert sha(GATE)==m['gate_sha256'] and sha(m['runner_path'])==m['runner_sha256']
    assert m['contexts']==[CONTEXT] and authority['contexts']==m['contexts']
    assert 'OPAE_PLATFORM_GEN' not in os.environ
    assert os.environ.get('QUARTUS_ROOTDIR_OVERRIDE')=='/opt/altera/26.1.1/quartus'
    assert os.environ.get('OPAE_PLATFORM_ROOT')==m['release_root'] and os.environ.get('BUILD_ROOT_REL')=='../../../..' and os.environ.get('PR_COMPILE')=='1'
    owner_live(authority);parent=proc(os.getppid())
    observed_context={'exe':parent['exe'],'cwd':parent['cwd'],'argv':parent['argv'][1:]}
    assert observed_context==CONTEXT,('unrecorded native context',observed_context)
    assert sha(parent['exe'])==m['tools'][parent['exe']]['sha256']
    ancestor=parent;found=False
    for _ in range(40):
        if ancestor['pid']==authority['runner']['pid']:
            assert all(ancestor[k]==authority['runner'][k] for k in ('pid','start_ticks','exe','cwd','argv'));found=True;break
        if ancestor['ppid']<=1:break
        ancestor=proc(ancestor['ppid'])
    assert found,'native process is not descended from current owned runner'
    assert sha(m['prepared_metadata_file'])==m['prepared_metadata_sha256'];prepared=json.loads(Path(m['prepared_metadata_file']).read_text())
    assert m['critical_inputs']==prepared['critical_inputs'] and m['external_inputs']==prepared['external_inputs']
    assert len(m['critical_inputs'])==2588 and len(m['external_inputs'])==298
    for path,entry in m['critical_inputs'].items():check_binding(path,entry)
    for path,entry in m['external_inputs'].items():check_binding(path,entry)
    assert m['prerequisites'] and all(sha(path)==digest for path,digest in m['prerequisites'].items())
    qsf=(J/'ofs_pr_afu.qsf').read_text()
    for line in ('set_global_assignment -name FAMILY "Agilex 7"','set_global_assignment -name DEVICE AGFB027R25A2E2V','set_global_assignment -name TOP_LEVEL_ENTITY top','set_global_assignment -name REVISION_TYPE PR_IMPL','set_global_assignment -name NUM_PARALLEL_PROCESSORS 36'):
        assert qsf.splitlines().count(line)==1,('project identity',line)
    append_owned('gate-events.jsonl',{'accepted':True,'scope':authority['scope'],'native':parent,'manifest_sha256':authority['manifest_sha256']},authority)
    return {'accepted':True,'native':parent}

def main():
    try:
        result=validate();print(json.dumps(result,sort_keys=True));return 0
    except BaseException as exc:
        result={'accepted':False,'error':repr(exc)}
        try:
            authority=json.loads((R/'authority.json').read_text());append_owned('gate-rejections.jsonl',result,authority)
        except BaseException:pass
        print('IA840F_GATE_REJECTED: '+json.dumps(result,sort_keys=True),file=sys.stderr);return 1

if __name__=='__main__':sys.exit(main())
