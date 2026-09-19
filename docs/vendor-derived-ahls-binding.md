# Vendor-derived AHLS board binding sources

## What is implemented

`afu/ahls/rtl/ahls_board_binding.sv` is a **connected reusable board-side RTL module**, not another descriptive contract and not a generated AHLS component. It instantiates the extracted IA840F/OFS board services, a DFH/UUID and CSR-aperture router, a tag-retaining MMIO bridge, and host/local-memory byte-to-line adapters. It has no compute workload, application stream, queue descriptor format, or oneAPI runtime dependency.

This is source integration, **not a functional AHLS AFU image**. There is deliberately no replacement `ofs_plat_afu`, no `kernel_system`, no guessed generated module/port names, no AFU UUID or application CSR base chosen on the user's behalf, and no project/top-level activation. The caller must supply the mandatory UUID/aperture parameters and bind the actual generated IP. Quartus 26.1.1 is the intended target, not a qualified toolchain result.

This implementation supersedes the earlier “no RTL wrapper or source-list entry is supplied” status in `docs/ahls-integration.md`; that document's generated-IP, address-domain and software obligations still apply. The existing contract now points to these sources while keeping generated binding and all execution gates false.

## Exact source inventory

All paths below are relative to `afu/ahls/`.

| File | Implementation |
|---|---|
| `rtl/ahls_board_binding.sv` | Connected composition, raw MMIO and per-bank interfaces, CSR flat-port boundary, exported common clock/reset and alignment faults. |
| `rtl/ahls_ofs_board_services.sv` | Primary PCIe host port 0 mapped through PIM, actual conventional-to-split Avalon converter, per-bank PIM mappings, explicit CDC and unused-resource masks. |
| `rtl/ahls_mmio_aperture.sv` | Read-only five-word AFU DFH/UUID region; parameterized nonoverlapping CSR range; image-aperture rebasing; serialized response routing. |
| `rtl/ahls_mmio_to_avmm.sv` | Word-to-byte address expansion, unchanged data/byteenable, tagless-agent bridging with one outstanding read and returned PIM user metadata. |
| `rtl/ahls_avmm_byte_to_line.sv` | Parameter-derived byte-address division by bytes/beat; preserves burst count, byte enables, user metadata and both response channels. Misaligned requests stall and raise a fault, rather than silently truncating. |
| `ahls_binding_sources.tcl` | Explicit registration of only those five RTL files. Does not select a top, import generated AHLS IP, invoke a tool or source the oneAPI ASP. |
| `provenance.json` | Source roots, exact files/line ranges, current byte sizes/SHA-256 and adaptation notes. These selected pins are not full dependency/toolchain closure. |
| `LICENSE` | MIT grant and retained source attribution. |
| `integration-contract.json` | Existing descriptive contract extended with the source implementation and still-unbound generated instance. |
| `static-source-review.json` | Static inventory/hash/registration checks only; no HDL execution or qualification. |

## Actual internal wiring

```text
plat_ifc.host_chan.ports[0]
  -> ofs_plat_host_chan_as_avalon_mem_rdwr_with_mmio
       -> mmio (PIM word-addressed, 64-bit)
          -> ahls_mmio_aperture [DFH/UUID + explicit CSR range]
             -> csr_mmio (range-rebased PIM words)
                -> ahls_mmio_to_avmm
                   -> csr_* (tagless 64-bit aligned-byte-addressed agent)
       <- host_split (PIM split rd/wr, physical line-addressed)
          <- ofs_plat_avalon_mem_if_to_rdwr_if
             <- host_lines (shared Avalon commands)
                <- ahls_avmm_byte_to_line <- host_bytes

plat_ifc.local_mem.banks[b]
  <- ofs_plat_local_mem_as_avalon_mem [CDC enabled]
     <- local_lines[b]
        <- ahls_avmm_byte_to_line <- local_bytes[b]
```

The `csr_*`, `host_bytes` and `local_bytes` names are **new generic binding boundaries**, not assertions about AHLS-generated names. Data and responses flow in the opposite direction on the same interfaces. There is no fake memory, constant-success generated component or bypass datapath.

### Clock, reset and resource ownership

The primary PCIe mapper crosses into `plat_ifc.clocks.uClk_usrDiv2`; each local bank also crosses into that domain. `binding_clk` and `binding_reset_n` are exported from the mapped MMIO interface. The memory adapters drive their byte-side interface clock/reset from the mapped line-side interface. Do not drive those clock/reset fields a second time, or connect a component running in another domain without an actual CDC bridge.

