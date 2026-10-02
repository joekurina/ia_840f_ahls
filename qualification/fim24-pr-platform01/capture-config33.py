import base64,datetime,gzip,hashlib,json,os,socket,subprocess,traceback
from pathlib import Path
ROOT=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01');T=ROOT/'release01';R=ROOT/'export01';BUFFER='ia840f_fim24_pr_config33_result';NAMES=['hw/lib/build/platform/sim/fim_project_macros.txt', 'hw/lib/build/platform/ofs_plat_if/rtl/ifc_classes/other/extend_pim/ofs_plat_fim_other_if.sv', 'hw/lib/build/ofs-common/src/common/includes/ofs_pcie_ss_cfg_pkg.sv', 'hw/lib/build/ofs-common/src/fpga_family/agilex/mem_ss/includes/ofs_fim_mem_if_pkg.sv', 'hw/lib/build/src/afu_top/mux/top_cfg_pkg.sv', 'hw/lib/build/src/includes/ofs_fim_cfg_pkg.sv', 'hw/lib/build/syn/board/ia840f/syn_top/ofs_ip_cfg_local_mem_asp.qprs', 'hw/lib/build/syn/board/ia840f/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_db.vh', 'hw/lib/build/syn/board/ia840f/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_local_mem.vh', 'hw/lib/build/syn/board/ia840f/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_pcie_ss.vh', 'hw/lib/platform/platform_db/import/extend_pim/ofs_plat_fim_other_if.sv']
result={'batch':BUFFER,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'success':False,'native_tools_executed':False,'hardware_access':False,'files':{}}
try:
 assert socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
 assert subprocess.check_output(['tmux','display-message','-p','-t',os.environ['TMUX_PANE'],'#S'],text=True).strip()=='ia840f_mailbox_monitored_01'
 raw=(R/'result.json').read_bytes();assert hashlib.sha256(raw).hexdigest()=='4debead014384dd31b3dda0c072cf2836bf9f7298360e7f39d04fa88dc7d886e';inv=json.loads(raw)['release_inventory']
 for n in NAMES:
  m=inv[n];p=T/n;s=p.stat();assert m['kind']=='file' and s.st_size==m['bytes']<1024**2;b=p.read_bytes();e=p.stat();assert hashlib.sha256(b).hexdigest()==m['sha256'] and s.st_mtime_ns==e.st_mtime_ns
  result['files'][n]={'bytes':len(b),'sha256':m['sha256'],'base64':base64.b64encode(b).decode()}
 result.update(success=True,file_count=len(result['files']))
except BaseException as exc:result.update(error=repr(exc),traceback=traceback.format_exc())
finally:
 b=gzip.compress(json.dumps(result,sort_keys=True).encode(),mtime=0);h=hashlib.sha256(b).hexdigest();subprocess.run(['tmux','load-buffer','-b',BUFFER,'-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b',BUFFER+'_sha256',h],check=True)
 print('FIM24_PR_CONFIG33',result['success'],h,flush=True)
if not result['success']:raise SystemExit(1)
