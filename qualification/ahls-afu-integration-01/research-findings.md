# AHLS AFU Integration Research Findings — ahls-afu-integration-01

Date: 2026-09-19 (PDT)
Mode: READ-ONLY research. No vendor execution, no remote mutation, no source edits.
Local tree: `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`
Remote: `uwb_student00@100.101.227.97` (Agilex7Workstation), `B = /home/uwb_student00/ahls/new_BSP`, `WORK12 = B/work_ia840f_fim_12`
Remote access: SSH BatchMode, read-only commands only.

Machine-readable inventory with SHA256: `ahls-artifact-inventory.json` (same directory).

---

## 1. Do actual AHLS-generated RTL/IP artifacts exist? — **NO**

Exhaustive pattern searches (`*.aocx *.aoco *.aocr *.prj top_*_di.ip *_di_hw.tcl *_di_inst.sv register_map_offsets.h *_register_map.h`, plus any `*hls*`/`aoc*` dirs) over:

- Local `N`: `afu/`, `examples-afu/` (excl. `.git`), `experiments/`, `interfaces/`, `reference/`, `oneapi-asp/`, `ofs-agx7-pcie-attach/`, `qualification/` (only binding-lib copies), and `/home/joe/Projects/Thesis/AHLS/hls-samples`
- Remote `B`: full tree (excl. `.git`), incl. all `work_ia840f_fim_*`, `work_ia840f_ipgen_*`, `work_ia840f_msa_generation_01`, `qualification/`
- Remote `/home/uwb_student00/ahls/altera_hls/` (depth 6)

…found **zero generated AHLS design artifacts**. Concretely:

1. The only AHLS-named RTL anywhere is the **hand-written reusable binding library**, present identically on both hosts (`N/afu/ahls/` == `B/afu/ahls/`, per-file SHA256 match, see inventory):
   - `rtl/ahls_ofs_board_services.sv` (84 lines) — maps `ofs_plat_if` host_chan/local_mem to Avalon byte agents
   - `rtl/ahls_avmm_byte_to_line.sv` (54 lines) — aligned byte-address → PIM line-address adapter
   - `rtl/ahls_mmio_aperture.sv` (112 lines) — DFH/UUID + non-overlapping CSR aperture with rebasing
   - `rtl/ahls_mmio_to_avmm.sv` (80 lines) — serialized 64-bit tagless Avalon CSR bridge
   - `rtl/ahls_board_binding.sv` (75 lines) — **entry module**, composition of the above
   - `ahls_binding_sources.tcl` — source registration only ("Reusable source registration only. Not an AFU top selection or AHLS IP import.")
2. The library's own contract confirms it: `N/afu/ahls/integration-contract.json` —
   `"status": "vendor_derived_board_sources_present_generated_ip_unbound"`,
   `"executable_configuration": false`, `"source_implementation.status": "connected_reusable_rtl_not_elaborated_not_top_level_activated"`,
   `bound_instance.generated_project/top_module/afu_uuid = null`, `"normalized_boundary_is_generated_ahls_abi": false`.
   Its `artifact_handoff.observed_generated_project` is `null` and it lists the artifacts that are *expected* but absent: `<project>.prj/top_<project>_di.ip`, `<project>_prj/<project>_di_hw.tcl`, `<project>.prj/<project>_di_inst.sv`, `<project>.prj/include/register_map_offsets.h`, `<project>.prj/include/kernel_headers/<kernel>_register_map.h`, `<project>_interface_structs.sv`.
