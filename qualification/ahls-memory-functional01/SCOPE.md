# Connected AHLS numerical simulation

Run the actual generated AHLS DDRIP, connected DMA/fabric and both actual PIM bank shims against byte-accurate synthetic host/bank memory endpoints. This is own-logic simulation, NOT vendor DDR simulation; DDR vendor simulation remains SKIPPED BY USER. Use real MMIO CSR transactions, DMA host-to-bank input staging, generated-kernel start/status/finish, and DMA bank-to-host copyback. Check every numerical result and surrounding guard byte, deterministic stalls, delayed write responses and distinct bank clocks. Observe synthetic endpoint drain before copyback rather than claiming HLS finish proves physical visibility. No primary PCIe mapper/OPAE/physical DDR/reset/PR or live hardware operation.

Preserve first failures and change only the demonstrated source/fixture issue in a successor. Bound native commands/process groups and resources using the existing supervisor. Prior structural A&E evidence is reused, not rerun.
