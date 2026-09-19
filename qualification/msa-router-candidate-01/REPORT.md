# Router candidate review: exact ON enum established; no justified overlay

## Outcome
The exact nondefault enum for `ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION` is **ON** (UI `On`), alongside **AUTO** and **OFF**. These are decoded from the actual installed 26.1.1 assignment library's value-semantics table, not guessed from nearby printable strings. However, this bounded review **does not establish ON as an effective stronger Agilex 7 optimization**. No source-overlay patch is emitted and no fresh compile is recommended on this evidence alone.

The hypothetical assignment spelling is `set_global_assignment -name ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION ON`; this is an exact enum result, **not an approved or validated candidate**.

## Evidence and applicability issue
- Library: `/opt/altera/26.1.1/quartus/linux64/libdb_acf.so`, SHA256 `ff83ee6769849c55ebb83a6c6567e3d2f9e063210deee7b83bc6698221929f16`.
- Static ELF disassembly establishes variable-name lookup via `acf_variable_strings` at virtual 0x41fc20, with index minus one. Correct PT_LOAD translation subtracts 0x1000 for the writable segment. Assignment ID is 1083.
- `acf_get_variable_enum_value_types` scans 12-byte records at 0x33e400. Records 0x340e0c/0x340e18/0x340e24 bind ID 1083 to AUTO/OFF/ON respectively, all non-debug, family sentinel 78. `acf_enum_type_to_string` resolves their IDs 71/3/2 through 0x3fa660. See `decoded-enum.json` and captured disassembly `remote-static-5.json`.
- Crucially, `acf_variable_includes_family` separately indexes `acf_variable_families` at 0x3fe660 using the variable ID directly. This assignment's bitmap has **only family indices 15 and 55 enabled**. The bounded review did not establish their device-family names. A generic enum's family sentinel therefore does **not** prove Agilex 7 applicability. This is a concrete unresolved restriction, not permission to force ON.
- Installed help says Auto already inserts buffers/duplicates logic for fitting necessity or performance improvement with nominal compile-time increase. It does not quantify a stronger ON policy or guarantee additional MSA optimization.
- `/opt/altera/26.1.1/quartus/linux64/assignment_defaults.qdf`, SHA256 `6bf28d61aacedcc91ed126e50bcfe2af597841caefad36f70f3859edd1a818c7`, line 449 defaults the setting to Auto; line 450 also defaults router register duplication to Auto.
- Work10 fitter SHA256 `118b90656eb59450598906fb3f191b5ba10ab7f9f0464a6f006dfafe284ac173` is verified against the local completed report. Its transformation table contains 500 rows labeled Router Logic Cell Insertion and Logic Duplication / Routability optimization. This proves the transformation already ran on this Agilex 7 design, **not that this legacy assignment controls it on this family**. The effective settings table does not expose this assignment or Post Route Physical Synthesis.
- `POST_ROUTE_PHYSICAL_SYNTHESIS` has installed descriptive help, but no established effective-disabled baseline. It is not used as an alternate blind toggle. No post-route synthesis text appeared in the completed fitter report.
- The installed `common/help/webhelp` directory contains only `hlp_alias.txt`, not full option help pages. Bounded text searches found the assignment in QDF but no independent schema. A bounded `*dstr*` library-name lookup was empty; this does not prove family mapping cannot be found elsewhere.

## Baseline and scope
Live SOURCE re-read and locally hash-verified: `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293`, captured as `remote-source-baseline.qsf`. Keep seed 2, maximum-placement source spelling, SPEED synthesis and MAXIMUM router timing optimization. The stale local maintained SOURCE was not used. Work10 remains EMIF0 setup -0.508 ns, EMIF1 -0.170 ns, hold -0.004 ns; no timing recovery is claimed.

No maintained SOURCE/WORK/gate/authorization edits, native Quartus query, compile, RTL/SDC/clock/geometry/PF/BAR/pin change, DDR simulation, hardware access, install or commit occurred. Only Python file reads, static nm/objdump inspection and owned tmux evidence buffers were used remotely, in new named windows/panes %386–%391 inside `ia840f_mailbox_monitored_01`. Every batch asserted Agilex7Workstation UID 1000. Local outputs are exclusively in this qualification directory.

## Next decision
Do not spend a compile merely switching this Auto to ON. First resolve the installed family bitmap mapping and the Agilex 7 consumer's interpretation of this assignment; if supported and meaningfully different, package one ON-only overlay against the above SOURCE hash. Static acceptance then supports a fresh compile experiment, not a proven timing fix. Preserve seed/effort and compare all-corner setup/hold, transformation evidence, resources and runtime. Area/congestion/hold regression and a no-op remain real risks. Targeted MSA alias mapping belongs to the separate sibling investigation and was not duplicated here.
