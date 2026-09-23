# MMIO full-address admission and persistent faults — connected simulation

**Native candidate green03 passes; independent review pending.** [Scope](SCOPE.md), [source binding](source-binding01.json), [parent verification](parent-verification01.json).

## Actual result

Questa Intel FPGA Edition2024.3 from the validated Quartus25.1 installation; fresh work_ahls_mmio_guard01/green03, tmux@239/%239. All5 native/effective commands0, outer0, no diagnostic errors, all original/input/tool checks true and no timeout or remaining owned group.529sources/450HDLunits include actual generated AHLS/DMA/fabric and PIM bank adapters, not a kernel substitute. Final native markers:

```
AHLS_GUARD_NEGATIVE_PASS writes=11 reads=5 stable_checks=107
AHLS_GUARD_UNIT_PASS cases=4 elements=91 copied_bytes=1088 dma=16 checks=2821 mmio_reads=275 mmio_writes=97 bank0_W=18 bank1_W=31
```

Simulation ends49480ns,0errors/255warnings. Complete warning rows remain in [warnings03.json](warnings03.json); inherited warnings are not waived. The exact negative-count and positive-score checks are required by the runner, separately from native exit codes. Counts275/97 are this test's total MMIO transactions, not host performance evidence.

## What changed

The new guard sees the full20-bit byte address **before** the generated low17-bit router. Forwarded windows are the existing DMA/identity64KiB and kernel256bytes at0x10000. Full aligned64-bit accesses and write strobes are required. Invalid high addresses, bad alignment/size/strobes and diagnostic writes never assert downstream requests. Individual DMA register/value checks remain in the real CSR manager; their DECERR/SLVERR responses are captured as persistent faults as well.

Read-only diagnostic registers at AFU-relative0x20000/08/10/18 expose an identifier, saturated per-direction counters and immutable-until-reset first-fault records. Bit definitions and reason codes are in SCOPE.md. They are a **new candidate AFU ABI**, not an address authorized for hardware probing. Posted-write BRESP may be ignored upstream by PIM, so software-readable state is retained instead of assuming a returned B response reaches the CPU.

AW/W are buffered independently and retained until each downstream handshake; R/B payloads are held through source backpressure. The guard serializes operations and gives already-presented writes priority over read admission. The test overlaps a status read with a rejected write and holds BREADY low; the read sees the updated count. This proves ordering within this guard for the exercised interface sequence, **not PCIe ordering of writes not yet received or global DMA/kernel drain**.

Final source: `afu/ahls_memory/control/ia840f_ahls_mmio_guard02.sv` (module name remains unsuffixed); final test `ahls_mmio_guard02_tb.sv`. Compile only the selected source, not both failed/final same-name implementations.

## Directed checks

- Rejected kernel alias0x30080, DMA aliases0x40028/0x20028, unaligned addresses, invalid size and partial strobes, read-only diagnostic write.
- Unknown DMA register0x128 and zero length at0x38 reach the actual CSR layer and generate preserved downstream DECERR/SLVERR faults.
- Invalid reads return zero/DECERR; no rejected outer AR/AW reaches the fabric. Counters cover11writes/5reads exactly, including downstream errors.
- Full address/reason/response of the first write and read failure remain sticky after later faults and valid traffic. Valid records remain readable without clear side effects.
- DMA pointer canary is read back through actual MMIO. Kernel arguments have **no pointer readback**; the corrected fixture reads the buffered x registers hierarchically, without driving them, and asserts the value unchanged after rejected writes. Zero downstream-forwarding checks independently enforce admission.
- Both AW-first and W-first request ordering;107 sampled retained-response checks. Finite request/response deadlines remain.
- Four no-reset HLS cases1,8,17,65 retain91 exact arithmetic comparisons and1088 byte comparisons including724guards;16DMA transfers complete, and fault counters remain unchanged after that valid campaign. All golden outputs happen to be positive; no signed-extreme coverage is claimed.

## Preserved causal history

All native commands return0 in all five attempts; fatal logs correctly produce outer1 for the four failures.

1. **red01:** transparent PIM AXI-Lite connector,4275ns: alias write0x30080 returnsOKAY, expectedDECERR. Baseline fails before later canary checks.
2. **green01:** first guard,4335ns: same wrong response. Write classifier had no formal arguments and implicitly referenced enclosing captured fields; the observed combinational call did not update for the invalid address. Preserved failure; no universal simulator/synthesis claim.
3. **green02:** make address/size/strobe dependencies explicit function arguments. Invalid response/zero-forwarding tests now pass;4370ns failure exposes the fixture's unsupported kernel-pointer readback assumption. Captured ABI and CRA RTL show argument reads return status.
4. **red02:** corrected fixture uses read-only buffered-register observation; unchanged transparent baseline still fails0x30080 at4275ns.
5. **green03:** same corrected fixture; only guard source differs fromred02. Passes negative checks and full numerical regression. No assertion, alias address, DMA endpoint, generated kernel or memory model was weakened.

Parent independently verifies2645sourcepayloads across5runs, all script/result/outer/log hashes and input/original/tool preservation/lifetime evidence. The sole DUT delta in the final causal pair is the guard; fixture/model/compile/library bytes are identical.

## Not yet qualified

This guard is currently exercised in the connected simulation, **not yet inserted into the real-PIM alternate top or accepted by native Quartus A&E/mapped synthesis/fit/STA**. The previous page-safe PIM milestone does not cover it. Baseline/final source/fixture failures are retained, not relabeled.

Primary PCIe/OPAE and physical DDR are absent; synthetic host line-request behavior and fixture-only store/B visibility observation remain as in the accepted numerical gate.32-bit MMIO, arbitrary malformed peers, saturation over billions of events, reset under accepted traffic, fairness/starvation, full host posting/order semantics and timeout/cancellation are not qualified. Existing code is deliberately single-operation; a peer that never supplies the remaining AW/W or response can block progress. No live-access safety guarantee is made.

The guard does not validate kernel pointer/size/control values or enforce kernel/DMA one-in-flight lifecycle. It does not repair DMA capability/state truncation, first bus-error encodings, intermediate page-split error accumulation, device reset-release/freeze/PR or global drain/fences/buffer lifetime. A hardware release still requires those source contracts, fullFIMsignoff, safe recovery and actual OPAE/DDR/transfer/numerical/durable-boot gates.

No FPGA/MMIO/device/driver/flash/reboot operation occurred. All addresses above are simulated AFU-relative transactions. Vendor DDR simulation remains **SKIPPED BY USER**. Goal incomplete.
