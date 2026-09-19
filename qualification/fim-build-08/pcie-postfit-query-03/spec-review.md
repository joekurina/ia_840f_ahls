# Query03 focused specification re-review

**Disposition: PASS for the bounded query experiment specification. Advance to parent quality review. This is not native acceptance or launch authorization.**

Reviewed against S1–S3 in query02/spec-review.md. Local read-only inspection and hash/inventory comparisons only; the sole write is this review. No vendor execution, remote access, source edits, authorization issuance, DDR simulation, hardware operation or commits. Work09 was untouched.

## Three prior gaps

- **S1 PASS — live exclusive-run ancestry.** run-query.py validates bindings before exclusively creating query.claim, then captures its PID, Linux start ticks, executable, exact argv, cwd and ppid. ia840f_query03_gate.py:10–24 rereads the claimed live process, compares the whole identity and candidate runner context, and walks the callback parent's live ancestry to that runner. Absent/stale/unrelated identities reject. Lines 37–40 additionally retain the exact immediate STA executable/argv/project cwd check. This is a source-bound accidental-execution guard, not an OS sandbox. The five reported ancestry fixtures are inert evidence, not a live Quartus ancestry demonstration.
- **S2 PASS — bounded connectivity interrogation.** query.tcl:35–72 emits divider cell identifiers/types, exact alias-token counts, pin identifiers/directions, actual clock-input fanins and their source identifiers. The captured query01/api-help2.log:775–834 supports get_fanins -clock -stop_at_clocks and its traversal through combinational paths to clock targets. Clock target matching reports full source clock name, master/master pin and period; ambiguous/unavailable PLL/clock resolution or an unexpected source-clock name rejects. Output pins have explicit target-associated clock counts, including zero. Proposed output period is computed from the resolved input period, not nominal 100 MHz, and no clock is created. Fitted-mode unavailability is explicit and separate from vendor divide-by-two evidence; alias correspondence is not inferred from spelling. Actual native endpoint resolution, CSR identity and aliases remain findings to inspect in the full experiment log, not conclusions of this review. In particular, target-associated output counts do not claim complete propagated-clock coverage; a zero divider count or missing clock-input information cannot establish connectivity acceptance.
- **S3 PASS — bounded TRS absence discriminator.** query.tcl:32–40,73–81 emits exact and hierarchical resource/clock counts for the requested inserted TRS hierarchy, inventories oscillator types independently of names, separately prints name matches, and emits an inventory-end marker after completing the scans. The unrelated altera_int_osc_clk is explicitly distinguished. Counts and native inventory completion must be reviewed together; the marker alone is not acceptance and does not invent an exception if TRS is present.

## Bindings and unchanged scope

Recomputed all five principal hashes below; each matches hashes.json, and the four executable/script exports match their candidate file bindings. Parsed 8,027 prelaunch files, 7,892 callback files and 11 links. Every callback digest agrees with its prelaunch digest. The 135 callback exclusions are exactly unchanged from query02 after path retargeting; links are retarget-only. No binding keys were dropped or added after query02/query03 name normalization. Changed copied XML/JSON bindings are consistent with the inspected preparation script's scratch-path relocation; remote bytes were not independently rehashed here.

The isolated experimental dispatcher diff is only the query03 cwd/module retarget. Unrelated setup/compile/runtime branches are byte-preserved relative to query02. Exact STA grammar, AGFB027R25A2E2V, source/link/tool checks and authorization hash binding remain. Candidate approved=false and ready_for_build=false. The runner retains its 80-second timeout and native return-code propagation.

The supplied missing-authorization results report runner/dispatcher rc1 before claim/log creation. Supplied Tcl fixture results are explicitly mocked. Preparation preservation claims are supplied evidence, not independently observed remote state. Native success is **not required before approval of this bounded experiment**, but native return code, complete log, API behavior and actual identities/connectivity must be checked afterward. No timing closure, PCIe clock relationship, TRS absence or readiness is established now.

## Reviewed SHA256

| Artifact | SHA256 |
|---|---|
| candidate.json | `911bcf9cead7d2e7cd3e7c6c486a19633a07aa97070825a1fef1570dfd651428` |
| query.tcl | `9eba919bbceb7bf30a330eb9de589bf7d1433ff3df3c68234d7afab7d42af9a1` |
| run-query.py | `3c1791ee1fcd297930027da5a91b009fcd99853e7b5d83948231ffe80f1448c4` |
| ia840f_query03_gate.py | `9f02ff5576d55b5153738b93dcf465d675a4086fd5054aa9a1be767b8dc6c26e` |
| ia840f_experimental_gate.py | `d9fb29dd3cc900356c670f2dc429d72fcd25e1461260edbb949334b735c92630` |
| REPORT.md | `6478f6df3c298a2057e6649f9d9c94bdc693011dd4dd445358f9e9389bea70eb` |
| tests.json | `564314f93117d366343be75ff793bf98f9936104e398a5f1e5c3ad4a7050c349` |
| ancestry-tests.json | `bdc520fba748f5e2cfd2e8755cc7283bc2a2cf59dda59c50e8ba590b2a61aec0` |
| query-fixture.tcl | `c65b054244d1cfd94a14629ffaca021586b016cda331daa3037b6d0ef8920d5b` |
| query-fixture-result.txt | `86e8332f5156117a5eee95b8356bfa265ed7591bd032b23e2816c7320251e267` |
| prepare-remote.py | `424f3420ba309ec056fa7320b4c55d8f1de3803acf8b3dd2b8a54487f107a46b` |
| hashes.json | `d6e629a18b426741df085370e2c543bac78562d7f59beb3b2fc1dde246fd34fb` |
