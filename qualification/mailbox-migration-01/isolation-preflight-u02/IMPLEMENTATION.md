# u02 implementation handoff — not approval

Local-only successor preparation is complete. Spec review then independent quality
review remain required. No remote staging/execution, bwrap/namespace/vendor run,
host chmod, package installation, capability removal, commit or push occurred.
Authorization, build readiness and vendor execution remain false. The only
future fixture is the explicit u02 root in preflight.py; old authorization is not
reusable. No approval input or historical review/receipt was copied as new.

## Scope and evidence

- Executed roles: python3, bwrap, tmux. Inventory-only: unshare, mount, setpriv,
  strace. Exact union and disjointness required before identity collection.
- Universal checks remain location, realpath, regular-file type, cumulative hash
  bytes, SHA-256, ENODATA-only capability absence, and current interpreter.
  Actual mode/capability hex and source-bound role are recorded. Caller role
  fields cannot override classification. Only executed tools reject SUID/SGID
  and nonempty capability bytes; inventory privilege is never execution consent.
- Main source diff: ROOT constant, two role constants, additive tool_roles helper,
  narrowly changed tool_identities. All other preflight functions/classes are
  AST-identical to u01, including fixed argv/main/B1 ownership/B2 cleanup. probe.py
  and test_b1b2.py are byte-identical, as are tools.json/source-provenance.json.
  Existing test_local expectations changed only for the explicit u02 root and
  full expected tool map. The old reserved vendor/observation paths and abstract
  listener name deliberately remain unchanged.
- The README records read-only /usr versus noexec/nosuid, visible setuid mount,
  mandatory NoNewPrivs and every zero capability set, and qualification limits.
- root-only.diff/root-only-hashes.json isolate the root change as an audit
  projection, not an executed intermediate source. scope.diff includes every
  changed copied member; new tests/runner/audits are additive files.
- preservation-before.json and preservation-check.json compare all 502 entries
  outside u02 in the qualification directory, including original u01, reviews,
  receipts and decisions: zero changes. Regular files were hashed; symlink
  targets and other entry types/modes were recorded without following/opening
  special files.

## Verification

Command executed from /home/joe:

```sh
python3 -I -B -S /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/isolation-preflight-u02/run_local_u02.py
```

Final verification-u02-02/results.json: 48 tests (14 existing + 19 B1/B2 + 15 new),
zero failures/errors/skips, exit 0, Python 3.13.5. All seven Python files parse
with the Python 3.9 grammar (not an installed Python 3.9 runtime qualification).
Exact per-test output and source hashes are retained. The normal CLI, passed the
current manifest and NOT_APPROVED template hashes, returned exit 2,
REFUSED_BEFORE_CLAIM with approval scope mismatch, no retained fixture root.
No host/tool query or claim is reached by that template rejection. The only
nonmock launched test child is the inherited ordinary local Python sleeper.

HASHES.json SHA-256:
8bad241dbf06925614014ba101476d91319be8d64a1fd6af4c5a81a44a39efac

preflight.py SHA-256:
a05eae4011bb02f3a1e5d73a4f0f65305eda3712ef73f398f97e3c54c55da34b

Current manifest members and final tested source hashes were independently
recomputed and matched after the final run. EVIDENCE-HASHES.json covers the
remaining local records and fixtures separately; it does not approve them.

## Iteration history retained, not hidden

The focused RED test reproduced the old privileged/nonregular refusal; its exact
output is red-tool-roles-02.txt and its source/test hashes are in
red-tested-hashes.json. The first RED attempt left red-tool-roles.txt partial:
a global os.stat mock interfered with unittest traceback formatting. The test
now isolates the preflight OS mock, so the second RED capture is complete.

verification-u02-01 retained all original passing tests and one new test failure:
the cumulative byte-cap fixture expected rejection at equality (5 bytes against
a 5-byte cap), whereas the implementation correctly rejects only excess. The
fixture cap was corrected to 4, leaving production code unchanged. The runner
then used a new exclusive local evidence directory, not a remote fixture retry.
Final source/test hashes supersede the failed batch's exact retained hashes.

No outstanding local implementation blocker. Installed bwrap, namespace controls,
vendor/license behavior, full sandbox qualification and full proposal acceptance
remain untested and unapproved. No workflow/skill file outside u02 was modified.
