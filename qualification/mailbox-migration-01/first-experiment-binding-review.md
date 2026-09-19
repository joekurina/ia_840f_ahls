# First mailbox scratch experiment — independent binding review

## Decision

**PASS_WITH_EXPLICIT_EXPERIMENTAL_LIMITS.** The finite evidence is sufficient for the parent to authorize one observed selective leaf-upgrade experiment after the concrete staging preparations below. It is not sufficient to claim successful loading, exhaustive runtime closure, migration acceptance, an OS sandbox, or build readiness. **No execution authorization is issued by this reviewer. `ready_for_build: false`.**

The existing binding must not simply have its flags flipped: the attached proposal is deliberately unapproved, with all flags false and reviewer null. It recommends a fresh root, coordinated source-bound path rebinding, the explicit license environment, finite observed identity additions, and an independently verified observer. These are actionable parent staging work, not a demand for another recursive catalog investigation or successful vendor execution before permission to experiment. No user blocker is established.

## What the actual finite evidence establishes

- Independently hashed `followup-evidence-live01.json`: **3387272 bytes**, SHA-256 `7c407469a4196058230f3585c4d2908359f488a267c8e6f357e6d11ea240a9c7`. Parsed all five query results, their caps/unresolved arrays and supporting records. The supplied collector rc0 is collection status, not a vendor result.
- Independently hashed live02: `0c13de271466b3db1fd10585f99d965886a662e67d8421022bceceb9c768c0ed`. Its **358 records** have no record error, expected-hash mismatch or full-text hash mismatch. Followup's **136 records** also have no record error/full-text hash mismatch. Rehashed full-source/catalog config/archive-member texts as well. The 169 reused-record references are explicitly historical, not fresh revalidation.
- Catalog query: **108486 directory entries / 10455 texts / 24 full match files**, with the full-match cap reached. Launcher query: **80 archives / 40 resources**, both caps reached. Native query: **60 direct candidates**, not 60 selected dependencies. Helper query: **zero new files**, not proof that conditional/generation/dynamic dependencies do not exist. No expansion beyond this finite batch is required for the first experiment.
- The formerly missing SPI definition is actually captured: `/opt/altera/26.1.1/ip/altera/eip/altera_avalon_spislave_to_avalonmm_bridge/SPISlaveToAvalonMasterBridge_hw.tcl`, SHA-256 `9e66ac8ea6cca98c671ffef3a3fae788a560d17b9085a7c4d6095925de08d78c`. It declares `className spi_slave_to_avalon_mm_master_bridge`, version **20.0.0**, Agilex 7 support and a real Avalon-master waitrequest input. Its saved source remains 19.1.3 and must NOT be upgraded as collateral work. Its RTL callbacks are generation resources, not a reason to expand this saved-state experiment.
- The five previously named load/package helpers and five runtime candidates are in live02. Their exact byte hashes are inserted in the proposal. `reload_component_footprint`, `validate_component_footprint`, and `sync_sysinfo_parameters` were **not observed** in the capped package resource search; that is neither evidence of absence nor successful API discovery.
- Read actual root catalog XML: default `$` expands beyond the two explicit custom directories, including project-relative roots, installed IP, a relative shared-IP root, built-ins/factories and optional user paths. The clean scratch HOME, device-only QSF and excluded override variables reduce ambiguity but do not establish selected catalog implementations or absence of competition. Record actual opens/resolution in the experiment. Built-in 26.1 declarations are not proof of the requested Tcl APIs.
- Public mailbox composition still has DEBUG=0 / HAS_STREAM=0 / HAS_OFFLOAD=0. The config-stream endpoint is active under DEBUG=0; the offload memory endpoint is not. Do not omit the config endpoint merely because HAS_STREAM=0. Public **23.0.0**, core **21.0.0** remain expected selected versions, not already proven selections.
- Followup records the old fixed scratch absent and its ancestors non-symlink, readable license, and named tmux `ia840f_migration_preflight` (`$4`, `%4`, pane PID 25387). These are historical observations. It explicitly records **no deployed monitor** and no never-used-history proof.
- The missing help receipt was deployed/read back in the parent's live02 verification at unchanged hash `79db4ecb18aa7eeeeadb4de914902594c99bca775bb4a0e545e8769df5954ffd`; independently checked local bytes and matching live02 basis. Installed help rc0 establishes spelling, not selectivity. Failed prior API probes do not prove API support. The first real explicit-project operation is permitted to answer that question.

Read actual proposed/template bindings, complete harness and Tcl scripts, source baseline, README, original/rereview/final specification reports, quality report and runtime-catalog review. Recomputed all four original harness hashes, exact **34-file** local BMC inventory and both board boundary hashes. Prior tests remain prior tests; this review ran no tests.

