# Mailbox04 — independent SPEC successor review

**PASS — mailbox03 B1 is resolved. No residual blocking defect found in this bounded successor review.** The RELEASE-install edge now retains the epoch window when a simultaneous local request is rejected. The retained original-fail/fixed-pass evidence uses the same expanded fixture; subsequent DMA/reset capture and the separately isolated ARM-enqueue contamination case pass in the recorded fixed runs.

## Scope and inherited findings

This review closes B1 from `../mailbox03/SPEC-REVIEW.md:33–51` and the enqueue-test weakness at `:69`. It reuses that review's unchanged broad findings and deferred integration obligations rather than repeating them. The applicable requirements remain `../mailbox03/PLAN.md:5–9`, `../mailbox03/RESULT.md:34`, and `../DESIGN01.md` §§3–5: close the core epoch only on successful RELEASE completion, give coincident faults precedence, and monitor DMA attempts starting on ARM acceptance itself.

The candidate02 observer remains byte-identical to the predecessor's reviewed source. This is SPEC acceptance of the standalone digital mailbox correction, not counter requalification, QUALITY approval, CSR/AFU integration, physical CDC/reset timing, controller visibility, hardware acceptance, publication or teardown safety. Native width-adapter experiments are outside this review.

## Exact successor and evidence binding

Local byte comparison establishes:

- The **only mailbox RTL change** is appending ` && !source_reject` to the RELEASE epoch-clear predicate at `ia840f_ahls_observer_mailbox.sv:103`. Replacing the unique predecessor predicate with that predicate reproduces the complete successor bytes; no other RTL delta exists.
- The **only fixture change** is insertion of the two cases at `tb_observer_mailbox.sv:132–149`. Removing precisely that insertion reproduces the complete mailbox03 fixture bytes. All prior scenarios, clock/sequence defaults, driver tasks and checks remain unchanged.
- The unchanged observer hash agrees with both mailbox03 `test02.json` and mailbox04 `green02.json`.

Independently recomputed SHA256 bindings:

| File | SHA256 |
|---|---|
| `../mailbox03/SPEC-REVIEW.md` | `8f7931f3c9f24cfbdabb59acdcd6cfa28b85e79edf2fdf7d14f2ded0c74ee2f1` |
| `../mailbox03/ia840f_ahls_observer_mailbox.sv` | `25ed4e4c7c02cc9a74d57f6e8a4dec932392a17735e76862853b08b21fd8710e` |
| `ia840f_ahls_observer_mailbox.sv` | `980384d81f0bf54ade59f1a70e4f14bd72d83893709a71069fc5f595db3abc0a` |
| `tb_observer_mailbox.sv` | `1973821ef7a048c029740d67a77eaa7160c16a33b560dbb152f4929a5e12ecf2` |
| `../candidate02/ia840f_ahls_write_observer.sv` | `a903505e0fd7f0c64815ab1541cbeff4a0aa2feced83be434db0e99d80a516f3` |
| `red01.json` | `6035105edc6780f19ed8f7017ac74eed6a5c117adb256b746f57f8a922b19092` |
| `green02.json` | `c12e34f1c3376b5bc909ca30e81d3ce228c7a8dd49ffc72d8e900dae0ee5a9d5` |

All four retained fixed VVP artifacts match their individual hashes in `green02.json`; the retained `vvp` binary matches its recorded simulator hash. The VVP headers identify Icarus 12.0 stable, and their parameter/source tables agree with the recorded inputs. The RED artifact names the original mailbox03 RTL and the same local expanded fixture; its measured SHA256 is `ad1767db760d21492a7c26697dd3c1ac835d6ee65e9f8cb1f33e92d205ebf3d5` (measured here, not a hash recorded by `red01.json`).

## Original FAIL / fixed PASS on the same fixture

`red01.json:2–16` binds the original mailbox03 RTL and the exact mailbox04 fixture hash above, with the unchanged candidate02 observer. Its default parameters are sequence width64 and core/bank half-periods5/7ns, matching the first GREEN row's explicit parameters. Both fixture identities match the current bytes; this is not a weakened or separately corrected GREEN testbench.

RED compiled with exit0 and empty compiler output, then simulation exited1 at exactly:

