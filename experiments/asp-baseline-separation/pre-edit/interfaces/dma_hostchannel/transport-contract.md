# DMA host-channel candidate ABI v1

Source implementation contract for the new IA840F ASP. Not a vendor ABI, generated-design result or hardware qualification. Both software and RTL must agree before gates may open. Existing DDR DMA remains independent.

## Initial source contract

- AFU MMIO byte base `0x30000`, span `0x1000`, subject to full integration address-decode review. Existing DMA CSR base is `0x20000`; existing kernel control base is `0x4000`.
- Two channel slots, stride `0x100`: slot 0 `host_to_kernel`, H2D (MMD direction 1); slot 1 `kernel_to_host`, D2H (direction 0).
- Baseline kernel stream width 512 bits, element size 64 bytes. Byte-based queue capacities and counters; capacities power-of-two, multiples of 64. Reject unsupported channel names, directions, lengths and partial elements rather than silently truncating.
- Each channel owns a DMA-mapped host ring. Program a device-visible mapped address, never an unregistered process pointer. Mapping must guarantee the DMA address range used by the hardware; handle allocation failure explicitly.
- Monotonic unsigned 64-bit producer/consumer byte counts; modulo ring capacity only for memory indexing. Bound producer-consumer difference to capacity and reject malformed updates. Prevent transfer across a ring end without splitting it.

## Per-channel 64-bit CSR byte offsets

| Offset | Register | Semantics |
|---|---|---|
| 0x00 | IDENT | Read-only ABI identity `0x4941383448430001` |
| 0x08 | CONTROL | Bit0 RUN; bit1 QUIESCE; bit2 RESET_POSITIONS (only while QUIESCED, clears both positions and sticky errors). Commands are mutually exclusive. Quiesce stops new DMA, drains accepted traffic; it is not reset cancellation. |
| 0x10 | STATUS | Bit0 RUNNING; bit1 QUIESCED; bit2 ERROR. QUIESCED only when no transaction can touch the ring. |
| 0x18 | RING_IOVA | DMA address of ring; writable only quiesced |
| 0x20 | RING_BYTES | Power-of-two byte capacity; writable only quiesced |
| 0x28 | HOST_POSITION | H2D published producer or D2H released consumer; host-owned |
| 0x30 | DEVICE_POSITION | H2D consumed/copied consumer or D2H published producer; hardware-owned |
| 0x38 | ERROR | Sticky cause bits; clearing/reinitialization only quiesced |
| 0x40 | ELEMENT_BYTES | Read-only 64 |

Restart/reinitialization uses CONTROL bit2 RESET_POSITIONS while quiesced; MMD reads both positions as zero before programming/RUN. Zero RING_BYTES is permitted while quiesced to disarm a ring before unmapping; RUN requires a valid nonzero capacity. Position publication must follow data visibility. H2D data can be reclaimed only when DMA has completed copying it into owned FPGA buffering. D2H data may be published only after a proved ordered host-visible completion, not simply Avalon write acceptance. Use the established PIM write-fence/completion contract and document it precisely.

MMD `get_buffer` offers only contiguous available/free bytes until ring end. `ack_buffer` advances only the acknowledged available span and validates element alignment. Thread synchronization must protect channel state. Destruction must wait boundedly for quiescence; on failure preserve/quarantine DMA mappings rather than freeing live memory. Closing/reprogramming the device must coordinate channels before legacy teardown.

## Outstanding integration obligations

- Reconcile this candidate register map with selected RTL and MMD source; source definition alone is not compatibility proof.
- Connect arbitration to existing PIM host-memory services without breaking DDR DMA bursts, read responses, IRQs or fences.
- Resolve compiler-facing hostpipe channel XML/port naming from authoritative artifacts; no invented generated interfaces.
- Verify source wiring and future generated design under separate build authorization. Current scope forbids configuration, compilation, IP generation, simulation and hardware execution.
