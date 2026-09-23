# Combined donor DMA engine — native results

**Native paired datapath unit passed; independent review pending. Not the DMA top/PIM/AFU or hardware qualification.**

The actual unmodified AI Suite `dma_engine.sv` wrapper connects the corrected reader and response-aware writer through actual PIM `ofs_plat_prim_fifo_bram`, its32-entry SCFIFO and registered output. This replaces the prior tests' synthetic internal FIFO and testbench writer-completion pulse. External source/destination endpoints and platform configuration remain fixtures. [Source inventory](source-binding01.json), [final reader delta](source-binding02.json), [testbench](../../afu/ahls_memory/dma/tests/dma_engine_tb.sv).

## Reproduced defect and bounded correction

Pair01 reached the first one-beat descriptor dequeue but failed at cycle171/1776ns: `descriptor counter missed successful dequeue`. The reader increment was only under **next WAIT**, while real retirement in current WAIT selects next IDLE. The [additive counter patch](../../afu/ahls_memory/dma/patches/read_descriptor_count.patch) moves that existing increment to the nonreset clocked default. It changes no request/data/response/reset control. It applies after the reader AR correction, not to the pristine donor. [Preserved failed result](PAIR01-FAILURE.md).

Pair02 differs only in this reader file. Counter is still four bits/modulo16; consecutive increments are checked, wrap exhaustion is not. The writer remains the response-candidate SHA256 `fb2d589ddd54a26ef9237eb7b38a490d0b5096b7b648b82dcba97462db7fe14b`; its independent B-response acceptance is separate.

## Native execution and model identity

Fresh `work_dma_engine_integration01/pair01` and `pair02`, owned tmux203/204, selected `/opt/altera/25.1/questa_fe` Questa Intel FPGA Edition2024.3. Native version/vlib/vdir/vlog/vsim all return0 on both attempts, outer1/0 respectively. Fatal-aware acceptance retains the failed baseline despite simulator rc0. Final simulation **0errors/9warnings**: five relaxed input-port-kind13314 and four time-zero unique-case8315 across reader/writer. No FIFO over/underflow fatal or later warning appears. This is simulation, not Quartus mapped synthesis or timing.

The installed same-release modelsim.ini is copied unchanged. Explicit `-L altera_mf_ver` supplies `scfifo`; native `vdir -lib altera_mf_ver` identifies `MODULE scfifo`. The13 bound source inputs contain no substitute scfifo definition. [Catalog](catalog01.json) and [library inventory](library02.json) bind all6files/2652245bytes in that installed precompiled library; before/after hashes are unchanged. `PLATFORM_INTENDED_DEVICE_FAMILY="Agilex 7"` is added to the integration-only include fixture. Neither vendor sources nor installed library were edited; no library payload is redistributed.

Existing finite supervisor:120s/native-command watchdog,2CPU affinity,16GiB per-process limit, free-memory/disk and no-competing-native preflight. No timeout or live owned group after completion. Tools, sources and original files unchanged. [Parent verification](parent-verification01.json) checks all13decoded payloads/run, complete log sizes/hashes, exact sole-input delta and case sums. Logs/native argv/process identities are embedded in result-pair01/02.json; outer receipts are separate.

## Actual paired result

Pair02: **10cases,15616monitored cycles,168352checks,33AR,33AW,6470accepted Rbeats,6470checked Wbeats,32B replies**. Eight descriptors retire successfully; one early write-error case drains its write replies but holds descriptor ownership, and one missing-response case remains waiting/busy through128observations. The last synthetic transaction remains outstanding at simulation end; that is not a drained/recovery success. [Exact case ledger](cases02.json).

Every accepted source/destination request checks full address, length,ID,size and expected donor burst encoding. Read input, FIFO enqueue, FIFO dequeue and output data are independently counted/checked, including both boundary flags. The actual FIFO's full/empty assertions remain active. Data is checked at every stage against descriptor-position-dependent values, not merely the DUT's current address. All5956beats in the eight successful cases are additionally read back and compared from the synthetic destination-memory array before completion is accepted. The other514beats are still checked during transport; their descriptors are not called successful.

Long initial writer stalls and recurring backpressure exercise real FIFO fill/drain:5406stalled-read cycles,8618stalled-write cycles; maximum accepted-read-minus-accepted-write occupancy34beats. These are observed queue/driver counters, not a bandwidth benchmark. Four successful successor descriptors run without reset; status counter and exactly-one dequeue are checked. Selected multiburst tails include2 and255beats, beyond the earlier unit's one-beat tails.

Five host-source cases exercise address bits34/56; five host-destination cases bits35/55. Full direct engine interface addresses and payloads preserve them. This does **not repair or test the known narrowing in dma_top**, which is not instantiated. Local-side addresses use the upper half of a16GiB offset range. Physical bank selection is absent.

## Protocol and system limits

The donor emits WRAP encoding on the host side (reader in HOST_TO_DDR, writer in DDR_TO_HOST). The external test endpoint is an explicitly **linear line-request model**, not a generic AXI4 WRAP implementation. The PIM source context maps host address/length to linear TLP requests without using burst type (`ofs_plat_host_chan_GROUP_map_as_axi_mem_if.sv:353–357,590–592`); the Avalon bridge likewise projects address/length (`ofs_plat_axi_mem_if_to_avalon_rdwr_if.sv:70–76,250–255`). Those files are source context, not instantiated proof of the complete PIM path. No AXI4 WRAP/4KiB legality or mapper splitting guarantee is claimed.

Wrapper MODE parameter remains HOST_TO_DDR; its direction-dependent localparameters do not resize these externally supplied57-bit interfaces. Dynamic descriptor modes exercise both engine branches, not the DMA top's selector, address slices or physical mode lifetime. Exact active host widths, two-bank routing, ID/user adaptation and upstream MMIO decode still need integration.

Read responses are all well-formed IDzero/OKAY. **Read-response error handling is still a source-level gap and not qualified by this pass.** No malformed tags, invalid/overflow lengths,9-bit maximum burst-count proof, descriptor-queue producer/CSR aggregation, global cancellation/reset/drain, PCIe fencing or physical visibility. The error case only injects a write SLVERR. Fixture resets do not authorize/qualify live recovery. PIM host responses can precede physical visibility; the counted B contract must be traced through the actual mapper/fence path before buffer reuse.

No FPGA/device access, flashing, driver change or reboot. DDR vendor simulation remains **SKIPPED BY USER**. No unchanged native run is pending. Original/failed inputs and all prior gate packages are preserved; publication waits for this distinct independent review and parent acceptance.
