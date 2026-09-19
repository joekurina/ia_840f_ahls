# DDR library correction investigation — installed supported path blocked

**No compatible replacement library pair was found in the installed 26.1.1 tree. No vendor HDL fix was applied. Fresh run-03 still fails elaboration: native rc 12, 24 parameter-override errors, zero warnings, no simulation startup or scoreboard completion. `pass=false`, `ready_for_build=false`.**

## Actual execution and faster iteration

- Used only owned windows of `ia840f_mailbox_monitored_01` through SSH `uwb_student00@100.101.227.97`; no direct remote shell operations outside tmux.
- Created a separate hash-bound `run_resolution.py` and `accepted-review.json` in remote/local `qualification/ddr-library-fix-01`. The original smoke runner, harness, manifest and acceptance were not modified.
- Fresh exclusive remote `qualification/ddr-smoke-02/run-03` reused all 144 successful run-02 compile commands. Before reuse, verified every source/HEX hash, original package/tool hashes, exact compilation argv and successful logs, and exact modelsim.ini text. Copied and hash-verified 171 compiled-library files into run-03 rather than compiling unchanged RTL.
- Added only installed documented `-libverbose` and `-voptargs=-libverbose` options to the original elaboration/run argv. The 120-second cap and original run.do/harness/scoreboard/reset/traffic limits remained unchanged. Whole attempt took 5.122 seconds; vendor log reports four seconds.
- Native result: 24 `(vopt-2732)` errors, zero warnings, rc 12; diagnostic driver rc 1. No channel-done or PASS marker. Current acceptance rejects this real result; a synthetic exact two-channel completion fixture remains accepted.
- Input checks remain clean afterward. Original run-02 library file hashes remain unchanged. Eight local/remote historical package and run-01/run-02 result/log hashes match exactly.

## Concrete installed-library findings

1. Actual run-03 mapping diagnostics resolve `tennm_ver` to `/opt/altera/26.1.1/questa_fe/intel/verilog/tennm`. The generated Verilog-before-VHDL order is retained. No path from the older installed `/opt/intelFPGA_pro/23.1` was selected or used.
2. `vdir -l` identifies `tennm_iossm` in that library, compiled from `$MODEL_TECH/../intel/verilog/src/tennm_atoms.sv`, source start line 5821. Its recorded vendor build path is `nightly/26.1.1/130/...`; compile time is August 7, 2026; object format is 2025.3. Tool banner is Questa Altera FPGA Edition 2025.3, 2025.09 (September 15, 2025). These identities are evidence, not proof of a compatible internal primitive implementation.
3. The installed wrapper SHA256 is `af7c871553a92f173a4d774bdf28276438fee0f9a3bddb10e6c1433c3ce3afc3`. Its selected model branch instantiates `tennm_iossm_model_encrypted` with the unsupported overrides at lines 6196–6234. The wrapper's model-branch parameters are unconditional; merely recompiling this identical wrapper cannot remove those overrides. The recorded `EMIF_DISABLE_CAL_OPTIMIZATIONS` vendor compile define is not used as a workaround or a reason to alter calibration.
4. Complete mapped-library `vdir` enumeration, repeated with the correct run-02 cwd, exposes the wrapper but no separately listed `tennm_iossm_model_encrypted` unit. The `tennm_sm` library records the same wrapper source and same source version; it is not evidence of a matching alternative. The protected/internal target's implementation source cannot be established from the available public library metadata; **this report does not claim to have proven its exact hidden implementation or ultimate vendor defect**.
5. The actual generated `msim_setup.tcl` dev_com recipe calls, in order, `vlog -sv .../tennm_atoms.sv -work tennm_ver`, `vlog -sv .../mentor/tennm_atoms_ncrypt.sv -work tennm_ver`, and `vlog -sv .../fmica_atoms_ncrypt.sv -work tennm_ver`. The recipe and SHA256 are captured in `support-path-evidence.json`.
6. `/opt/altera/26.1.1/quartus/eda/sim_lib` contains seven files, but neither `tennm_atoms.sv` nor `mentor/tennm_atoms_ncrypt.sv`. An installed-tree filename inventory found the Questa plain wrapper and formal-verification `eda/fv_lib` candidates, not the matching Mentor simulation encrypted pair. Formal-verification sources are not substituted for simulation models. The existing `fmica_atoms_ncrypt.sv` is not the missing IOSSM source pair.

**Supported-path blocker:** the installed precompiled 26.1.1 wrapper is incompatible with the model interface selected by the installed simulator, and this installation does not provide the matching Mentor simulation source pair required by its own generated rebuild recipe. There is no evidenced supported narrow library replacement to compile from these installed files. A compatible vendor-provided simulator/library package or the matching 26.1.1 simulation source pair is required before a supported correction can be tested. No download, installation, downgrade, vendor patch, stub, decryption, warning/error suppression, full-calibration switch or programming was performed.

## Evidence

- `readback/ddr-smoke-02/run-03/{result.json,elaborate-run.log,modelsim.ini,run.do,output-hashes.json}`: exact remote readback. Result includes full argv, 120-second limit, native status and reused-library SHA256 inventory.
- `readback/ddr-library-fix-01/`: full native diagnostic logs (including both full vdir inventories), installed source candidate inventory, driver and acceptance, launch log/status, and `support-path-evidence.json` with recipe/source excerpts and file hashes.
- `retrieval-verification.json`: all 19 initial exported files individually SHA256-verified; whole export hash verified. The additional support evidence readback SHA256 is `1d58c37ade61a2988dbbddb095203b1954d15b981636fedab5f5ed01962f8c4f`; separately verified against the remote value. `execution-summary.json` records aggregate checks.
- Local named `*.py` inspection scripts preserve the exact commands sent through tmux; `*.txt` are pane captures. Full large logs were transferred through a named tmux buffer, not truncated pane history.

## Diagnostic issues and boundaries

The first `vdir -all` probe used the diagnostic cwd while original mappings were relative; it produced missing-DUT-library diagnostics. It was repeated with correct run-02 cwd and both logs were retained. Initial `-help` only described categories; `-help Library` supplied the actual documented verbosity flags. The vdir exports were large, so full logs were retrieved by a hash-verified tmux buffer. Neither issue altered the DUT or passing/failing classification.

Runs 01/02, Work04 HDL, repaired DDR models, geometry and smoke source files are unchanged. This is an actual failed bounded elaboration attempt plus a concrete installed-package blocker, not a passing DDR smoke or readiness promotion.
