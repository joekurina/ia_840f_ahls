# DMA host-channel compiler and streaming source contract

> **Historical experiment — outside the standard/USM BSP baseline.** This document preserves an earlier custom host-pipe investigation. Its transport choices, widths, CSR addresses and integration instructions are not requirements or approvals for the vendor-based modernization. Host pipes may enter the BSP only through an established reference-platform implementation; see [current preparation scope](preparation-plan.md). Do not execute the instructions below under the source-only authorization. Statements about candidate source locations describe the earlier experiment, not necessarily the active baseline after preservation/disconnection.


## Decision for integration

Use the **literal `hostpipe="true"`** on two 512-bit channel interfaces. Use the same explicit string for `port`, `chan_id`, and the MMD's accepted physical channel name:

```xml
<!-- Insert inside the existing board element; merge with existing channels. -->
<channels>
  <interface name="board" port="host_to_kernel" type="streamsource"
             width="512" chan_id="host_to_kernel" hostpipe="true"/>
  <interface name="board" port="kernel_to_host" type="streamsink"
             width="512" chan_id="kernel_to_host" hostpipe="true"/>
</channels>
```

This is a source integration contract, **not a compiler-validated board specification or a working DMA claim**. No vendor executable, configuration, compilation, simulation, test, or remote workstation operation was performed for this investigation. The XML is for the integration owner; no production board XML or hardware/source file was changed here.

| Contract | Evidence / confidence |
|---|---|
| `hostpipe="true"` and `hostpipe="false"` are the parser's accepted strings | High: static control-flow disassembly of the installed 2025.0 `aocl-boardspec`, not just nearby strings [1]. |
| `streamsource` is board-to-kernel, `streamsink` is kernel-to-board | High: existing OFS XML plus explicit kernel wrapper UDP connections [2]. |
| `width="512"` is the intended data payload width in bits | Existing XML width convention and 512-bit design requirement. Compiler acceptance of this new board combination remains unexercised. |
| `port` supplies the board streaming interface identity; `chan_id` is the channel identity used for I/O mapping | High for existing I/O channels [2,3]; keep them identical to remove an unnecessary naming ambiguity. |
| Non-CSR host-pipe runtime opens the discovered `physical_name` through MMD hostchannel create | Direct public runtime source [4]. The exact new compiler-emitted mapping is not available yet. |
| Exact generated HDL port names for these new host channels | **Not established**. Existing UDP names are precedent, not proof for DMA-hostpipe generation. |

## 1. Accepted hostpipe literal: stronger evidence than strings

The inspected file is:

```
/opt/intel/oneapi/compiler/2025.0/opt/oclfpga/host/linux64/bin/aocl-boardspec
SHA256 c5c09a0460e1cb09e512a37e19ca6948f6cf142337b42fa8356d0b50d8623f0c
```

Only Python byte reads and system `readelf`/`objdump` inspected this ELF. It was **never executed**, including no `--help` or validation invocation.

The retained disassembly [1] shows:

* `0x183fa` loads the `hostpipe` string at `0x3cd7b`, passes it to an attribute-reading helper at `0x18413`, then branches on success to `0x188f0`.
* `0x188f0..0x1890f` compares the returned string with `true` at `0x3c83e`, and on equality writes byte `1` to object offset `0x78`.
* On inequality, `0x18e1d..0x18e3c` compares with `false` at `0x3cae4`; equality writes byte `0` to the same offset.
* Neither comparison matching branches to `0x1906c`, constructing `Unrecognized hostpipe setting in Avalon interface '` from `0x3e738` and reporting against the `hostpipe` attribute.

Thus use lowercase `true`, **not** `1`, `yes`, `True`, or a made-up enum. This establishes the parser branch, not execution of the whole XML validation path. The binary is stripped: objdump's labels relative to `std::ctype` are nearest surviving dynamic-symbol labels, **not parser function names**.

Important correction to the earlier string-only evidence: the nearby `'; valid values are 'true' and 'false'.` string is **not** what this hostpipe rejection path appends. This path appends `'.` at `0x3cccc`. The accepted literals are established by the actual comparisons, not by assigning a nearby diagnostic to the wrong branch.

## 2. Names and directions are three different contracts

### Board XML and I/O identity

The public oneAPI handbook [3] describes numeric I/O pipe IDs as zero-origin indices into `channels` interfaces, counting only `streamsource` and `streamsink`, and describes `chan_id` as the interface/channel name needed for simulation. Its example uses `name="board"`, `port="c1"`, `type="streamsource"`, and `chan_id="c1"`; the next interface is a sink. This is the **I/O pipe** indexing contract, not evidence that a SYCL host-pipe type must select numeric I/O IDs.

