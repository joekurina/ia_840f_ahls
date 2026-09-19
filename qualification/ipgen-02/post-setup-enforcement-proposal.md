# Post-setup failure propagation: minimal proposal (not implemented)

## Decision and execution boundary

Add one closed post-setup wrapper to `ofs-common/tools/ofss_config/ia840f_experimental_gate.py`, one CLI branch, and inert tests in its existing test module. Reuse `monitor_setup_output` unchanged. Do not extend `native()` to compile/all/finish, modify the vendor Tcl error mechanism, add an arbitrary command runner, or route through `build_fim_compile.sh`.

**The source-bound change requires a fresh native setup in `work_ia840f_ipgen_03`. It cannot safely be retrofitted onto the consumed work02 authorization while preserving its existing record/claim binding.** Work02 must finish and be independently accepted or rejected first. No implementation, source/manifest/test edits, remote access, vendor execution, authorization issuance, or commits were performed for this proposal. The running setup status is task context, not a remotely verified result here. `ready_for_build` remains false.

Paths below use `C=/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach` and `W=/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03` for the **future** run. Current reviewed source still hardcodes work02. Local inspection root is `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach`. This document is outside its source inventory.

## What the present code establishes

References are to the inspected local source, not a claim of remote runtime acceptance:

- Gate lines 49–109: full inventories of `syn`, `src`, `ipss`, `ofs-common`, `tools`, pinned PIM inventory, mandatory outer and inner tool maps; only the authorization record and bytecode are excluded as specified in `inventory()`. The gate **and its tests** reside inside the bound `ofs-common` tree. A test-only edit also invalidates the old inventory.
- Lines 112–140: exact grammar already classifies `project_ip`, `generate`, and `headers`; no new grammar is required.
- Lines 150–158, 193–205: the exclusive setup claim contains the SHA-256 of the complete authorization-file bytes. `check_claim()` compares those bytes to the hash of the current fixed SOURCE record. It is not a hash of only the sources or an immutable subset of fields.
- Lines 160–176: the actual callback validates `/proc` parent ELF path, basename `argv[0]`, complete argv, cwd, executable hash, recorded context, permissions, and WORK/SOURCE script equality for `project_ip` and `headers`.
- Lines 226–261: `monitor_setup_output` merges stdout/stderr, streams bytes with boundary overlap, waits for the child, and rejects either nonzero exit or any rejection marker even with rc=0. Only setup's `ip_lib`, `pim_macros`, and `prepare` currently have a public monitored wrapper.
- Lines 264–276: CLI errors become exit status 1. The new branch can use the same exception handler.
- `syn/board/ia840f/setup/build_gate.tcl` emits `IA840F_GATE_REJECTED` before a Tcl error. QSF loading can demote the error to Critical Warning (125091). Do not equate a child exit of zero with acceptance.
- `emit_project_ip.tcl:45–80` opens the project and writes assignment data. `gen_ofs_ip_cfg_db.tcl:45–54` opens the project and invokes header emission; it only warns if the generator procedure is missing. Monitor success alone therefore does not prove header generation or complete RTL.
- `build_fim_compile.sh:37–40,102–112` rejects IA840F before its ordinary `quartus_sh --flow compile`. Do not weaken this boundary to reach generation.
- The embedded issuer in `qualification/goal-initial-preflight/deploy-runtime02.py` explicitly uses `permissions=['setup']`, even though its context table lists the future post-setup commands. A context entry is necessary, not sufficient permission. The older standalone issuer is not a valid template to run unchanged (it lacks the newer inner tool map).

## Exact minimal additive wrapper

Proposed name: `run_post_setup_quartus(name, args)`; CLI selector: `run-post-setup-quartus`. Keep `run_setup_quartus`, `quartus_context`, the claim format, `command_kind`, and the monitor's streaming implementation unchanged. Do not rename the monitor just to remove “setup” from its diagnostic: the wording is cosmetic and should not expand this patch.

The following is proposed implementation text, **not installed code**:

