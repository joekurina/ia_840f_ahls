# DDR Hardware Validation Gate — acceptance standard for "working"

Date: 2026-09-19. Status: **agreed with Joe** — if the tests below pass on our
image, DDR is *working*; no further qualification behind them.

## Basis

The vendor validated the IA-840F board and the EMIF IP in their own
configuration. Our build differs in exactly two deltas, and the hardware test
empirically clears both:

1. `NUM_BANK_FIFOS` 8→0 (both channels) — our MSA timing correction.
2. Calbus/EMIF ordering (generated calbus0→discrete vs donor calbus1→discrete;
   physical channels/pins preserved) — the open calibration-association item,
   hereby reclassified **resolved-by-hardware-test, pending execution**.

DDR simulation remains skipped by user direction; this gate replaces it as the
functional evidence.

## Test standard

Target: both 16 GiB x64 channels — discrete (ch0) and RDIMM (ch1) — running
our Work12-derived FIM image.

1. **Each channel independently, then both simultaneously.** Independent-only
   passes would miss a shared-calibration conflict visible only with both
   channels calibrating/refreshing together.
2. **Address-dependent data patterns** — `data = f(address, channel)`.
   Constant patterns can pass under address aliasing or swapped channels;
   this is the single highest-value pattern choice.
3. **Full-or-large sweeps plus sustained traffic**: GBs per channel covering
   all banks/rows, several minutes of continuous traffic to catch
   refresh/thermal marginality (our 26.1.1-generated controller was never
   vendor-run).
4. **Host↔DDR through the AFU/PIM data path in both directions**, with active
   numerical verification of copied-back data (completion/status flags alone
   are not proof). Initial validation may use the HE-MEM exerciser; the AHLS
   component's own data test follows once integrated.

## Verdict semantics

- **All pass** → DDR = working; both deltas cleared; calibration-association
  item closed.
- **Any failure** → item reopens: capture per-address failure map, reexamine
  calbus ordering and `NUM_BANK_FIFOS` effects first.

Executed as part of the plan's hardware FPGA Tests stage (discovery → MMIO →
both DDR channels → host transfers → AHLS results), evidence under
`qualification/hw-validation-01/` when run.
