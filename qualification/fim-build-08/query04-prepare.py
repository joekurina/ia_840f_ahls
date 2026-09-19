from pathlib import Path
import os,sys,json,hashlib,socket,subprocess,shutil,base64
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
b=Path('/home/uwb_student00/ahls/new_BSP');a=b/'qualification/fim-build-08/pcie-postfit-query-03';e=a.with_name('pcie-postfit-query-04')
def sha(p):
 h=hashlib.sha256()
 with open(p,'rb') as f:
  for v in iter(lambda:f.read(4194304),b''):h.update(v)
 return h.hexdigest()
def inv(p):return {str(x.relative_to(p)):os.readlink(x) if x.is_symlink() else sha(x) for x in p.rglob('*') if x.is_symlink() or x.is_file()}
def put(n,v):(e/n).write_text(json.dumps(v,indent=2,sort_keys=True))
def ret(s):return s.replace(str(a),str(e)).replace('query03','query04').replace('QUERY03','QUERY04')
r=json.loads((a/'candidate.json').read_text())
assert sha(a/'candidate.json')=='911bcf9cead7d2e7cd3e7c6c486a19633a07aa97070825a1fef1570dfd651428'
for p,h in r['callback_files'].items():assert sha(p)==h,p
for p,t in r['links'].items():assert os.readlink(p)==t,p
before=inv(b/'work_ia840f_fim_08'); donor=inv(a)
e.mkdir(exist_ok=False)
put('execution-preflight.json',{'work08':before,'query03':donor})
changes=[]
for n in ('scratch','pim'):
 subprocess.run(['cp','-a','--reflink=auto',str(a/n),str(e/n)],check=True,timeout=100)
 assert inv(a/n)==inv(e/n)
 for x in (e/n).rglob('*'):
  if x.is_symlink():
   old=os.readlink(x);new=old.replace(str(a),str(e))
   if old!=new:x.unlink();x.symlink_to(new);changes.append(str(x))
  elif x.is_file() and x.suffix in {'.tcl','.qsf','.qip','.ip','.qsys','.xml','.sdc','.json','.sh','.py','.txt','.ini'}:
   raw=x.read_bytes()
   if b'\0' not in raw:
    new=raw.replace(str(a).encode(),str(e).encode())
    if x.name=='ia840f_experimental_gate.py':new=new.replace(b'ia840f_query03_gate',b'ia840f_query04_gate')
    if new!=raw:x.write_bytes(new);changes.append(str(x))
for n in ('run-query.py','ia840f_query03_gate.py','ia840f_experimental_gate.py'):
 old=(a/n).read_text();new=ret(old);(e/ret(n)).write_text(new)
 assert new==ret(old)
old=(a/'query.tcl').read_text();assert old.count('set pins [get_cell_info -pins $c]')==1 and old.count('foreach_in_collection pin $pins')==1
new=old.replace('set pins [get_cell_info -pins $c]','set ia840f_query04_divider_pins [get_cell_info -pins $c]').replace('foreach_in_collection pin $pins','foreach_in_collection pin $ia840f_query04_divider_pins')
assert new.replace('ia840f_query04_divider_pins','pins')==old
(e/'query.tcl').write_text(new)
g=e/'scratch/ofs-common/tools/ofss_config'
(g/'ia840f_query04_gate.py').write_text((e/'ia840f_query04_gate.py').read_text())
assert (g/'ia840f_experimental_gate.py').read_bytes()==(e/'ia840f_experimental_gate.py').read_bytes()
r=json.loads(ret(json.dumps(r)))
for key in ('files','callback_files'):r[key]={p:sha(p) for p in r[key]}
r['links']={p:os.readlink(p) for p in r['links']}
put('candidate.json',r)
checks={}
for label,args,cwd in [('runner',['python3','-B',str(e/'run-query.py')],e),('dispatcher',['python3','-B',str(g/'ia840f_experimental_gate.py'),'quartus'],Path(r['cwd']))]:
 v=subprocess.run(args,cwd=cwd,capture_output=True,text=True);assert v.returncode!=0 and 'missing reviewed authorization' in v.stderr;checks[label]={'rc':v.returncode,'stderr':v.stderr}
assert not (e/'query.claim').exists() and not (e/'query.log').exists()
assert donor==inv(a) and before==inv(b/'work_ia840f_fim_08')
checks.update(query03_unchanged=True,work08_unchanged=True,complete_copy_verified=True,callback_snapshot_verified=True,normalized_two_reference_diff=True,mechanical_changes=changes,files=len(r['files']),callback_files=len(r['callback_files']),links=len(r['links']))
put('tests.json',checks)
for n in ('spec-review.md','quality-review.md'):shutil.copy2(a/n,e/n)
files={}
for n in ('query.tcl','run-query.py','ia840f_query04_gate.py','ia840f_experimental_gate.py','candidate.json','tests.json','execution-preflight.json','spec-review.md','quality-review.md'):
 raw=(e/n).read_bytes();files[n]={'sha256':sha(e/n),'size':len(raw),'base64':base64.b64encode(raw).decode()}
put('prepare-export.json',{'batch':'query04-prepare-01','files':files})
subprocess.run(['tmux','load-buffer','-b','query04_prepare_01',str(e/'prepare-export.json')],check=True)
print('PREPARED',sha(e/'prepare-export.json'),flush=True)
