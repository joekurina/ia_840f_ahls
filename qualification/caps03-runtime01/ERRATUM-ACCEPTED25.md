# Exact P-Tile warning accepted by user

Joe's instruction: “Accept the warning as the documented erratum and proceed with the remaining gates”.

The accepted message is exactly `vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway`, as observed in [live21-kernel.log](live21-kernel.log). It is accepted under the applicable P-Tile sticky VF Transactions Pending erratum described in [ERRATUM11](../caps01-dma-gib01/ERRATUM11.md) and its consumed review. This is an explicit qualification-policy exception, not warning suppression, a claim of measured zero outstanding requests, or a claim of warning-free teardown.

Preserve the original live21 receipt, `lifecycle_clean=false`, outer1 and logs unchanged. Its verified numerical pass, native0 and empty ownership are now accepted for continuation with this disclosed erratum. Future tests may accept this exact message for the exact test VF while retaining it in their evidence. A different BDF/message, later FLR-completion timeout, AER/IOMMU fault, unexpected response, data/guard failure, owner remaining or unknown execution remains a failure. All finite-completion, visibility and ownership checks remain required.

Stop the pending-status workaround investigation. Do not add CII, status clears, a reset bypass, warning suppression or a new FIM build to eliminate this accepted warning. Continue repeated/boundary numerical tests and independent/isolation/simultaneous/sustained DDR gates on the accepted image. No hardware operation is authorized merely by this record without the existing source-bound preflight and single-owner conditions.