3. Remote `/home/uwb_student00/ahls/altera_hls/aclsycl/` is the **AHLS compiler installation** (`bin/ahls`, `bin/aoc`, `ip/acl_*.sv` tool-internal IP library, `ip/board/bsp` etc.), not design output. No `*.prj`/`*.aocx`/`*_di_inst.sv` beneath it. Also present: `ubuntu-ahls.sif` (Apptainer image, 422 MB) and `altera -> /opt/intelFPGA_pro/23.1`.
4. Binding-library entry module `ahls_board_binding` interface (from `rtl/ahls_board_binding.sv`):
   - Parameters: `AFU_UUID [127:0]`, `CSR_BASE_BYTES`, `CSR_SIZE_BYTES`, `NUM_LOCAL_MEM_BANKS = local_mem_cfg_pkg::LOCAL_MEM_NUM_BANKS`, `CSR_BYTE_ADDR_WIDTH = ofs_plat_host_chan_pkg::MMIO_ADDR_WIDTH_BYTES`
   - Ports: `plat_ifc` (ofs_plat_if), `host_bytes` (Avalon mem-rdwr), `local_bytes[NUM_LOCAL_MEM_BANKS]`, outputs `csr_address[CSR_BYTE_ADDR_WIDTH-1:0]`, `csr_read/write`, `csr_writedata[63:0]`, `csr_byteenable[7:0]`, inputs `csr_waitrequest`, `csr_readdata[63:0]`, `csr_readdatavalid`, `csr_response[1:0]`, output `csr_unsupported_request`, `binding_clk/reset_n`, per-bank/host alignment-fault outputs.
   - Mandatory instance parameters (contract): `AFU_UUID`, `CSR_BASE_BYTES`, `CSR_SIZE_BYTES` — all currently unbound.

Conclusion Q1: the "AHLS IP" side of the architecture is a placeholder; nothing generated exists to integrate yet. Distinguishing evidence is unambiguous (contract status field + absence of every documented generated-artifact pattern).

---

## 2. PR-AFU slot mechanics in WORK12/SOURCE (from actual files)

### 2.1 Where afu.tcl / PR AFU gets instantiated

- Partition (WORK12 `syn/board/ia840f/syn_top/ofs_pr_afu.qsf`):
  `set_instance_assignment -name PARTITION green_region -to afu_top|pg_afu.port_gasket|pr_slot|afu_main`
  `set_instance_assignment -name QDB_FILE_PARTITION ofs_top.qdb -to | -entity top`
  `set_instance_assignment -name ENTITY_REBINDING afu_main -to afu_top|pg_afu.port_gasket|pr_slot|afu_main`
  `set_global_assignment -name REVISION_TYPE PR_IMPL`, `TOP_LEVEL_ENTITY top`, device `AGFB027R25A2E2V`, `POST_FLOW_SCRIPT_FILE quartus_sh:ofs_partial_reconfig/gen_gbs.tcl` (GBS generation).
- Source chain: `ofs_pr_afu.qsf` → `ofs_pr_afu_sources.tcl` (sources deliberately NOT in the .qsf so scripts can swap them) →
  - interfaces: `syn/shared_config/afu_if_design_files.tcl`
  - FIM default SR AFUs: `syn/board/ia840f/setup/afu_design_files.tcl` (only when `OFS_BUILD_TAG_SR_AFU` is unset → `src/afu_top/fim_afu_instances.sv`)
  - AFU entry: `ofs-common/src/fpga_family/agilex/afu_main.tcl`
