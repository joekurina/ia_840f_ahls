# Connected AHLS memory fabric — native Quartus25.1 iteration

Implement a fresh Platform Designer fabric using the [AI Suite donor](../ai-suite-ofs-reference01/REUSE-FINDINGS.md), accepted [AHLS import](../ahls-memory-pd25-import01/RESULT-ACCEPTANCE.md) and [elaboration](../ahls-memory-elab25-01/RESULT-ACCEPTANCE.md). Keep the scalar AFU and all prior FIM/native attempts unchanged.

The candidate has an AXI MMIO input, a separate exported DMA CSR path at byte0, and the actual AHLS CSR at byte0x10000. Two independent bank paths each arbitrate a donor-style512-bit AXI DMA input with one34-bit/256-bit AHLS Avalon host, using native protocol/width adapters, to a34-bit/512-bit AXI output. The donor bridge parameters are preserved, with geometry evaluated for this board. No DLA runtime or MMIO address-span extender is introduced. [Candidate provenance](../../afu/ahls_memory/fabric/provenance01.json).

This first step generates connected fabric RTL; it does not yet instantiate the DMA engine or PIM top. Intended later composition uses a single primary mapper for host channel0 and independent per-bank PIM CDC in bank0's core domain, as in the donor. Device reset-release, final PIM ID/user widths and memory visibility remain open. Exception output is constant zero and never a numerical/error checker. DDR simulation remains SKIPPED BY USER.

Native import/generation is authorized source-side work under GOAL-PROMPT.md. Fresh remote work only; original AHLS inputs, installed tools, Work21 and maintained SOURCE remain preserved. Explicit Quartus25.1 environment, resource preflight, two CPUs, per-process16GiB AS bound, finite600s command deadlines, and owned-process cleanup use the existing import runner. No FPGA access, driver change, flash or reboot occurs.
