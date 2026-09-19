# Mailbox migration 01 — independent-review candidate

**Implemented locally; not authorized for vendor execution. `ready_for_build: false`.**
No remote access, vendor command, Tcl interpreter, QPF opening, generation, source
integration, gate change, or commit was performed. The only executed tests are
Python inert fixtures. Synthetic upgraded XML in tests is explicitly not vendor
output, compatibility evidence, or evidence that an upgrade will succeed.

## Proposed project context and validity boundary

The proposed successor is exactly:
`/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/scratch`.
The Python harness explicitly materializes `mailbox_migration.qpf` and
`mailbox_migration.qsf` only after complete reviewed bindings pass. QPF contains
only `PROJECT_REVISION = "mailbox_migration"`. QSF contains exactly:

```tcl
set_global_assignment -name FAMILY "Agilex 7"
set_global_assignment -name DEVICE AGFB027R25A2E2V
```

Speed grade 2 is encoded by the part and checked independently against saved
leaf `AUTO_DEVICE_SPEEDGRADE` / `deviceSpeedGrade`. There is no invented speed
assignment, TOP_LEVEL_ENTITY, FIM QSF source, IP assignment, board setup script,
pre/post flow callback, or implicit `--new-quartus-project`. An underscore-only
project/revision avoids the observed hyphenated implicit-project-name error.

**Assessment:** a device-only project is a plausible minimal context for component
upgrade/save, because device metadata and explicit Qsys files/catalog search paths
supply this operation's inputs; a full FIM open would unnecessarily execute guarded
setup and risk reference synchronization to work03/original sources. This is a
proposal, NOT proof the installed loader accepts this QPF/QSF or that the component
can migrate in it. `minimal_project_reviewed` and `api_26_1_reviewed` remain false.
If this context is insufficient, stop and review a revised scratch-only context;
never open the current FIM, bypass project handling, or strip existing gates.

## Implemented scope and files

- `migration.py`: closed argv construction, fail-before-write binding checks,
  exclusive staging and per-stage claims, non-symlink byte copies, whole-scratch
  snapshots at every stage (files and empty directories), hash checks,
  separate vendor stages, snapshots, semantic comparisons, raw logs and receipts.
- `child.tcl`: load the immediate system and named mailbox, assert retained public
  settings before/after leaf save and after named system-info sync; reload and
  validate only `sdm_mailbox`; save `bmc_spi_sub.qsys`.
- `parent.tcl`: separately load/save `bw_840_support.qsys`, syncing/reloading/
  validating only `bmc_spi_sub_0`. No bulk reload or second upgrade.
- `source-baseline.json`: actual SHA-256 inventory of all 34 BMC files (2 systems,
  24 leaves, both custom component Tcl definitions, four custom RTL files, and the
  preserved old wrapper/setup files), plus active board wrapper/setup boundary
  hashes and installed-help receipt hash. The preserved old setup is copied as
  inert source evidence; it is never registered/sourced by this project.
- `binding-template.json`: exact proposed paths, QPF/QSF content, argv, search path,
  source and harness hashes, captured mailbox catalog hashes. Explicitly unreviewed;
  installed executable hashes are null. It CANNOT authorize staging/execution.
- `test-results.json`: captured final Python test output/exit status and actual
  unreviewed-template CLI rejection (exit 1, before scratch writes).
- `test_migration.py`: inert XML, binding, staging, mutation and intercepted-run
  tests. Temporary directories are deleted by tests only; production scratch is
  NEVER deleted or reused. Tests never execute even fixture vendor executables.

The complete BMC tree is copied under `scratch/bwbmc`, retaining every relative
`logicalView` and custom Tcl fileset path. Active wrapper/setup remain read-only
boundary evidence outside scratch; their original hashes are rechecked, not sourced.
The custom source catalog consists only of the copied arbiter and IRQ directories.
The exact search string ends in literal `,$` for the standard installed catalog;
there is no shell expansion. No competing old mailbox catalog is copied.

## Binding/review prerequisites — before even a scratch mkdir

Create a separately reviewed binding from the template; do not simply flip booleans.
Review must supply actual executable/runtime hashes (including launcher versus
real executable identities), all required catalog/helper/dependency hashes and
resolved search closure, installed API/package evidence, workspace instructions,
explicit device-only project authorization, side-effect policy, and named tmux
context. Licensing environment values, if needed, are explicit reviewed additions.
The template's four mailbox catalog hashes are not a claim of complete catalog
closure. In particular, IRQ Tcl depends on installed
`embedded_ip_hwtcl_common.tcl`; other catalog components and launcher runtime
libraries must be resolved and hashed before the closure review is true.

The harness checks each supplied tool/catalog/evidence hash and requires all named
closure review fields. Closure completeness and absence of competing catalog
resolution are review obligations, not claims that Python dynamically audited the
vendor's loader. Tool/source paths containing symlinks are rejected, including
ancestor symlinks; if the real installation uses them, stop and explicitly revise
and review identity handling rather than silently resolving a different executable.

