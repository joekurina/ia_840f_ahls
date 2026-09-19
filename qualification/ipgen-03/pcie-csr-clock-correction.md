# IA840F PCIe CSR clock parameter correction — local source review only

## Decision and scope

Implemented a narrow, evidence-backed translation in `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_vendor_pcie.py`. After the existing donor-preset hash/component checks, require the reviewed donor CSR request `100`, translate `axi_lite_clk_freq_user_hwtcl` to `core16_axi_lite_clk_freq_user_hwtcl`, remove the ignored legacy key from the effective parameter dictionary, and retain the existing source-bound `pcie_context(pcie)` call. The original preset and derivation hashes remain untouched. This is a port-0 parameter-name correction for the reviewed IA840F contract, not a generic migration of other boards or unknown parameters.

The local donor's actual saved PCIe parameter was inspected directly: it is **100**, not 250. “Saved parameter” here means the donor IP configuration, not a measured or implemented clock. The donor PLL also requests output 1 at 100.0 MHz. Work02 instead saved port-0 AXI-Lite at **250**, confirmed from its captured XML and lossless scoped records, not inferred from a default. Installed 26.1.1 schema accepts 100–250, defaults to 250, and forwards the port-0 value to `core16_axi_lite_source_freq_hwtcl`. The board wiring and current PLL producer request corroborate retaining 100 as the intended request.

**Not qualified:** actual PLL output-1 frequency, generated child parameters, generated timing constraints, timing closure, hardware behavior, or vendor-tool acceptance of the corrected invocation. The existing PLL requested-versus-actual warning remains unresolved. No PLL change is warranted by this evidence. A 100 MHz parameter request does not assert that the physical clock is exactly 100 MHz or waive any tolerance requirement.

## Exact behavioral delta

- Non-IA840F: existing immediate return remains; no source reads or gate call.
- IA840F: existing component/non-preset and two-PF (`pf0:1`, `pf1:0`) checks and preset SHA256 validation remain.
- Following the same donor overrides as before, the only effective parameter delta is deleting the legacy clock key and adding `core16_axi_lite_clk_freq_user_hwtcl='100'`. Other ports' clock fields, all PF/VF/IDs/BAR settings, and PF1 BAR2 width/type are preserved.
- A hash-consistent future donor with missing/non-100 legacy clock is rejected before parameter mutation rather than silently broadening the reviewed contract.
- Existing gate sees the corrected dictionary; any gate exception still propagates. Tests mock this gate and do not establish real authorization validity.
- Changed only the owned helper; added the separate inert test file and this report. Did not edit shared gate, shared gate tests, manifest, donor presets, PLL sources, work02, or claims. No remote operation, vendor execution, or commit was performed.

## Captured saved-IP evidence

The full preexisting byte-content evidence is `qualification/ipgen-02/remote-deployed-ip-source-content.json`; lossless ordered scope records are `qualification/ipgen-02/deployed-ip-scoped-parameters.json`. Both are read-only inputs. Locally recomputed SHA256 of each decoded XML string matches its captured SHA256 and the corresponding lossless-record SHA256:

- `ipss/pcie/qip/pcie_ss.ip`: `a41f8a7e4b2c54f4fb6720434994f305b2cc0f2cec4e9d0cec13e38c14e14341`
- `ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip`: `80b62a76642038c38263bffa72e19ec6d2dc575e5ca4a75f51465e7a0f90b176`

Exact selected lossless PCIe records (no legacy key or derived child source-frequency key was present among these saved parameter records):

```json
[
  {
    "scope": "component",
    "name": "top_topology_hwtcl",
    "value": "Gen4 1x16"
  },
  {
    "scope": "component",
    "name": "core16_axi_lite_clk_freq_user_hwtcl",
    "value": "250"
  }
]
```

Direct XML donor and PLL parameter extraction:

```json
{
  "donor_pcie": [
    {
      "name": "axi_lite_clk_freq_user_hwtcl",
      "value": "100"
    }
  ],
  "donor_pll": [
    {
      "name": "gui_clock_name_string1",
      "value": "clk_100m"
    },
    {
      "name": "gui_output_clock_frequency1",
      "value": "100.0"
    }
  ],
  "work02_pll": [
    {
      "name": "gui_clock_name_string1",
      "value": "clk_100m"
    },
    {
      "name": "gui_output_clock_frequency1",
      "value": "100.0"
    }
  ]
}
```

## Source excerpts (line-numbered, local captured source)

Paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Schema excerpts are the previously copied installed 26.1.1 sources, not freshly queried remote state. The complete original files remain at the listed paths. The setup command excerpt is retained intact, including unrelated parameters, so absence of the prefixed replacement is inspectable.

