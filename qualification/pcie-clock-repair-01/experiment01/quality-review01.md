# Independent QUALITY review — prepared Work14 offline STA A/B

## Verdict: REQUEST_CHANGES

**One important implementation defect blocks approval: the owned native process group is not supervised on every exit path.** No critical defect was identified. The narrow clock/constraint experiment, preserved-copy scope, and deferred numerical/result acceptance are otherwise reasonable; this review does not require successful native results before approving an experiment.

This verdict binds the actual `baseline/prepared-readback02/` and `candidate/prepared-readback02/` packages below, not the earlier prepare01 authoring files. The consumed SPEC PASS remains a separate prerequisite, not an implementation-quality waiver.

## Important finding Q1 — incomplete native-child lifetime supervision

**Affected:** both prepared `run-query.py` files; their implementations are identical after phase/path retargeting.

- Baseline runner SHA256: `0c1d8e04cd83da927db1408b720182e344053d6a30cfc9a354a49f117ed1656a`.
- Candidate runner SHA256: `2259f63626e5c42d9352966cbf918319449d60a6f8b272be1b70eb29791de02a`.

### Two concrete control-flow holes

1. **An exception after successful spawn can abandon the live native process.** At `run-query.py:79`, `Popen(..., start_new_session=True)` starts the child. The immediately following exclusive creation/write/close of `native-process.json` at `:80` is fallible. Neither it nor `wait_bounded` at `:81` is protected by child cleanup. For example, an I/O failure at `:80` jumps to the module-level handler at `:117–120`, which prints and exits 1; it never signals/waits for the child or persists a terminal execution/termination state. The child has a separate session and is not terminated by closing the parent's log descriptor. The 1800-second and report-total watchdog is never entered in this path. Unexpected exceptions from the wait/drain path likewise have no outer owned-child cleanup. Later callback rejection is not a replacement for bounding an already launched child during startup or licensing.

2. **Ordinary leader exit bypasses all descendant checks.** `wait_bounded:36` immediately returns `child.wait(timeout=2), reason` whenever the leader exits, with `reason=None`. `live_group` is called only inside the cap-abort branch at `:50–52`. Thus a leader that exits zero or nonzero while a descendant remains in its owned PGID leaves that descendant unsupervised, even though the timeout branch correctly handles a TERM-resistant descendant. On a zero-leader exit, postflight inventory/report hashing can race a remaining writer, and the function supplies no abort reason. A completion marker and intact originals do not establish that the process group is quiescent. The initial competing-tool check is not a post-run group-drain check.

These are static, directly reachable Python control-flow findings, not claims that Quartus has already exhibited the failures. AST inspection of each exact prepared runner confirms that the `Popen` statement has no enclosing `try/finally`, and that the normal return at line36 precedes the only group-drain calls. No additional package entry or custom fault-injection execution was performed.

### Why this blocks this bounded experiment

SPEC:24 requires a bounded owned subprocess group with preserved failure evidence and no progression after cap failure. The existing implementation enforces that ownership contract only on the watchdog's selected cap branch. Losing the supervisor after launch, or accepting leader exit as group completion, leaves native activity outside the promised wall/report supervision. Missing receipts and parent inspection do fail closed against normal B issuance, but do not terminate or bound the abandoned offline process.

### Required narrow correction

Keep the existing runner and source-bound model; no new generic framework or OS sandbox is needed.

- Establish an exception-safe owned-child cleanup region immediately after successful `Popen`. Reserve/pre-open fallible bookkeeping before launch where practical, but still handle errors after launch.
- Resolve the owned group's state before postflight inventory/export on **every** completion path, including ordinary leader exit and bookkeeping/wait exceptions. Preserve the unreaped-leader/PGID-identity safeguard until any final group signal; do not introduce unsafe signaling of a reaped/reused PGID.
- Retain explicit non-success/unknown-termination status when completion or drain cannot be confirmed, preserve any available raw native return code, and do not permit another phase. Where storage itself fails, retain the claim and available persistent log diagnostics rather than claiming that a receipt was written.
- Add real inert regressions for (a) a failure writing native-process metadata after successful spawn, and (b) a leader that exits without waiting for a TERM-resistant same-group child. Verify no live group writer remains at return (or an explicit unconfirmed failure is retained), failure artifacts are not overwritten, and no next stage becomes eligible. Existing tests cover neither path.

Retain this reviewed package as evidence and submit the corrected exact bytes through fresh binding/review before issuance. This reviewer has not changed any package or test.

## Exact binding and verified integrity

The SPEC review was read and its supplied SHA256 independently confirmed:
`89b9554fefb0cb555fa3e875fefbb703e3c468696a5b5bb845c758bf70d3f4f7`.
The parent consumption receipt hashes to
`612dedf938e60e0a2b0a0f2cfeddf447beba11b0ab4b14e15577d9c94e4dcbab`.

