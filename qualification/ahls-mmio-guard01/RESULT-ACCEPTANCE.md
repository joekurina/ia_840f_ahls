# Parent acceptance — full-address MMIO guard simulation

**ACCEPT_CONNECTED_MMIO_ADMISSION_TELEMETRY_SIMULATION_ONLY.** Consumed FINAL [independent review](independent-review01.md), SHA256 `e37bd057122f4418155c3812222bfd073a50058faeb6d93af6f5d60dfb4220ef`, after [parent verification](parent-review-verification02.json) of all30 frozen package members and retained2645payload/native/log/outer checks in [the original verification](parent-verification01.json).

Final guard02/TB02 (compiled unsuffixed) closes the demonstrated aliases at the full20-bit simulated interface and retains fault telemetry. Final causal pair red02/green03 differs only in the guard DUT; native/effective/outer0 forgreen03, exact11write/5read faults and all91sums/1088bytes/16DMA correct. All failed attempts remain failures despite native0.43compile/255simulation warnings remain source-bound, unchanged from the final baseline pair; none points to the guard.

Keep F1/F2 as nonblocking fixture coverage findings:107 sampled comparisons are not exhaustive VALID-through-handshake validation, and the overlap count proves visibility, not an isolated B-retirement-edge test. Inspected RTL supports those hold/order properties. First-record alternate reason encodings, full reserved-bit oracle, saturation/reset/extreme-peer/fairness coverage remain limited; do not rerun unchanged evidence. Strengthen the next changed fixture.

Corrected kernel-pointer canary is read-only observation of generated buffered registers; argument CSR reads return status. Zero-forwarding and real DMA-MMIO canary remain. No forced register, relaxed negative assertion, substituted kernel or weakened numerical oracle.

The guard does not provide PCIe ordering for writes not yet received, physical visibility, global drain/fences, lifecycle/value admission, reset/PR safety or a live-access guarantee. Real primary PCIe/OPAE/physicalDDR are absent. Quartus/top integration and mapped/fullFIMfit/timing are separate. New diagnostic addresses are simulation/source ABI, not authorization for live probing.

No FPGA/device/driver/flash/reboot operations; DDRvendorsimSKIPPEDBYUSER. Goal incomplete. Successor pim03 is a fresh top integration/native check, not an unchanged simulation rerun.
