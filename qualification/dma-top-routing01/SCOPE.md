# DMA top routing native gate

Build the actual donor dma_top/csr_mgr/descriptor FIFO/mux and PIM register slices around the corrected engines and real data FIFO. Drive documented aligned full64-bit CSR writes, not forced internal descriptors. Synthetic host/two-bank line-request endpoints only; no device/PIM mapper/DDR model.

First reproduce high host-source address clipping, then change only src_mem's address width while retaining its data/tag parameters. Separately reproduce inactive-bank interference with the width-corrected top, then mask bank ready/response ownership and unselected response readiness. Each run uses a fresh owned tmux directory with bound tools and source payloads. Preserve prior tests, donor originals and failed attempts. Native iteration is authorized; result acceptance requires independent review.

Valid admitted descriptor assumptions: one descriptor at a time, modes1/2,64bytealignment, no bank crossing, ordered IDzero replies and supported lengths. CSR alias/byteenable/overflow/stop/reset and source admission are not yet fixed. No broad hardware-readiness claim; DDR simulation SKIPPED BY USER.
