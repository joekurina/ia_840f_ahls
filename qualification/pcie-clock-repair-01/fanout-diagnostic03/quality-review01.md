# Independent QUALITY review — prepared Work14 fanout-diagnostic03

## Verdict and findings

**APPROVED — package QUALITY only. No critical or important blockers found in the exact prepared package.**

- **Critical:** none found.
- **Important:** none found.
- **Minor:** no package change requested. Native-behavior uncertainty and the inherited limitations below remain explicit; they are not defects to “fix” by widening this finite experiment.

This review follows the consumed SPEC PASS, but independently checks the actual source, complete retained package bindings and six permitted inert fixture outputs. It does not merely adopt the SPEC verdict. It grants **no native execution authority**, approves **no unseen issuer**, and does not accept any native result or close any task. Parent exact-binding acceptance and a separately inspected one-use issuer remain required; any future native result requires independent review. `approved=false` and `ready_for_build=false` remain intact. [`prepared-readback01/AUTHORITY.md:5–9`; `prepared-readback01/SPEC.md:27–39`]

## Exact review binding and integrity

All paths below are relative to this directory unless explicitly prefixed `../`. In citations, **Q**, **RUN**, **PREP**, **GATE**, **DISPATCH** and **HELPER** are the corresponding actual `prepared-readback01/` files: `query.tcl`, `run-query.py`, `prepare01.py`, `ia840f_clock_fanout03_gate.py`, `ia840f_experimental_gate.py` and `clock-repair.tcl`.

| Evidence | Independently checked SHA256 |
|---|---|
| Consumed `spec-review01.md` | `f6fdd7cf2e706dfaf6376fc606280b363c4308436060b98f8d3f6d70225a7594` |
| `parent-spec-consumption01.json` | `a90980c0d72d39ca10adc104b74b52308d7c3e906d027bcbbbbce7a069985280` |
| `preparation01.json.gz` — 1,434,403 bytes | `b9e6c8c35888553380cb047bb363fecf9c3d50e0b4f3b5e90339c0af18b63a70` |
| `prepared-manifest01.json` | `063e0f0baa29c39bd52981ef2b033538fec5068272dc221205c8433b017f3dca` |
| `prepared-readback01/candidate.json` — 4,191,423 bytes | `16acaa0babf1103eb573e76459f1e98fafc3aadeeff8b2acb23dd172d61a9949` |
| Q — 198 lines / 12,094 bytes | `22e5f6e05913325fa14a8753cda91c63bef98bec7893e333972f721e7c6e06b9` |
| RUN | `80f70410e5fc6bbf4f32f2494bcdd9740e4ef20e98939e748818653768abf263` |
| PREP | `fdca65fcbfc3da10e50b46b632f21b1c07b6be2f737ad6be0aa66a07b5bb961a` |
| GATE | `fcc3d278afc9d9fa656fe0beb68a2070978af331a14cdb978239208d58375868` |
| DISPATCH | `d8ba2587dfaf22fcd3225b1f929dd637adae055c4cc98cedd63a02d722537194` |
| HELPER | `8486a48acbe4f024beecefb95d09eeab69ce0331d3f16d4a1f9c0591cdb117f2` |
| `prepared-readback01/known-receivers.tcl` | `3bca69f770cba775919b7134822ae5eedcb324c1a25ed5540b781667d798ef6a` |
| `known-receivers-provenance.json` | `16c115401cd705ba6d73e02bd3f8bd1f5887c7794401360365f6a0022034fd64` |
| `prepared-readback01/preservation.json.gz` | `ba54fad92731357ffa65f163bdb402f133d3841f5e90660df752ac98f18394af` |
| `prepared-readback01/top.sdc` | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |

Before replay I froze all **46** specified files, excluding CURRENT, SPEC review and parent consumption from that original inventory and separately pinning the latter two to the hashes above. After replay and read-only analysis, all 46 file hashes and both prerequisite hashes were unchanged. The canonical inventory digest, using `json.dumps(relative_to_H_path_to_sha256, sort_keys=True, separators=(',', ':')).encode()`, is:

`12f2fdedcb7d9aa5f3ab6e0f2cb05899fa74f203161e49c44acdeccbd01ac2b9`.

The parent added `launch-source-inspection01.json` during this review. It is outside this frozen package and **was not consumed as issuer approval or authority**. CURRENT/status changes likewise do not rebind any prepared byte. Any changed frozen byte invalidates this review.

## Quality assessment

### 1. The collision correction is narrow, clear and causally testable

The replacement name identifies both diagnostic ownership and the actual collection type. I reconstructed the successor directly from the actual diagnostic02 prepared query. Its SHA256 is `de849ce56c3ae6db993a1e27d427c574cf6cccb7b7d68272a1c0ca8ab2468e5c`; replacing exactly the three scalar sites, before changing the root, produces `a6e4534c2ed2cd250832df0bf957c912d6fe8504c5348776abe8d950bdb4e9b4`. The fresh-root replacement then equals Q byte-for-byte. The saved `query-delta01.diff` equals a newly computed diff.

