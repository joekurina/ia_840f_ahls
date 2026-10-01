# Work22 — narrow PIM user-type review42

## Disposition

**Native evidence rules out the simple interpretation that the selected TX sink was synthesized with a scalar, one-bit `user`. It supports a frontend/type-resolution diagnostic, not a demonstrated PCIe metadata defect. It does not prove the more specific claim that Warning16803 was emitted only against an unspecialized default type.**

The useful new evidence is not just the type-name string: the actual exit-skid specialization has a **580-bit payload**, and synthesis explicitly represents the expected **SOP bit513** in its register-merging results. Its metadata reductions match the corresponding Work21 reductions. Therefore neither “inactive branch” nor “all six field assignments were necessarily discarded” is supported. Conversely, unchanged source, successful synthesis and these selected mapping rows are not independent proof of all three 26.1.1 driver equations.

Under **ordinary compiler semantic trust**, the correctly specialized source, actual width and selected native mappings support keeping the unchanged full-fit attempt running; no source repair, suppression or tie-off follows from this warning. If a categorical warning closure is required, the remaining discriminator is a **single narrow native SOP-driver/consumer readback**, specified below—not another broad review, unchanged build, simulator campaign or hardware probe. The later memory persona must be assessed in its own parameterization.

Scope: bounded local read-only source/report/Git/Python analysis. No SSH, workstation/device operations, vendor tools, tests, source edits or Git mutation. Only this report was written. Reviewer: **gpt-6-astra-900k / openai-codex**; no GLM5.3 review is claimed.

## Evidence notation and binding

All paths are relative to repository `/home/joe/Projects/Thesis/AHLS/new_bsp/new` unless stated otherwise.

- **S22**: `qualification/fim-build-22/synthesis38-readback/ofs_top.syn.rpt`.
- **S21**: `qualification/fim-build-21/synthesis-capture01/ofs_top.syn.rpt`.
- **S03**: `qualification/caps03-persona01/synth01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.syn.rpt`.
- **P**: `qualification/caps01-dma-burst01/diagnosis09/platform/ofs_plat_if/rtl/`. These older captured bytes are used only after exact Work22 compile-input matching.
- **G**: `P/ifc_classes/host_chan/prims/gasket_pcie_ss/`.
- **F**: `ofs-agx7-pcie-attach/`.
- **A**: `qualification/ahls-afu-fim-01/src/ofs_plat_afu.sv`.

The maintained PIM HEAD is `3c21189e728009d4c492fa2be54c0ab1008b06dc`. The ten PIM files listed in the appendix were rehashed and matched separately against the actual AFU-side keys in **Work22 `compile-inputs31.json`**, **Work21 `prepared-readback01/compile-candidate-01/compile-authorization.draft.json` → `work_inventory`**, and **CAPS03 `synth01-configuration-metadata.json` → `persona_inventory`**. Duplicate `pim_template` entries were not substituted for the selected AFU entries. The interface/primitive files also match the maintained PIM files.

References below use original native/source line numbers. Full reports were filtered locally, not dumped or regenerated.

## 1. What is actually declared and connected

`P/base_ifcs/axi/ofs_plat_axi_stream_if.sv:10–26,34–45` declares:

```systemverilog
parameter type TDATA_TYPE,
parameter type TUSER_TYPE,
...
typedef struct packed {
    logic last;
    t_keep keep;
    TUSER_TYPE user;
    TDATA_TYPE data;
} t_payload;
```

**There is no explicit `TUSER_TYPE = logic` default in this source.** The scalar `logic` mentioned by the warning must not be presented as a discovered explicit interface default. A temporary frontend/default-type interpretation is plausible, but its origin is not established by the retained reports.

Exact producer/receiver chain:

