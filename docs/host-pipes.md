# CSR-backed oneAPI host pipes — source-only FPGA Test

> **Historical experiment — outside the standard/USM BSP baseline.** This document preserves an earlier custom host-pipe investigation. Its transport choices, widths, CSR addresses and integration instructions are not requirements or approvals for the vendor-based modernization. Host pipes may enter the BSP only through an established reference-platform implementation; see [current preparation scope](preparation-plan.md). Do not execute the instructions below under the source-only authorization. Statements about candidate source locations describe the earlier experiment, not necessarily the active baseline after preservation/disconnection.


**Proposed selected transport: genuine oneAPI host pipes implemented in the kernel control/status register (CSR) interface. Not a high-throughput ring-DMA transport.** The C++ declarations and CMake target are source preparation only. Nothing here has been configured, compiled, linked, simulated, executed, installed, or hardware-qualified. Existing FIM/BSP build gates remain in force.

The distinction matters: the Intel runtime has both a CSR-backed host-pipe branch and a non-CSR host-channel branch. Missing ASP `aocl_mmd_hostchannel_*` implementations do not by themselves rule out CSR-backed host pipes. Conversely, an existing kernel CSR route does **not** prove that this compiler/BSP/runtime combination emits and consumes compatible host-pipe metadata.

## Source files and intended board variants

- [`../afu/hostpipe_csr/hostpipe_csr.cpp`](../afu/hostpipe_csr/hostpipe_csr.cpp): one finite kernel, host-to-device and device-to-host experimental host pipes, bounded cooperative host progress, and ordered numerical verification.
- [`../afu/hostpipe_csr/CMakeLists.txt`](../afu/hostpipe_csr/CMakeLists.txt): standalone, CMake-native hardware target `hostpipe_csr_fpga`, not a shell compiler wrapper.
- Exact supported source variants are `ofs_ia840f` and `ofs_ia840f_usm` in `oneapi-asp/ia840f/hardware/`. Neither is a qualification claim. USM is not needed or used by this example.

The CMake option `IA840F_ENABLE_HOSTPIPE_CSR_FPGA_TEST` defaults to `OFF`; with it off, the leaf project does not even enable the C++ language. When later explicitly enabled, the executable remains `EXCLUDE_FROM_ALL`. There are no automatic run, CTest, install, emulator, simulator, or report targets. The compiler must be selected explicitly through `CMAKE_CXX_COMPILER` and must identify as IntelLLVM 2025.0.x. FPGA backend options occur at link time. `IA840F_HOSTPIPE_BSP_ROOT` identifies the exact package root and `IA840F_HOSTPIPE_BOARD_VARIANT` is validated against the two literal variants; no family-only fallback is allowed. The resulting target argument is `-Xstarget=<absolute-package-root>:<exact-variant>`.

This standalone leaf is not wired into a default project build. Do not configure or build it now, and do not treat enabling the option as permission to bypass the separate unfinished BSP/FIM gates. Commands are intentionally not presented as an immediately runnable qualification recipe.

## Established API and the direction-specific protocol rule

The cached official **Intel oneAPI DPC++/C++ Compiler Handbook for FPGAs 2025.0**, document 829749, chapter 14, printed pages 199–200, establishes the CSR protocols:

- Cache: [`../reference/hostpipe-abi/oneapi-fpga-handbook-2025.0-829749.txt`](../reference/hostpipe-abi/oneapi-fpga-handbook-2025.0-829749.txt), lines 9044–9078. PDF and retrieval provenance are adjacent; see `source-manifest.json`.
- **H2D:** `protocol<protocol_name::avalon_mm>` with `uses_valid<true>`. The host writes data and asserts valid; the kernel clears valid when consuming the element. This prevents the host from overwriting an unconsumed element.
- **D2H:** `protocol<protocol_name::avalon_mm_uses_ready>`. The handbook explicitly restricts this protocol to device-to-host pipes and forbids specifying `uses_valid` on them. The ready handshake allows host backpressure rather than silently overwriting the last value.

The source therefore deliberately does **not** apply `avalon_mm_uses_ready` to both directions:

```cpp
namespace intel_exp = sycl::ext::intel::experimental;
namespace oneapi_exp = sycl::ext::oneapi::experimental;
using InputProperties = decltype(oneapi_exp::properties(
    intel_exp::protocol<intel_exp::protocol_name::avalon_mm>,
    intel_exp::uses_valid<true>));
using OutputProperties = decltype(oneapi_exp::properties(
    intel_exp::protocol<intel_exp::protocol_name::avalon_mm_uses_ready>));
using InputPipe = intel_exp::pipe<CsrInputID, std::int32_t, 0, InputProperties>;
using OutputPipe = intel_exp::pipe<CsrOutputID, std::int32_t, 0, OutputProperties>;
```

Installed headers inspected, not compiler-invoked:

