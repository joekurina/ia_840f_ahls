# Work14 baseline collector diagnostic01 — bounded scope

## Purpose, evidence and exclusions

Consume [source diagnosis](../fanout-diagnosis01.md), SHA256 `f8c83514f3df1433ddf45fa2deb304eab30b1aa6c2d28f74626c68120ae432cb`, and the [accepted failed baseline](../experiment03/baseline/RESULT-ACCEPTANCE.md). The prior query failed its positive-count/4096 bound before logging the count. Zero versus overflow is unknown. Fitter Fan-Out355 is not the missing STA count.

Use one fresh copied Work14 fitted database with the full original SDC load order. This is a diagnostic of two explicitly named starting collections, not an A/B run, fit, maintained-source correction or hardware operation. No SDC/clock/exception changes. The byte-identical prior clock helper is sourced for definitions only; neither apply nor verify_created is called. Its latent generated-clock function does not authorize use. `ready_for_build=false` throughout.

## Exact native query

Root `/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01`; cwd is root plus `/scratch/syn/board/ia840f/syn_top`. Only normal `project_open -revision ofs_top ofs_top`, `create_timing_netlist`, argument-free `read_sdc`, and `update_timing_netlist`. Preserve actual SDC filenames in native logging; inspect them against bound copied/original inputs at result review. Exact original top.sdc SHA256 `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` must survive preparation. No second SDC load, report_timing, path sweep or generic graph walker.

`D` remains the observed divider `pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst`. Pin O=`D|clock_div2`; keeper K=`D~div_reg`. Neither is the fitter net `...|u_pciess_clock_divider|clock_div2x`. Resolve exact O as one clock output pin. Capture `get_fanouts -clock Ocollection` count before any load-range test. Independently resolve exact K through get_keepers and get_registers (count/name must agree, no wildcard broadening), then capture `get_fanouts -clock Kcollection` count before either load-range decision. No fallback assignment from one root to the other. Do not add -stop_at_clocks to fanouts.

- Record up to256 clocks. Generated-only master/source/ratio properties are requested only for generated/virtual_generated types; base/virtual_base record not_applicable. Native diagnostics are never suppressed.
- Preserve4096 as each set's enumeration limit,8192 total possible enumerated loads. Emit both counts first. Zero is a complete empty observation. Over-cap is incomplete, never an empty set; skip that enumeration but retain the other planned bounded observations. The native collection is obtained before counting:4096 is an output enumeration limit, not a native traversal-runtime guarantee.
- For each enumerated load, record its full name, exact keeper identity and get_clocks -of_objects association. Preserve raw/enumerated/unique counts; duplicate or cardinality mismatch fails completion. Include all returned names, including out-of-prefix/non-FIFO nodes, without restricting to known receivers.
- When both sets are complete, record exact pin-only/keeper-only names and counts plus intersection count. Otherwise explicitly mark relation unavailable.
- Bind the32 exact observed Query02 receiver cell and clock-pin names in known-receivers.tcl (provenance JSON cites original log SHA256 `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89`). Check eight per group and exact name-set equality, not cardinality alone. Record membership in each set, actual clocks and each receiver clock-pin reverse fanin; baseline requires one K. Fanin enumeration ceiling32; emit count first.
- Resolve and record the separately named P-Tile load from the prior native warning, its clocks and membership in both sets. Emit every missing known name. Missing membership is an observation and does not become a silent positive collector verdict.
- API errors propagate; never catch them as empty collections. Root/known-identity drift rejects. Incomplete or duplicate load enumeration rejects after preserving available counts/known observations.

## Completion is diagnostic-only

`IA840F_FANOUT_DIAGNOSTIC_COMPLETE` means the bounded observations completed, NOT that either collector is validated. Both empty sets or missing known membership can produce a completed diagnostic whose support flags are false. Parent/independent review must interpret the full sets and discrepancies. Over-cap/API/identity errors yield incomplete failure. This marker cannot satisfy `IA840F_CONSTRAINT_COMPARE_COMPLETE baseline`; no experiment03 or future candidate authorization is enabled by it. Even pin0/keeper-positive with all known memberships is only evidence to review before choosing a full A/B collector. No old missing count is reconstructed retrospectively.

## Execution and preservation

Reuse the experiment03 baseline supervised runner, retargeted only in path/gate/permission/buffer identities and diagnostic-only result/completion markers. Retained legacy functions are not the CLI entry; `main_supervised` remains the entry. Whole-lifetime supervision, live claim ancestry, exact launcher/native executable/argv/cwd, input/link hashes and single-use artifacts remain enforced. Wall1800s, native address-space64GiB, individual-file128MiB, report-total1GiB, minimum MemAvailable80,000,000,000bytes, no competing quartus_/qsys- process; preparation also requires20,000,000,000bytes free. Source-bound guards are not an OS sandbox.

Copy Work14 and PIM with cp-a/reflink-auto; initially byte-identical. Only permitted text/link path relocations and scratch gate dispatch are added; baseline top.sdc remains unchanged. Hash-preserve original Work14, SOURCE and PIM before/after; missing or failed preservation is not acceptance. No OPAE/device/sysfs/MMIO/JTAG/driver/flash/reset/reboot access, and no fit. Never repeat the spent experiment03 attempt or modify its candidate.

## Gates and evidence

Fresh ordinary-file preparation exports14 files: the predecessor13 plus known-receivers.tcl. Exact manifest/archive/readback and actual missing-authorization runner/dispatcher rejection precede independent SPEC→QUALITY→parent consumption. Only then may a separately inspected, exact-byte-bound one-use diagnostic authorization issue. Prepared candidate approved=false is not authorization. Permission is `exact-offline-fanout-diagnostic01`.

18 full-entry inert Tcl tests and11 inert supervised-runner tests are local implementation regressions, not native API proof. Prepared-readback replay must bind actual query/helper/known names to actual recorded cwd/argv. Python3.9 AST and exact retarget comparison protect compatibility. Result review must separately inspect native/effective status, complete diagnostic output, bounds, loaded source identities and original-tree preservation. No review or rc0 alone qualifies a repaired clock, timing, CDC/DRC, persona, hardware or the mission.
