# Independent SPEC review — actual prepared fanout-diagnostic03

## Verdict

**PASS — no blocking SPEC gaps in this exact prepared scalar-rename successor.**

This is prospective package SPEC compliance only. It is **not** QUALITY approval, parent acceptance, authorization issuance, native-result acceptance, collector qualification, timing/hardware acceptance, or task closure. No unseen issuer is approved. `approved=false` and `ready_for_build=false` remain unchanged. The separate QUALITY → parent exact-binding acceptance → separately inspected one-use issuer barriers remain; any subsequent native result requires independent review. [`AUTHORITY.md:5–9`; `SPEC.md:27–39`]

Review scope is the existing finite unchanged-SDC Work14 diagnostic, not the broader BSP goal. Accepted diagnostic02 failure/diagnosis is inherited evidence, not a pending review reopened here. Its reviewed source delta is exactly the diagnostic-owned scalar plus two references and fresh-attempt identity retargeting.

## Exact evidence binding

Paths below are relative to this directory unless stated otherwise. `Q`, `HELPER`, `PREP`, `RUN`, `GATE`, `DISPATCH`, and `CAND` mean the corresponding files under `prepared-readback01/`: `query.tcl`, `clock-repair.tcl`, `prepare01.py`, `run-query.py`, `ia840f_clock_fanout03_gate.py`, `ia840f_experimental_gate.py`, and `candidate.json`. All eight authoring exports were verified byte-identical to their prepared counterparts, including SPEC and AUTHORITY. Citations are 1-based source lines; large candidate maps were parsed completely, not sampled.

