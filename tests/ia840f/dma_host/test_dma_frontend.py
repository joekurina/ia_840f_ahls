import os,sys,subprocess,json,hashlib,re
from pathlib import Path
exe=Path(sys.argv[1]).resolve();out=Path(sys.argv[2]).resolve();out.mkdir(exist_ok=False)
base=[str(exe),'--roundtrip-qualified-memory-afu','0000:4f:00.2','0']
cases=[('bank0',{},base,0),('bank1',{'MEMORY_BANK':'1'},base[:-1]+['1'],0)]
for n in range(1,52):
 cases.append((f'api-failure-{n}',{'MEMORY_FAIL_AT':str(n)},base,77 if n in (34,35,44,45) else 1))
for s,rc in [('zero',1),('multiple',1),('enum_partial_error',1),('bad_iova',1),('alias_iova',1),
 ('readback_mismatch',1),('sticky_error',77),('stale_count',77),('missing_visibility',77),
 ('payload_corrupt',77),('guard_corrupt',77),('source_corrupt',77)]:
 cases.append((s,{'MEMORY_CASE':s},base,rc))
for word in range(7):cases.append((f'identity-capability-{word}',{'MEMORY_MUTATE_WORD':str(word)},base,1))
for s,args in [('bad-bank',base[:-1]+['2']),('bad-bdf',base[:2]+['nonsense','0']),('missing-option',[str(exe)]),('old-option',[str(exe),'--inspect-qualified-memory-afu','0000:4f:00.2'])]:
 cases.append((s,{},args,2))
results=[]
for name,changes,argv,expected in cases:
 env={k:v for k,v in os.environ.items() if not k.startswith('MEMORY_')};env.update(changes)
 p=subprocess.run(argv,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=10)
 log=out/(name+'.log');log.write_bytes(p.stdout);text=p.stdout.decode(errors='replace')
 row={'case':name,'argv':argv,'changes':changes,'rc':p.returncode,'expected':expected,
      'log':log.name,'bytes':len(p.stdout),'sha256':hashlib.sha256(p.stdout).hexdigest()}
 row['pass']=p.returncode==expected and 'runtime error:' not in text and 'AddressSanitizer' not in text
 if expected==77:row['pass'] &= 'INERT_HOLD' in text and 'releases=0' in text and 'held=1' in text
 if expected==0:row['pass'] &= 'DMA roundtrip PASSED' in text and 'releases=2 go=2 held=0' in text
 if expected==2:row['pass'] &= 'API ' not in text
 results.append(row)
 if not row['pass']:print(name,p.returncode,'expected',expected,text);break
receipt={'inert':True,'hardware_access':False,'elf_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),
         'planned':len(cases),'executed':len(results),'passed':sum(r['pass'] for r in results),'cases':results}
(out/'result.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:receipt[k] for k in ['planned','executed','passed','inert','hardware_access']}))
raise SystemExit(0 if len(results)==len(cases) and all(r['pass'] for r in results) else 1)
