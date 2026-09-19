# Minimal post-setup monitored Quartus implementation

## Result and scope

Implemented the exact `run_post_setup_quartus(name, args)` body and `run-post-setup-quartus` dispatcher branch from `qualification/ipgen-02/post-setup-enforcement-proposal.md`. Rotated only the hardcoded WORK name from `work_ia840f_ipgen_02` to `work_ia840f_ipgen_03`.

The wrapper permits only the existing `project_ip`, `generate`, and `headers` grammar. Before spawning it validates the complete record, immutable claim, project cwd, permission, copied WORK script hash where applicable, and exact recorded runtime executable/hash/argv/cwd/kind. It launches the recorded outer launcher as an argv list through the unchanged output monitor. The independent actual-process callback still validates the inner tool identities.

No authorization transition, remote access, deployment, vendor execution, commit, manifest edit, or board-source edit was performed. Existing remote work/claims were not accessed or changed. Parent-provided work02 acceptance/status was context, not independently verified here. No readiness claim is made: `ready_for_build=false`, closed grammar, setup/claim semantics, and compile/all/finish prohibitions remain unchanged.

## Modified and created files

Local root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.

Modified:

1. `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_experimental_gate.py`
   - SHA-256: `005144000108164d6dd967aa50d757ce35423014cc7f00329a24391602d469e2`
2. `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/test_ia840f_experimental_gate.py`
   - SHA-256: `beb921e3f388b6649927611c45e7d601c1e1142e9a8e9b8be81b791cc50b5173`

Created: `qualification/ipgen-03/post-setup-implementation.md` (this report).

## Verification

Final full local unittest discovery, run from:

`/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -v -s . -p 'test*.py'
```

Actual result:

```text
Ran 42 tests in 14.832s
OK
exit_code=0
```

This directory contains the single local test module `test_ia840f_experimental_gate.py`; all of its tests ran. The only other `test*.py` found under the broader local root was an unrelated oneAPI GEMM `testlib.py`, not part of this gate suite. An earlier intermediate module run also passed (41 tests before the subprocess-exit regression was added).

Added 12 test methods with parameterized subcases covering:

- All three commands and the setup-only / setup+generate / setup+generate+headers permission matrix; exact outer launcher invocation with deliberately distinct inert outer/inner identities.
- Fresh complete fixtures finalized before exclusive claim creation; no claim renewal in the new positive permission/context fixtures.
- Setup/post-setup wrapper separation, executable/path rejection, SOURCE-vs-WORK scripts, every argument's removal/mutation/duplication, reordered/extra flags, alternate simulator/parallel mode, arbitrary scripts, and prohibited tool/stage forms.
- Missing/mutated/symlink claims, serialization-only record drift, permission drift/malformed/missing permissions, cwd, source/PIM inventory drift, launcher/inner bytes, PATH, readiness, and inventoried gate/test drift, all with zero monitor calls.
- Missing/wrong runtime contexts, independently mutating executable/hash/argv/cwd/kind for each command before claim creation, so context tests cannot merely fail on a stale claim.
- Missing/drifted WORK scripts; actual callback fixtures for every post-setup kind and permission set, wrong executable, argv[0], cwd, and extra arguments under the inner PATH identities.
- Setup-only permission expansion rejected against the unchanged original claim; a distinct fresh work/claim fixture succeeds while the old record/claim bytes are preserved. Any record restoration in that regression is explicitly temporary-fixture-only, not an operational transition.
- Real inert Python children through wrapper/dispatcher: clean rc0, rc7, every rejection marker on stdout/stderr with rc0, one-byte reads splitting markers, empty/binary-invalid-UTF-8/large output, exact merged byte preservation, and spawn exceptions.
- A separate Python process checks dispatcher return status through `sys.exit`, with synthetic record preflight and the real monitor, for every command. This harness injects the fixture-bound wrapper into a separately loaded dispatcher; it is not vendor integration evidence.
- A test-only checked-status three-stage sequence: failure at each position for rc7 and rc0/125091 leaves later sentinel/log files and acceptance receipt absent; successful logging does not override the failing wrapper status; clean sequences reach each stage in order. No production orchestration script was added or claimed tested.

Existing shell early-denial/no-side-effect, setup wrapper, single-run consumption, ELF-vs-launcher/argv[0], inventory, PCIe component/preset/PF/VF, and output-monitor tests remain intact and passed. Existing tests also perform their existing shell syntax checks; no shell artifact was changed.

### Byte-preservation check

Because these gate/test files are already untracked in the child repository, `git diff` alone cannot demonstrate their delta. A read-only Python reconstruction removed only the additive wrapper/dispatcher and reversed the WORK rotation; its SHA-256 matched the proposal's original gate exactly:

`53e996bddbcb7288353de3c44013eb6d27935832f1d6ed42c20d8142be4c48b2`

Removing only the new test helper/class block and reversing the added `contextmanager` import reproduced the proposal's original test SHA-256 exactly:

`8e701253cb597ba5bc8c81146c918e3ab2d823fb1d62e73140fbd12904b49878`

Thus all original function bodies, including the monitor, grammar, loader, callback, native/claim checks, and all original tests were preserved byte-for-byte. `git diff --check` returned zero in both the FIM and ofs-common repositories (it does not cover these untracked files). The workspace contains other preexisting modifications/untracked files, including a bytecode directory; none was cleaned up or edited as part of this task.

## Limitations and mandatory handoff

- Parent specification review followed by independent quality review is mandatory before deployment. Neither review is represented as completed by this implementation task.
- Manifest refresh, complete new inventories, reviewed tool hashes, archival transition evidence, new work03 authorization, and fresh native work03 setup remain the parent's separate deployment responsibilities. No permission/claim migration was performed here.
- A claim proves record consumption, not setup completion. The minimal wrapper deliberately adds no setup-completed receipt; reviewed acceptance of fresh work03 setup must precede the three monitored operations.
- Inert identity fixtures and Python children establish local fail-closed behavior only. They do not validate installed Quartus launcher behavior, project loading, Tcl integration, generation support, generated RTL, interfaces, or headers.
- The monitor is unchanged: it waits for process termination and rejects markers even at rc0; it does not immediately cancel vendor writes. Failed outputs remain failed evidence.
- Ordinary warnings such as `ofs_ip_cfg_db.tcl is not loaded in this project` still require independent header acceptance checks. A clean monitor status is not proof of fresh nonempty headers or complete RTL generation.
- No synthesis/compile/fit/assembly/finish/programming authorization, readiness transition, or generated-interface acceptance is implied.

No test failures or implementation blockers were encountered. The remaining barriers are the required reviews and separate deployment/qualification work, not local unit-test failures.
