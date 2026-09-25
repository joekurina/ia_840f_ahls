# Mailbox04 — B1 release-edge correction

Original mailbox03 and its SPEC FAIL are preserved. The exact original RTL was compiled against the expanded fixture and failed the intended `rejected RELEASE completion retains epoch window` assertion (red01.json, native1). The sole successor RTL delta adds `!source_reject` to the successful-RELEASE epoch-window-clear predicate; no counter or memory datapath change.

The same expanded fixture with the correction passes (green02.json): production64-bit sequence at core/bank half-periods5/7,7/3,5/17ns, each10cases76checks/native0; sequence8 overflow run11cases847checks/native0. Compiler diagnostics empty. Source, simulator and emitted simulation executable hashes and both compile/simulation argv are retained.

The regression verifies retained epoch monitoring after the rejected completion, then captures a subsequent DMA attempt and a bank-only reset. An additional one-core-edge DMA pulse proves contamination at ARM enqueue without relying on a later still-high pulse. Prior connected tests remain.

No hardware, vendor IP simulation, source mutation of mailbox03 or deployed-image change. This fixes a lost-monitoring-window defect, not a demonstrated false publication in mailbox03. Independent successor SPEC review deleg_6de0d237 is pending; quality follows a PASS. Local CSR wiring and physical CDC timing remain outside this slice.
