# CSR endpoint pipeline — native regression results

**Candidate source/native unit results; independent acceptance pending. No timing closure claim.**

The candidate adds continuously registered 65-bit inclusive source/destination endpoints. It changes neither the serialized AW/W/B transaction machine nor the original service-edge sampling of FIFO/error/control/freshness. Descriptor modes 0/3 still reject; modes 1/2 are retained. Legacy control is separate and still accepts low32-bit values, including3. [Source recommendation](source-review01.md), [exact patch](endpoint-pipeline01.patch).

Baseline SHA256 `b526562f8663139a1a5654e54695ada8de67ee260b3b6a79014344ab7f3c4073`; candidate `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77`. Originals are preserved. Only this AFU source differs from the selected Work21 source set.

## Native results

Both attempts used Questa2024.3 in the bound Quartus25.1 installation, two CPUs, finite16GiB address-space cap,120-second stage deadlines, source/tool/original checks and exclusive roots. Native/effective/outer all0 for version/vlib/vdir/vlog/vsim, no diagnostic errors/timeouts/owned survivors, every preservation flag true. [Integration receipt](outer-integration01.json), [differential receipt](outer-differential01.json), full result logs and runner configs retained locally.

- **integration01:** unchanged accepted corrected admission fixture with changed CSR:8 numerical copies,3397 R/W beats,19 AR/AW/B,8 successful retirements;110977 checks. High host source/destination4each, both directions and banks, inactive-bank isolation,3069R-stall/4908W-stall samples,38maximum buffered beats. Guard scoreboard56checks/32bad writes/4bad reads/20bad GO/20queue admissions. These helper counts are not the total MMIO transaction counts. Max-length cases are admission-only, not full max-length transfers.
- **differential01:** baseline and candidate instantiated together. The only baseline module change is its test-local module name.311 GO-oriented scenarios,1512 task-completed writes,23 reads,85 observed enqueue pulses,226 endpoint equality checks,665 minimum-three-cycle service gaps,106 B-stall and115 R-stall samples,246 synchronous module resets,8571 cycles,54876 assertions. Packed valid B/R, ready/valid timing, full architectural map and freshness compared before/after clock updates; continuous stalled-valid/payload checks extend through handshake. No internal production state was forced.

Directed coverage includes all6field orders ×3AW/W arrival styles ×2directions ×2banks ×2validity transitions; source/destination/length last before immediate GO; all descriptor mode/GO combinations,61reserved command bits with failed-GO freshness consumption,all8freshness combinations,invalid-access GO preserving freshness,individual bad-field invalidation,legacy control0–3,non-GO despite missing fields/full/errors,public status changes across split arrival and after B,preasserted next request during B stall,invalid access/read cases,and reset with AW-only/W-only/held-B/just-committed field.

The direct fixture has a synthetic public status input, not a real FIFO or sticky engine-error generator. Full-top integration is separate and unchanged from the retained healthy-transfer/full-queue fixture. It does not add unique queued-entry drain/error-recovery coverage or exhaust every suggested boundary case. No exhaustive proof, whole-FIM mapped behavior, hardware, reset/drain/PR or physical visibility acceptance follows.

## Pipelined next stage

After these real native regressions passed, the changed actual PR persona setup/synthesis was launched under standing native-iteration authority in `qualification/ahls-persona-work21-csr02`. Evidence review/publication runs in parallel; it is not a new execution-approval barrier. Fitter/final STA still must establish whether the arithmetic cut closes the3.000ns setup path without new failures. Clocks,SDC,staticQDB and other AFU/generated RTL remain unchanged. No hardware action.
