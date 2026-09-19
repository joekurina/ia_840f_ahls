from pathlib import Path
import subprocess,os,json,time,hashlib
b=Path('/home/uwb_student00/ahls/new_BSP');c=b/'ofs-agx7-pcie-attach';r=b/'qualification/ipgen-03'
assert hashlib.sha256((c/'syn/board/ia840f/setup/experimental-authorization.json').read_bytes()).hexdigest()=='a19998d51fa0b7bf5e2d5dfac99e50d16f28f85fd3cdbc569a707cb2401ff7f0'
env=os.environ.copy();env.update({'COPY_WORK':'1','OFS_ROOTDIR':str(c),'OFS_PLATFORM_AFU_BBB':str(b/'ofs-platform-afu-bbb'),'PYTHONDONTWRITEBYTECODE':'1'})
cmd=['./ofs-common/scripts/common/syn/build_top.sh','--stage=setup','-p','--ofss','nodefault,'+str(c/'syn/board/ia840f/config/ia840f.ofss'),'ia840f',str(b/'work_ia840f_ipgen_03')]
receipt={'argv':cmd,'cwd':str(c),'started_unix':time.time(),'environment':{k:env.get(k) for k in ['COPY_WORK','OFS_ROOTDIR','OFS_PLATFORM_AFU_BBB','QUARTUS_ROOTDIR_OVERRIDE','PATH','LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER']}}
(r/'setup-invocation.json').write_text(json.dumps(receipt,indent=2));print('SETUP03_STARTED',flush=True)
with (r/'setup-full.log').open('x') as f:p=subprocess.run(cmd,cwd=c,env=env,stdout=f,stderr=subprocess.STDOUT)
receipt.update({'returncode':p.returncode,'finished_unix':time.time()});(r/'setup-result.json').write_text(json.dumps(receipt,indent=2));print('SETUP03_COMPLETE_EXIT',p.returncode,flush=True)
