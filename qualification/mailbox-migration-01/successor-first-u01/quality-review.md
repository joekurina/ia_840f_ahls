# Independent successor quality review

## Verdict: APPROVED

**Approval is limited to the exact successor preparation reviewed below. No vendor launch, migration acceptance, isolation capability or build readiness is approved. `ready_for_build: false`. Live launch remains blocked.**

Read `spec-review.md` (PASS), the complete successor Python/test/Tcl sources, README, retained regression output and receipt, governing binding proposal/review, and adjacent observer gate/documentation and isolation design review. Independently compared source bytes and calculated hashes; did not rely on the specification verdict alone. No critical or important defect requiring changes to this narrowly specified preparation was found. The important unresolved operational limitations below remain mandatory constraints, not implemented fixes.

## Exact artifacts and independent verification

| Successor artifact | SHA-256 |
|---|---|
| `migration.py` | `a4f360484dba25f4e0a12a7cdb294b1387c86f1bb7b884480acb630368bb2f9c` |
| `child.tcl` | `3b735d9ccb1886dfbc3791a905abde3afa067892743798a5e4ed344cb7071362` |
| `parent.tcl` | `5b8d78e78e61cec558fcbe8abd5f1eb9cdd6a76efc203cfb4d598adf2fbcf51d` |
| `source-baseline.json` | `148bb2897db6416a5950d152b6a8104c39cffda494e2723c97afecce9efb3a57` |
| `binding-template.json` | `12493ca49698ef00603e1722e7ea363d3997e86ac2b89921e5c5a9de9aeceb5a` |
| `test_migration.py` | `71e2bad62827541cf96f57dbb4c0d43b2b15e308dc0334294eac2ee1ab58df5f` |
| `README.md` | `f8b77c7f4b38671f03146c55ae0bba16201076aa3ff2e7ec03476a80799e0992` |
| `regression-results.json` | `6a5bac5ab8883e9c3d1f57e5757a12bad9da75d08b38444398288f70f75de971` |
| `spec-review.md` | `1ef295174d8ee31658166ca299c2e6bbfe225b2071ba986c17bcd000a9b0a6de` |

- Governing proposal hash: `3a43e54127052568364e5bdbeb1e70b7a2d98a0454132f9777c4c24859bfaf83`; governing binding-review hash: `60f00b2d8f574a006499f5a20e7ca25e156f7a2116b754ebe7822bea06dc2e91`. Verified both through the preserved-input receipt.
- Each of the proposal's three replacements occurs exactly once in its original. Applying only that replacement in memory produces the exact successor and the proposed hash. Thus Python ROOT and the two Tcl cwd assertions are the only harness changes; no checks, stage operations or subprocess behavior were altered.
- Baseline bytes are identical. Recomputed the actual local 34-file BMC inventory and both board-boundary hashes: exact baseline matches.
- Parsed candidate equality is exact, including argv, six-key environment and identity maps. All candidate boolean flags remain false and reviewer null. The template is the candidate object, not the proposal envelope.
- Test bytes differ only by `LOCAL_N = m.HERE.parents[1]` becoming `LOCAL_N = m.HERE.parents[2]`. Direct script execution imports the sibling successor and restores the original fixture root.
- All 28 preserved original-file hashes, all nine delivered hashes in the regression receipt, and all ten existing `SHA256SUMS` entries match. This establishes present byte identity, not historical absence of transient writes. The manifest predates review files and was not modified.

## Source-bound checks and stage barriers

`migration.py:304–338` retains early binding rejection before claims, writes or subprocesses. It checks exact root/source/part/argv/cwd/project/search values, full source inventory, mailbox settings, board boundaries, harness identities, enumerated tool/catalog/evidence hashes, review flags and constrained environment. The delivered false/null candidate fails the first review check. These are source-bound review checks, not an OS sandbox or proof that the enumerated runtime closure is exhaustive. Named tmux identity and the candidate's exact six-key environment still require external prelaunch verification; the generic checker alone does not independently establish either.

