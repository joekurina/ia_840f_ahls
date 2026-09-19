# Independent Work09 specification review

## Verdict: PASS for the authorized experimental compile; NOT timing/functional acceptance

The minimal placement-effort experiment may advance to the separate quality review and then exact review consumption/issuance under the user's continuing authorization. No new user approval is required. This review does not issue authorization or launch anything. S1 remains open for final constraint acceptance; it does **not** block this explicitly authorized unchanged-constraint experiment.

## Independently verified scope and bindings

- All 43 exported file hashes match `remote-evidence/export-sha256.json`. All 12 overlay files match their overlay hashes and captured before-file hashes. Reconstructing the unified diff from captured before/after bytes exactly reproduces both copies of `candidate.patch`.
- Comparing Work08's captured authorized source inventory to Work09's draft across all source trees yields exactly three changed files: the two gate modules and base QSF. No RTL, SDC, pin, PLL, DDR or PCIe configuration delta is introduced.
- The sole QSF change is `OPTIMIZATION_MODE "SUPERIOR PERFORMANCE"` to `OPTIMIZATION_MODE "SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT"`. SPEED, maximum router optimization and seed remain unchanged. Installed 26.1.1 assignment-library evidence contains the display/internal enum; this is static evidence, not native option acceptance or demonstrated timing improvement.
- Both gate modules change only Work08→Work09 dispatch/WORK/EVIDENCE roots. All 135 contexts are exactly equal after the WORK substitution, including executable hashes and argv; runtime grammar, ancestry, tool/source/dependency checks and rejection policy are not weakened. The unchanged compile shell calls the SOURCE entry guard before writes and the SOURCE compile helper after changing to WORK; the retargeted dispatcher recognizes the WORK project directory.
- Every overlay digest is identical in the draft SOURCE inventory and WORK inventory. Draft WORK inventory equals the staged inventory (5564 entries); 106 dependency pins are present. The captured maintained-source readback is unchanged. These are independently checked captured artifacts, not a fresh remote observation.
- Issuer requires exact five-file timing review (four inherited BTI files plus QSF), exact remaining gate-file review, and unchanged three-file inherited Work05 DDR source review. It requires exact issuer/runner/draft hashes in `handoff_files`, validates candidate and copied WORK bytes plus maintained before-bytes, and uses exclusive issuance lock and record creation. Draft pins issuer/runner hashes, verified here; consumed and inherited reviews are added as dependencies on issuance. The draft itself is pinned by the consumed handoff, avoiding a self-hash dependency.
- Runner uses the required tmux session, explicit 26.1.1 PATH, sanitized build options, exact native command, exclusive run directory/log, record/inventory preflight, native return code and rejection-marker handling. Readiness stays false; compilation/timing acceptance remains pending report review. The draft's approved, accepted_execution, source_review_consumed, gate_review_consumed and ready_for_build are all false.
- Parsed inert evidence contains 40 actual invocation cases: 12 positive and 28 negative, across candidate SOURCE and copied WORK entry modules. Missing-record evidence reports rejection before claim/native log. These are captured inert tests, not independently rerun native integration tests.

## Inherited constraints and hardware contract

The four BTI files are byte-identical to Work08: unconditional qsfp reference port, CC19/BW19 electrical/preservation assignments, replacement source-list entry and standalone 6.400 ns clock. Their applicability review is inherited except for the explicitly unresolved TRS exception question below. Full inventory comparison preserves AGFB027R25A2E2V, core470/seven requested PLL outputs, two 16GiB x64 no-ECC channels, BOT/BOT and whole-pair mapping, PCIe Gen4x16/PF1/BAR contracts. This is preservation evidence, not fresh hardware qualification.

Read the actual `../fim-build-08/timing-review-01/REPORT.md`: Work09 REPORT.md's statement that it was absent is incorrect and must not be propagated. It establishes real MSA setup failures -0.366/-0.236 ns at 333.33 MHz and independent EMIF1 hold -0.004 ns. Placement effort is a reasonable bounded experiment, not a proven remedy. Work08 native success does not override timing FAIL; images remain unqualified and are not to be programmed.

S1: the complete reported clock table and fit/STA token searches did not find the exact TRS oscillator, but fitted-resource absence remains unproven. Do not call S1 closed, restore a speculative exception, or conflate the different present `altera_int_osc_clk` with TRS. The existing oscillator-exception review's bounded fitted-node/clock/effective-exception interrogation is still required before final constraint acceptance. Its absence does not invalidate an authorized experiment that preserves the same constraints and makes no acceptance claim.

Other inherited final-acceptance issues in the actual timing review also persist: physically fitted unconstrained PCIe divider, BMC IRQ/JTAG timing policy and unresolved applicable ignored constraints/relationships. Even improved MSA slack cannot by itself establish timing or constraint completeness. No frequency retuning, false-path relaxation or hardware contract change is authorized by this review.

## Actionable handoff

Proceed to independent quality review against the exact hashes below. Any consumed `timing_review.accepted=true` must explicitly mean acceptance **for experimental execution**, with this open-gap disposition retained in the accompanying review evidence, not a claim of timing closure. Preserve ready_for_build=false and functional acceptance=false. Correct the missing-report statement in subsequent reporting; no candidate source edit is required for that documentation correction. The stale “Work08-only” gate docstring and issuer's incomplete review-schema docstring are nonfunctional documentation nits, not runtime binding defects.

