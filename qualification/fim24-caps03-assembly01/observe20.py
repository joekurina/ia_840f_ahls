"""Finite ordinary-process/log observation of the one admitted assembly."""
import datetime,gzip,hashlib,json,os,subprocess,sys,time,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01');R=ROOT/'asm01';J=ROOT/'base01/build/syn/board/ia840f/syn_top';BATCH=sys.argv[1]
out={'batch':BATCH,'scope':'finite ordinary-file/process observation only; no vendor/hardware operation','success':False,'hardware_access':False,'samples':[]}
try:
    assert os.environ.get('TMUX')
    for index in range(3):
        row={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'operation_exists':R.exists(),'native':[]}
        if (R/'status.json').is_file():
            data=(R/'status.json').read_bytes();assert len(data)<4*1024**2
            status=json.loads(data);row['status']={k:status.get(k) for k in ['started','ended','complete','execution_clean','error','commands','runner']}
        for p in Path('/proc').iterdir():
            if not p.name.isdigit():continue
            try:
                exe=os.readlink(p/'exe');cwd=os.readlink(p/'cwd');argv=(p/'cmdline').read_bytes().decode().rstrip('\0').split('\0')
                if exe=='/opt/altera/26.1.1/quartus/linux64/quartus_asm' and cwd==str(J):
                    fields=(p/'stat').read_text().rsplit(')',1)[1].split()
                    row['native'].append({'pid':int(p.name),'start_ticks':fields[19],'state':fields[0],'ppid':int(fields[1]),'cpu_ticks':int(fields[11])+int(fields[12]),'exe':exe,'exe_sha256':hashlib.sha256(Path(exe).read_bytes()).hexdigest(),'cwd':cwd,'argv':argv})
            except (FileNotFoundError,ProcessLookupError,PermissionError):pass
        log=R/'assembly.log'
        if log.is_file():
            with log.open('rb') as stream:stream.seek(max(0,log.stat().st_size-12000));data=stream.read(12000)
            row['log_bytes']=log.stat().st_size;row['log_tail_sha256']=hashlib.sha256(data).hexdigest();row['log_tail']=data.decode(errors='replace')
        out['samples'].append(row)
        if (R/'result.json').is_file():
            result=json.loads((R/'result.json').read_text());out['terminal_result_observed']={k:result.get(k) for k in ['execution_clean','ended','error','commands']};break
        if index<2:time.sleep(5)
    out['success']=True
except BaseException as exc:out.update(error=repr(exc),traceback=traceback.format_exc())
blob=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0)
subprocess.run(['tmux','load-buffer','-b',BATCH+'_result','-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BATCH+'_sha256',hashlib.sha256(blob).hexdigest()],check=True)
print(json.dumps({'success':out['success']}),flush=True)
if not out['success']:raise SystemExit(1)