1. `G/ofs_plat_host_chan_align_tx_tlps.sv:15–20` has generic interface modport formals: `stream_sink` is `to_sink`; header/data inputs are `to_source`. The interface's `to_sink` drives `t` and `tvalid`; `to_source` receives them (`ofs_plat_axi_stream_if.sv:54–65,99–110`). Generic formals do not replace connected instance specializations.
2. `align_tx_tlps.sv:47–59` explicitly specializes **header** and **data** input-register interfaces with `TUSER_TYPE(logic)`. This is intentional: header user is the single PU/DM flag, data user is unused. The RHS `hdr_source.t.user` at line205 is legitimately scalar; it is not the indexed LHS.
3. The **indexed LHS** is local `sink_skid`, explicitly specialized at `:80–85` with `t_ofs_fim_axis_pcie_tuser`. Package `G/ofs_plat_host_chan_fim_gasket_pkg.sv:156–163` defines a packed `{dm_mode,sop,eop}` struct and a packed `[NUM_OF_SEG-1:0]` array of that struct. Even `NUM_OF_SEG=1` is an array of one three-bit struct, not scalar logic.
4. `G/ofs_plat_host_chan_fim_gasket.sv:78–90,149–182` specializes `fim_tx_a_st` with that same array type, specializes header/data users as scalar logic, and connects them to `align_tx` in exactly those roles.
5. `align_tx_tlps.sv:310–314` passes `sink_skid` to `ofs_plat_axi_stream_if_skid_sink_clk`. Its source formal is `to_source_clk`, sink formal is `to_sink`; it copies clocks/reset backwards and carries the **whole packed payload**, with `N_DATA_BITS=stream_source.T_PAYLOAD_WIDTH` (`P/base_ifcs/axi/prims/ofs_plat_axi_stream_if_skid.sv:42–73`). There is no field cast/narrowing here. Parameter-match assertions are under `translate_off`; they are not synthesis checks.
6. `P/utils/prims/ofs_plat_prim_ready_enable_skid.sv:33–49` forwards those bits through FIFO2. `ofs_plat_prim_fifo2.sv:68–87,115–145` preserves bit positions in its two `data[0:1]` entries; `first=data[1]`.

The six warnings are precisely the two assignments to each member in the active `seg1` branch, source lines **205–207 and224–226**. This branch is selected when data exceeds one header and the segment count is one (`align_tx_tlps.sv:94`). Its source equations before the skid are:

```text
dm_mode = hdr_source.tready ? hdr_source.t.user : 0
sop     = hdr_source.tready
eop     = sink_skid.t.last
```

These are source-derived equations, not an executed simulation or recovered native Boolean expression.

## 2. What 26.1.1 actually elaborated/mapped

| Native observation | Evidence | Consequence / limitation |
|---|---|---|
| Six Warning16803 records at the exact six sites | S22:129675–129680 | Not six independent instances. S22:123109–123115 is the table representation, not extra warnings. |
| Warning block follows `Elaborating from top-level entity "top"` | S22:129415 | The log does **not** explicitly label these as a discarded/default-only analysis pass. Do not assert that phase attribution as proven. |
| `sink_skid.TUSER_TYPE` is the array typedef; header/data user types are `logic` | S22:73540–73558 | Correct requested specialization, not by itself bit-driver evidence. |
| Actual exit-skid `N_DATA_BITS=580`, with `align_tx|exit_skid|skid` in **All Instances** | S22:74401–74411 | Stronger than the type-name string: 512 data + 3 user + 64 keep + 1 last. A scalar-user payload would be578. |
| Header/data register payload widths290/578 | S22:75382–75402 | Consistent with256-bit header /512-bit data, each with a single user bit. |
| `seg1.prev_data` has actual merge/constant reductions | S22:114793,115053 | The warned branch is not dismissible as inactive. |

From the bound packed declaration and native580-bit width, the exit FIFO positions are:

| Field | Packed bit(s) |
|---|---:|
| data | 511:0 |
| user[0].eop | 512 |
| user[0].sop | 513 |
| user[0].dm_mode | 514 |
| keep | 578:515 |
| last | 579 |

The mapping panel then provides **member-position evidence**:

- **DM input:** `align_tx|hdr_entry_reg|r|data_to_dst[256]` is included in a GND reduction (`S22:114688`). This is the header's user bit, immediately above its256 data bits.
- **DM output:** `align_tx|exit_skid|skid|f|f|data[0..1][514]` is GND due to stuck `data_in` (`S22:114992`). With a zero incoming PU/DM bit and a zero non-SOP assignment, this is source-consistent. It cannot test the missing `dm_mode=1` case.
- **SOP:** FIFO `data[0][513]` merges into `data[0][51]`; `data[1][51]` and `data[1][174]` merge into **`data[1][513]`** (`S22:115375–115378`). The latter is an explicitly named native representative, not an assumed absent or grounded bit. This contradicts a blanket diagnosis that synthesis lost the entire user structure or necessarily ignored every field write. A merge row does not supply that representative's full driver equation or consumer equation.
- **External DM corroboration:** the named TX-A pipeline's `s_tuser_reg[0..8]` is GND (`S22:114634`). This includes PU/DM bit0. **It does not include bit9; it is not evidence that every outgoing user bit is constant.**