No remote query, vendor launch, source change, DDR simulation, programming, commit or push was performed. Only this review file was created.

## Exact reviewed hashes

Paths below are relative to this directory unless prefixed `../`. Overlay table covers all inherited and changed source bytes; the export manifest binds the remainder of the captured package.

| File | SHA256 |
|---|---|
| `REPORT.md` | `f31085add67e7b281072e109c0964b8e0c01279a6823bcb18c2022ca2d7d46b9` |
| `candidate.patch` | `936beb30e027c06859fa5f8fc3b09a9f207afce2250f65d16cc55b09862513d4` |
| `remote-evidence/export-sha256.json` | `d2e37f9774ef76b9b739fbc9c12a0559303d52fcf2fe12bb7e5f1879848a5348` |
| `remote-evidence/overlay-sha256.json` | `1603de39d9819d59e57027af9a0c22d4e7a5b368c9e21bc92a14d8483964492b` |
| `remote-evidence/source-before.json` | `2ba69d521eeb6f12992df1c4102a6cebdb291a29bcfcad8d61099e16168edc9c` |
| `remote-evidence/compile-authorization.draft.json` | `1beb87ed2dbab43412b8e4bd94da5d06364341ee4deb89bb3587b03808b3cb66` |
| `remote-evidence/issue_authorization.py` | `83c1fd4a165e9842e7b8c5d83548bd01378ae6c89411984ad5c3969fb9af7495` |
| `remote-evidence/launch_native_compile.py` | `205f0f407fcc5ac166b45c9e5a5da6aa468a254bf693027286b36027b98421c7` |
| `remote-evidence/handoff-verification.json` | `875245f51f359374c4cbce54f65d47826ddfcd1e9c30fa730a6d8a97e5374741` |
| `remote-evidence/final-verification.json` | `7af842453ce0954c2a5b43437f25fc392cdaf9abdd9e56847c0b99cc0e45a0b3` |
| `remote-evidence/installed-option-evidence.json` | `05de79bffa471c0c32f6ec205a3c0aae273d930839982e1676efb15fe78e11f5` |
| `remote-evidence/real-dispatch-tests.log` | `6a3bfcf213ee358cfb10195334ed8c4c713317b203a271895f29fa35ea36fc6d` |
| `remote-evidence/staged-work-inventory.json` | `a9fa55fba71133424dca89069664e8b29d08c3bbe2c7dbf55f04d4018be85fbc` |
| `remote-evidence/source-overlay/syn/board/ia840f/setup/emif_loc.tcl` | `a48a84b89fd6c5d5fd36c87cfe5c7d03264f3dea08ea6a447151351a21b523c3` |
| `remote-evidence/source-overlay/syn/board/ia840f/source_manifest.json` | `82d5dabdc760bb24128ab0c9a5c96650da2d72f6d16f88f2d0d1780e4e745b0e` |
| `remote-evidence/source-overlay/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv` | `b9b0deb0582d554cb2178ed4ee090c088d9841951b19d1223cd4ca96bd9498a1` |
| `remote-evidence/source-overlay/ofs-common/tools/ofss_config/ia840f_experimental_gate.py` | `4d552ad4aca740501e29578608a4d023acc930e607eb4600d2f60da951ef8b0b` |
| `remote-evidence/source-overlay/ofs-common/tools/ofss_config/ia840f_compile_gate.py` | `fa62f29c9d4beab38bf8566f4b2ab4518deb50a56e1afdcb768b298a059610b6` |
| `remote-evidence/source-overlay/ofs-common/tools/ofss_config/test_ia840f_compile_gate.py` | `d53dd05b86fbb93393033b6aef170e31ab7fbd517a0fb00259ffc603268e26e2` |
| `remote-evidence/source-overlay/ofs-common/scripts/common/syn/build_fim_compile.sh` | `0514c9be94702a7ec87e16d6e90d844e37a48d097aecc73a0a731331650c7c07` |
| `remote-evidence/source-overlay/src/board/ia840f/top.sv` | `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d` |
| `remote-evidence/source-overlay/syn/board/ia840f/setup/top_loc.tcl` | `07a08b895a30f12c9553647073ec6a8d7243f2ca92ce70fd0b1ae5bd698a5be2` |
| `remote-evidence/source-overlay/syn/board/ia840f/syn_top/ofs_top_sources.tcl` | `2056aeb757e8e27eff0aa2589f6e997a52595b095ca18802ecad1819665ba2aa` |
| `remote-evidence/source-overlay/syn/board/ia840f/setup/bti_refclk.sdc` | `01b76a80f664c4ec0bf553874c68c7f71878642f205080e29727e50ce71c3cac` |
| `remote-evidence/source-overlay/syn/board/ia840f/syn_top/ofs_top.qsf` | `ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3` |
| `../fim-build-08/spec-review.md` | `87aad7dc0bcc0b6f03247197de688a039637856a05f853884c4c4f7b02b4edc2` |
| `../fim-build-08/oscillator-exception-review.md` | `8f906bb47f06929a150ba22835c392faf2be03f54eea04f4c4093d1707822e98` |
| `../fim-build-08/timing-review-01/REPORT.md` | `908e5c33c84fe04c151abe652ee4ed1c01f528b026777109d42f7dc2d7ed37ba` |
| `../fim-build-08/remote-evidence/compile-authorization.json` | `81ebc5ae0c4811d3618af78dd8db034a7310bad7f2bbb18272224c66763f9bf7` |
