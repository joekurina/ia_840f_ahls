# IA840F PF1 BMC FLR: source-only decision

## Decision and scope

**Do not change reset wiring or RTL on the evidence available here.** The vendor
BMC endpoint and pinned modern OFS ST2MM do not implement a PF1 host-transaction
cancellation/drain boundary. Clearing only the TX CDC would remove one stale
completion store, but not prevent surviving CSR-domain requests from producing
new old-generation completions after reset. Resetting all CSR-domain bridge
state instead would abandon independently accepted AXI channels against a live,
shared slave. Neither is a vendor/OFS-proven portable correction.

This is a concrete source-contract gap, not a claim of an observed hardware
failure. No HDL/Tcl execution, tests, build/configure/IP generation, installation,
remote access, programming, commit or push was performed. Active target remains
AHLS/OFS/OPAE. The PCIe/BAR2 derivation and presets are untouched. All gates remain
closed; `ready_for_build` remains false. Only this review document is added.

Paths below use these roots:

- `C/`: `new/ofs-agx7-pcie-attach/`, relative to `new_bsp/`.
- `V/`: `old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/`, same parent.
- `B/`: `C/src/board/ia840f/`.
- `S/`: `C/ofs-common/src/common/st2mm/`.
- `L/`: `C/ofs-common/src/common/lib/`.
- `Q/`: `C/ipss/ia840f/bwbmc/`.

Existing `docs/vendor-derived-bmc.md:99-122` is consistent with this review.
Its statement about reset ownership is not transaction-safety qualification.

## Reset ownership and retained state

| Boundary/state | Actual reset owner and source evidence | Effect of PF1 FLR alone |
|---|---|---|
| Link-0 PF/VF routing and A/B muxes | `B/fim_afu_instances.sv:105-151`: interface and mux resets are `rst_n[0]` | No PF1 reset input at these mux instances; downstream reset is not proof that already queued upstream traffic has disappeared. |
| PF1 endpoint selection and port reset | `B/fim_afu_instances.sv:168-210,219-239`: PF identity 1, VF inactive; PF reset AND system reset, registered then duplication tree | `bwbmc_st2mm.rst_n` is PF1 port reset; `rst_n_csr` stays global CSR reset. |
| RX CDC FIFO | `B/bwbmc_st2mm.sv:118-134`; `L/axis/ofs_fim_axis_cdc.sv:40-77` | FIFO asynchronous clear uses `~axis_s.rst_n`, here PF1 port reset. |
| Zero-stage RX binding | `L/axis/ofs_fim_axis_pipeline.sv:53-62` | Pure combinational stream connection, **not** an admission/quiesce gate. `tready` is forwarded; CDC ready is `~fifo_almfull`, not explicitly qualified by PF1 reset. Do not interpret ready during FIFO clear as guaranteed retained acceptance. |
| Packet-filter register/demux and request pipeline | `B/bwbmc_st2mm.sv:163-182`; `B/bwbmc_st2mm_rx_bridge.sv:39-81`; `S/st2mm_packet_filter.sv:62-90,106-125` | CSR reset only. Requests already beyond RX CDC survive PF1 reset. |
| AXI channel valids, pending counters and response acknowledgments | `S/mmio_req_bridge.sv:158-184,243-312,332-413` | CSR reset only. AW/W/AR requests can continue; B/R responses can still retire. |
| Completion metadata FIFO, read-data FIFO, packet staging | `B/bwbmc_st2mm.sv:188-210`; `S/st2mm_tx_bridge.sv:36-59`; `S/mmio_rsp_bridge.sv:128-239,256-268,322-339`; `S/mmio_rsp_tag_tracker.sv:85-105` | CSR reset only. Existing completion information and newly arriving late responses survive PF1 FLR. |
| TX CDC FIFO | `B/bwbmc_st2mm.sv:41-44,136-142`; `L/axis/ofs_fim_axis_cdc.sv:54-77` | Source is CSR-reset `st2mm_tx_if`; PF1 reset of the destination does **not** clear its FIFO. Destination reset only restores `out_is_sop` (`:43-50`); with default `DENSE_OUTPUT=0`, `tlast_fifo_rvalid=1` (`:80-83`). |
| TX skid/output registers | `B/bwbmc_st2mm.sv:144-149`; `L/axis/ofs_fim_axis_pipeline.sv:14-26,84-105`; `L/axis/ofs_fim_axis_register.sv:173-207,244-264` | PF1 port reset clears skid/output valid and deasserts upstream ready. It does not clear the preceding TX FIFO or CSR producer. |
| BMC AXI/Qsys and shared SPI/SDM | `B/fim_afu_instances.sv:224-245`; `B/bwbmc_wrapper.sv:74-120` | Global CSR reset only; no host-only reset or cancellation/idle port exists at this wrapper. |

