#!/usr/bin/env python3
"""Link a real AHLS SYCL fat binary with an already fitted matching AOCX.

Use the installed compiler's own frontend/post-link/wrapper/link plan. Only its
single FPGA-backend job is replaced by the supplied image; no hardware is opened.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for field in ('compiler', 'image', 'source', 'output', 'target', 'flow'):
        parser.add_argument('--' + field, required=True)
    args = parser.parse_args()
    image = Path(args.image).resolve(strict=True)
    source = Path(args.source).resolve(strict=True)
    output = Path(args.output).resolve()
    image_hash = sha(image)
    source_hash = sha(source)
    work = output.parent / (output.stem + '-host-link')
    work.mkdir(exist_ok=False)
    temporary = work / 'tmp'
    temporary.mkdir()
    env = dict(os.environ, TMPDIR=str(temporary))
    argv = [args.compiler, '-###', '-DFPGA_HARDWARE', '-Xshardware',
            '-Xstarget=' + args.target, '-Xsbsp-flow=' + args.flow,
            str(source), '-o', str(output)]
    plan = subprocess.run(argv, env=env, capture_output=True, text=True, timeout=60)
    (work / 'compiler-plan.json').write_text(json.dumps({
        'argv': argv, 'rc': plan.returncode, 'stdout': plan.stdout,
        'stderr': plan.stderr}, indent=2))
    if plan.returncode:
        raise RuntimeError('AHLS driver-plan failure: ' + plan.stderr)
    commands = [shlex.split(line.strip()) for line in plan.stderr.splitlines()
                if line.lstrip().startswith('"')]
    if not 1 < len(commands) < 50:
        raise RuntimeError('Unexpected AHLS plan command count')
    allowed = {'clang-21', 'llvm-link', 'clang-offload-bundler', 'sycl-post-link',
               'file-table-tform', 'clang-offload-wrapper', 'clang', 'ld'}
    records = []
    backend_count = 0
    for index, command in enumerate(commands):
        name = Path(command[0]).name
        if name == 'llvm-foreach':
            if not any(Path(token).name == 'aoc' for token in command):
                raise RuntimeError('Unrecognized foreach transformation')
            backend_count += 1
            incoming = Path(next(token.split('=', 1)[1] for token in command
                                 if token.startswith('--in-file-list=')))
            outgoing = Path(next(token.split('=', 1)[1] for token in command
                                 if token.startswith('--out-file-list=')))
            if len(incoming.read_text().splitlines()) != 1:
                raise RuntimeError('Expected exactly one vector-add device image')
            outgoing.write_text(str(image) + '\n')
            records.append({'index': index, 'FPGA_backend_skipped': True,
                            'supplied_AOCX': str(image), 'sha256': image_hash})
            continue
        if name not in allowed or any(Path(token).name in
                {'aoc', 'ahls', 'quartus_fit', 'quartus_syn', 'quartus_asm'}
                for token in command):
            raise RuntimeError('Unexpected host-link command: ' + repr(command))
        result = subprocess.run(command, env=env, capture_output=True,
                                text=True, timeout=180)
        (work / ('stage-' + str(index) + '.log')).write_text(
            result.stdout + result.stderr)
        records.append({'index': index, 'argv': command, 'rc': result.returncode})
        (work / 'progress.json').write_text(json.dumps(records, indent=2))
        if result.returncode:
            raise RuntimeError('AHLS host stage failed: ' + repr(command) +
                               '\n' + result.stdout + result.stderr)
    if backend_count != 1 or not output.is_file():
        raise RuntimeError('Incomplete SYCL fat-binary link')
    if sha(image) != image_hash or sha(source) != source_hash:
        raise RuntimeError('Host-link input changed')
    (work / 'result.json').write_text(json.dumps({
        'output': str(output), 'sha256': sha(output), 'commands': records,
        'FPGA_backend_executed': False, 'AOCX_sha256': image_hash,
        'source_sha256': source_hash, 'hardware_access': False}, indent=2))
    print('AHLS SYCL fat binary linked:', output, flush=True)


if __name__ == '__main__':
    main()
