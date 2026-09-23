# Independent review: AHLS 2026.1.0 DDRIP report generation

Review date: 2026-09-23 UTC. Scope: local, read-only examination of the frozen result and exact source; this report is the only project file written. No SSH, vendor execution, sample execution, hardware access, source changes, commit or push.

## Verdict

**ACCEPT_IP_GENERATION_ONLY; HOLD_ABI_INTEGRATION_HARDWARE.** The captured native report target completed successfully for the exact adapted DDRIP sample with HLS IP Gen 2026.1.0 and an inner `aoc -target=AGFB027R25A2E2V`. The emitted interface declarations and header-level register layout are consistent with the intended two-memory-host design.

This is not a complete host-ABI approval. The Tcl does not explicitly specify `addressUnits`, the retained XML includes distinct compiler memory-space bases, and the actual top-level/CSR RTL bodies are inventoried but not available in this review package. Byte-addressed memory spans are corroborated by the metadata; effective Platform Designer address-unit defaults, pointer encoding, and actual finish-counter implementation remain integration checks. Do not treat this verdict as acceptance of Quartus 25.1 import, a persona build, OPAE/DMA, physical DDR operation, timing, or numerical correctness.

## Evidence integrity and scope

Paths below are relative to this directory unless stated otherwise. `P` denotes `artifacts/build/mmhost_ia840f.report.prj/`.

- Freeze manifest SHA-256: `b5bd6c62df3a817a2030f16d1338fefcaa57a5246727bc9b141413fbf1e65ee1` (`result-review-freeze01.json`). **All 15 listed files match their frozen hashes.**
- Result archive SHA-256: `9fc5b99048d45ba2632127eec48fcdfbb40bddcb89a44e7f320c2853ea50fe59` (`result01.json.gz`). Parsed successfully; `complete=true`, all three recorded commands have rc0, and `hardware_access=false`.
- All six current `../../afu/ahls_memory/` inputs match the result's input hashes. All eight embedded Base64 payloads hash correctly and equal their extracted local copies.
- The inventory contains **251 build files: 224 beneath the report project and 27 other build files**. It is not an inventory of 251 RTL modules. All seven locally retained build artifacts match the inventory's byte sizes and hashes; four additional retained files are execution/environment logs.
- All 155 distinct paths referenced by the generated Tcl synthesis/simulation filesets occur in the inventory. This checks recorded dependency presence, not the bytes of every remote generated file. Most generated RTL and report bodies were not exported; do not claim independent rehashing or semantic review of all 251 files.
- No `.ip`, `.sof`, `.gbs` or `.rbf` entries occur in the inventory. Missing `.ip` files are normal before Platform Designer import, not failure of report generation.

Key retained artifact hashes:

| Artifact | SHA-256 |
|---|---|
| `P/mmhost_ia840f_report_di_hw.tcl` | `f14a3420abed226b931b20600a3833adbc3b6478c70994485a832c2246bf14c3` |
| `P/mmhost_ia840f_report_di_inst.sv` | `e919316cd52a5a2aaac88493af3c50e5deb3c79a23ade374a050dc04d32bc29c` |
| `P/ipinterfaces.xml` and `P/board_spec.xml` (identical) | `1347ab794166b741aa4d1cdc263bc1bad9ee50f31d5ccdf2a208eb2c49e6c1a6` |
| `P/include/register_map_offsets.h` | `2d0e46ae309643e34098237ed3df45160314a1b265b2771cbbf7381a40c07a5f` |
| `P/include/kernel_headers/DDRIP_register_map.h` | `7ae5a030da2336addf1c6de10d742504ddfb1fcfb98a6e25bf1757d64c105be6` |
| `P/logs/mmhost_ia840f_report.log` | `361d9ecdb1dee15512b5d4f1a6cc69b97bc99614fc75859a280a15e51460cce0` |

## Compiler, target and exact source

`artifacts/logs/step00.log:1-6` identifies **HLS IP Gen 2026.1.0**, build `461da9be608f74678d9c52a2dc1cbb67c58d57fa`, Clang 21.0.0git. The recorded compiler launcher is `/home/uwb_student00/ahls/altera_hls/aclsycl/bin/ahls`, SHA-256 `cfa39317030afe071c35134067a1898a54832b49a9c0df5ac21063f6b7b1be3f`. This is historical captured identity, not a fresh remote tool remeasurement.

`generate01.py:16-29` sources `fpgavars.sh`, configures the explicit part, and executes only version/configure/report-build commands. `artifacts/logs/step02.log:18-23` records `-DFPGA_HARDWARE`, followed by `-Xshardware -Xstarget=AGFB027R25A2E2V -fsycl-link=early`, and `Built target report`. Crucially, `P/logs/mmhost_ia840f_report.log:1` independently records the backend's `-sycl -rtl -hardware -target=AGFB027R25A2E2V`. A report executable being linked is not evidence that it was run; no application-run command is present.

