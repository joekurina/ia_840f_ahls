# Work12 header-correction-02 — focused independent specification re-review

## Verdict: PASS (specification only)

MUST FIX 1 in `spec-review.md` is resolved for the reviewed successor. This is not quality approval, authorization issuance, remote staging, or native-result acceptance. Independent quality review must follow before the separately gated native header experiment. All build/compile/functional readiness remains false; timing, calibration association and constraint completeness remain unresolved.

**Reviewed successor manifest SHA256:** `ed1422e5dfc4acfddace312cfe5ab35c5575ab3dc43fcf6730a4df50d1a7c6e9`.

## Failure-evidence contract

Read the complete candidate runner and issuer, submitted regression driver, exact candidate diff, correction report, verification and transfer overlay. Compared complete parsed draft bindings against the original, not merely selected fields.

- `run_headers.py:33–36` captures the raw child return code and exclusively persists `native-status.json` while the native log is still open, before log close, diagnostic reads, output collection, postflight verification or inventory.
- Diagnostic reading, each output hash, each output stat, output persistence, strict postflight verification and strict inventory are independently collected. Errors are explicitly retained. An unreadable diagnostic log produces unknown/null flags, not false success.
- Strict inventory failure retains an error and triggers per-entry best-effort traversal. Failed entry hashes remain explicit errors, rather than permitting a partial inventory to count as accepted.
- Native zero with collection/postflight failure returns 1; native 17 remains 17; raw signal status -15 is retained and converted to outer exit 143. Every tested failure keeps native acceptance, build readiness and compile authorization false.
- Exclusive run-directory reservation and exclusive evidence creation remain intact. Rejected reruns leave prior fixture bytes unchanged. No timeout/supervision redesign or unrelated gate change was introduced.
- As documented by the implementation, evidence storage failures cannot guarantee persistence on an unwritable filesystem; the raw status is also retained in memory and the outer handler preserves its nonzero exit. This does not turn failed persistence into acceptance.

## Fresh local tests and independent probe

All execution used fresh local temporary copies and real inert Python children. No vendor executable or issuer was executed. Evidence root: `/tmp/work12-spec-rereview02-h3phf4sk/`.

Commands actually executed successfully (exit 0):

```sh
python3 -B /tmp/work12-spec-rereview02-check.py
# This checker ran:
python3 -B /tmp/work12-spec-rereview02-h3phf4sk/test_failure_evidence.py /tmp/work12-spec-rereview02-h3phf4sk/run_headers.py /tmp/work12-spec-rereview02-h3phf4sk/regressions
python3 -B /tmp/work12-spec-rereview02-h3phf4sk/independent_probe.py
```

**14/14 submitted cases passed freshly**, covering ordinary native 0/17, native 0/17 paired separately with postflight, hash, stat, inventory and diagnostic-read faults, and SIGTERM with/without postflight failure. Each case checks rejected-rerun immutability. Results, subprocess commands and fixture paths are in `regressions/results.json`; output is in `regressions.log`.

**Two additional independently authored combined-failure probes passed**, without importing the submitted test harness: native 0 and native 17 each simultaneously encountered (1) postflight mismatch, (2) strict inventory failure, and (3) a PermissionError hashing one output and that same fallback inventory entry. Observed exits were respectively 1 and 17. Both retained the native checkpoint, diagnostics, healthy output hash/stat, unreadable output's available stat, healthy fallback inventory entry, and all four explicit collection errors. Both rejected reruns without byte changes. See `independent_probe.py`, `independent-results.json`, and the two `independent-*` fixture directories.

Test source identities:

| Artifact | SHA256 |
|---|---|
| Submitted regression driver | `05d32f820ab32bb7051c05e0f9e0272473aa41d71eb370acc90f7cfd992910f1` |
| Independent probe | `60200698f68a6a435b487be88b7766cd8f22c1421639c44a2e1f743ca9ef4d88` |