The vendor BSP used configurable PIM CDC plus a generated Qsys board containing further crossings. That generated board is not imported. This implementation therefore explicitly enables PIM CDC for both PCIe and memory, using vendor timing-stage settings (one for host, three for local) and the OFS local-memory example's common-AFU-domain pattern. These are source selections, not measured timing claims.

Bank count selects the first N banks, with N required to be at least one and no greater than the platform bank count. Each selected bank must be serviced by the eventual binding, or deliberately tied idle if the bound image does not use it. Port 0 and those banks are marked in use; PIM ties off all other platform resources. There is no multi-link child-port assumption, HSSI stream or BMC ownership in this module. Do not instantiate a competing platform tie-off alongside this composition.

### MMIO semantics and limitations

- Supply `AFU_UUID`, `CSR_BASE_BYTES` and `CSR_SIZE_BYTES` explicitly. The source checks nonzero identity, eight-byte granularity, nonempty nonwrapping range, aperture bounds and exclusion of the first 40 bytes. No host register offsets or generated kernel bases are invented.
- DFH/UUID matches the OFS five-word pattern at byte offsets 0 through 32: AFU type, end-of-list, UUID low/high and reserved words. This is a single AFU feature; it does not advertise an invented AHLS capability chain.
- Subtract the CSR aperture base **once**, in the router. Downstream addresses are image-relative. Generated header macros may already contain kernel bases; the future host layer must not add them twice.
- Raw PIM MMIO is word-addressed. The bridge appends the beat byte-index zeros and preserves byte enables and data lane positions. It does not shift a high-half 32-bit write into the low half, split 64-bit reads, merge responses, or perform read-modify-write.
- The vendor ASP special-cased `byteenable == 8'hF0` into address bit 2 when entering its particular generated Qsys fabric. That fabric is not present here. This boundary explicitly uses **beat-aligned byte addresses plus byte enables**, not the old Qsys encoding. A generated 32-bit CSR, word-addressed agent or lane-sensitive interface requires a real width/unit adapter based on its metadata. Do not connect it directly merely because its signals are Avalon.
- The tagless bridge retains `user` for one accepted read until its response, including support for a same-cycle response. Read and write requests are stalled during an outstanding read. Neither adapter retries a destructive read. Waitrequest allowance must be zero.
- Both MMIO stages accept only single-beat requests and mutually exclusive read/write. Unsupported requests stall; the tagless stage exposes `csr_unsupported_request`. Unsupported raw requests stopped by the router do not reach that signal. This flag is not an OPAE error-reporting ABI.
- Unmapped reads receive zero payload plus Avalon decode-error response; whether a particular PIM exposes that response to software requires mapper qualification. Writes to read-only DFH/reserved/unmapped space are ignored. Writes are posted and no write-response service is advertised.
- `csr_response` is an explicit generic input. A future binding may tie it to success only after confirming the generated agent has no error response and specifying that limitation. No AHLS IRQ, invocation controller, globals aperture or width adapter is fabricated here.

### Memory semantics and limitations

Host geometry comes from `HOST_CHAN_AVALON_MEM_RDWR_PARAMS`, not an application width. Local geometry comes from `LOCAL_MEM_AVALON_MEM_PARAMS`. The connected wrapper carries burst/user widths from its normalized input interfaces and rejects mismatched data/address/response geometry rather than narrowing silently. All local interfaces in the array have common geometry. The exact source byte-address width is line-address width plus `clog2(bytes/beat)`; no upper address bits may be discarded.

Addresses must be aligned to the entire bus beat on **every cycle with read or write asserted**, including noninitial write-burst beats and cycles stalled by waitrequest. `ahls_avmm_byte_to_line.sv:22–31` checks alignment continuously; it has no burst-start tracker. A producer that leaves address unspecified after the initial write beat is not directly compatible with this normalized boundary and needs an evidence-based adapter. This is a restriction of this library, not a general Avalon requirement. Partial accesses use byte enables on that aligned beat. A component that emits sub-beat addresses or a different data width needs a proven packing/width adapter before this boundary. Burst counts are positive Avalon beat counts and must obey the selected PIM's burst rules; no change to burst semantics, lane order or outstanding-read capacity is made. Memory response channels have no ready signal: the eventual generated binding must accept every response, including bursts. The source passes both read and write response information without converting burst acknowledgements into invented per-word acknowledgements.

`host_bytes` names **physical IOVA bytes** from OPAE registration. The old USM path contributes only the proven shared-to-split conversion pattern; its VTP service, virtual-pointer runtime, DMA engine and `kernel_system` are excluded. Do not pass a process virtual address. Preserve PIM user flags when deliberately issuing fences/interrupts; ordinary generated memory requests need an explicit known user value, typically zero, in the generated binding. No fence generator or host-visible completion protocol is supplied.

