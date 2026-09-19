# Work09 experimental compile — FINISHED; timing FAIL

## Final update — 2026-09-19 05:10:39 UTC

Native exit **0**, ended **2026-09-19T05:10:09.842816+00:00**. Assembly successful (0 errors, 1 warning); full compilation reports 0 errors, 950 warnings. Final matching build process set is empty. **Timing acceptance FAIL; readiness, constraint acceptance and functional acceptance remain false.** EMIF0 setup -0.435 ns; EMIF1 setup -0.313 ns; EMIF1 PHY hold -0.004 ns. One unconstrained clock, two input ports and two output ports remain.

Final report, exact two-image byte sizes/SHA256, assembly/native receipts and verified compact transfer: [`monitor-completion-20260919T050902Z/REPORT.md`](monitor-completion-20260919T050902Z/REPORT.md). Prior full STA evidence remains in `monitor-final-20260919T050111Z/`; it was reverified locally, not duplicated. No query04 interaction, source/gate/WORK edits, restart/stop, DDR simulation or hardware action.

## Historical launch handoff (preserved below)

Observed 2026-09-19 04:10:59 UTC, after native start at 04:06:34 UTC. Quartus 26.1.1 synthesis is actually running, not merely queued. No compile completion, timing acceptance or functional acceptance is claimed.

## Issuance and execution

All 30 unique exact hashes listed in the accepted specification/quality reviews were recomputed locally without mismatch. Remote preflight verified 23 package/source-overlay hashes and both actual review records. Consumed timing review covers the four BTI files plus QSF; gate review covers the remaining four gate files; issuer validated the unchanged inherited Work05 three-file DDR source review. Parent disposition is acceptance for experimental execution only.

Within `ia840f_mailbox_monitored_01:build09_execution`, cwd `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-09`:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 issue_authorization.py /home/uwb_student00/ahls/new_BSP/qualification/fim-build-09/consumed-reviews.json > issuance.log 2>&1
PYTHONDONTWRITEBYTECODE=1 python3 launch_native_compile.py > runner-console.log 2>&1
```

Issuer returned 0. Authorization read back SHA256:
`e6cf0894d44051d3dd7a74fde02036350f560764ebcb75df2ad255edb911c4f0`.
Consumed record SHA256:
`92459e2453278a600c681a904b429563f2bcdeff328c2b6588fffbdaf0888162`.
Review SHA256: spec `825d42e51054b050794f69959da8db047daf6dfce6ff08c409d6163f95b6e462`; quality `779da8ec91d2935139b012607821dbef79826435b282aaebd456c494e4e24b1d`.

Runner explicitly selects `/opt/altera/26.1.1/quartus`, including bin and sopc_builder/bin PATH and current license environment per the read instructions. No watchdog was added or changed.

Actual native argv, cwd `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`:

```sh
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_09
```

Live PIDs / Linux start ticks: runner 124991 / 7881963; native shell 125051 / 7882108; Quartus flow 125068 / 7882414; quartus_syn 125101 / 7883313. Actual synthesis argv: `quartus_syn --ipc_flow=17 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top`. Fresh exclusive claim persists. Build continues in tmux; observer window is `build09_observer`.

## Source and native-generated WORK readback

Issuer verified initial WORK inventory and exact SOURCE before-bytes, then applied only the reviewed overlay. Maintained SOURCE changes relative to captured before-bytes are exactly the QSF placement mode plus two gate retargets. All SOURCE overlay hashes still match. No clock reduction, RTL, SDC, pin, DDR or PCIe change was made.

Important native result: Quartus migrated WORK QSF during project loading. The reviewed `SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT` is converted by the tool to `OPTIMIZATION_MODE "HIGH PERFORMANCE EFFORT"` plus `GLOBAL_PLACEMENT_EFFORT "MAXIMUM EFFORT"`, with a deprecation comment and LAST_QUARTUS_VERSION update. SOURCE retains the exact reviewed mode. See `native-generated-qsf.diff`; this is native output, not a manual live edit. All other overlay SOURCE/WORK hashes match. An initial observer's post-launch equality assertion therefore failed; the replacement observer records the migration rather than asserting false byte equality. Neither observer changes the build or gate.

## Evidence and limits

Remote evidence root: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-09`.
- `run/native.log`, `run/status.json`, `run/invocation.json`, `runner-console.log`.
- `compile-authorization.json`, `native-compile.claim.json`, `consumed-reviews.json`, both review files, `issuance-preflight.json`, `issuance.log`.
- `launch-observation-20260919T041059Z.json` (SHA256 `d172de4f53e7b139c19d2d28e4b74fbf202abea2761ee9a198583f68d49594e8`) captures process ancestry, executable paths, argv, start ticks, hashes and current log tail. Local copy verified against remote SHA256.
- `final-marker-check.json`: zero occurrences of all four production rejection markers, including Critical Warning 125091. Native log error/fatal scan is empty at this observation. This is an early snapshot, not final acceptance.
- Local `issued-readback/` holds hash-verified actual authorization, claim, consumed reviews and issuance evidence. Export SHA256 verified `2feead000aae8be73747956c9b7f5c3c901c6bb1eb50b08c86de547f2377ce11`.

Readiness, timing acceptance and functional acceptance remain false. S1/TRS, unconstrained PCIe divider, BMC IRQ/JTAG policy and inherited constraint-completeness issues remain open. Work08 evidence and panes were not modified. Correction to historical REPORT.md: `fim-build-08/timing-review-01/REPORT.md` exists; the prior absence claim is wrong. Its actual hash was reverified in this transition.

No DDR simulation, programming, driver installation, commits, source rebinding or gate weakening. A too-large initial tmux transfer command failed before execution; compressed individual transfers succeeded and were read back exactly. No build restart was needed.
