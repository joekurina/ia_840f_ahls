# PIM local-memory USER source review

**Static source evidence only; ABI acceptance and build readiness remain false.** No source, manifests, gates, calibration reports, or other existing reports changed. No remote/vendor/HDL/test execution, source imports, Tcl evaluation, or generated headers fabricated. This review owns only this file and `pim-user-next-reads.json`.

## Evidence notation and checks

`F<n>:<line>` means zero-based `files[n].content` in `memory-artifacts.json`, not a local generated file. Read `generated-memory-review.md` and the requested captured sources F9/F10/F18/F37–F50; additionally inspected the MSA wrappers and QIPs F59/F60/F81/F83. Recomputed byte counts and SHA-256 for all 17 full-text records in that selection; four requested wrong-path records have no content. Verified identical generated pairs F37/F44, F38/F45, F39/F46, F40/F47, F43/F50. Receipt hash and local source bindings are in the companion JSON.

Local citations below are relative to:

`P = /home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if`

`L = P/src/rtl/ifc_classes/local_mem`

These are **pinned library source/templates**, not proof of the uncaptured generated implementations. F18's package hash matches the local package exactly.

## 1. USER is not a single command ABI

- **PIM flag:** F18:13–25 / `L/afu_ifcs/axi/ofs_plat_local_mem_axi_mem_pkg.sv` defines `LM_AXI_UFLAG_NO_REPLY = 0`, a **bit index**, and `LM_AXI_UFLAG_WIDTH = 1`. It describes burst-splitting bookkeeping, not an MSA opcode or a directive for the memory hardware to omit responses.
- **Field organization:** captured generated cfg F39/F46:38–41 describes `{ AFU user bits, FIM user bits, PIM user bits }` and adds the PIM flag width to `OFS_PLAT_PARAM_LOCAL_MEM_USER_WIDTH`. This documents intended organization; it is not evidence that the active gasket shifts those fields into an MSA command layout.
- **Single PIM width versus per-channel raw widths:** `P/src/rtl/base_ifcs/axi/ofs_plat_axi_mem_if.sv:101–184` uses one `t_user` width for AW/W/B/AR/R. Its response comments specify B returning AW USER and R returning AR USER by convention. Raw MSA instead has AWUSER/ARUSER **14**, BUSER **1**, and no WUSER/RUSER ports (F59/F60:11–50). F59:94–104 disables W/R USER despite retained width parameters; :164–165 ties the internal WUSER input to zero and leaves RUSER unconnected. Disabled parameter widths are not external ports.

### NO_REPLY request/response trace

`P/src/rtl/base_ifcs/axi/prims/ofs_plat_axi_mem_if_map_bursts.sv:36–81` either directly connects compatible burst widths or inserts the burst mapper and WLAST repair. In the splitting implementation:

- :182–186 marks generated AR sub-bursts using `!rd_complete || original_flag`.
- :206–220 **preserves read-data validity**, but masks intermediate `R.last`. It does not discard the R data beats.
- :278–281 marks generated AW sub-bursts similarly.
- :316–323 suppresses intermediate B-valid using the returned flag.

Thus the package comment about squashing R/B responses needs this precise implementation qualification: read burst-end tags are suppressed, write responses are filtered. These operations require the PIM request flag to survive until the PIM response path, not necessarily through the device's own USER signals.

## 2. The existing native-AXI adapter already preserves metadata and zeroes device USER

**Important refinement to the earlier review:** do not infer broken NO_REPLY return handling merely from the captured raw gasket. The local native-AXI adapter deliberately wraps that boundary:

`L/native_axi/ofs_plat_local_mem_GROUP_as_axi_mem.sv:121–187` instantiates burst mapping first, then `ofs_plat_axi_mem_if_user_ext`, with **`FORCE_USER_TO_ZERO(1)`**, **`FORCE_RD_ID_TO_ZERO(1)`**, and **`FORCE_WR_ID_TO_ZERO(1)`**. It then passes through timing/clock-crossing stages to FIU (:189–265). The generated QSF lists the corresponding non-GROUP adapter at F38/F45:142 and helper at :122; those generated bodies still need capture. Listing is not proof of an AFU instance's actual elaborated route.

