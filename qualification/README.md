# IA-840F AHLS BSP — Qualification Evidence

Every subdirectory here is an append-only record of one gated milestone in the
campaign to build a working AHLS-compatible OFS FIM for the BittWare IA-840F
(Intel Agilex 7 AGFB027R25A2E2V). Evidence conventions:

- Reports (`.md`), receipts/inventories (`.json`), scripts (`.py`), command
  transcripts (`.txt`, `.jsonl`), and diffs (`.patch`, `.diff`) are committed.
- **Raw payloads larger than 2 MB are kept out of the repository** (see
  root `.gitignore`). They remain preserved on the build host
  (`uwb_student00@100.101.227.97:/home/uwb_student00/ahls/new_BSP/`) and on the
  local working machine, and are referenced by exact SHA256 in the committed
  reports (e.g. full STA reports, oversized synthesis logs, evidence archives).
  Where a SHA is recorded in a committed report, it refers to these local-only
  payloads.
- The remote build host, the maintained SOURCE tree, and all WORK trees are
  **not** part of this repository; this directory records the qualification
  chain that ran against them.

## Milestone index (chronological)

| Stage | Directories | Outcome |
|---|---|---|
| Goal preflight / source staging | `goal-initial-preflight`, `ipgen-02` | Source snapshots hashed; ready_for_build=false |
| RTL/IP generation (Work03/04) | `ipgen-03`, `ipgen-04` | Work03 full generation failed (mailbox waitrequest); Work04 generation+headers rc0 |
| BMC mailbox migration | `mailbox-migration-01` | sdm_mailbox upgraded 20.2.2→23.0.0, waitrequest restored; integrated integration-05 |
| Byte-to-line adapter sim | `byte-line-protocol-01`, `byte-line-questa-01..03`, `byte-line-questa-diagnostic-03`, `byte-line-questa-transfer-01..03` | Final: 154 scenarios / 160,007 checks PASS, 0 err/0 warn |
| DDR model arc (simulation only) | `ddr-model-repair-01`, `ddr-smoke-01/02`, `ddr-library-fix/import/rebuild-01`, `ddr-sdk2026-01` | Elaboration blocked by protected IP; DDR simulation later SKIPPED BY USER |
| MSA timing arc | `msa-bank-spreading-fix-01/02`, `msa-bank-spreading-integration-01`, `msa-timing-next-01`, `msa-timing-candidate-seed2`, `msa-next-supported-step-02`, `msa-router-candidate-01`, `msa-router-capability`, `router-native-capability-01`, `msa-targeted-duplication-01` | Root cause isolated to scheduler bank-spreading; corrected via NUM_BANK_FIFOS 8→0 ×2 |
| FIM compile campaign | `fim-bti-clock-01`, `fim-build-05`..`fim-build-12` | Work05/06 invalid (gate dispatch), Work07 fit fail (BTI), Work08 first full compile + BTI fix, Work09/10/11 timing experiments, **Work12 full compile rc0, all Setup met, one −0.004 ns hold path** |
| Host/toolchain | `bittware-sdk-python-repair-01`, `jtag-recovery-preflight-01`, `pcie-generated-evidence-01`, `memory-generated-evidence-01` | SDK/CSP Python repaired; JTAG visible but not usable; PCIe/memory generated-IP evidence |

Post-Work12 status (2026-09-19): compile chain proven end-to-end; timing
acceptance pending independent review of the Work12 STA; AFU is still the
default standard-exerciser, not AHLS; no hardware programming has occurred.
All readiness/qualification flags remain false pending those reviews.
