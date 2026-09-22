# Independent SPEC review — prepared fanout diagnostic01

## Verdict: PASS

**No blocking SPEC gaps found in the actual `prepared-readback02/` package.** The implementation matches the narrowed, unchanged-SDC, baseline-only observation contract. This is SPEC acceptance of those exact prepared bytes, **not QUALITY approval, execution authorization, native-result acceptance, collector validation, successful A/B evidence, or hardware/timing qualification**. No unseen future issuer is approved.

Only local reads, hashing/parsing and the four explicitly permitted inert fixture invocations were performed. No remote connection, vendor/help invocation, real preparation/runner/gate/issuer entry, authorization, git or hardware action occurred. Only this report was authored; saved fixture receipts and prepared artifacts were not rewritten. No tracked work was closed.

### Citation convention

- `F`: this report's directory, `qualification/pcie-clock-repair-01/fanout-diagnostic01`.
- `D`: `F/prepared-readback02/`; unqualified query/helper/runner/preparer/gate citations below refer to **D**, not merely authoring copies.
- `Z`: sibling `experiment03/`; `Q2`: `qualification/fim-build-14/pcie-postfit-02/` under the project root.
- Line references are 1-based. All SHA256 values below were recomputed from local bytes. Remote-state statements refer to the saved preparation capture, not a new live inspection.

## 1. Exact package and record binding

Decoded the lossless gzip archive in memory and independently checked its batch identity, exact export set, base64 bytes, lengths and SHA256 values against both the manifest and all **14** readback files. All applicable authoring files equal their actual prepared exports. The archive retains the complete candidate bytes irrespective of raw-candidate ignore rules.