Shared reset connectivity is explicit, not inferred from names:
`Q/bw_840_support.qsys:9778-9783` connects `sysrst_bridge.out_reset` to AXI,
MM bridge, host pipelines, system ID and nested `system_rst`.
`Q/bmc_spi_sub.qsys:19382-19395` connects separate `sdm_reset.out_reset` to
`sdm_mailbox.in_reset`, and `system_rst_bridge.out_reset` to SPI transport,
shared/host pipelines, arbiter, IRQ generators and RAM reset. The wrapper feeds
both from inverted global CSR reset. Host and SPI SDM masters both reach
`sdm_pipeline.s0` (`Q/bmc_spi_sub.qsys:19219,19261`). PF1 FLR must not be routed
into either shared reset to mask the missing transaction boundary.

## What accepted and pending actually mean here

1. **PCIe stream acceptance:** CDC writes on source `tvalid && tready`
   (`L/axis/ofs_fim_axis_cdc.sv:63-68`). This only establishes entry into that
   FIFO during valid operation, not AXI acceptance. RX FIFO clearing cannot
   retract traffic already sampled by the CSR packet filter (`S/st2mm_packet_filter.sv:62-90`).
2. **Request-bridge acceptance:** `i_mmio_req_st.tready = load_cmd`
   (`S/mmio_req_bridge.sv:145`). A read handshake records requester ID, PCIe
   tag, length, attributes and lower address through registered `o_tlp_rd`
   (`:192-203`), **before** downstream AR acceptance. Request payload/valid
   pipeline is at `:158-184`; `load_cmd`, `csr_cmd_active` and `wait_ack` are
   at `:377-405`. Thus READ_ALLOWANCE=1 does not imply that every accepted
   request has reached the slave, or that only one request/completion exists
   in the entire endpoint.
3. **AXI acceptance:** AW, W and AR use separate VALID/READY handshakes.
   Their valid bits retire independently (`S/mmio_req_bridge.sv:332-375`);
   `S/axi_lite_if_conn.sv:45-78` is combinational wiring, not an isolation
   adapter. A write may have AW accepted without W, or W without AW. Clearing
   host bridge state alone is not cancellation of the live Qsys slave state.
4. **Pending request accounting:** `write_add = mmio_wvalid_t2 &&
   ~csr_cmd_active`, `read_add = mmio_arvalid_t2 && ~csr_cmd_active`; subtracts
   use delayed B/R handshake acknowledgments (`S/mmio_req_bridge.sv:243-312,408-413`).
   These are local launch/response counters, not exported drain status and
   not completion delivery counts. The source uses WRITE_CNT_WIDTH for the
   read counter as well; both allowances are 1 at this board instance, so
   this review does not alter that inherited implementation.
5. **Response consumption:** `S/mmio_rsp_bridge.sv:128-149` sets AXI RID to
   zero internally, accepts R when its response FIFO is not almost full,
   and holds BREADY high. Accepted R is queued; B retires the posted write
   locally and does not create a PCIe read completion. R/B acceptance is
   not evidence of PCIe TX delivery.
6. **Response storage:** for this READ_ALLOWANCE=1 instance, the response
   FIFO has depth-log2 5, with its `almfull` output used as `rsp_fifo_full`
   (`S/mmio_rsp_bridge.sv:156-178`). Metadata uses a separate FIFO, not AXI
   transaction IDs (`USE_AXI_LITE_TID=0`, `:208-239`;
   `S/mmio_rsp_tag_tracker.sv:85-105`). Staging includes `fifo_mmio_rsp_t1`,
   `ctt_re`, `send_packet` and `tx_q` (`:181-194,256-268,322-339`), then the
   board TX mux and depth-log2 6 CDC (`B/bwbmc_st2mm.sv:55-85,136-149`).
   These stores have no FLR generation field or late-response discard input.

Reset-sensitive registered strobes also need an explicit contract in any future
change: `o_tlp_rd` and delayed response-ack registers in the request bridge,
and `rsp_fifo_wr` in the response bridge, are not reset in their defining
always blocks (`S/mmio_req_bridge.sv:192-203,408-413`;
`S/mmio_rsp_bridge.sv:142-149`). A one-wire CSR-reset patch does not establish
coordinated producer/consumer invalidation or safe release.

## Exact PF1 reset and response intervals

`C/ofs-common/src/common/flr/flr_rst_mgr.sv` has `RST_CNT_WIDTH=7`
(`:30-34`), reset predicate `cnt[6] & cnt[5]` (`:70-79`), and busy predicate
`cnt[6]` (`:81-87`). PF decode, registered reset and counter are at `:95-124`.
For an isolated, one-CSR-cycle PF1 request, with global reset inactive and the
counter initially idle, let E0 be the CSR edge sampling request valid:

