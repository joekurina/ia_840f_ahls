import hashlib,json,os,sys
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-23/cpa-work21-46')
P=E/'scratch/syn/board/ia840f/syn_top'
def sha(p):
 h=hashlib.sha256()
 with open(p,'rb') as f:
  for v in iter(lambda:f.read(4194304),b''):h.update(v)
 return h.hexdigest()
def identity(pid):
 p=Path('/proc')/str(pid)
 stat=(p/'stat').read_text().rsplit(')',1)[1].split()
 return {'pid':int(pid),'ppid':int(stat[1]),'start_ticks':stat[19],
         'exe':str((p/'exe').resolve()),'argv':(p/'cmdline').read_bytes().rstrip(b'\0').decode().split('\0'),'cwd':str((p/'cwd').resolve())}
def check_ancestry(r, parent, claim, lookup=identity):
 live=lookup(claim['pid'])
 if live!=claim:raise ValueError('CPA46_REJECT stale runner claim')
 if any(live[k]!=r['runner'][k] for k in ('exe','argv','cwd')):raise ValueError('CPA46_REJECT runner context')
 seen=set();pid=parent
 while pid>1 and pid not in seen:
  seen.add(pid)
  if pid==claim['pid']:return
  pid=lookup(pid)['ppid']
 raise ValueError('CPA46_REJECT unrelated ancestry')
def validate(runtime=False):
 r=json.loads((E/'candidate.json').read_text())
 a=E/'authorization.json'
 if not a.is_file():raise ValueError('CPA46_REJECT missing reviewed authorization')
 auth=json.loads(a.read_text())
 expected={'approved':True,'candidate_sha256':sha(E/'candidate.json'),'permission':'exact-offline-cpa46'}
 if auth!=expected:raise ValueError('CPA46_REJECT authorization binding')
 if r['ready_for_build'] is not False or r['part']!='AGFB027R25A2E2V':raise ValueError('CPA46_REJECT target/readiness')
 for filename,digest in r['callback_files' if runtime else 'files'].items():
  if sha(filename)!=digest:raise ValueError('CPA46_REJECT source binding '+filename)
 for filename,target in r['links'].items():
  if os.readlink(filename)!=target:raise ValueError('CPA46_REJECT link binding '+filename)
 if runtime:
  check_ancestry(r,os.getppid(),json.loads((E/'query.claim').read_text()))
  proc=Path('/proc')/str(os.getppid())
  exe=str((proc/'exe').resolve());argv=(proc/'cmdline').read_bytes().rstrip(b'\0').decode().split('\0')
  if exe!=r['executable'] or argv!=r['runtime_argv'] or (proc/'cwd').resolve()!=P:raise ValueError('CPA46_REJECT runtime context')
 return r
if __name__=='__main__':
 try:validate(runtime=True)
 except Exception as exc:print(exc,file=sys.stderr);sys.exit(1)
