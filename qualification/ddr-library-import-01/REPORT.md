# DDR older-library import experiment — no passing compatible candidate

**Run-04 compiled the 23.1 wrapper but hit the unchanged 120-second per-command watchdog on the encrypted source. Run-05 imported the complete 23.1 precompiled Verilog device library and actually attempted elaboration with current Questa: native rc 12, 24 parameter-override errors, zero warnings. No simulation startup, channel completion or PASS marker. `pass=false`, `ready_for_build=false`, `hardware_qualified=false`.**

## Donor provenance and focused search

- Donor installation: **Quartus Prime Pro 23.1.0 Build 115, 03/30/2023, patches 0.02iofs, 0.10, 0.30** (actual `quartus_sh --version` captured).
- Current execution tool remained `/opt/altera/26.1.1/questa_fe/bin`: **Questa Altera FPGA Edition 2025.3 / 2025.09**. No tool installation or version downgrade.
- Read-only filename inventories covered `/opt/intelFPGA_pro/23.1`, `/home/uwb_student00/IA-840f/`, and the explicitly added `/home/uwb_student00/Documents/IA-840f installation/`. No vendor file was modified.
- The old installation has a complete Mentor wrapper/encrypted pair and `fmica_atoms_ncrypt.sv`. Its Questa source copies of the wrapper and encrypted file are hash-identical to these Quartus simulation sources. Neither loose vendor directory contained another candidate trio/precompiled `tennm` library matching the focused filenames.
- The two accessible vendor `mem_ss_tg/sim/mentor/msim_setup.tcl` recipes and the current Work04 recipe specify this exact source trio, in this order, into `tennm_ver`. Their paths, hashes and command lines are in `readback/compatibility-evidence.json`. The wrapper has no text include dependencies. Two work-tree recipe paths and some metadata paths were broken absolute vendor symlinks; these are recorded, not followed or repaired.
- Read-only streaming member inventory of `Documents/IA-840f installation/ia840f-ofs-hldasp-2023.1.2-002.tar.gz` completed: **29422 members**, two matching recipe entries (one regular file, one symlink), no candidate primitive source trio/precompiled library. No extraction or installation. RPMs/installers were inventoried, not installed or exhaustively analyzed.

## Imported simulation source files

All copies were created exclusively under remote `qualification/ddr-library-import-01/imports/quartus-23.1/`, preserving the relative paths below `sim_lib`. Before/copy/after SHA256 checks passed.

| Original donor path | Bytes | SHA256 |
|---|---:|---|
| `/opt/intelFPGA_pro/23.1/quartus/eda/sim_lib/tennm_atoms.sv` | 2074957 | `9d41a280c1c5b7253441f6ea13d32bca8a1f3420f41624909abaa9867fa2be2c` |
| `/opt/intelFPGA_pro/23.1/quartus/eda/sim_lib/mentor/tennm_atoms_ncrypt.sv` | 1114926857 | `28c427537190107bc68669ecc3181c63b54930ad69fdd8aaadc7fcdab6b07bef` |
| `/opt/intelFPGA_pro/23.1/quartus/eda/sim_lib/fmica_atoms_ncrypt.sv` | 7997 | `9ee715f180ed90b04a6a9ae6425faef319d0907e6f8d823f21207b6dd7ae72f4` |

The complete precompiled donor `/opt/intelFPGA_pro/23.1/questa_fe/intel/verilog/tennm` was separately copied to `imports/precompiled-23.1/tennm`: **7 files, 269832642 bytes**. `readback/precompiled-import-manifest.json` records every original-relative filename, size and SHA256. Current `vdir` successfully reads its `tennm_iossm`: compiled March 31, 2023; opcode format **2022.4**, object version **75**; original build path identifies `nightly/23.1/115`. Its existing vendor compile definition `EMIF_DISABLE_CAL_OPTIMIZATIONS` is recorded, not newly added as a workaround. A same-release pair is a justified experimental candidate, **not proof of compatibility with the current design/simulator**.

## Actual bounded attempts

### Run-04: source import

Fresh exclusive remote `ddr-library-import-01/run-04` used only the imported trio to replace `tennm_ver`; all other device mappings/search order remained the original current-version settings.