### `qualification/ipgen-02/remote-setup-full.log`

```text
276: ip-deploy --family=agilex --part="AGFB027R25A2E2V" --search-path="$OFS_ROOTDIR/ipss/**/*,$" --output-name="sys_pll" --component-name="altera_iopll" --instance-name="iopll_0" --output-directory=../../../../ofs-common/src/fpga_family/agilex/sys_pll --component-parameter=gui_location_type="I/O Bank" --component-parameter=gui_reference_clock_frequency="100" --component-parameter=gui_use_locked="1" --component-parameter=gui_number_of_clocks="7" --component-parameter=gui_clock_name_string0="clk_sys" --component-parameter=gui_clock_name_string1="clk_100m" --component-parameter=gui_clock_name_string2="clk_sys_div2" --component-parameter=gui_clock_name_string3="clk_630m_noc" --component-parameter=gui_clock_name_string4="clk_50m" --component-parameter=gui_clock_name_string5="clk_sys_div4" --component-parameter=gui_clock_name_string6="clk_350m_noc" --component-parameter=gui_output_clock_frequency0="470" --component-parameter=gui_output_clock_frequency1="100" --component-parameter=gui_output_clock_frequency2="235.0" --component-parameter=gui_output_clock_frequency3="630" --component-parameter=gui_output_clock_frequency4="50" --component-parameter=gui_output_clock_frequency5="117.5" --component-parameter=gui_output_clock_frequency6="350" --component-parameter=gui_output_clock_frequency_ps0="2127.66" --component-parameter=gui_output_clock_frequency_ps2="4255.319" --component-parameter=gui_output_clock_frequency_ps5="8510.638"
277: ***************************************************************
278: Quartus is a registered trademark of Altera Corporation in the
279: US and other countries.  Portions of the Quartus Prime software
280: code, and other portions of the code included in this download
281: or on this DVD, are licensed to Altera Corporation and are the
282: copyrighted property of third parties. For license details,
283: refer to the Altera Software License Subscription Agreements
284: on the Quartus Prime software download page.
285: ***************************************************************
286: 
287: 2026.09.18.01:18:55 Warning: sys_pll.iopll_0: Able to implement PLL - Actual outclk frequency 1 differs from requested setting
288: 2026.09.18.01:18:55 Warning: sys_pll.iopll_0: Able to implement PLL - Actual outclk frequency 3 differs from requested setting
289: 2026.09.18.01:18:55 Warning: sys_pll.iopll_0: Able to implement PLL - Actual outclk frequency 4 differs from requested setting
290: 2026.09.18.01:18:55 Warning: sys_pll.iopll_0: Able to implement PLL - Actual outclk frequency 6 differs from requested setting

305: ip-deploy --family=agilex --part="AGFB027R25A2E2V" --search-path="$OFS_ROOTDIR/ipss/**/*,$" --output-name="pcie_ss" --component-name="intel_pcie_ss_axi" --output-directory=../../../../ipss/pcie/qip --component-parameter=axi_lite_clk_freq_user_hwtcl="100" --component-parameter=core16_enable_multi_func_hwtcl="1" --component-parameter=core16_enable_sriov_hwtcl="1" --component-parameter=core16_enable_10bit_tag_support_intf_hwtcl="1" --component-parameter=core16_ctrl_shadow_en_hwtcl="1" --component-parameter=core16_comp_timeout_en_hwtcl="1" --component-parameter=core16_flr_cap_user_hwtcl="0" --component-parameter=pcie_link_en_hwtcl="1" --component-parameter=pipemode_sim_ed_hwtcl="1" --component-parameter=total_pcie_intf_hwtcl="1" --component-parameter=top_topology_hwtcl="Gen4 1x16" --component-parameter=core16_pf0_pcie_cap_port_num_hwtcl="1" --component-parameter=core16_ceb_en_hwtcl="0" --component-parameter=core16_ceb_pf_std_cap_last_ptr_hwtcl="0" --component-parameter=core16_ceb_pf_ext_cap_last_ptr_hwtcl="0" --component-parameter=core16_ceb_vf_std_cap_last_ptr_hwtcl="0" --component-parameter=core16_ceb_vf_ext_cap_last_ptr_hwtcl="0" --component-parameter=core16_pf0_expansion_base_address_register_hwtcl="0" --component-parameter=core16_pf0_sriov_vf_bar0_type_hwtcl="64-bit prefetchable memory" --component-parameter=core16_pf0_sriov_vf_bar0_type_user_hwtcl="64-bit prefetchable memory" --component-parameter=core16_pf0_bar0_type_user_hwtcl="64-bit prefetchable memory" --component-parameter=core16_pf0_bar0_address_width_user_hwtcl="20" --component-parameter=core16_virtual_pf0_msix_enable_user_hwtcl="1" --component-parameter=core16_virtual_pf0_exvf_msix_cap_enable_hwtcl="1" --component-parameter=core16_virtual_pf0_acs_cap_enable_hwtcl="1" --component-parameter=core16_exvf_msix_tablesize_pf0="6" --component-parameter=core16_exvf_msixtable_offset_pf0="1536" --component-parameter=core16_exvf_msixtable_bir_pf0="4" --component-parameter=core16_exvf_msixpba_offset_pf0="1550" --component-parameter=core16_exvf_msixpba_bir_pf0="4" --component-parameter=core16_pf0_bar4_type_user_hwtcl="64-bit prefetchable memory" --component-parameter=core16_pf0_bar4_address_width_user_hwtcl="14" --component-parameter=core16_pf0_sriov_vf_bar0_address_width_hwtcl="20" --component-parameter=core16_pf0_sriov_vf_bar4_type_hwtcl="64-bit prefetchable memory" --component-parameter=core16_pf0_sriov_vf_bar4_type_user_hwtcl="64-bit prefetchable memory" --component-parameter=core16_pf0_sriov_vf_bar4_address_width_hwtcl="14" --component-parameter=core16_pf0_pci_msix_table_size_hwtcl="6" --component-parameter=core8_pf0_pci_msix_table_size_user_hwtcl="6" --component-parameter=core16_pf0_pci_msix_table_offset_hwtcl="1536" --component-parameter=core16_pf0_pci_msix_bir_hwtcl="4" --component-parameter=core16_pf0_pci_msix_pba_offset_hwtcl="1550" --component-parameter=core16_pf0_pci_msix_pba_hwtcl="4" --component-parameter=core16_pf0_pci_msix_table_size_vfcomm_cs2_hwtcl="0" --component-parameter=core16_virtual_pf0_ats_cap_enable_hwtcl="0" --component-parameter=core16_pf0_vf_ats_cap_enable_hwtcl="0" --component-parameter=core16_virtual_pf0_prs_ext_cap_enable_hwtcl="0" --component-parameter=core16_virtual_pf0_pasid_cap_enable_hwtcl="0" --component-parameter=core16_pf0_pasid_cap_max_pasid_width="0" --component-parameter=core16_pf0_pci_type0_vendor_id_hwtcl="32902" --component-parameter=core16_pf0_pci_type0_vendor_id_user_hwtcl="32902" --component-parameter=core16_pf0_pci_type0_device_id_hwtcl="48334" --component-parameter=core16_pf0_revision_id_hwtcl="1" --component-parameter=core16_pf0_revision_id_user_hwtcl="1" --component-parameter=core16_pf0_class_code_hwtcl="1179648" --component-parameter=core16_pf0_subsys_vendor_id_hwtcl="32902" --component-parameter=core16_pf0_subsys_dev_id_hwtcl="6001" --component-parameter=core16_exvf_subsysid_pf0="6001" --component-parameter=core16_pf0_sriov_vf_device_id="48335" --component-parameter=core16_pf0_vf_acs_cap_enable_hwtcl="1" --component-parameter=core16_pf0_vf_count_hwtcl="1" --component-parameter=core16_pf1_expansion_base_address_register_hwtcl="0" --component-parameter=core16_pf1_sriov_vf_bar0_type_hwtcl="Disabled" --component-parameter=core16_pf1_sriov_vf_bar0_type_user_hwtcl="Disabled" --component-parameter=core16_pf1_bar0_type_user_hwtcl="Disabled" --component-parameter=core16_pf1_bar0_address_width_user_hwtcl="12" --component-parameter=core16_virtual_pf1_msix_enable_user_hwtcl="1" --component-parameter=core16_virtual_pf1_exvf_msix_cap_enable_hwtcl="0" --component-parameter=core16_virtual_pf1_acs_cap_enable_hwtcl="1" --component-parameter=core16_exvf_msix_tablesize_pf1="0" --component-parameter=core16_exvf_msixtable_offset_pf1="0" --component-parameter=core16_exvf_msixtable_bir_pf1="0" --component-parameter=core16_exvf_msixpba_offset_pf1="0" --component-parameter=core16_exvf_msixpba_bir_pf1="0" --component-parameter=core16_pf1_bar4_type_user_hwtcl="64-bit prefetchable memory" --component-parameter=core16_pf1_bar4_address_width_user_hwtcl="14" --component-parameter=core16_pf1_sriov_vf_bar0_address_width_hwtcl="0" --component-parameter=core16_pf1_sriov_vf_bar4_type_hwtcl="Disabled" --component-parameter=core16_pf1_sriov_vf_bar4_type_user_hwtcl="Disabled" --component-parameter=core16_pf1_sriov_vf_bar4_address_width_hwtcl="0" --component-parameter=core16_pf1_pci_msix_table_size_hwtcl="6" --component-parameter=core16_pf1_pci_msix_table_offset_hwtcl="1536" --component-parameter=core16_pf1_pci_msix_bir_hwtcl="4" --component-parameter=core16_pf1_pci_msix_pba_offset_hwtcl="1550" --component-parameter=core16_pf1_pci_msix_pba_hwtcl="4" --component-parameter=core16_pf1_pci_msix_table_size_vfcomm_cs2_hwtcl="0" --component-parameter=core16_virtual_pf1_ats_cap_enable_hwtcl="0" --component-parameter=core16_pf1_vf_ats_cap_enable_hwtcl="0" --component-parameter=core16_virtual_pf1_prs_ext_cap_enable_hwtcl="0" --component-parameter=core16_virtual_pf1_pasid_cap_enable_hwtcl="0" --component-parameter=core16_pf1_pasid_cap_max_pasid_width="0" --component-parameter=core16_pf1_pci_type0_vendor_id_hwtcl="4794" --component-parameter=core16_pf1_pci_type0_vendor_id_user_hwtcl="4794" --component-parameter=core16_pf1_pci_type0_device_id_hwtcl="112" --component-parameter=core16_pf1_revision_id_hwtcl="1" --component-parameter=core16_pf1_revision_id_user_hwtcl="1" --component-parameter=core16_pf1_class_code_hwtcl="1179648" --component-parameter=core16_pf1_subsys_vendor_id_hwtcl="4794" --component-parameter=core16_pf1_subsys_dev_id_hwtcl="46548" --component-parameter=core16_pf1_vf_count_hwtcl="0" --component-parameter=core16_total_pf_count_hwtcl="2" --component-parameter=core16_dwidth_byte_user_hwtcl="64" --component-parameter=core16_num_seg_user_hwtcl="2" --component-parameter=core16_pf1_bar2_address_width_user_hwtcl="28" --component-parameter=core16_pf1_bar2_type_user_hwtcl="64-bit prefetchable memory"
306: ***************************************************************
307: Quartus is a registered trademark of Altera Corporation in the
308: US and other countries.  Portions of the Quartus Prime software
309: code, and other portions of the code included in this download
310: or on this DVD, are licensed to Altera Corporation and are the
311: copyrighted property of third parties. For license details,
312: refer to the Altera Software License Subscription Agreements
313: on the Quartus Prime software download page.
314: ***************************************************************
315: 
316: 2026.09.18.01:19:10 Warning: Ignored parameter assignment axi_lite_clk_freq_user_hwtcl=100

```

