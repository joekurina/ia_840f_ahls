from pathlib import Path
import subprocess,os,json,time,hashlib
b=Path('/home/uwb_student00/ahls/new_BSP');c=b/'ofs-agx7-pcie-attach';r=b/'qualification/ipgen-04'
assert os.environ.get('TMUX')
assert hashlib.sha256((c/'syn/board/ia840f/setup/experimental-authorization.json').read_bytes()).hexdigest()==json.loads((r/'authorization-issued.json').read_text())['sha256']
env=os.environ.copy();env.update({'COPY_WORK':'1','OFS_ROOTDIR':str(c),'OFS_PLATFORM_AFU_BBB':str(b/'ofs-platform-afu-bbb'),'PYTHONDONTWRITEBYTECODE':'1'})
cmd=['./ofs-common/scripts/common/syn/build_top.sh','--stage=setup','-p','--ofss','nodefault,'+str(c/'syn/board/ia840f/config/ia840f.ofss'),'ia840f',str(b/'work_ia840f_ipgen_04')]
receipt={'argv':cmd,'cwd':str(c),'started_unix':time.time(),'environment':{k:env.get(k) for k in ['COPY_WORK','OFS_ROOTDIR','OFS_PLATFORM_AFU_BBB','QUARTUS_ROOTDIR_OVERRIDE','PATH','LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER']}}
for suffix in ('invocation.json','full.log','result.json'):
 assert not (r/('setup-'+suffix)).exists(), 'Stage already used'
with (r/'setup-stage.claim').open('x') as f:f.write('reserved\n')
with (r/'setup-invocation.json').open('x') as f:json.dump(receipt,f,indent=2)
print('SETUP04_STARTED',flush=True)
with (r/'setup-full.log').open('x') as f:p=subprocess.run(cmd,cwd=c,env=env,stdout=f,stderr=subprocess.STDOUT)
receipt.update({'returncode':p.returncode,'finished_unix':time.time()})
with (r/'setup-result.json').open('x') as f:json.dump(receipt,f,indent=2)
print('SETUP04_COMPLETE_EXIT',p.returncode,flush=True)
raise SystemExit(p.returncode)
