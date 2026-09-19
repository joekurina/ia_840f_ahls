# DMA hostchannels MMD — source implementation, not qualification

> **Historical experiment — outside the standard/USM BSP baseline.** This document preserves an earlier custom host-pipe investigation. Its transport choices, widths, CSR addresses and integration instructions are not requirements or approvals for the vendor-based modernization. Host pipes may enter the BSP only through an established reference-platform implementation; see [current preparation scope](preparation-plan.md). Do not execute the instructions below under the source-only authorization. Statements about candidate source locations describe the earlier experiment, not necessarily the active baseline after preservation/disconnection.


## Hardware contract

Authoritative shared candidate ABI: `interfaces/dma_hostchannel/transport-contract.md`;
C constants: `interfaces/dma_hostchannel/dma_hostchannel_abi.h`.
This supersedes the software worker's initial DFH proposal: **no new GUID/DFH**.
The agreed MMIO base is `0x30000`, two slots at stride `0x100`, identity
`0x4941383448430001`, names `host_to_kernel` (H2D=1) and `kernel_to_host`
(D2H=0). Both use 512-bit / 64-byte elements. These are candidate transport names,
not evidence for the unresolved compiler-facing XML hostpipe literal.

CONTROL bit2 (`4`) is RESET_POSITIONS, accepted only QUIESCED. It resets both
positions and sticky errors; software waits for QUIESCED without RUNNING/ERROR
and reads both positions as zero. RUN=`1`, QUIESCE=`2`; never combine them.
After quiescence software clears RING_BYTES and RING_IOVA before unregistering.
Hardware must permit zero RING_BYTES while quiesced (it is disarmed, not a runnable
ring), and must not resume without a new explicit RUN command.

H2D DEVICE_POSITION can advance when completed reads have been copied into owned
FPGA storage. D2H DEVICE_POSITION must advance only after ordered host-visible DMA
completion, **not** write acceptance. Quiescence must cover every transaction
that can still touch the ring. Hardware must implement the shared contract and
host-memory arbitration/fences independently of the existing DDR DMA path.

## Software changes

- `common/source/host/mmd_hostchannel.{h,cpp}` implements two independent rings.
- `mmd.cpp` exports create/destroy/get_buffer/ack_buffer with C ABI inherited from
  `aocl_mmd.h`, negative errors, positive monotonically allocated channel handles,
  null/status validation and exception containment at the new export boundaries.
- `mmd_device.{h,cpp}` owns the transport and coordinates teardown/reprogramming.
- `host/CMakeLists.txt` lists the new implementation and shared C-header include
  directory. This is source wiring only, not a configured or linked library.
- Existing `mmd_dma.{h,cpp}`, DDR read/write/copy operations and board/FIM files
  are not modified by this worker. Optional transport is probed only on create.

`create` validates name, direction and power-of-two capacity in bytes (64 bytes
through 64 MiB). It reads identity, element size and initial quiescence before any
register writes. Missing/mismatched hardware fails without fallback. Allocation
uses `fpgaPrepareBuffer(..., flags=0)` followed by checked `fpgaGetIOAddress`;
only the returned IOVA is written to hardware. OPAE owns the registered allocation;
`fpgaReleaseBuffer` is used after quiescence. It does not use `pin_alloc`/MPF
virtual addresses or claim registration succeeded when an OPAE call fails.
Small rings have a minimum 4096-byte allocation but retain their requested logical
capacity. No physical-contiguity inference is made from the virtual address:
this implementation requires the OPAE backend's contiguous device-visible IOVA
mapping for the entire successful allocation.

`get_buffer` offers contiguous free H2D space or completed D2H data up to ring end;
zero available is success with zero bytes. It validates peer alignment, bounded
producer-consumer distance and bounded peer progress. Positions use unsigned
64-bit wraparound; only memory indexing is reduced modulo capacity. `ack_buffer`
publishes at most the remaining offered bytes, rejects partial 64-byte elements,
and advances the host position only after successful MMIO. Failed publication
is ambiguous, poisons the channel and must not be retried as if nothing happened.
Partial ACKs preserve the remaining offer. Repeated get calls refresh the offer.

A queue-state mutex serializes its operations; a lifecycle mutex serializes new
exports against open/close/program/reprogram. Returned raw pointers cannot carry
a lock across application code: the runtime must give each ring a single host
owner and must not destroy/reprogram concurrently with use of an offered pointer.
Legacy DDR API threading remains its pre-existing runtime contract.

CPU fences order host accesses around MMIO, but are **not** a substitute for DMA
coherence or the hardware's ordered completion. This source supports coherent
x86-64 OPAE/VFIO host DMA only; noncoherent DMA is unsupported. Backend mapping,
coherence and PIM routing remain platform-qualification obligations.

## Lifetime and failure policy

Destroy sends QUIESCE and polls with a one-second monotonic deadline. QUIESCED
must be observed without RUNNING before ring addresses are cleared and the buffer
released. ERROR is not sufficient evidence of quiescence. The deadline bounds
polling, not a potentially blocking vendor MMIO call.

On failed quiescence/MMIO clear/release, the mapping remains registered, the queue
is poisoned, and destroy/close/program returns failure. Retrying destroy/close can
finish recovery. A failed create also retains a private quarantined registration
when cleanup cannot be proved; close performs recovery even without a public
channel handle. The queue destructor never releases buffers implicitly. The Device destructor
also refuses legacy teardown if any hostchannel registration remains; only
explicit close/reprogram/destroy can release registrations.
Device close must stop channels before legacy teardown. Reprogram must stop them
before unpinning legacy memory or reconfiguration. Process/library teardown stops
attempting deletion after failed close and intentionally leaks the remaining
Device objects/OPAE handles rather than freeing active DMA memory. External
process/driver teardown and fault recovery are not hardware-qualified here.

## Source evidence and limitations

Inspected the cached Intel runtime commit
`32a36fe51d3bab2c7caff98e744e7ee3dd55da7d` under `reference/hostpipe-abi`:
`src/acl_hal_mmd.cpp:2318–2328` converts packet count × packet size to byte
queue_depth; push/pull obtain an offer, copy bytes and ACK; the repository MMD
header requires positive handles and byte-based offers/capacity. The source ABI
has all four hostchannel declarations, but previously no implementations in this
MMD. Existing MMIO uses OPAE region 0; Device initialization resets the port and
creates separate DDR DMA engines. The new rings do not replace those engines.

Unsupported: arbitrary element widths, partial elements, sideband ports,
scatter-gather descriptor lists, non-power-of-two queues, more than the two named
channels, noncoherent platforms, and generic board XML generation. The shared
header lives outside the vendor subtree; packaging the ASP alone must also carry
that header or explicitly relocate it and update the include path.

No configure, compilation, compiler invocation, tests, simulation, hardware,
remote access or commits were performed. Evidence is source reads and diff review
only. Build/export compatibility, transport RTL integration, real IOVA DMA,
ordered D2H completion, concurrent DDR traffic and teardown fault behavior remain
unverified. Acceptance gates must stay closed until separately authorized work
provides that evidence.