### `ofs-agx7-pcie-attach/src/board/ia840f/legacy/ipss/pcie/qip/pcie_ss.ip`

```text
6562:         <ipxact:parameter parameterId="axi_lite_clk_freq_user_hwtcl" type="int">
6563:           <ipxact:name>axi_lite_clk_freq_user_hwtcl</ipxact:name>
6564:           <ipxact:displayName>AXI-Lite Clock Frequency (in MHz)</ipxact:displayName>
6565:           <ipxact:value>100</ipxact:value>
6566:         </ipxact:parameter>

```

### `ofs-agx7-pcie-attach/ipss/ia840f/presets/ia840f_pcie_known_schema.qprs`

```text
1: <?xml version='1.0' encoding='utf-8'?>
2: <ip>
3:   <presets version="12.1">
4:     <preset name="ia840f_pf0vf0_pf1_bmc_source" kind="intel_pcie_ss_axi" version="All" board="default" preset_category="IA840F source-only" description="Vendor-derived candidate; board execution gate remains closed">
5:       <parameter name="axi_lite_clk_freq_user_hwtcl" value="100" />
6:       <parameter name="core16_ceb_en_hwtcl" value="0" />

61:       <parameter name="core16_pf1_bar0_address_width_user_hwtcl" value="12" />
62:       <parameter name="core16_pf1_bar0_type_user_hwtcl" value="Disabled" />
63:       <parameter name="core16_pf1_bar2_address_width_user_hwtcl" value="28" />
64:       <parameter name="core16_pf1_bar2_type_user_hwtcl" value="64-bit prefetchable memory" />
65:       <parameter name="core16_pf1_bar4_address_width_user_hwtcl" value="14" />
66:       <parameter name="core16_pf1_bar4_type_user_hwtcl" value="64-bit prefetchable memory" />

89:       <parameter name="core16_pf1_vf_ats_cap_enable_hwtcl" value="0" />
90:       <parameter name="core16_pf1_vf_count_hwtcl" value="0" />
91:       <parameter name="core16_total_pf_count_hwtcl" value="2" />

```

