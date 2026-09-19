#!/usr/bin/env python3
"""Read/parse/hash/diff only. Not an execution, build or simulation test."""
from pathlib import Path
import hashlib, json, re, difflib
import xml.etree.ElementTree as ET
OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
ASP = ROOT/'new/oneapi-asp'
UP = ROOT/'oneapi-asp'
VENDOR = ROOT/'old_bsp/ia-840/IOFS_BUILD_ROOT/oneapi-asp'
def digest(p):
    b=p.read_bytes()
    return {'size':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def inventory(p):
    return {str(f.relative_to(p)):digest(f) for f in sorted(p.rglob('*')) if f.is_file() and '.git' not in f.parts}
checks=[]
def check(name, condition):
    checks.append({'check':name,'passed':bool(condition)})
def defines(p):
    return set(re.findall(r'^\s*`define\s+(\w+)',p.read_text(),re.M))
manifest=json.loads((OUT/'preservation-manifest.json').read_text())
for x in manifest['records']:
    p=OUT/x['snapshot']
    check('preserved:'+x['snapshot'],digest(p)=={k:x[k] for k in ['size','sha256']})
pre=json.loads((OUT/'pre-edit-active-inventory.json').read_text())
current=inventory(ASP)
changes=[]
for f in sorted(pre.keys()|current.keys()):
    old={k:pre[f][k] for k in ['size','sha256']} if f in pre else None
    now=current.get(f)
    if old != now: changes.append({'path':'oneapi-asp/'+f,'before':old,'after':now})
restored=['common/hardware/common/build/asp_design_files.tcl','common/source/host/CMakeLists.txt','common/source/host/mmd.cpp','common/source/host/mmd_device.cpp','common/source/host/mmd_device.h']
for f in restored: check('exact upstream restoration:'+f,(ASP/f).read_bytes()==(UP/f).read_bytes())
check('IA840F MMD identity selector unchanged',digest(ASP/'common/source/CMakeLists.txt')=={k:pre['common/source/CMakeLists.txt'][k] for k in ['size','sha256']})
selector=(ASP/'common/source/CMakeLists.txt').read_text()
check('explicit IA840F selector and rejection', 'elseif("${ASP_AFU_ID}" STREQUAL "IA840F")' in selector and 'message(FATAL_ERROR "Unsupported ASP_AFU_ID=' in selector)
for root in ['common/source/host','common/hardware/common/build']:
    matches=[]
    for p in (ASP/root).rglob('*'):
        if p.is_file() and any(t in p.read_bytes() for t in [b'mmd_hostchannel', b'asp_hostchannel',b'interfaces/dma_hostchannel',b'DmaHostChannels']):
            matches.append(str(p.relative_to(ASP)))
    check('no experimental implementation/dependency:'+root,not matches)
# All other common files must equal the actual pinned upstream reference.
common_deltas=[]
for f,pin in inventory(UP/'common').items():
    p=ASP/'common'/f
    if not p.exists() or digest(p)!=pin: common_deltas.append(f)
check('only common delta is deliberate MMD board selection',common_deltas==['source/CMakeLists.txt'])
variant_evidence=[]
reference_paths=set(UP/f for f in restored)
reference_paths.update([UP/'common/source/CMakeLists.txt',VENDOR/'common/source/CMakeLists.txt',VENDOR/'common/source/host/mmd_device.cpp',UP/'common/hardware/common/build/rtl/kernel_wrapper.v',UP/'common/hardware/common/build/board_hw.tcl',UP/'common/hardware/common/build/ddr_channel_hw.tcl'])
for name in ['ofs_ia840f','ofs_ia840f_usm']:
    usm=name.endswith('_usm')
    base=ASP/'ia840f/hardware'/name
    vendor=VENDOR/'ia840f/hardware'/name
    upstream=UP/'n6001/hardware'/name.replace('ia840f','n6001')
    xml=ET.parse(base/'board_spec.xml').getroot()
    vx=ET.parse(vendor/'board_spec.xml').getroot()
    ux=ET.parse(upstream/'board_spec.xml').getroot()
    check(name+':vendor device and historical resources',[(e.tag,e.attrib) for e in xml.find('device').iter()]==[(e.tag,e.attrib) for e in vx.find('device').iter()])
    check(name+':reference XML schema/revision',xml.get('version')==ux.get('version') and all(c.get('revision')=='ofs_pr_afu' for c in xml.findall('compile')))
    bankmem=xml.find("global_mem[@name='device0']")
    vbankmem=vx.find("global_mem[@name='device']" if usm else "global_mem[@name='DDR']")
    check(name+':vendor memory metadata', {k:v for k,v in bankmem.attrib.items() if k!='name'}=={k:v for k,v in vbankmem.attrib.items() if k!='name'})
    banks=bankmem.findall('interface')
    vbanks=vbankmem.findall('interface')
    check(name+':two vendor banks',len(banks)==len(vbanks)==2)
    params=dict(re.findall(r'^set\s+(\w+)\s+\{?([^\s}]+)\}?$',(base/'build/parameters.tcl').read_text(),re.M))
    ranges=[]
    for i,(b,v) in enumerate(zip(banks,vbanks)):
        check(name+':vendor bank '+str(i),{k:x for k,x in b.attrib.items() if k not in ['port','type']}=={k:x for k,x in v.attrib.items() if k not in ['port','type']})
        check(name+':modern bank port '+str(i),b.get('port')=='kernel_device0_'+str(i) and b.get('type')=='agent')
        start,size=int(b.get('address'),0),int(b.get('size'),0)
        ranges.append((start,start+size))
        check(name+':address width agrees with bank '+str(i),size==1<<int(params['p_MEM_0_MEMORY_BANK_ADDRESS_WIDTH']))
    check(name+':nonoverlap and capacity',ranges[0][1]<=ranges[1][0] and sum(e-s for s,e in ranges)==32*1024**3)
    check(name+':parameters retain reference DMA and no iopipes',params['p_NUMBER_OF_DMA_CHANNELS']=='1' and params['p_NUMBER_OF_GLOBAL_MEMORY_SYSTEMS']=='1' and params['p_MEM_0_NUMBER_OF_MEMORY_BANKS']=='2' and params['p_IOPIPE_SUPPORT']=='false' and params['p_MEM_0_DATA_WIDTH']=='512')
    host=xml.find("global_mem[@name='host']")
    check(name+':USM variant split',(host is not None)==usm)
    if usm:
        check(name+':reference host window',ET.tostring(host)==ET.tostring(ux.find("global_mem[@name='host']")))
        h=host.find('interface')
        check(name+':USM host/device nonoverlap',int(h.get('address'),0)+int(h.get('size'),0)<=ranges[0][0])
    flags=defines(base/'build/rtl/ofs_asp.vh')
    vf=defines(vendor/'build/rtl/opencl_bsp.vh')
    for flag in ['INCLUDE_USM_SUPPORT','USM_DO_SINGLE_BURST_PARTIAL_WRITES','USE_KERNEL_IRQ','USE_F2H_IRQ','USE_H2F_IRQ','USE_WR_FENCE_FLAG','USE_WRITEACKS_FOR_KERNELSYSTEM_LOCALMEMORY_ACCESSES']:
        check(name+':vendor flag '+flag,(flag in flags)==(flag in vf))
    check(name+':reference modern DMA/writeack flags',{'INCLUDE_ASP_DMA','ASP_ENABLE_DMA_CH_0','USE_WRITEACKS_FOR_KERNELSYSTEM_GLOBAL_MEMORY_0_ACCESSES'}<=flags)
    check(name+':bank2/3 disabled',not flags & {'ASP_ENABLE_GLOBAL_MEM_0_BANK_2','ASP_ENABLE_GLOBAL_MEM_0_BANK_3'})
    afu=json.loads((base/'build/oneapi_afu.json').read_text())['afu-image']['accelerator-clusters'][0]
    uuid=afu['accelerator-type-uuid']
    halves=f"{int(params['p_AFU_ID_H'],0):016x}{int(params['p_AFU_ID_L'],0):016x}"
    check(name+':UUID agreement',uuid.replace('-','').lower()==halves and uuid in selector and uuid in (VENDOR/'common/source/CMakeLists.txt').read_text())
    check(name+':named target identity',xml.get('name')==name and afu['name']==name)
    for cmd in xml.findall('compile/generate')+xml.findall('compile/synthesize'):
        check(name+':closed compiler entrypoint',cmd.get('cmd')=='sh build/scripts/source-only-stop.sh')
    for p in [base/'board_spec.xml',base/'build/parameters.tcl',base/'build/rtl/ofs_asp.vh',base/'build/oneapi_afu.json']:
        f=str(p.relative_to(ASP))
        check('board configuration preserved:'+f,digest(p)=={k:pre[f][k] for k in ['size','sha256']})
    for p in [vendor/'board_spec.xml',vendor/'build/rtl/opencl_bsp.vh',upstream/'board_spec.xml',upstream/'build/parameters.tcl',upstream/'build/rtl/ofs_asp.vh',upstream/'build/oneapi_afu.json']: reference_paths.add(p)
    variant_evidence.append({'name':name,'bank_ranges_decimal':ranges,'capacity_bytes':sum(e-s for s,e in ranges),'afu_uuid':uuid,'active_defines':sorted(flags)})
# Existing board locks are retained byte-for-byte, without executing them.
gates=[]
for f in pre:
    if f.startswith('ia840f/') and (f.endswith('.sh') or f.endswith('entry.tcl') or f.endswith('setup-asp.py')):
        gates.append(f)
        check('unchanged source-only lock:'+f,digest(ASP/f)=={k:pre[f][k] for k in ['size','sha256']})
for i,expected in [(0,'MEM_FORMAT_DISCRETE'),(1,'MEM_FORMAT_RDIMM')]:
    p=ROOT/f'old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_intf_{i}.ip'
    el=ET.parse(p).getroot()
    vals={x.get('parameterId'):[c.text for c in x if c.tag.endswith('value')] for x in el.iter() if x.tag.endswith('parameter')}
    check('vendor physical memory '+str(i),vals.get('MEM_DDR4_FORMAT_ENUM')==[expected] and vals.get('MEM_DDR4_DQ_WIDTH')==['64'])
    reference_paths.add(p)
refroot=ROOT/'new/reference/hostpipe-abi'
rm=json.loads((refroot/'source-manifest.json').read_text())
for x in rm['files']:
    p=refroot/x['path']
    check('retained reference hash:'+x['path'],digest(p)['sha256']==x['sha256'])
    reference_paths.add(p)
# Retain exact diff of all live changes, including losslessly archived deletions.
diff=[]
for x in changes:
    f=x['path'].removeprefix('oneapi-asp/')
    old=(OUT/'pre-edit/oneapi-asp'/f).read_text().splitlines(True)
    new=(ASP/f).read_text().splitlines(True) if (ASP/f).exists() else []
    diff.extend(difflib.unified_diff(old,new,fromfile='pre-edit/oneapi-asp/'+f,tofile='active/oneapi-asp/'+f))
(OUT/'baseline-separation.diff').write_text(''.join(diff))
report={'scope':'Source parsing, hashes and diffs only; no project scripts, tests, compilers, simulators or vendor tools executed.', 'upstream_commit':manifest['upstream_commit'], 'preserved_files':len(manifest['records']),'changes':changes,'variants':variant_evidence,'gates':gates,'checks':checks,'references':{str(p.relative_to(ROOT)):digest(p) for p in sorted(reference_paths)},'passed':all(x['passed'] for x in checks)}
(OUT/'static-check-evidence.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'passed':report['passed'],'checks':len(checks),'failed':[x['check'] for x in checks if not x['passed']],'preserved_files':len(manifest['records']),'active_changed_files':len(changes),'retained_gate_files':len(gates)},indent=2))
raise SystemExit(0 if report['passed'] else 1)
