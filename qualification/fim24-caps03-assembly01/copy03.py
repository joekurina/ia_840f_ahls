"""Copy accepted STA for assembly SOURCE/API review; no project/native/authority."""
import base64,copy,gzip,hashlib,json,os,shutil,socket,subprocess,sys,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01');D=ROOT/'base01';P=ROOT/'source03';BATCH=sys.argv[1];INPUT='ia840f_asm_copy03_inputs';EXPECTED='ab7e37fa695ca9c4d561c7d2f5cdf610b7dac14a9eea6e487b01c76009dae695'
out={'batch':BATCH,'scope':'acceptedSTA source-copy only','success':False,'assembly_started':False,'authority_issued':False,'hardware_access':False,'exports':{}};owned=False
def sha(path):
    digest = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''): digest.update(block)
    return digest.hexdigest()

def inventory(root):
    result, total = {}, 0
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in dirs + files:
            path = Path(directory) / name
            if path.is_symlink():
                entry = {'kind': 'symlink', 'target': os.readlink(path), 'resolved': str(path.resolve(strict=True))}
                if path.is_file(): entry['sha256_of_target'] = sha(path)
            elif path.is_file():
                size = path.stat().st_size; total += size
                assert total <= 8 * 1024**3
                entry = {'kind': 'file', 'bytes': size, 'sha256': sha(path)}
            else: continue
            result[str(path.relative_to(root))] = entry
            assert len(result) <= 20000
    return result, total

def binding(path, entry):
    path = Path(path)
    if entry.get('kind') == 'symlink':
        return path.is_symlink() and os.readlink(path) == entry['target'] and str(path.resolve(strict=True)) == entry['resolved'] and ('sha256_of_target' not in entry or sha(path) == entry['sha256_of_target'])
    return path.is_file() and not path.is_symlink() and path.stat().st_size == entry['bytes'] and sha(path) == entry['sha256']

def preserve(m):
    assert inventory(Path(m['original_fitted_root']))[0] == m['original_fitted_inventory']
    assert inventory(Path(m['original_mapped_root']))[0] == m['original_mapped_inventory']
    for rootkey, mapkey in [('original_setup_root','original_setup_inventory'),
                             ('release_root','original_release_inventory'), ('archive_root','archive_inventory')]:
        assert all(binding(Path(m[rootkey]) / n, item) for n, item in m[mapkey].items()), rootkey
    assert all(binding(n, item) for n, item in m['external_inputs'].items())
    for n, item in {**m['tools'], **m['opae_tools']}.items():
        assert sha(n) == item['sha256']
        if 'bytes' in item: assert Path(n).stat().st_size == item['bytes']
        if 'real' in item: assert str(Path(n).resolve()) == item['real']
    for prefix in ('setup','release','simulation','synthesis','fit','sta'):
        assert sha(m[prefix + '_result_file']) == m[prefix + '_result_sha256']
    return True

def save(path, body):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('xb') as stream: stream.write(body)

def export(path, name):
    size = path.stat().st_size
    assert size < 16 * 1024**2
    body = path.read_bytes(); assert len(body) == size
    out['exports'][name] = {'source': str(path), 'bytes': size,
                            'sha256': hashlib.sha256(body).hexdigest(),
                            'base64': base64.b64encode(body).decode()}
try:
 assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 assert (ROOT/'help02').is_dir() and not D.exists() and not P.exists() and not (ROOT/'asm01').exists()
 raw=subprocess.check_output(['tmux','save-buffer','-b',INPUT,'-']);assert len(raw)<2*1024**2 and hashlib.sha256(raw).hexdigest()==EXPECTED
 c=json.loads(gzip.decompress(raw));assert c['root']==str(ROOT) and c['scope']=='copy acceptedSTA for assembly source review only'
 S=Path(c['source_root']);m=c['inherited'];assert S==Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_sta01/base01')
 before,total=inventory(S);assert before==c['source_inventory'] and len(before)==4038 and total==1011925993 and preserve(m)
 active=[]
 for p in Path('/proc').iterdir():
  if not p.name.isdigit():continue
  try:
   exe=os.readlink(p/'exe')
   if Path(exe).name.startswith(('quartus_','qsys-','ahls','aoc','vsim','vlog')):active.append({'pid':int(p.name),'exe':exe})
  except (FileNotFoundError,ProcessLookupError,PermissionError):pass
 assert not active and shutil.disk_usage(S).free>12000000000
 decoded={}
 for n,b in c['receipts'].items():
  assert Path(n).name==n;r=base64.b64decode(b['base64'],validate=True);assert len(r)==b['bytes'] and hashlib.sha256(r).hexdigest()==b['sha256'];decoded[n]=r
 shutil.copytree(S,D,symlinks=True);P.mkdir();owned=True
 copied=copy.deepcopy(before);links=[]
 for n,b in copied.items():
  if b['kind']=='symlink' and b['resolved'].startswith(str(S)+'/'):
   prev=b['resolved'];b['resolved']=str(D)+prev[len(str(S)):];links.append({'path':n,'before':prev,'after':b['resolved'],'target':b['target']})
 assert len(links)==2 and inventory(D)==(copied,total)
 for n,b in decoded.items():save(P/'prerequisites'/n,b)
 manifest={'scope':'prepared acceptedSTA assembly basis only; no authority','source_root':str(S),'design_root':str(D),'source_inventory':before,'design_inventory':copied,'ordinary_file_bytes':total,'relative_symlinks':links,
  'source_sta_result_sha256':m['sta_result_sha256'],'interface_uuid':m['interface_uuid'],'afu_uuid':m['afu_uuid'],'source_physical_qdb_names':m['required_physical_qdb'],
  'runtime_role_basis':m['runtime_outputs'],'protected_relative':{str(Path(n).relative_to(Path(m['design_root']))):b for n,b in m['protected_snapshot_inputs'].items()},
  'inherited_preservation':{k:m[k] for k in ('original_fitted_root','original_fitted_inventory','original_mapped_root','original_mapped_inventory','original_setup_root','original_setup_inventory','release_root','original_release_inventory','external_inputs','archive_root','archive_inventory','tools','opae_tools')},
  'ready_for_build':False,'hardware_ready':False,'native_authority_issued':False}
 save(P/'prepared-copy03.json',(json.dumps(manifest,sort_keys=True,indent=2)+'\n').encode())
 assert inventory(S)==(before,total) and preserve(m)
 J=D/'build/syn/board/ia840f/syn_top';names=['ofs_pr_afu.qsf','ofs_pr_afu_sources.tcl','ofs_top.qpf','build_env_db.txt','ofs_partial_reconfig/gen_gbs.tcl','output_files/user_clock_freq.txt','ofs_partial_reconfig/user_clock_defs.tcl']
 for n in names:export(J/n,'project/'+n)
 export(P/'prepared-copy03.json','prepared-copy03.json')
 out.update(success=True,source_entries=4038,copy_entries=4038,ordinary_file_bytes=total,qdb_members=sum(n.startswith('build/syn/board/ia840f/syn_top/qdb/') for n in copied),
  source_preserved=True,predecessors_tools_preserved=True,relative_symlinks=links,prepared_sha256=sha(P/'prepared-copy03.json'))
except BaseException as exc:out['error']=repr(exc);out['traceback']=traceback.format_exc()
finally:
 if owned:save(P/'copy03-result.json',(json.dumps({k:v for k,v in out.items() if k!='exports'},indent=2)+'\n').encode())
 blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
 subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
 print(json.dumps({'success':out['success'],'assembly_started':False}),flush=True)
if not out['success']:raise SystemExit(1)
