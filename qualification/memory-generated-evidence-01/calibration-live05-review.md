# Live05 calibration endpoint semantics review

## Decision

**Complete endpoint/table pairing is established through the readable RTL up to `tennm_iossm`; compatible permutation of those pairs is NOT established.** The unresolved boundary is now the primitive/firmware interpretation of `SEQ_GPT_INTERFACE_PAR_PTRS`, especially entries `0x00000064` and `0x00010264`, together with primitive calbus destination selection. Neither a physical-index interpretation nor a slot-only interpretation is proven. No configuration correction is justified by this capture. `ready_for_build=false`.

This is static local analysis only. No remote access, vendor/Tcl/HDL execution, simulation, tests, firmware disassembly, decryption, source/configuration change or commit. Preserve AGFB027R25A2E2V, both 16 GiB channels, physical0 discrete/P1, physical1 RDIMM, BOT/BOT membership, application identity topology and pins. Only this review and `calibration-live05-disposition.json` are task outputs.

## Evidence notation and integrity

`L<n>:line` denotes the decoded full `files[n].content` in `calibration-endpoints-live05.json`; `F<n>:line` denotes the same indexing in `memory-artifacts.json`. These are payload line numbers, not JSON-container lines. The exact original paths and per-file hashes are recorded in the disposition JSON.

| Alias | File basename | Bytes | Lines |
|---|---|---:|---:|
| L0 | mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_arch_fm_191_ekzngaq_seq_params_synth.txt | 18924 | 218 |
| L1 | mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra_seq_params_synth.txt | 19419 | 223 |
| L2 | mem_ss_mem_ss_501_qm5zaka_emif_cal_bot_altera_emif_cal_iossm_280_th76pdq_synth_global_param_tbl.txt | 1830 | 30 |
| L3 | mem_ss_mem_ss_501_qm5zaka_emif_cal_bot_altera_emif_cal_280_kyo6ogi.v | 492875 | 172 |
| L4 | mem_ss_mem_ss_501_qm5zaka_emif_cal_bot_altera_emif_cal_iossm_280_th76pdq.sv | 14324 | 300 |
| L5 | mem_ss_mem_ss_501_qm5zaka_emif_cal_bot_altera_emif_cal_iossm_280_th76pdq_arch.sv | 28376 | 494 |
| L6 | altera_emif_cal_iossm.sv | 28319 | 494 |

The live05 receipt independently matches 609575 bytes and SHA-256 `1c2179d1adb8a3c16b03d30f9ac2e9034e1ab6fb2187075ceff74de1f3f8d956`. All seven decoded payload sizes and hashes match; receipt errors are empty. Each path matches its literal QIP reference: respectively F65:815, F71:815, F77:52,55,54,53,46, joined to the containing QIP directory without sourcing Tcl. The earlier receipt hash matches `a333f976a8f95024b37ad918051b379c3922bd66b91e123e09fc575e95eb60ae`. Reviewed `calibration-endpoint-semantics-review.md` and targeted earlier payload lines as cited below.

## 1. Local field reports: real labels, not an absolute channel identity

All three reports explicitly say they are informational and are not used during compilation or simulation (L0/L1/L2:1–2). They give named values and annotated layouts; they do not themselves implement serialization or decoding.

The complete report comparison finds five changed common lines, plus five additional RDIMM control words:

| Field | L0 | L1 | Citation |
|---|---:|---:|---|
| SEQ_PT_DIMM_TYPE | 0 | 2 | L0/L1:10 |
| SEQ_PT_READ_LATENCY | 23 | 26 | L0/L1:15 |
| SEQ_PT_WRITE_LATENCY | 14 | 17 | L0/L1:16 |
| SEQ_PT_NUM_LRDIMM_CFG | 0 | 5 | L0/L1:33 |
| SEQ_PT_NUM_MR | 7 | 12 | L0/L1:51 |

L1:219–223 additionally labels five `RDIMM CONTROL WORD` values. Do not reinterpret the field name `NUM_LRDIMM_CFG` as proof that physical1 is an LRDIMM; the preserved channel identity is RDIMM and the report explicitly labels its added words as RDIMM words.

The field-layout evidence is now concrete:

* L0/L1:53–69: `SEQ_PT_TILE_ID_PTR=196 (0x00C4)`; tile entries 12,4,20 annotated `(T)=(1),(0),(2)`; AC lanes annotated `(1,0),(1,1),(1,2)`; data lanes annotated `(1,3),(0,0),(0,1),(0,2),(0,3),(2,0),(2,1),(2,2)`.
* L0/L1:70–210: `SEQ_PT_PIN_ADDR_PTR=212 (0x00D4)` and explicit `(T L P)`/AC-or-data-lane annotations for memory pins. For example DQ0 is annotated `(0 0 0)` with `DATA_LANE[1]`, while DQ32 is `(1 3 0)` with `DATA_LANE[0]` (147,179).
* L0/L1:211–218: `SEQ_PT_MR_PTR=352 (0x0160)` and the same seven MR values.

The complete mapping segment L0/L1:53–211 is text-identical. Thus these particular tile/lane/pin annotations cannot distinguish physical channel0 from physical channel1 by themselves. They do NOT prove that both controllers occupy the same absolute device resources, or that either controller may be moved electrically. No field in these reports explicitly declares a board-channel number or a calbus slot number. The coordinate reference frame still requires a consumer contract.

Earlier F66:39160–39167 and F72:39036–39043 contain the differing `SEQ_PT_SYN_CONTENT` strings. The new reports explain named parameter differences, but this batch contains no controller-side assignment packing those strings into the 4096-bit `calbus_seq_param_tbl` output. Do not infer byte order, padding, relocation, or absolute addresses from report prefixes. In particular the reports show local header addresses starting at `0x7419`, while the global report starts at `0x7400`; treating all printed addresses as one directly concatenated address map would be an unsupported assumption.

## 2. Readable table-to-consumer trace

1. **Physical wrapper association remains unchanged.** F61:205–248 maps EMIF0 memory pins to mem0 and commands to slot0, with its own return-data/table outputs. F61:261–302 does the analogous mem1/EMIF1/slot1 wiring. F61:315–328 connects the calibration endpoint inputs to those same controller outputs. The prior review documents the donor's reversed whole-conduit association; nothing here introduces a crossed table/command connection.
2. **Calibration wrapper forwards complete numbered groups.** L3:25–51 instantiates the IOSSM wrapper with `NUM_CALBUS_USED=2`, `USE_SYNTH_FOR_SIM=0`, `USE_SOFT_NIOS=0`, `SEQ_GPT_COLUMN_ID=1`, `SEQ_GPT_NUM_IOPACKS=16`, `SEQ_GPT_PARAM_TABLE_SIZE=1124` and a 4096-bit table width. L3:53–64 passes commands, return data and tables suffix-for-suffix. L3:76–159 terminates unused slot outputs and ties unused return-data/table inputs to zero.
3. **IOSSM instance preserves the pairing.** L4:150–180 forwards parameters into the generated architecture, fixes `SEQ_USE_SIM_PARAMS="off"`, and supplies named firmware/simulation-GPT/synthesis-GPT hex filenames. L4:192–203 passes slot0 and slot1 groups unchanged.
4. **Architecture packs an array, not a decoded local field layout.** L5:235–236 declares packed arrays indexed `[15:0]`. L5:291–294 assigns `calbus_rdata_i[0/1]` and `calbus_seq_param_tbl_i[0/1]` from the corresponding numbered ports, enabled by `NUM_CALBUS_USED > n`. L5:295–322 gates the other entries to zero for this two-endpoint instance. There is no swapping, slicing, byte reversal or extraction of TILE/PIN fields in these assignments.
5. **The actual visible consumer is a primitive boundary.** L5:324–340 instantiates `tennm_iossm io_ssm`; L5:355–367 sends paired return-data/table entries to primitive `calbus_rdata_0/1` and `calbus_param_tbl_0/1`, while the matching primitive command outputs directly drive `calbus_read/write/address/wdata_0/1`. The body of `tennm_iossm` is not one of these seven files. Neither a table-selection multiplexer nor the internal command destination decoder nor the firmware scheduling/relocation logic is exposed here.
6. **L6 does not add a deeper implementation.** A full line comparison shows L5 and L6 differ only in the module declaration at line15; the rest, including the primitive instantiation and wiring, is identical. The name `altera_emif_cal_iossm.sv` must not be mistaken for an implementation of the primitive's internals.

