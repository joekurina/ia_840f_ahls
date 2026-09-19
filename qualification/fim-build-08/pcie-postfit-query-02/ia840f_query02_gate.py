import hashlib,json,os,sys
from pathlib import Path
E=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-02')
P=E/'scratch/syn/board/ia840f/syn_top'
def sha(p):
 h=hashlib.sha256()
 with open(p,'rb') as f:
  for v in iter(lambda:f.read(4194304),b''):h.update(v)
 return h.hexdigest()
def validate(runtime=False):
 r=json.loads((E/'candidate.json').read_text())
 a=E/'authorization.json'
 if not a.is_file():raise ValueError('QUERY02_REJECT missing reviewed authorization')
 auth=json.loads(a.read_text())
 if auth!={'approved':True,'candidate_sha256':sha(E/'candidate.json'),'permission':'exact-read-only-postfit-query02'}:raise ValueError('QUERY02_REJECT authorization binding')
 if r['ready_for_build'] is not False or r['part']!='AGFB027R25A2E2V':raise ValueError('QUERY02_REJECT target/readiness')
 for filename,digest in r['callback_files' if runtime else 'files'].items():
  if sha(filename)!=digest:raise ValueError('QUERY02_REJECT source binding '+filename)
 for filename,target in r['links'].items():
  if os.readlink(filename)!=target:raise ValueError('QUERY02_REJECT link binding '+filename)
 if runtime:
  proc=Path('/proc')/str(os.getppid())
  exe=str((proc/'exe').resolve());argv=(proc/'cmdline').read_bytes().rstrip(b'\0').decode().split('\0')
  if exe!=r['executable'] or argv!=r['runtime_argv'] or (proc/'cwd').resolve()!=P:raise ValueError('QUERY02_REJECT runtime context')
 return r
if __name__=='__main__':
 try:validate(runtime=True)
 except Exception as exc:print(exc,file=sys.stderr);sys.exit(1)
