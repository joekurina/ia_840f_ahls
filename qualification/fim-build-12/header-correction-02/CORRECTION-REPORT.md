# Work12 header failure-evidence correction — local successor, awaiting review

## Result and scope

The successor is `candidate/`: a complete, narrowly rebound replacement of the original 77-file review package, retaining the original remote package, WORK, SOURCE, gate and native command paths. It is **not a second WORK tree**, not a remotely installed package, not an issued authorization and not accepted native results. Only three package files differ: `run_headers.py`, `header-authorization.draft.json` (one runner dependency hash), and `review-package-sha256.json` (runner and draft entries). The unchanged issuer reads these bindings dynamically; no issuer edit is necessary. `candidate.diff` is the exact delta. Historical assembly/test scripts and captured evidence remain historical; do not rerun preparation scripts to regenerate this correction.

Runner changes: persist `native-status.json` immediately after child completion, before log close or postflight; collect diagnostics, each output hash/stat, strict verification and WORK inventory independently; retain a best-effort per-entry inventory after strict inventory failure; record all caught collection errors explicitly. Every such failure rejects native acceptance; readiness and compile authorization stay false. Available nonzero native status wins over postflight failures, negative signal status converts to 128+signal, and native zero with a postflight failure returns 1. Claims and evidence files remain exclusively created; reruns cannot overwrite prior evidence. An exceptional failure while writing evidence itself is reported to stderr if the failure record also cannot be written; an unwritable filesystem cannot guarantee evidence persistence. No timeout/process supervision redesign.

## Real inert RED/GREEN execution

Commands run from the original local qualification directory:

```sh
python3 -B header-correction-02/test_failure_evidence.py remote-evidence/run_headers.py header-correction-02/red-final
# exit 1 (expected RED)
python3 -B header-correction-02/test_failure_evidence.py header-correction-02/candidate/run_headers.py header-correction-02/green-final
# exit 0; 14 cases passed
python3 -B header-correction-02/package_successor.py
# exit 0; exclusive one-shot packaging, not a repeatable check command
```

Each case starts an actual local Python child that writes two output files and diagnostic text, then exits 0/17 or receives SIGTERM. Remote identity, environment, gate bindings and selected failure sites are inert mocks, not vendor execution or remote live verification. Every case attempts a rejected rerun and hashes all retained fixture bytes before/after. Fresh `/tmp/work12-inert-*` roots are used; complete final fixtures were copied into `red-final/fixtures/` and `green-final/fixtures/` with byte verification for durable review.

| Case | Original behavior | Corrected behavior |
|---|---|---|
| native 17 + postflight dependency mismatch | outer exit 1; native rc absent from failure; outputs/inventory/results absent | exit 17; native rc17 checkpoint/result/failure, output hashes, diagnostics and inventory retained |
| native 0 + postflight dependency mismatch | outer exit 1 with incomplete evidence | exit 1; rc0 and available evidence retained, acceptance false |
| output hash, output stat, inventory, diagnostic-read exceptions; native 0 and 17 separately | collection exception interrupts evidence path | all eight cases preserve available independent evidence; explicit errors; exits 1/17 |
| ordinary native 0 / 17 | exits 0 / 17 | exits 0 / 17; evidence and rerun immutability preserved |
| SIGTERM (-15), ordinary and postflight failure | ordinary Python sys.exit(-15) gives 241; postflight gives 1 | raw -15 persisted; outer exit 143 in both cases |

Output-stat failure retains that file's independently available hash; output-hash failure retains its size/mtime; another healthy output remains hashed in every fault case. Inventory failure triggers best-effort traversal and retains healthy entries. Error details remain in `collection_errors`; unknown diagnostics are null rather than silently false. The checkpoint contents are also checked from mocked postflight load when present. Logs and `results.json` contain exact subprocess commands, exits and fixture locations. The original runner fails new checkpoint expectations even in ordinary cases, but its ordinary 0/17 exit behavior was unchanged.

`red/` and `green/` plus their logs retain the initial harness error: rerun rejection raised the injected ValueError, which the harness initially did not catch. The harness was corrected to accept any rejected rerun exception while still requiring byte immutability. `red-02/green-02` then confirmed RED/GREEN, and final runs additionally checked the checkpoint before postflight. No initial harness failure is presented as a successful regression.

## Package and preservation verification