- **Selection logic** (`ofs-common/src/fpga_family/agilex/afu_main.tcl`, WORK12 sha256 `800b6fc9…`):
  - `OPAE_PLATFORM_GEN` set → template-only PIM environment (`afu_main_pim/port_afu_instances.sv`, `VERILOG_MACRO OPAE_PLATFORM_GEN`).
  - Else if `afu_with_pim/afu.tcl` exists → **"Loading PIM-based AFU..."**: loads connector `afu_main_pim/port_afu_instances.sv` + `SOURCE_TCL_SCRIPT_FILE afu_with_pim/afu.tcl` (the AFU's own sources).
  - Else → **"Loading device exerciser AFU..."**: `ofs-common/src/common/afu_main_std_exerciser_design_files.tcl` + `afu_main_std_exerciser/fim_compile/port_afu_instances.sv`.
  - `afu_with_pim/pim.tcl` is loaded whenever present (it is, in WORK12).
- **WORK12 state**: `afu_with_pim/` contains `pim.tcl` (imports `afu/build/platform/platform_if_addenda.qsf`) but **no `afu.tcl`** → the PR slot is currently occupied by the **standard exerciser AFU**: HE-LPBK (`he_lb_top`) and HE-MEM (`he_mem_top`, under `INCLUDE_LOCAL_MEM` && `!INCLUDE_HSSI`; HE-HSSI disabled since `INCLUDE_HSSI` is not defined) — see `afu_main_std_exerciser/fim_compile/port_afu_instances.sv` (he_lb_top ~line 269, he_mem_top ~line 285). PR image metadata `ofs_pr_afu.json` still names the default: cluster `ofs_pr_default`, UUID `222baa4c-0ab8-4574-bf74-aa35b945a223`.
- Integration hook for an AHLS AFU: author `afu_with_pim/afu.tcl` + AFU JSON (UUID/clocks) so `afu_main.tcl` switches to the PIM branch — no FIM RTL edit required. (This is exactly the upstream `ofs_pim_and_afu_config.sh` flow that created the tree: `afu_with_pim/README`.)

### 2.2 Interface the AFU must present at the slot

Two supported tops:

a) **Native `afu_main`** (entity rebinding target). Ports (from `port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv` and `pr_slot.sv` lines 324–349):
   - clocks: `clk` (pClk, clk_sys **470 MHz**), `clk_div2` (235 MHz), `clk_div4` (117.5 MHz), `uclk_usr`, `uclk_usr_div2` (PR user clock, default from `user_clock.sv`, 100 MHz refclk; AFU JSON `clock-frequency-low/high` requests retargeting via `user_clock_config.tcl`)
   - `rst_n`, `port_rst_n[PG_NUM_PORTS][PG_NUM_LINKS]` (includes FLR when demuxed)
   - PCIe SS AXI-S TLP streams (512-bit, `pcie_ss_axis_if`): `afu_axi_tx_a_if`/`afu_axi_rx_a_if` (standard channel, all host responses on RX A), `afu_axi_tx_b_if` (optional second read/IRQ channel), `afu_axi_rx_b_if` (write commits; must tready=1 if unused)
   - `ext_mem_if [NUM_MEM_CH-1:0]` (`ofs_fim_emif_axi_mm_if.user`, NUM_MEM_CH=2)
   - `remote_stp_jtag_if` (`ofs_jtag_if.sink`, Remote STP; `INCLUDE_REMOTE_STP` defined)
   - Freeze/quiesce: `pr_slot.sv` drives `pr_freeze_emif[]`/`softreset_emif[]` per channel through `pr_slot_freeze_axis` wrappers before handing EMIF to `afu_main`.

b) **PIM `ofs_plat_afu`** (what the AHLS binding targets): `afu_main_pim/port_afu_instances.sv` builds `ofs_plat_if plat_ifc()` and instantiates `` `PLATFORM_SHIM_MODULE_NAME `` = `ofs_plat_afu` (from generated `platform_afu_top_config.vh`: `AFU_TOP_MODULE_NAME ofs_plat_afu`, `AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU 1`). It wires:
   - clocks via `ofs_plat_std_clocks_gen_port_resets` (pClk/pClkDiv2/pClkDiv4/uClk_usr/uClk_usrDiv2)
   - per PCIe stream: `map_fim_pcie_ss_to_host_chan` → `plat_ifc.host_chan.ports[s]`
   - per memory bank: `map_fim_emif_axi_mm_to_local_mem` → `plat_ifc.local_mem.banks[b]`
   - `plat_ifc.other.ports[0].sample_state = 32'hcafef00d` stub; `softReset_n = clocks.pClk.reset_n`.

### 2.3 Active build macros (WORK12 `fim_project_macros.tcl` / `ofs_top.qsf`)

