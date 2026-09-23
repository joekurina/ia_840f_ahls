# green02 — invalid kernel-argument readback assertion

Explicit classifier dependencies fix the invalid write response: the alias now returnsDECERR and the zero-forwarding assertion passes. The next failure is the fixture's assumption that reading kernel argument0x80 reads back the pointer.

The previously captured ABI review explicitly says argument-address reads return status, not arguments. Actual DDRIP_function_cra_agent.sv:548–587 supplies that read mux;838–871 stores x in arguments_1_buffered_q/arguments_0_buffered_q. This is a fixture error, not evidence of a changed argument.

Successor fixture replaces only those two unsupported pointer-readback comparisons with read-only hierarchical observation of the source-identified buffered x registers. It still programs via real MMIO, checks no rejected transaction is forwarded, and retains a real MMIO DMA-pointer canary and all arithmetic/copyback tests. No DUT register is driven or forced. Baseline and corrected candidate are rerun on this same corrected fixture; prior failed records remain.