`verification.json`, `original-before.json`, `candidate.diff`, and `transfer-overlay.json` hold machine-readable counts and hashes. Python checked all 127 pre-existing local qualification files, including original archive/spec review, unchanged; all 77 original archive regular members match original local bytes. The candidate has the same 77-member set / 76 manifest payloads: 74 files byte-identical and exactly three changed. Its tar members were read back and compared to candidate bytes.

- Original archive SHA256: `8d2d59b71afd4364be074406c87d1c86e4d9a094e1e6d5644b430263ca4f6112`.
- Candidate archive SHA256: `934c29efc126df35c3208a9d85acf80e6a550328b4175c87f91a2a973d5d6c8d`.
- Candidate manifest SHA256: `ed1422e5dfc4acfddace312cfe5ab35c5575ab3dc43fcf6730a4df50d1a7c6e9`.
- Issuer unchanged SHA256: `d1134328befd7e1ce49588b35e7bdd614f4ffa4ef8db8a8e150adc53df042011`.

The draft equals the original parsed draft except exactly the runner hash. All tool/SOURCE/PIM/WORK/dependency/header argv bindings remain identical except that hash. Compile gate, dispatcher, runner, 135 contexts, source overlays, corrected-memory evidence and all captured inventories remain byte-identical. Eight outputs remain absent from the bound preheader inventory. The accepted static 12-QIP/210-edge closure and 283-file transplant, two FIFO=0/copies=1 scope are inherited unchanged, not re-researched or re-executed. Existing captured remote tests are not newly executed tests.

## Deferred transfer — package only, not SOURCE integration

No remote command was made. Parent must obtain focused independent specification review, then quality review of this successor before header launch. Review acceptance must bind **the successor candidate manifest**, never the old manifest. No self-approval or accepted review envelope is supplied.

Remote package root stays `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-12`. Use only a fresh named window of owned tmux `ia840f_mailbox_monitored_01` on Agilex7Workstation, normal UID1000, for future transfer/preflight. Retaining original paths is conditional on a new live check that `header-issuance.lock`, `header-run/`, `header-authorization.json`, and compile authorization remain absent/unconsumed. Stop rather than replacing evidence or minting an unreviewed new WORK if that check fails.

Before any transfer, capture and verify the entire old remote 77-file package against the original manifest plus manifest hash. Create the exclusive backup directory `<remote-root>/header-correction-02-original-package/` and preserve all 77 original package files there, plus any existing original archive/spec review; hash-verify backups and preserve them permanently. Refuse to reuse a pre-existing backup directory. No transfer may overwrite original remote evidence without this verified backup. Recheck live SOURCE/PIM/dependencies/WORK/tool inputs with the reviewed preflight rules; captured old evidence is not a substitute.

The only allowed remote overlay, with expected old and new SHA256, is `transfer-overlay.json` (exact absolute target paths). In short:

| Target under remote root | Expected old SHA256 | New SHA256 |
|---|---|---|
| `run_headers.py` | `d62f18b3a7dd9c644859dbf5239c63e0bc300ff0b0708c8899087c495f4ff2dd` | `7f411c876adf583227a7f4d45cd188ffba7f987d05b4228f2ff43e50ec9f521f` |
| `header-authorization.draft.json` | `316a499b61cff2281d5b9785650ff53b969f80ec7ec4178692cac98595f120d5` | `d51473a0f16d757dc5c0624b40a858d2cb85835d6d7ec77f9684da88bfbc824b` |
| `review-package-sha256.json` | `a747747af93fa36911ac012e705982610fe481b404667d9ed5136a73a4e8822b` | `ed1422e5dfc4acfddace312cfe5ab35c5575ab3dc43fcf6730a4df50d1a7c6e9` |

Transfer these three files only (manifest last); do not extract the full archive over live remote evidence. Read back all targets and verify the full successor 76-payload manifest and exact three-file delta. Retain before/after inventories and backup receipt outside the manifest-covered files. SOURCE and WORK are not touched by this package correction. The issuer's later previously reviewed three-gate SOURCE integration remains a separate authorized step; no issuer or runner has been invoked here. Original `COMPILE-HANDOFF.md` sequencing remains applicable after this correction: fresh native headers and independent actual-result review first, then postheader inventory and separately reviewed full-compile bindings. No compile fixture may be issued.

## Limits / exclusions

No vendor, Query04/equivalent, DDR simulation, hardware operation, installation, permission change, authorization consumption, commit or push. No remote staging or live claim-state assertion. Hardware timing, calibration, constraint completeness and functional readiness remain unresolved/false. This report provides implementation/test evidence, not specification or quality approval.
