#!/usr/bin/env python3
"""Local-only preparation and bounded real-simulator runner; no installs."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
PIM = ROOT / 'ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl'
DUT = ROOT / 'afu/ahls/rtl/ahls_avmm_byte_to_line.sv'
headers = ['ofs_plat_if.vh', 'ofs_plat_clocks.vh', 'ofs_plat_host_ccip_if.vh',
           'ofs_plat_avalon_mem_if.vh', 'ofs_plat_avalon_mem_rdwr_if.vh',
           'ofs_plat_axi_mem_if.vh', 'ofs_plat_axi_stream_if.vh']
deps = [PIM/'utils/ofs_plat_log_pkg.sv',
        PIM/'base_ifcs/avalon/ofs_plat_avalon_mem_if.sv', DUT]
for name in headers:
    matches = list(PIM.rglob(name))
    if len(matches) != 1:
        raise RuntimeError(f'Expected unique actual dependency {name}: {matches}')
    deps.append(matches[0])

def pins():
    return {str(p): {'size': p.stat().st_size,
                    'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
            for p in deps}

before = pins()
(HERE/'original-inputs.before.json').write_text(json.dumps(before, indent=2)+'\n')
includes = sorted({str(p.parent) for p in deps})
sources = [str(p) for p in deps[:3]] + [str(HERE/'tb.sv')]
(HERE/'sources.f').write_text('\n'.join(['+incdir+'+str(HERE)] +
    ['+incdir+'+p for p in includes] + sources)+'\n')
probe = subprocess.run(['bash','-c',
    'for t in verilator iverilog vvp vsim vlog xrun vcs slang; do '
    'printf "%s: " "$t"; command -v "$t" || printf "NOT_FOUND\\n"; done'],
    text=True, capture_output=True)
(HERE/'discovery.log').write_text('PATH='+os.environ.get('PATH','')+'\n'+probe.stdout+probe.stderr)
commands = []
def run(argv, log, timeout):
    commands.append(argv)
    (HERE/'argv.json').write_text(json.dumps(commands, indent=2)+'\n')
    try:
        with (HERE/log).open('w') as output:
            result = subprocess.run(argv, cwd=HERE, stdout=output,
                                    stderr=subprocess.STDOUT, timeout=timeout)
        return result.returncode
    except subprocess.TimeoutExpired:
        with (HERE/log).open('a') as output: output.write('\nRUNNER TIMEOUT\n')
        return 124

status = {'scope':'normalized adapter only; not BSP/full AFU/CDC/hardware/integration qualification',
          'planned_scenarios':154, 'actual_checked_scenarios':0,
          'compile_rc':None,'simulation_rc':None,
          'configuration_fixture':'ofs_plat_if_top_config.vh; no board class definitions',
          'simulator_versions':{}}
verilator = shutil.which('verilator')
if verilator:
    run([verilator,'--version'], 'version.log', 10)
    status['simulator_versions']['verilator']=(HERE/'version.log').read_text().strip()
    argv = [verilator, '--binary', '--timing', '--assert', '-Wno-fatal',
            '--top-module', 'tb', '--Mdir', str(HERE/'obj_dir'),
            '-f', str(HERE/'sources.f')]
    status['compile_rc'] = run(argv, 'compile.log', 180)
    if status['compile_rc'] == 0:
        status['simulation_rc'] = run([str(HERE/'obj_dir/Vtb')], 'simulation.log', 30)
        text = (HERE/'simulation.log').read_text()
        status['actual_checked_scenarios'] = len(re.findall(r'^CHECKED \d+ ',text,re.M))
        status['status'] = ('PASS' if status['simulation_rc']==0 and
            status['actual_checked_scenarios']==154 and 'PASS scenarios=154 ' in text
            else 'FAIL')
    else:
        status['status']='COMPILE_BLOCKED'
else:
    status['status']='SIMULATOR_ABSENT'
    status['blocker']='No Verilator in PATH; local command-v probes found no HDL simulator. No compile or simulation executed.'
    (HERE/'compile.log').write_text('NOT RUN: no supported local simulator found.\n')
    (HERE/'simulation.log').write_text('NOT RUN: 0 scenarios checked.\n')
    (HERE/'version.log').write_text('Unavailable: no simulator executable found.\n')
    (HERE/'argv.json').write_text(json.dumps(commands,indent=2)+'\n')
after = pins()
(HERE/'original-inputs.after.json').write_text(json.dumps(after,indent=2)+'\n')
status['original_sources_unchanged'] = (before == after)
if before != after: status['status']='INPUT_CHANGED'
status['runner_rc'] = 0 if status['status']=='PASS' else 2
(HERE/'result.json').write_text(json.dumps(status,indent=2)+'\n')
print(json.dumps(status,indent=2))
sys.exit(status['runner_rc'])
