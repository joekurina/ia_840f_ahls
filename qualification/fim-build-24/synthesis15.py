"""Capture completed synthesis reports while the owned fitter continues."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-24';J=B/'work_ia840f_fim_24/syn/board/ia840f/syn_top';BUFFER='ia840f_migration24_synthesis15_result'
R={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'hardware_access':False,'files':{}}
try:
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    summary=J/'output_files/ofs_top.syn.summary';assert 'Synthesis Status : Successful' in summary.read_text()
    for name in ('ofs_top.syn.rpt','ofs_top.syn.summary','ofs_top.drc.synthesized.rpt','ofs_top.drc.partitioned.rpt'):
        p=J/'output_files'/name;st=p.stat();assert st.st_size<120000000
        data=p.read_bytes();after=p.stat();assert (st.st_size,st.st_mtime_ns)==(after.st_size,after.st_mtime_ns)
        R['files'][name]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
    R['success']=True
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    blob=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
    D=E/'synthesis15';D.mkdir(exist_ok=False);(D/'capture.json.gz').write_bytes(blob)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
    print('MIGRATION24_SYNTHESIS15',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
