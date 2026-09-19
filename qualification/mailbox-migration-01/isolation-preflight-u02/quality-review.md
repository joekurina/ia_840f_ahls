# Independent quality review — u02 partial nonvendor preflight

## Verdict: APPROVED — exact partial correction only

No blocking safety or correctness finding within this successor's fixed Python-only, partial nonvendor scope. This is a source/evidence quality verdict, **not execution authorization, installed-sandbox qualification, full-proposal acceptance, vendor/license acceptance or build readiness**. A fresh explicit parent decision and exact separately reviewed input binding remain necessary before any staging or bounded attempt. Historical u01 authorization is not renewed.

Reviewed exact bindings:

- `HASHES.json`: `8bad241dbf06925614014ba101476d91319be8d64a1fd6af4c5a81a44a39efac`
- `preflight.py`: `a05eae4011bb02f3a1e5d73a4f0f65305eda3712ef73f398f97e3c54c55da34b`

The fresh `spec-review.md` PASS, IMPLEMENTATION, disposition, README, complete implementation/payload, source diff, tests, runner, retained evidence and prior B1/B2 reviews were read. Prior reviews supply the historical partial-scope baseline, not approval for changed bytes.

## Safety and correctness findings

### Closed roles and universal identity checks

`preflight.py:27–36,207–231` correctly makes `{python3, bwrap, tmux}` the executed set and `{unshare, mount, setpriv, strace}` inventory-only. Disjointness and exact union are checked before identity I/O. Unknown/missing entries refuse. Caller role fields cannot override the source-bound classification, and observed mode/capability fields overwrite caller metadata.

Location, expected realpath, regular-file type, cumulative hash-byte allowance, SHA-256 equality and capability-query handling remain universal. Only ENODATA becomes absent capability data; other query errors refuse, and stat/hash read failures propagate. Privileged inventory metadata is recorded without normalization or execution permission. Every executed entry still rejects SUID, SGID and nonempty capability bytes. Moving the executed privilege rejection after hashing does not launch the file or bypass identity rejection. Fail-fast refusal need not collect subsequent entries.

`main:519–557` still checks bundle/input bindings and approval scope before host/tool discovery, and completes tool eligibility before tmux/bwrap subprocesses or claim creation. An identity failure has no fallback command or replacement attempt. Interpreter trust before starting the controller remains an independent prerequisite, not a retroactive guarantee of this check.

### B1 ownership remains intact

`preflight.py:85–152,372–509` retains the direct fork-owned, unreaped supervisor as the ownership anchor. Its child branch creates exactly one subprocess. An info-pipe PID is only a candidate until repeated identity/ancestry/namespace/NSpid checks and live pidfds pass. Ancillary closure precedes promotion. Rejected handles are closed, not signaled, including through the attempt's finally path. Normal lifecycle signals and cleanup target only accepted init or owned supervisor handles; numeric fallback remains limited to the direct unreaped supervisor when its pidfd was not acquired. Missing validated init produces unknown teardown, not presumed success.

### B2 cleanup and failure evidence remain intact

`preflight.py:279–369,372–509,607–632` retains independent stop, bounded WNOHANG reap, exit/namespace verification and descriptor/listener closure attempts. Cleanup precedes fallible pipe-receipt writing. Primary failure is preserved separately from cleanup/write errors; cleanup errors or unconfirmed teardown prevent an otherwise successful attempt from returning success. CONFIRMED still requires supervisor reaping, init exit and an empty namespace scan, not merely a sent signal.

The terminal reserve, exclusive receipt writes, conservative charging, compact terminal fallback and truthful postclaim final-unavailable reporting remain unchanged. Root claim tracking precedes child-directory creation. Unsupported topology, inaccessible evidence or early payload exit may safely produce refusal/inconclusive results. Documented supervisory rather than hard kernel bounds remain applicable.

### Payload privilege and execution boundaries remain intact

`probe.py:58–84,87–89,136–137` still requires `NoNewPrivs=1` and zero `CapInh`, `CapPrm`, `CapEff`, `CapBnd`, and `CapAmb` before substantive controls or lifecycle actions. The fixed argv uses isolated Python without optimization and requests `--cap-drop ALL`; no role-conditioned bypass exists. The payload has only fixed controls/lifecycle modes, with no arbitrary command path or inventory-tool launch added.

