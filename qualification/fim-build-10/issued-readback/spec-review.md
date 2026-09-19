# Work10 independent specification review

**Verdict: PASS — ready for a fresh independent quality review.**

No blocking specification discrepancies were found in the hash-bound package below. This is a focused review of the seed-only successor and its mechanical handoff/gate retarget, not requalification of the accepted unchanged framework. It is not authorization issuance, launch permission consumption, timing closure, or functional/build readiness. Parent must read this review and obtain the fresh quality review before launch.

## Scope and method

Review performed locally against the exported actual remote SOURCE baseline, candidate overlays, complete patch, draft, actual issuer/runner, preparation code, inventories and test evidence. Independent read-only Python assertions recomputed SHA256 for all 60 entries of `package-sha256.json` and all 44 exported entries, reconstructed the entire patch, compared full SOURCE/PIM/tool/context records with Work09, and reconstructed staged WORK inventory from Work04 plus archives/relocations/overlays. All assertions passed. No provided preparation/issuer/runner/native script was executed. Test results below were verified from bound logs and inspected test implementations, not independently rerun. No remote connection, Query04 access/retry, authorization, claim, vendor compile, simulation, hardware operation, code change, or commit was performed. Only this review is written.

## Specification findings

1. **Exact experimental delta PASS.** The full SOURCE inventory equals the recorded remote Work09 SOURCE baseline with exactly three files changed: `ofs_top.qsf` SEED 1 → 2; compile gate WORK/EVIDENCE 09 → 10; actual experimental dispatcher Quartus cwd 09 → 10. The reconstructed unified patch equals `candidate.patch` byte-for-byte. Baseline QSF is `ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3`; candidate is `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293`. The retained mode is exactly `SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT`, alongside SPEED and MAXIMUM router timing optimization. No stale local QSF substitution or Work09 native option migration was incorporated.
2. **Contract preservation PASS.** All other SOURCE entries and PIM inventory match the predecessor. All 12 overlays bind to both draft SOURCE and staged WORK. Nine overlays are byte-identical to remote baseline. No RTL, SDC, clock, geometry, PF/BAR, pin or BMC changes are introduced. This preserves the experiment's existing AGFB027R25A2E2V, core470/seven-PLL requests, DDR333 and two 16-GiB x64 no-ECC BOT/BOT contract; preservation is not new validation of those contracts.
3. **Fresh staging PASS.** `stage_remote.py` exclusively copies `work_ia840f_ipgen_04`, not compiled Work09, checks the copy, archives qdb/output_files/inherited authorization, relocates paths, applies overlays and verifies symlinks stay in WORK. Independently reconstructed all 5,564 final inventory entries from the recorded Work04 inventory by removing the six archived inventory entries, applying 170 recorded relocations and 12 overlays. Result equals both staged inventory and draft. Work04-before equals Work09's preserved generation inventory. Exported final/preflight evidence records unchanged full SOURCE, unchanged Work04, and preserved hashes for Work09 authorization, claim, finished status and log. This is local verification of captured evidence, not a fresh live-host attestation or inspection of every archived binary.
4. **Runtime gate preservation PASS.** All 135 executable/hash/argv/cwd contexts equal Work09 after only the WORK-root substitution; ten native executable identities remain. Outer/inner tool tables and PIM are identical. All 106 dependency pins remain bound, with no Work09 evidence path reused as a successor dependency. Changes to dependency values are exactly the new issuer, runner, overlay manifest, before manifest and staging receipt. Production `load_record` checks source/PIM/tool/dependency identities, readiness false and exact native binding. Production native entry verifies inventory, environment, real executable/argv/cwd and creates the claim with exclusive `x`; callback validation checks record hash, live ancestry and start ticks plus exact native parent identity and finite runtime context. The actual dispatcher now selects this gate from Work10 PROJECT cwd. No grammar broadening or weakening occurred. These controls are source-bound guards, not an OS sandbox.
5. **Issuer/runner coverage PASS.** Actual issuer and runner are byte-exact Work09→Work10 mechanical retargets. Issuer requires exact five-file `timing_review` equality including seed-2 QSF (top.sv, top_loc.tcl, ofs_top_sources.tcl, bti_refclk.sdc, ofs_top.qsf); inherited Work05 review still covers precisely the three unchanged DDR source repair files; remaining four overlay files require exact gate review. Handoff review must pin issuer, runner and draft. Issuer checks overlay/WORK/current SOURCE hashes and inventory before its exclusive issuance lock and subsequent synchronization. Full SOURCE inventory is checked after synchronization before exclusive authorization creation; this is not claimed to be an atomic rollback transaction. Runner validates authorization/environment/WORK, reserves run directory and evidence exclusively, propagates native exit and rejection-marker failure, and never converts exit zero into timing/functional acceptance. Consumed Work09 authorization/claim is not reused. This review does not create consumed-reviews JSON.
6. **Draft boundary PASS.** `approved`, `accepted_execution`, `source_review_consumed`, `gate_review_consumed` and `ready_for_build` are all false. Bound final evidence records no issued authorization or Quartus start and preparation asserts absence of Work10 authorization, claim, run directory and native build log. There is no author-claimed Work10 vendor run.

