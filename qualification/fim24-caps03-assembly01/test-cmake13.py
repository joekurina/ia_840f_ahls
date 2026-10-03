"""Exercise exact CMake configure/help/dry-run/refusal; never run Quartus."""
import base64
import datetime
import gzip
import hashlib
import json
import os
import signal
import socket
import subprocess
import sys
from pathlib import Path

ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01')
P=ROOT/'control07';J=ROOT/'base01/build/syn/board/ia840f/syn_top';R=ROOT/'asm01'
O=P/'inert-cmake13';BATCH=sys.argv[1]
out={'batch':BATCH,'scope':'CMake-only configure/help/make dry-run/refusal; no vendor tool',
     'success':False,'vendor_tool_executed':False,'hardware_access':False,'exports':{}}

def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def run(argv):
    child=subprocess.Popen(argv,cwd=P,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,start_new_session=True)
    try:
        data,_=child.communicate(timeout=30)
    except BaseException:
        # These commands are CMake/make only; no native query is admitted or invoked.
        os.killpg(child.pid,signal.SIGTERM)
        try: child.communicate(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(child.pid,signal.SIGKILL);child.communicate(timeout=5)
        raise
    return {'argv':argv,'rc':child.returncode,'stdout':data.decode(errors='replace')}

try:
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert not O.exists() and not R.exists() and not (P/'asm-inputs.admitted.json').exists()
    m=json.loads((P/'asm-inputs.draft12.json').read_text())
    assert sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256']
    O.mkdir();rows=[]
    configure=['/usr/bin/cmake','-S',str(P/'runtime'),'-B',str(O/'build'),'-G','Unix Makefiles',
               '-DCMAKE_MAKE_PROGRAM=/usr/bin/make','-DPERSONA_PROJECT='+str(J),
               '-DASSEMBLY_ROOT='+str(R),'-DQUARTUS_ROOT=/opt/altera/26.1.1/quartus']
    rows.append(run(configure));assert rows[-1]['rc']==0
    rows.append(run(['/usr/bin/cmake','--build',str(O/'build'),'--target','help']));assert rows[-1]['rc']==0 and 'assembly' in rows[-1]['stdout']
    rows.append(run(['/usr/bin/cmake','--build',str(O/'build'),'--target','assembly','--','-n']));assert rows[-1]['rc']==0
    assert '/opt/altera/26.1.1/quartus/bin/quartus_asm ofs_top -c ofs_pr_afu' in rows[-1]['stdout']
    bad=[arg.replace(str(O/'build'),str(O/'bad-build')) for arg in configure]
    bad=[arg if not arg.startswith('-DASSEMBLY_ROOT=') else '-DASSEMBLY_ROOT='+str(ROOT/'asm-wrong') for arg in bad]
    rows.append(run(bad));assert rows[-1]['rc']!=0 and 'exact assembler operation root' in rows[-1]['stdout']
    assert not R.exists() and not (P/'asm-inputs.admitted.json').exists()
    assert sha(P/'runtime/CMakeLists.txt')==m['cmake_sha256']
    for i,row in enumerate(rows):
        path=O/('case-%d.log'%i)
        with path.open('x') as stream:stream.write(row['stdout'])
        body=path.read_bytes()
        out['exports'][path.name]={'source':str(path),'bytes':len(body),'sha256':hashlib.sha256(body).hexdigest(),'base64':base64.b64encode(body).decode()}
    out.update(success=True,case_count=len(rows),cases=rows,cmake_sha256=m['cmake_sha256'],
               expected_native_argv=m['contexts'][0]['argv'],query_operation_absent=True)
except BaseException as exc:
    out['error']=repr(exc);out['traceback']=__import__('traceback').format_exc()
finally:
    blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True)
    subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
    print(json.dumps({'success':out['success'],'vendor_tool_executed':False}),flush=True)
if not out['success']:raise SystemExit(1)