### `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ip_params/intel_pcie_ss_axi_parameters.py`

```text
1: # Copyright (C) 2023 Intel Corporation
2: # SPDX-License-Identifier: MIT
3: 
4: default_component_params = {
5:     "axi_lite_clk_freq_user_hwtcl": 100,
6:     "core16_enable_multi_func_hwtcl": 1,
7:     "core16_enable_sriov_hwtcl": 0,
8:     "core16_enable_10bit_tag_support_intf_hwtcl": 1,
9:     "core16_ctrl_shadow_en_hwtcl": 1,

```

### `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/pcie_ip.py`

```text
56:     def set_ip_params(self):
57:         param_default_path = os.path.join(
58:             os.path.dirname(__file__), f"ip_params/{self.ip_component}_parameters.py"
59:         )
60:         logging.info(f"{self.ip_component} source file: {param_default_path}")
61: 
62:         self.PCIE_SS_PARAM = SourceFileLoader(
63:             f"{self.ip_component}_parameters", param_default_path
64:         ).load_module()

163:         else:
164:             for (
165:                 pcie_param,
166:                 pcie_param_value,
167:             ) in self.PCIE_SS_PARAM.default_component_params.items():
168:                 # The value will either be a list or single object. When it is a list,
169:                 # element 0 is the default value of the parameter. Element 1 is the
170:                 # name of the field in the .ofss file that can be set to override
171:                 # the default.
172:                 if isinstance(pcie_param_value, list):
173:                     pcie_param_value, ofss_param = pcie_param_value
174:                     if ofss_param in self.pcie_config["settings"]:
175:                         # Override default using settings
176:                         pcie_param_value = self.pcie_config["settings"][ofss_param]
177: 
178:                 self.ip_component_params[pcie_param] = pcie_param_value
179:                 logging.debug(f"Setting pcie config {pcie_param} to {pcie_param_value}")

```