This proves paired transport up to matching primitive ports. It does not prove that the primitive consumes table n solely for command n, nor that n has no additional fixed physical meaning.

The synthesis GPT filename is selected by L5:214–219 under the actual L3/L4 parameter values and reaches `tennm_iossm.parameter_table_hex_file` at L5:334. Firmware reaches `nios_calibration_code_hex_file` at L5:338. Global version, column, iopack count and table size pass as distinct primitive parameters at L5:325–329. The `.txt` report is not the connected initialization artifact; its corresponding `.hex` literal reference is F77:51. Matching the report to the actual initialized words and their decoded meanings remains distinct from matching the filename.

## 3. Particular unresolved field and exact remaining proof

L2:14–30 labels a 16-element `SEQ_GPT_INTERFACE_PAR_PTRS` array:

* element0 at printed address `0x7424`: `100 / 0x00000064`;
* element1 at `0x7428`: `66148 / 0x00010264`;
* elements2–15: zero.

L2:7–10 separately gives column1, 16 iopacks and table size1124. Neither the report nor L3–L6 defines the pointer-word bit allocation. In particular **do not label `0x00010264` as physical interface1, a slot1 tag, a packed high-half selector plus offset, or a flat pointer without an actual declaration/decoder**. Its numeric appearance is not evidence of any of these meanings. Likewise, the two populated entries matching the two connected slots is consistent with paired selection but does not establish it.

The precise missing semantic evidence is:

1. An authoritative definition plus producer/consumer interpretation of `SEQ_GPT_INTERFACE_PAR_PTRS` for this generated IOSSM version: field widths, units, offsets/relocation, selector meaning, and how entries bind `calbus_param_tbl_n` to `calbus_*_n`.
2. The `tennm_iossm` command/table-selection contract and its firmware use, resolving whether slot n is only a paired transport index or also an absolute iopack/controller/physical-order identity. Include how the local TILE/PIN coordinates are interpreted with the selected endpoint and global `col_id`, and any order-dependent scheduling constraint.
3. For a full byte-level trace, the exact controller producer assignment from `SEQ_PT_SYN_CONTENT` to its port and the synthesis GPT initialization words referenced at F77:51. These can close representation edges but, by themselves, cannot replace the primitive/firmware identity contract.
4. If donor compatibility is claimed rather than merely current-graph consistency, evidence that the relevant contract applies across the donor calibration version and this version; unchanged wrapper suffixes do not prove cross-version equivalence.

The exact new dependency edge is **L5/L6:324–367 → `tennm_iossm io_ssm`**, plus its named firmware parameter at L4:178/L5:338 (QIP reference F77:48). No primitive source path is invented and no generic recursive scan is requested. This review does not authorize firmware capture/disassembly or any additional acquisition. A version-specific vendor definition of the above contract can be useful without disassembly. If the implementation is protected, stop at that boundary and seek the documented contract; do not decrypt it.

No encrypted implementation block was encountered in the seven files. L5/L6:492–494 contain a Questa OEM pragma after the readable module ends; it was not decoded. L3's unusually large size comes from long padded lines and explicit zero constants, not an encrypted body. The missing primitive implementation must not be reported as proven encrypted merely because it is absent.

## 4. Acceptance and change disposition

* **Established source evidence:** paired endpoint/table wiring through every readable wrapper to corresponding primitive ports, exact field report differences, same local tile/lane/pin annotations, and the actual synthesis GPT/firmware parameter edges.
* **Unresolved source semantics:** absolute-versus-paired meaning inside `tennm_iossm` and `SEQ_GPT_INTERFACE_PAR_PTRS`. Therefore compatible pairing/permutation is not accepted, although no crossed pair is observed in readable RTL.
* **Functional acceptance:** not assessed. No calibration success/failure, electrical equivalence, fitted resource placement or complete generated OFS interface acceptance follows from this static review.
* **Correction proposal:** none. There is no defensible source-proven reason to swap slots, change column/iopack/table-size metadata, edit pointers, exchange physical channels, alter capacity, change AXM IDs/RUN_COMPOSE, or transplant donor automatic metadata.
* `ready_for_build`, `calibration_order_accepted`, `generated_interface_accepted`, `physical_equivalence_established`, and `calibration_functionally_accepted` remain false. Further proof is a prerequisite to accepting the semantic claim, not an authorization for a build or experiment.