`stage():341–361` retains exclusive scratch creation, copy readback and directory-aware snapshot. `run():364–404` retains claim binding, QPF/QSF/script equality, required directory/no-link checks and whole-scratch snapshot equality before a new stage claim or vendor process. Child and parent require clean preceding reports plus independent approval of the exact report SHA-256. Raw before bytes and exclusive failed-attempt claims are retained; there is no automatic retry or chaining.

The allowed source deltas remain leaf-only for upgrade, leaf/child for child refresh, and parent-only for parent refresh. Non-target system content and parent external boundaries remain protected (`243–287`). Tcl stays targeted to `sdm_mailbox` and `bmc_spi_sub_0`, with completion/error markers. Post-run project/binding checks, return-code/log checks and CLI failure propagation remain intact (`413–457`). Every report still has acceptance/readiness false and demands independent review. A clean report is not saved-state acceptance.

## Important retained limitations — not fixes or launch clearance

1. **Duplicate-role weakness remains.** `wait_port():183` constructs a role-keyed dictionary that can overwrite duplicate AVMM ports. `check_leaf()` also uses existence/first-match checks for some mappings and physical ports. Approval of these unchanged preparation bytes is conditional on full independent inspection of actual XML at every future barrier, before role dictionaries: decoded leaf `lockedInterfaceDefinition`, both child `componentDefinition`/`defaultBoundary`, and relevant parent representations. Reject duplicate AVMM roles and physical names; check IP-XACT mappings, unique one-bit output waitrequest, nontermination, retained readvalid/old ports, full parameters and actual version selection. Interpret conduit roles by their schema. At the upgrade barrier, child proxies must remain unchanged and unambiguous, not prematurely refreshed. No actual migrated XML exists in this review to accept; synthetic fixtures do not satisfy this obligation.
2. **Observer incomplete; launch blocked.** Adjacent `observer.py:96–99` unconditionally refuses vendor launch; its upgrade CLI calls that gate before preflight (`370–372`). Documentation discloses missing complete syscall/path/FD/rename/mmap audit and race-safe descendant accounting. The successor itself does not invoke this observer and would launch a vendor subprocess with a separately approved binding. Therefore this review is not permission to bypass the observer or flip flags. Complete independently reviewed observation, explicit parent authorization, fresh remote identity/path/hash verification and deployment readback remain outstanding.
3. **Isolation is proposal only.** `../isolation-alternative-review.md` describes a possible future vendor-only sandbox and explicit policy amendment. These exact successor bytes still call ordinary `subprocess.run`; no bubblewrap integration, namespace isolation or altered observation policy is implemented or approved here. Any integration requires new hashes and separate review, preserving the current artifacts.
4. **Saved-state checks are not RTL proof.** Nonconstant end-to-end backpressure, both requesters, retained readvalid and shared reset/FLR ownership require separately authorized standalone and nested generated-RTL validation. Serialized port presence and mocked success cannot establish them.

## Regression evidence and review activity

Verified the retained log contains exactly the same 35 class/method pairs as independent AST enumeration of the test source, all successful, followed by `Ran 35 tests in 157.198s` and `OK`. Receipt reports rc0 with no failures/errors/skips; log hashes and the recorded resolved interpreter hash match. Read raw stdout: synthetic stage reports retain acceptance false, including intentional failure fixtures. Tests mock vendor subprocesses and exercise binding mutations, directory/snapshot barriers, exclusive claims, stage approvals and CLI failure propagation; their positive fixture is not execution of the complete real remote candidate.

No tests were rerun, harness imported, scratch staged, remote/vendor/Tcl/HDL command executed, build performed or commit created. Local verification used read-only Python hashing, byte comparisons, JSON and AST parsing. **The only file written by this review is `successor-first-u01/quality-review.md`.**