### `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ip_params/iopll_component_parameters.py`

```text
4: component_params = {
5:     "gui_location_type": "I/O Bank",
6:     "gui_reference_clock_frequency": 100,
7:     "gui_use_locked": 1,
8:     "gui_number_of_clocks": 7,
9:     "gui_clock_name_string0": "clk_sys",
10:     "gui_clock_name_string1": "clk_100m",
11:     "gui_clock_name_string2": "clk_sys_div2",
12:     "gui_clock_name_string3": "clk_630m_noc",
13:     "gui_clock_name_string4": "clk_50m",
14:     "gui_clock_name_string5": "clk_sys_div4",
15:     "gui_clock_name_string6": "clk_350m_noc",
16:     "gui_output_clock_frequency0": 400,
17:     "gui_output_clock_frequency1": 100,
18:     "gui_output_clock_frequency2": 200,
19:     "gui_output_clock_frequency3": 630,
20:     "gui_output_clock_frequency4": 50,
21:     "gui_output_clock_frequency5": 100,
22:     "gui_output_clock_frequency6": 350,

```

### `ofs-agx7-pcie-attach/src/board/ia840f/top.sv`

```text
298: // Connections
299: //-----------------------------------------------------------------------------------------------
300: assign clk_csr   = clk_100m;
301: assign rst_n_csr = rst_n_100m;

505: // It also derives the ~100 MHz CSR clock along with a couple of related clocks to pass to the 
506: // port gasket for use by the AFUs
507: //-----------------------------------------------------------------------------------------------
508: 
509: sys_pll sys_pll (
510:    .rst                (ninit_done                ),
511:    .refclk             (SYS_REFCLK                ), // 100 MHz
512:    .locked             (pll_locked                ),
513:    .outclk_0           (clk_sys                   ), // 350 MHz for x8 and 470 MHz for x16
514:    .outclk_1           (clk_100m                  ), // 100 MHz
515:    .outclk_2           (clk_sys_div2              ), // 175 MHz for x8 and 235 MHz for x16
516:    .outclk_3           (clk_noc_fab_wr            ), // 600 MHz for driving wr fabric internal to NOC 
517:    .outclk_4           (clk_50m                   ), // 50 MHz
518:    .outclk_5           (clk_sys_div4              ), // 87.5 MHz for x8 and 117.5 MHz for x16
519:    .outclk_6           (clk_noc_fab               )  // 350 MHz for driving fabric side of NoC
520: );

583:      .FEAT_ID          (12'h020),
584:      .FEAT_VER         (4'h0),
585:      .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_pcie_slv_next_dfh_offset),
586:      .END_OF_LIST      (fabric_width_pkg::bpf_pcie_slv_eol)  
587: ) pcie_wrapper (
588:    .fim_clk                        (clk_sys                  ),
589:    .fim_rst_n                      (rst_n_sys_pcie           ),
590:    .csr_clk                        (clk_csr                  ),
591:    .csr_rst_n                      (rst_n_csr                ),
592:    .ninit_done                     (ninit_done               ),

```