The configured Quartus 25.1 environment does **not** prove Quartus 25.1 import or compilation. Also retain this discrepancy literally: both XML files name `device_model="agfb014r24a3e3vr0_dm.xml"` at line 9, whereas the inner backend command targets `AGFB027R25A2E2V`. The command establishes the requested backend target; the XML model field does not establish exact IA840F device geometry. No assertion that this field was corrected, or that its effect was separately validated, is made here.

The local donor `/home/joe/Projects/Thesis/AHLS/hls-samples` has both HEAD and `2026.1.0^{commit}` at `0abae6d78af5daca3fe5d67e617ab037e58aff89`. Direct `git show` comparison of `Tutorials/Features/hls_flow_interfaces/mmhost/part3_ddr_hosts/src/mmhost.cpp` proves:

- Original SHA-256: `97c3627d91987f8f2f73b3a43148873d5e619c2cfa109e2099798e2cd1f46374`.
- Adapted SHA-256: `bbc41b6fb33646066a42d7fa1b009aca46ebc8a1f295feb0f8d200fe63f37b64`.
- **Exactly two `awidth<32>` → `awidth<34>` replacements plus five leading provenance-comment lines; no other C++ change.** The donor working copy also equals the pinned blob.
- `License.txt` and `include/exception_handler.hpp` are byte-identical to their pinned upstream counterparts. The small standalone CMake project is new integration scaffolding, not a byte-identical copy of upstream CMake. Its report compile/link flags agree with upstream `mmhost/CMakeLists.txt:120-128,154-167`.
- Arithmetic remains signed `int`: `z[i] = x[i] + y[i]`; size is signed `int`, loop unroll is 8, pointer alignment is 32 bytes, data width is 256, variable-latency setting is 0, and maximum burst is 8. Future test inputs must avoid signed-32-bit addition overflow unless a separately reviewed kernel change defines other behavior. The tiny inherited SYCL `main` is not an implemented OPAE host or an executed test.
- Read-only `git diff HEAD -- afu` is empty; the AFU status lists only the six additive, untracked memory-sample files. This corroborates preservation of tracked scalar AFU files against the current HEAD, not a comparison against an unavailable earlier whole-tree snapshot.

## Emitted interfaces and memory spaces

`P/mmhost_ia840f_report_di_hw.tcl:352-448` and `_di_inst.sv:9-49` agree on **all 31 port declarations across eight interfaces** (names, widths, roles and directions checked programmatically).

| Interface | Verified declaration / source association |
|---|---|
| `avm_mem_gmem0_1_port_0_0_rw` | Avalon host: address 34, read/write data 256, byteenable 32, burstcount 4; source `buffer_location<1>` shared by `x` and `y` |
| `avm_mem_gmem1_2_port_0_0_rw` | Same widths; source `buffer_location<2>` used by `z` |
| `csr_ring_root_avs` | Avalon agent: address 5, read/write data 64, byteenable 8; read, write, waitrequest and readdatavalid |
| `clock`, `resetn`, `freeze` | Single-bit inputs; reset is active-low and Tcl declares `synchronousEdges BOTH` |
| `kernel_irqs` | Single-bit IRQ output, associated with `clock` |
| `device_exception_bus` | 64-bit output conduit, associated with `clock`/`resetn`; not a proven debug CSR interface |

Both memory hosts have read and write signals, even though this kernel reads through the first and writes through the second. Preserve `waitrequest`/`readdatavalid` handling. Memory hosts and CSR are associated with the same declared `clock` and `resetn`; the freeze conduit alone does not prove a complete freeze/reset protocol. The 4-bit burstcount carries the declared maximum of eight transfers, not a claim of sixteen-transfer operation. At 256 bits per transfer the declared maximum burst covers 256 bytes.

`P/ipinterfaces.xml:3-8` and Tcl comments at lines 381/401 reconcile the compiler memory spaces:

| Source group | XML agent port | Emitted host | Compiler metadata base | Size |
|---|---|---|---|---|
| `x,y`, buffer location 1 | `mem1_rw` | `avm_mem_gmem0_1_port_0_0_rw` | `0x0` | `0x400000000` bytes (16 GiB) |
| `z`, buffer location 2 | `mem2_rw` | `avm_mem_gmem1_2_port_0_0_rw` | `0x20000000000` (Tcl decimal `2199023255552`) | `0x400000000` bytes (16 GiB) |

**Address-unit boundary:** the XML's per-memory extent equals `2^34` bytes, corroborating byte-addressed, 34-bit per-host address spaces, not 34-bit 256-bit-word addresses. However, neither host nor CSR explicitly sets `addressUnits` in this Tcl. No effective Quartus 25.1 import metadata or this design's address-slicing RTL was available to certify those defaults independently. Verify the resulting host `SYMBOLS`/byte versus CSR `WORDS` conversion at import before wiring the adapter.

