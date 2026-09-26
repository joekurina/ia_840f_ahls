# CAPS03 native assembly acceptance

**Accepted for native assembly and artifact identity only.** Completed independent
review `deleg_2fbb4609` returned ACCEPT with no assembly blocker. Parent verification
agrees. This does not grant deployment, reset-entry, numerical or lifecycle acceptance.

## Verified result

`asm01` completed on 2026-09-26 at 01:50:46 UTC. Native/CMake/effective/outer status
is 0/0/0/0, with all preservation checks true, no postflight errors and no owned
residual process. Native zero is established through the successful single-command
CMake target, not an independently recorded Quartus wait status. All 17 captured
members were verified against the archive and their individual hashes.
[Outer receipt](asm01-outer.json), [parent verification](assembly-parent-verification01.json),
[native assembly log](asm01-capture/assembly.log).

All 344 protected physical snapshots and all inherited static images remain
byte-identical. The QSF delta is only the stage callbacks; RTL and timing constraints
were not changed. Assembly loaded the final root, green-region and auto-fabric
snapshots and used the inherited SOF/MSF/PMSF as preservation baselines.
[Parent verification](assembly-parent-verification01.json),
[assembler report, lines 176–206](asm01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.asm.rpt).

## New artifacts

Paths are under the remote run's
`persona/build/syn/board/ia840f/syn_top/output_files/`, mirrored locally under
`asm01-capture/` with the same relative paths. These files were absent from the
completed STA preinventory; they are not the inherited static image.
[Input inventory](asmprep01-result.json), [verified output identities](asm01-outer.json).

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `ofs_pr_afu.sof` | 10065141 | `8f778fca292cc77f87c196deb198d4798a1bd111999d69b0245d570fa2bfe276` |
| `ofs_pr_afu.green_region.pmsf` | 9373077 | `b98d8b161b5da6ff2e5ef1fb042fa043b379f1f358eaec09bfd59103d9e5faf5` |
| `ofs_pr_afu.green_region.rbf` | 9695232 | `2a74b1bca9a239a68d417acd1b26e4f970895b01ffe9e110eea2c32592a976bc` |

The Generated Files panel lists SOF/PMSF; the PR-RBF is additionally verified from
actual captured bytes. No GBS, JIC conversion, flash programming or boot result
is established by this stage.
[Assembler report, lines 230–258](asm01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.asm.rpt),
[outer receipt](asm01-outer.json).

## Current diagnostics and limits

The native footer reports zero errors and 19 warnings, reconciled as follows:

- **20727 ×1:** four unused PR inputs—`clk_div2`, `clk_div4`, `uclk_usr`, and
  `uclk_usr_div2`. Preserve this boundary-port finding; these are not the selected
  bank0 application clock.
- **18502 ×17:** current/base SDC assignment-set differences. Assembly did not
  change the selected constraints; their effective current-instance timing/CDC
  acceptance is in the consumed physical review, not a blanket warning waiver.
- **20536 ×1:** obsolete generic `GENERATE_RBF_FILE` setting ignored. The effective
  PR-RBF option is On and the actual PR-RBF exists. This establishes neither a
  generic full-device RBF nor GBS packaging.

[Current assembler diagnostics, lines 181–212 and setting line 99](asm01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.asm.rpt),
[warning rows and counts](assembly-parent-verification01.json),
[bounded physical acceptance](PHYSICAL-ACCEPTANCE01.md).

Four additional bank0 reset-sequence cycles, actual first-use/boot readiness and
the separate P-Tile pending-transaction/teardown issue remain obligations. The
source-only FLR counter budget is not a measured receiver reset waveform. No
hardware operation occurred. Current independent workstation recovery and the
operation-specific supported sequence must be established before live deployment.
[Reset-entry limits](PHYSICAL-ACCEPTANCE01.md#remaining-reset-entry-obligation),
[lifecycle disposition](../caps01-dma-gib01/ERRATUM11.md),
[authoritative safety scope](../../GOAL-PROMPT.md#workstation-safety--operating-rules-not-new-infrastructure).
