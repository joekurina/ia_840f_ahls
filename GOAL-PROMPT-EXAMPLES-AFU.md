# GOAL: Build and card-test every OFS `examples-afu/tutorial/afu_types/01_pim_ifc` example on the migrated IA-840F v2.0.0 platform

## Goal

Synthesize, load and run on the IA-840F card every example under
`examples-afu/tutorial/afu_types/01_pim_ifc/` of this repository, using the
accepted **`ia840f-caps03-v2.0.0`** image (ofs-2026.1-1 / Quartus Prime Pro
26.1.1 Build 130, FIM interface UUID `fc603c44-5c8f-5e94-bcbe-a5780030947c`,
already flashed and idle). Each example that synthesizes into a GBS is loaded
with `fpgaconf` into the green region and executed with its OPAE host program;
results are accepted per the evidence rules below.

**SCOPE CALIBRATION (Joe, 2026-10-05): the workstation-hang rule targets the
historical failure mode — blind/speculative PCIe MMIO BAR probes and unqualified
register writes, which wedged the machine. It does NOT apply to normal operation.**
Running the tutorial host programs (OPAE open → MMIO → DMA → read → exit),
re-running a host program, `fpgaconf` PR loads, and reading sysfs/OPAE state are
**normal, explicitly authorized operation — do them freely without asking**. Do
not let a transient D-state process sample (systemd and kernel threads enter D
for microseconds routinely) trigger a safety stop: re-check the actual state
live before treating it as a hang, and only a sustained (minutes) D-state on the
critical path with unresponsive SSH is a real stop condition.

**Flash rule (Joe): ALWAYS use the BittWare SDK flash writer
`bw_agilex_flash_programmer`. Never JTAG.** These examples load as PR GBS via
`fpgaconf` — **no reflash is expected for this goal**. If anything suggests a
full reflash is needed, stop and report instead of improvising.

**Deployment authority (Joe, standing):** you may load GBS files with
`fpgaconf`, run the host software, and reset/remove/rebind the AFU VF between
examples without asking. Do not reflash, power-cycle or reboot the workstation
for this goal unless a gate below forces it; if it does, stop and report.

## Targets, in this order

| # | Example | Variants | Host program | Notes |
|---|---|---|---|---|
| 1 | `hello_world` | `ccip/`, `avalon/`, `axi/` — three separate AFUs | `hello_world.c` | Simplest; validates MMIO path per PIM protocol. Build **all three** variants |
| 2 | `clocks` | single | `clock_freq_test.c` | Measures user-clock frequency; validates the 470 MHz PLL domain |
| 3 | `local_memory` | `avalon/`, `axi/` | `hello_mem_afu.c` | Exercises both 16 GiB local-memory banks via PIM bank mapping |
| 4 | `copy_engine` | single | `copy_engine` sw | Host→AFU→host streaming copy through PIM host channels |
| 5 | `dma` | single | `dma` sw | Full DMA engine: CSR + descriptor FIFO + AXI-MM mux to local memory |
| 6 | `PIM_advanced` | README pointer only | — | No RTL present; record that fact and skip (do not fabricate) |

`common/sw/common_include.mk` is shared infrastructure, not a target.

Expected pass per example: synthesis → GBS without new errors (tutorial-code
warnings are expected and recorded, not failures), `fpgaconf` accepts the GBS,
host program exits 0, and its self-checks pass (hello_world: MMIO write/read
round trip; clocks: measured frequency within the PLL's documented range;
local_memory/copy_engine/dma: data-verified transfers — no test counts "pass"
on exit code alone when it prints data checks).

## Environment (established facts — verify by hash/ls at use, don't guess)

- Repository `/home/joe/Projects/Thesis/AHLS/new_bsp/new`, branch `main`
  (at `ia840f-caps03-v2.0.0`). The examples live in the vendored
  `examples-afu/` tree, upstream `OFS/examples-afu@4a1350e3`. Work **in place**
  or in a work tree; do not modify the vendored sources except where a build
  requires a recorded, reviewed correction (see Corrections policy).
- Quartus Prime Pro **26.1.1 Build 130** at `/opt/altera/26.1.1`. **Always set
  `QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus` and a 26.1-only PATH
  explicitly** — the inherited launcher root selected 25.1 once already
  (preserved as help01).
- PIM: `ofs-platform-afu-bbb` is in the repository. The tutorial
  `afu_synth_setup` flow needs an `OPAE_PLATFORM_ROOT` release tree containing
  `hw/lib/platform/platform_db/ofs_agilex_adp.ini`. The v2.0.0 campaign built
  the AFU against the Work21 platform; generate or locate the matching release
  tree for the migrated FIM before the first synthesis (the CAPS03 build
  procedure in `docs/ia840f-build.md` documents the platform export that
  produces it). Do not reuse the old 23.1-era tree in
  `old_bsp/ia-840/IOFS_BUILD_ROOT/` against the 26.1 FIM.
