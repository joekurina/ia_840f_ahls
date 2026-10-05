from pathlib import Path
import json,hashlib,os,subprocess,datetime
r=Path('/home/uwb_student00/ahls/new_BSP/work_examples_afu01/recovery109');p=r/'result.json'
assert os.environ.get('TMUX') and hashlib.sha256(p.read_bytes()).hexdigest()=='36f35f5606d7b6160bc328d5b3ec0fe955b7d506d4c5756a8ffc666d5039f9c4'
d=json.loads(p.read_text());boot=Path('/proc/sys/kernel/random/boot_id').read_text().strip();assert d['success'] and d['off_confirmed'] and d['on_confirmed'] and boot==d['boot_before']
obs=Path('/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/activation-pre43/runtime/ownership27.py');assert hashlib.sha256(obs.read_bytes()).hexdigest()=='c120062efd638824d05f4495faf7e63634576744e3cc13f26aa0d3a2d12faf8c'
z=subprocess.run(['sudo','-n','/usr/bin/python3','-I','-B',str(obs)],capture_output=True,timeout=60);assert z.returncode==0;s=json.loads(z.stdout);assert s['boot_id']==boot and not any(s[k] for k in ['holders','maps','errors','relevant_processes'])
assert not Path('/run/systemd/shutdown/scheduled').exists()
def save(n,obj):
 with (r/n).open('x') as f:json.dump(obj,f,indent=2);f.write('\n');f.flush();os.fsync(f.fileno())
modules={}
for name,leaf in [('fpga_region','fpga-region'),('dfl_fme_mgr','dfl-fme-mgr'),('dfl_fme_region','dfl-fme-region')]:
 p=Path('/usr/lib/modules')/os.uname().release/'extra'/(leaf+'.ko');note=Path('/sys/module')/name/'notes/.note.gnu.build-id';modules[name]={'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'loaded_note':note.read_bytes().hex()}
record={'boot_before':boot,'cycle_sha256':'36f35f5606d7b6160bc328d5b3ec0fe955b7d506d4c5756a8ffc666d5039f9c4','modules':modules,'original_AER':d['original_AER'],'ownership':s,'argv':['sudo','-n','/usr/bin/systemctl','reboot'],'requested':datetime.datetime.now(datetime.timezone.utc).isoformat()};save('reboot-requested110.json',record)
z=subprocess.run(record['argv'],capture_output=True,text=True,timeout=20);save('reboot-command110.json',{'native_rc':z.returncode,'stdout':z.stdout,'stderr':z.stderr});assert z.returncode==0
