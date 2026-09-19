import pathlib,json,hashlib,tarfile,subprocess,importlib.metadata as m,sys,os
R=pathlib.Path('/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01');A=json.loads((R/'repair-analysis.json').read_text());B=json.loads((R/'distributions-before.json').read_text());D=json.loads((R/'distributions-after.json').read_text());C=json.loads((R/'csp-resources.json').read_text());I=json.loads((R/'integrity-result.json').read_text())
# Fresh post-import readback checks, including exact SDK tree inventory.
h={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in pathlib.Path('/usr/share/bittware-sdk').rglob('*') if p.is_file()};assert h==json.loads((R/'sdk-hashes-before.json').read_text())
x=subprocess.run([sys.executable,'-m','pip','check'],text=True,capture_output=True);assert x.returncode==0;(R/'pip-check-final.txt').write_text(x.stdout+x.stderr+'\nRC='+str(x.returncode))
for f in ['offline-csp-import.txt','bw-product-help.txt','bw-pip-list.txt']:assert (R/f).read_text().endswith('RC=0')
backup=R/'rollback-user-packages.tar.gz';sha=hashlib.sha256(backup.read_bytes()).hexdigest();manifestsha=hashlib.sha256((R/'rollback-manifest.json').read_bytes()).hexdigest();W=json.loads((R/'wheel-file-verification.json').read_text())
text='''# BittWare SDK 2026.1 Python repair — verified

Repaired the actual user Python 3.9 environment on Agilex7Workstation (UID 1000), not a virtualenv. `/usr/bin/python3` is 3.9.25 and is the interpreter selected by the inspected `bw_pip` shell/Python implementation; BWSDK_ROOT=/usr/share/bittware-sdk, BWSDK_VERSION=2026.1.0. Every remote operation ran in newly owned `pyrepair-*` tmux windows in ia840f_mailbox_monitored_01; monitor panes were untouched.

## Root cause and narrow changes

SDK 2026.1 splits/renames distributions without uninstalling their 2024 predecessors. Old distributions retained incompatible pins and duplicate entry points; several share files with new distributions. Removed only the obsolete BittWare dependency closure and its sole-required grpcio-tools compiler dependency. No active installed reverse dependency remains outside that closure. grpcio's protobuf extra advertises grpcio-tools but is optional, not a base runtime requirement; current SDK modules contain no grpc_tools imports. No network installation, dependency downgrade, broad environment wipe, driver change, or SDK edit.

Removed:
'''
for d in B:
 if d['name'] in A['remove']:text+=f"- {d['name']} {d['version']}\n"
text+='\nReinstalled these exact current bundled wheels using the source-reviewed vendor route `bw_pip --python-exec /usr/bin/python3 install --bittware-only`, with PIP_NO_INDEX=1, PIP_USER=1, PIP_NO_CACHE_DIR=1 and PYTHONDONTWRITEBYTECODE=1. Its implementation uses --force-reinstall --no-deps --no-build-isolation for BittWare wheels only; third-party dependencies were left unchanged. This restores shared namespaces and CLI scripts deleted by old RECORD-based uninstall.\n\n'
for d in D:
 if d['name'] in A['current']:text+=f"- {d['name']} {d['version']}\n"