## Test-evidence reconciliation

| Evidence | Verified result | Meaning and limit |
|---|---|---|
| real-dispatch-tests.log + test_real_dispatch.py | 40 invocations: 12 positive, 28 negative | Both overlay and copied-WORK production entry/runtime paths; mocked future record/claim/process identities, real recorded path/hash checks; no vendor child |
| compile-gate-tests.log + bound test_ia840f_compile_gate.py | 8 tests, OK | Inert policy fixtures including claim, identity/source/tool/readiness/options/inventory/ancestry rejection; not vendor integration |
| missing-work10-record-tests.json | 3 nonzero rejections at the exact absent Work10 compile-authorization.json | Copied entry, build_top and build_fim_compile; preparation/final evidence asserts no native log/claim/run side effects |
| issuer-tests.log + test_issuer.py | 2 tests, OK | Temporary inert fixture issuance, exclusive reissue rejection and negative timing/gate/handoff/source/inherited review subcases; fixture success is not remote issuance |
| runner-tests.log + test_runner.py | 3 tests, OK | Actual inert Python children: exit 7 propagated, rejection-marked zero rejected, clean zero exit-only acceptance; repeated run preserves bytes |

The issuer fixture uses a reduced overlay set; exact production five-file timing coverage was therefore independently checked in the actual issuer and full 12-file manifest rather than inferred from the two-test count. The unchanged compile test carries historical Work05 naming in one log check; the three explicit Work10 missing-record checks and preparation no-side-effect assertions provide the successor-specific coverage. Historical Work07/Work08 comments in inherited helpers are nonfunctional stale labels, not runtime retarget defects. No code churn is requested for these inherited comments.

## Timing rationale and acceptance still open

The separately captured installed seed help permits a non-negative placement seed and explicitly warns improvement is not guaranteed. The linked seed-2 rationale documents routing-majority EMIF scheduler feedback paths with material logic depth; hidden DERIVED latency parameters and protected internal RTL do not justify an unsupported pipeline edit. Seed 2 is a single-variable placement experiment, not a demonstrated fix. The report preserves Work09 setup failures (EMIF0 -0.435 ns, EMIF1 -0.313 ns), EMIF1 PHY hold -0.004 ns, one unconstrained clock and two inputs/two outputs. S1/TRS fitted-resource applicability, PCIe divider constraints, BMC IRQ/JTAG and other applicable ignored constraints remain unresolved. Query04 stays blocked; it was not accessed. Existing Work08 timing evidence is not declared absent.

An eventual result must compare both DDR WNS/TNS/failing endpoints and routing/cell composition, all hold checks, clocks, unconstrained paths and ignored-constraint diagnostics. An image or native zero exit cannot establish acceptance. Future timing-review acceptance may mean only acceptance of this bounded unchanged-constraint experiment. `ready_for_build` must remain false pending the actual acceptance work.

## Exact review coverage and SHA256 bindings

