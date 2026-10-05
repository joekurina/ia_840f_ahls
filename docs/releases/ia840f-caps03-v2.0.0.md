# IA-840F CAPS03 v2.0.0 — OFS 2026.1 / Quartus Prime Pro 26.1.1 migration

This release migrates the accepted **CAPS03 static FIM + PIM + memory-HLS AFU**
platform from the qualified ofs-2025.1-1 / Quartus Prime Pro 25.1 baseline to
**ofs-2026.1-1 (commit `866c25bb`) / Quartus Prime Pro 26.1.1 Build 130**, and
re-qualifies it on the physical card: the migrated image was SDK-programmed,
boot-identified, and passed all five named hardware gates.

It is a source, documentation and qualification-evidence release. Publishing
this tag does not rebuild, program or test the card. The hardware acceptance
below is the recorded result of the 2026-10-03/04 campaign; nothing was re-run
to publish the tag.

## Checkout

```bash
git clone --branch ia840f-caps03-v2.0.0 --single-branch \
    https://github.com/joekurina/ia_840f_ahls.git
cd ia_840f_ahls
export REPO="$(pwd -P)"
```

The repository is private; use an account with access. The annotated
`ia840f-caps03-v1.1.0` (Quartus 25.1 baseline) tag remains unchanged and
published as fallback.

## What changed since v1.1.0

- **Upstream platform migration:** FIM source moved to
  `ofs-agx7-pcie-attach` tag `ofs-2026.1-1` (commit
  `866c25bb166810f65aae4f6b15374d0a89810e69`), fim-common
  `147cae890b7d1245301cf5cde229f761b287b70d`; the PIM is retained at
  `3c21189e728009d4c492fa2be54c0ab1008b06dc`.
- **Toolchain:** Quartus Prime Pro **26.1.1 Build 130**
  (`/opt/altera/26.1.1`); the explicit
  `QUARTUS_ROOTDIR_OVERRIDE` requirement is documented because the inherited
  launcher root once selected 25.1 (captured and preserved as help01).
- **Timing re-closed at the unchanged 3.000 ns application target:** mapped
  synthesis, first-attempt fit, and five-corner numerical STA (all 923 records
  nonnegative; +0.002 ns worst setup). EMIF1 closed via two CLOCK_SPINE 2 QSF
  records (+0.082 ns at the failing corner). The four-line `top.sdc` is the
  maintained form; PLL stays 470 MHz.
