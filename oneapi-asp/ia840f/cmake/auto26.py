#!/usr/bin/env python3
"""Create the normal compiler-callback configuration from explicit SDK/PR roots."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--package', required=True)
    p.add_argument('--flow', required=True, choices=('afu_flat','afu_flat_kclk'))
    p.add_argument('--kernel-dir', required=True)
    args = p.parse_args()
    board = Path(args.package).resolve(strict=True)
    kernel = Path(args.kernel_dir).resolve(strict=True)
    sdk = Path(os.environ['INTELFPGAOCLSDKROOT']).resolve(strict=True)
    quartus = Path(os.environ['QUARTUS_ROOTDIR_OVERRIDE']).resolve(strict=True)
    platform = Path(os.environ['OPAE_PLATFORM_ROOT']).resolve(strict=True)
    if not (board/'board_env.xml').is_file() or not (sdk/'bin/ahls').is_file():
        raise RuntimeError('Explicit AHLS and board roots are required')
    if not (quartus/'bin/quartus_sta').is_file():
        raise RuntimeError('Explicit matching Quartus root is required')
    project = kernel/'fim_platform/build/syn/board/ia840f/syn_top'
    static_sha = hashlib.sha256((project/'ofs_top.qdb').read_bytes()).hexdigest()
    if static_sha != 'dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4':
        raise RuntimeError('Compiler selected a different static FIM')
    import xml.etree.ElementTree as ET
    spec = ET.parse(kernel/'board_spec.xml').getroot()
    name = spec.attrib.get('name')
    if name not in ('ofs_ia840f','ofs_ia840f_usm'):
        raise RuntimeError('Compiler board variant unavailable: '+str(name))
    config = kernel/'ia840f-build-config.json'
    cfg = dict(sdk=str(sdk),quartus=str(quartus),platform=str(platform),
               opae='/usr',bbb=str(board/'source/extra/intel-fpga-bbb'),
               variant=name,flow=args.flow,seed='2',board=str(board),
               work=str(kernel),config=str(config))
    with config.open('x') as f:
        json.dump(cfg,f,indent=2)
    z = subprocess.run([sys.executable,str(board/'cmake/build26.py'),'backend',
                        '--kernel-dir',str(kernel),'--config',str(config),
                        '--flow',args.flow])
    raise SystemExit(z.returncode)


if __name__ == '__main__':
    main()