The report establishes successful26.1.1 synthesis, not full-fit acceptance (`S22:131493`). The81-warning footer does not erase these six frontend records or replace review39's complete495-record accounting.

## 3. Which metadata could matter

The direct receiver is `G/map_fim_pcie_ss_to_pim_axi_stream.sv`, connected by `fim_gasket.sv:122–133`:

- `:59`: outgoing `tuser_vendor[0] = pim_tx_a_st.t.user[0].dm_mode`.
- `:64–67`: outgoing store/interrupt-commit request is `sop && (is_mwr(header) || is_interrupt(header))`.
- `:46`: outgoing `tlast` comes from **`t.last`**, not `user[0].eop`.
- The direct TX-A receiver has only the two user-member reads above; no TX-A `eop` read. The separate logging macro is inside `translate_off` (`fim_gasket.sv:135–140`). Thus the warned EOP copy is not this selected path's PCIe `tlast` driver.

The store-commit feature is explicitly present in bound `F/ofs-common/src/common/includes/ofs_pcie_ss_cfg.vh:25–26`. Its index is `TUSER_WIDTH-1` (`ofs_pcie_ss_cfg_pkg.sv:31–40,61`); native USER_W10 makes this **bit9** (`S22:25634–25635`). Incorrect SOP could therefore lose or mis-tag commit requests in a configuration issuing stores/interrupts. Incorrect DM could misinterpret a DM-encoded header. These are concrete **conditional consequences**, not observed Work22 failures.

**Current Work22 is the scalar base AFU:** native `qual_vec_op_report_di` at `S22:114241`, matching A. A:139–155 idles host-memory requests and both local-memory request ports. Its incoming DM bit is actually reduced to zero as above; completion headers keep the default PU flag (`fim_gasket.sv:383–408`). The source permits DM1 for IRQ/DM-write branches, so the zero result here must not be generalized to every future AFU. Nor should active MMIO-completion TX be called wholly idle merely because DMA requests are idle.

For this selected path, EOP's duplicate is not an external framing dependency; DM0 is source/native-consistent; **SOP and its commit-bit consumer are the only remaining potentially consequential dynamic member/consumer pair needing a more explicit native witness if the warning is to be categorically closed.**

## 4. Matching qualified older reports

| Observation | Work22 /26.1.1 | Work21 /25.1.0 | CAPS03 /25.1.0 |
|---|---|---|---|
| Native Warning16803 message count | 6 | **0** | **0** |
| Correct sink user typedef | S22:73555 | S21:73553 | S03:13692 |
| Exit-skid payload580 and explicit instance membership | S22:74405,74408 | S21:74403,74406 | S03:15445,15449 |
| Incoming header-user bit256 GND | S22:114688 | S21:114637 | S03:40443 |
| Exit-skid DM bit514 GND | S22:114992 | S21:115588 | S03:42337 |
| Same SOP/bit51/bit174 alias relationships | S22:115375–115378 | S21:115972–115975 | Not claimed |

Zero16803 was also checked in both older `.syn.ae.rpt` files, including absence of the `can't index into non-array` message. **There is no matching old Warning16803 to use as an inherited-warning waiver.** The same bound RTL produced this new diagnostic under26.1.1; the compared type/width and selected reductions remain consistent.

Work21 is the closer scalar/Avalon comparator. CAPS03 uses `primary_axi|e|impl|tlp_as_axi_mem`, not Work22's `ahls_binding|board|primary_avalon|impl|tlp_as_avalon_mem`; its memory-persona traffic cannot be transplanted into this build's acceptance. Even CAPS03's observed header-user/DM output is zero, so it supplies no DM1 mapping witness. Older result acceptance is bounded (`fim-build-21/RESULT-ACCEPTANCE.md`, `caps03-persona01/SYNTHESIS-ACCEPTANCE02.md`), not proof of hardware operation or26.1.1 bitmapping.

## 5. Smallest missing offline discriminator

**First choice: one source-correlated native readback of the completed Work22 synthesized snapshot, on a separate preserved copy—not the running full-fit tree.** Use a supported same-release elaborated/technology-map view to inspect only:

1. the `align_tx` exit-skid **SOP input bit513** and its output representative `align_tx|exit_skid|skid|f|f|data[1][513]` (slot0 alias `data[0][51]`), accounting for the existing two-entry FIFO;
2. its actual fanout/equation at outgoing TX-A **store-commit bit9**, qualified by valid transfers and the decoded write/interrupt predicate.

