# Independent Work12 specification review

## Verdict: MUST FIX — one bounded header-runner failure-evidence defect

The corrected-memory integration and the separation between header-only execution and future full-compile authorization satisfy the inspected specification. Do not consume this review as acceptance or begin quality approval yet: the header runner loses the native return code and output/inventory evidence when its post-native verification raises. Correct that narrow failure path, regenerate the affected package bindings, and re-review. No parameter research, DDR simulation, project query or integration redesign is requested.

This is specification review only, not quality approval, authorization issuance, or native-result acceptance. No vendor executable or remote command was launched.

## MUST FIX 1: preserve native evidence before fallible postflight checks

**Location:** `remote-evidence/run_headers.py`, lines 33–46; especially `gate.load_record()` at line 39, before output/inventory persistence and before `state.update(native_returncode=rc, ...)`.

The specification and handoff require native-status preservation, failure propagation, output hashes and postheader inventory, including rejected attempts. Currently a completed native child can return 17 and emit its output, but a subsequent source/tool/dependency mismatch raises before any of those facts are saved. The exception handler writes only initial state and the exception to `failure.json`, then re-raises. The actual entry point consequently reports a Python exception exit instead of propagating native rc17. Even the already calculated diagnostic flags/output hashes are lost from structured evidence. A failure in output hashing/stat collection can produce the same omission earlier in the postflight sequence.

**Independent inert reproduction:** imported an unchanged fresh local copy of the runner; mocked only the remote host/tmux identity, gate record/environment/inventory/process identity and record hash. The child was real local Python, not a fake vendor executable. It wrote `fresh.txt` and exited 17. The first `load_record()` returned the inert record; its second call raised `ValueError('inert postflight dependency mismatch')`.

Observed retained files: `claim.json`, `invocation.json`, `native.log`, `failure.json`, and the child's `fresh.txt`. **No `outputs.json`, `postheader-work-inventory.json`, or `result.json` was saved.** The failure record was:

```json
{
  "ready_for_build": false,
  "header_native_started": true,
  "started_ns": 1789814277260663315,
  "error": "ValueError('inert postflight dependency mismatch')"
}
```

There is no native return code in that record. Local reproduction evidence is retained under `/tmp/work12-spec-mtgigow0/runner-17-True/`; this directory is outside the reviewed package.

**Minimal acceptance criterion:** record the native rc immediately after child completion, independently preserve available diagnostics/output hashes and a best-effort postheader inventory even when verification fails, and record any evidence-collection error explicitly. Keep acceptance false on every postflight failure. Preserve/propagate an available nonzero native rc; use nonzero runner failure when native rc was zero. Retain exclusive claims and immutable rerun behavior. Add inert regressions for native rc17 plus postflight failure and native rc0 plus postflight failure. This does not require a general monitoring framework, timeout redesign or vendor execution.

## Integration and identity checks that passed

I read the full `REPORT.md`, `COMPILE-HANDOFF.md`, accepted native memory result review, actual header issuer/runner/gate, compile gate and runner, dispatcher delta, draft/fixture, test sources, inventories and complete-closure checker. Numerical checks below were recomputed in Python, not accepted solely from summary counters.

- Archive: **1,801,854 bytes**, SHA256 `8d2d59b71afd4364be074406c87d1c86e4d9a094e1e6d5644b430263ca4f6112`. Verified all **77 regular archive members** against their local bytes and all **76 manifest payload hashes**; the manifest is the additional member.
- Manifest SHA256: `a747747af93fa36911ac012e705982610fe481b404667d9ed5136a73a4e8822b`.
- Header draft SHA256: `316a499b61cff2281d5b9785650ff53b969f80ec7ec4178692cac98595f120d5`.
- Accepted native-result review SHA256: `72f7b597efe11080f1163e3fd00826fcbf8553fd55eebfc15004cca4e3e19e16`. Its accepted scope remains exactly both MSA FIFO counts 8 → 0, copies=1, unchanged compared interfaces/topology, and the specifically accepted generated timestamps. No parameter re-investigation was performed.
- Rehashed all **284 actual locally captured accepted memory files** against Work12's preflight memory inventory. The active transplant contains exactly **283 project files**, excluding `first-save.ip` provenance. Its only two inventory differences are the recorded absolute-path relocations in `mem_ss/mem_ss.xml` and `mem_ss/mem_ss_generation.rpt`; all other memory identities, including RTL/HEX/SDC, match accepted bytes.
- Recomputed the full captured **5,567-entry Work04 → 5,265-entry Work12** inventory accounting, excluding only the explicit archived prefixes. Matched the exact lists of **4,798 unchanged non-memory entries**, **180 explained deviations**, and **four new paths**. Every applicable overlay/relocation hash matches; no unaccounted removal or drift remained.
- Recounted **170 relocations: 167 metadata files and three symlinks**. Retained remote staging/final-verification code checks Work04 and original generation-tree preservation. This is captured remote preservation evidence, not a new live check.
- Independently traversed actual accepted local QIP bytes, parsing every recognized `*_FILE` reference and rejecting unrecognized forms. Reproduced the complete captured edge list exactly: **12 QIPs, 210 edges**, including every **five HEX**, **six SDC**, and **14 TCL_ENTITY_FILE edges**. Every edge target/hash is in the final Work12 inventory. No edge points to Work04 or standalone generation. Native project selection/load remains experimental, not established by this static closure.
- Recounted **1,360 captured SOURCE files, 530 PIM entries and 419 baseline dependencies**. All baseline dependency pins remain in the header draft. The complete predicted SOURCE inventory equals the preflight inventory with exactly the **three reviewed gate changes**, not the entire historical overlay reapplied. The smaller `source-before.json` is an overlay-before subset, not the full SOURCE inventory; its entries match the corresponding full preflight map.
- QSF hash is `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`, with hold ON, SEED 2 and maximum-placement effort. `emif_loc.tcl` is retained; no invented `emif.tcl` is required.
- All **135 compile contexts** equal the complete Work11 context table after only Work12 path substitution. The compile gate and native compile runner are byte-exact mechanical Work11-to-Work12 retargets. Dispatcher changes are limited to fresh-WORK routing and exact header argv selection; other callbacks still require compile authorization.