`local_bytes[b]` names offsets within one explicit board bank. This library does not implement host-to-DDR initialization/copyout, bank interleaving, arbitration between several generated hosts or automatic `buffer_location` routing. OPAE host-buffer registration does not put data in board DDR.

Reset clears the MMIO tracking state; it is not proof outstanding host writes have retired. Kernel done, posted-write acceptance, FIM local commits and host-visible ordered completion remain distinct. The FIM source explicitly describes RX-B commits as an ordering point within the FIM, not application completion. No buffers may be released on the strength of this module's reset or kernel done alone.

## Provenance and deliberate changes

Evidence IDs below resolve to exact source paths/lines and current hashes in `provenance.json`.

- **V_BOARD:** BittWare `oneapi-asp/ia840f/hardware/ofs_ia840f/build/rtl/ofs_plat_afu.sv`, primary host mapping, bank loop and tie-off. Extracted out of the legacy `afu`/BSP/Qsys wrapper instead of relabeling it AHLS-generated.
- **V_USM / N_AFU / P_SPLIT:** vendor and modern shared-Avalon to split-host-memory pattern. The actual PIM converter is instantiated unchanged by reference. VTP, MPF tags, ASP DMA and USM runtime are not copied.
- **N_BOARD / P_HOST / P_LOCAL / O_LOCAL_CDC:** modern mapper API, native AXI local memory, explicit reset and common-domain CDC. These remain actual PIM dependencies, not handwritten substitutes for PCIe/EMIF protocol machinery.
- **N_LOGIC / P_UNITS / P_LOCAL_PARAMS:** vendor address conversion with modern PIM units/geometry. The new adapter parameterizes the vendor's hardcoded shift and rejects misalignment/width loss. It intentionally does not import the old Qsys MMIO bit-2 quirk.
- **O_DFH:** standard OFS DFH/UUID and MMIO user echo. The bounded range decoder and serialized tracking are new glue, not claimed to be copied vendor implementations or proven in hardware.
- **V_FIM:** board-side native PCIe TLP/commit and AXI EMIF boundary; no direct coupling of AHLS payload streams to PCIe AXI TLP signals.
- **H_HANDOFF / H_MEMORY / S_MEMORY:** actual AHLS artifacts and configurable external-memory properties. The sample uses two locations and a sample-specific 256-bit width; neither is made a board default here.

No source under the vendor trees, modern ASP, PIM, HLS samples, archived hostchannels or sibling board/BMC presets was modified.

## Source inclusion and remaining binding

`ahls_binding_sources.tcl` is the future caller's source-registration entry. It only registers the library RTL and was **not executed**. The platform must already supply an IA840F-generated PIM with its full source/IP/SDC closure and `ofs_plat_if.vh`; raw `*_GROUP_*` source templates are not compilable substitutes for the generated group names. The library does not import the ASP source list or its competing `ofs_plat_afu`.

A later real `ofs_plat_afu` may instantiate `ahls_board_binding`, with actual UUID/aperture parameters and normalized memory interfaces, then connect the genuine generated component via an inspected adapter. That adapter still requires:

1. Complete generated `.prj` sources, `top_*_di.ip`, `*_di_hw.tcl`, `*_di_inst.sv`, actual register headers and any struct definitions. No matching instantiation/header files were found by the bounded `hls-samples` searches; nothing was generated.
2. Exact ports, widths, optional controls, reset/readiness, clock requirements, CSR address units and register side effects; implement a width/unit adapter where this board-side normalized boundary differs.
3. Every buffer-location mapping and all response/ack semantics; explicitly map or omit host/local services according to the real image. The supplied integrated composition supports memory-bearing IA840F images with at least one local bank; it is not a universal zero-port wrapper.
4. Independent device-global apertures, invocation/conduit controls, external streams and IRQs if the generated component has them. No fixed stream transport is selected here.
5. OPAE host identity/register handling, address allocation, ordered visibility and bounded quiescence/recovery. These sources do not constitute that host library.
6. Separately authorized PIM generation/import, elaboration, simulation, timing and hardware validation, including native host write-retirement/fence behavior and toolchain compatibility.

## Verification boundary

Only local source inspection, file writes and static source/JSON/hash checks were performed. No HDL compiler/linter, simulation or authored execution test ran. `static-source-review.json` records selected source hash matching, the five-source registration inventory and instance/dependency checks; these are text-level checks, not elaboration or functional verification. No build, configure, setup, IP generation, vendor tool, workstation access, install, programming, commit or push was performed.
