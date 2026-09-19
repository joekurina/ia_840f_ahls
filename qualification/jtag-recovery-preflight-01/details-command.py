import pathlib,json,os,subprocess,stat
P=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/jtag-recovery-preflight-01')
a=json.loads((P/'inventory.json').read_text()); print('IMAGES',json.dumps([x for x in a if pathlib.Path(x['path']).suffix in ['.sof','.rpd','.pof','.jic']]))
print('PDF',json.dumps([x for x in a if x['path'].endswith('.pdf')]))
for f in ['/dev/bus/usb/001/017','/dev/bus/usb/001/018']:
 s=os.stat(f); print(f,oct(s.st_mode),s.st_uid,s.st_gid,'read',os.access(f,os.R_OK),'write',os.access(f,os.W_OK))
print((P/'jtagd.log').read_text())
f=pathlib.Path('/home/uwb_student00/Documents/IA-840f installation/IOFS_BUILD_ROOT/oneapi-asp/ia840f/README.md'); print('SOURCE',f); print('\n'.join(str(i+1)+': '+x for i,x in enumerate(f.read_text().splitlines()) if 295<=i<=345))
for base in ['/etc/udev/rules.d','/usr/lib/udev/rules.d']:
 for f in pathlib.Path(base).glob('*.rules'):
  t=f.read_text(errors='replace')
  if any(x in t.lower() for x in ['09fb','6810','bittware']): print('RULE',f,t)
