import os,json,hashlib,socket,subprocess,time,re
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
os.umask(0o077)
old=Path('/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch-monitored-parent-03')
r=old.with_name('scratch-monitored-generation-04'); r.mkdir()
inv=json.loads((old/'invocation.json').read_text())
names=[n for n in json.loads((old/'before.json').read_text()) if n.startswith('bwbmc/') or n in ('mailbox_migration.qpf','mailbox_migration.qsf')]
for n in names:
 p=r/n; p.parent.mkdir(parents=True,exist_ok=True); p.write_bytes((old/n).read_bytes())
(r/'home').mkdir(); (r/'tmp').mkdir()
def save(n,v):
 with (r/n).open('x') as f: json.dump(v,f,indent=2)
def inventory():
 return {str(p.relative_to(r)):{'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in r.rglob('*') if p.is_file()}
save('before.json',inventory())
env={k:v.replace(str(old),str(r)) for k,v in inv['env'].items()}
results=[]
for label,system in [('leaf','ip/bmc_spi_sub/sdm_mailbox.ip'),('child','bmc_spi_sub.qsys'),('parent','bw_840_support.qsys')]:
 argv=['/opt/altera/26.1.1/qsys/bin/qsys-generate',system,'--synthesis=VERILOG','--simulation=VERILOG','--simulator=MODELSIM','--quartus-project='+str(r/'mailbox_migration.qpf'),'--rev=mailbox_migration','--part=AGFB027R25A2E2V','--search-path='+str(r/'bwbmc/ip/arbiter')+','+str(r/'bwbmc/ip/irq_generator')+',$']
 save(label+'-invocation.json',{'argv':argv,'env':env,'cwd':str(r/'bwbmc'),'started':time.time(),'tool_sha256':hashlib.sha256(Path(argv[0]).read_bytes()).hexdigest()})
 print('GENERATE_START',label,flush=True)
 try:
  with (r/(label+'.log')).open('xb') as f: rc=subprocess.run(argv,cwd=str(r/'bwbmc'),env=env,stdout=f,stderr=subprocess.STDOUT,timeout=1800).returncode
  error=None
 except Exception as e: rc=None; error=repr(e)
 log=(r/(label+'.log')).read_text(errors='replace')
 result={'stage':label,'returncode':rc,'exception':error,'errors':[line for line in log.splitlines() if re.search(r'\bError:',line)],'finished':time.time(),'ready_for_build':False}
 save(label+'-result.json',result); results.append(result); print(json.dumps(result),flush=True)
 if error: break
save('after.json',inventory()); save('result.json',{'stages':results,'ready_for_build':False}); print('BMC_GENERATION_EXPERIMENT_FINISHED',flush=True)
