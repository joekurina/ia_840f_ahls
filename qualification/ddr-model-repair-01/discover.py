import pathlib,os,subprocess,json
r=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01');r.mkdir(exist_ok=False)
env=os.environ.copy();env.update(QUARTUS_ROOTDIR_OVERRIDE='/opt/altera/26.1.1/quartus',PATH='/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/opt/altera/26.1.1/questa_fe/bin:/usr/bin:/bin')
for k in ['LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER']:env[k]='/home/uwb_student00/quartus_26/LR-191011_License.dat'
(r/'environment.json').write_text(json.dumps({k:env[k] for k in ['PATH','QUARTUS_ROOTDIR_OVERRIDE','LM_LICENSE_FILE','MGLS_LICENSE_FILE','SALT_LICENSE_SERVER']},indent=2))
for tool in ['qsys-script','qsys-generate']:
 p=subprocess.run([tool,'--help'],env=env,cwd=r,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT);(r/(tool+'-help.txt')).write_text(p.stdout);print(p.stdout)
p=pathlib.Path('/opt/altera/26.1.1/quartus/sopc_builder');
for f in p.rglob('*'):
 if f.is_file() and f.suffix in ['.tcl','.html'] and f.stat().st_size<3000000:
  t=f.read_text(errors='replace')
  if 'set_component_parameter_value' in t and ('save_component' in t): print('API_DOC',str(f));print(t[:3000])
