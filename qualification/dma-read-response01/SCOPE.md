# Read-response error gate

Use paired-engine pair02 as the exact baseline. Add a separate test and additive reader patch; do not edit original donor, prior tests, frozen results or installed tools. Parent alone runs fresh owned-tmux Questa jobs under the bound Quartus25.1 installation. No FPGA, MMIO, driver or DDR-model execution.

Plan: (1) reproduce accepted non-OKAY RRESP being ignored using the real wrapper/FIFO/writer; (2) latch first non-OKAY response on an R handshake, report sticky rd_rsp_err/rd_resp_enc, continue the current valid descriptor's traffic, suppress descriptor dequeue and hold after writer-local completion; (3) prove baseline-fail/candidate-pass with the same directed test, including first/middle/final/single errors, EXOKAY, multiple faults, backpressure, no-reset good successors and combined write/missing-B faults; (4) freeze evidence for independent review.

Contract: valid same-ID ordered requests/responses and supported lengths. Bad read data may have reached destination: discard the entire failed descriptor's result. Sticky error is not drained/visible and never permits buffer release or reset. RLAST/RID/admission/overflow/4KiB, dma_top/bank/PIM routing, global stop/reset/fence and physical visibility remain separate unresolved obligations. Module reset in simulation is a fixture, not approved live recovery. DDR vendor simulation SKIPPED BY USER.