## Exact proposed scope and changed binding fields

Machine-readable deliverable: `first-experiment-binding-proposal.json`, SHA-256 `3a43e54127052568364e5bdbeb1e70b7a2d98a0454132f9777c4c24859bfaf83`. It is a proposal envelope, **not directly a migration binding**; its `candidate_binding` is the full future binding. `changes_from_proposed_binding` gives **139 exact JSON-pointer additions/replacements**, including every concrete hash. `review_basis` binds the actual old source/report bytes. Do not pass the envelope to migration.py.

Use fresh root:

`/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch-first-7c407469a419-u01`

Fresh absent path plus exclusive mkdir establishes this attempt's single-use claim; universal history is not required. Never delete the old scratch or a colliding new path. If this fresh name already exists, stop and review a newly named successor; do not reuse it.

This **requires** coordinated changes because `migration.py:14` and both Tcl cwd assertions hard-code the old path. The proposal supplies exact one-occurrence byte substitutions and computed successor hashes, without applying them:

| File | Proposed SHA-256 (not written/deployed/tested) |
|---|---|
| `migration.py` | `a4f360484dba25f4e0a12a7cdb294b1387c86f1bb7b884480acb630368bb2f9c` |
| `child.tcl` | `3b735d9ccb1886dfbc3791a905abde3afa067892743798a5e4ed344cb7071362` |
| `parent.tcl` | `5b8d78e78e61cec558fcbe8abd5f1eb9cdd6a76efc203cfb4d598adf2fbcf51d` |

Parent must review/apply those substitutions in a successor, update its accompanying template/docs and verify deployed bytes. The unchanged existing template and candidate are not silently superseded. The proposed Python replacement was AST-parsed only. Existing test evidence covers the old bytes, not a new test run of these successors.

Changed operational fields are exactly `root`, `cwd`, root-dependent strings in all three `argv` vectors, `search_path`, `env.HOME`, `env.TMPDIR`, three `harness_hashes`, `env.LM_LICENSE_FILE`, and additions to `tool_hashes`, `catalog_hashes`, `evidence_hashes`. Unchanged: source path/inventory, part/speed, QPF/QSF/revision, all vendor options other than root substitution, source-baseline identity, reviewer/review flags and readiness.

The first vendor vector remains the exact array in the proposal: qsys-generate `--upgrade-ip-cores bmc_spi_sub.qsys --batch=./ip/bmc_spi_sub/sdm_mailbox.ip`, followed by the explicit fresh QPF, revision `mailbox_migration`, part `AGFB027R25A2E2V`, and fresh custom arbiter/IRQ search string with literal `,$`. Cwd is fresh `bwbmc`. No shell expansion, all-IP request, FIM project, bypass, implicit project, synthesis/simulation flag or wrapper callback is added. QSF remains exactly family Agilex 7 and DEVICE only. This is the minimal operational/project binding, not a claim that the count of retained evidence files is mathematically minimal.

Environment is closed to exactly six keys:

```json
{
  "HOME": "/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch-first-7c407469a419-u01/home",
  "TMPDIR": "/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch-first-7c407469a419-u01/tmp",
  "PATH": "/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/qsys/bin:/usr/bin:/bin",
  "QUARTUS_ROOTDIR": "/opt/altera/26.1.1/quartus",
  "LANG": "C",
  "LM_LICENSE_FILE": "/home/uwb_student00/quartus_26/LR-191011_License.dat"
}
```

Do not inherit collector `LD_LIBRARY_PATH` or `QUARTUS_ROOTDIR_OVERRIDE`; do not add Java injection, CLASSPATH, IP_IPX_PATH, Questa or shell startup exports. License is the absolute readable node-locked path; never derive it from scratch HOME or copy license contents into the report.

The finite hash envelope has **120 tool/runtime identities, 25 catalog identities, 5 evidence identities**. It deliberately retains the already collected 77 whole JAR identities and compatible direct-native candidates as a conservative finite superset, not an asserted selected classpath. Catalog additions are SPI, five helpers and five explicit catalog-index/configuration files. Arbitrary unrelated catalog/example Tcl and the inactive offload component are not authorized merely because the search found them. Full maps and exact changed hashes are in the JSON, avoiding prose abbreviation of identifiers.

The **27 remaining native candidate references** (including ordinary symlinked libraries/OS paths) are separately retained with target hash and symlink-chain evidence. Do not insert these symlink paths into the harness's no-links dictionaries or rewrite vendor argv to resolved targets. An external preflight compares these recorded chains/target bytes; the runtime observer then records actual selections. Additional native libraries or Java resources inside the bound 26.1.1 runtime or standard OS roots are a disclosed loader-discovery allowance: capture their identities for review, not a false claim they were statically pinned. A changed known identity, different installation, user-injected runtime or unexpected executable stops the run. Exhaustive transitive dynamic closure is an acceptance investigation, not a prerequisite circularly requiring prior execution.

