# Work14 UART-only build preparation

Status: **preflight PASS; preparation/review in progress; native build NOT STARTED**.

## Purpose and authority

Fresh source-bound FIM compile for the vendor-convention UART correction in [dfl-uart-fix-02](../dfl-uart-fix-02/REPORT.md), under the active GOAL-PROMPT.md source/build permission. No timing settings, PCIe/DDR topology, clocks, reset, BMC or AFU changes are intended. No dummy-CSR simulation; DDR simulation remains SKIPPED BY USER. No deployment, FPGA access, native OPAE, udev activation or recovery is authorized here.

Reuse the existing native OFS compile process and reviewed compile gate/issuer/runner pattern. Do not create a new generic build framework. Preserve Work13 and its persona and use fresh `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14` with new run records.

## Actual ordinary-file/OS preflight

Collector [preflight01.py](preflight01.py) ran in the owned tmux session `ia840f_mailbox_monitored_01`, window `fim14_preflight01`, @18 / %18. It did not open FPGA devices, sysfs resources, PCI config, OPAE or vendor executables. [Launch receipt](preflight-launch01.json), [raw result](preflight01.json), [compact transport](preflight01.json.gz).

- Complete result: true.
- Remote SOURCE inventory exactly equals the W13 issued record across `syn`, `src`, `ipss`, `ofs-common`, `tools`; no unexplained delta.
- PIM inventory exactly matches the W13 record.
- All 20 unique recorded tool files unchanged; binaries read as ordinary files, not executed.
- Process snapshot shows no active Quartus/qsys/AHLS compile or simulator.
- Available RAM: 126598533120 bytes; swap used: 0.
- Free filesystem space: 1376815935488 bytes.
- Work13 allocated size from `du -sk`: 2326992 KiB.
- Successor WORK and remote evidence directory did not exist.
- Remote source target remains original SHA256 `67c43a85a93c23c851a5f1136b05c1467bd541ab5bedb6da373af7d9d87d3bdc`; local corrected target is `df74b8e8e04408f2009f398444c5375c0e6ed66fa01452e8f594dfe2712fd60c`.

Preflight JSON SHA256: `497865782959a926a00fb900085a329162acd607aab1619e5ca563f1ec8d6f6b`.
Gzip SHA256: `c8283404642afef01bd2002fdee16d81e504e16ef9db56d6868913f108de8c87`.
W13 issued-record SHA256: `204cd46e869b7d78ef8978ac01ac88b19cd99f5f7a6e6152de2a1d8fadc51df1`.
All exported readback files and transport hashes were verified locally. The earlier tmux listing command had a shell-quoting error before listing; the corrected tmux-only listing succeeded. No build or probe was launched by either listing.

## Minimum preparation

1. Complete independent spec/quality review of the UART-only source correction; publish that source milestone separately.
2. Reuse Work13's generated inputs in fresh Work14. Inventory before/after, relocate only known work-root paths/symlinks, move inherited QDB/output artifacts outside the new compile inputs, and preserve the original Work13 tree unchanged.
3. Mechanically retarget the existing compile gate/dispatcher and issuer/runner to Work14, retaining the finite native command grammar and all source/tool/PIM checks. Bind the UART delta separately from gate-path retargets. Run syntax/import and missing-record rejection checks; no native Quartus until the fresh package is reviewed/issued.
4. Integrate only the accepted UART file and necessary gate retargets into remote SOURCE, with exact original hashes, backups and whole-inventory delta verification. Do not overwrite stale local copies of unrelated remote source settings.
5. Issue fresh reviewed authorization, then run native compile only in a new owned tmux window with persistent logs. Inspect synthesis, fit, STA and assembly separately. Negative timing remains a failure, even if compilation exits zero.

The observed W13 QSF uses seed 2, aggressive hold closure ON, HIGH PERFORMANCE EFFORT and MAXIMUM EFFORT placement. Preserve these and all board constraints; no new timing experiment is bundled with the UART correction. The recorded interface UUID is historical and must not be represented as a verified live image identity or a new PR-compatibility result.