Paths below are relative to this Work10 evidence directory. All package entries were independently digest-verified; semantic inspection focused on the files and comparisons described above, not a new line-by-line qualification of unchanged framework/RTL. The complete package manifest is itself pinned here. The predecessor and rationale support files are pinned separately below. Any change to candidate, gate, issuer, runner, draft or supporting bound evidence invalidates this review's applicability to the changed bytes.

| File | SHA256 |
|---|---|
| `REPORT.md` | `685367d05cbafbef61413b38062cbb68478d9d9fbc0d3eb1488a412eeaa7df04` |
| `export_remote.pane` | `76a01bff14d584a782b3680c16c8f9b85448c1d8b3980b771d040ee9d50f1fa5` |
| `export_remote.py` | `b2506e0d92a37ab9184e35e6d16cfae1eb353d1090ce59abb00ac82598cdb24f` |
| `issuer-tests.log` | `42d779b3b01d9814cdf7003dbfb90cc4d3372dee48167062e05e9b706ddf15bf` |
| `local-verification.json` | `1b87459028b0b15fea909d09999c240da35e651aa9e1556f3c3c46d7ba3e2d8d` |
| `package-sha256.json` | `fb666ce47c0bf2527dd3c164a185026ce0336702a2bc64ea6ceccf68f7c5ae39` |
| `preflight_remote.pane` | `a79a10b1e79ed01a15032e1bdd401e4019715cf918a4dbd0da838b44aa8c4334` |
| `preflight_remote.py` | `ec00481db8e8586bd83ade44a7fa164217f8cc0cd8939ab1e21f7a34815d08ec` |
| `prepare_remote.pane` | `d2d19a813e29b0dd47329394af6f5ece4b0d7d9b90ce52a12c468e066ba73497` |
| `prepare_remote.py` | `0324200e4a2756b01ce17fae4e90e2d3d29b87cec338a4653e04d2539e8ce57c` |
| `remote-evidence/candidate.patch` | `d3fc5a1a81abb2c9c711c7fa5ba715c90b361570598e09769dd563e84300b2de` |
| `remote-evidence/compile-authorization.draft.json` | `3946f9994cae8c459a69ca1f09758ec1dafc2e3c434c30b7d815b0a1831ea947` |
| `remote-evidence/compile-gate-tests.log` | `87f7147fd5cb582ac56150ae191a8503a48bf6f56c729357de454e3ecf0bd31c` |
| `remote-evidence/export-sha256.json` | `e305579e97bdb761c7e2e44712dfd2f9414e607d141fdbf6681fb903db2e3a49` |
| `remote-evidence/final-verification.json` | `ca9e595a6f4e3a924769e77c25925ebd3c8134d5e3453d3ae0757c2fd3d856e7` |
| `remote-evidence/handoff-verification.json` | `3227d8786fa62bcf12e9480ff8c15554b61f57c2f6a6491dc81646aba28e227e` |
| `remote-evidence/issue_authorization.py` | `c01c585bd2ac2193f46df49f2630cb9ae56c875e392a849c4b8ee77b70ba81f1` |
| `remote-evidence/launch_native_compile.py` | `31beb72d84a1a5bafc4226f7145a8a0414dc8883b44a36825fae089756581895` |
| `remote-evidence/missing-record-rejection.log` | `7c9b5a622e800f899303f836bc0b59abce71c248fcc2a290f9373499612d8317` |
| `remote-evidence/missing-work10-record-tests.json` | `2d7790003c35eb93f2f718dcf87f878503569519178d8fbffab63232a628a12b` |
| `remote-evidence/overlay-sha256.json` | `8fa1f10ae399c621132200ed1dd6608b64c9c54891694831298b2bf93299d2ba` |
| `remote-evidence/preparation-preflight.json` | `9f86ab0ac6b6d92e99c2f17c36fee7579cc97ea651865a77d5be17c5bf117902` |
| `remote-evidence/prepare_handoff_remote.py` | `726c24cc1cb3caf8eae4f6669da90225a30880a689b43e48d8dad510e80b18c2` |
| `remote-evidence/real-dispatch-tests.log` | `0670949d6a71ea8ce007a21e1269c15e7a610484037af15de90119e472618613` |
| `remote-evidence/relocations.json` | `4024348f0d03d403611963ea1380a2242401a3fda1d67644f25c1451c1793124` |
| `remote-evidence/source-before.json` | `1603de39d9819d59e57027af9a0c22d4e7a5b368c9e21bc92a14d8483964492b` |
| `remote-evidence/source-before/ofs-common/scripts/common/syn/build_fim_compile.sh` | `0514c9be94702a7ec87e16d6e90d844e37a48d097aecc73a0a731331650c7c07` |
| `remote-evidence/source-before/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv` | `b9b0deb0582d554cb2178ed4ee090c088d9841951b19d1223cd4ca96bd9498a1` |
| `remote-evidence/source-before/ofs-common/tools/ofss_config/ia840f_compile_gate.py` | `fa62f29c9d4beab38bf8566f4b2ab4518deb50a56e1afdcb768b298a059610b6` |
| `remote-evidence/source-before/ofs-common/tools/ofss_config/ia840f_experimental_gate.py` | `4d552ad4aca740501e29578608a4d023acc930e607eb4600d2f60da951ef8b0b` |
| `remote-evidence/source-before/ofs-common/tools/ofss_config/test_ia840f_compile_gate.py` | `d53dd05b86fbb93393033b6aef170e31ab7fbd517a0fb00259ffc603268e26e2` |
| `remote-evidence/source-before/src/board/ia840f/top.sv` | `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d` |
| `remote-evidence/source-before/syn/board/ia840f/setup/bti_refclk.sdc` | `01b76a80f664c4ec0bf553874c68c7f71878642f205080e29727e50ce71c3cac` |
| `remote-evidence/source-before/syn/board/ia840f/setup/emif_loc.tcl` | `a48a84b89fd6c5d5fd36c87cfe5c7d03264f3dea08ea6a447151351a21b523c3` |
| `remote-evidence/source-before/syn/board/ia840f/setup/top_loc.tcl` | `07a08b895a30f12c9553647073ec6a8d7243f2ca92ce70fd0b1ae5bd698a5be2` |
| `remote-evidence/source-before/syn/board/ia840f/source_manifest.json` | `82d5dabdc760bb24128ab0c9a5c96650da2d72f6d16f88f2d0d1780e4e745b0e` |
| `remote-evidence/source-before/syn/board/ia840f/syn_top/ofs_top.qsf` | `ea5b7bfd3f1d5f35092afe7db1a0497033ed8d08d85b5fa82d4c8d7a16a243c3` |
| `remote-evidence/source-before/syn/board/ia840f/syn_top/ofs_top_sources.tcl` | `2056aeb757e8e27eff0aa2589f6e997a52595b095ca18802ecad1819665ba2aa` |
| `remote-evidence/source-overlay/ofs-common/scripts/common/syn/build_fim_compile.sh` | `0514c9be94702a7ec87e16d6e90d844e37a48d097aecc73a0a731331650c7c07` |
| `remote-evidence/source-overlay/ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv` | `b9b0deb0582d554cb2178ed4ee090c088d9841951b19d1223cd4ca96bd9498a1` |
| `remote-evidence/source-overlay/ofs-common/tools/ofss_config/ia840f_compile_gate.py` | `1f147c46af7fe3e34e65eabeb6519fef0d6ff80ef7adc0a882e707caaeef3135` |
| `remote-evidence/source-overlay/ofs-common/tools/ofss_config/ia840f_experimental_gate.py` | `ded3e1213e9bbfce5335070c65553ff5d40a5e30eb46f8845ccc0c23f66aa365` |
| `remote-evidence/source-overlay/ofs-common/tools/ofss_config/test_ia840f_compile_gate.py` | `d53dd05b86fbb93393033b6aef170e31ab7fbd517a0fb00259ffc603268e26e2` |
| `remote-evidence/source-overlay/src/board/ia840f/top.sv` | `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d` |
| `remote-evidence/source-overlay/syn/board/ia840f/setup/bti_refclk.sdc` | `01b76a80f664c4ec0bf553874c68c7f71878642f205080e29727e50ce71c3cac` |
| `remote-evidence/source-overlay/syn/board/ia840f/setup/emif_loc.tcl` | `a48a84b89fd6c5d5fd36c87cfe5c7d03264f3dea08ea6a447151351a21b523c3` |
| `remote-evidence/source-overlay/syn/board/ia840f/setup/top_loc.tcl` | `07a08b895a30f12c9553647073ec6a8d7243f2ca92ce70fd0b1ae5bd698a5be2` |
| `remote-evidence/source-overlay/syn/board/ia840f/source_manifest.json` | `82d5dabdc760bb24128ab0c9a5c96650da2d72f6d16f88f2d0d1780e4e745b0e` |
| `remote-evidence/source-overlay/syn/board/ia840f/syn_top/ofs_top.qsf` | `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293` |
| `remote-evidence/source-overlay/syn/board/ia840f/syn_top/ofs_top_sources.tcl` | `2056aeb757e8e27eff0aa2589f6e997a52595b095ca18802ecad1819665ba2aa` |
| `remote-evidence/stage_remote.py` | `45ad28ac249934a1040e8842256534179bb1cae497bdab04f06793bc00bed077` |
| `remote-evidence/staged-work-inventory.json` | `f9486c1fcbf635d10c3a1f5902724ed3c4626d71307ce091d0e6f30db77a8754` |
| `remote-evidence/staging-receipt.json` | `82989773bb2eec23985a54f1563608083b364eebc3147092deecd5d02d85c7ae` |
| `remote-evidence/test_real_dispatch.py` | `d2ba0baa8e56a8f89e89e604a0bc0941b030371d8ac12010f19ebdc352759130` |
| `remote-evidence/work04-before.json` | `57dd48021ff22c165796b522cb1695625cfadcd0be0e42557786a774b9200cd7` |
| `remote_driver.py` | `4ad602ebaf00abedff9ce20cc6d3e9a875da3b4b711f160737d2439705037bac` |
| `runner-tests.log` | `4e39572beffcdc5245130b072410072db703e522a774f790531205d77d35a925` |
| `test_issuer.py` | `e086d2615684293653ab919c2e554afe089d0616a92c402571e830f0428059ec` |
| `test_runner.py` | `8736c18b44dcf9bb6157cfe6b53012011d2b7c4a27a7239e3d3c8533e66075f1` |
| `transfer-verification.json` | `0e83b02b3443872da46673a2dc697f8650038b0b98757bda08675e2d76abf8b2` |
| `verify_package.py` | `e3a3fe89df51c99ae00ee253c2570ef3074dbff799e8ea9706ea3fd7577b1035` |

