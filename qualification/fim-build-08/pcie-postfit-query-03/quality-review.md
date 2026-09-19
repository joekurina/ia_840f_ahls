# Query03 independent quality review

**Verdict: APPROVED for the bounded post-fit diagnostic experiment. No must-fix issues found.**

This follows the specification PASS and is bound to the exact bytes below. Approval is not a native result, readiness finding, or issuance of authorization. Candidate `approved=false` and `ready_for_build=false` remain unchanged.

## Focused findings

- **Runner identity and exclusivity:** gate lines 10–24 parse Linux start ticks correctly, compare the live complete claim and reviewed runner executable/argv/cwd, then require the callback parent ancestry to reach that runner. Lines 37–40 independently constrain immediate STA identity. Runner validation precedes exclusive claim and log creation. Missing authorization rejects before these writes. This is an accidental-execution guard, not an adversarial sandbox.
- **Status and timeout:** runner preserves native status and emits `REQUIRES_LOG_REVIEW`; the 80-second `subprocess.run` timeout becomes rc124. A consumed claim rejects reruns before subprocess launch or evidence modification. Timeout kills/waits the direct child; it is not a general process-tree watchdog. The reviewed STA launch is a single query, not a compile-flow launcher. Inspect for surviving vendor activity if native timeout occurs rather than treating rc124 as acceptance.
- **STA/Tcl:** installed help supports the selected pin/cell properties, clock target collections and `get_fanins -clock -stop_at_clocks`. Vendor collections are traversed with `foreach_in_collection`; ordinary constructed period lists use Tcl list operations. Source clock matching and explicit zero output-target-clock counts are coherent. Finite cell/clock inventory and fanin queries do not add clocks or timing exceptions. Ambiguous input endpoints or an unexpected source-clock name reject. Native collection/pin behavior remains experimental, not a circular precondition to launching this reviewed diagnostic.
- **Evidence limits:** fitted divider mode is explicitly unavailable through the captured STA API. Name-based PLL/CSR checks are diagnostic heuristics, not physical proof. `PROPOSED_ONLY` remains hypothetical; output clock counts mean target-associated clocks, not every propagated clock. A zero divider count or absent input-clock information cannot establish divider acceptance. TRS absence requires reviewing the complete native inventory and completion, not just rc0 or a marker.
- **Bindings:** recomputed manifest hashes match; all four script exports match their candidate prelaunch bindings, and every callback digest equals its corresponding prelaunch digest. The dispatcher routes the exact query03 cwd to the isolated gate before unrelated branches. Remote preservation assertions remain supplied evidence, not independently reverified by this local review.

## Independently exercised, inert only

- Five ancestry cases: positive descendant accepted; stale ticks, wrong argv, unrelated ancestry and absent identity rejected. Also exercised `identity()` against this local Python process and checked PID/PPID.
- Executed the runner text with only its evidence root relocated to a temporary directory, a fake gate module and mocked subprocess: native rc0, native rc7 and TimeoutExpired all persisted and propagated correctly; timeout argument remained 80. For each case a rerun rejected at exclusive claim creation, made no second subprocess call and preserved all evidence bytes.
- Executed the supplied Tcl fixture using tkinter Tcl with mocked vendor commands: output matched the supplied fixture log exactly, including alias-token distinction and explicit zero output clocks. Replaced the mock clock name with an unrelated name and verified `DIVIDER_INPUT_NOT_EXPECTED_CSR` rejection.

These tests do not establish Quartus integration. The next useful step is the actual bounded diagnostic under the parent's existing authorization process, followed by review of native status and the complete log; no further framework or broad audit is requested.

## Minor, nonblocking note

`native-result.json` uses `write_text`, not exclusive creation. The immutable consumed claim already prevents normal rerun overwrites, verified above; do not delete/reset that claim. Exclusive result creation would be optional defense against an inconsistent manually altered evidence directory, not a prerequisite to this fresh experiment.

## Reviewed SHA256

| Artifact | SHA256 |
|---|---|
| candidate.json | `911bcf9cead7d2e7cd3e7c6c486a19633a07aa97070825a1fef1570dfd651428` |
| query.tcl | `9eba919bbceb7bf30a330eb9de589bf7d1433ff3df3c68234d7afab7d42af9a1` |
| run-query.py | `3c1791ee1fcd297930027da5a91b009fcd99853e7b5d83948231ffe80f1448c4` |
| ia840f_query03_gate.py | `9f02ff5576d55b5153738b93dcf465d675a4086fd5054aa9a1be767b8dc6c26e` |
| ia840f_experimental_gate.py | `d9fb29dd3cc900356c670f2dc429d72fcd25e1461260edbb949334b735c92630` |
| spec-review.md | `7590ebdb6572a3c26435ccff44a5280ca6fbfb13fa7ba260f35b66206631511c` |
| REPORT.md | `6478f6df3c298a2057e6649f9d9c94bdc693011dd4dd445358f9e9389bea70eb` |
| tests.json | `564314f93117d366343be75ff793bf98f9936104e398a5f1e5c3ad4a7050c349` |
| ancestry-tests.json | `bdc520fba748f5e2cfd2e8755cc7283bc2a2cf59dda59c50e8ba590b2a61aec0` |
| query-fixture.tcl | `c65b054244d1cfd94a14629ffaca021586b016cda331daa3037b6d0ef8920d5b` |
| query-fixture-result.txt | `86e8332f5156117a5eee95b8356bfa265ed7591bd032b23e2816c7320251e267` |
| prepare-remote.py | `424f3420ba309ec056fa7320b4c55d8f1de3803acf8b3dd2b8a54487f107a46b` |
| hashes.json | `d6e629a18b426741df085370e2c543bac78562d7f59beb3b2fc1dde246fd34fb` |
| ../pcie-postfit-query-01/api-help2.log | `9ee495aad959b7119eb422b05ecef69345ecda80a7ab87f17d450f6b5d83b6d4` |

Scope: local reads and inert tests only; created this review only in the project. No remote access, vendor launch, source changes, authorization, Work09 modifications, DDR simulation, hardware actions or commits. Temporary test directories were removed.
