# BUFFER-LIFETIME01 — retained VFIO buffer ownership

## Decision and evidence scope

Use **two backend-owned 4096-byte buffers, flags = 0**, allocated and initialized before the first GO; initially transfer only 64 bytes, one descriptor at a time. Keep both allocations and their original owning process/handle alive until completion and quiescence are established. **After a possibly issued GO, an error/deadline with unknown quiescence must enter a non-returning ownership hold, not ordinary cleanup or process exit.** This is containment, not DMA cancellation or recovery.

Offline source inspection only: no remote connection, hardware access, build, installation, reset, driver change, or source edit. The supplied native identity/topology is context, not reverified here. This report does not adjudicate the identity-inspection result or attest target ELF loading.

Paths below are relative to `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `O=qualification/source-resume-01/remote/home/uwb_student00/opae-sdk/libraries`
- **P** = `O/plugins/vfio/opae_vfio.c`; measured SHA256 `8ff7fde00206024f70108d37fd3ebfae9daddea5f3b23175b12bd7c5a63d2b6a` — matches supplied pin.
- **V** = `O/libopaevfio/opaevfio.c`; measured SHA256 `9228499743db5e96fb9ceef4f38ca086840fee616af2d174b19098fc9a00baed` — matches supplied pin.
- **R** = `qualification/caps01-dma-host01/bound-rtl`.

## Allocation, IOVA, and pinning

The retained adapter binds PrepareBuffer, ReleaseBuffer and GetIOAddress to the `vfio_fpga*` implementations (`O/plugins/vfio/plugin.c:119–124`).

1. **PrepareBuffer rounds before allocation**, including PREALLOCATED calls: `len <= 4096` becomes 4096; `4096 < len <= 2 MiB` rounds to 2 MiB; larger lengths round to a multiple of 1 GiB (**P:1493–1539**). Use a non-null output-pointer argument, a valid WSID output, and positive bounded length; this implementation is not a substitute for frontend validation.
2. `opae_vfio_iova_reserve` additionally rounds that size to `sysconf(_SC_PAGE_SIZE)`, then passes the resulting size **by value** to `mem_alloc_get` (**V:604–615**). That resulting size is used for virtual allocation, DMA mapping and stored metadata (**V:696–741**, **V:618–632**). Thus a smaller 64-byte request does not create a 64-byte mapping. With a 4096-byte base page, each proposed allocation and DMA mapping is 4096 bytes; both total 8192 bytes. The rounding expressions were evaluated locally, not exercised against VFIO. Native base-page size was not queried by this review.
3. With flags zero, the lower layer uses anonymous private read/write `mmap`: ordinary pages for size <=4096, explicit 2 MiB hugetlb pages for sizes above 4096 through 2 MiB, and explicit 1 GiB hugetlb pages above that; **there is no fallback** if mmap fails (**V:662–715**). Therefore the proposed 4096-byte buffers need neither preallocation nor a configured hugetlb pool on the intended 4 KiB-page target. This is not the larger OFS tutorial's huge-page allocation regime.
4. PREALLOCATED only substitutes the caller's non-null pointer for mmap. It does **not** bypass length rounding, provide backing storage, or validate pointer alignment/backing extent (**P:1507–1539; V:718–734**). Such a caller must supply suitably page-aligned, writable mapped storage covering the entire rounded extent and preserve it until unregistration is safe. It need not itself be hugetlb storage: that branch skips the hugetlb mmap. Avoid this unnecessary ownership complication for the tiny test.
5. Both directions get `VFIO_DMA_MAP_FLAG_READ | VFIO_DMA_MAP_FLAG_WRITE` through `VFIO_IOMMU_MAP_DMA`, using the reserved IOVA and full rounded size (**V:726–739**). This is the kernel DMA mapping/pinning boundary; there is no separate user-space `mlock` or completion fence here. The selected container is TYPE1 IOMMU (**V:1224–1247**). Exact running-kernel pin/unpin implementation, limits, and reset-on-release behavior are outside this retained userspace source review.
6. PrepareBuffer stores buffer metadata in the container map and returns its pointer as WSID (**V:741–811; P:1543–1555**). GetIOAddress merely dereferences that metadata and returns `buffer_iova`; it neither pins anew nor checks completion, and ignores its handle argument (**P:1588–1602**). Keep WSIDs paired with the owning handle; never reuse them after release. Program the **returned IOVA**, not the CPU pointer, and validate its alignment and full 64-byte end address against the bound host-address width before GO. Touch/init the complete buffers before GO; do not modify or recycle an in-flight buffer.

## Release and close are destructive, not drain operations

`fpgaReleaseBuffer` calls `opae_vfio_buffer_free`, which removes the virtual-address entry from the container hash map (**P:1567–1585; V:852–875**). The map is configured with `opae_vfio_value_cleanup`, which invokes `opae_vfio_destroy_buffer` (**V:1151–1190**). The destructor's order is explicit (**V:635–659**):

1. Request `VFIO_IOMMU_UNMAP_DMA` over the **whole recorded mapping** (kernel unmap/unpin boundary).
2. `munmap` backend-owned memory; skip this step only for PREALLOCATED memory.
3. Return the IOVA to the allocator and free the metadata.

There is **no AFU status check, cancellation, outstanding-transaction wait or fence**. Worse, an unmap failure only reaches `ERR` and does not prevent munmap/IOVA reuse/metadata destruction; returned unmap size is not checked. `ERR` is compiled out without LIBOPAE_DEBUG (**V:59–65**). A successful ReleaseBuffer return is therefore not proof of successful unpin, much less quiescence. Allocation failure handling is also not uniformly leak-proof: hash-map insertion failure returns without destroying the already mapped node (**V:803–811**). Before GO this is a resource-error issue, not evidence of active DMA; do not fabricate a WSID or retry release through stale metadata.

Skipping explicit release and calling `fpgaClose` is **not** a hold:

- Close frees token/optional SVA state, then closes the VFIO pair (**P:777–811**).
- Pair close destroys the selected device context, then an optional VFIO physical-function context (**P:474–489**). The latter is conditional on the actual VF's `physfn` using vfio-pci (**P:521–559**); it is not a reason to open excluded management PF1. Supplied PF0 dfl-pci topology selects the direct VF branch.
- `opae_vfio_close` calls the destructor (**V:1386–1399**), which explicitly destroys **all remaining DMA buffers before closing any FDs**, then destroys BAR mappings/device FD, unsets the group container/closes group FD, destroys IOVA bookkeeping, and finally closes the container FD (**V:483–514; 150–160; 250–261; 410–419**).
- `fpgaUnmapMMIO` itself merely validates/unlocks in this backend; it is neither BAR teardown nor quiescence (**P:1216–1231**).

Thus an eventual device-FD release/reset cannot be assumed to protect the buffers that userspace already unmapped. Process exit is no escape hatch: Linux `_exit(2)` explicitly closes all process FDs even though it skips atexit handlers (locally inspected `/usr/share/man/man2/_exit.2.gz`, DESCRIPTION/NOTES). Leaking C objects and returning, `_Exit`, aborting, or being killed does not preserve the owning address space and VFIO context. This report does not claim what exact device activity the unreviewed native kernel's release path performs.

## Phase-dependent cleanup policy

| State | Policy |
|---|---|
| Failure **before any GO**, with no pre-existing/other-owner active DMA | Do not submit. Release each successfully acquired WSID once, then close/finalize normally; report cleanup errors separately. A second-allocation or GetIOAddress failure does not require indefinite hold of an otherwise idle first allocation. |
| Previous serial descriptor proven complete/quiescent; failure before the next GO | Same ordinary cleanup policy. Being before the *second* GO alone is insufficient if the first remains uncertain. |
| All issued descriptors proven complete/quiescent, including normal host-memory visibility requirements | Release buffers then close. A numerical mismatch discovered only after established quiescence is a failed test, not automatically an in-flight DMA case. |
| GO attempted; completion uncertain, response error, polling/API error, or deadline | Stop submission/polling and enter **HOLD_UNKNOWN_DMA** with both buffers, WSIDs, mappings and all owning FDs retained. No retry, reset, stop-bit write, cleanup, or exit. |

Mark possible DMA ownership **before attempting the GO store**, not only after its API success: the VFIO MMIO write is a volatile store, not a device admission/completion acknowledgement (**P:1008–1037**). A software deadline ends the finite access attempt; it does not establish cancellation.

The bound RTL supports this distinction: read-response errors latch while transaction traffic continues, and prevent descriptor retirement (**R/dma_read_engine.sv:71–85, 128–144, 204–230**). Write-response errors latch during operation; success requires response credits drained and no error, while ERROR retains the descriptor (**R/dma_write_engine.sv:92–118, 163–170, 294–319**). Neither error status nor FIFO emptiness alone proves system-wide quiescence. Normal local retirement/busy/error checks must follow the separately bound host completion contract; this report does not promote local AXI response retirement to a new PCIe/host-memory fence. Legacy control is expressly not a qualified drain/reset ABI (**R/csr_mgr.sv:191–197**).

## Smallest fail-stopped ownership hold

Keep the **original process**, not just a saved IOVA or duplicated FD, alive indefinitely with its address space, loaded entry module, handle and backend contexts intact. No new keeper daemon, fork handoff, direct pin API, driver modification or reset workaround is needed.

A minimal Linux realization is a **non-returning self-SIGSTOP hold**, with unexpected SIGCONT returning only to the hold, never to cleanup or more device access. Establish handling/blocking of ordinary asynchronous termination signals (including HUP/INT/TERM/QUIT and any timeout signal) **before GO**, and retain that protection in hold. Linux `signal(7)` identifies SIGSTOP as process stop, SIGCONT as continuation, and SIGKILL/SIGSTOP as uncatchable/unblockable (locally inspected `/usr/share/man/man7/signal.7.gz`). An equivalent non-returning, non-busy waiting loop with protected signals can preserve the same ownership; neither is an OPAE recovery API.

Emit one failure/hold record using already captured status and ordinary output, identifying PID, phase and retained ownership; do not perform extra MMIO to improve diagnostics. Ensure the launcher never unwinds into finalize/dlclose and the supervisor treats the hold record as a failed attempt **with a retained owner**, not a process to kill. No `timeout`/TERM→KILL escalation, cleanup trap, terminal-close kill, automatic restart or successor run may reclaim that owner. The finite bound applies to device accesses, **not** to held-process lifetime. SIGKILL, OOM, fatal process failure and host loss remain outside this guarantee.

Only an independently established end to possible DMA permits reclamation; this report supplies no automatic recovery sequence. Joe's confirmed physical access is accepted—no further generic permission is requested. A stopped owner preserves resources; it does not stop FPGA DMA, guarantee host availability, or make unknown DMA safe to continue.

### Additional source identities

SHA256 of cited bound RTL at inspection:

- `dma_read_engine.sv`: `3fc1937ad8268d0cfaf3453a85f8573a10aa1b98ae695deff62a89d772145a88`
- `dma_write_engine.sv`: `fb2d589ddd54a26ef9237eb7b38a490d0b5096b7b648b82dcba97462db7fe14b`
- `csr_mgr.sv`: `053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93`

The retained O snapshot lacks the core buffer wrapper and libopaemem implementation; routing, cleanup callback registration, size propagation and destructive syscall ordering above are directly visible in the cited VFIO sources. No claim of an independent audit of the missing allocator/hash-map implementation or native kernel is made.
