# Connected DMA + AHLS memory core — native generation/elaboration

**Native generation and analysis/elaboration completed; independent review pending.** This is an additive component, not a deployable FIM/persona. [Scope](SCOPE.md), [parent verification](parent-verification01.json), [interface verification](native-interface-verification01.json).

## Source and native sequence

1. Add `afu/ahls_memory/fabric/ia840f_ahls_memory_fabric_dma_hw.tcl`, preserving the prior accepted fabric component. Apart from the new name, change both DMA entry ID parameters16→9, enable M0BRESP in the MMIO and DMA-CSR bridges, and enable S0BRESP in DMA-CSR. No memory width/address, bank output ID/USER, HLS, clock/reset or latency-parameter change.
2. Native Quartus25.1 qsys-script import/validate/save and qsys-generate synthesis-HDL generation, fresh `work_ahls_memory_dma_core01/fabric01`, tmux@217. Native/effective/outer0/0/0; no timeout or surviving owned group. All224 bound source inputs and the isolated corrected LSU retain before/after identities; component/system scripts and tools unchanged. Full261captured native members preserved with archive hash in [receipt](outer-fabric01.json).
3. Add `afu/ahls_memory/core/ia840f_ahls_memory_core.sv`: flat external MMIO, host-memory and two bank interfaces containing actual DMA top/CSR/descriptorFIFO/selector/mux/register slices/read-write engines/dataFIFO and the generated AHLS fabric. All245generated ports connected;171external ports. No primary host mapper is instantiated here.
4. Native `/opt/altera/25.1/quartus/bin/quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ia840f_ahls_memory_core_elab -c ia840f_ahls_memory_core_elab`, fresh `work_ahls_memory_dma_core_elab25_01/elab01`, tmux@218. Native/effective/outer0; no timeout or surviving owned group. BothQIPs and254dependency edges supply255generated inputs, plus25core inputs:280bound files. Seven native report/log/project members captured. QSF, all copied/original source and tools unchanged. [Receipt](outer-elab01.json), [QSF](project01.qsf), [dependency graph](qip-dependencies01.json).

The banner “Quartus Prime Synthesis was successful” is the native **analysis/elaboration** result, not mapped synthesis, fit, assembly or timing. The native parameter/hierarchy sections show csr_mgr, descriptor scfifo, selector, both register slices, dma_engine reader/writer/dataFIFO, and actual DDRIP/LSU/CRA structures together. No simulation or numerical execution of this combined core occurred.

## Bound interfaces and preservation

Generated HDL and SOPCINFO match **245ports /11interfaces** exactly by name,direction,width. Versus prior fabric, only8DMA ID ports16→9 and new2-bit dma_csr_bresp differ. Bank output IDs remain18, USER2, addresses34bytes/data512; DMA inputID9/USER2; CSR16→18ID routing remains intact. NewBRESP is wired directly to the real CSR interface, not tied toOKAY. [Connections](connection-ledger01.json). All155generated HLS source files match the prior accepted fabric byte-for-byte, including corrected write-ack LSU.

Standalone source-bound geometry projection:2banks,34-bit byte offsets,512data,AXIlen8,localID9/USER2,host57. [Source chain](geometry-binding01.json). **ARUSER/AWUSER14 in mem_ss metadata does not mean local USER14**: WUSER is absent, the FIM package defaults WUSER1, and local_mem_cfg_pkg adds one NO_REPLY bit, yielding2. The earlier unit geometryUSER14 was explicitly synthetic; its tests are not automatically qualification for this different integration shape. External hostUSER4 matches the PIM host flag structure, but actual host mapping/fencing is not present.

The projection and minimal include umbrella are **not the imported/generated full PIM**. A component-only simulation UUID is retained and cannot be flashed or used for discovery. Bank outputID18 must reach a PIM shim that preserves extra AFU IDs, not be sliced to the physicalID9. The captured native local-memory shim source has user/extra-ID preservation, burst mapping and optional CDC; none of those shims is instantiated by this component pass.

## Diagnostics — retain, do not waive

Native banner says0errors/1warning. The complete log contains **142warning occurrences**:13469×49,16788×17,21610×73,17498×1,20759×1,21620×1. [Warning ledger](warning-ledger01.json) binds every source-bearing diagnostic to an available local source/hash. These counts are separate native presentations; do not relabel this warning-clean or force equality.

- DRC **RES-10204**, High,1violation/0waived: no Reset Release IP detected;1of10rules failed. This component has an external reset, not a board reset owner. Establish exactly one full-device provider and its path during FIM/PIM integration; do not add duplicate device-level IP to silence this standalone result.
- New DMA warnings include CSR config-field truncation,150→64status packing, nine-state writer debug state into6bits, request/performance counter widths, and undriven partial-status or inactive-interface fields. Source-based classification is required; vendor origin is not a waiver.
- Directional mux warns97→74packed AR resizing before its field-wise AR copy, and USER4→2 mapping. Normal DMA commands currently generate zero special flags, but no arbitrary host flag preservation, atomics/interrupt/fence behavior or functional mixed-USER proof follows. Review actual macro ordering and consumers rather than treating all width warnings as address clipping or all as harmless.
- HLS generated warnings/constant-zero exception output remain. That exception bus is not a numerical/completion/error detector.

## Open integration and acceptance boundaries

The core now connects DMA to the actual generated AHLS two-bank arbitration/width-conversion fabric, rather than testing them separately. This establishes native structural elaboration only. The full kernel has not run through this transport. Required next boundaries include one primary PIM host mapping, real generated platform/package import, per-bank ID/USER/CDC adapters, coherent reset/PR, strict outer MMIO decode (known upper-address alias remains), readable admission/first-error status, posted-write fault visibility, stop/reset/global drain, host-buffer lifetime/fences and actual numerical integration tests.

The CSR admission candidate is the exact separately simulated green03 source; its independent review is still separate. Prior routing acceptance is published f9a860d86168d6b468eb4f4bcee35baccf79e45a. Neither predecessor acceptance nor this native compile establishes physical DDR, host visibility, timing, OPAE discovery or durableboot.

During capture, an API tool-call cap interrupted local report extraction. Parent completed the existing archive's mechanical byte-preserving extraction and verified all261members; no native rerun occurred. Raw archives/generated RTL/oversized reports/payload-bearing runners remain local-only under the artifact policy.

No FPGA/device/MMIO, driver changes, programming or reboot. Vendor DDR simulation **SKIPPED BY USER**. Workstation availability and all hardware safety gates remain binding; overall goal incomplete.
