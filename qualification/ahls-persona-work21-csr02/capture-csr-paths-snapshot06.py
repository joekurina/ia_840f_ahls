ROOT='/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_csr02/csr-paths06'
ARGS=['-t', '/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_csr02/csr-paths06/csr-paths06.tcl']
TOOLSHA='979845fbc25bad3fb1aa72d26fa5a18337834a3a31d7113fef9328d40f21c91b'
CPUS=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]
QSFHASH='fd6cd702aac41aee02c56fd3d203b9471a9000665c65b86553c1033f4c2c6cd4'
BUFFER='ia840f_persona_csr02_csr_paths_snapshot06'
import os,json,hashlib,subprocess,socket
from pathlib import Path
from datetime import datetime,timezone
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path(ROOT);s=json.loads((R/'status.json').read_bytes());assert s['run']=='csr02-csr-paths06'
out={'timestamp':datetime.now(timezone.utc).isoformat(),'status':{k:v for k,v in s.items() if k not in ('original_setup_inventory','input_hashes','files','qdb_outputs')},'native':None,'hardware_access':False}
assert len(s['commands'])==1
c=s['commands'][0]
if not s['complete']:
 p=Path('/proc')/str(c['pid']);a=(p/'stat').read_text().rsplit(')',1)[1].split();exe=os.readlink(p/'exe');argv=(p/'cmdline').read_bytes().decode().rstrip(chr(0)).split(chr(0));cwd=os.readlink(p/'cwd')
 assert a[19]==c['start_ticks'] and exe=='/opt/altera/25.1/quartus/linux64/quartus_sta' and argv[1:]==ARGS and Path(cwd).resolve()==Path(s['project']).resolve()
 assert hashlib.sha256(Path(exe).read_bytes()).hexdigest()==TOOLSHA
 limits=(p/'limits').read_text();line=next(l for l in limits.splitlines() if l.startswith('Max address space'));assert line.split()[-3:-1]==[str(64*1024**3)]*2
 affinity=sorted(os.sched_getaffinity(c['pid']));assert affinity==CPUS
 out['native']={'pid':c['pid'],'start_ticks':a[19],'exe':exe,'argv':argv,'cwd':cwd,'cpu_ticks':int(a[11])+int(a[12]),'affinity':affinity,'address_space_limit':line}
q=(R/'persona/build/syn/board/ia840f/syn_top/ofs_pr_afu.qsf').read_bytes();assert hashlib.sha256(q).hexdigest()==QSFHASH
out['gate_accepted_count']=len((R/'gate-events.jsonl').read_text().splitlines()) if (R/'gate-events.jsonl').exists() else 0
assert not (R/'gate-rejections.jsonl').exists()
out['log_tail']=(R/'timing.log').read_text(errors='replace')[-7000:]
b=json.dumps(out,sort_keys=True).encode();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',hashlib.sha256(b).hexdigest()],check=True)
