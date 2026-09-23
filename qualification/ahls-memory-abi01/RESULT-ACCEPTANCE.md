# Parent disposition: recovered AHLS DDRIP source review

**ACCEPT_SOURCE_ABI_FINDINGS; HOLD_WRITE_RETIREMENT_IMPORT_INTEGRATION_HARDWARE.**

## Recovery and integrity

Delegation `deleg_be1b88cf` lost its owner before recording a terminal result, but its durable report [ABI-SOURCE-REVIEW01.md](ABI-SOURCE-REVIEW01.md) was saved. The parent read the complete report, preserved it unchanged, and measured SHA-256 `8b15f14e3c91c192a1564641710240a9304e182f26e3bfaede8423d20c65ce43`. This acceptance is a parent disposition of that recovered source research; it does not invent a successful delegation terminal status.

The parent independently verified all **169 captured files / 3,450,821 bytes** against both the compressed capture and the original AHLS generation inventory, and compared the extracted bytes exactly. See [verified-source-manifest01.json](verified-source-manifest01.json). The prior IP-generation acceptance remains unchanged; nothing was regenerated. The original sample SHA-256 remains `bbc41b6fb33646066a42d7fa1b009aca46ebc8a1f295feb0f8d200fe63f37b64`.

## Accepted source findings

- The raw `_di` CSR input is a 64-bit-word index, not a byte address. Pointer byte offsets are x `0x80`, y `0x88`, z `0x90`; size `0x98`, start `0x08`, status `0x00`, finish `0x30`. The outer `kernel_system` explicitly shifts byte addresses right by three. An integration decoder must prevent out-of-window aliases. [Review §§1–2](ABI-SOURCE-REVIEW01.md#1-active-hierarchy-and-address-units).
- Only the low 34 pointer bits survive packing. The compiler inserts the z memory-space prefix internally, then the LSUs project addresses to 34 bits. Software supplies per-logical-host byte offsets, not CPU pointers or guessed physical-bank addresses. Logical host-to-FIM-bank mapping remains a wrapper responsibility. [Review §3](ABI-SOURCE-REVIEW01.md#3-pointer-packing-prefix-and-projection).
- The finish value is two bits, padded to 64 bits, with delayed clear-on-read. A finish coincident with the read-sampling edge can be lost at the following clear; status polling and one-in-flight, quiescent finish draining must not be confused with concurrent atomic fetch-and-clear. [Review §5](ABI-SOURCE-REVIEW01.md#5-finish-counter-and-read-clear-timing).
- The parent checked the active write-interconnect parameters, direct external write/waitrequest wiring, token-ring FIFO pop and acknowledgment producer. Under zero waitrequest allowance, the FIFO retains an unaccepted write while `lsu_ic_top.sv:569` still synthesizes an external acknowledgment from asserted write alone. This is a **captured-source handshake/accounting defect**, not a demonstrated end-to-end hardware failure and not proof of a defect in an independently verified pristine vendor distribution. [Review §6](ABI-SOURCE-REVIEW01.md#6-does-done-wait-for-downstream-writes).

## Open boundaries

Completion cannot be used as downstream-write retirement evidence until that acknowledgment path is corrected or otherwise given a source-supported, verified contract. No fixed delay, ignored waitrequest, or tied external acknowledgment input is accepted as a workaround. No vendor or generated source was patched in accepting this report.

Quartus 25.1's effective Platform Designer address units/adapters, the complete imported dependency closure, physical bank geometry, DMA ordering/fencing, clock/reset/freeze handling, persona fit/timing and all hardware numerical/DDR/transfer/boot gates remain open. This record does not change the separately running Work21 FIM build, authorize hardware access, or reinstate DDR simulation.
