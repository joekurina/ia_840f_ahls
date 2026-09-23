import os,socket,json,hashlib,subprocess
from pathlib import Path
from datetime import datetime,timezone
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
R=Path('/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_caps01/asm01')
s=json.loads((R/'status.json').read_text());a=json.loads((R/'authority.json').read_text())
assert s['run']=='caps01-asm01' and a['scope']=='persona-asm-only' and a['ready_for_build'] is False
r=s['commands'][-1];out={'at':datetime.now(timezone.utc).isoformat(),'run':s['run'],'complete':s['complete'],'command':r,'native':None,'hardware_access':False,'resource_preflight':s['resource_preflight']}
if not s['complete']:
 p=Path('/proc')/str(r['pid']);st=(p/'stat').read_text().rsplit(')',1)[1].split();exe=os.readlink(p/'exe');cwd=os.readlink(p/'cwd');args=(p/'cmdline').read_bytes().decode().rstrip(chr(0)).split(chr(0))
 assert st[19]==r['start_ticks'] and {'exe':exe,'cwd':cwd,'argv':args[1:]} in a['contexts']
 assert hashlib.sha256(Path(exe).read_bytes()).hexdigest()==a['runtime_hashes'][exe]
 out['native']={'pid':r['pid'],'start_ticks':st[19],'state':st[0],'exe':exe,'cwd':cwd,'argv':args,'cpu_ticks':int(st[11])+int(st[12]),'affinity':sorted(os.sched_getaffinity(r['pid'])),'as_limit':[x for x in (p/'limits').read_text().splitlines() if x.startswith('Max address space')]}
q=Path(s['project'])/'ofs_pr_afu.qsf';assert hashlib.sha256(q.read_bytes()).hexdigest()==s['input_hashes'][str(q)]
out['parallel_assignment']=[l for l in q.read_text().splitlines() if l.startswith('set_global_assignment -name NUM_PARALLEL_PROCESSORS')]
out['gate_rejections']=(R/'gate-rejections.jsonl').read_text() if (R/'gate-rejections.jsonl').exists() else None
f=R/'assembly.log'
with f.open('rb') as fd:fd.seek(max(0,f.stat().st_size-8192));out['log_tail']=fd.read(8192).decode(errors='replace')
b=json.dumps(out,indent=2).encode();buf='ia840f_persona_caps01_asm_snapshot01'
subprocess.run(['tmux','load-buffer','-b',buf,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',buf+'_sha256',hashlib.sha256(b).hexdigest()],check=True)
