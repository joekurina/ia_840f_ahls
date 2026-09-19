#!/usr/bin/env python3
"""Bounded source/interface checks, NOT Quartus elaboration or DDR simulation."""
from pathlib import Path
import hashlib, json, re
Q = Path(__file__).resolve().parent
N = Q.parent.parent
C = N / 'ofs-agx7-pcie-attach'
PIN = 'syn/board/ia840f/setup/emif_loc.tcl'
MEM = 'ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv'
def sha(b): return hashlib.sha256(b).hexdigest()
headers = json.loads((N/'qualification/ipgen-04/headers-final-evidence.json').read_text())
for item in headers.values():
    assert sha(item['content'].encode()) == item['sha256']
def header(name):
    return next(v['content'] for k, v in headers.items() if k.endswith('/'+name))
wrapper = header('mem_ss_sv.sv')
info = header('mem_ss_if_info.vh')
assert 'localparam NUM_PORTS = 2;' in header('mem_ss_param_pkg.sv')
assert 'HAS_IFC_MEM_SS_MEM_G1_DDR4_IF' not in info
assert 'mem_ss_mem_ddr4_if.ip mem_ddr4[NUM_PORTS-1:0]' in wrapper
physical = wrapper.split('interface mem_ss_mem_ddr4_if;',1)[1].split('endinterface',1)[0]
fields = {}
for high, name in re.findall(r'^\s*(?:logic|wire)\s+(?:\[(\d+):0\]\s+)?(\w+);', physical, re.M):
    fields[name] = int(high)+1 if high else 1
assert fields['cs_n'] == 1 and fields['dq'] == 64 and fields['a'] == 17

def pins(text):
    return re.findall(r'^set_location_assignment (\S+) -to (\S+)',text,re.M)
def validate_targets(rows):
    bad=[]
    for coord, target in rows:
        target=target.strip('"')
        # (n) is the existing Quartus differential companion assignment,
        # not an invented HDL field; fitter acceptance is not asserted here.
        if re.fullmatch(r'ddr4_mem_ref_clk\[[01]\]\.(clk(?:\(n\))?|oct_rzqin)',target):
            continue
        match=re.fullmatch(r'ddr4_mem\[([01])\]\.(\w+)(?:\[(\d+)\])?',target)
        if not match:
            bad.append(target);continue
        _,field,bit=match.groups()
        if field not in fields or (fields[field]==1 and bit is not None) or (fields[field]>1 and (bit is None or int(bit)>=fields[field])):
            bad.append(target)
    return bad
before=pins((Q/'before'/PIN).read_text()); after=pins((C/PIN).read_text())
assert len(before)==len(after)==241
assert len({p for p,t in after})==241 and len({t for p,t in after})==241
assert [p for p,t in before]==[p for p,t in after]
expected=[(p,t.replace('ddr4_mem_group_1[0]','ddr4_mem[1]').replace('ddr4_mem[0].cs_n[0]','ddr4_mem[0].cs_n')) for p,t in before]
assert expected==after
assert sum('ddr4_mem_group_1[0]' in t for p,t in before)==118
assert len(validate_targets(before))==119
assert validate_targets(after)==[]
assert dict(after)['PIN_HB29']=='ddr4_mem[0].cs_n'
assert all((p,t) in after for p,t in before if 'ref_clk' in t)
text=(C/MEM).read_text(); old=(Q/'before'/MEM).read_text()
removed=text
for signal in ['AWQOS','ARQOS']:
    assert f'`define IFC_MEM_SS_I_AXI_MM_IF_WIDTH_{signal} 4' in info
    pattern=r'`ifdef IFC_MEM_SS_I_AXI_MM_IF_WIDTH_'+signal+r'\n[^`]*?`endif\n'
    block=re.search(pattern,text)
    assert block and re.search(r'assign ss_axi_mm\[c\]\.'+signal.lower()+r"\s*= '0;",block[0])
    assert len(re.findall(r'assign\s+ss_axi_mm\[c\]\.'+signal.lower()+r'\s*=',text))==1
    removed=removed.replace(block[0],'')
assert removed==old, 'QoS repair must be the entire RTL delta'
assert 'for (genvar c = 0; c < NUM_MEM_CHANNELS; c++) begin : axi_mm_map' in text
protected=json.loads((Q/'protected-before.json').read_text())
assert all(sha((C/k).read_bytes())==v for k,v in protected.items())
# Mutated coordinates and stale/scalar aliases must fail the acceptance checks.
assert validate_targets([('PIN_HB29','ddr4_mem[0].cs_n[0]')])
assert validate_targets([('PIN_GW52','ddr4_mem_group_1[0].ba[1]')])
assert validate_targets([('PIN_FK52','ddr4_mem[1].dq[64]')])
result={'status':'PASS','scope':'source and captured generated-interface checks only',
        'memory_pin_assignments':len(after),'preserved_package_coordinates':len(after),
        'renamed_rdimm_targets':118,'scalar_cs_n_corrections':1,
        'before_unmatched_hdl_target_spellings':119,'after_unmatched_hdl_target_spellings':0,
        'differential_companion_requires_quartus_fit':True,
        'qos':'two guarded zero assignments; one driver per field in each generated channel',
        'protected_files_unchanged':len(protected),'negative_target_fixtures':3,
        'DDR_simulation':'SKIPPED BY USER','Quartus_elaboration':'NOT RUN',
        'ready_for_build':False}
print(json.dumps(result,indent=2))