| Artifact | SHA256 |
|---|---|
| `preparation01.json.gz` — 1,434,403 bytes | `b9e6c8c35888553380cb047bb363fecf9c3d50e0b4f3b5e90339c0af18b63a70` |
| `prepared-manifest01.json` | `063e0f0baa29c39bd52981ef2b033538fec5068272dc221205c8433b017f3dca` |
| CAND — 4,191,423 bytes | `16acaa0babf1103eb573e76459f1e98fafc3aadeeff8b2acb23dd172d61a9949` |
| Q — 198 lines, 12,094 bytes | `22e5f6e05913325fa14a8753cda91c63bef98bec7893e333972f721e7c6e06b9` |
| `SPEC.md` | `d2e9c18bd243bf1f35f7ab66b055504dda12096e5c50e28e10f9198dd434012a` |
| `AUTHORITY.md` | `c3b3cc5ee69f20a6630e03bd6bb505e3ec0704b958dde89db906cc8d7105aaa3` |
| RUN | `80f70410e5fc6bbf4f32f2494bcdd9740e4ef20e98939e748818653768abf263` |
| GATE, including candidate-bound copied gate | `fcc3d278afc9d9fa656fe0beb68a2070978af331a14cdb978239208d58375868` |
| DISPATCH | `d8ba2587dfaf22fcd3225b1f929dd637adae055c4cc98cedd63a02d722537194` |
| PREP | `fdca65fcbfc3da10e50b46b632f21b1c07b6be2f737ad6be0aa66a07b5bb961a` |
| HELPER | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `known-receivers.tcl` | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| `known-receivers-provenance.json` | `16c115401cd705ba6d73e02bd3f8bd1f5887c7794401360365f6a0022034fd64` |
| `prepared-readback01/preservation.json.gz` | `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af` |
| `prepared-readback01/top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |

Before behavioral replay, I froze all **46 existing non-CURRENT files**. The SHA256 of `json.dumps(relative_path_to_sha256, sort_keys=True, separators=(',', ':')).encode()` was, and after replay/read-only verification remained:

`12f2fdedcb7d9aa5f3ab6e0f2cb05899fa74f203161e49c44acdeccbd01ac2b9`.

`CURRENT.md`, this new report, and any subsequent unbound parent status/launch-inspection artifacts are outside that frozen comparison. No changed bound file was excused by that exclusion.

## Findings against SPEC

### 1. The query is exactly the permitted intervention

I reconstructed expected Q directly from diagnostic02's actual prepared query, requiring exactly one occurrence of each of the three replacement strings. The old SHA256 is `de849ce56c3ae6db993a1e27d427c574cf6cccb7b7d68272a1c0ca8ab2468e5c`; the in-memory rename-only, old-root version hashes to `a6e4534c2ed2cd250832df0bf957c912d6fe8504c5348776abe8d950bdb4e9b4`. Applying the fresh-root retarget produces actual Q byte-for-byte. `query-delta01.diff` also exactly matches a recomputed diff.

The only substantive query changes are `ia840f_fc_cell_pin_collection` at Q:159,160,163; Q:7 is the mechanical root change. The `-pins` API option and `pins:$name` audit label remain intact. No vendor-array unset/conversion, error-to-empty substitution, global `literal()` change, helper repair, fallback selector, or moved SDC load was introduced. The native array's origin/scope remains unknown. [`SPEC.md:5–7,37–39`; `query-delta01.diff:3–26`; `Q:15–18,73–85,154–185`]

HELPER, the known-receiver Tcl, and its provenance JSON are byte-identical to diagnostic02. I matched all 32 Tcl rows against the provenance records, verified four groups of eight, and checked the retained Q2 source-log hash `6d934bb5862574a6518fc5803d051757eefcb88a3caaf2f7db44850971460b89`. HELPER supplies definitions; its `apply` and `verify_created` entries are not called by Q. The known incorrect future-candidate precheck at HELPER:45–56 is neither fixed nor approved. [`known-receivers.tcl:1–35`; `known-receivers-provenance.json:1–11,173`; `HELPER:27–73`; `SPEC.md:7`]

### 2. All finite observations and acceptance boundaries are retained

- Normal project-open/netlist/argument-free read_sdc/update order, exact fresh cwd/report destination, exclusive audit creation, and source-gate sentinel remain. C must be absent and helper-created false. [`Q:73–96`]
- All four forward calls retain their actual O/K collections and immediate count/flush records; the unchanged 4096 per-set cap, raw names, duplicate/enumeration checks, and complete-set relations remain. Incomplete membership is `unavailable`, not falsely empty. These are enumeration caps, not a claim that native graph traversal is intrinsically bounded. [`Q:11–14,26–58,97–117`; `SPEC.md:11–15`]
- Named T and all six raw/transformed first-cell API contrasts remain before physical-group decisions. There is no global matcher-mode change or automatic selector winner. [`Q:118–136`]
- Four fixed groups require exact eight-name sets; all 32 physical identities must be visited once. Cell type, actual cell-pin collection, input-clock properties, the already established single-pin-ID reverse call, exact saved pin/K relation, actual buried-register collection, clock association and per-register membership remain. [`Q:137–188`]
- Zero/multiple in-cap buried registers remain legitimate observations and set `mapping_single_register_each` false. They are not a circular prerequisite for approving this diagnostic package, and cannot qualify a collector. API errors propagate; identity/cap/duplicate defects prevent completion. The completion marker still means finite diagnostic completion only, not positive coverage, A/B comparison, clock repair or timing acceptance. [`Q:174–195`; `SPEC.md:23–29`]

### 3. Actual prepared bytes and complete inventory closure reconcile

I decompressed the retained archive, required batch `ia840f_clock_fanout03_preparation01`, and independently verified **all 15 exports**: strict base64 decoding, exact byte counts, SHA256, readback byte equality, complete manifest membership, and absence of extra readback files. The raw candidate is retained losslessly in the archive despite its local git-ignore rule. [`prepared-manifest01.json:1–62`; `.gitignore:1`; `PREP:110–115`]

CAND has exactly **7,885 file**, **7,762 callback-file**, and **10 link** bindings. Its callback map equals the specified suffix-filtered file map, including all corresponding hashes. Every exported file that participates in candidate bindings matches those actual bindings, including both gate locations, copied dispatcher and both top-SDC locations.

The complete preservation inventory is byte-identical to diagnostic02's export and contains 7,346 Work14, 1,656 SOURCE, and 536 PIM entries. Reconstructing the copies from that inventory plus the four recorded relocation entries, the inspected dispatcher insertion and the one copied successor gate exactly reproduces **all 7,873 copied-file bindings and all 10 links**. The remaining 12 file bindings are exactly the ten declared root inputs and two unchanged vendor-executable identities. No arbitrary omitted/changed files were accepted. Link targets remain lexically within the prepared scratch/PIM copies. [`PREP:48–60,60–98`; `prepared-readback01/path-relocations.json:1–22`; `CAND:8–7771,7775–15673`]

After normalizing only the declared 02→03 identity tokens, the full predecessor/successor file-key and callback-key sets have **no additions or removals**, every link agrees, and **all non-inventory context fields agree**. Exactly nine file hashes change: query, runner, root gate, SPEC, AUTHORITY, copied gate, copied dispatcher, `mem_ss.xml`, and `ofs_top.qar_info.json`. This independently matches the complete recorded delta, not merely its count. The latter two changes match the before/after hashes in the path-relocation record; their full remote payloads are not separately exported here. All SDC bindings, including top.sdc, remain unchanged. [`preparation-verification01.json:23–74`; `prepared-readback01/constraint-delta.json:1–6`]

These are independent checks of retained raw exports, complete inventories, source transformations and preparation receipts—not a new remote rehash or a per-open native provenance trace. No opaque QDB bytes were rewritten by the inspected preparation path; historical literal original-QDB proxy references remain an explicit limitation, not asserted scratch-only opens. [`PREP:60–76`; `SPEC.md:33`]

### 4. Fresh routing and inherited safety contract are preserved

The preparer, runner and gate are exactly their predecessor bytes after mechanical root/module/permission/buffer/marker retargeting. The actual copied dispatcher is also exactly retargeted. The recorded runtime and three test delta files match recomputed diffs. `main_supervised` remains the selected runtime entry; no monitoring/descendant-recovery redesign was introduced. [`runtime-retarget01.diff`; `RUN:312–316`; `DISPATCH:289–294`]

CAND binds part `AGFB027R25A2E2V`, permission `exact-offline-fanout-diagnostic03`, the exact `quartus_sta -t <fresh-root>/query.tcl` outer/runtime contexts, and the runner `/usr/bin/python3.9`, argv `python3 -B <fresh-root>/run-query.py`, cwd `<fresh-root>`. The root is `/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic03`; native cwd appends `/scratch/syn/board/ia840f/syn_top`. [`CAND:2–7,7772–7774,15674–15692`]

The host/uid/owned-session guards, 80,000,000,000-byte MemAvailable threshold, 20,000,000,000-byte preparation disk threshold, competing-native check, exclusive fresh leaf and OWNED failure-receipt guard remain. Runtime retains exact file/link/context checks, live claim identity/ancestry, exclusive single-use artifacts, 1800-second wall cap, 64-GiB address-space limit, 128-MiB individual-file limit and 1-GiB report-total cap. Preservation or unresolved termination cannot become success. These are normal-account source-bound controls, **not an OS sandbox**. [`PREP:32–59,117–121`; `GATE:10–42`; `RUN:134–249,252–300`; `SPEC.md:31–33`]

Preparation receipts identify window/pane `@52/%52`, outer rc0 and the exact archive digest. The actual prepared runner and dispatcher missing-authorization checks both returned rc1 with `CLOCK_FANOUT03_REJECT missing reviewed authorization`; the receipt states donors unchanged, vendor not launched, authorization not issued. I verified these retained results and inspected the corresponding code; I did **not** rerun either actual entry standalone. [`preparation-dispatch01.json:3–11`; `preparation-pane01.txt:1–2`; `prepared-readback01/tests.json:1–16`; `PREP:99–108`]

## Independently replayed inert tests

I inspected all four fixture sources, their loaded query/helper/known sources, and runner/preparer/gate entry behavior before replay. The only behavioral executions were the six expressly permitted local fixture commands below, each using expanded absolute script paths and cwd equal to this fanout-diagnostic03 directory. No saved receipt was overwritten. Every process returned **rc0 with empty stderr**, every expected case passed, and **the complete returned JSON equaled its existing saved receipt**, including source bindings and records—not just the declared counts.

| Command (`python3 -B` plus absolute local script path) | Cases | Saved complete JSON matched |
|---|---:|---|
| `test-query.py` | 25 | `query-tests01.json` |
| `test-query.py --prepared` | 25 | `query-prepared-tests01.json` |
| `test-collision.py` | 10 | `collision-tests01.json` |
| `test-collision.py --prepared` | 10 | `collision-prepared-tests01.json` |
| `test-supervision.py` | 11 | `supervision-tests01.json` |
| `test-preparation.py` | 2 | `preparation-tests01.json` |
| **Total** | **83** | **All six complete comparisons equal** |

The inherited query cases retain distinct cell/pin/register/collection namespaces, full-entry cwd/report checks, both matcher scenarios, aliases, zero/multiple buried-register data, cap/duplicate/identity/API failures, and old/wrong/spent-root rejection. [`test-query.py:18–156,157–194`]

The additive differential runs the actual old and successor full queries under five array conditions. No-array and global-only controls complete both versions. Each of the three synthetic caller-frame injections reproduces the old exact `can't set "pins": variable is array` failure, one physical CELL and no mapping/completion; the successor completes all 32 mappings and retains four forward calls, six selectors and T. The catching loop observes exact unchanged array sentinel contents before the procedure frame exits, including old failures. No array cleanup is used. These are **synthetic ordinary-Tcl mechanisms, not recovered native cause or Quartus emulation**. [`test-collision.py:16–80,84–103`]