`INCLUDE_USER_CLK, DDR4_NUM_MEM_GROUPS=2, INCLUDE_IA840F, INCLUDE_DDR4, INCLUDE_PR, DISABLE_HE_HSSI_CRC, INCLUDE_PCIE_SS, INCLUDE_REMOTE_STP, INCLUDE_LOCAL_MEM, SHARED_AFU_MAIN_TO_PORT_AFU_INSTANCES, AFU_MAIN_HAS_PF_VF_MUX`. NOT defined: `INCLUDE_HSSI`, `INCLUDE_PMCI`, `INCLUDE_HPS`, `INCLUDE_HBM`, `INCLUDE_UART`.
PCIe SS config (`ofs_ip_cfg_db/ofs_ip_cfg_pcie_ss.vh`): 1 link, 2 PFs, PF0 has 1 VF (total VFs 1) → per `top_cfg_pkg.sv`, the port gasket is served by **PF0 VF0** (shared VF port).

---

## 3. CSR/MMIO contract of the PIM for this configuration

All from WORK12 generated files:

- **Outer aperture**: `ofs_fim_cfg_pkg.sv` line 63–70: `MMIO_DATA_WIDTH = 64`; `MMIO_ADDR_WIDTH = OFS_FIM_IP_CFG_PCIE_SS_PF0_BAR0_ADDR_WIDTH` = **20** (PF0 BAR0, 2 MiB, FIM management); `MMIO_ADDR_WIDTH_PG = OFS_FIM_IP_CFG_PCIE_SS_PF0_VF_BAR0_ADDR_WIDTH` = **20** (VF BAR0 → port gasket/AFU). The hypothesized "11-bit outer aperture" is **wrong**: the AFU-reachable outer aperture is the 20-bit (2 MiB) PF0-VF0 BAR0. (PF1 BAR0 is 12-bit, non-PG management.)
- **DFL layout**: `src/includes/fabric_width_pkg.sv`: `apf_pr_slv_baseaddress = 'h70000` (port gasket DFH at BAR0 offset 0x70000), `apf_pr_slv_address_width = 16` (PG CSR window 64 KiB), `apf_pr_slv_next_dfh_offset = 'h10000`, EOL=0 → the **AFU DFH is the next feature at BAR offset 0x80000** of the DFL walk. PG CSR (`pg_csr`, `port_gasket.sv` line 285, `MM_ADDR_WIDTH` default 18, PG CSR decode 16-bit) owns port control (softreset/FLR), user-clock freq cmd/sts, remote STP.
- **PIM MMIO presentation** (`ofs_plat_if_top_config.vh`): `OFS_PLAT_PARAM_HOST_CHAN_MMIO_ADDR_WIDTH = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH_PG` (20, byte-level), `OFS_PLAT_PARAM_HOST_CHAN_MMIO_DATA_WIDTH = 64`, `OFS_PLAT_PARAM_HOST_CHAN_ADDRESS_SPACE "IOVA"`, `BYTE_EN_SUPPORTED 1`, `NUM_INTR_VECS = NUM_AFU_INTERRUPTS`, 512-bit MMIO writes supported (`ofs_plat_host_chan_pkg.sv` line 32 `MMIO_512_WRITE_SUPPORTED = 1`). MMIO travels as PCIe MemRd/MemWr TLPs on the AXI-S A channel (there is no separate AXI-lite to the AFU; the PIM gasket mapper splits MMIO from host-memory traffic).
- **What an AFU must implement**: a device feature list starting at MMIO address 0 of its region — first entry = 5 quadwords: DFH, two AFU UUID words, two reserved (`examples-afu/tutorial/afu_types/01_pim_ifc/hello_world/hw/rtl/avalon/hello_world_avalon.sv`, comment block ~lines 43–52, "A valid AFU must implement a device feature list, starting at MMIO address 0"). The UUID must equal the JSON UUID (`afu_json_mgr` → `afu_json_info.vh` `AFU_ACCEL_UUID`; WORK12 template currently carries the all-zero `dummy_afu` UUID). Avalon MMIO geometry macro (`ofs_plat_host_chan_GROUP_as_avalon_mem_rdwr.vh` line 23–26): `ADDR_WIDTH = MMIO_ADDR_WIDTH_BYTES - clog2(BUSWIDTH/8)`, `DATA_WIDTH(BUSWIDTH)`, `BURST_CNT_WIDTH(1)`.
- The binding library already models this: `ahls_mmio_aperture` implements DFH/UUID + rebasing (`CSR_BASE_BYTES`/`CSR_SIZE_BYTES` mandatory), `ahls_mmio_to_avmm` serializes to a 64-bit byte-enabled Avalon agent for generated CSR banks.

