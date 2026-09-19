# Work11 independent code-quality and execution-gate review

## Verdict: APPROVE — exact bounded experiment gate only

**Critical: none. Important/must-fix: none. Minor: one documentation-only observation below.**

Approval binds only the bytes enumerated here, following the accepted specification review. It means the executable experiment gate is suitable for the later review-consumption/issuance process. This review neither issues nor consumes authorization and does not launch anything. All draft approval, execution, review-consumption and readiness flags remain false; `ready_for_build=false` remains mandatory. No timing, functional, hardware-programming, or DDR-simulation acceptance is implied.

Scope is precisely the supported hold-only `TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON` QSF addition and mechanical Work10-to-Work11 retargets in two gates. Seed 2, maximum-placement effort, SPEED/MAXIMUM router effort and hardware/clock/pin/geometry/PF/BAR/SDC contracts remain unchanged. Specification PASS supplies native family applicability; native support is not evidence of timing improvement. Existing setup failures are an accepted baseline for this isolated hold experiment, not a must-fix prerequisite. Work10's previously reviewed generic framework is not reopened here.

## Verification and findings

- Independently rehashed all **65 package-manifest entries**, **44 remote-export entries**, and the specification report against the parent's exact SHA256. Reconstructed the exact three-file patch with the shipped verifier in an isolated copy. Its regenerated `local-verification.json` is byte-identical to the packaged result. Original manifests and evidence were not rewritten.
- Checked every exported overlay against its spec-review map and the draft's SOURCE and WORK bindings: exactly **5 timing + 4 gate + 3 inherited DDR files**. Full SOURCE differences are exactly the three permitted files. The entire **135-context** table equals Work10 under only work-root substitution. Draft WORK inventory matches all **5,564** staged entries. PIM and outer/inner tool maps match Work10; all **106 dependency pins** either match their prior pins or, for the five Work11 artifacts, rehash against exported bytes. Ten distinct runtime executable identities are retained.
- Issuer requires exact timing/gate hash-map equality, accepted inherited Work05 DDR source review, and exact issuer/runner/draft handoff hashes. It checks overlay/copy/baseline bytes and initial WORK inventory, then exclusively reserves `authorization-issuance.lock`, synchronizes overlays and validates the full SOURCE inventory before exclusive record creation. This is fail-closed but not transactional rollback: a post-reservation failure can leave synchronized SOURCE bytes and retains the lock, with no executable authorization. An independently injected post-lock failure preserved the lock and all evidence on rejected retry. No cleanup or automatic retry was introduced.
- Inspected SOURCE-overlay and WORK dispatch coverage: the actual `main()` routes exact Work11 project cwd to the compile validator; old/malformed cwd variants reject. Native and run-native-compile dispatch remain unchanged. Reviewed exported **40 production-entry fixture invocations (12 positive/28 negative)** and **3 actual missing-record rejection paths** (Python entry, build_top, build_fim_compile). Those remote results were inspected, not rerun remotely. Future records, process identities and claims in the dispatch harness are explicitly inert; filesystem/tool/hash checks in that recorded remote harness remain real.
- Runtime authorization remains exact executable/hash/argv/cwd membership plus claimed native ancestry, not a stage label. Claim creation uses exclusive `open('x')`; ancestry verifies record hash, live parent chain, PID start ticks, `/usr/bin/bash`, exact top-level argv and SOURCE cwd. SOURCE/PIM/dependency/tool/part/readiness checks precede acceptance. Inner and outer tool resolution remain distinct. No IPC normalization, arbitrary flags, or widened context grammar were introduced.
- Runner reserves the run directory exclusively before writing invocation/log data; log creation is exclusive. Exit 7 propagates as 7; zero plus a rejection marker returns failure; clean zero is exit-only acceptance with timing/report and functional acceptance still pending/false. Existing run evidence stays byte-identical on rejected repeats. Exceptions retain runner-error status; claims are not removed. The monitored gate also scans rejection markers across chunk boundaries, including downgraded QSF Critical Warning 125091. This review does not claim process sandboxing or termination of all vendor descendants on an external interruption.

### Minor observation (non-blocking, inherited)

The compile-gate module's opening docstring still says “Work08-only,” and the issuer's usage sketch omits the now-required timing/handoff fields. Executable Work11 constants and equality checks, the package report and the exact maps below are correct. These inherited comments do not broaden authorization; no source edit is requested for this bounded review.

## Local inert execution

Executed only within an isolated `/tmp/work11-quality-2rtyeur5/` copy, with `PYTHONDONTWRITEBYTECODE=1`:

1. `python verify_package.py`: exit 0; exact patch, export, binding and context checks passed; generated summary byte-matched original.
2. `python -m unittest -v test_issuer test_runner`: **5 tests PASS** (2 issuer, including five negative subcases; 3 runner with actual inert Python children).
3. `python -m unittest -v test_ia840f_compile_gate.CompileTests`: **7 tests PASS**. Did not run the eighth shell test in the incomplete local overlay, where missing build_top could yield a misleading nonzero result. Instead inspected the separately recorded three exact remote missing-record errors and no-side-effect evidence.
4. Independent full-12-overlay issuer fixtures: **7 cases PASS**: positive exact coverage; missing timing file; extra gate file; wrong inherited DDR hash; wrong runner handoff hash; existing issuance lock; injected post-lock inventory failure and byte-preserving rejected retry. Identity/inventory providers are mocked; fixture issuance is not real Work11 authorization.