## Header execution contract checks

The sole header context binds installed `quartus_sh -t WORK/ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl --project=ofs_top --revision=ofs_top`, cwd `WORK/syn/board/ia840f/syn_top`. Runtime validation checks executable/hash/argv/cwd plus live runner ancestry, PID start time and authorization hash. The actual source-pinned exporter invokes trusted qsys-script children; this is explicitly not OS containment. The operation matches the proven header route identified by the accepted parent result; actual Work12 native behavior is still the next experiment.

All **eight required outputs** are absent from the final preheader inventory; the runner requires nonempty, fresh outputs. Staging archives the obsolete memory subtree and aggregate project configuration directory to defeat stale-memory mtime skips. It does not unnecessarily regenerate unchanged PCIe/PLL IP. Native gate rejection markers and Error/Fatal/parenthesized diagnostic forms are rejected; `Critical Warning` also rejects the known 125091 downgrade case. The finding above concerns retaining these results if postflight itself fails, not the ordinary diagnostic predicate.

The issuer checks exact independent spec/quality manifest mappings and current package/full SOURCE/PIM/dependency/WORK/tool bindings before the exclusive issuance lock and scoped SOURCE writes. Existing changed SOURCE files are backed up; the lock/partial state remain consumed if issuance fails rather than permitting silent reuse. No accepted review envelope or real authorization is supplied. No source overlay was installed by this review.

The preheader compile fixture is expressly inert and unapproved. There is no real compile draft/authorization in this package. Actual successful header output and result review must precede full postheader inventory capture and a separately reviewed compile draft/issuer. Work11's historical review classification must not be blindly reused. This sequencing is correct and does not justify binding guessed future header hashes.

## Tests and evidence boundaries

**Fresh local execution:** all **eight existing inert compile-gate unit tests passed** from `/tmp/work12-spec-mtgigow0/source`, using the real local shell entry copied into that temporary source tree. Separate real inert Python children exercised the unchanged header runner: native **rc0 returned 0**, native **rc17 returned 17**, both saved output/status/inventory evidence, and rejected reruns preserved all evidence bytes. The added postflight-failure case reproduced MUST FIX 1; its rerun also left evidence unchanged.

**Captured remote tests inspected and independently counted, not freshly rerun remotely:** **22 header-dispatch cases** (two acceptances, 20 rejections), **40 compile-dispatch cases plus two trace summaries**, **four missing-record rejections**, actual Tcl helper resolution/missing-record rejection, issuer missing-review rejection before lock, and the captured two outer-runner cases. Those captured tests do not cover the reproduced postflight failure. I do not claim the remote real-filesystem 22/40 suites were rerun on this different local host.

The package payload hashes were rechecked after local testing and remain unchanged. The initial local inventory-shape assertion was corrected after identifying `source-before.json` as the intentionally smaller subset; this was a reviewer check error, not package drift. Retained preparation transport/assembly failures are resolved preparation failures, not vendor attempts.

Fresh execution preflight must still recheck live remote inputs. Timing, calibration association, constraint completeness and functional readiness remain unresolved/false as permitted for this experiment. No Query04/equivalent, DDR simulation, hardware action, installation, permissions change, authorization consumption, commit or push occurred.

## Additional reviewed executable identities

| File | SHA256 |
|---|---|
| `issue_headers.py` | `d1134328befd7e1ce49588b35e7bdd614f4ffa4ef8db8a8e150adc53df042011` |
| `run_headers.py` | `d62f18b3a7dd9c644859dbf5239c63e0bc300ff0b0708c8899087c495f4ff2dd` |
| `ia840f_header_gate.py` | `5f2119633171c0e262c556bfe1b27cdc7f297c5ca8b352647c449c8f048b0087` |
| SOURCE compile gate | `b5b9de19d84aa67c725cdbe31e20a03f298120fc6475cd777834df6aef0fcde1` |
| SOURCE actual dispatcher | `f8fb4eb4d24322e03894ed15391ea0e2e87c00a685f78123f317cda01aed8bfb` |

Created only this report in the qualification evidence directory. Local inert fixtures/results are isolated in the temporary directory; original SOURCE, gates, authorization, package and accepted memory evidence were not edited.
