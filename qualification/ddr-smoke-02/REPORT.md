# Work04 bounded two-channel DDR smoke — executed, FAILED at elaboration

**Actual HDL compilation and elaboration were executed in two fresh attempts. Neither reached simulation startup or traffic. `pass=false`, `ready_for_build=false`.**

Local package: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/ddr-smoke-02`.
Remote package: `/home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02`.
All remote actions used owned windows in `ia840f_mailbox_monitored_01` on `uwb_student00@100.101.227.97` (observed host `Agilex7Workstation`). Existing monitoring was untouched. Normal-account scratch, not an OS sandbox.

## Changes and verification

- Fixed the reproduced false-PASS detector in `run_smoke.py`: case-insensitive word-boundary `Error:` / `Fatal:` with optional whitespace before the colon now match anywhere, including timestamp/DWR and `Internal Error:` prefixes. Retained DDR_SMOKE_FAIL, design-loading and license failure checks.
- Expanded `review/parser-regression.py`: 11 diagnostic fixtures are detected and rejected by acceptance, while a clean completion fixture and two informational lines remain accepted. Timeout/nonzero, missing and duplicate completion fixtures are rejected. Python-only tests; not simulation evidence.
- Ran existing `inert_check.py` successfully before both attempts: 128 DUT ports, 32 model connections, 142 ordered IP commands, 27 design libraries, five HEX files, parser fixtures, real Python child timeout/nonzero handling, and early review rejection. The original inert receipt's reset-source field remains false; it does not claim protocol proof.
- Issued and hash-bound `accepted-review.json` under the existing authorization; no additional review delegation or approval loop. Its legacy `reset_sequence_source_accepted=true` means the reviewed **bounded startup experiment** is accepted. `reset_protocol_source_proven=false`, `hardware_qualified=false`, and `ready_for_build=false` are explicit.
- First native elaboration feedback exposed device-library search ordering. Corrected only the runner's `-L` order to match generated `msim_setup.tcl`: Verilog libraries before VHDL libraries. All 20 original mappings remain, and IP source order is unchanged. Re-ran regressions, rebound acceptance, staged and verified exact readback, then executed a fresh run-02.
- Original runner/receipts/report and pre-order-fix runner/acceptance remain under `evidence/pre-parser-fix` and `evidence/pre-library-order-fix`. Remote originals were preserved likewise and retrieved under `remote-receipts/evidence/`.
- No maintained/generated HDL, model HDL, manifest inputs, geometry, calibration modes, scoreboard, traffic or timeout bounds were changed. No commits or programming.

## Actual results

| Attempt | Compile commands rc=0 | Elaboration native rc | Vendor errors / warnings | Runner native rc | Scoreboard markers |
|---|---:|---:|---:|---:|---:|
| run-01 | 144 / 144 | 12 | 638 / 4388 | 1 | 0 channel, 0 PASS |
| run-02 | 144 / 144 | 12 | 24 / 0 | 1 | 0 channel, 0 PASS |

Each attempt recorded 175 steps: two version checks, 28 vlib invocations, 144 compile commands (DPI + 142 IP/model commands + harness), and one combined elaboration/run invocation. Total recorded wall time was 28.557 s and 28.244 s, respectively. No timeout cap was reached or extended. The runner's `hdl_executed=true` includes compilation; it must **not** be read as successful time-advancing simulation.

Both attempts verified all 148 manifest source/HEX inputs before and after, with no mismatches. Both real repaired models and Work04 DUT were compiled without modification. No accepted transaction count is available because elaboration failed before startup; zero completion markers are observed, not a successful zero-traffic test.

### Remaining concrete blocker

run-02 reports 24 `(vopt-2732) Module parameter ... not found for override` errors from the installed precompiled `tennm_iossm` wrapper at:

`$MODEL_TECH/../intel/verilog/src/tennm_atoms.sv`, lines 6196–6234.

The wrapper instantiates `tennm_iossm_model_encrypted`. Rejected overrides include `a_iossm_is_calib_master`, `mem_contents_0` through `mem_contents_3`, `calbus0_interface_id` through `calbus15_interface_id`, `mem_contents_valid`, `mem_contents_updated`, and `nios_fw_file`. Optimization aborts with `Error loading design`; native vsim exit is 12.

Matching generated library order removed the protected FIFO errors and all 4,388 warnings, but did not remove this separate installed IOSSM interface mismatch. Read-only targeted inspection confirms the wrapper calls and installed library source provenance. `vdir` identifies `tennm_iossm` in the installed Verilog library; the encrypted target is not exposed as a separately listed unit there. The original Quartus sim_lib directory does not contain `tennm_atoms.sv` or a mentor encrypted-source tree from which to rebuild the normal generated device closure. Its `fmica_atoms_ncrypt.sv` declares `tennm_fmica_core`, not a replacement IOSSM model. The evidence does not prove the ultimate vendor-internal cause.

No vendor HDL edit, parameter removal, diagnostic suppression, force, calibration bypass or full-calibration switch was attempted. Resolving the installed IOSSM model/wrapper compatibility is the next concrete blocker; no DDR readback success or hardware qualification is claimed.

## Exact commands and tools

Both attempts used this command shape, substituting `run-01` / `run-02` only for the fresh output:

```sh
python3 /home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02/run_smoke.py \
  --execute \
  --review-record /home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02/accepted-review.json \
  --output /home/uwb_student00/ahls/new_BSP/qualification/ddr-smoke-02/run-02
