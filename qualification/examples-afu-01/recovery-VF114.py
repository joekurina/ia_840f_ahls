from pathlib import Path
import json,subprocess,hashlib,os,time
r=Path('/home/uwb_student00/ahls/new_BSP/work_examples_afu01/recovery109');assert not (r/'VF-setup114.json').exists();boot=Path('/proc/sys/kernel/random/boot_id').read_text().strip();assert boot=='c5b29027-5b6b-4bf2-b7ed-ace79cc87e73'
expected={'/usr/bin/pci_device':'502c80133f66e7d9326660cc7c358b81b6bd0ef9525463b0df710eeae0815a10','/usr/lib/python3.9/site-packages/opae/admin/tools/pci_device.py':'8ab8230856e51b76c733d309d11d2cbec9fe9fac78e8e86b1ed7f90cc38975df','/usr/lib/python3.9/site-packages/opae/admin/sysfs.py':'d70da0e869d7ce45ac13a15916d345841a131c0572cf1af247c2fcae32ba1151','/usr/bin/opae.io':'bd3001695d17a6bfb3cd4d01d11f96b767704d30da6e95dcad97137eeed00dda','/usr/lib64/python3.9/site-packages/opae/io/utils.py':'3777bbf406aff1a081d3085a19127f8eed95b485f2ed001c14bd6bb69d4c4bed','/usr/lib64/python3.9/site-packages/opae/io/pci.py':'ee0be3e67201123efb4a725a59661664b49a9e6e6eeed89721873dffdfc3ea02','/usr/lib64/python3.9/site-packages/opae/io/config.py':'6022ee8473ea8b472de4d4de7141ee4387cd4d987cdc6939466820e14068bd0b'}
for p,h in expected.items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==h,p
pf=Path('/sys/bus/pci/devices/0000:4f:00.0');vf=Path('/sys/bus/pci/devices/0000:4f:00.2');assert (pf/'driver').resolve().name=='dfl-pci' and (pf/'sriov_numvfs').read_text().strip()=='0' and not vf.exists()
record={'boot':boot,'success':False,'commands':[],'tool_hashes':expected}
def persist():(r/'VF-setup114-status.json').write_text(json.dumps(record,indent=2))
def run(label,argv):
 row={'label':label,'argv':argv};record['commands'].append(row);persist()
 with (r/(label+'114.log')).open('xb') as log:
  p=subprocess.Popen(argv,stdout=log,stderr=subprocess.STDOUT,start_new_session=True);row['pid']=p.pid;persist()
  try:row['native_rc']=p.wait(timeout=45)
  except subprocess.TimeoutExpired:row['execution_state']='UNKNOWN, originalownerretained';persist();raise
 persist();assert row['native_rc']==0;return (r/(label+'114.log')).read_text()
def write(path,value,label):return run(label,['sudo','-n','/usr/bin/python3','-I','-B','-c','from pathlib import Path; Path('+repr(str(path))+').write_text('+repr(value)+')'])
try:
 original=(pf/'sriov_drivers_autoprobe').read_text().strip();assert original=='1';write(pf/'sriov_drivers_autoprobe','0','autoprobe-off');assert (pf/'sriov_drivers_autoprobe').read_text().strip()=='0'
 run('create-VF',['sudo','-n','/usr/bin/pci_device','0000:4f:00.0','vf','1']);assert vf.exists() and not (vf/'driver').exists() and (vf/'physfn').resolve()==pf.resolve();assert (vf/'vendor').read_text().strip()=='0x8086' and (vf/'device').read_text().strip()=='0xbccf'
 group=(vf/'iommu_group').resolve();assert sorted(x.name for x in (group/'devices').iterdir())==['0000:4f:00.2']
 write(vf/'driver_override','vfio-pci','VF-override');assert (vf/'driver_override').read_text().strip()=='vfio-pci'
 run('VFIO-init',['sudo','-n','/usr/bin/opae.io','init','-d','0000:4f:00.2','uwb_student00:uwb_student00']);assert (vf/'driver').resolve().name=='vfio-pci' and (pf/'driver').resolve().name=='dfl-pci'
 write(pf/'sriov_drivers_autoprobe',original,'autoprobe-restored');assert (pf/'sriov_drivers_autoprobe').read_text().strip()==original
 node=Path('/dev/vfio')/group.name;st=node.stat();assert st.st_uid==1000 and st.st_mode&0o777==0o660 and os.access(node,os.R_OK|os.W_OK)
 record.update(success=True,VF_driver='vfio-pci',VF_group=group.name,VF_node_uid=st.st_uid,VF_node_mode=oct(st.st_mode&0o777),PF_driver='dfl-pci',autoprobe_restored=True,reset_method=(vf/'reset_method').read_text().strip())
except BaseException as exc:record['error']=repr(exc)
with (r/'VF-setup114.json').open('x') as f:json.dump(record,f,indent=2)
print('VF_SETUP',json.dumps(record));assert record['success'],record.get('error')
