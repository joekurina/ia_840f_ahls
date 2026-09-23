# Matching Work21 PR-platform qualification scope

Produce the vendor OFS out-of-tree PR/PIM template from the already accepted Quartus25.1 Work21 static shell without rebuilding or mutating it. Preserve root QDB and SOF/MSF/PMSF identity, exact source/tool/PIM bindings, finite native execution and every failed attempt. Keep original gating and original sources; use a copied PR-only project and separately issued release-only callbacks. Normal-account execution is not an OS sandbox.

Accepted inputs: Work21 fit/assembly/constrained-numerical STA with unwaived signoff findings, and the exact public PIM source. This stage does not compile the guarded AHLS persona. Archive source discovery elaborates the intentionally empty OPAE_PLATFORM_GEN wrapper around the imported static shell; constant undriven template outputs are not evidence about active PCIe/DMA behavior.

Deliverable: native-generated release tree, source-discovery A&E/DRC evidence, exact image/interface/configuration bindings, failed-run dispositions and independent result review. No blanket warning waiver, no copied legacy authorization, no inferred fit/STA/PR/hardware acceptance. No hardware or device tools. VendorDDRsimulation SKIPPED BY USER. Goal incomplete.
