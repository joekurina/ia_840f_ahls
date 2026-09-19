# Fresh source-based tennm rebuild — concrete protected-source compiler failure

**The actual fresh rebuild failed in current Questa after 197.221 seconds compiling the encrypted source: native rc 2, four `vlog-13488` errors, 61 warnings. The plain wrapper compiled successfully. No complete candidate library was produced; elaboration and bounded DDR smoke were not reached. `pass=false`, `ready_for_build=false`, `hardware_qualified=false`.**

## Execution and artifact

- Current compiler: `/opt/altera/26.1.1/questa_fe/bin/vlog`, banner **Questa Altera FPGA Edition-64 vlog 2025.3 Compiler 2025.09 Sep 15 2025**.
- Fresh exclusive attempt: remote `/home/uwb_student00/ahls/new_BSP/qualification/ddr-library-rebuild-01/run-06`.
- Candidate output is the **incomplete, failed** `run-06/libraries/tennm_ver`; it must not be promoted or reused as a valid library.
- The unchanged coherent Quartus 23.1 imported trio was bound by original donor/import hashes. Actual recipe commands used `vlog -sv SOURCE -work tennm_ver` in generated order. No user defines, suppression options, altered calibration switches or source edits were added.
- This is an older-source compatibility experiment using the current compiler, not an official 26.1.1 library or supported-version certification.
- The newly authorized source-build bounds were **1800 seconds total / 1500 seconds per command**, specifically because the previous 120-second watchdog could not diagnose a 1,114,926,857-byte protected source. The simulation/elaboration cap stayed **120 seconds**; no reset, traffic or simulation watchdog extension.

| Stage | Native rc | Measured wall time | Result |
|---|---:|---:|---|
| Plain `tennm_atoms.sv` | 0 | 0.367 s | 0 errors, 0 warnings |
| `mentor/tennm_atoms_ncrypt.sv` | 2 | 197.221 s | 4 errors, 61 warnings |
| `fmica_atoms_ncrypt.sv` | — | — | Not reached after compiler failure |
| Elaboration / DDR smoke | — | — | Not reached; no channel or PASS markers |

Whole attempt including setup and verification: **203.312 seconds**. This failure was not the watchdog.

## Diagnosis

All four current errors are:

`** Error (suppressible): .../mentor/tennm_atoms_ncrypt.sv(40): (vlog-13488) Incorrect size constant for integer literal.`

Line 40 is in the protected source region; compiler output does not expose the offending expressions. There is no source-grounded readable-wrapper correction for this diagnostic. Suppressing an error marked “suppressible,” decrypting/patching protected content, deleting parameters or stubbing models would not establish preserved semantics, so no such action was taken.

The earlier **24 `vopt-2732` unsupported overrides** were independently parsed from run-05 and retained in `readback/diagnosis-v2.json`: `a_iossm_is_calib_master`, `mem_contents_0` through `_3`, `calbus0_interface_id` through `calbus15_interface_id`, `mem_contents_valid`, `mem_contents_updated`, and `nios_fw_file`. The visible wrapper chooses `tennm_iossm_model_encrypted` in the `iossm_use_model` branch. Current generated calibration integration explicitly passes `IOSSM_USE_MODEL(1)`; this was not changed. The model branch passes those overrides unconditionally.

The older wrapper contains no `EMIF_DISABLE_CAL_OPTIMIZATIONS` condition; the visible preprocessor conditions found there concern `QUARTUS_CDC`. The old vendor-precompiled `EMIF_DISABLE_CAL_OPTIMIZATIONS` metadata was **not propagated** to this generated-recipe source build. Its effect inside protected source cannot be established from readable evidence. Thus this fresh compile does not prove which hidden implementation caused the earlier 24 errors, nor that they would persist or disappear after a successful source build. It establishes a separate concrete compatibility blocker in the available protected 23.1 source with the current compiler.

## Reuse, readback and safeguards

- Verified all **144** successful original run-02 compile commands/logs, source/HEX and package/tool hashes, original INI/settings and saved library inventory before copying the unchanged compiled DUT/model libraries. Did not reuse mutated run-03 work-library bytes.
- `modelsim.ini` changes only `tennm_ver` to the fresh candidate; the original generated library search order and exact simulation argv remain in the driver. The original `run.do`, harness, two 16 GiB x64 channels, channel 0 discrete/channel 1 RDIMM, BOT/BOT, reviewed 100-reference-cycle cold reset and two writes/two reads per channel were retained.
- Full before/after library inventories and a final all-file readback inventory are saved. The after inventory contains **177 library files**, including the failed partial candidate. A separate readback confirmed the inventory, original reused libraries, bound inputs and complete donor/import source hashes unchanged.
- SALT/LM/MGLS license paths, exact compiler argv, tool hashes, versions, stage timestamps, native return codes and all untruncated compiler logs are captured. No license-file contents were exported.
- Six synthetic acceptance regressions passed, distinct from actual simulation. Final log parsing additionally recognizes `Error (suppressible):`; the first diagnostic collector missed that spelling and is preserved, with corrected `diagnosis-v2.json` authoritative. Native rc and missing smoke execution already made the attempt fail regardless.
- **22 remote evidence files** were retrieved through owned tmux buffer `ddr_library_rebuild_01_evidence`; whole transfer and every file SHA256 verified. Whole export SHA256: `7f64cde619db27cbe4271dbd9d00aa095a60b3e06bd34d6620eb2872f3421b67`.

Primary local evidence: `readback/execution-summary.json`, `readback/run-06/result.json`, `readback/run-06/compile-import-01.log`, `readback/diagnosis-v2.json`, `readback/source-inspection.json`, `readback/accepted-review.json`, `readback/run_rebuild.py`, and `retrieval-verification.json`. Live/final remote status is `stage-status.json`.

All remote operations ran in owned windows of `ia840f_mailbox_monitored_01`. Writes stayed in new qualification scratch; vendor installations/directories, maintained/generated HDL, repaired models and previous attempts were not edited. No installation/downgrade, programming, commits, error suppression, decryption, detailed calibration, long traffic or extensive reset/error campaign. A compatible vendor source/model package or vendor-supported resolution of the protected literal errors is needed to complete this path; a passing smoke cannot be claimed from these results.
