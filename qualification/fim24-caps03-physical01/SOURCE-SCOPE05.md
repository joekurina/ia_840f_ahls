# First matching persona fit — source/API review package

The completed mapped-synthesis gate is accepted with findings in [acceptance36](../fim24-caps03-implementation01/SYNTHESIS-ACCEPTANCE36.md). This package prepares **one first fit only**. It contains no runnable admission or implemented fit gate; no fit has run.

## Prepared copy and proposed change

[Copy03](copy03-readback/prepared-copy03.json) contains3894 entries/648,172,944bytes from the exact completed synthesis. All608 mapped-QDB members, imported static QDB, original synthesis and external/setup/release/archive inputs were reverified. Relative link text is unchanged; two internal resolved paths naturally move into the new copy. No binary database, source, constraint, setting or original artifact was edited.

Candidate05 replaces only the two copied QSF gate references, proposing new `build_gate_physical08.tcl`/`ia840f_physical_gate08.py`; old gate files remain. All other QSF bytes, NUM_PARALLEL_PROCESSORS36, seed1 and PR/static/source/SDC assignments remain unchanged. The active copy still selects the spent synthesis gate and is not runnable as fit. [Exact proposed delta](qsf-delta05.patch).

The [current role proposal](input-output-roles05.json) preserves3031 copied inputs, including68 static/mapped snapshot members,276 temporary HDL/source-snapshot files,99 clearbox sources and all three inherited static image artifacts.863 existing entries are separately classified as native outputs/project metadata:590 DNI checkpoint/cache entries,265 QDB report/cache/manifest/import materialization entries,seven persona reports andQPF. This is an explicit per-path proposal, not reuse of the older1133-path exemptions. All3894 entries must be bound before launch; the original complete synthesis stays fully immutable. QPF changes remain separately captured and narrowly checked. Two new gates would give3896 active entries/3033 critical input entries.

## Actual installed API and source chain

CMake-native no-project help01/02 succeeded for the actual26.1.1 fitter/STA and documented the proposed exact fitter argv, explicit QSF read-on/write-off, and future STA snapshot/multicorner/report flags. These are API observations, not project-load or fit acceptance. The candidate CMake exposes only version and fit, no default build/synthesis/STA/assembly target. The native context is direct `quartus_fit --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu` in the exact fresh syn_top directory. [Plan05](source-plan05.json), [help01](help01-readback/fit_help.log), [option help02](help02-readback/fit_read_settings_files.log).

Current PR QSF, flattened490,165-byte `ofs_top.out.sdc`, PIM source chain, user-clock scripts and JSON/config helpers are captured and copied unchanged. PIM's first-fit user-clock targets derive from the existing `auto-200`/`auto-100` requests; achieved-clock output remains separate. `user_clock_config.tcl` treats `output_files/user_clock_freq.txt` as generated output and attempts deletion in fitter context; it is absent in this starting copy. The user-clock targets do not authorize relaxing the unchanged application/EMIF3.000ns target. Native realized clocks and constraints remain a later result obligation.

The QSF's TIMING_ANALYZER_REPORT_SCRIPT invokes the user-clock computation and reporting helpers under STA; POST_FLOW_SCRIPT_FILE points to GBS packaging. They remain unchanged collateral, but standalone fit is not permission to run either later stage. No helper executes while source is inspected. [Captured project hooks](copy03-readback/project/ofs_partial_reconfig/ofs_sta_report_script_pr.tcl), [PIM helpers](helpers04-readback/build/platform/ofs_plat_if/par/user_clock_config.tcl).

## Execution boundary and retained findings

After SOURCE review, implement/test fresh owner/ancestor callback and early runner, binding every finite executable context (especially linux64/quartus_fit), full before-state, critical/runtime roles, original inputs, tools and controls. Use the exercised supervision behavior through descendant drain/final bytes, actual string start-tick representation and source-bound rejection checks. Keep all36CPUs/64GiB per-process, finite60/60/10800-second stages and32MiB polled log threshold. No aggregate isolation claim.

Native0 must be accompanied by actual fit reports, callback ownership and preservation. Critical20580 requires real root/import/PR preservation evidence;19854/power-up and mixed reset/enable/duplication findings remain open. No guessed PR assignment, seed change, timing waiver or source change is proposed. Subsequent multicorner STA/reset/CDC/electrical disposition, assembly, deployment and hardware acceptance remain separate. SOURCE review is not execution QUALITY or issuance.
