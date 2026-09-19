# Work11 independent specification review

## Verdict: PASS — bounded experimental specification only

No must-fix specification findings. This review accepts the exact packaged Work11 candidate for the later independent review-consumption/issuance process. It does **not** issue or consume authorization, authorize hardware programming, establish native Work11 execution, accept timing/functional results, or set build readiness. All draft approval, consumption, execution and readiness flags remain false.

## Independent verification

- Rehashed all 65 entries of the existing package manifest and all 44 remote exports. Re-executed the package verifier in a disposable isolated copy with the prior Work10 evidence available; its recomputed local-verification.json exactly matched the packaged result. Original evidence was not rewritten.
- Reconstructed candidate.patch from the actual exported before/overlay bytes. Exactly three files change: one appended QSF assignment and mechanical Work10-to-Work11 retargets of compile-gate WORK/EVIDENCE and the actual entry-dispatch cwd. No context grammar, options, ancestry or fail-closed validation changed; all 135 contexts equal the prior table under the work-root substitution.
- Baseline QSF SHA256 is `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293`. The sole experimental delta is `set_global_assignment -name TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON`. Seed 2, maximum-placement source spelling, SPEED and MAXIMUM router effort remain intact. Exact full SOURCE inventory comparison shows only these three changes; RTL, SDC, clocking, geometry, PF/BAR and pin contracts are unchanged.
- Independently reconstructed the entire 5,564-entry staged inventory from the recorded Work04 inventory, removing the specified inherited output/QDB/authorization paths, applying all 170 relocation records with checked before values, then applying 12 overlays. Result exactly equals the draft and staged inventory. Work04 inventory equals the prior recorded generation-tree inventory. This is fresh generation-tree staging, not reuse of Work10 compiled QDB. Receipt inventory byte hashes also match.
- Full recorded SOURCE baseline equals the previous draft source inventory; PIM's 530 entries and both outer/inner tool maps are unchanged. The draft binds 10 distinct runtime executable identities and 106 dependencies; non-Work11 dependency hashes remain equal to prior pins, while all five Work11 dependency artifacts rehash correctly. Exported preparation code performs live SOURCE/PIM/tool and Work04 checks before staging and rechecks SOURCE, Work04 and four Work10 historical artifacts afterward. Final recorded evidence reports no authorization, claim, run directory or native log. This review validates the exported evidence, not a new live remote read.
- Inspected exact issuer/runner source and verified mechanical equivalence to Work10. Re-executed local inert issuer tests (2 tests, including five negative subcases) and runner tests (3 tests) successfully in the isolated copy. Runner exit/rejection propagation and exclusive evidence preservation are tested; clean exit alone remains non-functional acceptance.
- Inspected the recorded eight passing compile-gate tests, actual dispatch harness and 40 recorded invocations (12 positive/28 negative), and all three missing-Work11-record rejection paths. Dispatch exercises production entry/runtime validation against real paths but uses explicitly inert future record/claim/process identities; no vendor child is run. These remote regressions were reviewed, not re-executed remotely.

## Native applicability and acceptance boundary

Read the prior native capability report and actual capability/default/readback logs. Exact device AGFB027R25A2E2V identifies Agilex 7; the family/fitter lists include this assignment, native metadata lists On/Off, default is OFF and scratch reopen reads ON. Capability log SHA256 `0280128b32ebb3ee36bf8df7fc92b1805afdbb2229d1bc3c9790f91c418c4872`; alternative log SHA256 `5e921d58401880e1f46537837782c0eaa2144b44cd8bd83bb1a7d303b03b3a3e` were recomputed. No scratch power-management defaults are introduced by this patch.

This is permission to test a supported **hold-only** change, not a setup fix or timing-closure finding. A setup fix is not a prerequisite to this bounded experiment. Existing setup failures and S1/TRS, PCIe-divider, BMC IRQ/JTAG and unconstrained-path questions remain open. Later acceptance must inspect both DDR channels, all timing corners, setup/hold WNS/TNS/failing endpoints, PHY hold paths, effective settings/native QSF migration, constraints, warnings, complete logs and image inventories. Assembly or native exit zero alone is insufficient. Source-bound guards are not an OS sandbox.

## Exact review-consumption coverage