| CSR edge / interval | Result after edge |
|---|---|
| E0 | `pf_flr_rst_in[1]=1`; counter remains zero; registered `pf_flr_rst[1]` is still zero. |
| E1 | Counter wraps to 127; registered reset asserts from the decoded request. |
| E1 through E32 | Counter traverses 127 through 96: 32 counter-state intervals satisfying reset predicate. |
| E33 | Counter becomes 95; registered reset remains asserted using the preceding count 96. |
| E34 | Registered reset deasserts. |
| E33 through E64 | Counter traverses 95 through 64: 32 counter-state recovery intervals. |
| E65 | Counter becomes 63; busy predicate becomes false. |
| E66 or later | Earliest registered PCIe FLR response if this request is FIFO head and valid; queueing behind other FLRs may delay it. |

The registered CSR reset pulse therefore lasts 33 CSR periods, including its
trigger cycle. Do not quote the 32 reset-predicate states as the full registered
pulse. These are arithmetic/source deductions, not HDL execution or waveform
measurements; repeated request-valid cycles are outside the isolated-pulse
assumption.

`pf_flr_rst_n` then crosses through a three-stage `fim_resync` into `clk`
(manager `:164-175`; `L/sync/fim_resync.sv:92-104`). The board adds one
`port_rst_in_n` register and `TREE_DEPTH=3` duplication tree
(`B/fim_afu_instances.sv:198-209`). That tree has **three registers plus a leaf
register**, not only three (`L/sync/fim_dup_tree.sv:27-38`): five additional
`clk` stages after the resynchronizer output. Both assertion and release take
this path. Exact elapsed time and destination pulse duration depend on the
clock relationship; there is no nanosecond or fixed `clk`-cycle guarantee here.

The manager queues delayed FLR requests and pops the head when its counter is
not busy (`:204-247`). Its port list (`:35-47`) has **no endpoint drained/idle
input**, and it does not wait for AXI R/B, request counters, completion FIFOs,
TX delivery or a return acknowledgment from the port-reset duplication tree.
Recovery is a time allowance for reset propagation, not a drain guarantee.

## Vendor and standard OFS precedent

- `V/src/afu_top/fim_afu_instances.sv:230-271` passes the vendor port reset
  only to BMC `rst_n`, passes global CSR reset to `rst_n_csr` and the wrapper,
  ties `flr_rst_n=1`, and leaves `flr_ack` unused. Its old numeric BWBMC_PID and
  obsolete PF3 comments are not a reason to undo modern PF1 identity routing.
- `V/src/afu_top/bwbmc_st2mm/bwbmc_st2mm.sv:81-99,104-126,140-187` has the
  same edge-pulse acknowledgment and CSR-only bridge resets. Its RX CDC uses
  port reset for FIFO write side, and TX CDC uses CSR reset for FIFO write
  side. `V/ofs-common/src/common/st2mm/pcie_axis_cdc_fifo.sv:39-58,71-89`
  clears the FIFO using `snk_rst_n`; output `src_rst_n` clears only output
  valid. Restoring the old CDC is therefore not a stale-completion fix.
- Modern `S/st2mm.sv:96-142,156-205` retains the pulse-only `flr_ack`,
  source-reset CDC and TX skid with CSR-only RX/TX bridges. `flr_rst_n` is
  consumed only by its falling-edge detector; no queue occupancy or AXI
  response condition enters that acknowledgment.
- Crucially, the normal OFS management instance is **PF0**, not this PF1
  endpoint: `C/src/afu_top/afu_top.sv:501-531` uses global link/CSR resets,
  omits the FLR ports, and explicitly says link-0 PF0 management FLR has no
  meaning. This is precedent for management remaining alive, **not** proof
  that a shared management slave behind a resettable PF1 is transaction-safe.
- Vendor and modern `flr_rst_mgr.sv` are byte-identical, as are their
  `mmio_req_bridge.sv` files. A static diff of `mmio_rsp_bridge.sv` shows
  interface/width adaptation, not a newly introduced FLR cancellation contract.

## Specific failure exposures and rejected partial patches

- **Already queued TX completion:** it can remain in CSR-reset TX CDC through
  PF1 reset while the downstream skid is cleared/backpressured. Release allows
  old data to advance; no FLR generation check exists at this boundary.
- **Read accepted by live Qsys, response late:** preserved CSR state can build
  an old completion after the port-reset interval, even if TX FIFO alone were
  cleared. The timer does not inspect that read.
- **Request accepted into CSR filtering/pipeline but not AXI:** it may issue
  during PF1 reset, since those stages are not reset or FLR-gated.
