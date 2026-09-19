# BittWare SDK 2026.1 Python repair — verified

Repaired the actual user Python 3.9 environment on Agilex7Workstation (UID 1000), not a virtualenv. `/usr/bin/python3` is 3.9.25 and is the interpreter selected by the inspected `bw_pip` shell/Python implementation; BWSDK_ROOT=/usr/share/bittware-sdk, BWSDK_VERSION=2026.1.0. Every remote operation ran in newly owned `pyrepair-*` tmux windows in ia840f_mailbox_monitored_01; monitor panes were untouched.

## Root cause and narrow changes

SDK 2026.1 splits/renames distributions without uninstalling their 2024 predecessors. Old distributions retained incompatible pins and duplicate entry points; several share files with new distributions. Removed only the obsolete BittWare dependency closure and its sole-required grpcio-tools compiler dependency. No active installed reverse dependency remains outside that closure. grpcio's protobuf extra advertises grpcio-tools but is optional, not a base runtime requirement; current SDK modules contain no grpc_tools imports. No network installation, dependency downgrade, broad environment wipe, driver change, or SDK edit.

Removed:
- bw-agilex 2024.3.1
- bw-bmc 0.1.25
- bw-bmc-lite 0.1.0
- bw-common 0.4.64
- bw-mctp 0.2.2
- bw-pldm 0.2.10
- bw-sdk 2024.3.1
- bw-uart-edge 0.1.6
- bw-usb 2024.3.1
- bw-vfio 0.0.1
- grpcio-tools 1.64.1

Reinstalled these exact current bundled wheels using the source-reviewed vendor route `bw_pip --python-exec /usr/bin/python3 install --bittware-only`, with PIP_NO_INDEX=1, PIP_USER=1, PIP_NO_CACHE_DIR=1 and PYTHONDONTWRITEBYTECODE=1. Its implementation uses --force-reinstall --no-deps --no-build-isolation for BittWare wheels only; third-party dependencies were left unchanged. This restores shared namespaces and CLI scripts deleted by old RECORD-based uninstall.

- bw-utils 0.1.5
- bw-usb-devices 0.1.5
- bw-vfio-devices 0.1.19
- bw-pldm-transport 0.1.13
- bw-bmc-utils 0.2.12
- bw-bmc-core-lite 0.1.4
- bw-bmc-core 0.1.14
- bw-achronix-product 0.1.43
- bw-uart-edge-devices 0.1.8
- bw-sysfs-devices 0.0.4
- bw-peripherals 0.1.7
- bw-mctp-transport 0.1.3
- bw-kit 0.1.17
- bw-core-utils 0.1.18
- bw-core 0.1.30
- bw-cmdk-comps-v1 0.1.5
- bw-cmdk 0.1.11
- bw-cardtest-tests 0.1.30
- bw-cardtest 1.5.21
- bw-bmc-abs 0.1.3
- bw-agilex-product 0.1.49

Kept: pydantic 2.11.10, cffi 1.17.1, grpcio 1.78.0, protobuf 6.33.6.

## Native pip check output

Before:
```text
bw-common 0.4.64 has requirement pydantic==1.8.2, but you have pydantic 2.11.10.
bw-sdk 2024.3.1 has requirement pydantic==1.8.2, but you have pydantic 2.11.10.
bw-usb 2024.3.1 has requirement cffi==1.14.6, but you have cffi 1.17.1.
bw-vfio 0.0.1 has requirement cffi==1.14.6, but you have cffi 1.17.1.
bw-vfio 0.0.1 has requirement grpcio==1.64.1, but you have grpcio 1.78.0.
grpcio-tools 1.64.1 has requirement protobuf<6.0dev,>=5.26.1, but you have protobuf 6.33.6.

RC=1
```
After, repeated after imports:
```text
No broken requirements found.

RC=0
```

## Bundled and installed IA840F CSP

Wheel: `/usr/share/bittware-sdk/python/bw_agilex_product-0.1.49-py3-none-any.whl` (SHA256 `01ecc9b347f6ef8a8d730323d1c2f54ba865167a38d0988406fff53b91b1c2bf`). All nine following installed files were byte-hash compared to their wheel members:

- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F/IA-840F.yml`
  SHA256 `d5c8f46aa819b955523eb43c84d33d4ddb45c40ab255908c92e336cb06d50ca5`
- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F/ia-840f_cardtest.json`
  SHA256 `2b4bd3860c64d2c5103e4752d37a5d35c51e3341f69bd42f4a3ec6d0510d1cfc`
- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F/clocks/Si5397-RevA-IA-840-840_R1-Project_base-R3.slabtimeproj`
  SHA256 `75b4284054a92e7f9d0cf91553b21394f0cc39cc7881ebf5c728ec6767edc164`
- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F/clocks/Si5397-RevA-IA-840-840_R1-Project_base-R3_NO_input.slabtimeproj`
  SHA256 `a39681c75502f8fa25e6b2dc97f40c0bbd42808e70b823f650a25e8ba1a82c6e`
- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F/clocks/Si5397-RevA-IA-840-840_R1_base-R3-Registers.h`
  SHA256 `8867b6ae0fd9045cbbff7e04fa0f6e68336ab6b298154831710e8f0975dd086e`
- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F/clocks/Si5397-RevA-IA-840-840_R1_base-R3_NO_input.h`
  SHA256 `350543b09106d5c353215c7a822677958d605f42f95adde26355a578bd5b0ccb`
- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F/clocks/ia840f_reva_si5397_original.h`
  SHA256 `f1ca0525c7053eff9ea854c8356c7c527bba251cb9d514a0e2d6adb4504916a1`
- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/data/IA-840F/test_plans/ia840f_card_test.yaml`
  SHA256 `cf9762e9b1320e6570c3146b5ea577e05debafb1ffab0896508810f59691da33`
- `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/products/ia840f_product.py`
  SHA256 `cc47e0d51091f479530eab919957ea724f84427e1ebee1119ebe7b2b41a25c5e`

## Read-only host validation

- `bw_pip --python-exec /usr/bin/python3 list`: rc 0, live installed/bundled versions; full output retained.
- Actual installed `~/.local/bin/bw_product --help` executed through runpy with the same interpreter: rc 0, native usage output retained. Source reviewed first: product registry loading is static; card discovery is not invoked. We deliberately did not run bw_card_list (even its parser consults kit interfaces), programming utilities, or tests.
- Offline import of `bw_agilex.products.ia840f_product.IA840FProduct`: rc 0, actual class paths resolve to installed data. `importlib.resources.files('bw_agilex')` agrees with class data_directory. Card YAML validates through the vendor's real Pydantic CardDescriptionModel; card-test JSON parses; test-plan paths enumerate. No fake product instance or synthesized output used.
- Import/help subprocesses used a defense-in-depth Python audit guard denying device/sysfs opens, file writes, arbitrary subprocesses, sockets and arbitrary dlopen. Allowed only normal Python ctypes handle, libpthread.so.0, read-only `/sbin/ldconfig -p` lookup, and /dev/null after source inspection showed those import requirements. The initial over-strict guard stopped at standard ctypes load; corrected guard passed, with no blocked audit events on final resource validation. No semaphore methods or card methods called.

## Integrity and rollback

- 151 original SDK files unchanged; exact tree hash inventory repeated after final host imports. Vendor source directories were never written.
- 15491 unrelated installed distribution files unchanged by SHA256.
- All 21 current wheels' bw_* Python/package resource payloads verified against installed bytes (897 files). CLI targets verified for every current console entry point. Generic top-level docs/ files are not covered by this payload assertion: vendor wheels collide there (initial broad check found docs/index.md disagreement), so do not interpret this as full RECORD equality for shared documentation.
- Before uninstall: snapshot of 2,499 existing affected package/script files including all old dist-info/RECORD metadata, plus full environment distribution/requirement/location/entry-point inventory and pip freeze. Archive members were read back and every hash checked before mutation.
- Rollback archive: `/home/uwb_student00/ahls/new_BSP/qualification/bittware-sdk-python-repair-01/rollback-user-packages.tar.gz`; 6409136 bytes; SHA256 `3b238fc54f78c06244cd5a740ec2bec21f121ff1bdcb982a438590c56355a976`.
- Rollback manifest SHA256 `3de72dc8111d151b999490210511eb170508fac69d9c73cf81c3ed85adb1f27f`.
- Restore only as an explicitly requested rollback: stop user Python tool use, review rollback-manifest.json and extract this tar into `/home/uwb_student00` to restore preserved affected files, then re-run same-interpreter pip check. This restores the pre-repair mixed environment and its known dependency conflicts, not a working 2024 dependency set. No automatic rollback performed.

Key evidence: repair-analysis.json (reverse dependencies and exact RECORD intersections), distributions-before/after.json, rollback-manifest.json, uninstall.txt, vendor-reinstall.txt, pip-check-before/after/final.txt, wheel-file-verification.json, csp-resources.json, bw-product-help.txt, offline-csp-import.txt, bw-pip-list.txt, sdk/unrelated-hashes-before/after.json. Initial diagnostic failures are retained in local pane transcripts; none changed packages before backup succeeded.

## Scope

This repairs host Python packaging and confirms bundled host CSP resources. It does not supply FPGA RTL/device primitive simulation libraries, solve the DDR model/elaboration blocker, or qualify hardware. No card tests, device discovery, programming, reset, VFIO binding, service reload, groups/sudo, reboot, maintained BSP edits, or commits.