## Concrete observation / stop / retention policy

Use **strace follow-fork syscall capture around the Python harness from process start**, not attach-after-launch or process polling alone. Its exact proposed prefix, trace path, limits and lifecycle are in `monitoring_recommendation`. Resolve/hash the workstation's actual strace and Python paths; validate supported options and fork/exec/file-write capture with a harmless nonvendor probe before staging. This tool availability/observer check has NOT been performed here. If unavailable or ptrace-restricted, use a separately reviewed equivalent observer; never silently run unobserved. This is finite operational preparation, not another vendor discovery experiment.

Observer storage is exclusively created outside scratch at `/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/observation-first-7c407469a419-u01`. Per-stage trace/log files are observer-owned, not vendor write permission. Keeping live traces and approval JSON outside scratch avoids changing `staged.json` or prior-report snapshot equality. Use umask 077. Capture all syscalls, full argv/env strings up to the specified bound, fork/clone/exec/exit, cwd/dirfd paths, file descriptors, writes and shared writable mappings. Raw read-syscall formatting avoids recording license read buffers. Treat any truncation that hides relevant argv/path identity as nonacceptance. Supplement with PID/start-time/executable/maps records; these snapshots do not replace syscall tracing.

The observer/watchdog must be running before vendor launch; record its own identity and health. First-stage command and environment are exact; internal launchers/Java/quartus IPC argument strings are explicitly observations to be reviewed, not invented pre-known commands. Expected executable identities are limited to the bound launcher, bound JRE and bound quartus wrapper/native IPC path. Shell interpretation is limited to the bound wrapper, not arbitrary `-c`. An unexpected executable, generation/compile/fit/assembler/simulator, changed project path, user init file or original/FIM sourcing stops the experiment. Do not authorize a process merely because it inherited a stage label.

Bound each attempt to **1800 seconds / 2147483648 trace bytes**, with watchdog checks every second and TERM then KILL after 10 seconds. Run in a dedicated process session/group and also track descendant PID/start-times so setsid children are accounted for. Stop on observer failure, lost traces or unaccounted descendant. Record final survivor scan. These limits are a proposed supervisor policy, not functionality currently present in migration.py, and polling cannot prevent an unexpected write before detection.

Vendor persistent writes are allowed only under the fresh scratch. Scratch HOME/TMPDIR caches, tool logs, backups and incidental files are retained and reviewed; this is NOT permission to modify unrelated BMC source or the QPF/QSF. Observer alone may write the observation directory. Read-only node-locked license use, /dev/null, anonymous pipes and ordinary local IPC are acceptable; pathname sockets/caches must be scratch-local. No external persistent cache or remote network endpoint is preapproved. Unexpected external writes/connections => stop, retain, review. No cleanup, deletion or rollback is automatic; a detected original/work03 change invalidates acceptance even if subsequently reverted.

Audit trace paths using cwd/dirfd, descriptor aliases, renames and shared writable mappings, not just open filenames. Rehash original BMC and board boundaries and retain a before/after protected-workspace manifest (including original/work03) to supplement trace evidence. Complete tracing follows descendants, but is not a hostile-process sandbox or proof against external services/concurrent writers. **Do not describe this collector or observer as sandbox proof.**

Keep all exclusive claims, raw before bytes, before/after scratch/project inventories, target XML, stdout/stderr, syscall traces, process/maps identities, watchdog status, partial outputs and failures through independent disposition. Trace loss, timeout, malformed output or a missing final report never permits retry. No monitor file may be inserted into scratch after a snapshot to manufacture acceptance.

## Authorization versus acceptance, and stage barriers

Parent's separate approval may interpret `*_reviewed=true` as **reviewed bounded experimental scope with disclosed uncertainty**, not proof of previously successful loader/API use or exhaustive closure. This resolves the older README/spec language that otherwise circularly requires loaded-project success before the first project experiment. Record that interpretation with the actual approval; do not silently change boolean meaning or declare earlier claims satisfied. All these fields remain false here.

Prelaunch: parent approves limited scope, applies/verifies successor root bindings, verifies observer, current named tmux/host/user, fresh path/ancestors, exact remote source/tool/catalog/evidence hashes and read-only license, and no-links compatibility for new SPI/IPX entries. Evidence files in the proposed remote hash map must actually exist there with matching bytes; local presence alone is not deployment proof. Harness exclusively creates scratch; do not precreate it for the monitor.