```text
CHECK rejected RELEASE completion retains epoch window
core_errors=01 bank_errors=00 busy=0 valid=0 seq=2
```

This is the assertion at fixture line137, reported through the common check task at line56. Its logged rejection/invalid/not-busy terms already satisfy the assertion; the failed term is retention of `epoch_window`, reproducing B1 rather than a build failure or unrelated assertion.

`green02.json` records the fixed RTL against that same fixture:

| Sequence bits | Core/bank half-periods (ns) | Cases | Checks | Native commands | Compile / simulation exit |
|---|---|---:|---:|---:|---|
| 64 | 5 / 7 | 10 | 76 | 15 | 0 / 0 |
| 64 | 7 / 3 | 10 | 76 | 15 | 0 / 0 |
| 64 | 5 / 17 | 10 | 76 | 15 | 0 / 0 |
| 8 | 5 / 7 | 11 | 847 | 271 | 0 / 0 |

Every recorded compiler output is empty. These are inspected existing execution receipts, **not reviewer reruns**. The clock schedules repeat the directed scenarios, not disjoint coverage or physical metastability testing.

## B1 closure and continued fault capture

At fixture lines132–137, a fresh ARM and exact four-enabled-byte write/B retirement precede RELEASE. The fixture observes `box.source_complete` after a core edge, without forcing internal state, then asserts a second request at the falling edge before response installation. The outstanding command keeps `core_ready` low, so this is a rejected busy request, not a second accepted command. The following `ct()` checks after nonblocking updates.

In the fixed RTL, `source_reject` both sets local error bit0 (`:94`) and suppresses epoch closure (`:102–104`) on that same edge; it also prevents snapshot validity (`:124–128`). The added qualification sees the current rejection directly instead of relying on the previous value of `core_errors`. Busy clears and the faulted completion still installs, but the retained epoch remains open. With no rejection, the existing successful RELEASE behavior is unchanged and remains checked at fixture line102.

The same scenario then proceeds **without a core reset**:

1. Lines138–140 remove the rejected request, pulse a later DMA attempt for one core sampling edge, and require local DMA error bit2 plus the retained window.
2. Lines141–142 pulse bank-only reset and require local reset error bit1, the retained window and invalid snapshot.

The first added assertion checks rejection plus invalidity plus busy-clear plus retention; the later assertions independently require the additional fault bits. Thus the fixed runs demonstrate the requested continued monitoring, not merely invalidation on the original collision. The source retains these core error bits until core reset. A native observer already disarmed by RELEASE need not report the later DMA event in its frozen payload; the surviving core-local fault is authoritative under the existing contract.

## Isolated ARM-enqueue contamination

The old broad contamination case at lines125–127 is preserved and is still not edge-isolating by itself. The new case at lines144–148 fixes that evidence gap separately:

- It starts from `reset_case()`, with no active epoch or retained contamination, and checks readiness.
- At one core falling edge it presents ARM and `dma_write_attempt` together.
- After exactly the intervening rising edge, it deasserts **both** inputs at the next falling edge, before any later core sampling edge can observe DMA with an already-open epoch.
- It awaits the actual connected observer response and requires core contamination bit2, invalidity and native observer error bit5.

Consequently, this case cannot pass merely by detecting the attempt one core cycle after ARM. It exercises the explicit `source_accept && core_cmd==2'd1` term in `dma_now` (`RTL:53,56–57`) and propagation of the captured sticky fault to the unchanged observer. This conclusion combines the inspected pulse timing with the recorded fixed passes; no additional enqueue mutant was executed or claimed.

## Disposition

**B1: CLOSED. Isolated enqueue-test weakness: CLOSED for the directed acceptance-edge case. SPEC: PASS.** The remaining bounded-coverage limitations and integration obligations in mailbox03's review remain unchanged and are not promoted into new blockers for this one-condition successor. Parent QUALITY review remains separate.

Review actions were local reads, SHA256 hashing and textual/byte comparisons only. No build, test/simulator execution, SSH, device access, vendor tool, git operation or implementation edit occurred. The only authored file is `qualification/caps02-publication01/mailbox04/SPEC-REVIEW.md`.
