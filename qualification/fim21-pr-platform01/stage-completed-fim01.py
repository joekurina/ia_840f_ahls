import os,socket,json,hashlib,gzip,subprocess,shutil,time
from pathlib import Path
from datetime import datetime,timezone
assert __debug__ and socket.gethostname()=='Agilex7Workstation' and os.getuid()==1000 and os.environ.get('TMUX')
B=Path('/home/uwb_student00/ahls/new_BSP');W=B/'work_ia840f_fim_21';D=B/'work_fim21_pr_platform01/base01';R=B/'work_fim21_pr_platform01/stage01';assert not D.exists() and not R.exists()
C={'artifacts': {'syn/board/ia840f/syn_top/ofs_top.qdb': {'bytes': 83178648, 'mtime_ns': 1790144645798018229, 'realpath': '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_21/syn/board/ia840f/syn_top/ofs_top.qdb', 'sha256': '7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8'}, 'syn/board/ia840f/syn_top/output_files/ofs_top.green_region.pmsf': {'bytes': 7202780, 'mtime_ns': 1790144526202664364, 'realpath': '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_21/syn/board/ia840f/syn_top/output_files/ofs_top.green_region.pmsf', 'sha256': '27b3e78810d54cf452dcc1aa834c62584290c9d3358e84f00a374294426a3663'}, 'syn/board/ia840f/syn_top/output_files/ofs_top.sof': {'bytes': 7901287, 'mtime_ns': 1790144535862692947, 'realpath': '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_21/syn/board/ia840f/syn_top/output_files/ofs_top.sof', 'sha256': 'bbede03c8c432e50ae6ae1f30739af3bfd3330781776d2c623269cc131b38ca4'}, 'syn/board/ia840f/syn_top/output_files/ofs_top.static.msf': {'bytes': 3309305, 'mtime_ns': 1790144520912648712, 'realpath': '/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_21/syn/board/ia840f/syn_top/output_files/ofs_top.static.msf', 'sha256': 'da2395b08b6713e6e4335b488f5757e052d583b44b908837e8d18747bb151705'}}, 'selected': {'ofs-common/scripts/common/syn/build_var_setup_common.sh': {'bytes': 6749, 'sha256': 'afc72621173d5dc95a38b1278f73d6878c3149ec54750cc35bc5fe7c5fa337c8'}, 'ofs-common/scripts/common/syn/emit_project_macros.tcl': {'bytes': 2752, 'sha256': 'a1840cda620fc854f2b71b00acf1953273e305db84c0ac21923d2f45b1504c75'}, 'ofs-common/scripts/common/syn/generate_pr_release.sh': {'bytes': 13963, 'sha256': '7218392b358ffd7950651ad7d4b067e4fc4d604ab840bd0cf61182c0c8715319'}, 'ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl': {'bytes': 4897, 'sha256': 'ab3ccd35a5af39fd6faccdaa69456b26ace04a8791728e276b787f345d7455da'}, 'ofs-common/scripts/common/syn/pim/ofs_pim_setup.sh': {'bytes': 4777, 'sha256': '99bb00318eef2fcccb3a1f538c0ae4e8a125b42c2253295dd1013a07e3de3fd3'}, 'ofs-common/scripts/common/syn/release_bin/README': {'bytes': 2197, 'sha256': '130fe92cb928cce7344e29cffd4fec9a4944656ce96b6e5b3e2d0bd60a5af031'}, 'ofs-common/scripts/common/syn/release_bin/afu_synth': {'bytes': 3836, 'sha256': 'f4b3e50ed71bde7d69335e203c17993c93ccc1197cba5abdf0b49255294f029d'}, 'ofs-common/scripts/common/syn/release_bin/update_pim': {'bytes': 1750, 'sha256': 'c9fe8ef48fcb61f5a137a4201328c3c6a346c7794ec9a1a1c40a3355c175f4a3'}, 'ofs-common/src/fpga_family/agilex/afu_main.tcl': {'bytes': 4353, 'sha256': '800b6fc92915cd4e66aba8cc051997ceea8fe155a2b2ae20dec85a2db21c2f47'}, 'ofs-common/tools/ofss_config/ia840f_experimental_gate.py': {'bytes': 14870, 'sha256': '335e2d085e33198db31ea83765b08f0b01e835606d7e404e8fc71bd8f230097d'}, 'src/top/ofs_agilex.ini': {'bytes': 3475, 'sha256': '3518f0bdabd3004e3e8920745056640db7783f6dc95f233cc50f8b61c48d5b54'}, 'syn/board/ia840f/setup/afu_design_files.tcl': {'bytes': 2365, 'sha256': '6d508346610f16420d098bb50801d9d82fda626de9c5b2e1af3569844d4f538c'}, 'syn/board/ia840f/setup/build_gate.tcl': {'bytes': 975, 'sha256': '69a11ed228ea07d7d1f6e9be4cf9bd0548f58e5d05e7f5d9f5e7c48659077fff'}, 'syn/board/ia840f/setup/config_env.tcl': {'bytes': 2801, 'sha256': '2f9ac4cf3678a0107104ba46e72275e809f419e5f6cc85f7ef945cc00aa73c74'}, 'syn/board/ia840f/syn_top/build_env_db.txt': {'bytes': 358, 'sha256': 'cd70202b481da9f56deab32123b9fc6bba5f6aeff01e37a985eafb7992814372'}, 'syn/board/ia840f/syn_top/fim_base_ip.tcl': {'bytes': 8629, 'sha256': 'f7450eb21300718a8ec2bde00d161c25a151647b5affd933af3f1f6bc540f694'}, 'syn/board/ia840f/syn_top/fim_project_macros.tcl': {'bytes': 790, 'sha256': '7e858a4d5d7c54a1727dd09083c35d95f68fe43d674d241355f59f6c6a2df5ea'}, 'syn/board/ia840f/syn_top/fme-ifc-id.txt': {'bytes': 37, 'sha256': '8b1c4bbed434c4d7c57744e841ad3613a764feffd2e6ef4ee8a87f7051f425d5'}, 'syn/board/ia840f/syn_top/ofs_pr_afu.qsf': {'bytes': 7641, 'sha256': '8e651a807fe04b6eaacc35d13472359435229d41ce6f2567db8c384d4eec68ac'}, 'syn/board/ia840f/syn_top/ofs_pr_afu_sources.tcl': {'bytes': 2923, 'sha256': '20673909569e8e7fbbe67ad2d377162a4f1a9853525599fede392d22fab41585'}, 'syn/board/ia840f/syn_top/ofs_top.out.sdc': {'bytes': 487926, 'sha256': 'ccdd8bce2d6aa19aacfb96e1b17d8207bd00eccaaba9319f521fbaf157de27eb'}, 'syn/board/ia840f/syn_top/ofs_top.qpf': {'bytes': 1374, 'sha256': 'cc43f69eb9482389d7794d9a45fd5a51ae804026307518d893be9b5576e35c3f'}, 'syn/board/ia840f/syn_top/ofs_top.qsf': {'bytes': 8249, 'sha256': '801d9ae71588011828e6c217effb0c2292fadec8a08c39ebc5bd972549ca0256'}, 'syn/board/ia840f/syn_top/ofs_top_sources.tcl': {'bytes': 7234, 'sha256': '2056aeb757e8e27eff0aa2589f6e997a52595b095ca18802ecad1819665ba2aa'}, 'syn/scripts/build_var_setup.sh': {'bytes': 11613, 'sha256': '72f9495337c3c6d6e7e8c6147e437ca4b3478559125590adb81787df0d2b8ac9'}}}
def digest(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(4*1024*1024),b''):h.update(b)
 return h.hexdigest()
