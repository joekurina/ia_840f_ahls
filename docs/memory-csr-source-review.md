# IA840F memory management CSR source review

**ready_for_build: false. No configuration or RTL patch is justified by the available source contract.**
Active target: AHLS/OFS/OPAE with Quartus Prime Pro 26.1.1; oneAPI is reference-only. This review does not authorize execution or assert IP compatibility.

## Outcome

The modern common wrapper already contains the source-supported counterpart of the vendor's outer memory CSR fabric: a 64-bit FIM DFH branch at memory-local `0x000` and a 32-bit subsystem branch at `0x800`. No new CSR engine or address allocation is needed for that routing. However, enabling the route is not proof of equivalent subsystem registers, error reporting, or clock/reset connectivity. The checked-in modern MSA `CSR_EN` parameter has no implementation/parameter-definition evidence in this source set establishing an alias to legacy `DIAG_ENABLE_CSR`. Consequently neither flag is changed.

An important refinement to the earlier memory review: the vendor internal controller-MMR routes exist, but their addresses are outside the actual outer 11-bit subsystem aperture. Do not advertise those routes as directly host-accessible vendor capability or widen the aperture as an incidental porting fix.

Only this document and `reference/vendor-integration/memory-csr-source-review.json` were created. The earlier `memory-port-source-map.md` and JSON remain historical snapshots; presets, derivation script, manifests, donor hashes and all gates are unchanged.

## Evidence notation

Paths below use:

- `V/`: `../old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/` relative to `new/`, read-only.
- `N/`: `ofs-agx7-pcie-attach/` relative to `new/`.
- `C/`: `N/ofs-common/src/fpga_family/agilex/mem_ss/`.
- `L/`: `V/ipss/mem/qip/mem_ss/ip/mem_ss_fm_0/`.

The companion JSON records full-file current SHA-256 and line counts for 24 source files, 14 parsed management connections, and all 58 register entries (including metadata fields and derived FIM-relative offsets) in legacy `mem_ss_fm_0_csr_base.ip`. Its paths are relative to `new_bsp/`. These are source metadata, not hardware readback. Modern baseline identifiers are FIM `599ac052eafbc9cede22561c099233ae4a54cb7d`, common `34a8540697fdf3d66fbcaa263fa037bae17cc32f`, as pinned by the enclosing preparation task; current file hashes are not substituted for commit identifiers or donor hashes.

## Exact vendor management routing

1. `V/src/pd_qsys/fabric/apf.qsys:11943-11945,12069-12071,12195-12197` routes `apf_st2mm_mst`, `apf_mctp_mst`, and `apf_uart_mst` to `apf_bpf_slv.altera_axi4lite_slave` with base `0x0000`. These are declared fabric initiators, not assertions that all transports are active on this board.
2. `V/src/pd_qsys/fabric/bpf.qsys:16589-16593,16820-16824` maps both `bpf_apf_mst` and `bpf_pmci_mst` to `bpf_emif_slv.altera_axi4lite_slave` at **`0x00015000`**. `V/src/top/top.sv:203,1126-1144,1193-1196` declares the 12-bit local interface and connects it to memory `csr_lite_if`.
3. `V/ipss/mem/rtl/mem_ss_top.sv:54-55,102-181` splits that interface through `emif_csr_ic`. Its source Qsys `V/ipss/mem/qip/axilite_ic/emif_csr_ic.qsys:4260-4284` maps `emif_dfh_mst` at `0x0000` and `mem_ss_csr_mst` at **`0x0800`**. Both downstream addresses are 11 bits; DFH data is 64 bits, subsystem data is 32 bits.
4. `V/ipss/mem/rtl/mem_ss_top.sv:200-221` connects the subsystem clock/reset to `clk_csr` / `rst_n_csr` and connects `csr_app_ss_lite_*` / `csr_ss_app_lite_*`. AW/AR addresses explicitly zero-extend the 11-bit interface into the subsystem.

Thus the fabric-relative windows are `0x15000–0x157ff` (outer DFH/status/capability) and **`0x15800–0x15fff`** (subsystem CSR). These are offsets in the management fabric, not CPU physical addresses, PCIe BAR allocations or DDR application addresses.

### Subsystem registers actually described by vendor metadata

`L/mem_ss_fm_0_csr_base.ip:962-970` declares a 32-bit register block of range `0x180`. Selected exact offsets are:

