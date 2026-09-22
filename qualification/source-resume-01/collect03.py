#!/usr/bin/env python3
"""Final bounded ordinary-file collection for W13 source contracts."""
import datetime,gzip,hashlib,json,os,socket,stat,subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_13';S=W/'syn/board/ia840f/syn_top'; BUFFER='ia840f_source_resume_01_batch03'
assert os.environ.get('TMUX') and socket.gethostname().lower()=='agilex7workstation'
r:dict=dict(batch=BUFFER,time=datetime.datetime.now().astimezone().isoformat(),pane=os.environ['TMUX_PANE'],pid=os.getpid(),files={},commands={},inventory={})
def take(p,content=True):
    p=Path(p)
    try:
        q=p.resolve(strict=True);assert not str(q).startswith(('/dev/','/sys/','/proc/'));s=q.stat();assert stat.S_ISREG(s.st_mode)
        h=hashlib.sha256()
        with q.open('rb') as f:
            for c in iter(lambda:f.read(1048576),b''):h.update(c)
        v=dict(resolved=str(q),size=s.st_size,sha256=h.hexdigest())
        if content:
            assert s.st_size<2000000
            v['content']=q.read_text()
        r['files'][str(p)]=v
    except Exception as e:r['files'][str(p)]=dict(error=str(e))
def run(name,args):
    p=subprocess.run(args,capture_output=True,timeout=40);r['commands'][name]=dict(argv=args,rc=p.returncode,stdout=p.stdout.decode(errors='replace'),stderr=p.stderr.decode(errors='replace'))
try:
    for f in ['fim_project_macros.tcl','ofs_top_sources.tcl','fim_base_ip.tcl','fme-ifc-id.txt','ofs_ip_cfg_db/ofs_ip_cfg_pcie_ss.vh','output_files/ofs_top.flow.rpt','output_files/ofs_top.fit.summary','output_files/ofs_top.sta.summary','output_files/ofs_top.asm.rpt','afu_with_pim/afu.tcl']:
        take(S/f)
    for f in ['src/board/ia840f/afu_top.sv','src/top/top_cfg_pkg.sv','src/top/ofs_fim_cfg_pkg.sv','src/pd_qsys/fabric/fabric_width_pkg.sv','src/afu_top/port_gasket.sv','ofs-common/src/common/port_gasket/pg_csr.sv','ofs-common/src/common/port_gasket/pg_afu.sv','ofs-common/src/common/port_gasket/afu_main.sv','syn/board/ia840f/setup/afu_design_files.tcl','syn/board/ia840f/setup/parameters.tcl','ipss/pcie/qip/pcie_ss.ip']:
        take(W/f)
    # Relevant register implementation can be in generated kernel wrapper, not csr-named file.
    P=S/'afu_with_pim/afu/hw/ahls_ip/qual_vec_op.report.prj'
    matches=[]
    for p in P.rglob('*'):
        if p.is_file() and p.suffix in ['.sv','.v','.tcl']:
            if p.stat().st_size>2000000:continue
            text=p.read_text(errors='replace')
            if any(x in text.lower() for x in ['finishcounter','finish_counter','finish_count','clear_on_read','finish_count_lo','resultpipeid_pipe_channel_data']):
                matches.append(str(p));take(p)
    r['inventory']['generated_finish_matches']=matches
    for f in ['output_files/ofs_top.sof','output_files/ofs_top.green_region.rbf']:take(S/f,False)
    take(B/'work_ahls_persona_01/ofs_pr_afu.gbs',False)
    for p in (B/'work_ahls_persona_01/build').rglob('*.sta.summary'):take(p)
    for p in (B/'work_ahls_persona_01/build').rglob('*.flow.rpt'):take(p)
    # Ordinary node metadata only; no node opens or sysfs-attribute reads.
    r['inventory']['node_metadata']={}
    for p in Path('/dev').glob('dfl-*'):
        s=p.stat();v=dict(mode=stat.S_IMODE(s.st_mode),uid=s.st_uid,gid=s.st_gid,major=os.major(s.st_rdev),minor=os.minor(s.st_rdev));r['inventory']['node_metadata'][str(p)]=v
        take(Path('/run/udev/data')/('c%d:%d'%(v['major'],v['minor'])))
    run('opae_library_files',['ldconfig','-p'])
    for root in ['/usr/local/include/opae','/usr/include/opae']:
        for f in ['access.h','enum.h','properties.h','mmio.h','types.h','utils.h','fpga.h']:take(Path(root)/f)
    for p in [Path('/etc/opae.cfg'),Path('/etc/opae/opae.cfg')]:take(p)
    r['complete']=True
except Exception as e:r['complete']=False;r['error']=repr(e)
finally:
    raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True)
    print('EVIDENCE',BUFFER,'JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),'COMPLETE',r.get('complete'),flush=True)