```python
def run_post_setup_quartus(name, args):
    kind = command_kind(name, args)
    require(kind in ('project_ip', 'generate', 'headers'),
            'not a post-setup Quartus command')
    record = load_record()
    check_claim()
    require(str(Path.cwd().resolve()) == str(PROJECT),
            'Quartus output directory')
    permission = 'headers' if kind == 'headers' else 'generate'
    require(permission in record['permissions'],
            permission + ' not authorized')
    if kind in ('project_ip', 'headers'):
        relative = Path(args[1]).relative_to(WORK)
        require(sha(WORK / relative) == sha(SOURCE / relative),
                'work script source hash mismatch')
    executable = RUNTIME_EXES[name]
    require(any(c == {'executable': executable,
                      'sha256': sha(executable),
                      'argv': [name] + args,
                      'cwd': str(PROJECT), 'kind': kind}
                for c in record['quartus_contexts']),
            'unrecorded runtime executable/argv')
    monitor_setup_output([record['tools'][name]['path']] + args)
```

Add only this dispatcher branch alongside the setup wrapper branch:

```python
elif len(sys.argv) >= 4 and sys.argv[1] == 'run-post-setup-quartus':
    run_post_setup_quartus(sys.argv[2], sys.argv[3:])
```

Rationale for the small amount of duplicated preflight: the wrapper must reject missing permission, missing context, and copied-script drift **before spawning**. Calling `quartus_context()` from Python here would inspect the wrong parent (the operator's shell, not Quartus). Preflight constructs the expected context; the existing in-Quartus callback remains the independent check of the actual process. Neither stage labels nor a preflight assertion replace that callback.

`load_record()` must still validate outer PATH before the launcher is started. The callback must still use `load_record(quartus_inner=True)` under Quartus's altered PATH. Launch the recorded outer path as an argv list, not `RUNTIME_EXES[name]` directly, not PATH lookup alone, and never `shell=True`. `RUNTIME_EXES` retains the exact `/opt/altera/26.1.1/quartus/linux64/{quartus_sh,quartus_ipgenerate}` paths. Hashes must be revalidated against reviewed evidence, not guessed or copied from a differently installed tool.

Do not call `native('setup-entry', ...)` or `setup_environment()` here: the worktree already exists, and setup-only options are not a post-setup authorization mechanism. The fixed cwd, approved record, permission, claim, hashes and runtime callback provide this narrow wrapper's checks. Reconstruct any environment needed by the existing project from the accepted setup evidence; do not source an unreviewed compile/bootstrap flow to obtain it.

## Only permitted post-setup calls

All run from exactly `W/syn/board/ia840f/syn_top`, after independent setup acceptance and explicit authorization. The wrapper takes the following literal names and argv in the listed order; this table defines no new flags:

1. `quartus_ipgenerate -t W/ofs-common/scripts/common/syn/emit_project_ip.tcl --project=ofs_top --revision=ofs_top --output=project_ip_for_generation.tcl` — kind `project_ip`, needs `generate`.
2. `quartus_ipgenerate ofs_top -c ofs_top --generate_project_ip_files --synthesis=verilog --simulation=verilog --simulator=modelsim --parallel=off` — kind `generate`, needs `generate`.
3. `quartus_sh -t W/ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl --project=ofs_top --revision=ofs_top` — kind `headers`, needs `headers`.

Invoke each through `python3 C/ofs-common/tools/ofss_config/ia840f_experimental_gate.py run-post-setup-quartus ...`, with explicit `|| exit 1` (or checked subprocess status). Preserve a distinct merged log and actual wrapper status for each. If using `tee`, use `pipefail` and record the wrapper's `PIPESTATUS[0]` immediately; a successful logger is not a successful vendor command. No subsequent invocation or success receipt on failure. Do not execute the generated assignment file as a newly authorized arbitrary Tcl command.

`--synthesis=verilog` requests IP RTL output here; it does **not** authorize `quartus_syn`, a synthesis stage, `--flow compile`, fit, assembly, finish, programming, or additional simulation tool execution. No modifications to the normal compile or simulation helper scripts are needed for this explicit qualification sequence.

The monitor is a process-boundary acceptance guard, not immediate vendor cancellation. Quartus may continue writing files after a downgraded error until it exits. Keep those outputs as failed evidence, do not treat them as accepted, and stop before the next invocation. Broad rejection of Critical Warning (125091) is intentional; do not narrow it to only the current marker or ignore it as noise.

## Authorization and claim transition: no in-place extension

A same-run permissions edit is incompatible with the present immutable receipt semantics:

1. Changing `permissions` (or even JSON whitespace) changes the record hash.
2. The existing claim still contains the old hash, so `check_claim()` fails.
3. Rehashing the source inventories does not fix the claim, and replacing the claim with a new hash destroys the original receipt's meaning. Existing tests that renew a claim expressly label that as **fixture-only**, not an operational migration procedure.
4. Adding the wrapper or tests changes the source inventory independently. Updating only the authorization file or only the copied WORK gate is not a valid deployment.

**Minimal solution without redesign:** preserve work02 and issue a separately reviewed work03 authorization for a fresh native setup. Do not delete, reset, renew, overwrite, or reuse either old claim. Do not use `-k` or copy work02 into work03 as a substitute for setup.

Future sequence, requiring separate approval and not performed here:

1. Wait for work02 to terminate; verify no dependent vendor process remains. Capture full logs, actual native exit status, source/manifest/gate/test hashes, source inventories, exact authorization bytes, claim bytes, recorded contexts, both tool maps, generated setup artifact inventory and accepted/rejected decision. Preserve the work02 tree and original claim at their paths. Archive the exact work02 record with a verified hash equal to its claim (if not equal, stop and investigate rather than repair).
2. Only after work02 setup has been accepted, explicitly review expansion to generation/headers. If rejected, do not call it accepted or automatically expand permissions; repair/review setup separately.
3. Implement the small wrapper and tests, rotate the hardcoded WORK constant to work03, refresh the manifest entries affected by the source change without changing readiness, run inert tests and independent review, and establish the new complete inventories. Do not edit source while work02 is running.
4. Archive the prior fixed-path authorization before replacing it, with an append-only transition receipt recording predecessor record hash, predecessor claim bytes/hash, predecessor evidence locations, source deltas, new work path, new record hash, reviewer decision and scope. This is provenance, not a new bypass accepted by the gate. The previous claim continues to bind its **archived** exact record; it is not made valid against the new active record. The unchanged old WORK gate will consequently not accept the new SOURCE record, which is desirable retirement, not a reason to rewrite the old claim.
5. After that explicit review, issue work03's initial record with `permissions=['setup','generate','headers']`, both mandatory tool maps, unchanged readiness false, complete updated inventories, and the exact setup and post-setup contexts with work03 cwd/paths. This is a **new** authorization, not an edit to a consumed authorization. Verify work03 and its claim are both absent. Native `setup-entry` exclusively creates a new work03 claim against this final record. Keep the record byte-identical thereafter.
6. Perform and independently accept the fresh native work03 setup, then and only then run the three monitored operations. Permission issuance after work02 acceptance does not eliminate work03 setup acceptance. The current gate does not encode a setup-completed receipt: the sequencing checkpoint remains an explicit reviewed operational hold, not a feature to claim the minimal patch implements.

If policy requires withholding work03's `generate`/`headers` permissions until **work03 itself** is accepted, this minimal immutable-record design cannot provide that transition. Stop and seek approval for a separately specified immutable setup record plus hash-linked supplemental authorization mechanism. That would require extra schema/loader/claim semantics and tests, not a hidden claim rewrite or part of this minimal wrapper patch. Repeating setup with a setup-only record and then editing it merely repeats the same dead end.

## Required tests for a future implementation

Use existing `RecordTests` fixtures, mocked identities/context evidence, and inert Python children. Never execute files masquerading as fixture Quartus tools. No proposed test below has been implemented or represented as passing in this task.

1. **Positive wrapper matrix:** each of the three exact commands; valid actual fixture record/inventories/tool maps/claim/cwd, matching WORK script where relevant, and an exact runtime context. Patch only the monitor at spawn boundary; assert exactly one call with the recorded outer launcher plus unchanged argv. Issue each fixture's complete final record before creating its claim.
2. **Permission boundary before spawn:** setup-only rejects all three; setup+generate admits only project-IP/generation and rejects headers; setup+generate+headers admits all. Use separately finalized fixtures, not operational claim renewal. Missing/malformed permissions already fail `load_record()`.
3. **Closed grammar before spawn:** reject setup commands through the new wrapper and post-setup commands through the setup wrapper. Reject arbitrary executable/path, scripts, SOURCE instead of WORK post-setup scripts, wrong project/revision/output, missing/extra/duplicate/reordered flags, mode sync, parallel on, alternate simulator, compile/syn/fit/asm/finish/programming forms. Reuse existing grammar tests and fill the project-IP matrix gaps. Monitor must not be called.
4. **Binding failures before spawn:** independently mutate/remove claim; change record after claim; wrong cwd; drift source inventory, PIM, launcher/inner tool bytes or PATH; readiness true; missing/wrong context executable/hash/argv/cwd/kind; missing/drifted copied script. Assert zero monitor calls. Extend actual-callback fixtures across all three kinds so the preflight does not replace `/proc` checks.
5. **Immutable claim regression:** retain existing `test_single_run_consumption`; explicitly show setup-only to expanded permissions fails with the original claim unchanged. A positive new-run fixture uses a distinct work/claim, with old record/claim preserved. Confirm changing inventoried gate/test content fails old authorization. Include byte-only record serialization drift.
6. **Output propagation at wrapper/CLI boundary:** all three kinds, clean rc0 succeeds; rc7 fails; each existing rejection marker on stdout and stderr with rc0 fails; marker split across reads fails; invalid UTF-8, empty output, and output larger than one chunk stream without corruption. Keep existing `OutputPropagationTests`; add post-setup CLI dispatch coverage and mock spawn exceptions. Assert stdout is byte-preserved even when the monitor raises and CLI status is nonzero.
7. **Stop-before-next-stage harness:** use inert Python programs through the proposed reviewed sequence, not native initialization or vendor executables. For rejection at each position, assert that later-stage sentinel files and acceptance receipt are absent; clean run reaches all sentinels in order. Test nonzero child and rc0/125091 at every position; verify logging cannot mask wrapper status. If a reusable orchestration script is later added, test its actual blocks, not a copied imitation.
8. **No regressions:** existing setup wrapper tests, native early-denial/no-side-effect shell tests, actual ELF versus launcher/argv[0] tests, work-script equality tests, original PCIe component/preset/PF/VF checks, and denial of compile/all/finish remain intact. Run the full existing unittest module with bytecode disabled; shell syntax-check only any shell artifact actually changed.

## Acceptance beyond process success

A zero wrapper status is necessary, not sufficient. Preserve per-command logs/status and inventories, and compare accepted project-IP enumeration to required sources. Check generated child-IP artifacts, top-level interface names/widths/protocols, PCIe PF/VF/capability behavior, memory controller/model/port mapping, and BMC/FLR qualification evidence according to the board's outstanding requirements. In particular, treat `ofs_ip_cfg_db.tcl is not loaded in this project` as failure of header acceptance despite its being an ordinary warning not covered by the current monitor. Check expected nonempty, fresh header artifacts rather than assuming their existence from rc0.

Do not mark full RTL generation, generated-interface validation, or build readiness complete based only on a saved component, setup success, enumeration success, or clean monitor output. Failed/partial outputs are evidence to retain, not reusable accepted products. The source manifest's unresolved board/toolchain/integration requirements and `ready_for_build=false` remain in force.

## Verification performed for this proposal

Read-only source inspection plus a temporary-directory, non-vendor `check_claim()` probe against the actual imported gate (Python bytecode disabled):

```text
gate_sha256=53e996bddbcb7288353de3c44013eb6d27935832f1d6ed42c20d8142be4c48b2
test_sha256=8e701253cb597ba5bc8c81146c918e3ab2d823fb1d62e73140fbd12904b49878
unchanged_record_claim=PASS
permission_extension=IA840F EXPERIMENTAL GATE: missing/mismatched single-run claim
claim_bytes_preserved=PASS
```

The temporary probe exercised only claim hashing against synthetic record bytes; it did not pretend to validate a complete authorization, run the proposed wrapper, or open a project. No remote status was polled and no vendor code executed. The only persistent deliverable written by this task is this proposal.
