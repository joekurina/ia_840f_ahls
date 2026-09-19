# Work11 aggressive-hold-only experiment — prepared, not authorized or launched

## Outcome and review boundary
Fresh remote `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11` and `qualification/fim-build-11` are prepared for independent specification and quality review. All draft approval, review-consumption, execution and readiness flags remain false. No real Work11 authorization, issuance lock, native claim, run directory or build log was created. Maintained SOURCE is unchanged. This is review readiness, not build readiness or timing acceptance.

All remote preparation, tests and export ran in owned windows/panes `%393`, `%394`, `%395` of `ia840f_mailbox_monitored_01`, with asserted Agilex7Workstation hostname and UID 1000. No compile, simulation, Query04, hardware action, permission change, installation or commit occurred. Native-stage commands below were deliberately rejected before launch. Source-bound gates are not an OS sandbox.

## Exact experiment
`remote-evidence/candidate.patch` has exactly three changed files relative to verified live remote SOURCE:
- `syn/board/ia840f/syn_top/ofs_top.qsf`: append only `set_global_assignment -name TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON`.
- `ofs-common/tools/ofss_config/ia840f_compile_gate.py`: WORK/EVIDENCE 10 → 11.
- `ofs-common/tools/ofss_config/ia840f_experimental_gate.py`: actual Quartus entry dispatcher cwd 10 → 11.

The QSF baseline is `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293`; candidate is `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`. SEED 2, SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT, SPEED, MAXIMUM router effort, RTL, SDC, clocks, memory geometry, PF/BAR contracts and pins are unchanged. The stale local maintained QSF was neither used nor overwritten. Native Work10 optimization-mode migration is not copied into SOURCE.

Capability grounding is `../router-native-capability-01/REPORT.md` and its native evidence: the exact-device Agilex 7 global/fitter APIs list this assignment, legal values On/Off, native default OFF, and scratch reopen returns ON. That is prior native capability evidence, not Work11 timing evidence. No minimal scratch QSF or its native power-management initialization defaults were copied. This is a hold-only experiment targeting the repeated -0.004 ns PHY violation, **not a setup-recovery claim**; setup, area or runtime may worsen.

## Fresh staging and preserved bindings
The full Work04 generation tree matched its prior recorded inventory before copying and after all tests. The fresh copy was hash-verified before 170 recorded relocations. Its inherited QDB/output directories and experimental authorization were archived under remote `inherited-output/`; no compiled Work10 QDB was reused. All staged symlinks resolve inside WORK. The draft binds 5,564 WORK files/symlinks, 12 overlay files, 106 dependencies and 10 runtime tools.

Full live SOURCE and PIM inventories matched the prior issued record before staging; outer/inner tool hashes were reread. SOURCE remained unchanged afterward. Work10 authorization, claim, finished status and native log were hashed before/after and are unchanged. Work10 WORK/images were not written or used as staging inputs. Evidence: `preparation-preflight.json`, `work04-before.json`, `staged-work-inventory.json`, `staging-receipt.json`, and `final-verification.json` under `remote-evidence/`.

The complete 135-context table equals Work10 after only the work-root substitution. Actual entry dispatch, exact executable/argv/cwd/hash grammar, process ancestry/start-time checks, readiness/options/source/tool/dependency checks and rejection behavior are preserved. Issuer and runner are mechanically retargeted Work10 bytes, verified locally against the prior package; no generic framework or weakened gate was introduced.

## Executed regressions
- Remote compile-gate suite: **8 tests PASS**; positive claim and source/tool/part/readiness/review/work/options/argv/cwd/symlink/ancestry mutations.
- Actual candidate SOURCE-overlay and copied-WORK dispatch: **40 invocations PASS**, **12 positive / 28 negative**. Production entry, load-record and runtime checks execute against real paths/hashes; future approval/claim/process identity is explicitly inert fixture data. No vendor child runs.
- **3 real missing-Work11-record rejection paths PASS**: copied Python entry, build_top shell, build_fim_compile shell. Each rejects specifically for absent `qualification/fim-build-11/compile-authorization.json`, with no native log, claim or run directory.
- Local issuer: **2 tests PASS**, including exclusive repeat and five negative review/handoff/stale-source/inherited-review subcases. Its printed issuance is confined to temporary inert fixtures, not a remote authorization.
- Local runner: **3 tests PASS** with real inert Python children. Exit 7 propagates; zero with rejection marker fails; clean zero is exit-only acceptance. Repeated execution preserves existing evidence bytes.
- Local package verifier PASS: **44 exported files** hash-verified, exact patch reconstructed, all overlays matched to SOURCE/WORK draft inventories, exactly three SOURCE changes, issuer/runner equivalence and all 135 contexts checked. `verify_package.py` is reproducible without remote access.

The unique export batch `work11-review-export-01` whole-wire SHA256 matched the remotely printed value: `e7d69ec5155dae4f7f1f53dd3c45c25696967627d411eda270fb364eae1e4fb0`. `remote-evidence/export-sha256.json` is the remote file manifest; `package-sha256.json` covers the local review package except itself. Preparation scripts, exact remote payloads, console captures and regression logs are retained. No preparation/test failure occurred.

## Required independent review and later acceptance
Review `candidate.patch`, both gate overlays, `issue_authorization.py`, `launch_native_compile.py`, `compile-authorization.draft.json`, inventories and regression evidence. The issuer still requires exact five-file `timing_review` coverage (top.sv, top_loc.tcl, ofs_top_sources.tcl, bti_refclk.sdc, QSF), inherited three-file Work05 DDR source review, remaining gate-file coverage, and issuer/runner/draft handoff hashes. No Work11 consumed-review record is manufactured. Any later timing-review acceptance means permission for this bounded experiment, not timing closure. Source synchronization and authorization issuance remain later reviewed actions; compilation was expressly not launched here.

Parent-provided completed Work10 baseline: native fit/STA/assembly exit zero, but EMIF0 setup -0.508 ns / TNS -185.081 ns / 711 failing endpoints; EMIF1 setup -0.170 ns / TNS -29.340 ns / 403 endpoints; hold -0.004 ns; one unconstrained clock and two inputs/two outputs. These baseline figures are context supplied by the parent, not a newly parsed Work11 result. Preserve all Work10 failed timing reports and images.

An eventual run must compare every analyzed corner, **both DDR channels' setup and hold WNS/TNS/failing endpoints**, PHY hold paths, routing/cell composition, transformation counts and warnings, effective settings/native QSF migration, clocks and constraint completeness, ignored constraints/relationships and unconstrained paths against Work10. S1/TRS applicability, PCIe divider and BMC IRQ/JTAG policy remain open. Preserve full native logs/return codes and assembly/image size/SHA256 inventory; an assembled image is not timing or functional acceptance and is not authorization to program hardware. No expected setup recovery is claimed. Keep `ready_for_build=false` until full acceptance is established.

## Key SHA256
| Artifact | SHA256 |
|---|---|
| candidate.patch | f6c8092099e83429f63004818e162d853d1b32e2c89cd8864bc14092d258f4ce |
| issue_authorization.py | e773fb2d445da6b92c0cddbc9c6b707faf31184364700cf6df9470a43a00c07a |
| launch_native_compile.py | f4d41bf2c0a5ab48912ce669a86b0c0d91fa5b18affdf4a8d62d992fbeb57389 |
| compile-authorization.draft.json | 10fa545ac9be6b79b75e26619ad3361939c30383ef8dafbb584c08a865d44300 |