### `ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/pcie_ss/pcie_ss_dm_top.sv`

```text
226:     .coreclkout_hip_toapp           (coreclkout_hip                 ), \
227:     .p0_pin_perst_n                 (                               ), \
228:     .p0_reset_status_n              (reset_status_n[0]              ), \
229:     .ninit_done                     (ninit_done                     ), \
230:     .dummy_user_avmm_rst            (                               ), \
231:     .p0_axi_st_clk                  (fim_clk                        ), \
232:     .p0_axi_lite_clk                (csr_clk                        ), \
233:     .p0_axi_st_areset_n             (fim_rst_n[0]                   ), \
234:     .p0_axi_lite_areset_n           (csr_rst_n[0]                   ), \
235:     .p0_subsystem_cold_rst_n        (subsystem_cold_rst_n[0]        ), \
236:     .p0_subsystem_warm_rst_n        (subsystem_warm_rst_n[0]        ), \

```

### `reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_parameters.tcl`

```text
1718:                                                                                                                                                                                                                                                                                                                                                                                                                   
1719:                                                                                                                                                                                                                                                                                                                                                                                                                    
1720:     \
1721:         { core16_axi_lite_clk_freq_user_hwtcl                  false       false                    false               INTEGER          250                {100:250}                                                   true                                        true                                            NOVAL               NOVAL               "Port 0 AXI-Lite Interface Settings"                  "PCIe0 AXI-Lite Clock Frequency (in MHz)"         NOVAL                                                                   "Select the PCIe Subsystem AXI-Lite Operating Clock Frequency"  }\
1722:         
1723:         { core8_axi_lite_clk_freq_user_hwtcl                    false       false                   false               INTEGER          250                {100:250}                                                   true                                        true                                            NOVAL               NOVAL               "Port 1 AXI-Lite Interface Settings"                  "PCIe1 AXI-Lite Clock Frequency (in MHz)"         NOVAL                                                                   "Select the PCIe Subsystem AXI-Lite Operating Clock Frequency"  }\
1724:         

```

### `reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_fileset.tcl`

```text
219:         set QUARTUS_ROOTDIR $env(QUARTUS_ROOTDIR)
220:         set top_topology                        [get_parameter_value top_topology_hwtcl]
221:         set virtual_rp_ep_mode                  [ ip_get "parameter.virtual_rp_ep_mode_hwtcl.value" ]
222:         set device_family_hwtcl                 [ ip_get "parameter.device_family.value" ]
223:         set core16_axi_lite_clk_freq_value      [ ip_get "parameter.core16_axi_lite_clk_freq_user_hwtcl.value" ]
224:         set core8_axi_lite_clk_freq_value       [ ip_get "parameter.core8_axi_lite_clk_freq_user_hwtcl.value" ]
225:         set core4_0_axi_lite_clk_freq_value     [ ip_get "parameter.core4_0_axi_lite_clk_freq_user_hwtcl.value" ]
226:         set core4_1_axi_lite_clk_freq_value     [ ip_get "parameter.core4_1_axi_lite_clk_freq_user_hwtcl.value" ]
227:         set core16_axi_st_clk_freq_value        [ ip_get "parameter.core16_axi_st_clk_freq_user_integer_hwtcl.value" ]
228:         set core8_axi_st_clk_freq_value         [ ip_get "parameter.core8_axi_st_clk_freq_user_integer_hwtcl.value" ]
229:         set core4_0_axi_st_clk_freq_value       [ ip_get "parameter.core4_0_axi_st_clk_freq_user_integer_hwtcl.value" ]

246:         set params(device_family)                       [get_parameter_value device_family]
247:         set params(top_topology)                        $top_topology
248:         set params(virtual_rp_ep_mode)                  $virtual_rp_ep_mode
249:         set params(core16_axi_lite_source_freq_hwtcl)   $core16_axi_lite_clk_freq_value
250:         set params(core8_axi_lite_source_freq_hwtcl)    $core8_axi_lite_clk_freq_value
251:         set params(core4_0_axi_lite_source_freq_hwtcl)  $core4_0_axi_lite_clk_freq_value
252:         set params(core4_1_axi_lite_source_freq_hwtcl)  $core4_1_axi_lite_clk_freq_value
253:         set params(core16_axi_st_source_freq_hwtcl)     $core16_axi_st_clk_freq_value
254:         set params(core8_axi_st_source_freq_hwtcl)      $core8_axi_st_clk_freq_value

```

