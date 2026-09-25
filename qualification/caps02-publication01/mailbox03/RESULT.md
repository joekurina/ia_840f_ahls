# Two-clock observer mailbox — actual connected RTL test result

## Result

The new mailbox was compiled and simulated locally with the unchanged candidate02 native observer, not a mocked observer response. `test02.json` binds exact source SHA256, argv and all four runs. Icarus12.0 `-g2012 -Wall` returned0 with no compiler diagnostics.

| Sequence width | Core half-period / bank half-period | Result |
|---|---|---|
|64|5ns / 7ns|8 cases,63 checks; native0|
|64|7ns / 3ns|8 cases,63 checks; native0|
|64|5ns / 17ns|8 cases,63 checks; native0|
|8 (overflow test)|5ns / 7ns|9 cases,834 checks; native0|

These rows repeat the same directed scenario set at different digital clock schedules; they are not four disjoint coverage sets or physical metastability tests. The8-bit run deliberately reaches the sequence limit and verifies saturation/failure, not wrap.

`negative-reset.json` records a deliberately faulty copy omitting bank reset from the observer-only common reset. It compiles, then fails the intended active-epoch reset assertion with core_errors=00, valid=1, sequence=1. Correct RTL instead invalidates the snapshot and records the epoch reset fault. This is a negative control of the new mechanism, not an old-FIM reproduction. `missing-feature.json` preserves the initial absent-module elaboration failure; it is not a functional baseline.

## What was exercised

- One-cycle ARM/SNAPSHOT/RELEASE command strobes into the actual observer, with one native ARM delivery.
- Coherent acknowledged ARM token, exact write-retirement snapshot and frozen snapshot contents while native totals subsequently change.
- Delayed final write response keeps retirement false.
- Native clock stopped after initialization: core status stays busy with invalid snapshot, no false completion; resuming that clock completes one request.
- Busy request rejection poisons local validity without issuing a duplicate command.
- Brief native reset during an active epoch invalidates results, preserves the core-side epoch window and sets a fault.
- Idle native reset invalidates the snapshot without rewinding the surviving core sequence; only a new explicit request produces another valid snapshot.
- Core reset invalidates both sides' handshake state and does not replay a pending ARM.
- DMA contamination on ARM enqueue, native ARM rejection, live native error and sequence overflow fail closed.

## Boundaries

This is **offline digital RTL evidence**, not hardware or physical CDC acceptance. Bundled payload stability is enforced by the request/ack protocol; physical max-delay/reset-recovery constraints and Quartus synchronizer treatment are still required before integration. `async_reg` annotations alone are not evidence of Quartus consumption or timing closure.

The mailbox drives only the new observer's reset, command and reporting signals. It does not reset or drive memory/FIM channels. Its live core outputs never wait combinationally for the bank clock, but the actual local-CSR response path is not integrated/tested yet. A halted core clock is outside this claim. The source command must be a pulse; acknowledgement and busy-clear do not mean success unless the resulting error/valid/token/sequence fields pass.

No HLS/generated-PD/PIM/DMA/image source was changed. No remote tool, device, MMIO, reset, reflash or numerical kernel run occurred. Counter quality review and mailbox independent spec/quality review remain. Post-B visibility, full AFU wiring, CSR validation, native synthesis/fitter/STA and hardware are unaccepted. TARGET_RETIRED is not PUBLISHED or global teardown safety.