| Vendor register family | Subsystem-relative offset | FIM-management-relative offset |
|---|---|---|
| DFH low/high | `0x00`, `0x04` | `0x15800`, `0x15804` |
| GUID low/high DWORDs | `0x08–0x14` | `0x15808–0x15814` |
| DFHv1 CSR address and size/group | `0x18–0x24` | `0x15818–0x15824` |
| Version; feature lists | `0x60`, `0x64`, `0x68` | `0x15860`, `0x15864`, `0x15868` |
| Interface attributes | `0x70` | `0x15870` |
| Scratch | `0x80` | `0x15880` |
| Control/read/write access policies | `0x90–0xa4` | `0x15890–0x158a4` |
| Base error/status | `0xb0` | `0x158b0` |
| Memory calibration pass/fail | `0xc0`, `0xc4` | `0x158c0`, `0x158c4` |
| Memory capability | `0xc8`, `0xcc` | `0x158c8`, `0x158cc` |
| Memory-interface attribute slots | `0x100–0x17c` | `0x15900–0x1597c` |

Ranges in this table group DWORD entries, not promises that every intervening byte is an independently implemented register. The JSON contains every exact entry. Attribute slots beyond the two board channels are metadata slots, not additional physical channels. `mem_ss_base_status` documents sticky AXI SLVERR/DECERR bits cleared by writing one (`L/...csr_base.ip:1788-1854`). No indirect-address/data command register is described in the parsed block. Do not invent one to bridge the aperture mismatch.

### Internal MMR targets are a separate layer

`V/ipss/mem/qip/mem_ss/mem_ss_fm_0.qsys` declares:

| Internal master | Target | Base | Lines |
|---|---|---|---|
| `csr_base.bridge_axi4l` | `csr_base.csr_apb3` | `0x0000`, default connection | 15459-15462 |
| same | `csr_base_ccb_DDR_CTRL_0.s0` | `0x00100000` | 15480-15483 |
| same | `csr_base_ccb_DDR_CTRL_1.s0` | `0x00110000` | 15501-15504 |
| `csr_base_ccb_DDR_CTRL_0.m0` | `intf_0.ctrl_mmr_slave_0` | `0x0000` | 15564-15567 |
| `csr_base_ccb_DDR_CTRL_1.m0` | `intf_1.ctrl_mmr_slave_0` | `0x0000` | 15585-15588 |

The internal AXI addresses are 23 bits (`L/...csr_base.ip:4263-4273,4545-4555`). Neither high target address can be directly presented through the outer 11-bit zero-extended input. No verified indirect mechanism was found in the register metadata; implementation-level indirect behavior is not inferred from the existence of `bridge_axi4l`. A new large host aperture would be an ABI change, not restoration of demonstrated direct access.

Clock crossings are explicit: Qsys lines 15610-15616 connect each controller user clock to its CCB `m0_clk`, and the CSR bridge clock to the CCB `s0_clk`. Lines 15725-15731 connect controller user resets to both sides of the associated CCB, and CSR reset controller output to the base bridge/APB reset. These legacy connections are evidence to compare, not automatically valid modern reset wiring.

## MSA CSR semantics: known vendor behavior versus unproven modern alias

- Both legacy MSA leaves set **`DIAG_ENABLE_CSR=true`** at `L/mem_ss_fm_0_msa_{0,1}.ip:2062-2065`.
- The resulting legacy `msa_csr` is a **conduit containing `msa_csr_slverr` and `msa_csr_decerr` outputs**, not an independent addressable AXI CSR bank (`...msa_0.ip:955-982,1872-1896`; same shape on channel 1).
- Qsys lines 15674-15687 connect these conduits to `csr_base.msa_csr_0/1`; lines 15695-15721 route controller status into `csr_base` and its status outputs to the MSAs. This explains a concrete vendor diagnostic path; it does not establish a modern register-map alias.
- `N/ipss/ia840f/derive_presets.py:92-109` only copies exact matching MSA names or the listed explicit geometry/data-width aliases. `DIAG_ENABLE_CSR` is **not** in that alias map. The modern `CSR_EN=false` values remain reference defaults (`N/ipss/ia840f/presets/ia840f_mem.qprs:2906,2924`), as the derivation JSON records.
- Parsing the entire modern `mem_presets.qprs` found 11 MSA `CSR_EN` entries, all `false`; no enabled example. A search of the candidate tree located `CSR_EN` only in presets/derivation evidence, not an MSA implementation or parameter callback. Therefore its exact effect, output shape, parent-parameter override behavior, and equivalence to the vendor error conduits **remain unestablished**. The likely diagnostic relationship is a lead, not sufficient evidence for changing it to `true`.

## Modern source-supported counterpart and enable distinction

`C/local_mem_wrapper.sv:55-70` forwards the CSR interface to `mem_ss_top`; the IA840F top connects the existing `bpf_emif_slv_if` (`N/src/board/ia840f/top.sv:230,1168-1186,1274-1276`). Modern fabric Tcl retains base `0x15000` for APF and PMCI initiators and AW=12/DW=64 (`N/src/pd_qsys/fabric/bpf.tcl:608-611,1368-1373,1601-1606`). No board-local replacement router is missing here.

