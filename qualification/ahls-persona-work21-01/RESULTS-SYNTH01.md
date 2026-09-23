# Actual Work21 PR-context AHLS synthesis

**Native/effective0; outer125 preserved and source-preservation delta reconciled; independent review pending.** [Delta disposition](NATIVE-DELTA-DISPOSITION01.md), [receipt](outer-synth01.json).

Command: `/opt/altera/25.1/quartus/bin/quartus_syn --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu`, in `/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/synth01/persona/build/syn/board/ia840f/syn_top`. Native start2026-09-23T14:45:31.272324+00:00; supervisor native end2026-09-23T14:50:00.078656+00:00. Quartus25.1.0 Build129 SC Pro, partAGFB027R25A2E2V, board top`top`. Native elapsed00:04:28; peak virtual memory4590MB.11 exported result members verified; archive SHA256`4f696aa58d79d1c65629261e5ff151acfcbe4dd25ee7cff69f9bab1eef147cca`. No native job remains.

## Composition demonstrated

Native log selects **Loading PIM-based AFU** with OPAE_PLATFORM_GEN absent. The partition table identifies root import`ofs_top.qdb` and **green_region Reconfigurable** at`afu_top|pg_afu.port_gasket|pr_slot|afu_main`. Both page-safe bank paths, primary host mapper, actual generated HLS/DMA core and full-address MMIO guard occur under the real FIM wrapper.

Whole-project estimate:96,955ALMs,252,626dedicated registers,0DSPs. **Green region:36,362ALMs,85,806registers,1,373,376block-memory bits,0DSPs**. Its4,960boundary ports are partition-boundary signals, not board pins. Guard retained255combinationalALUTs/331registers and both one-hot safe4-state FSMs. [Native panels](native-panels-synth01.json). These are synthesis estimates, not fitted utilization or timing.

## Diagnostics remain visible

- **443 explicit warning occurrences including nested messages; native footer230.** The earlier unindented-only ledger224 is retained but superseded by [complete ledger](warning-ledger-synth02.json). No warning count is silently substituted for another.
- Critical20580 says the imported green region's PARTIAL_RECONFIGURATION_PARTITION type was not explicitly specified in current project. **The later native partition table nevertheless says Reconfigurable**; do not declare PR absent or add guessed constraints. Physical partition preservation still needs fitter evidence.
- Critical19854: explicit initial values in green_region. Preserve as a PR/lifecycle finding.
- Keep active LSU tristate-to-OR transformations, narrowed/swept RAM fields,31constant boundary groups, and prior mapped-path R1/R2 questions open; native success is not mapped-functional proof.
- Synthesized DRC: **5of13rules failed**, no waivers: RES-30132 medium2 (`afu_top|clk_div2_q1/q2`); LNT-30023 medium1 (PCIe MSI-X reset polarity); LNT-30010 low6; TMC-20501 low4; TMC-20500 low1. No high-severity violation in this snapshot. That is not global reset/CDC signoff.
- The actual-FIM context does not exhibit the naked top-interface non-driving-input violation; this does not waive remaining full-FIM/hardware requirements.

No HLS regeneration, unchanged-FIM rebuild, fit, STA, assembly, GBS generation, FPGA access, programming, driver operation or reboot occurred. Vendor DDR simulation SKIPPED BY USER. Goal incomplete. Next justified native stage is a separately bound fitter invocation using this completed synthesis database, not a repeat of synthesis.