Do not assign a PCIe physical-channel number, MMIO offset, MMD handle, or C++ mangled pipe type name to `chan_id`. Here choose the literal strings `host_to_kernel` and `kernel_to_host`. Preserve existing channel ordering if extending a board that already exposes numeric I/O pipes; inserting entries can change their indices. The selected compiler's treatment of mixed host/I/O indexing still requires later generated-artifact inspection.

### Runtime physical name

The cached public MMD header says `channel_name` is the same name used in `board_spec.xml` [4]. For the non-CSR branch, `acl_program.cpp:1356–1362` passes `hostpipe.physical_name` to `hostchannel_create`; the HAL passes the name through and converts packet count times packet width into the byte queue depth. The MMD should recognize the two chosen strings exactly and reject unknown names/direction mismatches.

There is no new compiled autodiscovery artifact here proving which XML name field produced `physical_name`. Keeping `port == chan_id == MMD physical name` is an implementable conservative contract, **not** a claim to have recovered that compiler transformation. The logical SYCL pipe name is separate from this physical name. Do not construct a fake autodiscovery record to cover that missing evidence, or silently use `implement_in_csr=true` when DMA is required.

### Existing HSSI source precedent

The OFS editor emits `udp_out_N` as a `streamsink` and `udp_in_N` as a `streamsource` [2]. In the same source tree, `kernel_wrapper.v:867–875` connects:

```
kernel_system.udp_out_0_{data,valid,ready} <-> udp_avst_from_kernel[0]
kernel_system.udp_in_0_{data,valid,ready}  <-> udp_avst_to_kernel[0]
```

These are actual source spellings for that I/O path. They are **not** newly observed generated DMA-hostpipe ports. Also, the current common `board_hw.tcl` does not export these UDP interfaces: the HSSI path connects at the `kernel_system` wrapper boundary. Merely adding board Tcl exports does not automatically modify that wrapper or prove the new streaming path is integrated.

## 3. Implementable Tcl naming, without fabricated generated names

Board-owned component interfaces and their HDL ports can be assigned explicitly. Compiler-generated module ports cannot be retroactively named just by assuming a suffix convention.

The following is a component-definition excerpt for an **owned bridge component** (its RTL/file-set/module declaration and transport-side interfaces are separate requirements). Here `kernel_clk` and `kernel_reset` must already be declared clock/reset interfaces belonging to that component. These `add_interface_port` statements deliberately define exact names for the bridge's own RTL ports:

```tcl
# Component _hw.tcl: owned RTL bridge, kernel-clock domain.
add_interface kernel_tx avalon_streaming source
set_interface_property kernel_tx associatedClock kernel_clk
set_interface_property kernel_tx associatedReset kernel_reset
set_interface_property kernel_tx dataBitsPerSymbol 512
set_interface_property kernel_tx symbolsPerBeat 1
set_interface_property kernel_tx readyLatency 0
add_interface_port kernel_tx host_to_kernel_data  data  Output 512
add_interface_port kernel_tx host_to_kernel_valid valid Output 1
add_interface_port kernel_tx host_to_kernel_ready ready Input  1

add_interface kernel_rx avalon_streaming sink
set_interface_property kernel_rx associatedClock kernel_clk
set_interface_property kernel_rx associatedReset kernel_reset
set_interface_property kernel_rx dataBitsPerSymbol 512
set_interface_property kernel_rx symbolsPerBeat 1
set_interface_property kernel_rx readyLatency 0
add_interface_port kernel_rx kernel_to_host_data  data  Input  512
add_interface_port kernel_rx kernel_to_host_valid valid Input  1
add_interface_port kernel_rx kernel_to_host_ready ready Output 1
```

At the **board system-composition** level, after instantiating that component as `hostchannel_bridge`, these statements assign the board-visible interface identifiers to match the XML:

```tcl
# System composition callback, with hostchannel_bridge already instantiated.
add_interface host_to_kernel avalon_streaming start
set_interface_property host_to_kernel EXPORT_OF hostchannel_bridge.kernel_tx
add_interface kernel_to_host avalon_streaming end
set_interface_property kernel_to_host EXPORT_OF hostchannel_bridge.kernel_rx
```