---

## 4. Memory channel interface the AFU sees via PIM local_mem

FIM→PR boundary (native): `ofs_fim_emif_axi_mm_if.user ext_mem_if[1:0]` — AXI4-MM, 2 channels (`mem_ss_param_pkg.sv` `NUM_PORTS = 2`; `DDR4_NUM_MEM_GROUPS=2`). Widths from generated `ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_if_info.vh` (lines 16–55): **addr 34 (byte), id 9 (AWID/BID/ARID/RID), user 14 (AWUSER/ARUSER), data 512, wstrb 64, len 8, BUSER/RUSER width 1**. This confirms the 512/34/9/14 two-channel hypothesis exactly.

PIM side (`ofs_plat_if_top_config.vh` + `local_mem_cfg_pkg.sv` + `ofs_plat_local_mem_axi_mem.vh`, all in `afu_with_pim/afu/build/platform/ofs_plat_if/rtl/`):
- `OFS_PLAT_PARAM_LOCAL_MEM_IS_NATIVE_AXI 1`, `NUM_BANKS = NUM_MEM_CHANNELS = 2`, line addr width = `ARADDR(34) - clog2(64) = 28` → `LOCAL_MEM_BYTE_ADDR_WIDTH = 34`, `DATA_WIDTH 512`, `ECC_WIDTH 0` (full bus == data bus), `BURST_CNT_WIDTH = AXI_MEM_BURST_LEN_WIDTH+1 = 9` (Avalon-style; AXI variant subtracts 1 → 8), `USER_WIDTH = WUSER = 14` organized as `{AFU user, FIM user, PIM user}` (only FIM's 14 in the macro), `RID/WID_WIDTH = 9`, gasket `fim_emif_axi_mm`, max active lines rd 256 / wr 128, suggested 2 timing stages.
- AFU consumption choices: AXI (`ofs_plat_axi_mem_if` with `LOCAL_MEM_AXI_MEM_PARAMS[_DEFAULT|_FULL_BUS*]`) or Avalon (`LOCAL_MEM_AVALON_MEM_PARAMS`, `ofs_plat_local_mem_as_avalon_mem.sv`). The AHLS binding uses the Avalon view per bank (`local_bytes[b]` → `ahls_avmm_byte_to_line` byte→line adapter with alignment fault).
- Access path per bank: `map_fim_emif_axi_mm_to_local_mem #(INSTANCE_NUMBER b)` (`afu_main_pim/port_afu_instances.sv`, local-mem generate block).

Host memory via PIM: `host_chan` native class `native_axis_pcie_tlp`, gasket `pcie_ss`, ADDR_WIDTH 51 (IOVA lines), DATA_WIDTH = `TDATA_WIDTH` (512), split Avalon read/write (`ofs_plat_host_chan_GROUP_as_avalon_mem_rdwr`), max active flits rd 1024 / wr 128. Physical IOVA only — no VTP/USM translation, no DMA engine in the binding (contract `limits`).

Clocks at the AFU boundary: pClk 470 MHz (`sys_pll_ip_params.vh` `clk_sys` actual 470.0; div2 235.0, div4 117.5), uclk_usr default (100 MHz refclk-derived, retargetable per AFU JSON). FIM compile Work12 accepted baseline: rc0, all setup met, one accepted −0.004 ns vendor hold (per task context).

---

## 5. Integration gaps — what must exist/decide before an integration candidate can be assembled (ranked)

1. **CRITICAL — No generated AHLS IP exists.** There is no `<project>.prj/` (top_<project>_di.ip, _di_hw.tcl, _di_inst.sv), no register_map_offsets.h / kernel_headers/<kernel>_register_map.h, anywhere local or remote. The entire AFU payload must first be produced by an authorized AHLS compilation (vendor execution — out of scope here). Without it there is nothing to instantiate; every downstream gap depends on its actual ports/register map.
2. **CRITICAL — AFU identity/aperture unbound.** `bound_instance` in `integration-contract.json` is null (UUID, CSR base/size, kernel instances, endpoints). `ofs_pr_afu.json` still carries the default exerciser UUID `222baa4c-…`. An AFU UUID must be generated/registered and `CSR_BASE_BYTES`/`CSR_SIZE_BYTES` chosen (non-overlapping with the DFH/UUID header, within the 2 MiB VF BAR0 / DFL next-DFH chain at 0x80000+).
3. **CRITICAL — PR slot integration hook not authored.** `afu_with_pim/afu.tcl` does not exist; the slot builds the std exerciser (HE-LPBK+HE-MEM). Needed: afu.tcl sourcing the generated IP + binding lib + AFU JSON (UUID, clock requests), relying on `afu_main.tcl`'s PIM branch; or `OFS_BUILD_TAG_SR_AFU` path. Must also decide JSON `afu-top-interface` (ofs_plat_afu vs afu_main) since that flips `AFU_TOP_REQUIRES_AFU_MAIN_IF` and which `port_afu_instances` is used.
4. **HIGH — Invocation semantics unselected.** CSR-register-mapped start/done vs conduit: the binding supplies no MMIO→start controller (contract bridge `invocation.status = mode_unselected`). FinishCounter clear-on-read, single completion owner, argument-write serialization must be specified against the real generated register map.
5. **HIGH — Host-memory path decisions.** Physical IOVA only: host software must register buffers (OPAE) and supply IOVA; generated Avalon-MM agents need width/burst/outstanding-response adaptation to the PIM split rd/wr host_chan (512-bit lines, byte-enables supported); no VTP/USM; ordering/quiescence must be defined (fence flags insufficient).
6. **HIGH — Streaming pipes have no transport.** External AHLS pipe endpoints (Avalon-ST/AXI-S) have no DMA bridge or host transport in this FIM configuration (no HSSI, no hostchannel MMD in scope). Either bound to on-board endpoints, a custom bridge designed, or pipes kept internal.
7. **MEDIUM — Generated-IP clock/reset binding.** Which uclk_usr/pClk domain the AHLS IP uses, reset polarity/synchronization, CDC into 470 MHz pClk MMIO path, user-clock frequency request in AFU JSON, freeze/quiescence cooperation with `pr_slot_freeze_axis`.
8. **MEDIUM — CSR pipes & device globals.** Register-map-driven (input-valid/output-ready protocol, no manufactured ready/valid registers); host-accessible device globals need a separate MM agent decision.
9. **MEDIUM — OPAE host layer absent.** No host implementation (`opae_host_contract.implementation_present = false`): enumeration by UUID, MMIO read/write with correct byte offsets/widths, buffer registration, bounded waits, teardown.
10. **MEDIUM — Toolchain compatibility unverified.** AHLS observation 2026.1 vs Quartus 26.1.1 Pro (`contract.scope` flags this as user-context only; installation compatibility uninspected). The generated .ip must be importable by the 26.1.1 PR flow.
11. **LOW (verification ladder, all currently false)**: elaboration → simulation → timing → hardware gates; per contract `acceptance_gates`.

Also noted (no action): WORK12 `ofs_pr_afu.qsf` (sha256 `8e651a80…`) differs from local SOURCE (`7895adcb…`) by the documented native QSF migration (`OPTIMIZATION_MODE "HIGH PERFORMANCE EFFORT"` replacing deprecated Superior-Performance string) and PR import comments — expected post-launch migration, not operator drift; `ofs_pr_afu_sources.tcl` is byte-identical both hosts (`20673909…`).

---

## 6. Verification of this research

- Every load-bearing claim above cites a file actually read this session (paths as printed by find/cat on the respective host); hashes for all cited files are in `ahls-artifact-inventory.json`.
- Searches that returned empty are reported as empty (no generated artifacts), including the hls-samples tree and remote compiler install.
- No file was modified on the remote; no vendor tool executed; no builds. Local writes confined to this directory (`research-findings.md`, `ahls-artifact-inventory.json`).
