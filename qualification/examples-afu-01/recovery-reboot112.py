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
modules={'fpga_region': {'path': '/usr/lib/modules/5.14.0-687.15.1.el9_8.x86_64/extra/fpga-region.ko', 'sha256': '7d8a160293985df0b497825db606342f44d67b8399ccb4dc1b71bc26d8488cd7', 'loaded_note': '040000001400000003000000474e550054b90aaa0fb2542566ce663159398310c8e548de'}, 'dfl_fme_mgr': {'path': '/usr/lib/modules/5.14.0-687.15.1.el9_8.x86_64/extra/dfl-fme-mgr.ko', 'sha256': '1f6493865c025ec4cea9568d6b34660135e8b9111552bdd0784dc9be9cfffcd4', 'loaded_note': '040000001400000003000000474e55006675e340311e4d2379d5906257f61ca933ad2aa7'}, 'dfl_fme_region': {'path': '/usr/lib/modules/5.14.0-687.15.1.el9_8.x86_64/extra/dfl-fme-region.ko', 'sha256': '687791d091e1cee4ec5eb27c9fd823196b5bff574bae496255c05796aa03aeec', 'loaded_note': '040000001400000003000000474e5500984c9e404e74df6ebf988f728e98a287c96a8f5f'}}
for name,row in modules.items():
 assert hashlib.sha256(Path(row['path']).read_bytes()).hexdigest()==row['sha256'] and (Path('/sys/module')/name/'notes/.note.gnu.build-id').read_bytes().hex()==row['loaded_note']
record={'boot_before':boot,'cycle_sha256':'36f35f5606d7b6160bc328d5b3ec0fe955b7d506d4c5756a8ffc666d5039f9c4','modules':modules,'original_AER':d['original_AER'],'ownership':s,'argv':['sudo','-n','/usr/bin/systemctl','reboot'],'requested':datetime.datetime.now(datetime.timezone.utc).isoformat()};save('reboot-requested112.json',record)
z=subprocess.run(record['argv'],capture_output=True,text=True,timeout=20);save('reboot-command112.json',{'native_rc':z.returncode,'stdout':z.stdout,'stderr':z.stderr});assert z.returncode==0
