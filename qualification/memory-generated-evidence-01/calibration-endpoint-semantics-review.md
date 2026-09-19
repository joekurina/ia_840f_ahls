# Calibration endpoint / sequence identity semantics

**Outcome: acceptance remains unresolved, but the missing evidence is now narrowed to exact generated table and IOSSM source references, not another generic memory-composition lookup. `ready_for_build=false`. No remap or physical/electrical equivalence is established.**

## Scope and notation

`F<n>:line` means decoded `memory-artifacts.json` `files[n].content`, not the JSON container line. `D` is `/home/joe/Projects/Thesis/AHLS/new_bsp/old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f`. Donor paths below are relative to D. `R` is this review's directory.

Read the requested installed-source/order reviews, next-evidence request, live04 disposition, live02/live04 receipts, and relevant generated payloads. Independently verified full payload byte counts and SHA-256 for all 87 captured memory payloads, eight live02 payloads, and five live04 payloads; no mismatch. Four exact donor files were read: `ipss/mem/qip/mem_ss/mem_ss_fm_0.qsys` and the `intf_0`, `intf_1`, and `emif_cal_location_bottom_row` IP files under `ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/`, each prefixed `mem_ss_fm_0_`.

This is bounded static local evidence inspection. No remote/installation access, Tcl/HDL/vendor execution, decryption, firmware disassembly, tests, build, generation, project load, source/pin/config changes or commits. Only the two named endpoint-review outputs are written. No claim of an exhaustive donor-tree search or absence of generated donor files elsewhere is made.

## 1. The endpoint's table originates at the controller boundary

The important direction is **controller → calibration IP** for the sequence table, while calibration read/write/address/write-data travel in the opposite direction.

* Donor `mem_ss_fm_0_intf_0.ip:3541–3548` declares `calbus_seq_param_tbl` as output with vector endpoints 0 and 4095. `mem_ss_fm_0_intf_1.ip:3463–3470` declares the same output shape.
* Donor bottom calibration IP `:320–327,416–423` declares `calbus_seq_param_tbl_0` and `_1` as inputs with that shape. Interface role-to-port mappings at `:70–73,147–150` associate the common role with each numbered port.
* Donor Qsys `:15632–15645` connects whole conduits bus0→intf1 and bus1→intf0, with empty start/end subport selectors. This is not merely a command-side reversal: the declared table role belongs to that same connection. This establishes saved graph intent, not a generated donor implementation trace.
* Generated EMIF0 F51:45–51,89–95 and EMIF1 F54:41–47,85–91 expose command inputs and `calbus_seq_param_tbl` as a 4096-bit output. F57:7–18,22–35 takes the two tables as calibration inputs and forwards each numbered interface unchanged into `...altera_emif_cal_280_kyo6ogi`.
* F61:315–328 pairs table0 and return-data0 with EMIF0, and table1 and return-data1 with EMIF1. F61:205–302 retains physical mem0/discrete and mem1/RDIMM association as documented in the prior order review.

Thus the new graph does **not** demonstrably send the other controller's sequence table to a controller's command endpoint. It changes the slot association of a complete endpoint/table pair. This excludes one simple crossed-table explanation; it does **not** prove that permuting complete pairs is legal.

## 2. New concrete evidence: actual per-controller sequence payloads are already captured

The leaf architecture metadata contains more than interface widths:

| Physical controller | Synthesized parameter | Simulation parameter | Hex characters / encoded bytes per value |
|---|---|---|---|
| EMIF0, discrete/P1 | F66:39160–39167 `SEQ_PT_SYN_CONTENT` | F66:39168–39175 `SEQ_PT_SIM_CONTENT` | 560 / 280 |
| EMIF1, RDIMM | F72:39036–39043 `SEQ_PT_SYN_CONTENT` | F72:39044–39051 `SEQ_PT_SIM_CONTENT` | 600 / 300 |

All four are marked derived and valid. The synthesized values differ between controllers and the simulation value differs from the synthesis value within each controller. These are actual captured hex strings, not reconstructed tables. Lengths and SHA-256 of the exact hex text are recorded in the companion JSON. In particular, a common 4096-bit port width is **not** evidence that both controllers have an identical parameter payload.

No captured field-layout declaration binds any byte of these strings to a physical controller number, bus slot, iopack ID or column ID. The values do not occupy the entire 4096-bit width as text-encoded bytes; do not guess padding, endianness, table placement, or infer a field from a small numeric prefix. The producer assignment of `SEQ_PT_SYN_CONTENT` into `calbus_seq_param_tbl`, including any padding/mode selection, lies below the captured wrapper. Names plus differing payloads are not a decoded identity contract.

Crucially, the generated QIPs point to **readable named sequence reports**, not just firmware blobs:

* F65:815 → `altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_arch_fm_191_ekzngaq_seq_params_synth.txt`.
* F71:815 → `altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra_seq_params_synth.txt`.
* Corresponding synth hex and simulation text are explicitly referenced at F65/F71:814,816, but are **not** requested initially: the named synthesis reports are the smaller useful first semantic edge. The `.txt` extension suggests a report, not a guarantee of field labels or content; existence and content are unverified.

The four donor saved files do not expose `SEQ_PT_SYN_CONTENT` or a field layout. Their QUARTUS_SYNTH file-set references alone are not literal filenames of generated implementations. Do not fabricate an old-version implementation path or claim current field meanings apply to 2.7.0 without evidence.

