from pathlib import Path
import json,hashlib,zipfile,tarfile,subprocess,re
Q=Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-sdk2026-01');root=Path('/usr/share/bittware-sdk')
def sha(p):
 h=hashlib.sha256()
 with Path(p).open('rb') as f:
  for b in iter(lambda:f.read(8388608),b''):h.update(b)
 return h.hexdigest()
archives=[]
for p in root.rglob('*'):
 if not p.is_file():continue
 if p.suffix in ('.whl','.zip'):
  with zipfile.ZipFile(p) as z:names=z.namelist()
 elif str(p).endswith(('.tgz','.tar.gz')):
  with tarfile.open(p) as t:names=t.getnames()
 else:continue
 archives.append({'path':str(p),'sha256':sha(p),'members':names,'candidate_members':[n for n in names if re.search(r'tennm|fmica|msim_setup|modelsim\.ini|\.(sv|vhd|qdb)$',n,re.I)]})
(Q/'all-sdk-archive-inventory.json').write_text(json.dumps(archives,indent=2))
paths=['/opt/altera/26.1.1/quartus/eda/sim_lib/tennm_atoms.sv','/opt/altera/26.1.1/quartus/eda/sim_lib/mentor/tennm_atoms_ncrypt.sv','/opt/altera/26.1.1/quartus/eda/sim_lib/fmica_atoms_ncrypt.sv','/opt/altera/26.1.1/questa_fe/bin/vlog','/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04/ipss/mem/qip/mem_ss/mem_ss/sim/mentor/msim_setup.tcl','/home/uwb_student00/IA-840f/bittware-sdk-2026.1.0-1.el9.rpm','/home/uwb_student00/IA-840f/bittware-csp-ia840f-2024.3.1-1.el9.rpm']
records=[]
for p in map(Path,paths):
 x={'path':str(p),'exists':p.exists()}
 if p.is_file():x.update(bytes=p.stat().st_size,sha256=sha(p))
 if p.name=='msim_setup.tcl':x['recipe']=[l for l in p.read_text().splitlines() if 'tennm_atoms' in l or 'fmica_atoms' in l]
 records.append(x)
(Q/'prerequisites.json').write_text(json.dumps(records,indent=2))
cmd=['/opt/altera/26.1.1/questa_fe/bin/vlog','-version'];r=subprocess.run(cmd,capture_output=True,text=True,timeout=15);(Q/'tool-version.json').write_text(json.dumps({'argv':cmd,'rc':r.returncode,'stdout':r.stdout,'stderr':r.stderr},indent=2))
hashes={str(p):sha(p) for p in root.rglob('*') if p.is_file()};before=json.loads((Q/'sdk-hashes-before.json').read_text());assert hashes==before
(Q/'sdk-hashes-after.json').write_text(json.dumps(hashes,indent=2))
summary={'sdk_file_count':len(hashes),'sdk_unchanged':True,'archive_count':len(archives),'candidate_members':[{'path':x['path'],'members':x['candidate_members']} for x in archives if x['candidate_members']],'pass':False,'ready_for_build':False,'hardware_qualified':False,'compile_executed':False,'elaboration_executed':False,'smoke_executed':False,'reason':'No new model source/library or source-grounded simulator fix in installed SDK; host CSP is bundled, not missing.'}
(Q/'result.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2));print(json.dumps(records,indent=2));print(r.stdout)