- **CDC evidence gate:** the scoped 20-FIFO/40-bundle discriminator ran natively
  in the migrated database — 2,700 exact-name endpoint joins resolved with zero
  gaps ([recorded CDC result in the migration aggregate](../../qualification/fim24-caps03-runtime01/MIGRATION-COMPLETE98.md#build-timing-and-artifact-lineage)).
- **Assembly & packaging:** one native `quartus_asm ofs_top -c ofs_pr_afu`
  (outer 0) with region-qualified outputs; offline GBS packaging verified
  payload-identical ([assembly](../../qualification/fim24-caps03-assembly01/ASSEMBLY-ACCEPTANCE28.md)).
- **Deployment:** BittWare SDK file package (non-RSU BOOT_INFO/P1 at address 0)
  programmed with `bw_agilex_flash_programmer` (the only flash route; JIC is
  packaging material, never writer input), erase/program/readback 100 %,
  byte comparison success, BMC Off/On with independent readbacks, exactly one
  workstation reboot. No JTAG was used.
- **Boot identity:** after activation the card enumerates with FIM interface
  UUID **`fc603c44-5c8f-5e94-bcbe-a5780030947c`** (application AFU UUID
  `d48dde9f-f551-578d-8bb0-69483ac95ec6` unchanged). The cached identity is
  source/module-bound probe evidence, not cryptographic attestation.

## Five real-card gates — all independently accepted

All five original operations returned application/container/outer **0/0/0**,
retained no owner, preserved boot, and passed payload/guard/full-host-page
checks. Each was reviewed FINAL PASS WITH LIMITS and published with
blob/branch/main-preservation verification.

| Gate | Verified actual result | Acceptance | Milestone |
|---|---|---|---|
| Numerical copyback | 9 signed integers `[-3,0,-5,-5,5,7,9,-16,-7]`, 36 result bytes, 156 guards, 6 descriptors, ticket 1 / completion `0x10002` | [review71/72](../../qualification/fim24-caps03-runtime01/COPYBACK-ACCEPTANCE72.md) | `51dceebe` |
| Boundary/repeat coverage | 34 cases, 2,982 integers, 11,928 result bytes, 5,224 guards, 536 descriptors | [review77/78](../../qualification/fim24-caps03-runtime01/COVERAGE-ACCEPTANCE78.md) | `59364892` |
| DDR independent/isolation/sustained | W0→W1→R0→R1, 2 GiB per bank, 67,108,864 descriptors, 594.000209015 s | [review83/84](../../qualification/fim24-caps03-runtime01/DDR-ACCEPTANCE84.md) | `a0e8ca51` |
| Logical walking-bit | 30 locations/bank, 120 descriptors, 1,920 copied-back bytes/bank | [review89/90](../../qualification/fim24-caps03-runtime01/WALK-ACCEPTANCE90.md) | `0d1e9ff2` |
| Bulk concurrent-bank | 65,536 integers, 262,144 output bytes, 128 guards, 8,324 descriptors, 268 tiles | [review95/96](../../qualification/fim24-caps03-runtime01/BULK-ACCEPTANCE96.md) | `60564071` |

Campaign aggregate and closure:
[MIGRATION-COMPLETE98.md](../../qualification/fim24-caps03-runtime01/MIGRATION-COMPLETE98.md).

## Retained artifacts (migrated image)

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Accepted `ofs_pr_afu.sof` | 10,067,421 | `00dbd01b5b8c7c0b49fb1f9340ac9464e61a634ff045a1c0c4b79a464175d46f` |
| SDK input RPD | 10,670,080 | `96fb0dc9e0716a712f9e77a09b11161ac495a6e16436beb756bf7fd04874647e` |
| JIC (packaging only) | 268,435,686 | `2e6f6bb02b04a511ba03cb4b93feab16f7570073826b46b15e989c552feacd1c` |
| Map file | 364 | `818df1df710349adf3b6720508ea3a91481a25162bb3ec304fb4eba3dcc0ffc2` |

These identify existing accepted artifacts, not the guaranteed output of a
future rebuild.

## Operator instructions

The v1.1.0 workflow guides remain the operator documentation and are linked
from the [README](../../README.md). Version-sensitive facts for the migrated
platform: Quartus 26.1.1 Build 130 with explicit root override; OFS tag
`ofs-2026.1-1`; FIM interface UUID `fc603c44-…` (was
`8f7d1a2f-…`-era 25.1 identity on the v1.1.0 image); expected
pending-before-FLR warning unchanged and scoped by
[ERRATUM-ACCEPTED25](../../qualification/caps03-runtime01/ERRATUM-ACCEPTED25.md).

## Retained acceptance limits

- Only the exact existing VF pending-before-FLR warning is accepted; anything
  else is failure. Each original trial retains `lifecycle_clean=false`,
  `lifecycle_accepted=true` and its unsuppressed journal.
- Native Design Closure FAIL for the disclosed physical scope remains recorded;
  the four-pin electrical basis carries forward unchanged settings, not
  independent signal-integrity certification.
- The release-wide HLS samples qualification (all 99 samples) remains paused
  and is not qualified by this release.
- General PR/cold/stopped-clock/active-failure recovery is not qualified.
- Raw evidence over the 2,000,000-byte publication cap and large binaries stay
  local, hash-referenced; this tag is not a ready-to-flash binary distribution.

## Provenance

- Campaign branch: `migration-ofs-2026.1-quartus26.1` (merged to `main` at this
  tag; 36 commits, `main` had zero divergence).
- Closure record: `2fb560c8` "Close scoped OFS 2026.1 Quartus 26.1 CAPS03
  migration".
- Campaign window: 2026-09-30 through 2026-10-04; card campaign day 2026-10-03
  (flash 13:35–16:35 PDT, activation 17:12 PDT, gates 17:28–19:26 PDT).

## Post-tag supplement: OFS AFU example instructions and results

The historical v2.0.0 tag is unchanged. Later source/evidence commits and release
attachments add the [AFU example operator guide](../ia840f-examples-afu.md) and
[copy/DMA repair report](../../qualification/examples-afu-debug-01/FINAL-SUMMARY43.md).
The original tag's generated source archives do not contain these later commits;
use the supplement's pinned checkout linked in the GitHub release notes.

All eight requested RTL variants have a scoped hardware pass: hello-world
Avalon/CCI-P/AXI, clocks, local-memory Avalon/AXI, and repaired copy-engine/DMA.
`PIM_advanced` is README-only and explicitly skipped, not a ninth AFU.

- Hello-world verifies a full64-byte MMIO-triggered DMA greeting.
- Clocks verifies divider/counter ratios and its packaged759MHz user target,
  not independently measured absolute470MHz.
- Both local-memory variants pass the commanded-data gate on banks0/1, not
  full-capacity/isolation/sustained qualification.
- Copy passes32×4096bytes with maxreq8/completion1, source-defined bitwise-NOT
  expectation,2048 read/write lines and zero data errors. Accepted repair
  milestone: `4ac6d7bad464428c8f7bd014cd5de24e8c4bb65f`.
- DMA passes bank0, one1024byteH2D and one1024byteD2H descriptor with all128words
  correct, using the original checked host and no host chunk workaround.
  Accepted repair milestone: `9ab6e4abe685ef8cdf1c3a02ef9db229ac442b79`.

The initial six-pass/two-failure report and its original receipts remain intact.
The follow-on corrects my wrong copy identity oracle and adds a shared256-byte
AFU-side packet cap with private USER4 response ownership. Actual retained PU
configuration allowed512-byte writes versus configured PF0MPS256/MRRS512; the
source/runtime discrepancy and paired tests support the diagnosis, but wire
packets/physical rejection were not captured. Gen3 itself is not a256-byte ceiling.

Both repaired tests retain a VFIO pending-transaction timeout/FLR-anyway warning
during cleanup. Data PASS and native0 do not establish global drain, reset safety,
future health or performance. Read-RRESP and intermediate-BRESP limitations remain.
Programming images, licensed tools and generated native workspace collateral stay
external and hash-referenced; this supplement is not a clean-checkout FPGA build kit.
No build, programming, reset or reboot was performed to publish it. Task prompt
files were removed from the current repository tree, not republished as runbooks.
