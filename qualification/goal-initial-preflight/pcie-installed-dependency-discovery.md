# Installed PCIe dependency discovery

Read-only discovery ran inside workstation tmux session `ia840f_goal_preflight`. Its persisted receipts are under `/home/uwb_student00/ahls/new_BSP/qualification/goal-initial-preflight/`:

- `pcie-child-and-deployment-prerequisites.json`
- `pcie-child-catalog-summary.json`

The following installed inputs were found and SHA-256 hashed:

| Input | SHA-256 |
|---|---|
| `/opt/altera/26.1.1/ip/altera/intel_pcie/ptile/avst/tcl/intel_pcie_ptile_ast_hw.tcl` | `a1445ad115b86d93f584ceefe09cc03032285393e727635680bd03325fd5e443` |
| `/opt/altera/26.1.1/ip/altera/subsystems/intel_pcie_ss_axi/rtl/ptile_pciess_top.sv.terp` | `f50c437ea75279a7f345ce3c4d68d31f4dfbf5cd188e8c9f2e4eb590672ef7e7` |
| `/opt/altera/26.1.1/qsys/bin/ip-deploy` | `5494247412c9c4d56956131d9f4e176705fde2e4782da1bef5fe63715bcc2199` |

The Python interpreter reports 3.9.25. The intended `work_ia840f_ipgen_01` output directory was absent at discovery.

The entry loads `intel_pcie_ptile_ast_module.tcl` and the shared P-Tile parameter sources. Follow-up read-only evidence (`pcie-child-entry-source.json`, `pcie-child-version-bar2-source.json`, and `pcie-child-exact-schema.json` in the remote evidence directory) establishes:

- `avst/tcl/intel_pcie_ptile_ast_module.tcl:70` declares `intel_pcie_ptile_ast` version **11.0.0**, with Agilex 7 listed. File SHA-256: `4d1bcb08bdcc4e96670969cb790868f456bb81dbecc8be00bc3a591900476651`.
- `common/tcl/intel_pcie_ptile_common_core16_parameters.tcl:550` exposes PF1 BAR2 `64-bit prefetchable memory`; lines 551–563 expose its width, explicitly including **28** at line 555. File SHA-256: `fdccb26acc9f61222aea59619e40031cae858709b5c36a3fd00d04d5d28275e8`.
- `/opt/altera/26.1.1/quartus/common/tcl/packages/lampas_iptcl/lampas.tcl` exists. File SHA-256: `e6377495a611411d60b085dbd20e8aa876b9c9effc66d659517f7dc37843c794`.

This closes the missing installed child-version/schema evidence, not runtime parameter validation or generated-interface acceptance. Conditional callbacks and complete subsystem integration remain unexecuted. No project generation or hardware operation occurred during this discovery.
