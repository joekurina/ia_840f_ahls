import os,json,hashlib,socket,subprocess,time
from pathlib import Path
assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
os.umask(0o077)
old=Path('/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch-monitored-01')
r=old.with_name('scratch-monitored-refresh-02'); r.mkdir()
inv=json.loads((old/'invocation.json').read_text()); names=list(json.loads((old/'after.json').read_text()))
for n in ['bwbmc/'+n for n in names]+['mailbox_migration.qpf','mailbox_migration.qsf']:
 p=r/n; p.parent.mkdir(parents=True,exist_ok=True); p.write_bytes((old/n).read_bytes())
(r/'home').mkdir(); (r/'tmp').mkdir()
def inventory(base):
 return {str(p.relative_to(base)):hashlib.sha256(p.read_bytes()).hexdigest() for p in base.rglob('*') if p.is_file()}
def save(n,v):
 with (r/n).open('x') as f: json.dump(v,f,indent=2)
before=inventory(r); save('before.json',before)
env={k:v.replace(str(old),str(r)) for k,v in inv['env'].items()}
tcl='load_system bmc_spi_sub.qsys; if {![load_component sdm_mailbox]} {error "Cannot load sdm_mailbox"}; save_component; puts [reload_component_footprint sdm_mailbox]; puts [validate_component_footprint sdm_mailbox]; save_system bmc_spi_sub.qsys'
argv=['/opt/altera/26.1.1/qsys/bin/qsys-script','--quartus-project='+str(r/'mailbox_migration.qpf'),'--rev=mailbox_migration','--package-version=26.1','--search-path='+str(r/'bwbmc/ip/arbiter')+','+str(r/'bwbmc/ip/irq_generator')+',$','--cmd='+tcl]
save('invocation.json',{'argv':argv,'env':env,'cwd':str(r/'bwbmc'),'started':time.time(),'tool_sha256':hashlib.sha256(Path(argv[0]).read_bytes()).hexdigest()})
print('REFRESH_START',flush=True)
with (r/'refresh.log').open('xb') as f:
 rc=subprocess.run(argv,cwd=str(r/'bwbmc'),env=env,stdout=f,stderr=subprocess.STDOUT,timeout=1800).returncode
after=inventory(r); save('after.json',after)
result={'returncode':rc,'changed_inputs':[n for n in before if before[n]!=after.get(n)],'ready_for_build':False,'finished':time.time()}; save('result.json',result)
print(json.dumps(result),flush=True); print((r/'refresh.log').read_text(errors='replace')[-18000:],flush=True)