README correctly explains that read-only `/usr` is neither noexec/nosuid nor an execution allowlist: privileged mount remains visible/executable in the intended view. Installed bwrap must establish NNP, and the payload must observe it. NNP does not revoke already-held privilege, so zero-capability checks remain essential. These are trusted-fixture controls, not hostile-code containment claims.

## Independent static verification

Only read-only parsing, hashing and filesystem metadata inspection were performed. No reviewed module was imported or executed, no tests rerun, and no subprocess, tool launch, signal experiment, namespace, vendor or remote execution occurred.

- Both requested digests match actual bytes; **all 14 manifest members match**.
- Independently reconstructed `scope.diff` is byte-exact. AST comparison finds only `tool_identities` changed and `tool_roles` added; every other existing function/class is unchanged. The production textual change is confined to ROOT, role constants/helper and identity handling.
- `probe.py`, `test_b1b2.py`, `run_local_b1b2.py`, `tools.json` and `source-provenance.json` are byte-identical to u01. All copied-source provenance hashes match historical u01; disposition and three source-document bindings match.
- The ROOT-only projection hashes to `385b426817c8fe927550a9ee8473c70ca4f3cac406ca880fbdc229f2efc1a8dc`. It remains an audit projection, not an executed intermediate.
- All seven final `tested_sha256` bindings match current files. All seven Python files parse with Python 3.9 grammar; this is not installed Python 3.9 execution verification.
- AST-enumerated test names exactly match retained successful transcript names: **14 existing + 19 B1/B2 + 15 role/baseline tests = 48**, zero recorded failures/errors/skips. Final retained evidence identifies Python 3.13.5. Tests use synthetic identities/topology; the inherited ordinary Python-child pidfd test is not a namespace observation.
- New tests cover role closure/override resistance, actual privileged inventory metadata, every executed privilege rejection, universal identity/type/location/realpath/hash/capability-query failures, cumulative inventory bytes, interpreter mismatch, read-error propagation and mandatory payload privilege fields.
- All **96** evidence-manifest entries match mode and applicable size/hash or symlink target. Special files were not opened.
- Independent enumeration of the surrounding qualification tree excluding u02 finds **502 entries**, exactly matching `preservation-before.json`, with no additions, deletions or recorded metadata/content differences. Historical u01 remains unchanged.
- Final CLI refusal evidence binds the current manifest/template and records exit 2, `REFUSED_BEFORE_CLAIM`, approval-scope mismatch and null retained root. Source ordering confirms that rejection precedes host/tool discovery and claim. This is retained evidence, not a newly run invocation.
- The failed RED capture and earlier cumulative-cap assertion failure remain retained, not concealed. Final evidence supersedes the earlier batch; no conclusion is drawn that installed isolation controls have passed.

## Nonblocking notes

1. `run_local_u02.py:2` says it “never invokes preflight.main,” but lines 36–51 deliberately invoke the normal CLI in a subprocess with the unapproved template. It does not call main directly in the runner process, but the literal wording is misleading. README and IMPLEMENTATION accurately describe the retained preclaim refusal, and the runner checks that exact refusal; this documentation nit is not a safety blocker. No source correction was made during review.
2. Retained local evidence does not qualify installed bwrap topology, NNP establishment, mount/network denial, lifecycle propagation or real teardown. Those remain matters for the separately authorized exact experiment. Known full-proposal omissions are expressly outside this partial review and are not reopened as requirements.

## Review effect and files changed

Only `isolation-preflight-u02/quality-review.md` was created. No source, manifest, historical record, approval input or authorization/readiness/vendor flag was changed. The template remains NOT_APPROVED with null identity/path inputs and false flags. Even a future successful partial experiment still returns exit 2 and `FINITE_FIXTURE_CONTROLS_OBSERVED_PROPOSAL_INCOMPLETE`, never full acceptance. This verdict alone grants no staging, retry or execution permission.
