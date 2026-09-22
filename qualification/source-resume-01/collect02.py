#!/usr/bin/env python3
"""Bounded source follow-up; module and udev metadata, no device access."""
import datetime,gzip,hashlib,json,os,socket,stat,subprocess
from pathlib import Path
B=Path('/home/uwb_student00/ahls/new_BSP'); D=Path('/home/uwb_student00/linux-dfl-backport')
BUFFER='ia840f_source_resume_01_batch02'
assert os.environ.get('TMUX') and socket.gethostname().lower()=='agilex7workstation'
r:dict=dict(batch=BUFFER,time=datetime.datetime.now().astimezone().isoformat(),pane=os.environ['TMUX_PANE'],pid=os.getpid(),files={},commands={},inventory={})
def run(name,args):
    p=subprocess.run(args,capture_output=True,timeout=40,env=dict(os.environ,LC_ALL='C'))
    r['commands'][name]=dict(argv=args,rc=p.returncode,stdout=p.stdout.decode(errors='replace'),stderr=p.stderr.decode(errors='replace'))
    return p.stdout.decode(errors='replace').strip()
def take(p,content=True):
    p=Path(p)
    try:
        q=p.resolve(strict=True); assert not str(q).startswith(('/dev/','/sys/','/proc/'))
        s=q.stat(); assert stat.S_ISREG(s.st_mode)
        assert s.st_size<50000000
        h=hashlib.sha256()
        with q.open('rb') as f:
            for chunk in iter(lambda:f.read(1048576),b''):h.update(chunk)
        v=dict(resolved=str(q),size=s.st_size,sha256=h.hexdigest())
        if content:
            assert s.st_size<=2000000
            v['content']=q.read_text()
        r['files'][str(p)]=v
    except Exception as e:r['files'][str(p)]=dict(error=str(e))
try:
    run('8250_modinfo',['modinfo','8250_dfl'])
    run('uart_built_modinfo',['modinfo',str(D/'8250_dfl.ko')])
    for module in ['8250_dfl','dfl','dfl-afu']:
        f=run(module+'_file',['modinfo','-F','filename',module]);take(f,False)
        take(D/(module+'.ko'),False);take(D/(module+'.mod.c'))
    for f in ['drivers/tty/serial/8250/8250_dfl.c','include/linux/dfl.h','drivers/fpga/dfl-afu-error.c','drivers/fpga/dfl-afu-main.c','drivers/fpga/dfl-pci.c','.8250_dfl.o.cmd','drivers/tty/serial/8250/.8250_dfl.o.cmd']:
        take(D/f)
    run('dfl_source_delta',['git','-C',str(D),'diff','--','drivers/fpga/dfl.c'])
    for p in Path('/usr/share/man/man7').glob('udev.7*'):take(p,False)
    run('udev_man',['bash','-c','gzip -cd /usr/share/man/man7/udev.7.gz'])
    run('opae_packages',['rpm','-qa','*opae*'])
    for root in [B/'work_ia840f_fim_13',B/'ofs-agx7-pcie-attach']:
        for f in ['src/board/ia840f/afu_top.sv','src/board/ia840f/top_cfg_pkg.sv','src/pd_qsys/fabric/rtl/fabric_width_pkg.sv','src/pd_qsys/fabric/apf.txt','syn/board/ia840f/syn_top/ofs_top.qsf','syn/board/ia840f/syn_top/fpga_defines.vh','syn/board/ia840f/syn_top/ofs_ip_cfg_db.vh','ofs-common/src/common/lib/axi4lite/dummy_csr.sv','ofs-common/src/common/port_gasket/port_gasket.sv','ofs-common/src/common/port_gasket/csr/pg_csr.sv']:
            take(root/f)
        r['inventory'][str(root/'syn/board/ia840f/syn_top')]=sorted(p.name for p in (root/'syn/board/ia840f/syn_top').iterdir())
    w=B/'work_ia840f_fim_13'
    wanted={'dummy_csr.sv','fabric_width_pkg.sv','ofs_ip_cfg_pcie_ss.vh','ofs_fim_cfg_pkg.sv','ofs_plat_host_chan_pkg.sv','ofs_plat_host_chan_fiu_if.sv','ofs_plat_host_chan_pcie_tlp_if.sv','ofs_plat_host_chan_pcie_tlp_if.vh','afu_json_info.vh','platform_afu_top_config.vh','ofs_plat_afu.sv','IDQualVecOp_register_map.h','IDQualVecOp_csr.v','IDQualVecOp_csr.sv','ofs_plat_host_chan_as_avalon_mem_rdwr.sv','ofs_plat_host_chan_avalon_mem_pkg.sv','pf_vf_mux_pkg.sv','pcie_ss_cfg_pkg.sv','ofs_fim_pcie_ss_cfg_pkg.sv','port_afu_instances.sv','map_fim_pcie_ss_to_host_chan.sv','afu_main.sv','dfh.sv'}
    for root in [w/'syn/board/ia840f/syn_top/afu_with_pim',w/'src',w/'ofs-common/src',w/'ipss/pcie']:
        for p in root.rglob('*'):
            if p.name in wanted and p.is_file():take(p)
    for root in [B/'work_ahls_compile_01',B/'qualification/ahls-compile-01']:
        for p in root.rglob('*'):
            if p.name in ['qual_vec_op.cpp','IDQualVecOp_register_map.h'] or ('csr' in p.name.lower() and p.suffix in ['.sv','.v','.h']):take(p)
    # Locate exact PCIe saved configuration filenames; no catalog-wide search.
    r['inventory']['pcie_ip']=[str(p) for p in (w/'ipss/pcie').rglob('*.ip')]
    r['complete']=True
except Exception as e:r['complete']=False;r['error']=repr(e)
finally:
    raw=json.dumps(r,sort_keys=True).encode();blob=gzip.compress(raw,mtime=0)
    subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=blob,check=True)
    print('EVIDENCE',BUFFER,'JSON_SHA256',hashlib.sha256(raw).hexdigest(),'GZIP_SHA256',hashlib.sha256(blob).hexdigest(),'COMPLETE',r.get('complete'),flush=True)