The distinguishing observation is that SOP is generated from `hdr_source.tready` and reaches the commit predicate with the payload, or is eliminated only through a source-justified current-persona constant/unused consumer. An unexpected constant, wrong field position or different valid-transfer equation would establish a concrete metadata defect. **A nonempty fanout/name list alone is not that discriminator.** The current capture has selected constants/aliases, not this equation readback.

This is the minimum remaining functional discriminator for the current warning. It need not re-prove DM0, require preservation of unused EOP, check the entire PCIe protocol, run full sequential equivalence, or introduce a new simulation framework. Command/API details are intentionally not invented: no vendor API was queried in this local-only review. If this view is unavailable, record that exact acquisition gap; do not replace it with guessed atom properties or a hardware probe.

A successful scoped mapping readback can close the **functional warning consequence** under ordinary compiler trust without proving the compiler's internal reason for issuing16803. A claim specifically about an unspecialized-default frontend pass would still require a phase-specific compiler diagnostic/explanation. Neither uncertainty justifies altering live source. Reassess dynamic SOP/DM use when the separately built CAPS03-derived persona actually changes those reachable inputs; do not use scalar constants as its proof.

## Binding appendix

Rehashed full native reports:

| Artifact | Bytes | SHA256 |
|---|---:|---|
| S22 | 54688090 | `d8c3f269cdf7fe5397ec109aa6d8c41e88145114028d0222db3deb95910f5478` |
| S21 | 56378370 | `0b41ed02e5b63ec4bff9eef506dd71100eaa3893ce794c4ff532082fef1c00dc` |
| S03 | 55852682 | `85277d3df84f215d3d66c0104dbf1688af009ff705f9876dbc422393917b3149` |

Input inventories: Work22 `17cc563665ea726b2ed48115a3fc6572a8fd795e3a596dc2efe47294b98214ca`; Work21 draft inventory `a27d5a15ecaea909eea081e7c0ab52956db6cd91e0a6202f2fb712c4b1dad09e`; CAPS03 configuration `f5f776ddffbcd4276fa8493fb51d6adfc1ffd19ecfeca625a8747aba501bb6cb`.

The ten matched PIM files (under P, with directory roles as cited above):

| File | SHA256 |
|---|---|
| `ofs_plat_axi_stream_if.sv` | `22c3b8d98a24d959af2e75166deaa2dc52a15af1ba0978952b410ff2d4c7e090` |
| `ofs_plat_axi_stream_if_reg.sv` | `9b3c560e917c92b9fca3229775235fa196157d9954d9dd52d168aee48f159a4b` |
| `ofs_plat_axi_stream_if_skid.sv` | `0786f4a8672bbc97384d4cd832d6bd65b47b6b8a1890446386ae64fe3ed11796` |
| `ofs_plat_prim_ready_enable_reg.sv` | `e1b885dffdee06a103fdeafb7c6e787ed46d09d4c2ca929f8f612da550a9ccd1` |
| `ofs_plat_prim_ready_enable_skid.sv` | `eec7055210b0f2caee2946400bfe79272d1abff01f34296b8bb984e9524f3701` |
| `ofs_plat_prim_fifo2.sv` | `312a7926c83d3a1fd233dae9710c86eb5c61e805f164577f35564c673c4c24ca` |
| `ofs_plat_host_chan_align_tx_tlps.sv` | `376279e0e5dcd40419a5c9f6b10265c0679334c773a565b9051a48595c3c85df` |
| `ofs_plat_host_chan_fim_gasket_pkg.sv` | `3b1cb8801314f84618fe32076f8e6938fd60ed336f40efc0bddda7e755eb09b8` |
| `ofs_plat_host_chan_fim_gasket.sv` | `00054bfee9e76aa40711ace49a22a5b5151a11e139ae1e5a7a2d272bb89a8b00` |
| `map_fim_pcie_ss_to_pim_axi_stream.sv` | `42bba370e7ed97cf84bd8e0b141765869ef88eab71fdce9019f82d3bdd7ef65c` |

Additional cited Work22 source matches: A `3638a59ec7d811c16d9d1e738ca57b606ee3cb9b8cc5bdb15b75ce965c8f12fb`; F/common `ofs_pcie_ss_cfg_pkg.sv` `3b8143d68cb60c8ff24832edbb931c5d4a751362cca066d20214b880115a5d20`; `ofs_pcie_ss_cfg.vh` `e454354d1c003aea5f30924f75ec8a1441682d6264727da4325bfa4d73c0aebb`.