- `/opt/intel/oneapi/compiler/2025.0/include/sycl/ext/intel/experimental/pipe_properties.hpp:39–44,56–68,77–100`: exact `uses_valid`, `protocol_name`, and `protocol` declarations.
- Adjacent `pipes.hpp:53–55`: fourth pipe template parameter is the properties type.
- `pipes.hpp:79–133`: nonblocking host `read(queue&, bool&)` and `write(queue&, const T&, bool&)`; these submit runtime operations and call `wait_non_blocking`. Initialize the success flag before **every** attempt: the unsupported-extension early-return path does not assign it.
- `pipes.hpp:237–239` and `79–82,108–111`: the host `memory_order` argument is currently unused. Its default `seq_cst` spelling is **not** evidence of a host/device global-memory fence.

Local Intel sample evidence under `/home/joe/Projects/oneAPI-samples-2025.0/DirectProgramming/C++SYCL_FPGA/`:

- `Tutorials/Features/hls_flow_interfaces/component_interfaces_comparison/csr-pipes/src/vector_add.cpp:18–33` establishes the `decltype(properties(...))` experimental pipe form; `:93–101` shows queue-taking host calls and a finite submitted kernel. That sample uses `avalon_mm` for its one-shot output, not the backpressured D2H protocol selected here.
- The parent `component_interfaces_comparison/CMakeLists.txt:38–46,128–140,155–168` documents BSP-root/variant targeting, link-stage FPGA backend flags, and explicitly excluded targets.
- `Tutorials/DesignPatterns/restartable_streaming_kernel/src/restartable_counter_kernel.hpp:29–35` uses the same property syntax, but assigns `avalon_mm_uses_ready` to a host-written stop pipe while its comment says it is unnecessary. This conflicts with the handbook's direction restriction. It is **not** copied as authority for H2D protocol selection.

The example chooses `std::int32_t` as a small scalar payload. No generic minimum/maximum host-pipe width, CSR payload-width limit, or achieved capacity is asserted. Template minimum capacity `0` is not a measured FIFO depth and is not used in the host progress logic.

## Runtime ABI evidence: CSR is not the host-channel path

All runtime paths below are relative to:

`reference/hostpipe-abi/intel-fpga-runtime-for-opencl/32a36fe51d3bab2c7caff98e744e7ee3dd55da7d/`

| Source | What the inspected source establishes |
| --- | --- |
| `src/acl_auto_configure.cpp:650–685` | Program host-pipe metadata includes `implement_in_csr`, `csr_address`, directions, protocol, and stall behavior. Those fields must come from real compiler output, not invented XML. |
| `src/acl_program.cpp:1349–1368` | A CSR pipe saves its CSR address and sets channel handle to `-1`; only the `else` branch calls `hostchannel_create`. |
| `src/acl_hostch.cpp:829–895` | D2H CSR reads check ready, read data when available, and rearm ready; the ready register is data address plus `csr_pipe_address_offet` (commented as eight bytes). Nonblocking reads fail while ready is one. |
| `src/acl_hostch.cpp:981–1053` | H2D CSR writes check valid, write data, then assert valid. Nonblocking writes fail while valid is one. The valid register uses the same documented offset. |
| `src/acl_hal_mmd.cpp:3122–3135` | CSR access dispatches through `aocl_mmd_read` / `aocl_mmd_write`, with `op=NULL`, on the MMD kernel interface. It does not dispatch through the memory-DMA interface or host-channel push/pull APIs. |

The fixed handshake-register offset is runtime ABI evidence, **not** a payload-width limit. The example does not hardcode CSR addresses or issue raw MMIO. Nor does it add non-CSR board channel XML, fake host-channel exports, or an emulated DDR mailbox. Compiler-generated metadata and address mapping remain a mandatory later verification step. The cached source revision is not proof of the identity or correctness of any installed runtime binary.

## Existing ASP route, traced in source

