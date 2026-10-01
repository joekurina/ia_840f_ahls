# IA-840F OFS 2026.1 / Quartus 26.1 migration campaign

## Goal

Migrate the delivered IA-840F OFS platform from the qualified
**ofs-2025.1-1 + Quartus Prime Pro 25.1** baseline (branch `main`,
release `ia840f-caps03-v1.1.0`) to **[ofs-agx7-pcie-attach tag `ofs-2026.1-1`](https://github.com/OFS/ofs-agx7-pcie-attach/releases/tag/ofs-2026.1-1)
with Quartus Prime Pro 26.1.1**, per the AHLS 2026.1 handbook's Quartus-26.1
recommendation for Agilex 7, and re-close timing at the unchanged **3.000 ns**
application-clock target.

The migration is a **new qualification campaign with new run-IDs**, not an
upgrade of the delivered image. The CAPS03 v1.1.0 result stays published on
`main` and untouched as fallback; nothing on `main` is modified or reflashed by
this branch until a migrated image independently passes the same evidence gates.

**DO NOT DO ANYTHING THAT COULD CAUSE THE WORKSTATION TO HANG.** Protecting the
workstation, its data, and remote access takes precedence over progress. Blind
probes, speculative scans, unbounded loops and unreviewed recovery experiments
are not allowed at any time.

## Pinned migration targets (verify by hash at use, never from memory)

| Item | Target |
|---|---|
| FIM donor | `ofs-agx7-pcie-attach` tag `ofs-2026.1-1`, commit `866c25bb166810f65aae4f6b15374d0a89810e69` |
| ofs-fim-common submodule | `147cae890b7d1245301cf5cde229f761b287b70d` (16 new-side commits versus `34a8540…`; the old pin is not an ancestor) |
| PIM donor | `3c21189e728009d4c492fa2be54c0ab1008b06dc`, explicitly retained after [source-interface re-derivation](qualification/migration-source-01/pr-freeze-review01.md); this commit already adds the PR-freeze field, and the new common supplies its producer connection |
| HLS samples | unchanged: `altera-fpga/hls-samples` tag `2026.1.0`, commit `0abae6d78af5daca3fe5d67e617ab037e58aff89` |
| Quartus | Prime Pro **26.1.1 Build 130**, installed at `/opt/altera/26.1.1` on the workstation |
| AHLS / HLS IP Gen | 2026.1.0 (unchanged; handbook-compatible) |
| Questa | 2024.3 (unchanged) |
| Device | AGFB027R25A2E2V (unchanged) |
| Timing target | 3.000 ns application clock (unchanged) |

Upstream delta being adopted: 22 commits, 100 files — Quartus-26.1 build
infrastructure (libcrypto.so path fix, pcie_only PR template generation,
n6001/iSeries/AGX5 26.1 ports), mem_tg DDR4 400 MHz test-generator timing
fixes, optional `pr_freeze_to_afu` propagation through
`ofs-fim-common …/port_gasket/pr_slot.sv` and `afu_main_pim`, and an AGX5-only
multi-link AFU DFH MMIO completion fix. **No commit touches the IA-840F board
layer or the EMIF/PHY timing cone.** The DFH fix is AGX5 256-bit-PU specific;
do not expect or claim it fixes anything on the P-Tile.

Documented evidence for this plan:
[release assessment](qualification/ofs-2026-target-01/upstream-review.md) and
[disposition](qualification/ofs-2026-target-01/DISPOSITION.md) (bounded
source-selection research — no jointly qualified 2026 tuple exists upstream),
[FIM build history](qualification/fim-build-21/CURRENT.md) (W13–W21),
[PCIe clock-repair candidate](qualification/pcie-clock-repair-01/production-clock01/CURRENT.md).

Vendor reference (context, not a pin or requirement): BittWare's own
minimized IA-840F OFS port is summarized in
[vendor FIM notes](docs/vendor-fim-notes.md) (source
`IA-840F FIM Notes.docx`, local-only, SHA256-hashed there). Key contrasts
with our platform: BittWare places BMC on **PF3** with their SDK driver —
our delivered platform uses **PF1 BMC** with OPAE/DFL and qualified that
way; their PMCI-removed/macro-tailoring approach documents the same
unsupported-subsystem seam the 2026.1-1 PMCI IP regeneration touches; their
~14% AGF027 utilization corroborates our 13.96% ALMs fit. Their document
does not change our architecture, pins, or flash rule.

## Standing rules carried forward unchanged

- **Flash rule (Joe's explicit correction): ALWAYS use the BittWare SDK flash
  writer `bw_agilex_flash_programmer`. It is the only flash route.** Never
  repair or retry JTAG; a JTAG failure such as `Hardware not attached` triggers
  the SDK route. JIC is file-only conversion evidence, never writer input.
  Generate the SDK RPD from the exact accepted full-device SOF of the *migrated*
  image with the recorded `MT25QU02G`/`ASX4`/`AGFB027R25A`/`bitswap=OFF`
  contract. Then BMC Off/On with separate readbacks and one normal reboot.
  Conversion, programming, activation and numerical qualification remain
  distinct outcomes. [Writer contract](qualification/caps01-bwflash01/PROGRAM02-RESULT.md).
- **Deployment authority**: flashing the card, BMC power cycle and one
  workstation reboot remain approved when a new operation is justified by this
  campaign's gates. Preserve stop-on-error/no-duplicate-operation behavior and
  temporary-setting restoration.
- **Erratum acceptance**: only the exact VF pending-before-FLR warning is the
  accepted exception
  ([policy](qualification/caps03-runtime01/ERRATUM-ACCEPTED25.md)). Anything
  different — another BDF, FLR-completion timeout, AER/IOMMU fault, data or
  guard failure, leftover owner — is a hard failure. Raw `success=false` records
  stay unedited.
- **Reuse, never replay**: a new FIM interface UUID invalidates PR/persona
  compatibility; all card-bound gates re-run against the migrated image. Do not
  resynthesize unchanged standalone artifacts or rerun completed CAPS03
  hardware operations as a "sequence". The GettingStarted standalone results
  remain valid and are not re-derived.
- **Scope discipline**: no new subsystems, protocols or features absent from
  the donor references. Adaptation is limited to the IA-840F board layer and the
  HLS/OPAE integration seam. Report gaps and obtain Joe's scope decision; do not
  invent. Editing or reading this prompt is documentation-only and launches
  nothing.
- **Evidence policy**: concise evidence with exact commands, hashes, return
  codes; native exit 0 is not functional or timing acceptance; preserve failed
  results; independent review for actual result acceptance; focused milestone
  commit/push with remote-state verification; no secrets/tool binaries/no files
  over 2 MB in Git. Report before and after every long-running step.

## Phase 1 — Source basis update (offline, no tools)

1. Re-pin `sources.lock.json`: `fim_release=ofs-2026.1-1`, FIM `866c25bb…`,
   fim-common `147cae89…`; re-derive the PIM pin against the actual new
   producer/consumer interface, not cross-repository ancestry. Record the delta
   decision with evidence. Source review retained `3c21189e…`; generated and
   real-card qualification remain open.
2. Re-vendor the FIM tree at the new tag. Preserve **all** maintained
   IA-840F additions and overlays, including these four vendor-tree files:
   `ofs-common/tools/ofss_config/ia840f_compile_gate.py`,
   `ia840f_experimental_gate.py`, `src/board/ia840f/afu_top.sv`,
   `syn/shared_config/top.sdc`. The complete [migration inventory](qualification/migration-source-01/vendor01/manifest.json)
   also identifies ten modified common-donor files. Two (`build_fim_setup.sh`
   and `setup_opae_sdk.sh`) overlap upstream at file level and require retaining
   both non-conflicting change sets; a FIM-only diff does not cover its submodule.
3. **PIM seam inspection**: the new fim-common adds the optional
   `pr_freeze_to_afu` port through `pr_slot.sv` → `afu_main_pim`. Inspect the
   actual `afu/ahls` wrapper against it. Do not tie it inactive to conceal an
   interface mismatch; do not consume it end-to-end unless actually connected.
4. Keep `iopll_470MHz.ofss` (`freq = 470`) as the board PLL selection. The PLL
   answer for collaborators stands: 470 MHz is what BittWare's own fitted FIM
   realizes (old fit report: VCO 1410 MHz, M=141, N=10); the "400 MHz for x16"
   source comment was never a fitted reality. Never read frequencies from
   comments — read them from fit reports.

## Phase 2 — PCIe divider constraint (state: fixed in baseline; candidate optional)

Correct state of the three `top.sdc` variants — do not confuse them:

- `qualification/pcie-clock-repair-01/production-clock01/original-top.sdc`
  (`8255b34c…`) preserves the **donor** bytes: the obsolete 3-line wildcard
  divider declaration. Lineage copy only; never rebuilt from.
- The **maintained**
  `ofs-agx7-pcie-attach/syn/shared_config/top.sdc` (`b706fc11…`, commit
  `69952f8`) already carries the **Work15 four-line fix**: full modern
  `EP_PFTILE_WRAPPER.gen_pciess` hierarchy, explicit
  `-master_clock {sys_pll|iopll_0_clk_100m}`, no `-add`. Its fresh-fit evidence
  is accepted: divider constrained (intra-clock setup/hold 17.489/0.056 ns),
  all eight formerly invalid-clock FIFO net-delay assignments positive
  (minimum 15.369 ns), zero invalid-clock rows remaining. Work15–Work21 all
  built with this file; W21's accepted "byte-identical top-level SDC" is it.
  **The migration baseline is this 4-line form.** There is no obsolete block
  left to replace and no coverage gap being inherited.
- `production-clock01/top.sdc` (`8021e795…`) is the **parked expanded
  candidate**: a 43-line guarded Tcl namespace (pin identity/direction checks,
  master-clock association, pre-existing-definition rejection,
  `IA840F_PCIE_CLOCK_DECLARED`/`REJECT` markers; `delta.json`:
  `native_run=false`, `ready_for_build=false`). Not in the baseline; its
  pending review chain (independent source SPEC → parent consumption →
  QUALITY → exact source acceptance) is incomplete by deliberate pause, not
  by rejection.

**Decision fulfilled: Joe selected the proven four-line form.**
[Decision record](qualification/migration-source-01/CONSTRAINT-DECISION01.md).
The guarded candidate remains parked; its review chain is not a prerequisite
for this selected route. Preserve the four-line declaration and carry the
separate Work21 fit-only margin overlay as required below. Fresh native
authorization and all empirical clock/exception gates remain mandatory.

Post-compile empirical gates either way: divider clock present in the fit
clock table (`original 80 + avmm_clock0`), no invalid-clock net-delay rows,
changed-transfer/exception coverage, net-delay shape comparable to Work21
(144 records, worst slack 1.024 ns).

## Phase 3 — Native 26.1.1 compile

1. Regenerate **every** IP leaf natively under Quartus 26.1.1 — do not carry
   25.1-generated IP forward. Include the remote-STP `scjio_agilex` debug leaf.
   (Directional note: the W20 failure was 26.1-generated IP consumed by a 25.1
   flow — `CLTAP_CONNECTION` absent from 25.1's endpoint declaration. Migrating
   to 26.1 removes that boundary, but only if IP is actually regenerated under
   26.1. Verify the installed 26.1.1 endpoint wrapper passes it.)
2. Carry forward exactly these QSF items from Work21: the exact-instance
   `ALLOW_REGISTER_RETIMING OFF` on EMIF1 `bit243` (W18 origin),
   `ENABLE_INTERMEDIATE_SNAPSHOTS ON` (W17 diagnosis infrastructure), and the
   fit-only 10 ps hold-margin overlay with `quartus_sta` signoff-skip guard.
   Keep `LAST_QUARTUS_VERSION` the only expected QSF version delta unless
   evidence shows otherwise.
3. Environment: use the installed 26.1.1 toolchain explicitly; do not trust a
   possibly stale `QUARTUS_ROOTDIR_OVERRIDE`; apply the upstream 26.1 build
   fixes inherited with the tag (libcrypto.so path, PR template generation)
   rather than re-deriving them. All remote work through the established owned
   tmux workflow, one build root per attempt (`work_ia840f_fim_22`+),
   authorization-before-launch, no rerun of a consumed run.
4. Verify realized PLL outputs from the fit report (expected: same 1410 MHz
   VCO / 470 MHz `clk_sys` family, 7-output preset). If 26.1.1 IP generation
   alters the realized set, stop and compare against the clock-consumer
   contract before proceeding
   ([review](qualification/pcie-generated-evidence-01/clock-consumer-contract-review.md)):
   do not retune, rename, disable outputs, restore the 5-output donor, or round
   the PCIe AXI-Lite request (`INTEGER {100:250}` cannot be 100.714286).

## Phase 4 — Timing closure expectations and protocol

The one known physical risk is the EMIF1 write-data `bit243` Hyper-Register →
UFI → PHY hold path: it failed at exactly −0.004 ns across W15–W18 on 26.1.1
and passed at +0.082 ns on 25.1 (W21) with the acceptance explicitly refusing
causal attribution to tool version, retiming assignment, or placement. Treat a
repeat marginal failure as a **placement/seed outcome, not a defect**:

- Bounded refit iterations within the retiming-restricted QSF; no margin
  inflation, no new exceptions, no path waivers.
- Use the intermediate snapshots to locate the stage where slack lands.
- Every accepted close verifies the exact transfer across all five corners
  with "No SDC Exception on Path".
- Budget 1–3 full compiles for this; report before/after each.

Disclosed, non-blocking, unchanged posture: reserved JTAG TDI/TMS/TDO and
`bwbmc_bmc_irq` unconstrained ports; Design-Assistant FAIL panel (LNT-30010
reset fanout — 1735 CLRN / 981 SCLR / 513 ENA loads; reset recovery/removal
genuinely met); signoff overlapping-rule findings. Bank0 reset margins
(+0.592/+0.155 ns) and global minima (+0.242/+0.140 ns) are distinct numbers —
never substitute one for the other.

## Phase 5 — Evidence gates (all card-bound gates re-run)

1. Static: synthesis/fit/assembly acceptance reviews via independent delegate;
   full multi-corner STA at 3.000 ns; record the new FIM interface UUID.
2. New UUID ⇒ AFU persona re-synthesis/refit against the migrated shell;
   hls-samples 2026.1.0 RTL generation and RTL simulation against the new PIM.
3. Deployment: BittWare SDK flash of the accepted migrated SOF, BMC Off/On with
   readbacks, one reboot; verify the new static FME identity before any AFU work.
4. Hardware gates on the migrated image: OPAE numerical copyback, 34-case
   coverage, DDR independent/isolation/sustained trio, walking-bit, bulk
   concurrent-bank — per the agreed [DDR hardware validation gate](docs/ddr-hardware-validation-gate.md).
   The ~78-minute full-capacity run only if the campaign scope explicitly
   requires it; its inefficient serial harness is a retained defect, not
   bandwidth.
5. Then, and only then, resume the reopened release-wide hls-samples goal on
   the migrated platform — that resumption is Joe's separate decision.

## Workstation safety — carried forward

- No speculative MMIO/BAR reads/writes, UUID/base scans, `/dev/mem`, raw
  resource mapping, or alternative probing when OPAE enumeration fails.
- One card owner and one operation at a time; no overlapping tests or subagent
  device access. A timeout, disconnect or unexpected device response means stop,
  preserve evidence, report. Never duplicate-launch, auto-reset, rescan, rebind,
  reflash or reboot after failure.
- No BIOS/AER/permission/link/service changes to force a pass. Gen3 x16 is the
  expected host link. Preserve board clocks, PR/static boundaries and the shared
  BMC SPI/SDM path. Never improvise power sequencing.
- **Blind probes that could hang the machine are not allowed** — including
  retry loops against wedged hardware, unbounded waits, and recovery
  experiments without reviewed finite scope and stop conditions.

## Paths, tools and working method

- Repository: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`, campaign branch
  `migration-ofs-2026.1-quartus26.1` (this file), fallback/baseline `main`,
  `github.com/joekurina/ia_840f_ahls`.
- Agilex workstation: `uwb_student00@100.101.227.97`; build root
  `/home/uwb_student00/ahls/new_BSP`; owned tmux workflow only, not ad hoc
  direct SSH. Quartus 26.1.1 at `/opt/altera/26.1.1`; 25.1 remains installed
  for comparison/provenance only — do not mix flows inside one attempt.
- Parent performs implementation and execution; independent review accepts
  actual design/results; subagents never author executable changes or touch
  hardware.
- **Subagent model preference (Hermes)**: prefer **GLM-5.3 (provider `zai`)**
  for subagents; prefer **GLM-5.3-Flash** for watcher-class tasks — those that
  set off builds and poll logs/tmux output/status files (long-step monitors,
  capture/status scripts). If a preferred model is unavailable in the runtime,
  disclose the substitution in the run report rather than silently falling
  back. Model choice does not change the authority boundaries above.
- Keep artifacts under the campaign's run-IDs; do not scatter files in the home
  directory; distinguish simulation, physical implementation and real hardware
  in every report.

## End-of-session handoff format

Replace the current handoff state rather than appending chronology. Record
only: selected architecture and reason; files actually changed; tests/builds
run and outcomes; exact active job/ownership if any; remaining blocker; one
next concrete action. Link existing evidence instead of repeating it. Never
mark an old job active from a delayed notification. Report completion only
when the migrated image's real-card acceptance criteria are met; explicitly
identify unperformed or blocked checks.