The supervision fixture now mocks the actual successor03 import and exercises the real inherited supervised entry with owned inert Python children, mocked gate/host/resources/tmux, failure paths, no surviving live owned writers, and unchanged rejected-rerun evidence. The preparation fixture inertly checks evaluated root equality and actual existing-leaf rejection before copy/runtime work. Their scratch files are temporary fixture artifacts, not project changes. [`test-supervision.py:30–36,108–174`; `test-preparation.py:8–39`]

## Residual limits and write boundary

- The rename removes the reproduced synthetic collision but does not prove native success or identify who created the native array. A future failure must remain evidence, not grounds to infer unsupported pin APIs or absent loads.
- Accepted diagnostic02 history remains: the equal 459-name default sets and empty filtered sets, known32/T name membership without completed mapping, and the first raw/transformed lookup contrast are design-specific observations. Duplicate-suffix/LUTRAM-name arithmetic does not establish physical equivalence or justify dropping names to force fitter fanout355. [`../fanout-diagnostic02/RESULT-ACCEPTANCE.md:14–20`]
- Unknown buried-register cardinality is experimental data. No positive complete clock-only collector, affected-domain coverage, clock propagation, exception/timing comparison, CDC/DRC closure, fit, persona or hardware qualification follows from this PASS.
- The inactive helper's candidate guard and old experiment03 candidate remain blocked. No new help/native probe is needed for this rename review, and no issuer is approved by it. [`SPEC.md:7,25,29,35`; `AUTHORITY.md:5–9`]
- I rechecked the accepted historical review/diagnosis/parent-consumption hashes: `3dad601f05e8968ec893008e9f95300f51f7330c8ae6a7a527a9107416b9e6a7`, `2449999c2efeef88cee8307250c793b9c3e19042e62307c680f64d40081ea8cc`, and `0a1c95a172d49500a31e46211d9758cf04d144054c71ebfa0674f7161c815bc6`. Their acceptance is inherited, not reissued.

**Only this report is authored.** The frozen 46 files and old query/helper/known inputs were rechecked unchanged after all six replays and read-only verification. No code, source, saved receipt, authorization, claim, task state or other documentation was changed; no remote, native/vendor/help, hardware, git/auth, actual standalone runner/gate/preparer, or issuer operation was performed. No blocking SPEC issue was encountered.
