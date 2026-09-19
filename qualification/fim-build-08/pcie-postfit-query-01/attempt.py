from pathlib import Path
import os,subprocess,hashlib,json,time
w=Path('/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08')
e=Path('/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-01')
s=e/'scratch';s.mkdir()
p=w/'syn/board/ia840f/syn_top'
def inventory():
 out={}
 for x in sorted(p.rglob('*')):
  if x.is_file() and not x.is_symlink():
   h=hashlib.sha256()
   with x.open('rb') as f:
    for b in iter(lambda:f.read(4*1024*1024),b''):h.update(b)
   out[str(x.relative_to(w))]=h.hexdigest()
 return out
before=inventory();(e/'before.json').write_text(json.dumps(before,indent=2))
# Preserve every project and database byte; do not edit or replace the gate.
for rel in ['syn/board/ia840f/syn_top','syn/board/ia840f/setup','ofs-common/tools/ofss_config']:
 dst=s/rel;dst.parent.mkdir(parents=True,exist_ok=True)
 subprocess.run(['cp','-a','--reflink=auto',str(w/rel),str(dst)],check=True,timeout=60)
t=e/'query.tcl'
t.write_text('''load_package sta
project_open -revision ofs_top ofs_top
# Never continue if Quartus downgrades the source-bound rejection.
if {[info exists ia840f_gate_result]} {error "SOURCE_BOUND_GATE_REJECTION_STOP"}
create_timing_netlist
read_sdc
update_timing_netlist
foreach_in_collection c [get_cells -hierarchical *] {
 set n [get_cell_info -name $c]
 if {[string match *clkdiv_inst* $n] || [regexp -nocase {osc|TRS} $n]} {
 puts "RESOURCE $n TYPE [get_cell_info -wysiwyg_type $c] INPUT [get_cell_info -in_pin_names $c] OUTPUT [get_cell_info -out_pin_names $c]"
 }
}
foreach_in_collection c [get_clocks *] {
 set n [get_clock_info -name $c]
 if {[regexp -nocase {100m|avmm|osc|TRS} $n]} {puts "CLOCK $n PERIOD [get_clock_info -period $c] MASTER [get_clock_info -master_clock $c] DIV [get_clock_info -divide_by $c]"}
}
delete_timing_netlist
project_close
''')
env=os.environ.copy();env['QUARTUS_ROOTDIR_OVERRIDE']='/opt/altera/26.1.1/quartus';env['LM_LICENSE_FILE']='/home/uwb_student00/quartus_26/LR-191011_License.dat'
cmd=['/opt/altera/26.1.1/quartus/bin/quartus_sta','-t',str(t)]
binding={'argv':cmd,'cwd':str(s/'syn/board/ia840f/syn_top'),'tool_sha256':hashlib.sha256(Path(cmd[0]).read_bytes()).hexdigest(),'script_sha256':hashlib.sha256(t.read_bytes()).hexdigest(),'source_inventory':'before.json','scope':'finite post-fit query only; existing gate unmodified; reject means stop'}
(e/'query-binding.json').write_text(json.dumps(binding,indent=2))
with (e/'query.log').open('w') as f:
 try:r=subprocess.run(cmd,cwd=binding['cwd'],env=env,stdout=f,stderr=subprocess.STDOUT,timeout=80);rc=r.returncode
 except subprocess.TimeoutExpired:rc=124
print('QUERY_RC',rc); print((e/'query.log').read_text()[-16000:])
after=inventory();(e/'after.json').write_text(json.dumps(after,indent=2));(e/'result.json').write_text(json.dumps({'rc':rc,'original_project_unchanged':before==after,'file_count':len(before)})); print('UNCHANGED',before==after,len(before))