`L/native_axi/prims/ofs_plat_axi_mem_if_user_ext.sv` gives the exact library behavior:

- :94–100 records the entire AR ID/USER on accepted AR, and dequeues on accepted last R beat.
- :124–130 records the entire AW ID/USER on accepted AW, and dequeues on accepted B.
- :146–155 and :166–170 gate request acceptance with metadata FIFO capacity and zero AW/W/AR USER when requested. Read/write IDs are zeroed independently.
- :157–178 copies response payload/status, then **replaces all B/R USER with saved AW/AR USER** and restores saved IDs (all bits when IDs are forced to zero). Raw BUSER or synthetic zero RUSER therefore need not carry PIM NO_REPLY on this adapter path. WUSER is not the metadata source for the B response.
- :14–19 explicitly assumes responses remain ordered within each channel. The adapter's :174–181 comments explain forcing same IDs for that purpose; this is source intent, not tested MSA ordering acceptance.

The helper's header claims FIM flags are passed to the device, but executable assignments are narrower evidence: `FIM_USER_WIDTH` and `FIM_USER_START` (:25,:71) are not used to slice/shift USER. The COPY macros copy whole fields (`P/src/rtl/base_ifcs/axi/ofs_plat_axi_mem_if.vh:168–210`), and the chosen adapter then zeroes them. With forcing disabled, this helper does not implement a documented removal of low PIM bits. **Do not invent a `{MSA command, NO_REPLY}` translation from its comments.**

This supports a source-derived explanation for preserving AFU metadata without device echo. It does **not** establish that zero is the correct MSA ordinary-request encoding, that all AFUs use this adapter, or that the generated implementation equals the template. No new zero-USER patch is proposed.

## 3. Captured generated/FIM boundary and conditional width conclusion

| Evidence | What is established |
|---|---|
| F37/F44:70–86 | Actual generated selection is `native_axi` / `fim_emif_axi_mm`; FIM USER parameter is **AXI_MEM_WUSER_WIDTH**, not AWUSER width. |
| F10:44–77,85–88 | FIM derives separate channel widths from emitted interface macros. WUSER falls back to one when absent; subsystem selection also depends on absent generated headers. |
| F39/F46:38–41; F40/F47:26–33 | Generated cfg adds flag width; FIU banks use `LOCAL_MEM_AXI_MEM_PARAMS_FULL_BUS_DEFAULT`. Local macro template `L/afu_ifcs/ofs_plat_local_mem_GROUP_axi_mem.vh:58–65` binds USER_WIDTH to that cfg. |
| F43/F50:45,52,61,75,86 | Actual gasket directly assigns AW/AR USER, does not drive WUSER, and copies B/R USER back; no shift/field separation is present here. |
| F9:309,321,333,341 | FIM wrapper directly forwards AW/AR USER to subsystem and BUSER back; supplies zero RUSER. |

If the expected no-WUSER headers are emitted and the generated flag package matches F18, the PIM native-bank expectation is **1 + 1 = 2**, compared with raw AW/AR USER width 14. This is a **conditional source expression**, not an observed compiled ABI. Missing F24–F27 and empty F29 prevent treating fallback compilation as correct configuration. In the local adapter's force-zero path, that width discrepancy alone does not demonstrate metadata loss or nonzero PIM bits leaking into MSA commands. Conversely, widening an INI parameter alone does not establish any valid MSA command mapping or response behavior.

## 4. Correct generated paths: no local-memory `afu_ifcs/include` guess

Two actual QSF roots, with exact full paths expanded in the JSON:

- `R0 = /home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/syn/board/ia840f/syn_top/afu_with_pim/pim_template/hw/lib/build/platform/ofs_plat_if`
- `R1 = /home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/syn/board/ia840f/syn_top/afu_with_pim/afu/build/platform/ofs_plat_if`

For **each** root, the finite read set is:

