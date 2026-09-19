
import pathlib, time, json, subprocess, datetime, os, hashlib, tarfile, re
E=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08')
D=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/monitor-20260919T031118Z-89da00')
D.mkdir()
W=pathlib.Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08/syn/board/ia840f/syn_top/output_files')
S={'pid':os.getpid(),'samples':[],'readiness':False,'DDR_sim':'SKIPPED'}
S['hostname']=subprocess.check_output(['hostname'],text=True).strip(); S['uid']=os.getuid()
assert S['hostname']=='Agilex7Workstation' and S['uid']==1000
start=time.monotonic()
while True:
    log=(E/'run/native.log')
    if not log.exists(): log=E/'native.log'
    txt=log.read_text(errors='replace') if log.exists() else ''
    ps=subprocess.check_output(['ps','-eo','pid,ppid,stat,etime,time,args'],text=True)
    procs=[p for p in ps.splitlines() if ('quartus' in p or '108156' in p or '108158' in p or '108175' in p) and 'python' not in p]
    hits=[{'line':i,'text':l} for i,l in enumerate(txt.splitlines(),1) if re.search(r'^Error|21650|21636|125091|gate.*reject|Synthesis was|Fitter was',l,re.I)]
    S['samples'].append({'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'log_path':str(log),'status':json.loads((E/'run/status.json').read_text()),'bytes':len(txt.encode()),'hits':hits,'tail':txt.splitlines()[-12:],'processes':procs})
    (D/'snapshot.json').write_text(json.dumps(S,indent=2))
    print(S['samples'][-1]['utc'],len(txt),len(hits),flush=True)
    if re.search(r'^Error|IA840F_GATE_REJECTED|Error \(125091\)',txt,re.M): break
    if re.search(r'Fitter was successful|Routing.*ended|Timing Analyzer was successful|Fitter placement preparation operations complete|Fitter placement operations beginning', txt, re.I): break
    if time.monotonic()-start>=210: break
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
