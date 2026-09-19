# Independent specification review — u03 tmux serialization correction

## Verdict: PASS — narrow local correction only

No specification blocker found for this serialization-only successor. This verdict is not execution authorization, full isolation acceptance, installed-runtime qualification, vendor/license acceptance, or build readiness. Independent quality review must follow, then a fresh explicit parent decision binding the reviewed u03 bundle and fresh input bytes before staging or execution. Consumed u02 permission is not inherited or renewed by fixture absence.

Reviewed SHA-256 bindings, independently verified against local bytes:

- `HASHES.json`: `76c503a12ca7fb5772a13ce8a4dcad6481817f66c3208e3b36a6285f6df85a20`
- `preflight.py`: `c3f67d5b33efc52f812a6f1d42f67b2e26594897a8ccd73dd077320c0de3c4ba`

## Findings

### Exact serialization, unchanged identity

`preflight.py:538–541` requests exactly `#{session_name}|#{session_id}|#{pane_id}|#{pane_pid}` and requires exact byte equality with `b'ia840f_migration_preflight|$4|%4|25387\n'`. All four identity values and the single terminating newline remain mandatory. There is no splitting, trimming, whitespace normalization, wildcard, alternate identity, underscore acceptance, retry or automatic rebinding. The same absolute tmux executable, socket, target, environment, three-second timeout and `check=True` remain.

The retained `u02-stop-evidence.json` records the previous tab-format query returning `b'ia840f_migration_preflight_$4_%4_25387\n'`, rc 0 for that query, and the consumed invocation refusing with rc 2 and `REFUSED_BEFORE_CLAIM` for named-pane identity drift. Fixture absence is recorded. These are retained historical observations, not observations repeated by this review; expected future pipe output has not been live-verified.

### Production delta and inherited safeguards

Independent comparison of actual u02 and u03 source confirms exactly three changed production lines: the future fixture ROOT suffix changes from u02 to u03, and the requested/expected tmux string literals change tabs to pipes. Independently reconstructed production/root-test/runner diffs match `scope.diff` byte-for-byte.

The sole future fixture ROOT is `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/preflight-isolation-7c407469a419-u03`. Reserved vendor/observation paths and the abstract-listener name remain unchanged. `probe.py`, `test_b1b2.py`, `test_tool_roles.py`, `tools.json`, `source-provenance.json` and `parent-inputs.template.json` are byte-identical to u02.

Consequently source-bound executed/inventory-only tool roles and identity checks, B1 fork ownership/live-pidfd validation and rejected-handle treatment, B2 independent cleanup/reaping/exit evidence and terminal receipt reserve, fixed Python payload/argv, resource/time limits and preclaim ordering are retained without modification. The tmux equality check still precedes bwrap help and fixture claim. Bundle/input checks and approval scope still precede host/tool discovery. This is preservation of the accepted partial-scope baseline, not a new full-isolation safety claim.

The renamed local runner changes its evidence directory and adds the tmux regression group. Its corrected docstring accurately states that the unapproved-template CLI invokes main but refuses before host/tool discovery or fixture claim; it no longer claims never to invoke main.

### Inert regression coverage and retained results

Static inspection of `test_tmux_identity.py` confirms extraction of the actual two production tmux statements with a synthetic subprocess and exact argv/call-count assertions. Coverage includes exact pipe success, rejection of the recorded underscore bytes, independent mutation of every identity field, tab/space/CRLF/newline changes, missing/reordered/extra fields or output, and query error propagation without retry. The positive bytes are explicitly an expectation rather than a workstation observation.

The retained transcripts and `results.json` agree: 14 local, 19 B1/B2, 15 tool-role/baseline and 9 tmux tests, **57 total**, with zero recorded failures/errors/skips. AST-enumerated test names exactly match successful transcript names and recorded counts. All seven `tested_sha256` bindings match current files. The retained interpreter identifies Python 3.13.5; the runner records Python 3.9 grammar checks, and independent static parsing also accepts all seven files with Python 3.9 grammar. This is not execution verification under Python 3.9. Tests were not rerun or imported by this reviewer. The inherited ordinary owned Python-child pidfd test is not namespace or installed-tool qualification.

Retained CLI evidence binds the current manifest and unapproved template, records rc 2, empty stdout, approval-scope mismatch, `REFUSED_BEFORE_CLAIM`, null retained root/final receipt and false authorization/readiness. Static ordering supports that refusal boundary.

### Provenance, preservation and authorization boundaries

- All 14 bundle-manifest member hashes match; all three original source-provenance bindings match.
- The u02 source-manifest digest, every copied-source hash and all four historical bindings in successor provenance match their actual local targets, including the stop evidence and historical reviews.
- All 55 evidence-index entries match recorded mode and applicable size/hash or symlink target. Special files were not opened.
- Independent metadata/content comparison and tree enumeration find exactly the 607 entries recorded in `preservation-before.json` outside u03, with no additions, deletions or recorded differences. File bytes/modes/mtimes and symlink targets are preserved; access times are outside the recorded contract. This includes consumed u02 and surrounding qualification evidence. The baseline digest matches the preservation record and evidence index.
- The template remains `NOT_APPROVED`, with null tmux realpath/hash and protected-path inputs, and explicit false authorization/readiness/vendor flags. No filled `parent-inputs.json`, staging artifact or execution decision is present in the reviewed u03 tree. Successor provenance and retained results keep flags false.

## Scope and remaining prerequisites

Review used local static reads, AST parsing, hashing and filesystem metadata enumeration only. No reviewed code was executed/imported, no tests rerun, and no tmux, remote, namespace, bwrap or vendor action was performed. Historical u02 reviews were used as provenance, not as successor approval.

Installed tmux pipe serialization, bwrap topology, namespace denials, no-new-privileges establishment, lifecycle propagation and real teardown remain unverified. Existing full-proposal omissions and supervisory-versus-hard-bound limitations remain explicitly applicable. Even future successful partial controls do not grant full proposal acceptance or build readiness.

Only this new `isolation-preflight-u03/spec-review.md` was created. No source, manifest, historical evidence, parent input or readiness flag was modified. Quality review and a fresh parent decision remain required; this PASS grants no staging, retry or execution permission.