The issuer requires exact equality of the following file/hash maps, not partial coverage. These are specification-review-approved bindings for the bounded experiment; this document is not itself a consumed-reviews JSON or a substitute for the independent quality/gate review. The issuer must still consume the required reviews and revalidate current bytes before any later launch.

### timing_review — five files; experimental permission, not timing acceptance

| Relative path | SHA256 |
|---|---|
| `src/board/ia840f/top.sv` | `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d` |
| `syn/board/ia840f/setup/top_loc.tcl` | `07a08b895a30f12c9553647073ec6a8d7243f2ca92ce70fd0b1ae5bd698a5be2` |
| `syn/board/ia840f/syn_top/ofs_top_sources.tcl` | `2056aeb757e8e27eff0aa2589f6e997a52595b095ca18802ecad1819665ba2aa` |
| `syn/board/ia840f/setup/bti_refclk.sdc` | `01b76a80f664c4ec0bf553874c68c7f71878642f205080e29727e50ce71c3cac` |
| `syn/board/ia840f/syn_top/ofs_top.qsf` | `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c` |

### Inherited Work05 source_review — three unchanged DDR files

| Relative path | SHA256 |
|---|---|
| `syn/board/ia840f/setup/emif_loc.tcl` | `a48a84b89fd6c5d5fd36c87cfe5c7d03264f3dea08ea6a447151351a21b523c3` |
| `syn/board/ia840f/source_manifest.json` | `82d5dabdc760bb24128ab0c9a5c96650da2d72f6d16f88f2d0d1780e4e745b0e` |
| `ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv` | `b9b0deb0582d554cb2178ed4ee090c088d9841951b19d1223cd4ca96bd9498a1` |

### gate_review — four remaining overlays

| Relative path | SHA256 |
|---|---|
| `ofs-common/tools/ofss_config/ia840f_experimental_gate.py` | `4bd00f70a301b6ec66592544a4b637e75ab396f907afdf40e0facfcf707de9f8` |
| `ofs-common/tools/ofss_config/ia840f_compile_gate.py` | `6492a6b5d1a1b347d1fe9f6f077d3e9f09bee2744590592a615f3ba03174bf64` |
| `ofs-common/tools/ofss_config/test_ia840f_compile_gate.py` | `d53dd05b86fbb93393033b6aef170e31ab7fbd517a0fb00259ffc603268e26e2` |
| `ofs-common/scripts/common/syn/build_fim_compile.sh` | `0514c9be94702a7ec87e16d6e90d844e37a48d097aecc73a0a731331650c7c07` |

The inherited Work05 accepted source review is required at issuance and remains dependency-pinned. It is not manufactured or consumed by this review. Handoff coverage is exactly issuer, runner and draft below.

## Hash-bound review target

| Artifact | SHA256 |
|---|---|
| `package-sha256.json` | `d81ef1ef7948056d50818dc6d7915c32bfbca6ddcb6f81966ef3204e8d91e082` |
| `REPORT.md` | `3ee6e7d68634965bdc78a4c6766b2817fc35cb7244e4ef8b4da9d97de458da31` |
| `verify_package.py` | `32badae14d234133fc075f7a43b36970711f6d15d6e4194a4d8b07b9d580fd92` |
| `remote-evidence/export-sha256.json` | `72860993d0ea339cb5d4ac077032dc52adb3ef8d85fbc00749dc01d346054a3d` |
| `remote-evidence/candidate.patch` | `f6c8092099e83429f63004818e162d853d1b32e2c89cd8864bc14092d258f4ce` |
| `remote-evidence/issue_authorization.py` | `e773fb2d445da6b92c0cddbc9c6b707faf31184364700cf6df9470a43a00c07a` |
| `remote-evidence/launch_native_compile.py` | `f4d41bf2c0a5ab48912ce669a86b0c0d91fa5b18affdf4a8d62d992fbeb57389` |
| `remote-evidence/compile-authorization.draft.json` | `10fa545ac9be6b79b75e26619ad3361939c30383ef8dafbb584c08a865d44300` |

Only `spec-review.md` was created in the package by this review. No source/code edits, remote operations, vendor invocations, authorization consumption or commits were performed. The original 65-entry manifest is preserved; this review is an additional artifact outside that manifest.
