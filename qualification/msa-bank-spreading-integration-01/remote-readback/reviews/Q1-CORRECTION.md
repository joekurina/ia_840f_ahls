# Q1 correction — successor 02

Status: local correction tested; ready for independent focused re-review, NOT deployment.
`execution_ready` remains false. This is an implementer report, not new review approval.

## Minimal change

Only `stage_candidate.py` and `test_bank_spreading.py` differ from predecessor 01.
Before either publication write, the publisher now checks existence and exact validated
bytes for every output not in the selected memory-preset/provenance pair. It does not
require that pair to be current. The final all-output readback remains unchanged.
No transaction framework, inherited assertion cleanup, or source derivation change.
`q1-correction.patch` contains exactly these two file changes.

Five added tests use fresh temporary fixture copies, restore both publication targets
to their captured baseline bytes, then independently exercise stale/missing simulation
and stale/missing PCIe collateral. Rejection must preserve the complete board-directory
file inventory and bytes, including absence. The positive case must change exactly the
selected pair and produce the preserved candidate bytes.

## Actual execution

- RED, before publisher edit: five new tests ran; four negative tests failed because
  rejection still changed memory preset and provenance. Positive test passed; exit 1.
- GREEN: all 21 tests passed (16 existing plus five new); exit 0.
- Unchanged `verify_package.py` ran in a fresh relocated package copy: all four child
  commands exited 0, including all 21 tests, stage comparison twice and production
  derivation comparison. It reproduced the original four outputs and preserved the
  baseline/candidate inventories. Regenerated source patch matched byte-for-byte.
- Exact commands, cwd, exit codes and publisher identities: `q1-evidence/commands.json`.
  Logs: `q1-evidence/red.log`, `green.log`, `verifier.log`; fresh verifier output in
  `q1-evidence/verification/`. Temporary package location is recorded in those results.

Use ordinary unoptimized Python with `-B` and `PYTHONDONTWRITEBYTECODE=1`.
To reproduce, copy this package to a fresh temporary directory before running
`python -B verify_package.py`: the unchanged verifier overwrites its historical
`verification/` files and regenerates `candidate.patch`. Do not run it in an evidence
package whose historical files must remain immutable.

## Historical evidence and integrity

All inherited reviews, reports, manifests, logs and results are HISTORICAL 01 evidence,
not new approval of 02. In particular `quality-review.md` retains REQUEST_CHANGES Q1;
`implementation-spec-review.md` and `review-contract/` are prior reviews. Root
`REPORT.md`, `artifact-manifest.json`, `red.log`, `green.log`, `publication.json`,
`compare.json`, and `verification/` are preserved historical bytes. The old manifest
still describes 01; its publisher/test entries intentionally do not describe 02.
The current authoritative package inventory is `q1-artifact-manifest.json`, excluding
only itself; `q1-changed-file-inventory.json` enumerates the successor delta.

The complete predecessor inventory was captured before copying, its 79 manifest
entries validated, and all 82 original files rechecked unchanged. All inherited files
in 02 remain byte-identical except the two correction files. All three source-candidate
files and `candidate.patch` retain their required authoritative hashes, recorded in
`q1-evidence/integrity-results.json`. The standalone baseline, candidate source and
sibling `candidate/reference` dependency layout is unchanged.

No remote/vendor calls, maintained SOURCE/WORK/gate/auth changes, build/generation,
Query04, DDR simulation, hardware actions, installs, permission changes or commits.
No new source semantics, execution authorization or deployment readiness is claimed.
Independent quality re-review remains outstanding.
