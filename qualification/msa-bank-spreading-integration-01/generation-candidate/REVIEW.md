# Fresh memory-generation successor — execution review required

**Not authorized or launched. No full compile.** The three-file correction is already integrated and verified; this package is a separate, unconsumed generation proposal. No `consumed-review.json`, run claim or WORK directory is supplied. All execution, timing, constraint and functional readiness remains false. Work11 completed with failed timing; its records and source settings remain preserved.

## Minimal supported path

1. In an exclusively created empty `work_ia840f_msa_generation_01`, run the same native memory preset deployment sequence recorded in ipgen-04's `setup-full.log` and implemented in SOURCE `ofs-common/tools/ofss_config/ofs_ip.py:set_qsys_script_args`: set part/family/board, add `mem_ss`, load, apply the reviewed board preset, save. This is not the isolated candidate publisher.
2. Preserve first-save bytes, reload the named component using the supported component API, save again, and compare against the actual Work11 complete saved subsystem. Both saves must be identical. No generated Work04/11 memory is copied into WORK.
3. Generate **only the new mem_ss.ip synthesis hierarchy** with documented positional `.ip`, `--synthesis=VERILOG`, explicit part and search path, parallel off. Do not run a full FIM setup, project enumeration, compile, simulation, upgrade, or example design. No QPF is created or supplied; `qsys-script --qpf=none` is the observed native deployment form, and qsys-generate's project argument is documented optional. The new standalone generation invocation has not yet been exercised and requires this review. It does not assume that opening the existing FIM project is safe.

Installed help captures are in `evidence/`; the installed launchers and inner scripts were freshly hashed. Full original helper and native setup log are captured in the parent `deployment-callchain.json`. The new Tcl adds only an early execution-review/runner-ancestry check and supported reload/save to the observed native memory sequence. These checks are normal-account accidental-execution protection, not an OS sandbox against an operator modifying the scripts.

## Exact bindings and execution

`execution-binding.json` contains the complete argv, cwd, environment, SOURCE/PIM inventory, tools and dependency hashes. The script enforces those bytes via the independent package manifest before any claim, log, scratch creation or vendor invocation. SOURCE gates and all consumed claims are unchanged. The old source-bound authorizations cannot authorize the changed SOURCE and must not be reused.

After independent specification and quality acceptance, the parent reviewer must create **only** `consumed-review.json` with approved/spec_accepted/quality_accepted true, the exact reviewed `package-manifest.json` SHA256, and execution_ready false. `consumed-review.template.json` is deliberately unapproved. It is not an issuer or permission to execute. Do not edit the bound package to bypass a rejection.

Commands inside a fresh window of owned tmux session `ia840f_mailbox_monitored_01` on `uwb_student00@100.101.227.97`:

```sh
cd /home/uwb_student00/ahls/new_BSP/qualification/msa-bank-spreading-integration-01/generation-candidate
env -u PYTHONOPTIMIZE PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -B run_generation.py --preflight
env -u PYTHONOPTIMIZE PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 -B run_generation.py
```

Only the runner should launch the following bound stages; these are shown for review, not bypass commands:

```text
cwd=/home/uwb_student00/ahls/new_BSP/work_ia840f_msa_generation_01
/opt/altera/26.1.1/quartus/sopc_builder/bin/qsys-script
  --qpf=none
  --search-path=/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ipss/**/*,$
  --script=/home/uwb_student00/ahls/new_BSP/qualification/msa-bank-spreading-integration-01/generation-candidate/save_reload.tcl

/opt/altera/26.1.1/quartus/sopc_builder/bin/qsys-generate
  /home/uwb_student00/ahls/new_BSP/work_ia840f_msa_generation_01/mem_ss.ip
  --synthesis=VERILOG
  --part=AGFB027R25A2E2V
  --search-path=/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ipss/**/*,$
  --parallel=off
```

The runner sets native 26.1.1 ROOTDIR/PATH and license variables itself; it removes PYTHONOPTIMIZE and disables bytecode. The stage limits are 900/1800 seconds. Logs, native return codes, invocation environment, runner PID/start ticks and exclusive claim are retained; timeout terminates only the runner-created stage process group. A failed attempt is never reused.

## Comparison and preservation

`compare_memory.py` is an implemented checker, not a checklist. The captured Work11 baseline contains 3,016 module/nested parameters and 31,812 complete XML atoms. The saved comparison covers every parameter, including derived/hidden values, and every serialized attribute/text node: external/locked interface definitions, port widths/directions, clock/reset associations, connections, and boundaries. Only two scoped FIFO values may change from 8 to 0; copies must remain 1. Missing/duplicate keys, extra XML drift or an altered reload rejects before generation. XML inter-element indentation is not treated as a design value; raw complete diffs are retained too.

After generation, the checker covers the complete captured synthesis SOPCINFO hierarchy and top/MSA wrappers, inventories the entire fresh output, checks both MSA zero/copies1/full parameter-and-connection maps and ports, and retains complete XML atom and HDL line differences. It reports the exact old/new generated-directory token mapping used solely to pair files; it does not remove those identifiers from the content comparison. Paths, UUIDs, timestamps, derived changes and connection changes remain visible. Any missing counterpart or failed MSA check rejects. All remaining generated drift requires independent review; native exit zero never sets generated acceptance, timing or functional readiness true.

SOURCE inventories preserve Work11's authoritative QSF `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`, hold ON, seed2, maximum placement effort, pins/SDC, core470 and seven-PLL-output contract, both 16-GiB x64 no-ECC interfaces, BOT/BOT, application0→memory0 and1→1, calibration wiring and PCIe settings. The memory-only generator does not apply or certify whole-board timing constraints; those files remain unchanged and bound for later full integration. Calibration-association acceptance remains a separate unresolved issue. No promise of original donor implementation equivalence, unchanged traffic ordering/latency, timing improvement, or hardware function follows.

## Review-sensitive limits

- This standalone generation context is source/help-grounded but not natively accepted yet. Review its exact argv and the additional reload step before launch.
- The saved checker is intentionally strict. Generation-only IDs or other saved metadata may require an itemized follow-up after the first native save; do not relax the check merely to reach generation.
- The source manifest is historical and preserved. It already had four Work11-era stale entries before this integration; exact full Work11 source parity was proven. The parent integration receipt/source-after inventory now supersede only the three changed correction identities. Do not reinterpret the old manifest or consumed authorization as current execution authority.
- Query04 prohibition remains: no retry, equivalent invocation, or project interrogation. No DDR simulation, hardware operation, installation, permissions change, commit or push.
