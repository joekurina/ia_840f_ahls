# Independent quality review — u03 partial preflight correction

## Verdict: APPROVED

Approved only for the narrow, specification-passed local serialization correction. No new regression or blocking quality defect was found in this delta. This is **not staging or execution authorization**, full isolation acceptance, remote qualification, vendor/license acceptance, or build readiness. A separate fresh parent decision remains required; `ready_for_build` remains false.

### Reviewed bindings

Independently hashed the actual local bytes:

- `HASHES.json`: `76c503a12ca7fb5772a13ce8a4dcad6481817f66c3208e3b36a6285f6df85a20`
- `preflight.py`: `c3f67d5b33efc52f812a6f1d42f67b2e26594897a8ccd73dd077320c0de3c4ba`

All 14 manifest members match. All seven retained tested-source hashes match current files. All 55 evidence-index entries match their recorded mode and applicable size/hash or symlink target; special files were not opened. The successor's u02 manifest, copied-source and historical bindings also match their local targets.

## Findings

### 1. Exact identity checks are preserved

Independent u02/u03 comparison confirms exactly three changed production lines: ROOT changes to the exclusive u03 fixture, the tmux format changes tab separators to printable pipes, and the expected stdout changes to those same pipes. The reconstructed production, root-test and renamed-runner diffs match `scope.diff` byte-for-byte.

At `preflight.py:538–541`, the expected stdout remains the single exact byte string:

```python
b'ia840f_migration_preflight|$4|%4|25387\n'
```

Session name, session ID, pane ID, pane PID, ordering and the single terminating newline are mandatory. There is no normalization, splitting, trimming, alternate identity, underscore fallback, retry or automatic rebinding. Pipes are passed in one argv element, not through a shell. The absolute executable, socket, target, environment, captured byte streams, three-second timeout and `check=True` are unchanged.

Mismatch raises the existing `RuntimeError`. Launch errors, nonzero-exit exceptions and timeout exceptions have no new interception or retry and reach the existing preclaim error handler (`preflight.py:624–632`). The identity check remains before bwrap help and fixture claim. Bundle/input validation and approval-scope validation still precede host/tool discovery (`preflight.py:519–557`).

### 2. Inherited safeguards are unchanged, not newly qualified

The complete production comparison establishes preservation of source-bound tool roles and identity checks, B1 fork ownership/live-pidfd ancestry checks and rejected-handle handling, B2 independent cleanup/reaping/exit evidence, terminal receipt reserve, fixed payload/argv, limits and preclaim ordering. Static reading of those paths found no interaction introduced by the delimiter change. `probe.py`, `test_b1b2.py`, `test_tool_roles.py`, `tools.json`, `source-provenance.json` and the input template are byte-identical to u02. Reserved paths and the abstract-listener name are unchanged.

The new fixture root is exactly `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/preflight-isolation-7c407469a419-u03`. Claim collision remains terminal, with no removal, reuse or alternate suffix.

The retained u02 stop record documents underscore-separated query bytes and an rc-2 `REFUSED_BEFORE_CLAIM` invocation for identity drift, with fixture absence recorded. It is historical evidence, not a query repeated here. The consumed u02 run is immutable and its permission is not renewed by fixture absence or by this verdict.

### 3. Regression coverage tests the actual changed statements

Static inspection of `test_tmux_identity.py` confirms extraction of the actual production tmux assignment and following `require` statement, rather than a separately reimplemented validator. The synthetic subprocess asserts the exact argv, kwargs and single call, including failure cases. Coverage accepts exact expected pipe bytes, rejects retained underscore bytes, independently mutates each identity, rejects whitespace/newline/field/output alterations, and checks error propagation without retry.

The error regression injects `OSError`; it does not separately exercise `CalledProcessError` or `TimeoutExpired`. This is not a blocker for this unchanged exception path: `check=True`, timeout and direct propagation remain explicit in the inspected source. Positive pipe bytes are an expectation, not proof of installed tmux serialization.

The local runner adds this test group, uses an exclusive new evidence directory and accurately documents its unapproved-template CLI invocation. It records source hashes, grammar validation and refusal evidence, and exits unsuccessfully if any group reports failures, errors or skips.

### 4. Retained evidence is internally consistent and appropriately limited

AST-enumerated test names exactly match the successful retained transcript names and recorded group counts: 14 local, 19 B1/B2, 15 tool-role/baseline and 9 tmux tests, **57 total**, with zero recorded failures, errors or skips. The recorded interpreter is **Python 3.13.5**. Independent static parsing accepted all seven files using Python 3.9 grammar rules; this is not execution under Python 3.9.

The retained CLI refusal binds the current manifest and template and records rc 2, empty stdout, approval-scope mismatch, `REFUSED_BEFORE_CLAIM`, null retained root/final receipt and false authorization/readiness. Static source ordering supports that boundary. These are retained local results, not tests rerun by this reviewer. The inherited owned Python-child pidfd test does not establish namespace or installed-tool qualification.

## Authorization boundary and review method

`parent-inputs.template.json` remains `NOT_APPROVED`, with null tmux realpath/hash and protected-path inputs and false authorization/readiness/vendor flags. No filled `parent-inputs.json` exists in the reviewed u03 directory. The parent must separately decide any exact limited execution and bind the reviewed bundle and fresh input bytes; neither old inputs nor consumed authorization are inherited.

Installed tmux pipe behavior, installed Python/bwrap behavior, namespace denials, no-new-privileges establishment, lifecycle propagation and real teardown remain unverified. The documented partial-scope omissions and non-hard-bound supervisory limits remain applicable. Even successful future finite controls would not establish full proposal acceptance or authorize a build/vendor run. This review does not reopen the accepted partial scope as a general isolation redesign.

Review used local reads, byte comparisons, hashing, filesystem metadata and AST parsing only. No reviewed code was executed or imported, no tests were run, and no subprocess probe, remote, tmux, bwrap, namespace or vendor action was performed. Only this new `quality-review.md` was written; sources, manifests, templates and consumed evidence were not modified. No commit or push was performed.