Paths below are relative to `new/` (this document's parent):

1. `oneapi-asp/common/source/host/mmd.cpp:1045–1046` reports `AOCL_MMD_KERNEL` for `AOCL_MMD_KERNEL_INTERFACES`; `mmd_device.h:101` defines it as `0x4000`. `mmd.cpp:1214–1224,1262–1271` dispatches writes/reads to the device methods.
2. `oneapi-asp/common/source/host/mmd_device.cpp:1024–1083` distinguishes `AOCL_MMD_MEMORY` (DMA) from other interfaces, which call MMIO with `mmd_interface + offset`. `:1143–1261` implements those accesses through OPAE `fpgaReadMMIO32/64` and `fpgaWriteMMIO32/64`.
3. `oneapi-asp/common/hardware/common/build/board_hw.tcl:387–390` connects `pipe_stage_host_ctrl.m0` to `kernel_interface.ctrl` at `0x4000`. `:416–419` connects `kernel_interface.kernel_cra` to `board_kernel_cra_pipe.s0`; `:461–462` exports the latter master as `kernel_cra`.
4. `oneapi-asp/common/hardware/common/build/ip/kernel_interface_hw.tcl:67–75,156–174` routes control through the address-span extender (`windowed_slave` at `0x1000`, control at `0x20`), clock crossing, and kernel CRA bridge. A compiler CSR address must be interpreted with this actual window/address contract; **do not turn a kernel-relative CSR address directly into an assumed PCI BAR offset**.
5. `oneapi-asp/common/hardware/common/build/rtl/kernel_wrapper.v:320–340,808–818` carries kernel control through the CRA bridge into the generated kernel system's CRA ports.
6. Both `oneapi-asp/ia840f/hardware/ofs_ia840f/board_spec.xml:44` and `.../ofs_ia840f_usm/board_spec.xml:48` declare the existing `kernel_cra` host interface. `oneapi-asp/ia840f/board_env.xml:2–5` selects the IA840F package/default variant and the OPAE/MPF/MMD library chain.

This is evidence for a **candidate existing control route**, not a generated interconnect, fitted design, address-translation proof, or working host-pipe demonstration. In particular, the runtime's direct CSR dispatch and the ASP address-span window must be reconciled against actual emitted metadata before declaring end-to-end compatibility. No common ASP/MMD/RTL source was modified by this example.

## FPGA Test behavior and bounded-host limitations

- Submit exactly one kernel invocation. Its fixed loop consumes and transforms a finite sequence; it is not an infinite autorun/service kernel. Blocking device-side pipe operations deliberately preserve backpressure. A finite trip count does not mean it can finish when transport is broken.
- Inputs alternate nonzero positive/negative index-derived values. There is no RNG, fixed RNG seed, zero-only vector, feeder kernel, device buffer, or USM payload. The kernel computes `3*x + 7` and the host independently evaluates the expected result with wider signed arithmetic, comparing every output at its expected sequence index.
- The host alternates **nonblocking** output reads and input writes. It retries the same input after a failed write and advances receive state only on success. It never tries to finish all writes before starting all reads.
- After the first successful send, draining is intentionally paused for ten milliseconds to offer backpressure, then resumed regardless of send progress. This does not require filling any presumed FIFO depth. Retry counters are observations, not a pass requirement: the source alone does not prove that a particular run will encounter a full pipe. No bandwidth claim follows from these counters or this pause.
- One monotonic thirty-second deadline covers setup, transfer progress, and polling the **finite kernel's** completion event. After all payloads are received, the host still polls `event::get_info<info::event::command_execution_status>()` under that same deadline; it does not wait indefinitely on a kernel event or the entire queue. It dispatches asynchronous errors explicitly.
- This deadline is **cooperative, not a hard driver timeout**. Queue creation/submission, a nominally nonblocking host-pipe operation, status queries, error delivery, diagnostic output, or OS scheduling can block inside a call. In particular, the installed header's nonblocking API still waits for its runtime operation internally. A later authorized hardware run needs an independent whole-process watchdog and explicit device-recovery policy; the example does not implement or prove either.
- The queue intentionally has process-lifetime ownership. Both success and failure flush diagnostics and use `std::_Exit`, avoiding queue teardown waits or normal unwinding of live FPGA resources. This is a standalone diagnostic lifecycle, **not** a reusable library cleanup pattern. It neither cancels a stuck kernel nor resets the device; process termination does not prove hardware quiescence. Subsequent invocations after failure require operator/runtime recovery, not blind reuse.

## What remains unverified

1. Actual oneAPI 2025.0 compiler acceptance of this source and emitted CSR host-pipe metadata: both directions, names, sizes, CSR addresses, handshake/stall flags, protocol, and generated reset/ready behavior. Header/sample/handbook agreement establishes API spelling, not generated results.
2. The selected installed runtime's CSR ABI, MMD interpretation of the emitted offsets, address-span window handling, access sizes and errors, and compatibility with the IA840F compiler-generated kernel system. Source presence does not certify runtime implementation correctness.
3. The unfinished modern IA840F FIM/ASP integration, toolchain compatibility, generated IP, timing, resets, and real hardware numerical correctness/backpressure behavior.
4. **No host-channel DMA streaming support is added.** CSR traffic uses the control path. Existing memory DMA and USM are different capabilities; this is not a descriptor ring, zero-copy payload stream, or throughput implementation.
5. **No global-memory fence can be inferred.** A CSR ready/valid handshake or a returned pipe token does not establish visibility of unrelated DDR/USM stores to host DMA. The example deliberately transports all numerical payload through the pipes and makes no cross-memory ordering claim.

No execution outputs are supplied because no execution was performed. A later numerical pass would qualify only the exercised finite exchange on the recorded compiler/BSP/runtime/image, not a production persistent-control protocol or high-throughput DMA transport.