Local command output and extra-case results are retained at `/tmp/work11-quality-2rtyeur5/quality-local-tests.json`, SHA256 `eef5c99fecdcbd45b720a6b6e39892a9d48328dfc90c5fa1071246c0408cf8e7`. This temporary local evidence is outside the immutable package manifest.

## Exact review-consumption maps

Map equality is required; this Markdown review is not itself `consumed-reviews.json`. The inherited accepted Work05 review must still be read and bound by the issuer. Timing coverage below approves experimental execution only, not timing closure.

### timing_review — five files

| Relative path | SHA256 |
|---|---|
| `src/board/ia840f/top.sv` | `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d` |
| `syn/board/ia840f/setup/top_loc.tcl` | `07a08b895a30f12c9553647073ec6a8d7243f2ca92ce70fd0b1ae5bd698a5be2` |
| `syn/board/ia840f/syn_top/ofs_top_sources.tcl` | `2056aeb757e8e27eff0aa2589f6e997a52595b095ca18802ecad1819665ba2aa` |
| `syn/board/ia840f/setup/bti_refclk.sdc` | `01b76a80f664c4ec0bf553874c68c7f71878642f205080e29727e50ce71c3cac` |
| `syn/board/ia840f/syn_top/ofs_top.qsf` | `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c` |

### gate_review — four files

| Relative path | SHA256 |
|---|---|
| `ofs-common/tools/ofss_config/ia840f_experimental_gate.py` | `4bd00f70a301b6ec66592544a4b637e75ab396f907afdf40e0facfcf707de9f8` |
| `ofs-common/tools/ofss_config/ia840f_compile_gate.py` | `6492a6b5d1a1b347d1fe9f6f077d3e9f09bee2744590592a615f3ba03174bf64` |
| `ofs-common/tools/ofss_config/test_ia840f_compile_gate.py` | `d53dd05b86fbb93393033b6aef170e31ab7fbd517a0fb00259ffc603268e26e2` |
| `ofs-common/scripts/common/syn/build_fim_compile.sh` | `0514c9be94702a7ec87e16d6e90d844e37a48d097aecc73a0a731331650c7c07` |

### Inherited source_review — three unchanged DDR files

| Relative path | SHA256 |
|---|---|
| `syn/board/ia840f/setup/emif_loc.tcl` | `a48a84b89fd6c5d5fd36c87cfe5c7d03264f3dea08ea6a447151351a21b523c3` |
| `syn/board/ia840f/source_manifest.json` | `82d5dabdc760bb24128ab0c9a5c96650da2d72f6d16f88f2d0d1780e4e745b0e` |
| `ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv` | `b9b0deb0582d554cb2178ed4ee090c088d9841951b19d1223cd4ca96bd9498a1` |

### handoff_files — exactly three files

| Key | SHA256 |
|---|---|
| `issue_authorization.py` | `e773fb2d445da6b92c0cddbc9c6b707faf31184364700cf6df9470a43a00c07a` |
| `launch_native_compile.py` | `f4d41bf2c0a5ab48912ce669a86b0c0d91fa5b18affdf4a8d62d992fbeb57389` |
| `compile-authorization.draft.json` | `10fa545ac9be6b79b75e26619ad3361939c30383ef8dafbb584c08a865d44300` |

## Hash-bound package and review target

| Artifact | SHA256 |
|---|---|
| `package-sha256.json` | `d81ef1ef7948056d50818dc6d7915c32bfbca6ddcb6f81966ef3204e8d91e082` |
| `spec-review.md` | `efac69b5d115982c247fa7f225e501605869efa9f4030883a4dd814228efe8be` |
| `REPORT.md` | `3ee6e7d68634965bdc78a4c6766b2817fc35cb7244e4ef8b4da9d97de458da31` |
| `verify_package.py` | `32badae14d234133fc075f7a43b36970711f6d15d6e4194a4d8b07b9d580fd92` |
| `remote-evidence/export-sha256.json` | `72860993d0ea339cb5d4ac077032dc52adb3ef8d85fbc00749dc01d346054a3d` |
| `remote-evidence/candidate.patch` | `f6c8092099e83429f63004818e162d853d1b32e2c89cd8864bc14092d258f4ce` |
| `remote-evidence/issue_authorization.py` | `e773fb2d445da6b92c0cddbc9c6b707faf31184364700cf6df9470a43a00c07a` |
| `remote-evidence/launch_native_compile.py` | `f4d41bf2c0a5ab48912ce669a86b0c0d91fa5b18affdf4a8d62d992fbeb57389` |
| `remote-evidence/compile-authorization.draft.json` | `10fa545ac9be6b79b75e26619ad3361939c30383ef8dafbb584c08a865d44300` |

## Preservation and remaining acceptance

Rechecked all original package hashes and the specification report after local execution. Only `quality-review.md` is added to the original Work11 package by this review; isolated test copies/output are temporary local artifacts. No production source changes, manifest rewrites, remote/vendor calls, authorization consumption, compilation, simulation, installation, hardware actions or commits occurred.

Later issuance must revalidate live bytes; this review validates the exported package, not a fresh remote read. Later native results must assess both DDR channels and every analyzed corner, setup/hold WNS/TNS/failing endpoints, PHY hold, effective settings/native QSF migration, constraints/unconstrained paths, warnings, full return codes/logs and assembly/image inventories against Work10. Assembly or exit zero alone is insufficient. S1/TRS, PCIe-divider and BMC IRQ/JTAG questions remain open. Source-bound guards are not an OS sandbox.