## 3. Global calibration identity is distinct from a slot's sequence payload

F78:480–488 names nested `altera_emif_cal_iossm` 2.8.0, entity `mem_ss_mem_ss_501_qm5zaka_emif_cal_bot_altera_emif_cal_iossm_280_th76pdq`. The same component exposes two table inputs at F78:873–876 and 957–960.

Its captured derived global fields include:

| Field | Value | Citation |
|---|---:|---|
| `SEQ_GPT_GLOBAL_PAR_VER` | 2 | F78:611–618 |
| `SEQ_GPT_NIOS_C_VER` | 1 | F78:619–626 |
| `SEQ_GPT_COLUMN_ID` | 1 | F78:627–634 |
| `SEQ_GPT_NUM_IOPACKS` | 16 | F78:635–642 |
| `SEQ_GPT_PARAM_TABLE_SIZE` | 1124 | F78:659–666 |
| `PORT_CALBUS_SEQ_PARAM_TBL_WIDTH` | 4096 | F78:755–762 |

These numbers belong to different named fields and must not be equated. In particular, 16 iopacks is not the two exposed calbus endpoints; column1 is not proven to mean board channel1; the table-size field has no established unit here. F77:52 gives an exact synthesized global-table text path, separate from the controller-local reports. F77:48 references code.hex, but firmware capture/disassembly is neither necessary for the first read nor authorized.

The installed FM routine's sequential endpoint allocation is already explained by `calibration-installed-source-review.md`; live04 only closes package/declaration gaps. Neither provides the IOSSM table multiplexer, physical-address decoder or sequencer scheduling contract. Re-reading editability declarations will not close this boundary.

## 4. Exact unresolved question and next bounded read

To accept the permutation, establish whether the consumer uses slot n solely to select that connected endpoint's own table and command/return bus, with physical destination supplied consistently by that endpoint/table, **or** imposes an additional absolute iopack/controller/order relationship on n. Also distinguish calibration scheduling order from physical target selection; showing a loop over slots does not by itself exclude a physical-order dependency inside the loop. Any cross-version dependency relevant to the donor remains part of the acceptance obligation.

Seven exact generated files are proposed in `calibration-endpoint-next-reads.json`:

1. The two synthesized controller sequence reports (F65/F71:815).
2. The synthesized global-table text (F77:52).
3. The calibration wrapper, IOSSM instance, architecture wrapper and consumer (F77:55,54,53,46).

All absolute paths are computed by joining the **recorded containing QIP directory** to its literal `$::quartus(qip_path)` relative reference; no QIP is sourced. None of these seven paths is a captured `original_path` in the 99-record memory receipt. This proves missing capture, not missing files on the workstation. No installed descriptor path is guessed and no remote existence check is performed.

Maximum seven exact files, 2 MiB per file, 8 MiB aggregate; no listing, recursion, globs, symlink traversal or newly discovered dependency capture. Stop explicitly on limits/missing/protected sources. The three text reports seek field meanings; the four consumer-chain files seek packing, slot decode and hard-IP selection. If these show a further producer or firmware/documentation dependency, report that exact edge for a separate review instead of widening this request. This is the smallest selected first batch covering both endpoint tables and the currently visible consumer chain, **not a promise of full semantic closure**.

## 5. Disposition

* **Established:** complete endpoint/table pairs changed slots; generated per-controller synthesized payloads are available and differ; the next table/consumer paths are literal generated-QIP references.
* **Not established:** whether calbus suffixes are physical hard-IP indices or scheduling/selection indices; permutation invariance; successful calibration; electrical failure; a supported remap; fitted grouping or complete OFS interface acceptance.
* Preserve AGFB027R25A2E2V, both 16 GiB channels, physical0 discrete/P1 and physical1 RDIMM, BOT/BOT membership, application identity topology and all pins. Do not exchange channels, alter `RUN_COMPOSE`, AXM ID, cardinality or diagnostic strings, or transplant donor automatic device metadata.
* `ready_for_build`, `calibration_order_accepted`, `generated_interface_accepted`, and `physical_equivalence_established` remain false. The JSON proposal does not authorize its own execution.

## Input bindings

| Receipt | SHA-256 | Verified full payloads |
|---|---|---:|
| `memory-artifacts.json` | `a333f976a8f95024b37ad918051b379c3922bd66b91e123e09fc575e95eb60ae` | 87 |
| `calibration-installed-live02.json` | `3b245eee4f7c3313a15aa4e363c488b2f08b869aa6931407fa091f202c994e22` | 8 |
| `calibration-installed-live04.json` | `08d9eb973fea98e051fa26ece58f653e8e9d72d25f2fa22ab5f0c5999670601a` | 5 |

| Donor source relative to D | SHA-256 |
|---|---|
| `ipss/mem/qip/mem_ss/mem_ss_fm_0.qsys` | `49ac14b0a1b6e1dd2cf419f4fe9033261f29c8e3b8a29b23fc697632049c083f` |
| `ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_intf_0.ip` | `fa915fa6ae8dad27275abc1e269189c9ece4ecc2aaf4bc8ef328ba3c359b4dde` |
| `ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_intf_1.ip` | `d6ee7d9c0220270a16231314a6c9e3182377a1001fd41e96e44d36b44117f743` |
| `ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/mem_ss_fm_0_emif_cal_location_bottom_row.ip` | `b4cc10cc9c9b8712438a5379ebea4f797afdbf84d55753459c1b36b273a1c42e` |