def inventory(root):
 out={}
 for d,dirs,files in os.walk(root,followlinks=False):
  for name in dirs+files:
   p=Path(d)/name;n=str(p.relative_to(root));st=p.lstat()
   if p.is_symlink():
    target=p.resolve(strict=True);assert target.is_relative_to(root),('symlink escape',n,str(target));out[n]={'kind':'symlink','target':os.readlink(p)}
   elif p.is_file():
    h=digest(p);st2=p.stat();assert (st.st_size,st.st_mtime_ns)==(st2.st_size,st2.st_mtime_ns),n;out[n]={'kind':'file','bytes':st.st_size,'sha256':h}
  assert len(out)<=100000,'inventory cap'
 return out
mem=int(next(l.split()[1] for l in Path('/proc/meminfo').read_text().splitlines() if l.startswith('MemAvailable:')))*1024;free=shutil.disk_usage(B).free;assert mem>80_000_000_000 and free>20_000_000_000
for p in Path('/proc').iterdir():
 if not p.name.isdigit():continue
 try:assert Path(os.readlink(p/'exe')).name not in {'quartus_sh','quartus_syn','quartus_fit','quartus_sta','quartus_cdb','quartus_ipgenerate','vlog','vsim','aoc'},str(p)
 except (FileNotFoundError,ProcessLookupError,PermissionError):pass