1. **Stage, then selective mailbox leaf upgrade only. STOP.** Only `ip/bmc_spi_sub/sdm_mailbox.ip` is an allowed bound-source change. An immediate-parent Qsys rewrite or unrelated IP version update rejects this attempt even with rc0. Review actual loader selections/logs, leaf version/parameters/ports, QPF/QSF equality, complete output set, trace/external-effect audit and retained original hashes. This first barrier does not require already refreshed child proxies: those are intentionally stale until stage 2; require them unchanged and unambiguous, not falsely coherent with the upgraded leaf.
2. **Child refresh only after independent exact-upgrade-report-hash approval. STOP.** Named `sdm_mailbox` sync/reload/save, expected leaf/child targets only. Require both child proxy boundary representations now coherent with the upgraded leaf; no broad reload.
3. **Parent refresh only after independent exact-child-report-hash approval. STOP.** Named `bmc_spi_sub_0`; external parent boundaries unchanged. Final independent acceptance is still required; no automatic migration/build promotion.

At **every barrier**, manually/static-parse the **full actual XML** and reject duplicate AVMM roles before constructing dictionaries. This compensates for the known `wait_port()` dictionary overwrite weakness at migration.py:183. Count roles in decoded leaf `lockedInterfaceDefinition`, both child `componentDefinition`/`defaultBoundary` representations, and relevant parent representations. Review IP-XACT logical/physical maps and physical port-name uniqueness as well. Roles like conduit exports must be interpreted by schema; the mandatory role-uniqueness rule concerns AVMM, not an indiscriminate ban on every repeated role string anywhere. No harness helper result alone is acceptance.

Require unique one-bit output `avmm_waitrequest`, correct mapping, nontermination and no constant replacement; preserve `readdatavalid`, all old ports/mappings, addresses, clock/reset/IRQ routes, source logical references, exact full parameter set (including hidden/auto fields), FIFO depths 1024/1024/4, feature flags and both SPI/SDM requesters with globally shared resets. Full target timing/property changes need explicit independent review. Core 21.0.0 selection needs actual resolution evidence, not merely a public version string; insufficient evidence means retain and investigate, not manufacture approval.

Real **nonconstant** backpressure end-to-end through generated core/wrapper/interconnect to `sdm_pipeline.m0_waitrequest`, retained readvalid, shared reset/FLR ownership and both requesters require later standalone **and nested RTL generation/validation**. The user's overall generation authorization is not lost, but this binding intentionally covers saved-state migration only. Do not treat serialized port presence as that later RTL proof. No synthesis/fit/timing/hardware qualification is granted.

## Verification and unchanged artifacts

Static consistency assertions passed: receipt hashes/basis, full-text hashes, local source and boundary identities, unchanged source/part/QPF/QSF, root-only argv substitution, proposed successor byte hashes, and false review/readiness fields. No harness import/run, remote command, vendor executable, Tcl interpreter, test, build or scratch staging occurred.

Only these two review deliverables were written. Exact reviewed input SHA-256 identities:

```text
19b329ce0c475ea65f3457494e21dd83d215e6aabde84826a3add4fd06071e03  proposed-binding.json
a9a597bf88a3a8cfd1792ba7456ce3d9cc0cfb477486eccf1ee47327cba8c8a0  binding-template.json
35a69d8c0cfdea91434c907bdba5ea41123fd9dfed3ac8a82f7a934a731e44c7  migration.py
bab7fd328d6b053e6ce3e270e847229d35f7d9f296f4c3b79fb29d6f238cb9ba  child.tcl
98bd59f3dfdcc324990e6281cc7f15deebf44450be0559a0719ff53e5e23ea9b  parent.tcl
0bf737cd94f50033255b4abc1966c454433d1c467f5eae8f369e65d82f1bbed5  README.md
148bb2897db6416a5950d152b6a8104c39cffda494e2723c97afecce9efb3a57  source-baseline.json
e72e617ee926bc5731662e486d8d8d7c626e4294d2837bcc99753acb7cfd5d24  spec-review.md
d85248707be374e9debecaaff7a042680d21fb1bbd54d0611be47bdeb66d0640  spec-rereview.md
668b9bfb028228b8cd07069e3009140dfbfdba80f9090f8edb8fba5960c61412  spec-final-review.md
072d6b4df2f9a675221624fc11caabd061f5504ec1a7a6c20f29b24109d30525  quality-review.md
3b4a140459e78282abc7d0b3f5d58795d32ad1a28127df69fa7a54d4786e20e1  runtime-catalog-review.md
0c13de271466b3db1fd10585f99d965886a662e67d8421022bceceb9c768c0ed  binding-evidence-live02.json
7c407469a4196058230f3585c4d2908359f488a267c8e6f357e6d11ea240a9c7  followup-evidence-live01.json
3ffe4a1ad72fd15cef98388c428bc42efef505421e679b854a01e0f0ba154ea3  live02-parent-verification.json
```