### Supporting predecessor and rationale bindings

| File relative to Work10 | SHA256 |
|---|---|
| `../fim-build-09/remote-evidence/compile-authorization.draft.json` | `1beb87ed2dbab43412b8e4bd94da5d06364341ee4deb89bb3587b03808b3cb66` |
| `../fim-build-09/remote-evidence/work04-before.json` | `57dd48021ff22c165796b522cb1695625cfadcd0be0e42557786a774b9200cd7` |
| `../fim-build-09/remote-evidence/issue_authorization.py` | `83c1fd4a165e9842e7b8c5d83548bd01378ae6c89411984ad5c3969fb9af7495` |
| `../fim-build-09/remote-evidence/launch_native_compile.py` | `205f0f407fcc5ac166b45c9e5a5da6aa468a254bf693027286b36027b98421c7` |
| `../msa-timing-candidate-seed2/REPORT.md` | `72b448bd81e5c85fdc0d5676da282682f568acc275b8af102963007e828ea780` |
| `../msa-timing-candidate-seed2/verification.json` | `a290dfcf4221431c0a18a78f2cf8b8b426a63806b01adf6aee2511d2528d61c5` |
| `../msa-timing-candidate-seed2/remote-static.json` | `6fe97dabfce0bc2580518fbae05a205a15293fbab063fc7ec5f78d9febf7bfbb` |

**Disposition:** specification PASS; no blocking discrepancies. Ready for the separate quality reviewer, not launched or authorized by this document.
