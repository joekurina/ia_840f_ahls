# CAPS03 runtime — numerical pass and normal exit, lifecycle warning

## Current result and state

Live21 ran the original CAPS03 frontend once on the unchanged accepted image and 3.000 ns target. It passed all nine signed results, 156 guard/padding bytes, six retired DMA descriptors and host-page checks, then exited **0** through normal cleanup. The outer result is **1**, not a clean pass: the kernel reported the exact pending-transaction-before-FLR warning. Postflight found no device owners, mapped owners or D-state tasks. No successor hardware test is running. [Full result](NUMERICAL21.md), [native log](live21-native.log), [kernel log](live21-kernel.log), [receipt](live21-result.json), [outer](live21-outer.json).

Current verified boot is `8121620d-a638-42f8-abab-a547aae32076`. The earlier retained PID7231/namespace/container lifetime ended during the verified ordinary reboot16; do not replay recovery against those historical IDs. Postboot17 checked the new boot, ended ownership, expected Work21 FIM identity and PF bindings. Fresh preflight18/create19/bind20 restored VF `0000:4f:00.2`, singleton group76, before live21. [Postboot](postboot17-result.json), [preflight](preflight18-result.json), [create](create19-result.json), [bind](bind20-result.json).

No reflash, new BMC cycle, generated-HLS change, runtime replacement, native host rebuild or timing relaxation was required. Original programmed-image acceptance remains intact; the new issue is the retained lifecycle warning, not failed arithmetic. [Deployment](../caps03-flash01/SDK23.md), [original host build](../caps03-host01/NATIVE-BUILD01.md), [result](NUMERICAL21.md).

## First numerical pass and consumed owner review

Live13 remains the first real hardware DATA PASS: one nine-integer case with complete returned-span and host-page checks, intentionally retained after success. Its native exit remains null and outer1; later recovery does not retroactively make it a normal exit. The additive retained frontend and original frontend remain preserved. [First result](NUMERICAL13.md), [live13 receipt](live13-result.json), [historical retained-owner observation](postlive14-result.json).

Review `deleg_6b73b417` is consumed. Parent verified the native source bindings, finite HLS producer/extent/AW/W/B completion, DMA retirement/quiescence and host visibility/guards against the existing release-then-close contract. This successful state permits normal cleanup without a new universal drain proof, but the deployed `_Noreturn` wrapper could not resume cleanup. Fresh recovery-pre15 and one ordinary reboot16 provided its supported disposition. No preliminary SIGCONT, kill, BMC cycle, reflash or explicit PCI reset was issued. [Consumed review](lifecycle-review15.json), [contract](../caps01-dma-host01/BUFFER-LIFETIME01.md), [preflight](recovery-pre15-result.json), [reboot](reboot16-dispatch.json), [verification](postboot17-result.json).

## Entry evidence retained

Review `deleg_62c01146` is also consumed. RESET08 passed 32 phase cases/64 idle FLRs for its projected chain, which omitted one PR-slot host register. Parent checked the omitted source against Work21 and used corrected conservative accounting: 241.315 ns recovery and 229.315 ns beyond four extra bank0 cycles. This supported bounded normal-idle entry, not a cycle-exact full-chain simulation, stopped-clock/PR recovery or universal teardown proof. No image change was needed. [Admission](entry-admission.json), [RESET08](reset08-result.json), [first-result details](NUMERICAL13.md).

## Accepted normal-return scope

Review `deleg_474adbdd` is completed and consumed in [normal-review23.json](normal-review23.json). Joe subsequently accepted the exact pending-before-FLR warning and directed continuation ([policy](ERRATUM-ACCEPTED25.md)). The normal-return numerical gate is accepted with that disclosed exception; original raw `success=false`, outer 1 and `lifecycle_clean=false` remain unchanged. No guessed status clearing, reset bypass, warning suppression or FPGA rebuild is required.

This report records the original numerical/normal-return gate, not the current ownership of a later run. The completed [repeated/boundary](../caps03-coverage01/RESULT.md), [serial DDR](../caps03-ddr01/RESULT.md), [walking-bit](../caps03-walk01/RESULT.md) and [bulk HLS](../caps03-bulk01/RESULT.md) results have separate scopes. The [full-capacity](../caps03-full-ddr01/RESULT.md) result and [lifecycle reconciliation](../caps03-lifecycle01/RESULT.md) govern the final checkpoint. See [normal-return acceptance](ACCEPTANCE26.md) and [the maintained goal](../../GOAL-PROMPT.md); no historical next-action paragraph authorizes another hardware operation.