The existing board's `acl_internal_snoop` uses the same `add_interface ... avalon_streaming start` / `EXPORT_OF` pattern [2]; its underlying component uses `avalon_streaming source`. The new source/sink excerpt is a proposed component contract, not existing bridge code or executed Tcl. The instance/interface identifiers on the right side of `EXPORT_OF` must match the actual hardware worker's implementation.

**Names this can establish:** board interface `host_to_kernel`, board interface `kernel_to_host`, and explicit RTL port names inside the owned bridge. **Names it does not establish:** the FPGA compiler's new `kernel_system` physical port spellings, automatically flattened parent-system port names, or the compiler's internal pipe net names. Do not copy the six bridge port spellings into a `kernel_system` instance and claim verification from this excerpt. If integration remains at the existing HSSI-style wrapper boundary, use the actual generated module declaration/metadata when later authorized; if integration instead uses board-system interfaces, the composition must actually connect them rather than expose an unused second path.

For this proposed ready/valid contract: H2K has data/valid from board to kernel and ready back; K2H has data/valid from kernel to board and ready back. A beat transfers on simultaneous valid and ready, and an unaccepted valid beat must remain stable. `readyLatency 0` and a single 512-bit symbol are explicit design choices to align with the intended 512-bit word transport; generated compiler interface properties must later agree. Do not infer packet sidebands, byte enables, ready latency, CDC behavior, or reset polarity from the XML width. Any DMA-side packetization/partial-word behavior belongs in the bridge contract.

## 4. Source handoff and remaining qualification boundary

The parent can now insert the exact XML declarations and require the HW/MMD owners to share the two literal channel names. This resolves the accepted boolean literal and board-side naming choices without vendor execution. It does **not** resolve the missing generated boundary by inventing it.

Later, only with separate execution authorization, obtain and inspect compiler-generated interface metadata/module declarations and autodiscovery. Required evidence before calling this an integrated DMA host pipe:

1. Both names survive as non-CSR host-pipe physical mappings with expected direction and 512-bit transport width; distinguish XML bit width from runtime byte width.
2. Actual generated interfaces/ports connect to the DMA bridge once, with matching data/valid/ready roles and latency, clock, and reset contracts.
3. The MMD receives those exact physical names and binds actual pinned-memory DMA queues, not a CSR pipe or a shadow staging-only implementation.

None of these execution/transport checks was run. No public hostpipe-enabled reference BSP was newly established in this bounded investigation; the available OFS I/O source plus installed parser disassembly is enough for the proposed source contract, but not a substitute for generated-hostpipe qualification.

## Sources and retained evidence

[1] [Static installed-parser evidence](../reference/hostpipe-abi/boardspec-2025.0-static-hostpipe.txt): hash, literal addresses, and bounded objdump disassembly; only the system inspection programs ran.

[2] [OFS source excerpts with full-file hashes](../reference/hostpipe-abi/oneapi-asp-stream-port-source-excerpts.txt). Local source HEAD `1af2ca74c452cb6ebbf54beb86e758e53489e826`, origin `https://github.com/OFS/oneapi-asp`:

* `oneapi_asp_editor/oneapi_asp_editor_hw.tcl:632–645` (XML writer).
* `n6001/hardware/ofs_n6001_iopipes/board_spec.xml:49–59` (board channels).
* `common/hardware/common/build/rtl/kernel_wrapper.v:343–350,867–875` (module and explicit UDP ports).
* `common/hardware/common/build/board_hw.tcl:421–488` (export patterns and absence of UDP exports in the export block).
* `common/hardware/common/build/ip/memory_bank_divider_hw.tcl:191` (`avalon_streaming source` component precedent).

[3] [Cached Intel oneAPI FPGA Handbook 2025.0, document 829749](../reference/hostpipe-abi/oneapi-fpga-handbook-2025.0-829749.txt), text lines 9409–9455 (I/O pipe IDs, channel XML and `chan_id`). Original URL/hash provenance is in the existing [source manifest](../reference/hostpipe-abi/source-manifest.json).

[4] Public [Intel FPGA runtime commit 32a36fe51d3bab2c7caff98e744e7ee3dd55da7d](https://github.com/intel/fpga-runtime-for-opencl/tree/32a36fe51d3bab2c7caff98e744e7ee3dd55da7d), cached under `reference/hostpipe-abi/intel-fpga-runtime-for-opencl/32a36fe51d3bab2c7caff98e744e7ee3dd55da7d/`: `include/MMD/aocl_mmd.h:464–482`, `src/acl_program.cpp:1356–1362`, `src/acl_hal_mmd.cpp:2318–2328`. Source URLs and SHA256 values are in the existing manifest.
