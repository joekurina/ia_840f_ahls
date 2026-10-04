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

## Status — scoped migration complete with retained limits

The migration to **ofs-2026.1-1 + Quartus26.1.1 Build130**, unchanged
**3.000ns** target, is complete under the accepted numerical/CDC and functional
qualification scopes. All five original migrated-image hardware operations
passed native/container/outer0 and independent actual-result review; accepted
milestones are published with blob/remote-branch/main-preservation verification.
Raw timing/coverage/readiness flags and all disclosed limitations stay unchanged.

- Reused source/export/fabric/persona/simulation/mapped synthesis/fit/STA/CDC basis.
- Assembly`278ec04`,GBS`b1ba229e`,SDKfilepackage`d8ebe698`,originalSDKprogram`4cea7532`.
- Deployment`22890505`: one accepted BMCOff/On/readbacks + normalreboot,
  staticFME`fc603c44-5c8f-5e94-bcbe-a5780030947c`,newboot verified.
- Numerical`51dceebe`,34-case`59364892`,DDRtrio`a0e8ca51`
  (594.000209015s,explicitdurationpass),walking`0d1e9ff2`,bulk`60564071`.
- Final ordinaryOS/artifact97: all original trials terminal, expected cachedFME,
  unchangedboot, retainedimages hashmatch, emptyobservedholders/maps/D/errors.
- **No active job/review, UNKNOWN owner or remaining in-scope gate.**

Authoritative scoped closure: [MIGRATION-COMPLETE98](qualification/fim24-caps03-runtime01/MIGRATION-COMPLETE98.md)
and its [mechanical aggregate](qualification/fim24-caps03-runtime01/MIGRATION-COMPLETE98.json).
This supersedes the old staged-but-unadmitted assembly handoff, not its raw records.
No accepted build/test/programming stage is to be replayed.

## Next action

**None for this migration goal. Stop here.** The reopened release-wide
hls-samples2026.1.0 goal remains incomplete and requires Joe's separate later
scope decision. No automatic expansion into that work or a new capacity,
performance, reset, programming or recovery campaign is authorized.

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
- End-of-session handoff: replace the handoff state, don't append chronology.
  Record only current state, exact active job if any, one next action. Never
  mark an old job active from a delayed notification.
