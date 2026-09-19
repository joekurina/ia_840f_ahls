# Installed calibration declaration follow-up

Read-only exact-file capture completed in ia840f_migration_preflight under standing workstation inspection scope. No Tcl/vendor execution or board/source/configuration edit. Five full UTF-8 payloads were captured with stable size/mtime and verified SHA-256; no capture errors. Local receipt calibration-installed-live04.json is 1,965,253 bytes, SHA-256 08d9eb973fea98e051fa26ece58f653e8e9d72d25f2fa22ab5f0c5999670601a. Exact scope and command are retained alongside it. Earlier live03 limit failure is preserved.

## Findings

- ip_mem_ss/qcp/mem_ss_hwtcl_commands.tcl contains 20,812 noncomment statements, all set_instance_package_parameter_property. Static Python token enumeration, not Tcl execution, established this count.
- Its lines 14–37 contain 24 top/bottom calibration declarations: automatic board/device/family/speedgrade, diagnostics and short-interface-name editability. These are USER_EDITABLE properties, not slot remapping or physical-address/sequence-table implementation. No supported independent remap is established by this file.
- util/common_tables.tcl:33–59 defines create_device_features. Family selection depends on SYSINFO_DEVICE_DIE_REVISIONS: MAIN_FM[0-9]* selects fm; MAIN_FP* selects fp; MAIN_FMM* selects fmm; an empty revision list defaults to fp. Actual saved/generated FM evidence remains necessary; the board marketing name alone does not evaluate this callback. No callback was evaluated here.
- util/main.tcl:27–28 sources common_tables.tcl and hwtcl_helpers.tcl. util/pkgIndex.tcl:15–20 registers util and subsystem packages. These close the previously missing literal utility-package definitions, not calibration consumer semantics.

## Acceptance

Composition ordering remains explained by prior edit_qsys_fm.tcl evidence. Physical/electrical equivalence of donor reversed versus modern sequential calibration buses remains unresolved. Do not infer electrical failure, interchange channels, remap pins, or edit generated HDL. These files do not supply the calibration-address/sequence-table consumer needed for that determination.

ready_for_build remains false. No namespace probe, mailbox migration, IP generation, synthesis/fit/timing or hardware qualification was performed in this follow-up.