```

Absolute tools: `/opt/altera/26.1.1/questa_fe/bin/{vlib,vlog,vsim}`; version logs identify Questa 2025.3. SALT_LICENSE_SERVER, LM_LICENSE_FILE and MGLS_LICENSE_FILE used the existing runner's `/home/uwb_student00/quartus_26/LR-191011_License.dat`. No license contents were retrieved. Exact child argv, timeout, log name and native rc are in each `result.json`; launcher command/native status are in `remote-receipts/run-0*-launch-rc.json`.

Original bounds remain: 600 s compile total, 120 s per compiler, 120 s combined elaboration/run, 500 us startup, 1 ms simulation watchdog, 4096 user-clock cycles per transaction. Intended traffic remains exactly two full-strobe 512-bit writes and two reads per channel, addresses 0 and 64. Both 16 GiB x64/noECC channels retain discrete channel 0 / RDIMM channel 1, BOT/BOT, fast simulation, skip calibration, abstract PHY off. Initial cold reset remains the reviewed 100-reference-cycle bounded stimulus, not source-proven reset protocol.

## Local evidence and hashes

- `execution-summary.json`: mechanically counted stages, native statuses, marker counts and hashes.
- `run-01/result.json`, `run-02/result.json`: complete invocation/result records.
- `run-01/elaborate-run.log`, `run-02/elaborate-run.log`: full native error logs; full compiler logs and simulator transcripts are also retained.
- `run-01/retrieval-verification.json`, `run-02/retrieval-verification.json`: each confirms SHA256 verification of 179 retrieved files against remotely computed hashes.
- `remote-receipts/retrieval-verification.json`: 44 root/diagnostic/original files retrieved and SHA256 verified. Final remote runner and accepted record also match the local files byte-for-byte.
- `review/parser-fixed-result.json`, `review/run-02-parser-regression.json`, and inert regression outputs: passing synthetic tests bound to each runner version.
- `review/library-inspection.txt`, `review/simlib-inventory.txt`, `review/iossm-binding.txt`, `review/iossm-compile-default.txt`, `remote-receipts/library-diagnostic-*`: targeted integration evidence.

Final runner SHA256: `0c252c40bd1066024c6120617bfe4b16dd8820cfdd60bf19ee00c3dea7a67dd9`.
Final acceptance SHA256: `e884ddd7f9d657374344387e0f3f7bf92691c1bc1530c8dcd153673197c3a2e3`.
run-02 result SHA256: `4d93808640f2b13d7cf6e6b038fdab8f3bbcf8b6cddce8a031e826c1b3a9319f`.
run-02 elaboration log SHA256: `5b05c54544ebde5992f9d3d10475ae9f1a91091b9abf728a5c90e8c35faed490`.

## Evidence-handling issues

One staging helper had a placeholder-substitution SyntaxError before any remote write or vendor invocation; the invalid script is preserved and a syntax-checked corrected helper launched run-02. One oversized receipt export exceeded tmux history; it was re-exported in bounded chunks, with the complete transfer hash and every decoded file hash verified. Neither issue overwrote an attempt or affected native results. Earlier preparation evidence remains historical, not evidence of a passing smoke.
