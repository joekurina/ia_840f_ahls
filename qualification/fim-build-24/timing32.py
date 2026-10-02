"""Capture stable fitted/timing reports while assembly completes; no tools run."""
import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-24';J=B/'work_ia840f_fim_24/syn/board/ia840f/syn_top';BUFFER='ia840f_migration24_timing32_result'
R={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'hardware_access':False,'files':{}}
try:
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    assert 'Fitter Status : Successful' in (J/'output_files/ofs_top.fit.summary').read_text()
    assert 'Info: Quartus Prime Timing Analyzer was successful.' in (J/'output_files/ofs_top.sta.rpt').read_text(), 'STA report not complete'
    names=['output_files/ofs_top.fit.rpt','output_files/ofs_top.fit.summary','output_files/ofs_top.sta.rpt','output_files/ofs_top.sta.summary','output_files/ofs_top.tq.drc.signoff.rpt','output_files/ofs_top.sdc_constraints.rpt','build_env_db.txt','fme_id.mif','fme-ifc-id.txt']
    for rel in names:
        p=J/rel;st=p.stat();assert st.st_size<120000000
        data=p.read_bytes();after=p.stat();assert (st.st_size,st.st_mtime_ns)==(after.st_size,after.st_mtime_ns)
        R['files'][rel]={'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'base64':base64.b64encode(data).decode()}
    R['success']=True
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    blob=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
    D=E/'timing32';D.mkdir(exist_ok=False);(D/'capture.json.gz').write_bytes(blob)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
    print('MIGRATION24_TIMING32',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