- Card: `ia840f-caps03-v2.0.0` flashed and idle. DFL on PF0, management PF1,
  VF0 is the AFU. `fpgaconf` targets the VF via the normal OPAE/DFL path.
- Workstation `uwb_student00@100.101.227.97`, build root
  `/home/uwb_student00/ahls/new_BSP`, owned tmux only.

## Hard rules (unchanged from the migration campaign)

1. **One card owner, one operation at a time.** No concurrent hardware jobs.
   Hardware is a single serial lane; synthesis can parallelize.
2. **No speculative MMIO/BAR reads, UUID/base-address scans, `/dev/mem`, or
   raw probing** (the historical hang cause). This does NOT restrict the
   tutorial host programs or OPAE API usage — those are the sanctioned access
   path and need no special care.
3. **On failure: preserve the evidence, fix the cause, retry.** Do not
   duplicate-launch a still-running job (check first, then act), and never
   improvise power sequencing or reflash. But a failed host run, a lost exit
   receipt, or a supervisor bug is fixed and retried as part of normal work —
   host-only reruns and corrected monitoring **never require
   re-authorization**. Only PR reload loops, reflash, power-cycle or reboot
   after repeated failures warrant stopping to report.
4. **No BIOS/AER/permission/link/driver changes to force a pass.** If an
   example cannot run as a plain OPAE user, record why and move on; do not
   modify system state to make it pass.
5. **Preserve failures unedited.** A failed synthesis or a failing host run is
   evidence, recorded with its log, hashes and exit codes. Never extend or
   repair a hash — recompute it.
6. **Raw evidence over 2,000,000 bytes stays local**, SHA-referenced. No
   programming images or licensed binaries in the repo.

## Evidence and acceptance policy (same discipline as the migration)

Per example, one capsule under `qualification/examples-afu-01/` named
`<example>-<variant>/`:

1. **Stage the exact sources**: record the tree hash of the example directory
   actually built. If a correction to tutorial code is unavoidable (e.g. a
   platform-ini name or a Quartus 26.1 syntax change), it is a separate,
   minimal, recorded diff — reviewed before build, never a silent edit.
2. **Synthesize** with `afu_synth_setup`/Quartus 26.1.1; capture the log and
   the GBS. Record AFU UUID (each tutorial AFU has its own; the card gates on
   it at load).
3. **Accept the GBS** by review before hardware: hash, build-exit, and a
   quick source/UUID sanity check. GBS synthesis failures are recorded and
   that variant is marked unqualified — do not iterate past the first honest
   failure without writing down what changed and why.
4. **Load and run on the card** (`fpgaconf` + host program), capturing full
   stdout/stderr and exit codes. One `fpgaconf` per attempt; on failure,
   preserve and report.
5. **Close the capsule**: CURRENT.md with what ran, exact commands, results,
   hashes; commit at each accepted example (milestone commits, pushed).
6. **Final closure**: after the last example (or its recorded failure), one
   summary — which of the 8 AFU variants passed on hardware, which failed and
   why, which were skipped — committed and pushed. A failed example does not
   block the others; hardware is retried only via the stop-preserve-report
   rule, never automatically.

## Working method

- Parent implements and executes; independent review accepts actual results
  for each hardware gate. Synthesis-only stages need evidence discipline, not
  a review per attempt.
- **Never block on an unanswered clarify.** If an authorization prompt times
  out, record the question, choose the most conservative action that stays
  inside standing authority (host reruns, PR loads, normal runs qualify), and
  keep working. Pausing is for reflash/power/reboot territory or real hang
  symptoms — nothing else.
- Report before and after every long-running step (each synthesis is minutes
  to ~an hour; each card run is seconds to minutes).
- Subagent provider: whatever the runtime assigns; disclose substitutions.
- End-of-session handoff: replace the handoff state — current per-example
  status table, exact active job if any, one next action. Never mark an old
  job active from a delayed notification.

## Start here

1. Verify the card is idle and owned (OPAE enumerate shows
   `fc603c44-…`, no other owner), and the workstation tmux exists.
2. Establish the platform release tree for the migrated FIM (this is the one
   genuinely new dependency — do it first, it gates all synthesis).
3. Build `hello_world` **avalon** variant end-to-end first (synthesis →
   fpgaconf → host run → accepted). It is the smallest full-path validation of
   the whole chain. Then proceed down the table.
