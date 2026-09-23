# DMA read-request handshake correction

Status: **NATIVE UNIT PASS; INDEPENDENT RESULT REVIEW PENDING**. This does not qualify the full DMA or authorize hardware use.

## Source-supported correction

The pinned AI Suite read engine sampled ARREADY before presenting ARVALID, then advanced unconditionally from SEND_RD_REQ. The additive [patch](../../afu/ahls_memory/dma/patches/read_request_handshake.patch) changes only two state decisions: issue when a pending-read credit exists without requiring ready, then stay in SEND_RD_REQ until the actual ARVALID/ARREADY handshake. Existing registered address/length fields and counter updates are retained. The original donor and accepted FIM/fabric/HLS inputs remain unchanged. See [source identity](source-binding01.json) and [prior independent DMA findings](../ahls-memory-fabric01/DMA-DONOR-REVIEW01.md), §§4.3,10.

## Actual native results

Installed Questa Intel FPGA Edition2024.3 in `/opt/altera/25.1/questa_fe`, explicit isolated environment, owned tmux,2CPU affinity and16GiB per-process address-space limit,120s per native command. This is ordinary RTL simulation, not live FPGA/device access. Each run uses a fresh exclusive work directory under `/home/uwb_student00/ahls/new_BSP/work_dma_read_handshake01/`.

| Attempt | Native version/vlib/vlog/vsim | Observed outcome |
|---|---|---|
| red01, preserved original | 0/0/0/0 | `READ_REQUEST_FAIL cycle=3 ARVALID dropped before handshake`,85ns. unit_pass=false; fatal/error-aware runner rejected. Pane had exited before capture, so outer rc was not separately observed. |
| green01, two-decision correction | 0/0/0/0 |12cases,3,931cycles,16,955checks,22requests,3,145beats,142stalled-request cycles,2,961credit-block cycles; unit_pass=true, captured outer rc0. |

[Original native result](result-red01.json), [candidate native result](result-green01.json), [parent comparison](parent-verification01.json). All10 named inputs are identical except dma_read_engine.sv. Both use identical bound native tools and testbench. Per-log size/hash and full text, exact argv/process IDs/start ticks, resource headroom, native exit status and empty owned-process groups are retained. Both preserve copied sources/tools and the six prebound Work21 source files. The hash-bound native0/fatal distinction is not rewritten into a fictitious native nonzero.

The unmodified PIM AXI interface and checker remain enabled. Diagnostics include default input-port kind (13314) and two unique-case warnings at time0 before synchronous reset; both runs retain them. The candidate's simulation summary is0errors/3warnings, not warning-clean. No warnings are suppressed or changed in vendor source.

## Test scope and deliberate limits

The complete original/candidate dma_read_engine.sv is compiled with the actual donor dma_pkg and dma_fifo_if plus actual local PIM interface, AXI type and logging packages. Only the platform-configuration packages and umbrella header are unit fixtures (2banks,34local address bits,512data bits,57source address bits); they are **not a deployed PIM configuration**. Source payloads are local/hash-referenced, not republished.

The external unit sink returns every beat of each accepted INCR request, with patterned data derived from its full address. The test checks every FIFO payload, burst-last and final-packet flag, exact request address/length, entire stalled AR payload stability, no duplicate requests, at most two outstanding requests and no early descriptor dequeue. Lengths and patterns are explicit in [testbench](../../afu/ahls_memory/dma/tests/read_request_tb.sv); they cover1,2,63,256,257,512,513,769beats, repeated descriptors across reset and six ready schedules. Reset between cases is a unit initialization, not a qualified in-flight reset protocol.

Writer completion is a **testbench input**, asserted only after all expected FIFO output has been checked. There is no writer, DMA top, CSR, host mapper, bank selector, physical DDR, AHLS kernel or OPAE in this test. The unit sink intentionally supports the donor's large INCR requests; this is not AXI4 4KiB-boundary or PIM burst-adapter qualification. HOST_TO_DDR/WRAP semantics, source-width truncation in dma_top, invalid/overflow lengths, R errors, real B-response completion, reset/drain/visibility and all hardware gates remain open. No DDR vendor simulation: SKIPPED BY USER.

Do not rerun unchanged native success. Independent review governs bounded acceptance/publication, not a new execution-approval barrier. Next remaining DMA source work is truthful writer handshakes/burst scheduling/response retirement and exact PIM address/ID/user/fence binding.
