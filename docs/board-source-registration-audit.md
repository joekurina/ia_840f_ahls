# Board-local source registration audit

**Source-only; ready_for_build: false.** AHLS/OFS/OPAE remains the active target. No setup, Tcl/HDL execution, generation, builds, tests or workstation access occurred.

## Scope and result

The [JSON receipt](../reference/vendor-integration/board-source-registration-audit.json) enumerates 91 explicit file-assignment records from the IA840F board-local `.qsf` and `.tcl` files: 84 resolve to existing local files and seven are absent. Counts are assignment occurrences, not unique sources. Every scanned file and existing target is hash-bound in the receipt.

This is deliberately a finite registration inventory, **not full dependency closure**. It reads literal `set_global_assignment` file references, substitutes only the known `BUILD_ROOT_REL`, and resolves relative references against the board `syn_top` directory. It enumerates conditional branches without evaluating them. It does not execute the source-only gate or infer which branches Quartus would select; it does not recursively inspect common source lists, Qsys filesets, HDL includes, or generated interfaces.

## Absent paths have identified producers

All source paths below are relative to `ofs-agx7-pcie-attach/`.

| Absent path relative to board syn_top | Occurrences | Producer evidence | Disposition |
|---|---:|---|---|
| `../setup/config_env.tcl` | 2 | `ofs-common/scripts/common/syn/build_fim_setup.sh:143–148` creates the link | Setup prerequisite; do not create a worktree or run setup now |
| `ofs_partial_reconfig/ofs_sta_report_script_pr.tcl` | 1 | Same script, lines 131–140 | PR setup link; source exists in common scripts |
| `fim_project_macros.tcl` | 1 | `ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl:59–67` | Generated from a future FIM synthesis project |
| `fim_base_ip.tcl` | 1 | Same script, lines 103–116 | Generated FIM IP registration list |
| `ofs_top.out.sdc` | 1 | Same script, lines 103–110 | Fresh FIM timing export; never replace with an old board export |
| `ofs_ip_cfg_db/ip_gen_sv_wrapper_inc.tcl` | 1 | `ofs-common/scripts/common/syn/ip_get_cfg/ofs_ip_cfg_db.tcl:41–44` | Generated include-list artifact; the board PR source list checks existence before registration |

No omitted handwritten file or incorrect literal path was established by this bounded scan. The identified producers are evidence only, not permission to run them. Their outputs must remain absent until the corresponding execution is explicitly authorized.

## Board BMC registration

`setup/afu_design_files.tcl:14–24` selects the IA840F AFU top, PF1 instance wiring, ST2MM sources and board-owned BMC list. `setup/bwbmc_design_files.tcl:36–64` selects the active board wrapper and vendor Qsys/IP source files. The preserved wrapper under `ipss/ia840f/bwbmc/` is not selected by that list. Custom component implementation files remain owned by their Qsys filesets rather than being added as duplicate global RTL assignments (`setup/bwbmc_design_files.tcl:4–19`). These statements concern registration only, not component compatibility or functional closure.

No existing configuration, RTL, manifest, donor provenance or gate was changed by this audit. Memory group/CSR, BMC FLR, generated AHLS binding and toolchain qualification gaps remain unchanged.