| Identity | Baseline | Candidate |
|---|---|---|
| `preparation02.json.gz` SHA256 | `2ae2be6137c26f586cae9a344839f17e105c09843ce29b11af44e910ebaf3891` | `53bda029311930529d3230ed527a56237dca5615244490372dc9a0abfc34e4a2` |
| `prepared-manifest02.json` SHA256 | `5c2a19fa75d77616545e199d65eafc1cdde83bd7158471fea0d3c6fe1d99264c` | `e8ff407d11912bd0d4f70dda8a865b00a49c310ab9e1af06a187ee4f1ca67be0` |
| Prepared `candidate.json` SHA256 | `828849ff7b597d5269de8193091202b51feac6cca2afdc89f374e962c75125c7` | `2164915affe8f96c369cd2084eca66b7bd0d08237ba924ce2d01b2083d47a1a0` |
| Export count | 13 | 13 |
| File / callback / link bindings | 7884 / 7761 / 10 | 7885 / 7762 / 10 |

Both gzip archives were decoded in memory. Every export's actual bytes, size and hash matched the decoded archive and manifest; readback directories have exactly the declared file sets. All counts and package identities matched the parent's receipt. Prepared Python exports parsed under Python3.9 AST syntax. Large records were parsed, not dumped.

Programmatic normalized inventory comparison reproduced exactly ten changed file bindings, one helper addition, no removals and equivalent links. Callback inventories exactly equal the recorded full inventories minus the explicitly excluded suffix classes. Runtime query/helper/runner/SPEC bindings matched the readback bytes. Decoding `constraint-delta.json` and performing its one exact replacement reproduced candidate `top.sdc`; removing the old/new blocks leaves byte-identical remaining SDC, including cuts and multicycles.

- Baseline top SDC: `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`.
- Candidate top SDC: `eb65af7949f130fffb011c6b5a96a5bc46bde5df7d57d99091e03730a441ff9a`.
- Shared helper: `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2`.
- Shared query: `8ed2064e0b99c598b457a936f064ee6db6a260b2b672e9fe6c6949fd6d47124c`.

These are checks of the captured preparation evidence, not a new live remote inventory. The accepted E2 result prerequisite was read and was not reopened as a new selector/source-research task.

## Checks passed and retained limitations

- The clock helper preserves the intended named existing master and divide-by-two hypothesis, checks exact pins/directions/clock-pin status, divider cardinality/type, physical fanin and propagated input-clock association, rejects pre-existing output clocks, and verifies helper execution/generated-clock identity and output propagation. Namespaced state and true collection handling address the prior Tcl scope/handle failures. No new period, base clock, cut removal, refit or maintained-source edit was found.
- Installed captured API help supports the reviewed fanout, keeper, propagated-clock, timing-path, exception, skew, UCP and MPW command forms. Native object compatibility remains experimental and fail-closed, not pre-proven. There is no new requirement here for a native selector query.
- Finite query cardinalities, complete bounded endpoint-pair intent, structural baseline adjacency, clock/receiver inventories, global summaries and transfer reports are present. Negative numerical timing is retained rather than accepted or silently waived. Per-exception `-npaths` reconciliation remains a RESULT gate because `report_exceptions` does not return a completeness count. The MPW detail call uses `-nworst 20`; it must not be described later as an uncapped full per-node listing. Global MPW summaries and the explicit result-stage cap/completeness review remain necessary.
- Gate dispatch reaches the correct phase validator. Exact file/link, executable/argv/cwd, live-claim/ancestry, part/readiness and missing-authorization checks remain. Candidate authorization requires successful baseline native/effective status, three true preservation results, one completion marker and hashes of all five specified baseline result artifacts. Parent inspection before B issuance is still required; a future issuer is not implicitly reviewed here.
- On its implemented cap path, the runner correctly retains the leader for TERM/KILL, checks live-group drain, and preserves a cap abort independently of native status. Normal postflight records native status before preservation/report processing and distinguishes effective status and `timing_accepted=false`. Those positive properties do not close Q1's other lifetime paths.

### Actual inert test replay

Only the two expressly permitted fixture entry points were rerun, with `python3 -B`, from `/home/joe`:

- `test-guard.py`: exit0, **17/17** cases passed.
- `test-runners.py`: exit0, **11/11** cases passed, including the existing watchdog TERM-resistant-descendant case; descendant state was `absent`.

Tested authoring helper/query/runners were independently checked byte-identical to the corresponding prepared exports. The tests are inert local control-flow evidence, not Quartus execution. The runner fixture imports with a mocked gate and exercises `wait_bounded`; it does not invoke runner `main`, so its green result does not cover Q1's post-spawn metadata failure. Its descendant case keeps the leader alive until the timeout, so it also does not test ordinary leader-exit drain.

## Scope and disposition

Only this report was authored. Other activity was local read/hash/parse/static comparison and the two allowed inert fixtures; temporary runner-fixture files stayed in the designated scratch directory. No remote access, git, vendor/native STA, hardware, actual preparation/gate/runner entry, issuer or authorization action occurred. No package, test, previous evidence or maintained tree was modified.

**Do not issue against this package until Q1 is corrected and independently re-reviewed.** No numerical timing result, source promotion, constrained fit, Design Assistant sign-off, matching persona, DDR/transfer/AHLS/sustained/QSPI-boot result or independent host recovery is accepted. The separate EMIF1 hold violation and all hardware gates remain open.
