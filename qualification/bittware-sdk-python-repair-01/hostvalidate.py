import pathlib,subprocess,sys,os,json
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01')
# Defense-in-depth for source-reviewed static product/help paths: no device/sysfs,
# subprocess/network access, or file writes. Ordinary imports/resource reads only.
prelude='''import sys,os,runpy,json,pathlib
sys.dont_write_bytecode=True
blocked=[]
def audit(event,args):
 if event=='open':
  path=args[0]; mode=args[1];flags=args[2]
  if isinstance(path,(str,bytes)):
   path=os.fsdecode(path)
   if path!='/dev/null' and (path.startswith(('/sys/','/dev/')) or (isinstance(mode,str) and any(x in mode for x in 'wax+')) or (isinstance(flags,int) and flags & (os.O_WRONLY|os.O_RDWR|os.O_CREAT|os.O_TRUNC))):
    blocked.append((event,str(args)));raise RuntimeError('Read-only audit blocked '+repr(args))
 if event=='ctypes.dlopen' and args[0] in (None,'libpthread.so.0'):return
 if event=='subprocess.Popen' and list(args[1])==['/sbin/ldconfig','-p']:return
 if event.startswith(('subprocess.','socket.')) or event in ('os.system','os.remove','os.rename','os.mkdir','ctypes.dlopen'):
  blocked.append((event,str(args)));raise RuntimeError('Read-only audit blocked '+event)
sys.addaudithook(audit)
'''
checks={'bw-product-help':"sys.argv=['bw_product','--help'];runpy.run_path(os.path.expanduser('~/.local/bin/bw_product'),run_name='__main__')",'offline-csp-import':"""from importlib.resources import files
from bw_agilex.products.ia840f_product import IA840FProduct
p=IA840FProduct
assert pathlib.Path(p.card_desc_path).is_file()
assert pathlib.Path(p.fpga_desc_path).is_file()
assert str(files('bw_agilex').joinpath('data/IA-840F'))==p.data_directory
model=p._load_card_desc(p.card_desc_path)
json.loads(pathlib.Path(p.fpga_desc_path).read_text())
print(json.dumps({'class':p.__name__,'name':p.name.value,'data_directory':p.data_directory,'card_desc_path':p.card_desc_path,'fpga_desc_path':p.fpga_desc_path,'clock_files':p.clock_files,'test_plans':p.test_plans(),'card_model':type(model).__name__,'blocked_audit_events':blocked},indent=2))
"""}
for name,code in checks.items():
 x=subprocess.run([sys.executable,'-B','-c',prelude+code],capture_output=True,text=True,timeout=45,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'));(R/(name+'.txt')).write_text(x.stdout+x.stderr+'\nRC='+str(x.returncode));print(name,x.returncode,x.stdout,x.stderr)
print('DONE')