for n,e in {**C['artifacts'],**C['selected']}.items():assert (W/n).stat().st_size==e['bytes'] and digest(W/n)==e['sha256'],n
before=inventory(W);root_bytes=sum(e['bytes'] for e in before.values() if e['kind']=='file');assert free>root_bytes*3+10_000_000_000
R.mkdir(parents=True,exist_ok=False)
exclude={'syn/board/ia840f/syn_top/qdb','syn/board/ia840f/syn_top/db','syn/board/ia840f/syn_top/tmp-clearbox','run','compile-candidate-01','compile-candidate-02'}
def excluded(n):return any(n==s or n.startswith(s+'/') for s in exclude)
def ignore(d,names):return [n for n in names if excluded(str((Path(d)/n).relative_to(W)))]
shutil.copytree(W,D,symlinks=True,ignore=ignore,copy_function=shutil.copy2)
relocations={}
for n,e in before.items():
 if excluded(n) or e['kind']!='symlink':continue
 p=D/n;t=e['target']
 if t.startswith(str(W)+'/'):
  new=str(D)+t[len(str(W)):];p.unlink();p.symlink_to(new);relocations[n]={'before':t,'after':new}
expected={n:dict(e) for n,e in before.items() if not excluded(n)}
for n,e in relocations.items():expected[n]['target']=e['after']
after=inventory(D);assert after==expected,'candidate differs from exact copy and enumerated symlink relocation'
assert inventory(W)==before,'original Work21 changed'
for n,e in C['artifacts'].items():assert digest(D/n)==e['sha256'],n
out={'scope':'completed-FIM copy only; no vendor/hardware execution','utc':datetime.now(timezone.utc).isoformat(),'original_root':str(W),'staged_root':str(D),'original_inventory':before,'candidate_inventory':after,'excluded_prefixes':sorted(exclude),'symlink_relocations':relocations,'original_unchanged':True,'artifact_bindings':C['artifacts'],'mem_available':mem,'disk_free_before':free,'disk_free_after':shutil.disk_usage(B).free,'original_bytes':root_bytes,'candidate_bytes':sum(e['bytes'] for e in after.values() if e['kind']=='file'),'ready_for_native':False,'reason':'copied legacy gates/absolute text paths remain unissued; inspect and bind release-only successor before native use'}
b=gzip.compress(json.dumps(out,sort_keys=True).encode(),mtime=0);(R/'result.json.gz').write_bytes(b)
subprocess.run(['tmux','load-buffer','-b','ia840f_fim21_pr_stage01','-'],input=b,check=True);subprocess.run(['tmux','set-buffer','-b','ia840f_fim21_pr_stage01_sha256',hashlib.sha256(b).hexdigest()],check=True)