The second compiler metadata base exceeds the entire 34-bit output range; it is not a literal address to drive on that host, a PCI BAR offset, or a proven FIM bank aperture. The source establishes two buffer-location groups, **not** physical FIM bank numbering or deployed DMA routing. The README's proposed bank-local pointer programming is an integration intent: the correct 64-bit CSR pointer encoding, handling of the XML high address bits, and projection onto each 34-bit host still require the actual emitted datapath. Do not copy `0x20000000000` into a host ABI by assumption, or silently discard it without checking that datapath.

## Register-map boundaries, not a deployed MMIO ABI

`P/include/register_map_offsets.h:4` places DDRIP at component-relative offset zero. `DDRIP_register_map.h:17-52,80-100` describes CSR map version 5 and the following **byte offsets**, not PCI BAR addresses:

| Register | Component byte offset | Described payload | Corresponding 64-bit word index |
|---|---:|---|---:|
| Status | `0x00` | 64-bit read; done bit 1, busy bit 2, running bit 15 | 0 |
| Start | `0x08` | Low 32-bit write; write 1 to initiate | 1 |
| Finish counter | `0x30` | Header describes read/clear-on-read and repeats the counter in both lanes | 6 |
| `arg_x` | `0x80` | 64-bit pointer write | 16 |
| `arg_y` | `0x88` | 64-bit pointer write | 17 |
| `arg_z` | `0x90` | 64-bit pointer write | 18 |
| `arg_size` | `0x98` | Low 32-bit signed-size payload | 19 |

A 5-bit word-indexed, 64-bit CSR interface spans 256 bytes (`0x00..0xff`, last aligned slot `0xf8`); the described argument payload ends at `0x9b`, within the slot ending at `0x9f`. The emitted header and bus width therefore require a byte-to-word address conversion, not direct connection of byte offsets to a five-bit input. The table's word indices are derived from the header layout, not observed deployed MMIO accesses. Reserved bytes/holes are not authorized registers. XML `kernel_config size="0x100000"` is not evidence of a one-MiB implemented CSR bank or a deployed BAR base.

**Actual header defect:** lines 83-84 define `DDRIP_REGISTER_MAP_FINISHCOUNTER_REG` twice, at `0x30` and `0x34`. Do not consume this macro unchanged as an approved ABI, infer two independent counters, or issue an unaligned 64-bit read at `0x34`. Header prose alone cannot establish effective counter width, saturation/wrap behavior, byteenable handling, or completion-versus-store-retirement semantics. In particular, the earlier scalar AFU's narrow counter implementation must not be assumed to apply to DDRIP. Reconcile this design's CSR RTL before writing the real host.

Relevant bodies are recorded but absent locally:

| Inventory path beneath `build/mmhost_ia840f.report.prj/` | Recorded SHA-256 |
|---|---|
| `mmhost_ia840f_report_di.sv` | `c072b420ca510e98de233184d1fc7664b50a158714f5516b82991452e2540756` |
| `kernel_hdl/DDRIP/DDRIP_function_cra_agent.sv` | `2f011cfb6aacb19cef4dab7e9648b0607def46ddf8d926b7ef11eb8c54d6bdc7` |
| `DDRIP_interface_structs.sv` | `64760cef4911b9e07204d3faba360ace3e8e5fa04dcd01ef3c1589964007b07f` |
| `kernel_system.sv` | `c826ac8842403f9392d531b72380f47e48c25ce60272930e885124cabaf8d8ea` |

Their recorded hashes bind a future export; they are not a substitute for reviewing their contents.

## Remaining acceptance boundaries

1. **Generated ABI/integration:** export and hash-match the relevant generated RTL; settle address-unit defaults, pointer projection, finish-counter semantics and write retirement. Perform actual Quartus 25.1 Platform Designer discovery/import/validation/generation for this component. Earlier scalar or Quartus 26.1.1 evidence cannot qualify it.
2. **FIM/OPAE:** bind the exact physical memory instances and windows, implement reviewed data-width/burst/address adaptation, clocks/resets/freeze/IRQ handling, and source-derived CSR decoding without collisions. Implement real DMA and OPAE host behavior; USM compile-harness pointers are not deployed device pointers.
3. **Persona implementation:** no accepted full-persona synthesis, fitter, timing, CDC/DRC, image, or source-to-programmed-image coherence is supplied by this result.
4. **Functional hardware:** no emulator, simulator, numerical DDR or OPAE test ran in this evidence. Completion alone would not prove arithmetic, bank mapping, absence of aliasing, or DDR integrity. Future hardware acceptance needs bounded, overflow-safe numerical comparisons through the actual copy-back path and the separately authorized memory-test scope; no hardware action is authorized here.

The frozen `RESULT.md` is acceptable as a report-generation milestone when read with these limitations. Its blanket byte-address description must not be promoted to a verified imported/deployed ABI. `afu/ahls_memory/provenance.json` retains pre-generation `generated_ports_verified=false`; that historical input was not edited. This independent review records declaration-level verification without changing that frozen provenance or falsely closing the integration/hardware gaps.