`C/mem_top_design_files.tcl:14-20` selects the **common-tree** CSR Qsys and five leaf IPs. Its Qsys, not the leftover `N/ipss/mem/qip/axilite_ic/` copy, is the relevant modern authority: `C/qip/axilite_ic/emif_csr_ic.qsys:4709-4733` preserves `0x0000`/`0x0800`; its `mem_ss_csr_mst.ip` declares 11-bit addresses and 32-bit data. Source metadata identifies this Qsys as 25.1, not a Quartus 26.1.1 qualification.

`C/mem_ss_top.sv:74-76,168-191,193-266` already implements the routing:

- If `HAS_IFC_MEM_SS_CSR_AXI_LITE_IF` exists, outer DFH uses `emif_dfh_if`, the interconnect forwards the upper window to generated `mem_ss_csr_axi_lite_if`, addresses `[22:11]` are tied zero, and `.csr_axi_lite(ss_csr_axi_lite_if)` connects to `mem_ss`.
- Without that generated-interface macro, `mem_ss_csr` receives `csr_lite_if` directly; this retains the outer DFH/status/capability implementation, **not** the vendor subsystem CSR register bank. `C/mem_ss_csr.sv:43-55` identifies outer offsets `0x0`, `0x8`, `0x10` and an 11-bit decode.
- `N/ofs-common/scripts/common/syn/ip_get_cfg/mem_ss_get_cfg.tcl:116-121` explicitly recognizes **`ENABLE_MEM_CSR_INTF=ENABLED`** and emits `OFS_FIM_IP_CFG_${ip_name}_EN_CSR`. This establishes the OFS configuration intent, not the generated interface by itself. The RTL above is guarded by `HAS_IFC_...`, emitted from actual interface discovery (`ip_gen_sv_wrapper.tcl:762`), not by that `EN_CSR` macro. Do not manually define either macro to bypass missing IP evidence.
- `.csr_app_ss_lite_aclk()` and `.csr_app_ss_lite_areset_n()` are left open in the modern wrapper at lines 264-265, unlike the vendor's explicit clock/reset inputs. Their correct direction and association must be obtained from the selected modern IP export. Names alone do not justify tying them to `clk_csr` and `rst_n_csr`.

All nine modern reference occurrences of `ENABLE_MEM_CSR_INTF` are `DISABLED`; the IA840F preset also has `DISABLED` at line 7. The checked-in code supports an optional route, but contains no enabled modern IA840F export/register contract proving the vendor functionality end to end.

## Narrow patch prerequisites (not applied)

1. Obtain authoritative modern `mem_ss` and MSA component parameter definitions/RTL or equivalent pinned source metadata for the intended Quartus 26.1.1 flow. Establish the legal `ENABLE_MEM_CSR_INTF` values and whether/how it controls or overrides each MSA `CSR_EN`; establish the latter's actual diagnostics and register behavior.
2. Resolve the enabled CSR export's name, exact address/data widths, clock/reset directions and association. Check against the existing 23-bit/32-bit wrapper assumptions and its open clock/reset ports. Any later generated evidence requires separate execution authorization; no generation was performed here.
3. Compare actual modern CSR register addresses, DFH revision/identity/size, error-bit clear behavior, calibration/status and access-policy fields with the complete vendor inventory. An equal outer `0x800` offset is not equal software semantics.
4. If the above proves compatibility, narrowly add the explicit board-local top-level enable and proven MSA alias/default policy in `derive_presets.py` **and** the retained IA840F QPRS/derivation evidence together. Use the existing common router and `0x15000 + 0x800` allocation; do not invent new address ranges or a controller-MMR aperture. Patch clock/reset wiring only from the established export contract, scoped to the board if behavior differs from other boards.
5. Refresh affected current-file/output hashes in applicable manifests while retaining original donor hashes. Do not rewrite the earlier memory-port source-map snapshot to conceal a later change. Retain every execution gate and `ready_for_build: false` even after any source correction.

## Static results and limitations

- Parsed vendor Qsys/IP XML, both modern interconnect and preset XML, existing JSON evidence, and the derivation Python AST without executing project Python, HDL or Tcl.
- Persisted 58 exact legacy register entries and 14 management connections; register offsets were calculated from the proven management bases, not guessed.
- Hashed 24 cited source files. Independently compared the 37 candidate/vendor source entries selected from the earlier memory-map registry: **37 match, zero differ**. No donor/current hashes needed refreshing because no existing source/config was changed.
- Read the board gate and confirmed its unconditional `ia840f_ready_for_build false` setting and error path remain present. No gate was edited.
- No HDL/Tcl/project execution, configure/setup, IP generation, builds, tests, remote access, installation, programming, commits or pushes occurred. A broad initial filename/content search encountered legacy work-tree paths; no generated build artifact was imported or used to justify the routing conclusions.

The blocker is specific: **the modern enabled subsystem/MSA contract is absent from the inspected source evidence**, while the outer fabric counterpart already exists. This review intentionally does not reopen generic physical memory grouping or substitute development-kit geometry.
