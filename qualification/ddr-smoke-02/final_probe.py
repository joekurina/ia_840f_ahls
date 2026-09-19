import importlib.util
root=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02')
m=json.loads((root/'manifest.json').read_text())
spec=importlib.util.spec_from_file_location('runner',root/'run_smoke.py');runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)
print('FINAL_INPUTS '+json.dumps({'count':len(m['inputs'])+len(m['hex_files']),'mismatches':runner.check_inputs(m),'ready_for_build':False,'hdl_executed':False}))
for x in m['inputs']:
 p=pathlib.Path(x['path'])
 if p.suffix=='.v':
  print('MODES '+json.dumps({'path':str(p),'lines':[l.strip() for l in p.read_text().splitlines() if any(k in l for k in ['DIAG_FAST_SIM','DIAG_USE_ABSTRACT_PHY'])]}))
print('FILES '+json.dumps(sorted(p.name for p in root.iterdir())))