Inspected durable `red-final` and `green-final` results and fixtures: both enumerate 14 cases, with retained immutable-rerun receipts. The old runner's postflight rc17 case exits 1 and lacks the corrected evidence; ordinary old rc0/17 cases retain their ordinary exits but fail the new checkpoint expectation. Old signal exit is 241 rather than 143. All final GREEN cases have no recorded problems and the expected native statuses. Preliminary `red.log`/`green.log` are harness failures (missing rerun receipt after the injected rerun ValueError), not successful regressions. They are correctly distinguished in the correction report. My first local diff check likewise had a reviewer-only ordering assertion error: it generated manifest-before-runner sections, while the supplied diff orders runner-before-manifest. Correcting only checker section order produced exact diff equality; no candidate changes were made.

## Minimal bindings and preservation

Independently recomputed using Python and rechecked payload preservation after tests:

- All **127 pre-existing qualification files** match `original-before.json`.
- Original and successor archives each contain **77 regular members**, with every member byte-equal to its corresponding local package file.
- Candidate contains exactly that same **77-file set**, with **76 manifest payloads**, all hashes verified.
- Exactly **three** package files differ: runner, header draft, manifest. All other **74** are byte-identical. Recomputed unified diff equals `candidate.diff` exactly.
- Full parsed draft equals the original after changing only the exact runner dependency hash. SOURCE/PIM/WORK/tool/dependency/native-context/permission bindings and false approval/readiness flags otherwise remain identical.
- Manifest payload changes are limited to runner and draft. Issuer is unchanged and dynamically checks the successor mappings.
- All **135 compile contexts** are byte-preserved with the original context file. All **eight required outputs** remain absent from the bound preheader inventory. No compile authorization or guessed postheader hashes were added.
- Previously accepted corrected-memory integration remains inherited unchanged: 283 project files, 12-QIP/210-edge closure, FIFO=0/copies=1, hold ON, seed 2 and unchanged maximum-placement effort. No repeated parameter research or new native integration claim is made.

| Artifact | SHA256 |
|---|---|
| Candidate runner | `7f411c876adf583227a7f4d45cd188ffba7f987d05b4228f2ff43e50ec9f521f` |
| Candidate draft | `d51473a0f16d757dc5c0624b40a858d2cb85835d6d7ec77f9684da88bfbc824b` |
| Unchanged issuer | `d1134328befd7e1ce49588b35e7bdd614f4ffa4ef8db8a8e150adc53df042011` |
| Candidate archive | `934c29efc126df35c3208a9d85acf80e6a550328b4175c87f91a2a973d5d6c8d` |
| Original archive | `8d2d59b71afd4364be074406c87d1c86e4d9a094e1e6d5644b430263ca4f6112` |

Machine-readable fresh checks are in the temporary evidence root's `verification.json`. The one-shot packaging script was not rerun.

## Deferred transfer and remaining gates

The documented transfer procedure satisfies this specification review, but has **not been executed or live-verified**. Original remote paths are deliberately reused only conditionally, not treated as already staged:

1. Fresh owned-tmux remote checks must establish absence of header issuance lock, header run directory, header authorization and compile authorization; stop on consumption or pre-existing backup rather than reuse claims.
2. Verify the full old 77-file package and old manifest, then exclusively create and hash-verify a permanent backup of all 77 files plus any original archive/spec report before replacement.
3. Recheck live SOURCE/PIM/dependencies/WORK/tools; captured checks cannot substitute for current inputs.
4. Overlay only the three exact paths/old-new hashes in `transfer-overlay.json`, manifest last; do not extract the complete archive over retained evidence. Verify the full successor manifest and exact delta afterward, retaining receipts outside manifest payloads.
5. Use reviews bound to the successor manifest, then the unchanged issuer's separately reviewed SOURCE integration. Successful native headers and independent actual-result review precede postheader inventory and separately reviewed full-compile bindings. Do not issue the compile fixture.

No remote command, vendor/Query04 execution, DDR simulation, hardware action, SOURCE/WORK/gate edit, installation, permissions change, authorization consumption, commit or push occurred. This report is the only new file in the qualification directory; all review scripts and inert execution artifacts are outside the package in `/tmp`. No concrete remaining specification must-fix was found. Quality approval remains pending.