### `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_vendor_pcie.py`

```text
1: # IA840F-only source integration. No vendor tools are invoked here.
2: """Apply the vendor-derived subset, then require source-bound authorization.
3: 
4: Hook from PCIe.process_configuration after ordinary PF/VF processing. This is
5: not a compatibility shim for unknown IP parameters: those remain inventory in
6: the derivation report. Never bypass the rejection by ignoring BAR2.
7: """
8: import hashlib
9: import json
10: from pathlib import Path
11: import xml.etree.ElementTree as ET
12: 
13: 
14: def apply_ia840f_pcie_source(pcie):
15:     if pcie.platform != 'ia840f':
16:         return
17:     if pcie.ip_component != 'intel_pcie_ss_axi' or pcie.ip_preset:
18:         raise ValueError('IA840F requires non-preset intel_pcie_ss_axi PF/VF processing')
19:     if pcie.num_pfs != 2 or pcie.pf_vf_count != {'pf0': 1, 'pf1': 0}:
20:         raise ValueError('IA840F contract requires PF0VF0 AFU and enabled PF1 BMC (no PF1 VF)')
21:     # Resolve from this source tree, not a potentially populated output work tree.
22:     root = Path(__file__).resolve().parents[3]
23:     board = root / 'ipss/ia840f'
24:     report = json.loads((board / 'preset_derivation.json').read_text())
25:     path = 'presets/ia840f_pcie_known_schema.qprs'
26:     data = (board / path).read_bytes()
27:     if hashlib.sha256(data).hexdigest() != report['outputs_sha256'][path]:
28:         raise ValueError('IA840F PCIe source preset hash mismatch')
29:     preset = ET.fromstring(data).find('.//preset')
30:     if preset is None or preset.get('kind') != pcie.ip_component:
31:         raise ValueError('IA840F source preset component mismatch')
32:     overrides = {n.attrib['name']: n.attrib['value'] for n in preset.findall('parameter')}
33:     # The donor requests 100 MHz CSR. Quartus 26.1.1 names the enabled
34:     # port-0 AXI-Lite field core16_*; the legacy unprefixed key is ignored.
35:     # Translate only this reviewed IA840F contract, without changing the
36:     # hash-bound donor preset or claiming the PLL's actual frequency is 100.
37:     legacy_clock = 'axi_lite_clk_freq_user_hwtcl'
38:     port0_clock = 'core16_axi_lite_clk_freq_user_hwtcl'
39:     if overrides.get(legacy_clock) != '100':
40:         raise ValueError('IA840F source preset must request 100 MHz CSR clock')
41:     overrides[port0_clock] = overrides.pop(legacy_clock)
42:     pcie.ip_component_params.pop(legacy_clock, None)
43:     pcie.ip_component_params.update(overrides)
44:     # BAR2 names/values are now backed by the installed subsystem source.
45:     # This is not child-IP acceptance or permission to run the toolchain.
46:     from ia840f_experimental_gate import pcie_context
47:     pcie_context(pcie)

```

## Source evidence SHA256 inventory

Computed locally from complete files, not excerpts. This is documentation, not a replacement authorization manifest.

