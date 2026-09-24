import json,os,re,subprocess,sys
from pathlib import Path
binary=Path(sys.argv[1]);config=Path(sys.argv[2]);negative_dir=Path(sys.argv[3]);output=Path(sys.argv[4])
if output.exists():raise RuntimeError("exclusive result required")
def require(ok,why):
    if not ok:raise RuntimeError(why)
cases=[(name,category,config) for name,category in [
    ("valid","valid"),("read-fail","pre-detect"),("calloc-1","pre-detect"),
    ("calloc-2","pre-detect"),("null-path","pre-detect"),("relative-path","pre-detect"),
    ("ase","pre-detect"),("implicit","pre-detect"),("already-initialized","pre-detect"),
    ("no-device","detected-none"),("wrong-device","detected-none"),("scan-fail","detected-none"),
    ("load-fail","load-fail"),("symbol-fail","load-fail"),("configure-fail","load-fail"),
    ("init-fail","init-fail"),("repeat","repeat"),("init-fail-repeat","init-fail-repeat")]]
cases += [("reject-"+p.stem,"pre-detect",p) for p in sorted(negative_dir.glob('*.json')) if p.name not in ['candidate.json','results.json']]
records=[]
try:
    for name,category,path in cases:
        argv=[str(binary),name,str(path)]
        env={'PATH':'/usr/bin:/bin','LANG':'C','LC_ALL':'C','HOME':str(output.parent)}
        p=subprocess.run(argv,env=env,capture_output=True,text=True,timeout=5)
        row={'name':name,'category':category,'argv':argv,'environment':env,'rc':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
        records.append(row)
        require(p.returncode==0,'native '+name)
        require('runtime error:' not in p.stderr.lower() and 'assertion' not in p.stderr.lower(),'diagnostic '+name)
        lines=[line for line in p.stdout.splitlines() if line.startswith('RESULT ')]
        require(len(lines)==1,'result line '+name)
        f={k:int(v) for k,v in re.findall(r'(\w+)=(-?\d+)',lines[0])};row['observed']=f
        require(f['discovers']==0,'config discovery '+name)
        require(f['finis']==0,'unexpected finalization '+name)
        if category=='pre-detect':
            require(f['rc']!=0 and f['scans']==f['file_reads']==f['loads']==f['configs']==f['inits']==0,'pre-detect barrier '+name)
        elif category=='detected-none':
            require(f['rc']!=0 and f['scans']==1 and f['loads']==f['inits']==0 and f['initialized']==0,'no adapter '+name)
        elif category=='load-fail':
            require(f['rc']!=0 and f['loads']>0 and f['inits']==0 and f['initialized']==0,'loader failure '+name)
        elif category in ['init-fail','init-fail-repeat']:
            require(f['rc']!=0 and f['inits']==1 and f['initialized']==0,'initializer failure '+name)
        else:
            require(f['rc']==0 and f['scans']==1 and f['file_reads']==4 and f['configs']==f['inits']==1 and f['initialized']==1,'positive '+name)
        if category in ['repeat','init-fail-repeat']:
            require(f['rc2']!=0 and all(f[k]==f['first_'+k] for k in ['reads','scans','loads','inits']),'retry '+name)
        row['passed']=True
    require(len(records)==len(cases) and len({r['name'] for r in records})==len(records),'case completeness')
finally:
    output.write_text(json.dumps({'inert_only':True,'real_backend_loaded':False,'hardware_access':False,'records':records},indent=2)+'\n')
print('FPGA_TEST_STRICT_INIT_PASS cases='+str(len(records))+' real_backend_loaded=false hardware_access=false')