The harness rejects missing/unreviewed records, wrong paths/part/speed/readiness,
modified source or wrapper boundary, different QPF/QSF, search/argv/option changes,
missing hashes, unreviewed APIs/closure, unexpected environment keys, and missing
tmux before any claims/logs/directories. It does not accept `--bypass-quartus-project`.
Exclusive directory creation claims this one scratch; failed attempts retain the
claim and all partial files. An existing scratch can never be restaged/overwritten.
The stage claim binds canonical JSON of the entire authorization record.
Staging persists `evidence/staged.json` with every scratch file hash and directory
path, excluding only the snapshot file itself. Before the first upgrade claim,
log, before-image or subprocess, the complete scratch state must match it. Every
upgrade/child/parent report persists the same directory-aware state in
`scratch_inventory_without_report`, with exact `directories` and `files` members.
Before every stage, HOME, TMPDIR, source cwd, evidence and their ancestors must
still be directories; symlinks (including ancestors), missing or
retyped directories, extra files and even unexpected empty directories fail closed.
Unreadable directory walks fail rather than silently omitting entries. This is a
preflight check, not protection against concurrent hostile filesystem mutation.

## Stages, inspection barriers and side effects

Future operator entry points, ONLY after prerequisites and independent review:

```text
python3 migration.py stage --binding /absolute/reviewed-binding.json
python3 migration.py upgrade --binding /absolute/reviewed-binding.json
# STOP: inspect upgrade-report.json, upgrade.log, all source/project/output deltas.
python3 migration.py child --binding /absolute/reviewed-binding.json --approval /absolute/upgrade-approval.json
# STOP again: inspect child save, logs and serialized source/project/output deltas.
python3 migration.py parent --binding /absolute/reviewed-binding.json --approval /absolute/child-approval.json
# STOP: final parent report still says accepted=false; independent final review required.
```

No command above was run here. `python3 migration.py commands` only prints the
closed proposed command vectors, without files or subprocesses. There is no
source integration or HDL-generation stage in this harness.

The exact upgrade vector is documented selective `qsys-generate
--upgrade-ip-cores bmc_spi_sub.qsys --batch=./ip/bmc_spi_sub/sdm_mailbox.ip` with the
bound scratch QPF/revision, part and search path. Each refresh uses qsys-script
with the same explicit QPF/revision, proposed `--package-version=26.1`, fixed search
path and one fixed Tcl script. No synthesis/simulation/all-IP request is added.

Each stage creates its own exclusive claim, raw byte before-image (JSON hex),
namespace-aware XML/decoded embedded-XML snapshot, complete stdout/stderr log,
return code, after source inventory, complete scratch inventory, and a report
with full before/after target semantic trees. Non-target files must be byte-equal;
all other Qsys modules, connections, address maps, IRQ/reset routes, top boundaries,
proxy kinds, and logical paths must be semantically equal. Thus unrelated version
upgrades/serialization are rejected even if exit code is zero. Extra IP/Qsys/project/
component-catalog files or additions in the custom source directories are rejected.
All other newly created files are inventoried and require human log/output review.
After persisting a completed stage report, the CLI exits 1 for a nonzero vendor
return code or any semantic/log/binding error, including errors with vendor rc 0.
A successful stage awaiting independent review exits 0 but still records
`accepted: false`, `requires_independent_review: true`, and `ready_for_build: false`.
Preflight exceptions also fail the CLI; interrupted/malformed-output limits below
remain unchanged.

The mailbox's exact full saved module-parameter set (including auto device/speed
metadata) is checked; no silent added/removed hidden parameter or restored default
is allowed. Public resolution must be `altera_s10_mailbox_client` 23.0.0. Old ports
and mappings must remain; the real 1-bit waitrequest must appear in IP-XACT bus
mapping, physical output, decoded locked boundary and boundary mapping. Child
acceptance additionally checks both saved proxy boundary representations and
public originalModuleInfo version. Parent refresh must not change either external
boundary representation. Decoded interface timing and system-info changes remain
explicit independent-review items: this harness never edits metadata to force
old timing or declares every target delta safe automatically. Catalog core 21.0.0
resolution and nontermination/coherence across all representations require actual
resolution/validation evidence in that review, not just hashes and version strings.

Approval JSON must contain `reviewed: true`, a nonempty `reviewer`, the exact
SHA-256 of the prior report, and exactly these `checks` set to true:
`all_target_deltas`, `catalog_resolution`, `all_logs`,
`waitrequest_all_representations`, `no_unrelated_changes`. It belongs OUTSIDE
scratch so it does not alter the reviewed inventory. Previous rc must be zero,
errors empty, and the entire scratch inventory must still match before the next
claim, log or before-image is written. Both file hashes and exact directory sets
(including empty directories) must match. Only the prior report's own file hash
is excluded; all older reports, staged receipt and directory paths remain bound.
Old file-only receipts fail closed, even with exact-hash approval. There is no
receipt conversion, rebinding, cleanup, approval writer or automatic acceptance.