| Root-relative path | Derivation |
|---|---|
| `rtl/ifc_classes/local_mem/afu_ifcs/axi/ofs_plat_local_mem_axi_mem_pkg.sv` | F38/F45:36 literal SYSTEMVERILOG_FILE. |
| `rtl/ifc_classes/local_mem/afu_ifcs/ofs_plat_local_mem_axi_mem.vh` | Actual local template location, AFU-tree merge and group-0 rename. |
| `rtl/ifc_classes/local_mem/ofs_plat_local_mem_wrapper.vh` | Generated include wrapper. |
| `rtl/ofs_plat_if.vh` | Top include chain used by captured FIU/gasket. |
| `rtl/ifc_classes/local_mem/ofs_plat_local_mem_as_axi_mem.sv` | F38/F45:142. |
| `rtl/ifc_classes/local_mem/prims/ofs_plat_axi_mem_if_user_ext.sv` | F38/F45:122. |
| `rtl/base_ifcs/axi/prims/ofs_plat_axi_mem_if_map_bursts.sv` | F38/F45:99. |
| `rtl/base_ifcs/axi/ofs_plat_axi_mem_if.sv` | F38/F45:127. |
| `rtl/base_ifcs/axi/ofs_plat_axi_mem_if.vh` | Local top include :27, QSF AXI SEARCH_PATH. |

Generator proof: `P/scripts/platlib/gen_ofs_class_if.py:38–54` drops `native_axi` in the destination; :74–83 preserves `afu_ifcs`; :113–140 removes `_GROUP` for group zero; :198–209 creates the class-root wrapper and includes generated `.vh` basenames. `P/src/rtl/ofs_plat_if.vh:34–35` includes that wrapper. F38/F45:19 adds the **local_mem/afu_ifcs** search directory. The host-channel `afu_ifcs/include` package in the QSF is not a local-memory header location. Therefore the earlier review's proposed `local_mem/afu_ifcs/include` follow-up should be replaced by the explicit path above, without editing that other report.

F41/F42/F48/F49 are misses at different, wrong paths. They do not establish that these corrected paths are absent. No files at the original remote paths were opened during this task.

## 5. Smallest concrete next action and MSA definition closure

**First capture the corrected package and AFU header at R0/R1**, then the listed adapter/helper/include chain if they agree with the expected generation layout. Hash full text; report missing, encrypted, or oversized files instead of reconstructing them. The JSON enumerates 18 PIM paths and four additional MSA paths, deduplicated and counted programmatically.

For MSA, an exact generated route is already available: **F81/F83:40–41** each name `mem_ss_msa_105/synth/mem_ss_msa_top.sv` and `mem_ss_msa_105/synth/drc_pkg.sv` relative to their own QIP directory. The JSON expands both channel copies to absolute paths. Read these before seeking broader installed sources. F81/F83:5–9,59–60 identify `mem_ss_msa` **1.0.5**; no definition for the 14 command bits or BUSER meaning is inferred from that identity.

If those exact generated sources are missing/unreadable, use the separately authorized, bounded installed-source lookup in the JSON: only `/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg`, exact basename selectors `mem_ss_msa_top.sv`, `drc_pkg.sv`, `mem_ss_msa_hw.tcl`, capped depth/entries/files/bytes. This is a lookup proposal, **not a claim those basenames exist there**; the root is grounded by captured installed `ip_mem_ss/filesets.tcl` evidence. If absent, return bounded MSA directory names and stop; do not scan the entire installation. Follow at most four literal source/include edges from an actually found file in a separately scoped follow-up. Never source Tcl or decrypt protected HDL.

The unresolved question is specific: what do this MSA version's AW/AR USER bits and BUSER mean, is all-zero AW/AR USER a documented ordinary memory request for this configuration, and does the actual generated AFU adapter preserve metadata as the pinned source does? Until answered, retain the source-width concern but do not assert hardware failure, loss of NO_REPLY, a valid command-bit translation, or any compiled width. Calibration remains with the other reviewer.