The sole functional intervention is the assignment at **Q:159** and its consumers at **Q:160,163**, renamed to `ia840f_fc_cell_pin_collection`; **Q:7** is the fresh-attempt root. The `-pins` API call and `pins:$name` label are preserved. Namespace/main isolation already existed; no vendor array is unset, overwritten, converted or linked into our scope. No fallback, broad alias search, changed escaping mode, hidden error-to-empty substitution or reordered SDC loading was introduced. [`query-delta01.diff:3–26`; `Q:15–18,73–85,154–185`]

The additive collision fixture tests the actual old and new full queries rather than a standalone renamed assignment. Its `catch`/`return -options` wrapper preserves exceptional exits while inspecting array sentinels before the caller frame disappears. No-array and global-only controls distinguish a genuinely conflicting caller-local array from an unrelated global array. Each synthetic caller injection reproduces the exact old failure and requires new-query completion plus unchanged sentinels. This is useful regression evidence without pretending to identify the native creator/scope. [`test-collision.py:16–28,39–80,84–103`]

### 2. Representation boundaries and partial-failure semantics remain honest

Q keeps physical cells, pin IDs, collection handles and timing registers separate. The new temporary holds the actual `get_cell_info -pins` collection; iteration yields a pin ID, and the reverse query uses that ID without trying to enumerate it as a collection. Buried registers come from their own cell-derived collection, not a same-name keeper assumption. The fixture enforces distinct `COL…`, `C…`, `PIN…` and `R…` namespaces and rejects invalid cross-use. [`Q:19–40,159–184`; `test-query.py:18–24,60–153`]

All four forward calls retain counts and immediate flushes, full raw-name observations, the 4096 per-set cap, duplicate/enumeration checks and complete-set relations. Incomplete membership is `unavailable`, not falsely empty. The named tile and all six raw/transformed first-cell selectors precede the four exact eight-cell group decisions. Exact clock pin and one-K reverse checks, the full 32-cell visitation check and completion qualification are retained. API failures escape; other incomplete observations retain useful records without issuing completion. [`Q:26–58,97–138,147–195`]

Zero/multiple in-cap buried registers intentionally remain diagnostic data and clear `mapping_single_register_each`; they do not falsely reject the bounded package or silently establish a one-register mapping. `complete` and this mapping flag are distinct from collector acceptance. Neither a positive unfiltered set nor all32/T name membership nor full diagnostic completion establishes a complete clock-only domain. [`Q:174–191`; `prepared-readback01/SPEC.md:23–29`]

HELPER, known-receiver Tcl and provenance remain byte-identical to diagnostic02. The helper is sourced for definitions and utility procedures only; `apply` and `verify_created` are not invoked. Its known driving-association-versus-definition precheck defect remains present and explicitly unapproved. No global helper correction or candidate authorization is smuggled into this scalar fix. [`Q:4–5,86–96`; `HELPER:27–73`; `prepared-readback01/SPEC.md:7`]

### 3. Prepared provenance reconciles without hidden inventory drift

I strictly decoded and compared **all 15** archive exports against their byte counts, SHA256 values, complete manifest membership and actual readback bytes, including the losslessly archived raw candidate. There were no extra readback files. All **eight** authoring counterparts were byte-identical to their prepared exports. [`prepared-manifest01.json:1–62`; `PREP:97–115`]

The full candidate was parsed, not sampled: **7,885 files, 7,762 callback files, 10 links**. The callback map is exactly the prescribed suffix-filtered file map, including matching hashes. All relevant exported bindings match the candidate, including root/copied gates, copied dispatcher and both top-SDC locations.

I independently reconstructed **7,873 copied-file bindings and all 10 links** from the identical original preservation inventory, the four relocation records, the single dispatcher insertion and copied successor gate. Removing that exact insertion from DISPATCH recovers the original dispatcher digest `6d40de976fde2caec77a264e46d29a89ea94aebbe9e542edac55555f69626e94` recorded in the preserved Work14 inventory. The remaining **12** candidate entries are exactly ten declared root inputs and the two STA launcher/runtime executable bindings. Links remain lexically inside scratch/PIM. [`PREP:48–98`; `prepared-readback01/path-relocations.json:1–22`]

Normalizing only `fanout-diagnostic03`, `ia840f_clock_fanout03` and `CLOCK_FANOUT03` to their declared 02 counterparts leaves no file/callback additions or removals, identical links and identical non-inventory contexts. Exactly **nine** file hashes differ, matching the complete recorded old/new/path list: query, runner, root gate, SPEC, AUTHORITY, copied gate, copied dispatcher, relocated `mem_ss.xml` and `ofs_top.qar_info.json`. All SDC bindings remain unchanged. [`preparation-verification01.json:23–74`]

