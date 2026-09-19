
import pathlib, time, json, subprocess, datetime, os, hashlib, tarfile, re
E=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08')
D=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T025343Z-ecec9b')
D.mkdir()
W=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08/syn/board/ia840f/syn_top/output_files')
S={'pid':os.getpid(),'samples':[],'readiness':False,'DDR_sim':'SKIPPED'}
start=time.monotonic()
while True:
    log=(E/'run/native.log')
    if not log.exists(): log=E/'native.log'
    txt=log.read_text(errors='replace') if log.exists() else ''
    ps=subprocess.check_output(['ps','-eo','pid,ppid,stat,etime,time,args'],text=True)
    procs=[p for p in ps.splitlines() if ('quartus' in p or '108156' in p or '108158' in p or '108175' in p) and 'python' not in p]
    hits=[{'line':i,'text':l} for i,l in enumerate(txt.splitlines(),1) if re.search(r'^Error|21650|21636|125091|gate.*reject|Synthesis was|Fitter was',l,re.I)]
    S['samples'].append({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'log_path':str(log),'bytes':len(txt.encode()),'hits':hits,'tail':txt.splitlines()[-12:],'processes':procs})
    (D/'snapshot.json').write_text(json.dumps(S,indent=2))
    print(S['samples'][-1]['utc'],len(txt),len(hits),flush=True)
    if time.monotonic()-start>=240: break
    time.sleep(15)
paths=[E/'run/status.json',log]+sorted(W.glob('*.rpt'))+sorted(W.glob('*.summary'))
manifest=[]
for i,p in enumerate(paths):
    if p.is_file():
        data=p.read_bytes(); name=f'{i:02d}-'+p.name
        (D/name).write_bytes(data)
        manifest.append({'source':str(p),'name':name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()})
(D/'receipt.json').write_text(json.dumps(manifest,indent=2))
with tarfile.open(str(D)+'.tar.gz','w:gz') as t:
    for p in D.iterdir(): t.add(p,arcname=p.name)
print('DONE',str(D),flush=True)
