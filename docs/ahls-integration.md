# Altera AHLS → OFS integration contract

## Status and scope

The target is **Altera HLS IP Gen (`ahls`) integrated as RTL IP into a general-purpose IA840F OFS AFU**. It is not an `icpx`/oneAPI ASP runtime port. The companion [machine-readable contract](../afu/ahls/integration-contract.json) records the documented handoff, bridge obligations, evidence and unresolved bindings. It is descriptive data, **not an executable build configuration**. Null fields and empty endpoint arrays mean unbound, not absent or supported.

No application workload, queue layout, packet format or kernel count is prescribed. A connected board-side RTL library and source-registration Tcl are now supplied; see [vendor-derived binding](vendor-derived-ahls-binding.md). Its normalized boundary requires 64-bit CSR, native-width aligned memory accesses and at least one local bank. Those are library restrictions, not AHLS compiler requirements. Actual generated component binding and OPAE host implementation are still absent; no fake generated header or build result is supplied. Source discovery in `hls-samples` found no `*_di_inst.sv` or `register_map_offsets.h`; the few `_hw.tcl` matches were a Standard wrapper and convolution streaming gaskets, not a generated instance for this board. This is bounded discovery, not a claim about every local directory.

Quartus **26.1.1** is the requested target; AHLS **2026.1** is a previous observation supplied in task context. Neither installation nor their compatibility was checked. FIM `599ac052eafbc9cede22561c099233ae4a54cb7d` and common `34a8540697fdf3d66fbcaa263fa037bae17cc32f` are context pins, not independently reverified here. Existing `oneapi-asp` remains reference-only and untouched.

## Citation convention

Citations below are local source-file lines, not claims of compiled or hardware behavior. Paths are relative to these roots:

- **H**: `/home/joe/Documents/Obsidian/School/Thesis/AHLS/Handbook`
- **S**: `/home/joe/Projects/Thesis/AHLS/hls-samples`
- **N**: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`

The JSON `evidence` dictionary expands every evidence ID into a root, exact path and inclusive line range. It preserves the source names, including historical `oneAPI` spellings. Such names and `sycl::ext::oneapi::experimental` namespaces do **not** select the oneAPI compiler/runtime: the local Platform Designer CMake source explicitly sets `CMAKE_CXX_COMPILER ahls` (S `Tutorials/Tools/platform_designer/add_oneapi/CMakeLists.txt:1–23`, **S_COMPILER**).

## Actual documented AHLS handoff

The handbook identifies these generated outputs; these are filename patterns, not files produced by this task:

| Artifact beneath `<project_name>.prj` | Integration purpose |
|---|---|
| `top_<project_name>_di.ip` | Quartus import, HDL dependency closure and core-specific settings |
| `<project_name>_di_hw.tcl` | Platform Designer interface description |
| `<project_name>_di_inst.sv` | Actual instantiation example and port binding starting point |
| `include/register_map_offsets.h` | Image-relative kernel base offsets and includes |
| `include/kernel_headers/<kernel_name>_register_map.h` | Per-kernel register addresses, sizes, masks and version |
| `<kernel_name>interface_structs.sv` | Packed struct layout when applicable, including padding |

Sources: H `09 - Integrate Your Design.md:31–45,78–93` (**H9_OUTPUT**, **H9_IMPORT**); H `10 - RTL IP Core Interfaces.md:244–250,431–438` (**H10_CSR**, **H10_STRUCT**).

Record the actual split mode: default/off combines kernels into one IP; `per_kernel` gives separate projects/reports/IP. Preserve all project dependencies rather than cherry-picking an apparent top-level SV file. The sample's report path uses `ahls` with `-fsycl-link=early` (S `Tutorials/Tools/platform_designer/add_oneapi/CMakeLists.txt:89–99`, **S_EARLY**). Report/IP source production is not an integrated OFS image or timing qualification. **No command from that sample was executed.**

The Platform Designer reference is useful for the IP import boundary, but uses a JTAG-to-Avalon master and Arria 10 board-specific pins. It is not an IA840F PCIe wrapper (S `Tutorials/Tools/platform_designer/README.md:46–79`, **S_PD**).

## Bridge boundaries

### OPAE MMIO → shared AHLS CSR

AHLS exposes one shared Avalon-MM agent for CSR functions; each register-mapped kernel occupies its own image-relative offset. Invocation and argument interface styles can be selected independently. Register-mapped invocation is the documented default, not a board requirement (H `10 - RTL IP Core Interfaces.md:59–98,107–124,172–248`, **H10_TYPES**, **H10_ARGS**, **H10_CSR**). The local functor sample mixes a register-mapped pointer with a conduit scalar (S `Tutorials/Features/hls_flow_interfaces/invocation_interfaces/src/reg_map_functor.cpp:20–47`, **S_ARGS**).

The OFS example implements DFH/UUID discovery at the beginning of MMIO space; AHLS Status must not simply replace that region. Allocate a separate AHLS aperture and document:

1. OPAE MMIO region and byte aperture base.
2. Image-relative kernel base and whether each generated macro already includes it.
3. PIM and generated agent address units, width adaptation and byte enables.
4. Read/write response timing, backpressure and transaction-user routing.
5. Register read side effects and restrictions on splitting/retrying accesses.

The PIM Avalon MMIO address is a bus-word index, with byteenable for smaller requests, whereas generated CSR macros describe byte addresses. Do not wire these address buses unchanged. Sources: N `examples-afu/tutorial/afu_types/01_pim_ifc/hello_world/hw/rtl/avalon/hello_world_avalon.sv:41–111` (**O_DFH**) and N `ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl/ifc_classes/host_chan/afu_ifcs/avalon/ofs_plat_host_chan_GROUP_as_avalon_mem_rdwr.vh:18–26` (**P_UNITS**).

CSR invocation requires readiness, correctly sampled arguments, Start publication and completion ownership. Writes to Start while busy are ignored; reading FinishCounter acknowledges and clears accumulated completions and done. A monitoring thread must not consume the launcher's completion counter. Bind the actual generated CSR version rather than copying an example version. H `10 - RTL IP Core Interfaces.md:132–248` (**H10_CSR**).

For conduit invocation, capture arguments on the documented start/ready handshake and honor completion backpressure where enabled. `remove_downstream_stall` removes `ready_in`; no universal port list is safe. Software control of conduit invocation needs a separately specified controller, not raw OPAE calls to nonexistent CSR registers. H `10 - RTL IP Core Interfaces.md:357–384` (**H10_CONDUIT**).

### AHLS memory hosts → OFS local memory or host DMA

Pointer arguments cause Avalon-MM host interfaces. Distinct `buffer_location` values partition external memory interfaces, not physical board banks automatically. Width, address width, direction, latency, maximum burst and alignment are configurable; the sample's chosen values are illustrative only. H `10 - RTL IP Core Interfaces.md:464–490,537–549` (**H10_MEMORY**, **H10_MEMORY_PROPERTIES**); S `Tutorials/Features/hls_flow_interfaces/mmhost/part3_ddr_hosts/src/mmhost.cpp:13–32` (**S_MEMORY**).

For each endpoint, bind a location to one explicit address domain:

- **Local memory:** bank selection, usable range, address units, arbitration and any host transfer path. The OFS local-memory example maps banks with `ofs_plat_local_mem_as_avalon_mem`, crosses each bank clock to the AFU clock, and marks used banks for tie-off. It explicitly does not use host DMA. N `examples-afu/tutorial/afu_types/01_pim_ifc/local_memory/hw/rtl/avalon/ofs_plat_afu.sv:45–115,139–155` (**O_LOCAL**).
- **Host memory:** OPAE registration plus returned IOVA, a proven physical-address transport and a complete generated-Avalon-to-PIM adaptation. PIM host memory uses split read/write channels and line addresses. Preserve byte enables, burst semantics, read response capacity and write ordering; sharing the name Avalon is insufficient. N `examples-afu/tutorial/afu_types/01_pim_ifc/hello_world/hw/rtl/avalon/hello_world_avalon.sv:13–20` (**O_DFH**), PIM `.vh:11–26` (**P_UNITS**), and native PCIe mapper `.sv:111–138` (**P_PORTS**).

The host example obtains an address with `fpgaPrepareBuffer`/`fpgaGetIOAddress`; its cache-line conversion is for that example's AFU ABI, not an AHLS pointer rule (N `examples-afu/tutorial/afu_types/01_pim_ifc/hello_world/sw/hello_world.c:67–112`, **O_HOST**). SYCL USM syntax in an AHLS source/testbench does not establish shared virtual-address translation in the OFS hardware. `fpgaPrepareBuffer` does not place data in board DDR. Mixed annotated/unannotated pointers can require compiler-specific location routing bits; use the generated mapping, never guess them (H `10 - RTL IP Core Interfaces.md:653–747`, **H10_POINTER_ROUTING**).

Kernel completion alone is not the specification of PCIe host-visible write ordering. The PIM defines fence/interrupt user flags, but an enum declaration is not proof of end-to-end completion. Bind the selected mapper's actual retirement/fence semantics before publishing DMA completion or releasing buffers. N `ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl/ifc_classes/host_chan/afu_ifcs/avalon/ofs_plat_host_chan_avalon_mem_pkg.sv:9–41` (**P_FLAGS**).

### External pipes ≠ automatic PCIe transport

An inter-kernel pipe is internal. A pipe with only one endpoint in the generated kernel system is external; default streaming, or CSR when configured Avalon-MM. External means another system component, not necessarily the CPU. H `11 - Pipes.md:45–102` (**H11_TYPES**).

**Streaming pipes:** Avalon-ST or AXI-stream payload ports need a real producer/consumer. Bind generated names, direction, packing, symbols, sidebands, ready latency, optional ready/valid, buffering and CDC. An always-ready or always-valid configuration imposes a real system obligation. The AXI sample uses `StreamingBeatAxi` and `tlast`, demonstrating that packing/framing varies; its image dimensions and byte width are not platform defaults. H `11 - Pipes.md:168–192,389–442` (**H11_PROPERTIES**, **H11_STREAM**); S `Tutorials/Features/hls_flow_interfaces/streaming_data_interfaces/axi_streaming/src/streaming_data_interfaces.cpp:31–82` (**S_AXI**).

A generated payload stream supplies neither a PCIe DMA engine nor an OPAE pipe API. OFS native PCIe AXI streams carry TLPs, not arbitrary AHLS payloads. A PCIe streaming bridge, if selected later, needs its own proven transport contract; none is advertised here.

**CSR pipes:** require register-mapped invocation and share the CSR agent. For an input with valid, wait for valid=0, write the complete payload, then valid=1. For an output with ready, wait for ready=0, read the complete payload, then ready=1. Bind initial/reset state before first access. Input pipes do not have a ready register; output pipes do not have a valid register. Without those optional flow controls, writes overwrite or reads sample the latest value; there is no lossless FIFO guarantee. `min_capacity` does not create a CSR queue. H `11 - Pipes.md:80–102,154,597–650` (**H11_TYPES**, **H11_CSR**).

### Device globals, reset and optional controls

A host-accessible device global has an independent MM agent; it is not implicitly inside the shared CSR aperture. H `10 - RTL IP Core Interfaces.md:458–462` (**H10_GLOBAL**).

Bind all generated clocks, reset polarity/synchronization and any freeze/irq/exception controls from real generated metadata. Wait for busy to clear or ready to assert following reset; deasserting external reset is not sufficient. H `10 - RTL IP Core Interfaces.md:839–853` (**H10_RESET**). PIM clock crossing is an explicit mapper choice, and unused platform resources must use correct tie-off masks (**P_PORTS**, **O_LOCAL**). An AHLS irq is not automatically routed into an OPAE event.

## OPAE host control requirements

The local OFS host source supplies concrete API evidence: filter by accelerator type/UUID, enumerate, open, allocate/register a buffer, retrieve its I/O address, write MMIO, release and close (N `examples-afu/tutorial/afu_types/01_pim_ifc/hello_world/sw/hello_world.c:21–126`, **O_HOST**). It is a minimal example, not a production AHLS host library: it uses an unbounded spin and leaves several return codes unchecked.

A later host implementation must:

- Resolve the correct accelerator when multiple UUID matches exist; validate identity, aperture and CSR version before writes.
- Check every OPAE result; preserve access widths, byte offsets and generated argument packing.
- Serialize each invocation/CSR-pipe transaction and assign a single owner to destructive completion reads.
- Select polling or explicitly routed interrupts; define deadlines and recovery rather than inheriting the example's infinite wait.
- Specify memory publication/visibility, keep registrations alive until proven quiescence, and coordinate close/reset/reprogram with all in-flight traffic. A timeout does not prove DMA has stopped.
- Distinguish kernel completion, transport completion and output availability. Service connected stream endpoints concurrently when their dependency graph requires it.

This OPAE layer does not require SYCL queue submission, OpenCL MMD hostchannels or the oneAPI ASP runtime. AHLS sample testbench calls are not evidence of those services on the board.

## Source discrepancies retained, not silently repaired

- The handbook's illustrative header repeats the `FINISHCOUNTER` macro at `0x30` and `0x34` (H `10 - RTL IP Core Interfaces.md:333–340`, **H10_HEADER_ANOMALY**). Do not copy it as an actual header or infer two independent counters. Inspect the real generated header and RTL.
- CSR sample comments mention input ready/output valid, but the actual properties and handbook define input valid/output ready. The sample also has a blocking `OutputPipe::write` despite a comment claiming stop can always be serviced. S `Tutorials/Features/experimental/pipes/csr_pipes/src/csr_pipes.cpp:39–88` (**S_CSR**). Neither comment establishes a register or a liveness guarantee.

## Completion boundary

The deliverable is the source contract and its evidence, not a functional AFU. Before an implementation can be claimed complete, bind the actual AHLS project, complete endpoint inventory, board address map, all adapters, OPAE host ABI and reset/retirement behavior. Subsequent elaboration, simulation, timing and hardware qualification require separate authorization. All remain explicitly false in `acceptance_gates`.

Only local source reads/searches and the owned documentation/data writes were performed. No configure, build, setup, IP generation, test, vendor command, workstation operation, install, commit, push or accelerator migration was performed. JSON syntax checking is the file-write tool's automatic static check, not a project test or execution of authored code.
