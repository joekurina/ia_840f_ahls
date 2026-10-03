# IA-840F OFS 2026.1 / Quartus 26.1 migration campaign

## Goal

Migrate the delivered IA-840F OFS platform from the qualified
**ofs-2025.1-1 + Quartus 25.1** baseline (`main`, release
`ia840f-caps03-v1.1.0`) to **ofs-2026.1-1 + Quartus Prime Pro 26.1.1**, and
re-close timing at the unchanged **3.000 ns** application-clock target.

`main` stays published and untouched as fallback. New campaign, new run-IDs.

**DO NOT DO ANYTHING THAT COULD CAUSE THE WORKSTATION TO HANG.** Protecting the
workstation, its data and remote access takes precedence over progress.

**Flash rule (Joe): ALWAYS use the BittWare SDK flash writer
`bw_agilex_flash_programmer`. Never JTAG.** Then BMC Off/On with readbacks and
one normal reboot. Deployment authority (flash + BMC + one reboot) is approved.

**Reuse, never replay.** Accepted artifacts are never re-run; spent admissions
are never re-issued. Evidence policy unchanged: hashes, return codes,
independent review for acceptance, milestone commit/push, report before/after
every long-running step.

## Status — where the campaign actually is

Branch `migration-ofs-2026.1-quartus26.1`, head `c5a6e67` == origin. Previous
goal session `20260930_213351_8b60a9` stalled 2026-10-03 ~11:46 UTC in a
provider wait and did not recover; resume from files, not from its memory.

**Accepted (all on 26.1.1 Build 130, all committed):**

