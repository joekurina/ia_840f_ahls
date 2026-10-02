import datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');E=B/'qualification/fim-build-24';P=B/'work_ia840f_fim_24/syn/board/ia840f/syn_top/output_files/ofs_top.fit.place.rpt'
BUFFER='ia840f_migration24_clockallocation26_result';TARGET='local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]'
R={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'hardware_access':False,'native_tools_executed':False,'scope':'completed Place-stage allocation, not final routing/timing'}
try:
    assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
    assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
    before=P.stat();assert before.st_size<120000000
    raw=P.read_bytes();after=P.stat();assert (before.st_size,before.st_mtime_ns)==(after.st_size,after.st_mtime_ns)
    text=raw.decode();assert 'Info (170137): Fitter placement was successful' in text
    lines=text.splitlines();blocks=[]
    for i,line in enumerate(lines):
        c=[s.strip() for s in line.split(';')[1:-1]] if line.startswith(';') else []
        if len(c)!=2 or c[0]!='Name':continue
        rows=[{'line':i+1,'property':c[0],'value':c[1]}]
        for j in range(i+1,min(i+40,len(lines))):
            d=[s.strip() for s in lines[j].split(';')[1:-1]] if lines[j].startswith(';') else []
            if len(d)!=2 or d[0]=='Name':break
            rows.append({'line':j+1,'property':d[0],'value':d[1]})
        if any('Terminating Spine Index' in r['property'] for r in rows):blocks.append(rows)
    assert len(blocks)<=128,len(blocks)
    selected=[b for b in blocks if b[0]['value']==TARGET]
    R.update(source={'path':str(P),'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'mtime_ns':after.st_mtime_ns},clock_block_count=len(blocks),target_match_count=len(selected),target=TARGET,target_blocks=selected,clock_blocks=blocks,success=True)
except BaseException as exc:R.update(error=repr(exc),traceback=traceback.format_exc())
finally:
    blob=gzip.compress(json.dumps(R,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(blob).hexdigest()
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
    print('CLOCK_ALLOCATION26',R['success'],h,flush=True)
if not R['success']:raise SystemExit(1)
