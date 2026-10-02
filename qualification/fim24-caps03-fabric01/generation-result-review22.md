# Migrated CAPS03 fabric — independent generation review22

**Verdict: ACCEPT WITH FINDINGS for completed generation and offline simulation preparation.** No blocking defect found in the reviewed native outcome, exported ABIs, selected controls or project delta. This does not accept functional equivalence, simulation, persona implementation, timing or hardware.

Reviewer: GPT-6 (`gpt-6-astra-900k`, `openai-codex`), substituted for unavailable GLM5.3. Local reads and in-memory hash/XML/HDL/data analysis only; no prepared scripts/tests, Tcl/native tools, SSH, Git or hardware executed. Only this report is authored. Paths are relative here; `G/` means `completion17-readback/generated/`, `O/` means `completion17-readback/operation/`.

## Binding and native outcome

- Rehashed **324/324** freeze members with exact lengths; no missing/mismatched entries. `actual-result-freeze21.json` SHA256: `7c4e96762ad9f07e57feefce0f4cb99666abedcdb33cd73f115cbcaa17cbe910`. The compressed completion17 capture matches its collection receipt; all **301** decoded readbacks match, comprising **294** generated/input-metadata members and seven operation files. Admission digest, runner/CMake identities and review06/review13 consumption bindings reconcile.
- `O/result.json`, `O/status.json` and the four hash-bound logs establish one configure/version/import/generate sequence under **26.1.1 Build 130**, targeting **AGFB027R25A2E2V / Agilex 7**. All CMake/effective codes are zero; direct vendor targets propagate zero. `native15-completion-event.json` independently records outer zero; `execution_clean=true`, diagnostics/postflight errors empty, owned groups drained. No Warning/Error/Fatal/exception/rejection mentions were found in operation logs or generation reports; child deployment XML messages are all Info.
- All **155** emitted HLS files match admitted corrected hashes and `hls-generated-binding20.json`; no HLS resynthesis occurred. Both Tcl scripts match admission. Bound postflight records preservation of the original/corrected report trees, tools/helpers/control files and accepted Work24 release; these are captured observations, not fresh remote measurements.

## Actual interfaces and wrapper ABI

Independently parsed both generated wrappers, both SOPCINFOs and the saved child IP. Each wrapper has **245** unique ports across **11** interfaces, exactly matching `port-ledger19.json` in every name, direction and width. Included the final comma-less `bank_out1_ruser` declaration. Child-IP logical/physical role maps and all model ports agree. Decoded prior wrappers from `../caps02-fabric-fullwidth01/fullgen01-result.json`, verified their hashes against the ledger and `fullsim05-result.json` inputs, and compared complete ABIs: identical, without asserting internal equivalence.

| Actual interface | Ports | Boundary contract |
|---|---:|---|
| `clock_reset` | 1 | Input clock |
| `clock_reset_reset` | 1 | Input active-low reset; DEASSERT metadata |
| `freeze` | 1 | Input conduit |
| `device_exception_bus` | 1 | Output, 64 bits |
| `kernel_irqs` | 1 | Output interrupt |
| `mmio_control` | 33 | AXI4 slave; data/address/ID 64/20/16 |
| `dma_csr` | 31 | AXI4 master; data/address/ID 64/16/18 |
| `dma_ddr_in0` | 44 | AXI4 slave; data/address/ID 512/34/9 |
| `dma_ddr_in1` | 44 | AXI4 slave; data/address/ID 512/34/9 |
| `bank_out0` | 44 | AXI4 master; data/address/ID 512/34/18 |
| `bank_out1` | 44 | AXI4 master; data/address/ID 512/34/18 |

The sole saved child IP has the same import/post-generation digest, with `altera_has_errors=false`; its actual `altera_has_warnings` is also false. Nonempty footprints and role-width comparisons, not success banners alone, close the earlier empty-footprint/API-error concern.

## Geometry and response controls

`G/ia840f_ahls_memory_fabric_dma_fullwidth_hw.tcl` differs from baseline only by AXI bridge **19.9.3 → 19.10.3**. All four 69-parameter source maps remain unchanged. Generated composition RTL instantiates six AXI bridges of the selected version; all 59 source parameters represented as HDL overrides per instance match. Actual SOPCINFO retains acceptance/issuing limits 1 for control and 64 for memory.

Both banks retain 512-bit data, 34-bit byte addresses, 64-bit strobes, two-bit USER fields, entry IDs 9 and internal bank-output IDs 18. Both AXI response channels remain: BRESP/RRESP widths 2, correct direction/handshakes, and `USE_M0_BRESP`, `USE_S0_BRESP`, `USE_M0_RRESP`, `USE_S0_RRESP` all 1. AXI_VERSION remains AXI4; ACE, untranslated, atomic, cache-stashing and role-based-user selections remain disabled. Internal `ENABLE_AXI5=1` is not protocol selection. Vendor26 descriptor:1968–1984 confirms both new READ_ONLY/WRITE_ONLY defaults 1 **enable** their channels; no corrective override is warranted.

The two Avalon 20.1.0 full-width stages remain **HLS-only**; DMA paths remain direct to the corresponding bank interconnect. Source retains SYMBOLS/8-bit symbols, burst/read-pending/write-pending limits 64, both response enables and zero waitrequest allowances. Generated stages confirm 512/34 geometry, seven-bit burstcount, response/write-response wiring and command/response pipelines. Native logs explicitly retain 256→512 HLS adaptation. Clock/reset, IRQ, freeze and exception exports remain connected; MMIO DMA base zero/HLS base `0x10000` remains the source routing contract. These are generated structures/envelopes, not behavioral proof.

## Exact project delta

Recomputed `native-project-delta21.json` against actual before/after bytes. QPF is unchanged. QSF preserves all four initial family/device/top/NUM36 lines and appends **only**:

```tcl
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
set_global_assignment -name LAST_QUARTUS_VERSION "26.1.1 Pro Edition"
set_global_assignment -name IP_FILE ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric.ip
set_global_assignment -name QSYS_FILE ahls_memory_dma_fabric.qsys
```

No conflicting assignments or additional changes. These are project metadata, not physical voltage/timing qualification.

## Findings and remaining boundary

1. **Nonblocking observability limit:** the first ordinary snapshot followed completion; no live Java PID/executable/ancestry witness was captured. Retained CMake identities, fixed commands, logs and artifacts support this completed run; do not replay it to obtain a missing witness.
2. Parallel generation was enabled and reported an **attempt at two processors** for two IPs. The 36-CPU affinity and 64 GiB per-process limit are neither actual-worker nor aggregate-memory claims. Retained interface/helper `deviceFamily=UNKNOWN` does not contradict actual target metadata by itself.
3. Both QIPs independently resolve **265 assignments / 264 distinct captured targets**, all rehashed, corroborating closure18. Deep compile/library/order review and fresh **matching-PIM integrated simulation** remain separate obligations. Preserve active size/alignment, masks, responses/backpressure, arbitration/ID and completion checks. Exported freeze/exception ports do not prove quiescence or error detection. No DDR-vendor-internal/calibration requalification, persona/timing acceptance or hardware authority is introduced.