text+='\nKept: '+', '.join(f'{n} {m.version(n)}' for n in ['pydantic','cffi','grpcio','protobuf'])+'.\n'
text+='\n## Native pip check output\n\nBefore:\n```text\n'+(R/'pip-check-before.txt').read_text()+'\n```\nAfter, repeated after imports:\n```text\n'+(R/'pip-check-final.txt').read_text()+'\n```\n'
text+='\n## Bundled and installed IA840F CSP\n\nWheel: `/usr/share/bittware-sdk/python/bw_agilex_product-0.1.49-py3-none-any.whl` (SHA256 `01ecc9b347f6ef8a8d730323d1c2f54ba865167a38d0988406fff53b91b1c2bf`). All nine following installed files were byte-hash compared to their wheel members:\n\n'
for c in C:text+=f"- `{c['path']}`\n  SHA256 `{c['sha256']}`\n"
text+='''
## Read-only host validation

- `bw_pip --python-exec /usr/bin/python3 list`: rc 0, live installed/bundled versions; full output retained.
- Actual installed `~/.local/bin/bw_product --help` executed through runpy with the same interpreter: rc 0, native usage output retained. Source reviewed first: product registry loading is static; card discovery is not invoked. We deliberately did not run bw_card_list (even its parser consults kit interfaces), programming utilities, or tests.
- Offline import of `bw_agilex.products.ia840f_product.IA840FProduct`: rc 0, actual class paths resolve to installed data. `importlib.resources.files('bw_agilex')` agrees with class data_directory. Card YAML validates through the vendor's real Pydantic CardDescriptionModel; card-test JSON parses; test-plan paths enumerate. No fake product instance or synthesized output used.
- Import/help subprocesses used a defense-in-depth Python audit guard denying device/sysfs opens, file writes, arbitrary subprocesses, sockets and arbitrary dlopen. Allowed only normal Python ctypes handle, libpthread.so.0, read-only `/sbin/ldconfig -p` lookup, and /dev/null after source inspection showed those import requirements. The initial over-strict guard stopped at standard ctypes load; corrected guard passed, with no blocked audit events on final resource validation. No semaphore methods or card methods called.
'''
text+=f"\n## Integrity and rollback\n\n- {I['sdk_files_unchanged']} original SDK files unchanged; exact tree hash inventory repeated after final host imports. Vendor source directories were never written.\n- {I['unrelated_files_unchanged']} unrelated installed distribution files unchanged by SHA256.\n- All {I['wheels_verified']} current wheels' bw_* Python/package resource payloads verified against installed bytes ({sum(w['files_verified'] for w in W)} files). CLI targets verified for every current console entry point. Generic top-level docs/ files are not covered by this payload assertion: vendor wheels collide there (initial broad check found docs/index.md disagreement), so do not interpret this as full RECORD equality for shared documentation.\n- Before uninstall: snapshot of 2,499 existing affected package/script files including all old dist-info/RECORD metadata, plus full environment distribution/requirement/location/entry-point inventory and pip freeze. Archive members were read back and every hash checked before mutation.\n- Rollback archive: `{backup}`; {backup.stat().st_size} bytes; SHA256 `{sha}`.\n- Rollback manifest SHA256 `{manifestsha}`.\n- Restore only as an explicitly requested rollback: stop user Python tool use, review rollback-manifest.json and extract this tar into `/home/uwb_student00` to restore preserved affected files, then re-run same-interpreter pip check. This restores the pre-repair mixed environment and its known dependency conflicts, not a working 2024 dependency set. No automatic rollback performed.\n"
text+='''
Key evidence: repair-analysis.json (reverse dependencies and exact RECORD intersections), distributions-before/after.json, rollback-manifest.json, uninstall.txt, vendor-reinstall.txt, pip-check-before/after/final.txt, wheel-file-verification.json, csp-resources.json, bw-product-help.txt, offline-csp-import.txt, bw-pip-list.txt, sdk/unrelated-hashes-before/after.json. Initial diagnostic failures are retained in local pane transcripts; none changed packages before backup succeeded.

## Scope

This repairs host Python packaging and confirms bundled host CSP resources. It does not supply FPGA RTL/device primitive simulation libraries, solve the DDR model/elaboration blocker, or qualify hardware. No card tests, device discovery, programming, reset, VFIO binding, service reload, groups/sudo, reboot, maintained BSP edits, or commits.
'''
(R/'REPORT.md').write_text(text)
files=[p for p in R.rglob('*') if p.is_file() and p.name not in ('evidence-export.tar.gz','export-manifest.json')];manifest={str(p.relative_to(R)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files};(R/'export-manifest.json').write_text(json.dumps(manifest,indent=2))
with tarfile.open(R/'evidence-export.tar.gz','w:gz') as t:
 for p in files+[R/'export-manifest.json']:t.add(p,arcname=str(p.relative_to(R)),recursive=False)
subprocess.run(['tmux','load-buffer','-b','pyrepair01-export',str(R/'evidence-export.tar.gz')],check=True)
print('EXPORT',len(files), (R/'evidence-export.tar.gz').stat().st_size,hashlib.sha256((R/'evidence-export.tar.gz').read_bytes()).hexdigest());print('REPORT',R/'REPORT.md');print('DONE')