- Current `vlog -sv` compiled the old wrapper: **rc 0, errors 0, warnings 0**.
- Current `vlog -sv` on `mentor/tennm_atoms_ncrypt.sv` did not complete within the original **120-second per-command** timeout. The existing process-group watchdog terminated it and returned **124**. This is a watchdog result, not a reported HDL syntax/decryption error or proof of incompatibility.
- The **600-second aggregate compile budget** and **120-second elaboration/run cap** were not extended. The third file and elaboration were not reached; no partial compiled library was used for the next attempt.
- Full untruncated native logs and exact argv/timeouts are in `readback/run-04/`.

### Run-05: complete precompiled-library import

Fresh exclusive `ddr-library-import-01/run-05` independently copied the complete older vendor-precompiled library, not run-04's partial output. `vdir` accepted its format. The original reviewed elaboration command, including generated Verilog-before-VHDL order and documented resolution verbosity, ran with its original **120-second cap**.

- `modelsim.ini` changes only `tennm_ver` to `libraries/tennm_ver`; actual `-L` resolution points at the run-05 scratch copy.
- Elaboration took **6.575 seconds**, native **rc 12**, **24 `(vopt-2732)` errors, zero warnings**. The older wrapper source locations (6153–6183) still pass unsupported overrides to its selected IOSSM model interface.
- **Zero channel-done and zero PASS markers.** No startup, traffic, or calibration result was obtained.
- This demonstrates that the tested older precompiled replacement does not correct the current failure. It does **not** prove the hidden protected primitive's exact implementation/source identity, nor validate arbitrary cross-release mixing.

## Reuse and verification

The first preflight rejected run-03 library reuse before creating a run directory: its current `work/_lib.qdb` and `work/_lib1_0.qdb` differ from the stored pre-elaboration reuse hashes. We did not bless those changed bytes. The rejected driver/record/log are preserved; corrected, separately hash-bound drivers instead reused the unchanged run-02 compiled libraries after verifying all **144 compile commands**, successful logs, input/HEX hashes, tool/package hashes, and original settings. The run-03 elaboration argv was retained.

Both attempts copied and verified the run-02 library inventory, and confirmed the original remains unchanged afterward. Before/after generated design and HEX checks were clean; all imported/donor source hashes and precompiled donor/import hashes remain unchanged. **9 historical package/result/log files** match the pre-existing local evidence. Read-only vendor recipe hashes remain unchanged.

The original harness, geometry, clocks, two 16 GiB x64 channels, discrete channel 0 / RDIMM channel 1, BOT/BOT, reviewed 100-reference-cycle cold startup, and two writes/two reads per channel are unchanged. Scoreboard acceptance still requires exact completion markers plus no error/fatal diagnostics; six synthetic acceptance regressions passed (`acceptance-tests.json`), explicitly not simulation results.

## Evidence and boundaries

- Local report root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/ddr-library-import-01`.
- `readback/` contains **38 full remote evidence files**, including all native logs, invocation/results, INIs, original run.do files, source/precompiled import inventories, donor/version/recipe evidence, accepted hash-bound records, failed preflight evidence, and both actual drivers.
- Whole named-tmux-buffer transfer SHA256: `a2341b9382e8c2ad342765b63564234388a63e8c20b3e08283ac29941c853a13`. Whole export and every individual file verified (`retrieval-verification.json`). Large source/precompiled binary payloads remain in remote fresh scratch, with full per-file hashes; they were not redundantly transferred as local tool installations.
- Every remote operation ran in owned windows of `ia840f_mailbox_monitored_01`. Writes were confined to new qualification scratch; no writes to vendor directories, installed Quartus/Questa, maintained BSP, Work04, repaired external models, or previous runs. No commits, programming, parameter deletion, stubs, decryption, error suppression, forced calibration, detailed calibration test, long traffic, or extensive reset/error campaign.
- These are experimental source/library imports, not supported-version certification or hardware qualification. Under the unchanged bounds, there is still **no passing compatible replacement**. A source compile completing within the approved bounds, or a vendor-supplied matching current simulator/device-model package, is needed before claiming the library issue resolved.
