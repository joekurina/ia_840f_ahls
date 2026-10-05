# Copy-engine and corrected DMA — functional repairs verified

## Result

Both previously failing data tests now pass on the new packet-capped AFU images, and independent FINAL `deleg_394c8322` accepts each named scope. This closes the data-path debugging work; it does not qualify reset/drain safety or remove the remaining lifecycle warning.

| Test | Verified result |
|---|---|
| Copy-engine: 32 buffers × 4,096 bytes, completion frequency 1, maximum 8 requests in flight | Native/effective build 0/0, PR 0, host 0; 2,048 lines read and written; all 131,072 checked bytes match the bitwise-NOT expectation |
| Corrected DMA: bank 0, one 1,024-byte H2D descriptor and one 1,024-byte D2H descriptor | Native/effective build 0/0, PR 0, host 0; all 128 destination words correct; original host retained, no host-side descriptor chunking |

[Copy acceptance43](copy_engine-cap27/FINAL-ACCEPTANCE43.json), [DMA acceptance43](dma-cap27/FINAL-ACCEPTANCE43.json). Native input inventories preserve exactly 44/44 copy inputs and 47/47 DMA inputs. Each GBS matches its native RBF payload and the accepted FIM interface UUID. The final reviews rechecked the frozen manifests, native owner/argv/cwd and terminal receipts, exact stdout data markers, and same-boot scoped postflight.

## What was corrected

### 1. My copy checker had the wrong oracle

The tutorial instantiates `data_stream_engine` between reader and writer and deliberately inverts every payload bit. My earlier added checker expected an unchanged copy, so it rejected the source-defined transform. The separate `copy_engine_invert_checked.c` now expects bitwise NOT and includes bounded mismatch diagnostics. The old checker and all original failed receipts remain unchanged. [Oracle acceptance21](COPY-ACCEPTANCE21.json).

The old 2,048-byte identity-check failure therefore did not establish hardware corruption. Its returned bytes were not captured, so they are not retroactively inferred. The earlier 4 KiB completion deadline was a separate problem, now resolved at the same original request shape by the capped image.

### 2. AFU-side host packet fragmentation now respects the configured MPS

Actual retained build sources show PU encoding, disabled DM encoding and a 512-byte static write-packet allowance. The captured PF0 PCIe Device Control value `0x2930` specifies MPS 256 bytes and MRRS 512 bytes. PCIe Gen 3 itself does not impose a 256-byte payload limit.

The diagnostic controls localized the failure: unsplit 128/256-byte DMA transfers passed; unsplit 512/1,024-byte host-bound legs left destination memory poisoned even after a later snapshot, with correct source contents. Keeping H2D unchanged while splitting only D2H into 256-byte descriptors restored both full payloads. [Paired results20](DMA-PAIRED-RESULTS20.json), [source diagnosis28](DMA-DIAGNOSIS-CONSUMED28.json).

The implemented repair is an additive shared AFU adapter:

`original wide engine interface → public burst mapper → four-beat capped interface → existing primary PIM`

It preserves address/data widths, masks, IDs, USER fields, clocks/reset and PIM read sorting/buffering. The public mapper reconstructs fragment WLAST and original response cardinality. It uses private AFU USER bit 4 instead of the PIM's internal bit-0 NO_REPLY, avoiding nested suppression ownership. The original engines do not need to issue smaller descriptors. [Source acceptance29](CAP-SOURCE-ACCEPTANCE29.json), [candidate27](packet-cap27/review-manifest27.json).

Both original larger-request shapes now pass without the diagnostic host-chunking workaround. That verifies the functional repair and strongly supports the packet-size diagnosis. Actual on-wire TLP sizes or physical rejection were not captured; source-predicted packet sizes are not presented as wire measurements.

## Changed source artifacts

Paths are relative to this debug directory:

- `copy_engine_invert_checked.c` — separate corrected copy host; original host retained.
- `packet-cap27/ia840f_host_packet_cap.sv` — shared adapter, direct public `ofs_plat_axi_mem_if_map_bursts`, private USER4, PAGE_SIZE 4096, NATURAL_ALIGNMENT 0.
- `packet-cap27/copy_engine/ofs_plat_afu_cap.sv` — alternate copy top, unchanged engine and primary PIM settings.
- `packet-cap27/dma/ofs_plat_afu_cap.sv` — alternate DMA top; prior read-count/B-retirement corrections retained.
- `cap-source27-readback/` — exact staged source lists and alternate-top readbacks; the original top files are still present and unchanged.

All 85 original tutorial files still match the campaign's initial inventory. No FIM/export alteration, reflash, PCIe MPS/link change, driver change, power-cycle or reboot was performed for this repair. The prior closed campaign's raw failures, unknown statuses and milestone records remain intact; this follow-on supplies the correction and later successful evidence rather than rewriting history.

## Tested image locations

Both native builds used Quartus 26.1.1 Build130 and the unchanged matching release `/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01`.

**Copy image:**

```text
/home/uwb_student00/ahls/new_BSP/work_examples_afu_debug01/copy_engine-cap27/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs
```

SHA256: `9ed7a4b6c900505ef555fa6c1dfbda282737d70ba46fc8f34dacd80eb0d583dc` — 7,790,919 bytes.

**DMA image:**

```text
/home/uwb_student00/ahls/new_BSP/work_examples_afu_debug01/dma-cap27/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs
```

SHA256: `69c83b336a6b4bae3e0a8fe19b9c197d50fabd125c24893eebaad3768954abe2` — 8,470,847 bytes.

Programming images and oversized native logs remain remote-only and hash-referenced. These are retained native workspaces and qualified source changes, not an end-to-end clean-checkout build package. No additional synthesis is needed to reuse these unchanged tested images.

## Remaining limitations

**Both passing runs still logged a VFIO pending-transaction timeout during cleanup, followed by “performing function level reset anyway.”** The new warning timestamps are `7639.887118` for copy and `7779.246637` for DMA. They remain material and unwaived. Empty ordinary OS holders/maps/process lists and host exit0 do not establish global DMA drain, reset safety, future health or no-hang guarantees. [Copy kernel delta39](copy_engine-cap27/kernel-delta39.log), [DMA kernel delta41](dma-cap27/kernel-delta41.log).

Other limits:

- Copy's byte pattern repeats every 256 bytes within a buffer; generic fragment-permutation coverage is not established.
- Copy's unchanged AxBURST field is zero, not explicit INCR. Acceptance uses the existing PIM line-address semantics, not generic FIXED-burst compliance.
- DMA acceptance is bank0, low-32-bit IOVAs `0x0` and `0x1000`, aligned full-width 16-beat WRAP ranges. Other banks, ranges and unaligned/narrow accesses are unqualified.
- The original DMA read engine's RRESP observability remains incomplete; intermediate BRESP errors are not aggregated by the cap.
- No HDL simulation, capacity/isolation, error-injection, timing-signoff or performance qualification is claimed by these functional tests.

## Handoff

Both functional repair gates are accepted. No build, card operation or review remains active; late build-waiter notices refer to consumed completed jobs. The last recorded successful PR/test was the capped DMA image on boot `c5b29027-5b6b-4bf2-b7ed-ace79cc87e73`; this is not a fresh live-fabric integrity or hardware-health measurement.

No further hardware is needed to close these data failures. The unresolved VFIO lifecycle warning and stronger error/coverage qualification would be distinct follow-on work. Results and sources are retained locally in this debug directory; this follow-on has not been committed or pushed. The user-authored goal-file edit remains untouched and unstaged.