- Phase 1 source migration, four-line SDC baseline (Joe's decision), PIM
  retained `3c21189e…`
- Native export + fabric generation + persona setup
  (`2844249`, `3912bb7`, `a21394d`)
- Simulation first-run pass (`2d7d927`), mapped synthesis (`76fd93a`),
  first-attempt fit (`57fca75`), five-corner STA at 3.000 ns (`c5a6e67`)
- EMIF1 closed via CLOCK_SPINE 2 QSF records (+0.082 ns at the failing corner)
- **CDC gate closed** — query63 ran clean (outer 0, 87 reports, 9.9 MB),
  2,700 exact-name joins / 0 gaps / 10 net-delay groups over the
  40-bundle/20-FIFO structure; three result reviews accepted with findings
  ([CDC-ACCEPTANCE73.md](qualification/fim24-caps03-cdc03/CDC-ACCEPTANCE73.md))
- New FIM interface UUID `fc603c44-5c8f-5e94-bcbe-a5780030947c`

**In flight: assembly capsule `fim24-caps03-assembly01`** — staged but NOT
admitted; the native `quartus_asm` has never run:

- Workspace `work_fim24_caps03_assembly01/base01` on the workstation: exact
  copy of the accepted STA basis (4,038 entries / 1.01 GB / 733 QDB), tmux `@394`
- `SOURCE-SCOPE04.md` written; source/API freeze 36 members
  (`e09ee53e…`); CMake/runner/identity inert test suites pass
- [SOURCE/API review05](qualification/fim24-caps03-assembly01/source-api-review05.md)
  = **PASS WITH LIMITS, two required corrections before QUALITY/admission**
  (below)

## Next steps, in order

1. **Apply review05's two corrections:**
   - Keep four current STA artifacts immutable
     (`_all/1/report.sta.model`, `report.sta.rdb`,
     `legacy/1/da_report_timing_signoff_final.sqlite3`,
     `ofs_pr_afu.sta.qmsgdb`) plus final STA reports/user clocks; enumerate
     the remaining 26 exact mutable paths from the current role basis. Never
     exclude arbitrary QDB trees.
   - Expect region-qualified outputs: new nonempty SHA-bound
     `ofs_pr_afu.sof`, **`ofs_pr_afu.green_region.pmsf`** (not
     `ofs_pr_afu.pmsf`), `ofs_pr_afu.green_region.rbf`. Preserve inherited
     `ofs_top.sof` / `ofs_top.static.msf` / `ofs_top.green_region.pmsf`.
2. **QUALITY review** of the corrected runtime → **fresh exact admission** →
   one native assembler operation:
   `quartus_asm ofs_top -c ofs_pr_afu` in
   `base01/build/syn/board/ia840f/syn_top`.
   **Always set `QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus` and a
   26.1-only PATH explicitly** — the inherited launcher root selected 25.1
   once already (help01, rejected and preserved).
3. **GBS packaging** as a separate offline stage via the PR QSF's
   `gen_gbs.tcl` route — bare `quartus_asm` does not run it. Validate
   container/header/interface/AFU/clock metadata; payload byte-for-byte.
4. **Deployment:** SDK flash of the accepted persona GBS/SOF per the flash
   rule, BMC Off/On with readbacks, one reboot, verify static FME identity.
   Expected new identity: interface UUID `fc603c44-…` (AFU UUID `d48dde9f…`
   unchanged).
5. **Hardware gates on the migrated image:** OPAE numerical copyback, 34-case
   coverage, DDR independent/isolation/sustained trio, walking-bit, bulk
   concurrent-bank
   ([gate](docs/ddr-hardware-validation-gate.md)).
6. Then — Joe's separate decision — the reopened release-wide hls-samples
   2026.1.0 goal.

## Pinned targets (verify by hash at use)

| Item | Target |
|---|---|
| FIM | `ofs-agx7-pcie-attach` tag `ofs-2026.1-1`, commit `866c25bb166810f65aae4f6b15374d0a89810e69` |
| fim-common | `147cae890b7d1245301cf5cde229f761b287b70d` |
| PIM | retained `3c21189e728009d4c492fa2be54c0ab1008b06dc` |
| Quartus | 26.1.1 Build 130 at `/opt/altera/26.1.1` (explicit override required) |
| Device / timing | AGFB027R25A2E2V / 3.000 ns |
| Erratum policy | only the exact VF pending-before-FLR warning is accepted ([policy](qualification/caps03-runtime01/ERRATUM-ACCEPTED25.md)); raw `success=false` stays unedited |

Carried QSF items: `ALLOW_REGISTER_RETIMING OFF` (EMIF1 `bit243`),
`ENABLE_INTERMEDIATE_SNAPSHOTS ON`, fit-only 10 ps hold-margin overlay with
signoff-skip guard, CLOCK_SPINE 2 records. PLL stays 470 MHz; never round
100.714286 MHz. `top.sdc` is the four-line maintained form (`b706fc11…`);
guarded candidate stays parked.

## Workstation safety — carried forward

- No speculative MMIO/BAR reads, UUID/base scans, `/dev/mem`, or raw probing.
- One card owner, one operation at a time. Timeout/disconnect/unexpected
  response = stop, preserve, report. Never duplicate-launch, auto-reset,
  rescan, rebind, reflash or reboot after failure.
- No BIOS/AER/permission/link/service changes to force a pass. Never improvise
  power sequencing. No unbounded loops or unreviewed recovery experiments.

## Working method

- Repository `/home/joe/Projects/Thesis/AHLS/new_bsp/new`, branch
  `migration-ofs-2026.1-quartus26.1`, remote `github.com/joekurina/ia_840f_ahls`.
- Workstation `uwb_student00@100.101.227.97`, build root
  `/home/uwb_student00/ahls/new_BSP`, owned tmux only.
- Parent implements and executes; independent review accepts actual results;
  subagents never author executable changes or touch hardware.
- Subagent preference: GLM-5.3 (zai); GLM-5.3-Flash for watcher-class tasks.
  Disclose any substitution (reviewers ran on GPT-6.1 during GLM outages).
- End-of-session handoff: replace the handoff state, don't append chronology.
  Record only current state, exact active job if any, one next action. Never
  mark an old job active from a delayed notification.