| Artifact | SHA256 |
|---|---|
| `preparation02.json.gz` — 1,042,822 bytes | `8fb8eab7b421c0d9fb5f06f6f7169c598dbf347a38c43ae0988793a81e251f3c` |
| `prepared-manifest02.json` | `19c972f6e5e173c3b48e1bef4af73359dec0e695ddecf062daa07762b62e52e3` |
| `D/candidate.json` | `39afbfaec768985d9472da0b95c58df676afd0c273d1257a9f40180b9f44a719` |
| `D/SPEC.md` | `e0ea4dabe5fc9a96f0e489036daefd8e5c9cd7d8bf9c9f19a4e82ffe8a3e3e8c` |
| `D/AUTHORITY.md` | `a7039cc60913631743bfd16480363d0ab71d3948af14d3e38b9cdc98280a9adf` |
| `D/query.tcl` | `16ec28ff6ed66b9867338b09d4d12af0c3fa12d5926efd3b85cdc0c47edd0086` |
| `D/known-receivers.tcl` | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| `D/clock-repair.tcl` | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `D/run-query.py` | `fabd282e8c382f8eb36de419cc9959346ad7018f1dc3673782df23ee18288ff7` |
| `D/ia840f_clock_fanout01_gate.py` | `986c97fc71690c59b01e74e4fce2d0a56298f374fdfa3c198c87db1b3701d653` |
| `D/ia840f_experimental_gate.py` | `e59e732fc91c40d017206a9bca9478aa47dafe924b09ba4143268e283fd81cad` |
| `D/prepare02.py` | `87f3ba5f3c3acc0a8b120ad671f8b752620e1d989c4da6b1877a2f686a827522` |
| `D/top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |

The candidate independently recounts **7,885 file bindings, 7,762 callback bindings and 10 links**. Callback coverage equals precisely the full map minus `.qpf`, `.rpt`, `.log` and `.summary` suffix classes; no additional omission was found. Query, helper, known names, runner, authority, specification, constraint delta and top-SDC hashes agree with the record; copied phase gate/dispatcher and scratch top-SDC bindings also reconcile.

The exact remote evidence root is `/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic01`. The record requires:

- `approved=false`, `ready_for_build=false`, target `ia840f`, part `AGFB027R25A2E2V`, permission `exact-offline-fanout-diagnostic01`.
- Launcher argv `/opt/altera/26.1.1/quartus/bin/quartus_sta -t <root>/query.tcl`; native executable `/opt/altera/26.1.1/quartus/linux64/quartus_sta`, runtime argv `quartus_sta -t <root>/query.tcl`.
- Cwd `<root>/scratch/syn/board/ia840f/syn_top`; runner executable `/usr/bin/python3.9`, argv `python3 -B <root>/run-query.py`, cwd `<root>`.
- Recorded launcher hash `06c1bd805bc078d9636015c472e09a054160c405f3f06b7c555e7a4b6f7d3f14` and native hash `d675f96e7dffe1f7c736dfe2a20e1d3f4e576a5a53f714a644d2082c00fd4fae`. These are source-record bindings to the captured 26.1.1 installation, not freshly measured remote executables.

`preparation-dispatch02.json` binds the actual preparer to @48/%48. `preparation-pane02.txt:1–3` retains the matching archive digest and outer rc0. The lossless `D/tests.json`, identical to `preparation-verification02.json.actual_tests`, records capture time `2026-09-22T10:59:16.772191+00:00`, initial-copy equality and unchanged Work14/SOURCE/PIM, runner and dispatcher rc1 with `CLOCK_FANOUT01_REJECT missing reviewed authorization`, and `vendor_launched=false` / `authorization_issued=false`. These negative checks are not a native diagnostic run.

## 2. Narrowed observation contract — satisfied

| Requirement | Actual prepared implementation and finding |
|---|---|
| One unchanged baseline timing session | `query.tcl:64–85` enforces the exact cwd, rejects spent reports, exclusively opens the audit, then performs `project_open -revision ofs_top ofs_top`, `create_timing_netlist`, argument-free `read_sdc`, and `update_timing_netlist`. It checks the project gate result and requires the exact C name absent. No second SDC load, fit, path sweep or constraint modification is introduced. Original SDC clock-creation statements remain part of normal loading; “no clock creation” here means no added repair application. |
| Definitions-only helper | `query.tcl:4–5` sources the byte-identical helper and known-name data. Helper `apply` and `verify_created` are defined but never called by this diagnostic. `created` must remain false. The helper's latent generated-clock function is not authorization to execute it. |
| Clock inventory | `query.tcl:28–40` emits count before the 256-clock bound. Generated-only properties are queried only for `generated` / `virtual_generated`; `base` / `virtual_base` emit `not_applicable`. Unexpected types reject. No blanket Warning22890 suppression or raw-log filtering is added. Existing lookup `-nowarn` options are not used to turn API errors into empty success. |
| Exact two roots, no fallback | `query.tcl:86–99` validates O=`D|clock_div2` as one exact clock output pin through helper `one_pin:18–25`; independently resolves K=`D~div_reg` through both `get_keepers` and `get_registers`, each exactly one with the exact name. It does not substitute the fitter `clock_div2x` net or broaden the root patterns. |
| Both counts before load-range decisions | The pin `get_fanouts -clock` count is emitted immediately; the separate keeper count is then emitted before either enumeration decision (`query.tcl:90–102`). `emit:10` flushes each record. Neither fanout call adds `-stop_at_clocks`. Root/API failure propagates rather than inventing a second count. |
| Complete bounded sets | `enumerate_loads:42–58` enumerates every returned load for each count at most 4096, including zero as a complete empty set. Counts above 4096 are explicitly incomplete and not enumerated; the other set and remaining planned known-node observations are retained before final incomplete rejection. Both sets can total 8192 enumerated loads. This bounds enumeration/output, not the native traversal before counting. |
| No silent deduplication or prefix filtering | Every enumerated full name is retained, exact keeper identity is checked, and actual `get_clocks -of_objects` associations are emitted. Raw, enumerated and unique counts must agree; duplicates/cardinality mismatches prevent completion. There is no FIFO-only or hierarchy-prefix filter on returned loads. |
| Honest set relation | `query.tcl:103–111` emits full pin-only and keeper-only name lists/counts and intersection count only when both enumerations are complete. Otherwise the relation is explicitly unavailable. |
| Exact known32 and reverse fanin | `query.tcl:114–151` checks 32 distinct cells, exact cell/clock-pin resolution, input-clock-pin properties, and reverse `get_fanins -clock -stop_at_clocks`. Fanin count is emitted before its cap32; baseline then requires exactly one K. All four groups require eight and exact name-set equality, not merely counts. |
| Additional named load and missing membership | `query.tcl:153–162` resolves T, emits its actual clocks and membership in both sets, and emits missing names alongside all known-receiver records. Missing membership is not a positive collector verdict. |
| Diagnostic-only completion | `query.tcl:160–168` separates completeness from support flags. Both-zero or missing-membership observations can complete with false support. Over-cap/duplicate enumeration ultimately rejects; native/API or identity errors propagate without empty substitution. The distinct marker is `IA840F_FANOUT_DIAGNOSTIC_COMPLETE`, never the old comparison-baseline marker. |

The exact D/H/C constants are in `clock-repair.tcl:3–7`. Independently parsed `known-receivers.tcl` into **32 exact cell/pin records**, checked equality to `known-receivers-provenance.json`, and matched every record against Query02's raw CELL and reverse-fanin/count records. There are 32 unique cells and pins, four groups of eight, and 32 historical fanins naming exactly K with count1. Query02 log SHA256 is `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89` (`Q2/result-readback01/query.log:513–704`). T matches the exact register in the prior baseline's **Info13166 under Warning332060**, `Z/baseline/result-readback01/query.log:493–494`.

The captured installed help supports the chosen finite API surface: `api-help01/commands/get_fanouts.txt:29–40,67–75`, `get_clocks.txt:38–42`, `get_clock_info.txt:44–54`, and `read_sdc.txt:28–37`; the saved keeper/register/fanin/pin evidence was also hash-bound through the diagnosis. No fresh help capture is needed. None of this establishes that native O/K fanout sets will agree or that either will be usable.

## 3. Preservation, retargets and whole-lifetime boundary

Independently recomputed the complete predecessor-to-successor inventory delta against `Z/baseline/prepared-readback01/candidate.json`, normalizing only the exact evidence root and gate-module name. Result: **one addition** (`known-receivers.tcl`), **nine changed bindings**, **no removals**, and equivalent links. This exactly reproduces `predecessor-delta-verification02.json`.

Seven changes are the direct authored/gate bindings. The remaining two are the existing text-path relocations in `mem_ss.xml` and `ofs_top.qar_info.json`: both predecessor/successor relocation receipts share identical before hashes and reconcile their respective after hashes with the inventories. The parent's initial seven-change expectation omitted these two legitimate changes; the corrected comparison requires no package mutation. Both recorded absolute-link relocations reconcile as well.

The preservation-inventory digest is unchanged: `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af`. All **81 `.sdc` inventory entries** and **1,265 QDB-path/file inventory entries** remain hash-equal after exact path normalization. These are inventory-binding comparisons, not a claim to have freshly read every remote source/database file. Actual top.sdc and helper readback bytes also equal the predecessor; `constraint-delta.json` has identical before/after top-SDC hashes and baseline semantics. Normal loading may report preserved original paths embedded in the fitted database; actual loaded-file identity reconciliation remains a native-result review obligation, not permission to edit opaque QDB data.

`prepare02.py:45–59,106–108` checks the Work14 authorization/report identities, inventories original Work14/SOURCE/PIM, requires initial cp-a/reflink copies to match, and verifies originals again. Only scratch text/link relocations and scratch dispatch gates are added (`:60–98`). No maintained-source repair occurs.

The **actual runner**, not merely its saved diff, is byte-identical to the prior reviewed baseline after exactly normalizing root/gate, result-buffer identity, diagnostic completion marker and result label. The gate likewise differs only in exact root/module, permission and rejection identity; the dispatcher normalizes identically and routes the new cwd first (`ia840f_experimental_gate.py:289–305`). No supervision control-flow change is hidden in the retarget.

The prior Q1 reasoning therefore remains applicable to these verified corresponding bytes (`Z/quality-review01.md:27–37`): the CLI calls `main_supervised` (`run-query.py:312–316`), immediately protects successful spawn, observes leader exit without reaping, drains owned descendants before reaping/postflight, preserves raw status separately from effective failure, and rejects unknown termination and spent reruns. Legacy `main`/`wait_bounded` definitions are not the CLI entry. The local inert replay below also exercises the current runner.

Retained limits are wall1800s, RLIMIT_AS64GiB, individual-file128MiB, report-total1GiB, minimum MemAvailable80,000,000,000 bytes and no competing quartus_/qsys- process; preparation additionally requires20,000,000,000 bytes free (`run-query.py:134–174,252–300`; `prepare02.py:34–44`). Exact file/link hashes, runner PID/start identity and callback ancestry remain checked by `ia840f_clock_fanout01_gate.py:10–41`. These are source-bound guards and ordinary process-group supervision, **not an OS sandbox**.

## 4. Retained preparation failure — correctly distinguished

The failed `prepare01.py` retained relative E pointing to the spent experiment03 baseline. Its existence check rejected before copy/vendor work, but its catch appended a new preparation-error receipt into that unowned old directory. This was a preparer defect, **not a native failure** and not evidence that the entire old evidence directory received no new file (`PREPARATION-CORRECTION.md:3–7`).

Independently matched all **21** old artifact hashes recorded by `preflight02.json` to their accepted local prepared/result files and verified the retained appended-error string's hash. The captured prospective leaf was absent. The actual prepared `prepare02.py:8–10,49–50,117–121` fixes E, sets OWNED only after exclusive leaf creation, and permits an error receipt only for an owned leaf. Fresh02 transport identities and the exported preparer hash reconcile. The four inert regressions reproduce the old defect and require the new existing-leaf rejection to leave the fixture unchanged. Earlier authoring-verification01 is not accepted as proof of evaluated root agreement.

## 5. Independently exercised permitted tests

Ran these exact fixtures with `python3 -B`, cwd `/home/joe`; no output was redirected into saved receipts. Every invocation returned **rc0 with empty stderr**. Programmatically verified all pass flags/counts and their source hashes against the retained current receipts. Prepared Python exports additionally parse under Python3.9 grammar; this is not execution under a native Python3.9/Quartus installation.

| Invocation | Result | Saved receipt |
|---|---:|---|
| `test-query.py` | 18/18 | `query-tests02.json` |
| `test-query.py --prepared` | 18/18 | `query-prepared-tests02.json` |
| `test-supervision.py` | 11/11 | `supervision-tests01.json` |
| `test-preparation.py` | 4/4 | `preparation-tests02.json` |

The Tcl fixtures run the actual full query with mocked package/filesystem/vendor APIs. Cases cover empty/equal/subset/missing sets, both cap branches, duplicates, missing/duplicate root, group/reverse drift, API error, preexisting C, old/wrong cwd, spent reports and project-open sentinel. Prepared replay binds actual query/helper/known-name hashes; this review separately verifies exact recorded cwd/argv. The fixtures do not validate native collection semantics, actual clock associations or exhaustively inject every possible API/bound failure.

The eleven real-inert-child supervision cases retain raw0/7 separately from effective124 when descendants survive leader exit, terminate TERM-resistant writers, handle metadata/wait/inspection failures and wall/output caps, and leave no live owned child at runner return. Persistent inspection failure explicitly retains termination-confirmed=false. Every rejected spent rerun preserves evidence and performs no second spawn. The preparer fixtures mock host/session/transport identity and reproduce the stale-root/unowned-write defect only in temporary local scratch.

## 6. Disposition and remaining boundaries

**SPEC blockers: none.** QUALITY review and parent exact-binding consumption still precede any fresh native diagnostic. A future one-use issuer requires its own inspection, exact reviewed hashes, live preflight/preservation/resource checks, and exclusive unconsumed-state checks. This report does not issue authorization or approve an unseen issuer.

The accepted failed baseline remains native/effective3 with confirmed termination; its missing load count is still unknown between zero and greater-than4096. Fitter Fan-Out355 is not an STA fanout count. The diagnostic does not retroactively repair that missing evidence or enable experiment03's unissued candidate. The source diagnosis and independent failed-result review were hash-verified, and all **32** diagnosis source bindings in the parent's consumption record were independently rehashed.

After a separately authorized diagnostic, independent actual-result review must inspect raw/effective status, literal-true termination, complete observations and every cap, loaded SDC identities, errors/warnings, support flags/set discrepancies, and original-tree preservation **before choosing any future full A/B collector**. Diagnostic completion—even with positive known support—is not collector acceptance.

Omitting global corner/path/transfer reports is appropriate for this narrow observation question, not a relaxation of the later full A/B bar. A future comparison still needs complete-domain/out-of-prefix coverage and propagated clocks, understood A/B set identities and global transfer changes, exception precedence, all eight numerical FIFO constraints, every enabled corner and unconstrained-path/truncation evidence. Existing asynchronous cuts and overridden multicycles earn no new safety credit.

No maintained clock repair, refit, timing/CDC/DRC, DDR, OPAE/backend, recovery, persona or durable-boot qualification is granted. No device/sysfs/MMIO/JTAG/driver/flash/reset/reboot access is included. Selected-release and previously resolved/deferred research boundaries are not reopened; the mission remains incomplete.

### Additional supporting SHA256 bindings

| File | SHA256 |
|---|---|
| `preparation-verification02.json` | `69c255cb060ab3cc41205e4d1f66554801bec0dd130328f90099934effc5639f` |
| `predecessor-delta-verification02.json` | `1801d6a9a39e267063b9a6eddba2217a61cbbc98d8dcad3dcbd301301b9a0ef6` |
| `known-receivers-provenance.json` | `16c115401cd705ba6d73e02bd3f8bd1f5887c7794401360365f6a0022034fd64` |
| `query-tests02.json` | `e9b9979fe4366086fa3ac0e4b484175206808a37116e625b13810d4eeb6de512` |
| `query-prepared-tests02.json` | `3c25910c6149c3668c7ecb7e886a6e563489c0dbe5d77d6f33e1590c95db3460` |
| `supervision-tests01.json` | `175dbcf0b35f95d82a728b6be21995cddbfc7e572fc6ead6b5db2e9d252edcfc` |
| `preparation-tests02.json` | `02e8843d9392a49cce21740009dccb6344156840a4e3ee7c54de992d7d980fd0` |
| `preflight02.json` | `b94036767fd95578e534c2f3ad0c83f65a9925116a89ca6da9c2e96cd762ca05` |
| `Z/quality-review01.md` — prior Q1 reasoning | `e9c42ba465b7af2c69c8f131a031646ea002be2e47f7a594d32f3351d6875363` |
| `Z/baseline/RESULT-ACCEPTANCE.md` | `51091902df286ccc87e2f6e6fb643977de087ad280190759d36705f3c5f56225` |
| `Z/baseline/parent-result-consumption01.json` | `3006ea008bddf6e5afd6103349853d8513ca0d76a90f7d0bf21e4e660dbdf02d` |
| `Z/baseline/result-independent-review01.md` | `16971f186b464d07d4da051c50cc5ff2cbea57501a0a9d09446e10edc5d1cee7` |
| Sibling `fanout-diagnosis01.md` | `f8c83514f3df1433ddf45fa2deb304eab30b1aa6c2d28f74626c68120ae432cb` |

All pre-existing files in F were rehashed unchanged after the permitted fixtures and before report publication. No blocking issue was encountered during this review; the retained preparation01 defect is addressed by the reviewed preparation02 bytes and is not erased from the history.
