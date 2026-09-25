# Native write-retirement observer — implementation slice

Implement DESIGN01.md sections2–3 as one additive synthesizable passive native-clock module, with synchronous epoch commands and captured errors. Preserve existing HLS/PD/PIM/DMA/image sources. This slice counts accepted AW/W/B, enabled bytes, clean-checkpoint retirement, exact expected-volume epochs and sticky faults. It drives no memory ready/valid/address/data signals.

Acceptance: actual RTL simulation covers delayed final W/B, empty upstream gap, partial strobes, multi-burst fragments and hidden error B, W-before-AW, simultaneous channels, wrong IDs, count overrun/overflow, invalid commands, DMA contamination, reset and successful release. Test narrow counter widths only to reach overflow; production default64. All test addresses/data are simulated inputs, never device accesses. No mocked API response is represented as hardware evidence.

Deferred explicitly: asynchronous mailbox/reset lineage, guard CSR wiring, physical integration, controller post-B visibility contract, fitting/timing and hardware. Output is TARGET_RETIRED, never PUBLISHED. The new observer is not a complete AXI positional protocol checker or global teardown fence. Existing hardware kernel remains unlaunched.

Simulator dependency: extract Debian trixie iverilog12.0-2+b1 into this owned local tools directory; no system installation, remote run or vendor tool invocation. Preserve commands/logs and package hash. No new capability is written to the board.
