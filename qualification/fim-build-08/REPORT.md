# Work08 BTI fix — compilation completed; timing FAILED

## Final disposition (supersedes historical launch status below)

Native compilation finished September 18, 2026 at 20:40:03 PDT, exit 0; full compilation reported 0 errors / 950 warnings. Fitting and assembly completed, but timing acceptance FAILED. `ready_for_build=false`; functional acceptance remains false. No image was programmed.

| Gate | Result |
|---|---|
| Synthesis | PASS; 0 errors / 34 warnings |
| Bank 9A preservation clock | PASS; Info 21650 identifies qsfp_ref_clk at CC19 |
| Fitter | PASS; 0 errors / 202 warnings |
| Timing | FAIL; EMIF1 setup −0.366 ns, EMIF0 setup −0.236 ns, EMIF1 hold −0.004 ns; constraint-completeness issues also remain |
| Assembler | PASS; 0 errors / 1 warning |
| DDR simulation | SKIPPED BY USER |
| Image programming / hardware qualification | NOT RUN |

Remote output inventory (not qualified for programming):
- `ofs_top.sof`: 9,277,992 bytes; SHA256 `01772449f7210f3a7bff9f4327a41b921bb37c56b261a0ed16ccbfec05022d49`.
- `ofs_top.green_region.rbf`: 9,109,504 bytes; SHA256 `9156400055f3947e9ab03c8650b54e50cdd41e6ce70598f7c68fd66767e78a02`.

Evidence: [final completion snapshot](monitor-20260919T033051Z-01e73a/monitor-20260919T033926Z-185997/REPORT.md), its receipt/status/reports and image inventory; [independent timing review](timing-review-01/REPORT.md). STA execution success and native exit zero do not override negative slack or incomplete constraints. The removed TRS exception applicability remains open; no speculative timing exception is accepted.

## Historical launch record (retained, not current status)

Verified at 2026-09-19T02:38:14Z (2026-09-18 19:38:14 PDT). Started 19:37:28 PDT.
Fresh work: `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08`.
Session `ia840f_mailbox_monitored_01`, owned build window `bti08-build`, pane `%324`.
Runner 108156; native 108158; Quartus flow 108175; synthesis 108240 observed alive.
Quartus 26.1.1 IP-generation stage successful (0 errors/0 warnings), reused generated HDL. Synthesis running with exact IPC17 context. No IA840F_GATE_REJECTED or 125091 in captured native log. Fitter, timing and assembly NOT yet verified; BTI fix acceptance requires real fitter result.

## Implemented
- Unconditional `qsfp_ref_clk` input, retaining disabled full HSSI.
- Vendor CC19/BW19 pins and DIFFERENTIAL LVPECL plus six divider parameters, including 156250000 Hz and modern diagnostic `use_as_BTI_clock=TRUE` spelling.
- Board-scoped `bti_refclk.sdc`: 6.400ns, waveform 0/3.200; replaces inappropriate full Ethernet SDC include.
- Two gate constants/dispatch literals retargeted Work07→Work08; unchanged 135 exact contexts, source/tool/dependency/path/ancestry checks. No live gate edits after launch.
- `candidate.patch` is precise diff against fetched remote maintained Work07 source. `feature-matrix.md` documents provenance and preserved contracts.

## Verified
- Fresh Work08 copied/hash-checked from Work04 generation baseline, 170 relocations, inherited QDB/output archived. Work04 inventory unchanged. Previous Work07 authorization/claim preserved; old vendor BSP never written.
- Missing-authorization native shell rejected before log/claim creation.
- Real-path entry/runtime inert regression: 40 invocations, 12 positive and 28 negative; real vendor launch was intercepted during these tests. Fixture source inventory substitutes ALL future overlays (not merely two gate hashes as inherited test description says).
- Focused implementation-agent review consumed under continuing explicit user approval, not falsely attributed to an independent parent. Prior accepted DDR source review reused. Issuer/runner/draft hashes pinned.
- All 11 source-overlay files independently read back matching SOURCE/WORK/expected hashes after launch. 21 evidence files transferred via named tmux buffer and individually SHA256 verified, including full native-log snapshot and process identity/starttime data.
- DDR mappings, PTILE/PF1, core470 seven-output PLL and AHLS integration unchanged remotely outside explicit listed delta. Local six changed files synchronized; other historical local source may lag remote and was not blindly replaced.

## Exact command
From `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`:
```
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_08
```
Persistent runner uses Quartus/sopc_builder PATH, explicit QUARTUS_ROOTDIR_OVERRIDE and LM/MGLS/SALT license binding. No timeout watchdog. `ready_for_build=false`, functional acceptance false.

## Artifacts
Remote E: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08`
Status: `E/run/status.json`; output: `E/run/native.log`; reports: `work_ia840f_fim_08/syn/board/ia840f/syn_top/output_files/`.
Local evidence: `remote-evidence/`; exact hashes: `remote-evidence-sha256.json`.
Authorization SHA256 `81ebc5ae0c4811d3618af78dd8db034a7310bad7f2bbb18272224c66763f9bf7`.
Progress snapshot SHA256 `55a163c433c437a69f4ab897cd72083f778479e9a4d91cce2476e81bb9e7cb96`.

Work07's saved generic gate_rejection flag is not rewritten; actual prior blocker was fitter 21636/12274, not an observed gate marker. No programming, DDR simulation, install, resets, old-BSP writes, commits or pushes.

One transport attempt exceeded tmux command length before any execution; switched to stdin-loaded tmux buffer. No vendor attempt lost or reused.
