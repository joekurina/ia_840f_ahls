#!/usr/bin/env python3
"""Bounded file-only source closure; no FPGA API or sysfs attribute reads."""
import base64,datetime,gzip,hashlib,json,os,socket,stat,subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_13';S=W/'syn/board/ia840f/syn_top';BUFFER='ia840f_source_resume_01_batch04'
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
            v['base64']=base64.b64encode(q.read_bytes()).decode()
        r['files'][str(p)]=v
    except Exception as e:r['files'][str(p)]=dict(error=str(e))
def run(name,args):
    p=subprocess.run(args,capture_output=True,timeout=40);r['commands'][name]=dict(argv=args,rc=p.returncode,stdout=p.stdout.decode(errors='replace'),stderr=p.stderr.decode(errors='replace'))
try:
    for f in ['ipss/pcie/qip/sv_wrapper/pcie_ss_ip_params.vh','src/afu_top/mux/top_cfg_pkg.sv','ofs-common/src/common/lib/mux/pf_vf_mux_default_rtable.vh','ofs-common/src/common/protocol_checker/protocol_checker_csr.sv','ofs-common/src/fpga_family/agilex/port_gasket/port_gasket.sv','ofs-common/src/fpga_family/agilex/port_gasket/pr_slot.sv']:
        take(W/f)
    for f in ['ofs_ip_cfg_db/ofs_ip_cfg_db.vh','afu_with_pim/pim.tcl','afu_with_pim/afu/build/platform/ofs_plat_if/rtl/ofs_plat_if_top_config.vh','afu_with_pim/afu/build/platform/ofs_plat_if/rtl/ifc_classes/host_chan/native_axis_pcie_tlp/ofs_plat_host_chan_map_as_avalon_mem_if.sv']:
        take(S/f)
    for f in ['types_enum.h','version.h','init.h']:take(Path('/usr/include/opae')/f)
    run('package_owners',['rpm','-qf','/usr/lib64/libopae-c.so.2','/usr/lib64/libopae-v.so','/usr/include/opae/types.h'])
    for f in ['/usr/lib64/libopae-c.so.2','/usr/lib64/libopae-v.so','/usr/lib64/libxfpga.so']:take(f,False)
    for root in [Path('/home/uwb_student00'),B.parent]:
        r['inventory'][str(root)]=[p.name for p in root.iterdir() if 'opae' in p.name.lower()]
    for root in [Path('/home/uwb_student00/opae-sdk'),Path('/home/uwb_student00/opae'),B.parent/'opae-sdk']:
        if root.is_dir():
            run('git_'+root.name,['git','-C',str(root),'rev-parse','HEAD'])
            r['inventory'][str(root)]=[str(p.relative_to(root)) for p in root.rglob('*') if p.name in ['enum.c','enumerate.c','CMakeCache.txt']]
            for p in root.rglob('*'):
                if p.name in ['enum.c','enumerate.c','opae.cfg','CMakeCache.txt'] and p.is_file():take(p)
    # Exact metadata-only pathname checks for old chmod operands. No content reads.
    port=Path('/sys/devices/pci0000:4e/0000:4e:00.0/0000:4f:00.0/fpga_region/region0/dfl-port.0')
    r['inventory']['chmod_operand_paths']={}
    for pattern in ['dfl*/userclk/frequency','errors/*']:
        r['inventory']['chmod_operand_paths'][pattern]=[str(p) for p in port.glob(pattern)]
    # Existing saved timing reports: excerpts + full-file hashes, not new STA execution.
    for root in [S,B/'work_ahls_persona_01/build/syn/board/ia840f/syn_top']:
        f=root/'output_files'/('ofs_top.sta.rpt' if root==S else 'ofs_pr_afu.sta.rpt')
        take(f,False)
        lines=f.read_text(errors='replace').splitlines(); excerpts=[]
        for i,line in enumerate(lines):
            if 'Slack' in line and ('-0.336' in line or '-0.029' in line or '-0.004' in line):
                excerpts.append(dict(line=i+1,text='\n'.join(lines[max(0,i-8):i+38])))
        r['inventory'][str(f)+'_negative_path_excerpts']=excerpts[:30]
    r['complete']=True
except Exception as e:r['complete']=False;r['error']=repr(e)
finally:
    raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True)
    print('EVIDENCE',BUFFER,'JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),'COMPLETE',r.get('complete'),flush=True)