- **Write with only one channel accepted:** resetting the master alone can
  lose the complementary channel or associate later traffic with leftover
  slave state. Resetting the shared slave to avoid this violates SPI/SDM
  ownership. No such reset is proposed.
- **Completion already accepted into a global mux:** endpoint-local clearing
  cannot retract it. The mux instance receives only global reset. Its ordered
  behavior relative to PCIe FLR response needs a contract beyond local queues.

These are source-permitted exposures, not simulated counterexamples. No
invented timeout, epoch protocol, transaction-drain FSM or successful responder
is installed. Wiring `flr_ack` to any notion of drained status would be false:
it reports an input edge, is suppressed by `rst_n`, and is unused here.

## Required interface evidence before a correction can be selected

The following are precise requirements for a vendor-supported implementation
or an explicitly authorized future design. They are not new protocol choices:

1. **Admission boundary:** identify the last PF1 request accepted before FLR,
   including globally reset PF/VF mux storage, CDC contents, filter/demux and
   MMIO pipeline; define when admission resumes. Supply an existing mechanism
   for quiescing or classifying this traffic across `clk` and `clk_csr`.
2. **AXI ownership:** account separately for AW accepted, W accepted, AR
   accepted, B outstanding and R outstanding. The shared Qsys boundary must
   either provide documented host-only cancellation/isolation semantics or
   permit outstanding host work to finish without presenting old completions
   as new traffic. Include partial writes and error responses. Current wrapper
   exports neither cancellation nor an idle/drained indicator.
3. **Metadata/data correspondence:** define disposition of pre-AR metadata,
   late R responses and all response staging; prevent an old R response from
   consuming a newly accepted request's tag. Include counter/ack strobe
   release behavior. AXI IDs are tied zero and cannot identify generations.
4. **Completion boundary:** cover response FIFO, metadata FIFO, packet
   staging, TX CDC, skid and completions already passed to the global mux.
   Prove no old PF1 completion can escape after the defined FLR completion
   boundary under backpressure. A local FIFO clear alone is insufficient.
5. **FLR response contract:** either prove the existing fixed timer always
   suffices under documented latency/backpressure bounds, or provide a
   supported manager interface that waits for actual safe completion. No such
   bound or manager acknowledgment input is established by these sources.
   The edge-pulse `flr_ack` is not that interface.
6. **Shared services and reset crossing:** keep SPI transport, RAM, arbitration,
   IRQ state and SDM live for BMC-originated work; provide generated-interface
   evidence for any host-only boundary and defined cross-domain reset/release
   ordering. No speculative Qsys reset rewiring is acceptable.

Later functional qualification must exercise each distinct stored/pending case
above, including asymmetric AW/W acceptance, delayed/error R/B, TX backpressure,
request/tag reuse after FLR, reset propagation and concurrent SPI-originated
SDM work. Those are future acceptance criteria, not tests run in this pass.

## Permitted static results and unchanged provenance

- Parsed the existing manifest as JSON: `ready_for_build` is false.
- Recomputed SHA-256 for all **116** manifest records having `path` and
  `sha256`: all current local target files exist and match. This validates
  recorded bytes only, not elaboration or transaction behavior.
- `C/syn/board/ia840f/setup/build_gate.tcl:1-6` still unconditionally sets
  `ia840f_ready_for_build false` and raises an error. Nothing was executed.
- Rehashed the finite 57-file review snapshot (board sources, relevant common
  RTL, Qsys definitions, manifest/gate and reviewed donor inputs): no changes.
  Independently checked all 40 existing vendor-path/hash rows resolving under
  the donor root in `docs/vendor-derived-bmc.md`: all matched original bytes.
- No source or manifest edits were selected, so original donor hashes and
  current candidate hashes are preserved without a manifest rewrite.

| Unchanged candidate path relative to C | SHA-256 |
|---|---|
| `syn/board/ia840f/source_manifest.json` | `502b9467bbe7bae0492f1f33058aa4ab6c1bc6ea9182ef4322fa15ea35fcafab` |
| `src/board/ia840f/bwbmc_st2mm.sv` | `472b7c2ad6828ff6bdfd48c7f722388bbdb1ca788a7dacc0dbf28fceddb72a07` |
| `src/board/ia840f/bwbmc_st2mm_rx_bridge.sv` | `a02198a8836c14d03b68f842bcd38e503093c59291938c8e7435f51fd2232679` |
| `src/board/ia840f/fim_afu_instances.sv` | `e890723f848a4567a8b9390a2f8e4cc27bbd70c92d248367406585d1e493bc76` |

This decision preserves source progress without representing an unestablished
FLR protocol as implemented or build-qualified.
