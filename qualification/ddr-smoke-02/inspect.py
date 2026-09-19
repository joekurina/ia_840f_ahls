import base64
paths=[r/'ipss/mem/qip/mem_ss/mem_ss/sim/mem_ss.v']
paths+=list((r/'ipss/mem/qip/mem_ss').rglob('mem_ss_reset_ctrl_impl.sv'))
paths+=list((r/'ipss/mem/qip/mem_ss').rglob('msim_setup.tcl'))[:1]
# HEX hashes only below
for p in (r/'ipss/mem/qip/mem_ss').rglob('*.hex'):
 if '/sim/' in str(p): print('HEXJSON '+json.dumps({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}))
m=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01')
paths += [m/'source-closure.json',m/'ed_sim_mem/sim/ed_sim_mem.v',m/'ed_sim_mem_group1/sim/ed_sim_mem_group1.v']
for p in paths:
 print('FILEJSON '+json.dumps({'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'data':base64.b64encode(p.read_bytes()).decode()}))
