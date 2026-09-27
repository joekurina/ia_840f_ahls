# DDR Hardware Validation Gate — acceptance standard for "working"

Agreed with Joe on 2026-09-19. Status: **PASS on the accepted Work21/Quartus 25.1
CAPS03 image**, with the exact user-approved lifecycle erratum exception. DDR is
working under this agreed functional standard; no vendor-internal requalification
is added behind the pass ([combined actual-result acceptance](../qualification/caps03-full-ddr01/review16-consumed.json),
[final project acceptance](../qualification/caps03-final01/ACCEPTANCE.md)).

## Basis

The vendor validated the IA-840F board and the EMIF IP in their own
configuration. Our build differs in exactly two deltas, and the hardware test
empirically clears both:

1. `NUM_BANK_FIFOS` 8→0 (both channels) — our MSA timing correction.
2. Calbus/EMIF ordering (generated calbus0→discrete vs donor calbus1→discrete;
   physical channels/pins preserved) — the open calibration-association item,
   now **resolved-by-hardware-test** under the accepted combined result.

DDR simulation remains skipped by user direction; this gate replaces it as the
functional evidence.

## Test standard

Target: both 16 GiB x64 channels — discrete (ch0) and RDIMM (ch1) — running
the accepted Work21-based CAPS03 image at3.000 ns, built with Quartus 25.1.
The original Work12/Quartus26.1.1 wording described the earlier planned target,
not the image now accepted ([image and physical scope](../qualification/caps03-persona01/PHYSICAL-ACCEPTANCE01.md)).

1. **Each channel independently, then both simultaneously.** Independent-only
   passes would miss a shared-calibration conflict visible only with both
   channels calibrating/refreshing together.
2. **Address-dependent data patterns** — `data = f(address, channel)`.
   Constant patterns can pass under address aliasing or swapped channels;
   this is the single highest-value pattern choice.
3. **Full-or-large sweeps plus sustained traffic**: GBs per channel covering
   all banks/rows, several minutes of continuous traffic to catch
   refresh/thermal marginality. The combined board/OFS/HLS integration is
   empirically tested here, not claimed vendor-validated.
4. **Host↔DDR through the AFU/PIM data path in both directions**, with active
   numerical verification of copied-back data (completion/status flags alone
   are not proof). Initial validation may use the HE-MEM exerciser; the AHLS
   component's own data test follows once integrated.

## Verdict semantics

- **All pass** → DDR = working; both deltas cleared; calibration-association
  item closed.
- **Any failure** → item reopens: capture per-address failure map, reexamine
  calbus ordering and `NUM_BANK_FIFOS` effects first.

## Executed evidence and exact scope

- Independent banks, address/channel-dependent W0→W1→R0→R1 isolation and sustained
  traffic:2 GiB written/read per bank,590.093506230 s
  ([accepted sampled test](../qualification/caps03-ddr01/ACCEPTANCE07.md)).
- Sparse-address correlation follow-up:30 walking addresses/bank
  ([accepted result](../qualification/caps03-walk01/review04-consumed.json)).
- Concurrent functional bank0-read/bank1-write HLS:65,536 actively compared results
  plus DDR guards. This is source-supported concurrency, not measured wire overlap
  or sustained concurrent bandwidth ([accepted bulk result](../qualification/caps03-bulk01/review04-consumed.json)).
- Complete configured/exposed 16 GiB aperture of each bank written then read/compared,
  64 GiB aggregate traffic,536,870,912 descriptors. Full logical coverage removes the
  sparse-sampling dependency without claiming observed physical wire-address mapping
  ([full-capacity acceptance](../qualification/caps03-full-ddr01/ACCEPTANCE16.md)).
- OPAE/PIM host transfers and AHLS numerical/guard checks passed; six finite normal
  lifecycles ended with native 0/empty ownership under only the exact accepted
  pending-before-FLR warning ([reconciliation](../qualification/caps03-lifecycle01/reconciliation04.json)).

The combined actual-result review accepts this gate and closes both listed deltas.
The excessive 4702.629792690 s full-capacity runtime is an inefficient host-loop result,
not DDR bandwidth. Native Design Closure FAIL, excluded reset/recovery scopes and
warning-free/global-drain limitations remain disclosed; this pass does not erase
those distinctions ([final acceptance](../qualification/caps03-final01/ACCEPTANCE.md)).
No test, build or deployment is pending, and no spent operation is to be replayed.
