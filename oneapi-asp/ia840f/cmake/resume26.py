#!/usr/bin/env python3
"""Finish a bound, completed BSP fit from the normal AHLS board callback.

The application still links through ahls -Xshardware -Xstarget. This callback
reuses its exact generated RTL and integration fit instead of resynthesizing.
"""
import gzip
import json
import re
import shutil
from decimal import Decimal
from pathlib import Path


def finish(cfg, kernel, api):
    sha = api.sha
    native = api.native
    original = Path(cfg['completed_kernel']).resolve(strict=True)
    receipt_path = Path(cfg['completed_receipt']).resolve(strict=True)
    if sha(receipt_path) != cfg['completed_receipt_sha256']:
        raise RuntimeError('Completed result receipt changed')
    receipt = json.loads(receipt_path.read_text())
    for key in ('critical_preserved', 'original_preserved'):
        if not receipt.get(key) or not all(receipt[key].values()):
            raise RuntimeError('Completed input preservation failed: ' + key)
    for name in ('kernel_system.sv', 'kernel_system.qip', 'sys_description.hex'):
        if sha(kernel/name) != sha(original/name):
            raise RuntimeError('Compiler RTL differs from the completed fit: ' + name)
    for name, expected in cfg['completed_inputs'].items():
        if sha(original/name) != expected:
            raise RuntimeError('Completed fit input changed: ' + name)
    stage = kernel/'ia840f-native26'
    stage.mkdir(exist_ok=False)
    env = api.tool_env(cfg)
    q = Path(cfg['quartus'])
    edit = str(Path(cfg['sdk'])/'host/linux64/bin/aocl-binedit')
    result = {'variant':cfg['variant'], 'flow':cfg['flow'],
              'compiler_callback':True, 'synthesis_repeated':False,
              'fit_repeated':False, 'hardware_access':False}
    if cfg['completed_kind'] == 'image':
        if not receipt.get('timing_pass') or not receipt.get('RBF_readback_identical'):
            raise RuntimeError('Completed image is not accepted')
        image = Path(receipt['gbs']['path'])
        if sha(image) != receipt['gbs']['sha256']:
            raise RuntimeError('Completed GBS changed')
        report = Path(receipt['resource_report'])
        if sha(report) != cfg['resource_report_sha256']:
            raise RuntimeError('Completed resource report changed')
        api.timing_accept(original/'fim_platform/build/syn/board/ia840f/syn_top')
        shutil.copy2(report, kernel/'acl_quartus_report.txt')
        result.update(low_mhz=receipt['low_mhz'],high_mhz=receipt['high_mhz'])
    elif cfg['completed_kind'] == 'fit':
        if str(receipt.get('native_rc')) != '0' or receipt.get('cmake_rc') != 0:
            raise RuntimeError('Completed Fitter did not pass')
        project = stage/'compiled'
        shutil.copytree(original, project, symlinks=True)
        p = project/'fim_platform/build/syn/board/ia840f/syn_top'
        if sha(p/'ofs_top.qdb') != api.STATIC_SHA:
            raise RuntimeError('Imported static changed')
        sl = p/'asp_design_files.tcl'
        api.materialize(sl)
        text = sl.read_text()
        text = text.replace('"user_clock_operating.sdc"','"user_clock_vendor800.sdc"')
        sl.write_text(text)
        native(stage,'optimization-STA',[str(q/'bin/quartus_sta'),'ofs_top','-c','afu_flat','--mode=finalize'],p,env,1200)
        helper = (p/'ofs_partial_reconfig/user_clock_freqs_compute.tcl').read_text()
        pre = helper.split('\nif { [info script] eq $::argv0 } {',1)[0]
        a = pre.index('proc get_fmax_from_report { clkname required jitter_compensation} {')
        b = pre.index('\n# Returns [fmax1',a)
        fn = pre[a:b].replace('proc get_fmax_from_report {','proc asp78_vendor_fmax {',1)
        fn = fn.replace('if {$metric == "Recovery"} {','if {0 && $metric == "Recovery"} {',1)
        (p/'ofs_partial_reconfig/vendor_clock_helpers.tcl').write_text(pre+'\n'+fn)
        native(stage,'select-clock',[str(q/'bin/quartus_sta'),'-t',str(Path(cfg['board'])/'cmake/select26.tcl')],p,env,300)
        selected = dict(line.split('=',1) for line in (p/'vendor_operating_point.txt').read_text().splitlines())
        lo,hi = int(selected['low']),int(selected['high'])
        clock = (p/'user_clock_vendor800.sdc').read_text()
        needle = 'create_clock -name $asp73_clock_name -period 1.25 $asp73_targets'
        if clock.count(needle) != 1:
            raise RuntimeError('BSP optimization clock setter changed')
        replacement = ('if {[string match *iopll_0_outclk0 $asp73_clock_name]} {set ia26_period '+str(Decimal(1000)/Decimal(hi))+
                       '} else {set ia26_period '+str(Decimal(1000)/Decimal(lo))+'}\ncreate_clock -name $asp73_clock_name -period $ia26_period $asp73_targets')
        (p/'user_clock_operating.sdc').write_text(clock.replace(needle,replacement))
        sl.write_text(sl.read_text().replace('"user_clock_vendor800.sdc"','"user_clock_operating.sdc"'))
        (p/'output_files/user_clock_freq.txt').write_text('afu-image/clock-frequency-low:'+str(lo)+'\nafu-image/clock-frequency-high:'+str(hi)+'\n')
        native(stage,'final-STA',[str(q/'bin/quartus_sta'),'ofs_top','-c','afu_flat','--mode=finalize'],p,env,1200)
        result['STA_records'] = api.timing_accept(p)
        inherited = project/'ia840f-native26/inherited-output_files'
        for name, expected in cfg['base_outputs'].items():
            source = inherited/name
            if sha(source) != expected:
                raise RuntimeError('Matching base output changed: ' + name)
            shutil.copy2(source,p/'output_files'/name)
        native(stage,'assembly',[str(q/'bin/quartus_asm'),'--read_settings_files=on','--write_settings_files=off','ofs_top','-c','afu_flat'],p,env,1200)
        image = p/'output_files/afu_flat.green_region.gbs'
        native(stage,'GBS',['/usr/bin/packager','create-gbs','--rbf',str(p/'output_files/afu_flat.green_region.rbf'),'--gbs',str(image),
                          '--afu-json',str(p/'oneapi_afu.json'),'--set-value','interface-uuid:fc603c44-5c8f-5e94-bcbe-a5780030947c',
                          'clock-frequency-low:'+str(lo),'clock-frequency-high:'+str(hi)],p,env,120)
        native(stage,'resource-report',[str(q/'bin/quartus_sh'),'-t','scripts/gen-asp-quartus-report.tcl','ofs_top','afu_flat'],p,env,180)
        shutil.copy2(p/'acl_quartus_report.txt',kernel/'acl_quartus_report.txt')
        result.update(low_mhz=lo,high_mhz=hi)
    else:
        raise RuntimeError('Unsupported completed artifact class')
    zipped = stage/'image.gbs.gz'
    zipped.write_bytes(gzip.compress(image.read_bytes(),compresslevel=9,mtime=0))
    native(stage,'container-create',[edit,str(kernel/'fpga.bin'),'create'],kernel,env,60)
    native(stage,'container-image',[edit,str(kernel/'fpga.bin'),'add','.acl.gbs.gz',str(zipped)],kernel,env,60)
    result.update(GBS_sha256=sha(image),GBS_path=str(image),resource_report_sha256=sha(kernel/'acl_quartus_report.txt'))
    (stage/'result.json').write_text(json.dumps(result,indent=2))
    print('Completed BSP fit reused by AHLS callback',flush=True)