QPF/QSF writes are possible vendor side effects; byte changes are captured and
block progression. Any legitimate added QSYS/IP assignment needs separate review
and a successor context, not automatic permission. Scratch cwd, HOME and TMPDIR
are explicit; caches, logs, backups, project database/reference synchronization,
Java/tool subprocesses and incidental generated files are all within side-effect
review. License/network access, vendor user/system caches, or a vendor ignoring
HOME/TMPDIR cannot be excluded by this Python wrapper. It is **not an OS sandbox**,
and hashes/review flags are not protection against an operator changing the
harness or receipt. It grants no outside-scratch writes. Verify installed behavior
before authorization; unexpected external writes invalidate the run. On interruption
or malformed/deleted outputs, claims/logs/raw before evidence remain even if a
complete report cannot be produced; no retry/cleanup is automatic. No runtime
wall-time guarantee or process-tree sandbox is asserted.

## Installed evidence and unresolved assumptions

Read the full `ipgen-03/mailbox-refresh-procedure.md`,
`ipgen-03/bmc-mailbox-generation-review.md`, `plan.md`, and component closure report.
Also read the actual parent-supplied
`ipgen-03/installed-refresh-tool-discovery.json` locally:

- qsys-generate and qsys-script `--help`: rc **0**; relevant project/revision/
  search/package/part options present. Installed generate help describes upgrade
  as **all IP cores** in the system and batch as adding files. It does NOT prove
  selective behavior. The official 26.1 manual supplies the immediate-parent +
  single-batch selective contract, but non-target diff rejection remains mandatory.
- qsys-script `--cmd` without project: rc **1**, requires project/new-project.
- script-only discovery: rc **1**, attempted implicit project creation from a
  hyphenated basename, rejected as an invalid project name. This does not establish
  successful Tcl API discovery or package availability in the proposed project.

Still unresolved: installed minimal QPF/QSF acceptance; exact runtime/dependency
identity closure; standard catalog resolution; 26.1 Tcl package/API compatibility;
upgradeability of this old leaf; actual selective behavior; serialized boundary
schema/timing changes; project-reference edits and full write footprint. These
are execution blockers, not excuses to open the FIM or invent another flag.

After accepted save-diff review, separately authorize successor source rebinding
and standalone AND nested generation. Trace nonconstant waitrequest through the
installed core, wrapper and interconnect to `sdm_pipeline.m0_waitrequest`, retaining
readdatavalid, both upstream requesters, global reset and shared ownership. This
harness cannot qualify generation, shared-reset/FLR behavior, protocol, synthesis,
fit, timing, host stack, hardware or release readiness.

## Local verification

Executed with `PYTHONDONTWRITEBYTECODE=1` from `/home/joe`:

```text
python3 /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/test_migration.py
Ran 35 tests in 87.480s
OK (exit 0)
```

The fully intercepted three-stage test reaches synthetic upgrade/child/parent
reports, each deliberately `accepted: false`, and verifies the missing-review
barrier before child writes. Other tests cover exact 34-file/24-leaf inventory,
all retained parameter mutations, decoded snapshots, stale boundaries, lost ports,
wrong waitrequest width/name, unrelated leaf/RTL changes, address/reset/logical-path
drift, extra/bypass argv, missing/mutated bindings and hashes, non-symlink copies,
exclusive staging and preserved failed claims. Ten added regressions use the real
binding checker with mocked immutable source/tool identities: separate post-stage
HOME and TMPDIR symlinks, unexpected file/empty directory, missing/retyped
directory, scratch symlink as an ancestor of evidence, and separate CLI vendor
failure, zero-vendor semantic failure, and success-awaiting-review cases.
Preflight rejection asserts zero subprocess calls, zero new writes and unchanged
stage evidence. CLI tests intercept vendor calls and exercise `main()`/SystemExit.
Two additional tests independently cover child and parent barriers, each with
12 mutation subcases: missing HOME/TMPDIR, unexpected empty directory, both
retyped and symlinked environment directories, scratch and above-root ancestor
symlinks, old file-only receipt, a newly approved snapshot already missing HOME,
and an injected directory-walk error. Every rejection asserts zero intercepted
launches, zero `write_new` calls, no new stage evidence and byte-identical prior
evidence. The valid three-stage test reads back each report and verifies exact
snapshot equality with only that report's own file hash excluded.
`spec-review.md`, `spec-rereview.md` and `fix-report.md` are preserved unchanged;
`all-stage-fix-report.md` records the remaining directory-inventory correction.
Independent specification re-review, then quality review, remain required.
This verifies Python control/data
logic only; Tcl execution and real vendor integration remain untested.
