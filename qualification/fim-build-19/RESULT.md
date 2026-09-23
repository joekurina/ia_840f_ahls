# Work19 native failure — Python/OpenSSL loader collision

Status: **FAILED / SPENT**, no fit or timing conclusion. Native launched2026-09-23T04:49:10Z, explicitly stopped2026-09-23T04:50:39Z after guard rejection. Raw native rc−15, outer143; no owned non-zombie descendants remained in `stop-failed01.json`. Source/RTL and predecessor preservation passed preparation, but that does not accept the failed compile.

## Observed cause and bounded correction

The actual25.1 post-IP callback emitted Critical Warning125091 with `_hashlib` failing because `/opt/altera/25.1/quartus/linux64/libcrypto.so.3` lacks `OPENSSL_3.4.0`. Quartus continued into synthesis; parent stopped only the PID/start-bound native tree using pidfds. [Failure capture](failure-readback01/home/uwb_student00/ahls/new_BSP/qualification/fim-build-19/run/native.log) retains the full log; [termination](stop-failed01.json) records process identities/signals and remaining-task check.

A fresh native no-project25.1 diagnostic reproduced RAW_RC=1 and CLEAN_RC=0 when invoking Python with `/usr/bin/env -u LD_LIBRARY_PATH`. The successful operation imported hashlib,uuid,ssl and computed SHA256/UUID5. No system library, Python installation, vendor installation, or global shell change was made. Diagnostic package `python-env-diagnostic01.json.gz` SHA256 `3b7ca2a2b75ff3d2fc52a54134ef30b2106d471424af6efb41ce4d6fd76662f7`.

The inspected native Tcl source subtrees have two Python call sites: build_gate.tcl and update_fme_ifc_id.py invocation in ofs_post_module_script_fim.tcl. Work20 adds the clean environment prefix only to those calls, preserves all design inputs, and uses a fresh worktree/claim. No hardware operations. Work19 cannot establish hold closure or license checkout acceptance. Independent result review pending.
