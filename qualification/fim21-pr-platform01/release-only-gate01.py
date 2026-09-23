import os,sys,json,hashlib
from pathlib import Path
R=Path('/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/export01')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def proc(pid):
 p=Path('/proc')/str(pid);s=(p/'stat').read_text().rsplit(')',1)[1].split()
 return {'pid':pid,'ppid':int(s[1]),'start_ticks':s[19],'exe':os.readlink(p/'exe'),'cwd':os.readlink(p/'cwd'),'argv':(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0')}
def check():
 assert __debug__ and sys.argv[1:]==['quartus']
 c=json.loads((R/'authority.json').read_text());assert c['ready_for_build'] is False and c['scope']=='release-only'
 assert os.environ.get('OPAE_PLATFORM_GEN')=='1' and os.environ.get('QUARTUS_ROOTDIR_OVERRIDE')=='/opt/altera/25.1/quartus'
 p=proc(os.getppid());key={'exe':p['exe'],'cwd':p['cwd'],'argv':p['argv'][1:]}
 assert key in c['contexts'],('unrecorded native context',key)
 assert sha(Path(p['exe']))==c['runtime_hashes'][p['exe']]
 r=c['runner'];found=False;ancestor=p
 for i in range(40):
  if ancestor['pid']==r['pid']:
   assert all(ancestor[k]==r[k] for k in ('pid','start_ticks','exe','cwd','argv'));found=True;break
  if ancestor['ppid']<=1:break
  ancestor=proc(ancestor['ppid'])
 assert found,'native command not owned by issued runner'
 for path,h in c['critical_inputs'].items():assert sha(Path(path))==h,('critical input changed',path)
 q=Path(c['project'])/'ofs_pr_afu.qsf';s=q.read_text()
 for line in ('set_global_assignment -name FAMILY "Agilex 7"','set_global_assignment -name DEVICE AGFB027R25A2E2V','set_global_assignment -name TOP_LEVEL_ENTITY top','set_global_assignment -name REVISION_TYPE PR_IMPL'):
  assert line in s,('project identity',line)
 out={'accepted':True,'parent':p};fd=os.open(R/'gate-events.jsonl',os.O_CREAT|os.O_APPEND|os.O_WRONLY,0o600);os.write(fd,(json.dumps(out)+'\n').encode());os.close(fd)
try:check()
except Exception as e:
 out={'error':repr(e)}
 try:out['parent']=proc(os.getppid())
 except Exception:pass
 fd=os.open(R/'gate-rejections.jsonl',os.O_CREAT|os.O_APPEND|os.O_WRONLY,0o600);os.write(fd,(json.dumps(out)+'\n').encode());os.close(fd)
 print('IA840F_GATE_REJECTED: '+repr(out),file=sys.stderr);sys.exit(1)
