# Work21 flash boot verified after W13-route activation

## Result

**The W13 image-identity blocker is cleared.** After the already-completed JTAG program/verify, one USB BMC card power cycle and one normal workstation reboot produced the expected Work21 FME interface UUID:

`fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`

The workstation is reachable. Fresh Linux boot ID: `598f7b27-1798-4a88-8a79-9e4a2659c64d`; kernel `5.14.0-687.48.1.el9_8.x86_64`. Postboot capture completed `2026-09-24T19:37:53.955318+00:00`. Identity came from the source-verified kernel-cached compatibility accessor, populated during this boot's DFL probe; loaded module build IDs and file hashes matched the reviewed accessor evidence. No new FPGA MMIO was used by this check. See [postboot12-result.json](postboot12-result.json).

This establishes the intended static FME identity after QSPI programming and BMC power-off/on, without another volatile SOF load. It is **not** verification of the CAPS01 AFU UUID, DDR data integrity, host transfers, AHLS numerical behavior, or sustained operation. The original SDK-write/normal-reboot failure's precise cause remains unresolved: both transport and activation sequence changed.

## Executed stages

| Stage | Verified result | Evidence |
|---|---|---|
| Quartus25.1 JIC PV, program08 | Native0/outer0; erase, program, verify explicitly logged; zero errors/warnings; 120.132s | [program08-result.json](program08-result.json), [program08-outer-result.json](program08-outer-result.json) |
| Cable-setting restoration | Original24MHz and auto-adjust1 both read back | [activate10-result.json](activate10-result.json) |
| BMC cycle, activate10 | USB:0, IA-840F serial8110055; Off/native0/readbackOFF,12s, On/native0/readbackON,30s settle | [activate10-result.json](activate10-result.json) |
| OS reboot, reboot11 | One `sudo -n /usr/bin/systemctl reboot`; native0; requested19:34:42.699663Z | Original requested/command receipts embedded in [postboot12-result.json](postboot12-result.json) |
| Postboot12 | New boot; Work21 UUID match; PF0dfl-pci and PF1vfio-pci; source-bound accessor unchanged | [postboot12-result.json](postboot12-result.json) |
| AER restoration | Root status00000000; original masks00100000/00002000 read back after reboot; no extra restoration write necessary | [postboot12-result.json](postboot12-result.json) |

The user's interruption explicitly prohibited redundant programming once flash was complete. **No second programmer, repeat flash, or standalone flash verify ran.** Collector `proc_e8c6dc0c4c5f` completed0 and is consumed. All operations ran in owned remote tmux; the reboot ended that server, which was recreated only after SSH returned.

The power-on command's initial warning that the card was not powered on is emitted by `_get_bmc` before the requested On operation. Its subsequent `Power: ON` and native0 establish the power-on command result; it is not an unresolved power-on failure. See the privately retained source captures and [activate10-result.json](activate10-result.json).

## Image binding

- Existing combined SOF: `work_ahls_persona_work21_caps01/asm01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sof`, SHA256 `d64f296cec0e8dbcc55292c2e566c09bef48e52fcce3a8d20287dc86b9a68f3a`.
- Existing JIC: `work_caps01_bwflash01/prepare-off03/caps01-off.jic`, SHA256 `3ad69144b337c06be7e9eb456f6f43644e1e8bbdfb206540a68207f5873ba4f0`.
- Quartus Prime Pro25.1.0Build129; JTAG cable `IA-840F [1-3.2]`, verified AGFB027R25A/TAP1, native checksum0x960D9326.
- Complete single-image non-RSU BOOT_INFO+P1 layout retained; no vendor restore, resynthesis, conversion, or layout change. Exact argv and preservation checks are in [program08-result.json](program08-result.json).

## Preparation and preserved anomalies

The original helper was located at `ia840f/scripts/control_aer.sh`, not the incorrectly assumed board-root path. Its Surprise Down status/mask bit0x20 operations were narrowed to verified root4e:00.0. Only the card's PF1 and PF0 were removed through the reviewed `pci_device ... remove`; root port preserved, no global or manual rescan. See [source03-result.json](source03-result.json) (private source), [quiesce07-result.json](quiesce07-result.json).

The target04 wrapper expected the wrong product spelling (`IA840F` versus actual USB `IA-840F`). All native commands succeeded; the exact USB product/serial/location/VID/PID matched the cached descriptor. The original failed wrapper is preserved with [target04-disposition.json](target04-disposition.json); no hardware query was repeated to hide it.

The requested VFIO-daemon stop returned0 but its daemon exited1. [stop-inspect06-result.json](stop-inspect06-result.json) confirmed MainPID0, empty cgroup, original PID absent, no FPGA/VFIO holders or blocked tasks. Its failed service state was preserved, not relabeled a clean daemon exit or treated as a hung hardware transaction.

Specific route authority was reaffirmed after the risk disclosure. Independent recovery was not available and is not claimed. This successful observed execution is not a universal no-hang guarantee or standing permission for arbitrary future reconfiguration.

## Current boundaries

- PF0 `0000:4f:00.0` /8086:bcce /dfl-pci; PF1 `0000:4f:00.1` /12ba:0070 /vfio-pci.
- sriov_numvfs0; VF absent, as expected before per-boot setup. No VF was created in this sequence.
- CAPS01 AFU UUID `673c03a1-cef3-4c82-bf10-b12c247d9718` remains to be verified through the reviewed VF route.
- Both DDR channels, simultaneous traffic, real bidirectional transfers, numerical AHLS, and sustained/boundary testing remain **NOT RUN**. Vendor DDR simulation remains **SKIPPED BY USER**. UART remains excluded.
- No commit or push in this action. Raw source captures contain proprietary SDK material and must not be published. Keep large image files local/SHA-referenced.

## Receipt hashes

| Receipt | SHA256 |
|---|---|
| program08-result.json | `fffc8dcd648b8919029855004005f7cf4c23bb18d10c8bd81be97979c14383d6` |
| activate10-result.json | `3960778eda2b3b05e0abe8452710a52bcd3db73cb873520a956a2716a7e1e292` |
| postboot12-result.json | `d7c5c56d76ecfe872039aa04b7893d3404c81c55ac7175989ac5b7a7a24ccf71` |
| Native programmer log | `895642cfaded611b92d529acd0e6775f24189b18f6eac0ef0310768c393342f8` |

**Requested cycle/reboot scope completed; overall functional accelerator goal is not yet complete.**