This proves retained package/inventory consistency, not a fresh remote rehash or a per-open native file trace. The two relocated generated-file payloads are represented by their recorded hashes here, not separately exported complete bytes. Opaque QDB bytes were not rewritten by the inspected preparer; inherited literal original-QDB references remain a limitation rather than a claim of scratch-only native opens. [`PREP:60–76`; `prepared-readback01/SPEC.md:33`]

### 4. Retargeting preserves the selected runtime and fail-closed barriers

I compared actual prepared PREP/RUN/GATE/DISPATCH with their actual predecessor exports. They are exact mechanical identity retargets; the recorded runtime and three fixture diff files also equal recomputed diffs. The selected script entry remains **`main_supervised()`**, not the retained legacy `main()` or `wait_bounded()` definitions. There is no supervision redesign in this package. [`runtime-retarget01.diff`; `RUN:116–145,252–316`; `DISPATCH:289–294`]

The inspected supervision path protects the region immediately after successful spawn, reserves its metadata file exclusively before launch, uses WNOWAIT to keep the leader unreaped while group signaling may occur, checks descendants even after ordinary leader exit, and signals/drains before final reaping and postflight. Raw return status, abort reason and explicit termination confirmation remain separate; an unresolved inspection is not success. The permitted real-inert-child regressions exercise this actual selected entry, including post-spawn bookkeeping failure and TERM-resistant descendants. I found no current implementation defect requiring the previously accepted safety design to be reopened. [`RUN:134–249,273–300`; `test-supervision.py:30–36,51–107,108–163`]

Fresh root is `/home/uwb_student00/ahls/new_BSP/qualification/pcie-clock-repair-01/fanout-diagnostic03`, with native cwd `/scratch/syn/board/ia840f/syn_top` appended. The candidate preserves exact outer `/opt/altera/26.1.1/quartus/bin/quartus_sta -t <E>/query.tcl`, runtime `/opt/altera/26.1.1/quartus/linux64/quartus_sta` with argv `quartus_sta -t <E>/query.tcl`, and runner executable `/usr/bin/python3.9`, argv `python3 -B <E>/run-query.py`, cwd `<E>`. Part is `AGFB027R25A2E2V`; permission is `exact-offline-fanout-diagnostic03`. Authorization binds the exact candidate digest; source/link/context checks and live PID/start/ancestry checks remain. [`GATE:10–42`; `PREP:98`; `RUN:252–267`]

Host `Agilex7Workstation`, uid1000, owned session `ia840f_mailbox_monitored_01`, competing-native rejection, exclusive/spent artifacts, 1800s wall cap, 64GiB address-space limit, 128MiB individual-file limit, 1GiB report-total cap, 80,000,000,000-byte MemAvailable floor and 20,000,000,000-byte preparation disk floor remain. These source-bound normal-account controls are **not an OS sandbox**. [`PREP:32–59,117–121`; `RUN:134–145,252–300`]

The retained preparation receipt is ordinary-file-only, window/pane `@52/%52`, outer rc0 with the checked archive digest. Its actual prepared runner and dispatcher negative checks both have rc1 and `CLOCK_FANOUT03_REJECT missing reviewed authorization`, with authorization/vendor flags false and donors unchanged. These entries were inspected as saved evidence, not run standalone by this reviewer. [`preparation-dispatch01.json:3–11`; `preparation-pane01.txt:1–2`; `prepared-readback01/tests.json:1–16`; `PREP:99–108`]

## Independent inert replay

I inspected the fixture sources and loaded query/helper/known inputs before executing only the following six commands. Every script path was expanded under local H `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/pcie-clock-repair-01/fanout-diagnostic03`, and every cwd was exactly H. Outputs were retained in memory; saved receipts were not overwritten. Assertion optimization was not enabled.

| Command (`python3 -B` + absolute H/script) | Validation cases | Complete saved JSON equality | Saved receipt SHA256 |
|---|---:|---|---|
| `test-query.py` | 25 | `query-tests01.json` — equal | `363e84cff9309ea245ad8ead30f2bf5359db3e70fca0d3f993b764034b4e2b4e` |
| `test-query.py --prepared` | 25 | `query-prepared-tests01.json` — equal | `363e84cff9309ea245ad8ead30f2bf5359db3e70fca0d3f993b764034b4e2b4e` |
| `test-collision.py` | 10 | `collision-tests01.json` — equal | `074e46d47294921e4f81c8d113fb9300d4535ba74fccc7293a995c465ee78ac1` |
| `test-collision.py --prepared` | 10 | `collision-prepared-tests01.json` — equal | `01ae6803837d4d40c6ba2e24ef525a82f8297ced118c5bee8bb382dd86cb98dc` |
| `test-supervision.py` | 11 | `supervision-tests01.json` — equal | `4dc9fe577e20a857769a7c3f94bdab8e530990774e4bdd69a85773d18db7038d` |
| `test-preparation.py` | 2 | `preparation-tests01.json` — equal | `8ecd52b6b95b62e3c7993974ba0e0e9d2a5b20338c49d567c43938bc37291417` |