| Path | SHA256 |
|---|---|
| `qualification/ipgen-02/remote-deployed-ip-source-content.json` | `ba99d80c96f8a1d29d060b90c8710a67dac45c9d651eccef84fe51ff2ea54b31` |
| `qualification/ipgen-02/deployed-ip-scoped-parameters.json` | `8b5325040ceaa68d7c96e690f76f97a1d929bd924c992507648b08badc715a2b` |
| `ofs-agx7-pcie-attach/src/board/ia840f/legacy/ipss/pcie/qip/pcie_ss.ip` | `5911b752135ad2ef986ce6b96efaa1cb42ae002b6e3b6d7084bd4e9ecbe27cc5` |
| `ofs-agx7-pcie-attach/src/board/ia840f/legacy/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip` | `e3e795b22118f2d1bf04333db8acdd8e63b78b4f4bdf33799c0f66aa6ae100d6` |
| `ofs-agx7-pcie-attach/ipss/ia840f/preset_derivation.json` | `e58e146ea0ec90e1a2528ddffdba2553339f4168dadda0b109574844c41d2d06` |
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/test_ia840f_pcie_csr_clock.py` | `aeadedc0a79cc5e578ac7e8493a2fd0436dd7d557ecc7c1b2e1e122729c72d61` |
| `qualification/ipgen-02/remote-setup-full.log` | `6401505888ec4151c651b5465f5ccc051685e457c45587bc59c1c1f85fa6dba9` |
| `ofs-agx7-pcie-attach/ipss/ia840f/presets/ia840f_pcie_known_schema.qprs` | `420f73c5c4bf1432ce39508f068bc381f4e4f2117a87a96940ca8500a93c876e` |
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ip_params/intel_pcie_ss_axi_parameters.py` | `235643482b0012794cfaf57b664dfcb30b3839c0a7fe0dec528a658d665c0275` |
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/pcie_ip.py` | `841e245d17d7db23338bf4d24d87a7b0e73b038ba45a620f3165277c03d0b239` |
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ip_params/iopll_component_parameters.py` | `ddff1a6b8819804829d7acae14590737477628b79f535d426138df0e002b1b6e` |
| `ofs-agx7-pcie-attach/src/board/ia840f/top.sv` | `bb6ea012f3e2bbecafa6a238df7574bb145c02443b9612a99da8cd5c0e98d6fa` |
| `ofs-agx7-pcie-attach/ofs-common/src/fpga_family/agilex/pcie_ss/pcie_ss_dm_top.sv` | `889c9f2d2e404f5efb3e758c624f71da41618d99d54d2ee5e7be7e3f4b33b475` |
| `reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_parameters.tcl` | `752416154dc2eebeb37365b924579135d6513a47779326159e0d8921a772e3f0` |
| `reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_fileset.tcl` | `25616751a302b3eac05b059dcc2494cf97c5d26d8aa11972195fe9b2549c842b` |
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_vendor_pcie.py` | `8b89f1eba308d7b1de8a7a356604ded666e87a5b758a51337058f0fbf2204bc5` |

## Deterministic local tests

Command, from `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`:

```sh
python3 -B -m unittest -v test_ia840f_pcie_csr_clock
```

The test module imports only the deterministic helper and Python standard library. A mock module supplies `ia840f_experimental_gate.pcie_context`; it never imports the actual gate or launches FPGA tools. Tests compare the complete old-versus-corrected effective dictionary, verify preset hash against the unchanged derivation record, preserve other-port values and BAR2/PFs, exercise non-IA840F early returns, existing component/preset/PF rejection, hash mismatch, missing/changed CSR donor request with synthetic in-memory hash-consistent fixtures, idempotence, and propagation of a mocked gate denial.

Actual captured execution output:

```text
test_exact_parameter_delta_and_unchanged_source_hash (test_ia840f_pcie_csr_clock.CSRClockCorrectionTests.test_exact_parameter_delta_and_unchanged_source_hash) ... ok
test_existing_component_preset_and_pf_vf_rejections (test_ia840f_pcie_csr_clock.CSRClockCorrectionTests.test_existing_component_preset_and_pf_vf_rejections) ... ok
test_gate_observes_corrected_parameters_and_denial_propagates (test_ia840f_pcie_csr_clock.CSRClockCorrectionTests.test_gate_observes_corrected_parameters_and_denial_propagates) ... ok
test_hash_consistent_but_changed_clock_contract_rejected (test_ia840f_pcie_csr_clock.CSRClockCorrectionTests.test_hash_consistent_but_changed_clock_contract_rejected) ... ok
test_other_boards_return_before_any_source_reads_or_gate (test_ia840f_pcie_csr_clock.CSRClockCorrectionTests.test_other_boards_return_before_any_source_reads_or_gate) ... ok
test_preset_hash_mismatch_still_rejected (test_ia840f_pcie_csr_clock.CSRClockCorrectionTests.test_preset_hash_mismatch_still_rejected) ... ok
test_repeated_application_is_stable (test_ia840f_pcie_csr_clock.CSRClockCorrectionTests.test_repeated_application_is_stable) ... ok

----------------------------------------------------------------------
Ran 7 tests in 0.055s

OK
Exit status: 0
```

## Required parent review before any deployment

1. Review this helper/test change together with the independent shared-gate/spec work. The correction changes a source-bound input; this report grants no execution permission and does not refresh any authorization.
2. Preserve work02 and its claim as historical evidence. Use the parent's reviewed source inventory/rebinding and fresh-work/claim workflow for any later experiment; never reuse work02 authorization after this edit.
3. Later, under separately authorized vendor execution, confirm the command has the prefixed 100 field and no legacy field, the saved parent retains 100, and generated child `core16_axi_lite_source_freq_hwtcl` is 100. Compare the complete PF/VF/BAR/IDs configuration for unintended changes.
4. Separately reconcile actual PLL output-1 frequency/dividers and generated SDC against CSR/AXI-Lite consumer requirements. RTL generation or removal of the ignored-parameter warning is not clock qualification.

Execution note: this host has no bare `python`; initial read-only inspection failed with exit 127 and was immediately rerun successfully with `python3`. All successful inspection and unit-test commands used `python3`.
