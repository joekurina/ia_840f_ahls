# AHLS memory DMA adaptations

Additive patches against AI Suite commit `e0e07f7b1878a477dc4d1191918db8430193e148`; preserve original donor source and the existing scalar AFU. No complete adapted DMA is integrated yet.

`patches/read_request_handshake.patch` removes prior-cycle-ready dependence and holds a read request until its actual handshake. Native old-fail/new-pass unit results are in [qualification](../../../qualification/dma-read-handshake01/RESULTS01.md); independent acceptance pending.

`tests/` contains a source-bound native-SystemVerilog unit test and explicitly synthetic platform configuration/umbrella header. These fixtures are not a PIM mapper or hardware model. Original/candidate full source and PIM dependencies are hash-bound in the qualification source ledger and remain local.

Other DMA hazards are retained in the [independent donor review](../../../qualification/ahls-memory-fabric01/DMA-DONOR-REVIEW01.md) and its parent disposition. This patch alone does not fix writer timing, burst scheduling, errors, completion/drain, source-width truncation, bank ownership or host visibility. No hardware qualification or deployment approval.