**All six returned rc0, empty stderr, and all 83 validation rows passed.** Complete parsed JSON equality includes bindings, record counts, messages and status fields, not only the totals. Expected old-query failures count as passing differential validations, not successful diagnostic completions.

- **Query:** both source sets passed aliases, same-name and alternative matcher scenarios, all-zero forward observations and zero/multiple buried-register observations. The latter emitted 31/33 per-register records respectively while retaining 32 cell-map records and a false single-register flag. Over-cap, duplicate, group/tile/type/pin/reverse defects prevented completion; API errors preserved their own messages. Old/wrong cwd rejected before project/opened-audit operations, and spent/project-error/gate-sentinel cases rejected. [`test-query.py:157–194`]
- **Collision:** no-array/global-only controls completed old and new. For each of read_sdc, collection-loop and pin-API caller-array injections, old returned Tcl rc1 with exactly `can't set "pins": variable is array`, one CELL, no mapping/completion; new returned Tcl rc0 with 32 CELL/CLOCK_INPUT/CELL_REGISTER_MAP/REGISTER records and one completion. Both retained four fanout counts, six selectors and T. Each old failure recorded one unchanged caller sentinel snapshot; each successor recorded 68 unchanged snapshots. The global control remained unchanged. These are synthetic ordinary-Tcl mechanisms, **not native-origin proof**. [`test-collision.py:60–80`]
- **Supervision:** clean children returned raw/effective 0/0 and 7/7. Metadata failure, leader-zero/seven with descendants, wall/wall-descendant, output cap, wait failure and group-inspection cases returned effective124. The leader-zero/seven cases retained raw0/raw7. All 11 had no live owned process at return and unchanged rejected-rerun evidence; the deliberately unconfirmable inspection kept `termination_confirmed=false`, despite fixture cleanup observing no live child. PIDFD-based fixture cleanup and preserved donor checks passed. These are owned inert Python children with mocked gate/host/resources/tmux, not vendor execution. [`test-supervision.py:108–174`]
- **Preparation:** evaluated preparer/runner/gate roots agreed; actual existing-leaf rejection left the sentinel and leaf contents unchanged and did not append an unowned error receipt. Python3.9 grammar checks passed. No copy/native stage was reached. [`test-preparation.py:8–39`]

## Preserved limits and remaining gates

The accepted diagnostic02 failed-result lineage is reused, not reviewed or authorized a second time. I read its RESULT-ACCEPTANCE and rechecked the historical review, diagnosis and parent-consumption hashes: `3dad601f05e8968ec893008e9f95300f51f7330c8ae6a7a527a9107416b9e6a7`, `2449999c2efeef88cee8307250c793b9c3e19042e62307c680f64d40081ea8cc`, and `0a1c95a172d49500a31e46211d9758cf04d144054c71ebfa0674f7161c815bc6`. Its native/effective/outer rc3 attempt remains spent. The scalar failure did not demonstrate pin-API failure; creator/scope remain unknown. [`../fanout-diagnostic02/RESULT-ACCEPTANCE.md:3–20`]

Retain all459 prior default-set strings. The25 duplicate-suffix and79 LUTRAM-name relation to fitter355 is not physical identity proof. Equal default sets, empty filtered sets and known32/T name membership remain partial design-specific observations, not complete clock-only mapping. No full collector fix, affected-domain coverage, A/B baseline qualification or repair of the blocked helper/old candidate is accepted here.

Native success is **unknown**, and is not demanded as a circular prerequisite to approving this bounded package. Future result review must assess actual counts, identities, API/other diagnostics, completion, SDC filename/binding provenance, termination and original preservation. Failure remains evidence, not permission to broaden selectors or alter constraints.

All timing/setup/hold, CDC/DRC, separate EMIF1 hold, fit/persona/backend/recovery, DDR/transfer/AHLS numerical and sustained operation, and durable-boot qualification gates remain open and separate. No maintained-source, hardware or mission acceptance follows.

**Write boundary:** only this `quality-review01.md` report is authored. The original 46-file freeze and SPEC/parent-consumption pins were rechecked unchanged after the permitted replays and read-only analysis. No source, fixture, saved receipt, authorization, claim, status/task file or other package record was modified. No remote connection, vendor/native/help call, hardware operation, git write, authorization issuance, standalone actual runner/gate/preparer entry, or issuer execution was performed. No blocking issue or tool failure was encountered.
