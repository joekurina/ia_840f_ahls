# Work03 memory generated evidence — preparation only

**Not executed remotely. No collection authorization. All readiness remains false.**
Only this new directory is owned. No worktree/source, shared manifest, gate, BMC,
header or IP is changed. No vendor tool or project script is run/imported.

## Files and exact scope

- `scope.json`: closed, hash-pinned, literal absolute-path scope. Contains 51 exact
  file probes, two finite discovery roots, exact permitted synthesis module stems,
  suffixes, caps, expected source/input hashes and hashes of review evidence.
- `collect-memory.py`: Python 3.9-compatible stdlib-only collector; no subprocess,
  network, vendor tools, executable manifest evaluation or project-script imports.
- `test-fixtures.py`, `fixture-test-output.txt`: local synthetic filesystem tests
  and retained actual output. They do not invoke production `main`.

Remote base is exactly `/home/uwb_student00/ahls/new_BSP` (capital BSP).
Work root is exactly `work_ia840f_ipgen_03` beneath it. Production output is one
exclusive `qualification/memory-generated-evidence-01/memory-artifacts.json` beneath
that remote base. Parent may later retrieve that receipt to this local directory;
this task neither stages nor retrieves anything.

The two discovery roots, relative to Work03, are ONLY:

1. `ipss/mem/qip/mem_ss`
2. `ofs-common/src/fpga_family/agilex/mem_ss/qip/axilite_ic`

No whole-worktree or installation scan. Saved `mem_ss.ip`, CSR Qsys and its five
leaf IP inputs, and the two saved simulation-model IPs are exact probes derived
from the enumerated inventory. Simulation models are saved-input evidence only;
no simulation HDL is traversed. The known nested synthesis subsystem stem is
`mem_ss_mem_ss_501_qm5zaka`. Its exact subsystem, EMIF0/1, MSA0/1, calibration,
clock/reset bridge and reset-controller top stems are taken from the final
captured synthesis-report filenames. `emif_csr_ic` is also selected.

Discovery selects `.ip`, `.qsys`, `.sopcinfo`, `.qip`, `.sip`, `.f` metadata and
manifests, plus `.v`/`.sv` whose stem exactly matches the closed module-stem list
and whose path has a `synth` component. It prunes `sim`, `simulation`, `submodules`
and `.git`. It never follows file-list references. Names and serialized parameter
values are preserved, not normalized or interpreted. Inner megafunction HDL is
intentionally not selected. If a needed wrapper uses a different filename, the
receipt is not proof it does not exist; review captured manifests and authorize
another finite exact-path batch instead of widening this script during execution.

Exact probes also capture Work03 board `top.sv`, memory pin locations, memory
RTL/package/interfaces, source INI/preset/config and header/group producer Tcl.
The source bindings from the final proposal are comparison baselines, not claims
that remote copies still match. Source mismatch is explicitly partial.
External PIM template sources are exact files only, not a third discovery root.

`remote-setup-full.log:541-551,559-569,583-584` establishes that setup generated
local-memory native-AXI PIM templates and then copied the build to `afu/build`.
Scope probes both generated template and copied active-build candidates for the
config, FIU interface, USER package/gasket, top config and QSF manifest. Copied
path existence and active selection are not assumed. Missing paths are recorded.

OFS outputs are probed at the producer-derived `sv_wrapper/` and syn-top
`ofs_ip_cfg_db/` paths, including `ip_gen_sv_wrapper_inc.tcl`. These headers were
NOT RUN after overall mailbox generation failure. Missing probes are expected,
not permission to generate or fabricate replacements. The final saved input hash
`883ff7f07d572a91e8fa67ccff2f971dd50823779eb33edeeae3fe6e960f5952`
is required as the comparison baseline for `mem_ss.ip`.

## Hard bounds and receipt semantics

- 16,000 discovery entries; 768 directories; depth 12 below each discovery root.
- 256 selected file attempts overall; exact probes precede discovered top HDL,
  which precedes other discovered metadata.
- 4,194,304 bytes per file; 33,554,432 aggregate raw bytes read for artifact capture.
- UTF-8 full text only (original CRLF retained), original absolute path, SHA-256,
  byte count and before/after file-stat stability check. No truncated payloads
  masquerade as full captures. Non-UTF-8 or NUL-containing files are rejected.
- Missing files, discovery/read/depth/count/byte limits, mismatched hashes and
  symlink rejection are explicit issues. Any issue sets `status: partial` and
  exit 2. Successful bounded capture is named `bounded_scope_captured_not_qualified`,
  never complete generation. `complete_generated_tree` is always false.
- All path components are opened with directory FDs and `O_NOFOLLOW`; ALL symlinks
  are refused, including harmless in-root links. A link is reported as rejected,
  without resolving/reading its target; escape is therefore impossible through
  traversal, but the receipt does not classify link destination. Nonregular files
  are refused, using nonblocking open to avoid a FIFO hang.
- Receipt is created with `O_EXCL` and mode 0600, fsynced and read back for equality
  and hash. Existing receipt is a hard refusal. Interrupt/disk-write failure can
  leave an empty or invalid exclusive receipt: retain as failed evidence, never
  call it complete or silently overwrite it. No automatic retries or cleanup.
- Source reads can update filesystem atime; no source content is written. This is
  not an OS sandbox against hostile same-user mutation. File-stat checks are not
  an atomic cross-file snapshot, and bytes present now do not by themselves prove
  they were generated by the failed run. Compare inventory, receipts and metadata.

## Parent review and future operator usage (NOT executed here)

Before approving any future read-only collection, inspect script, scope and tests;
verify staging scope separately. Only stage the reviewed collector and scope into
the new remote qualification directory. It must already exist, have no symlink
ancestors and contain no `memory-artifacts.json`. Do not create or change Work03.

Verify endpoint **`uwb_student00@100.101.227.97`**, host **`Agilex7Workstation`**,
real/effective user **`uwb_student00`**, and actual named tmux session
**`ia840f_goal_preflight`** immediately before collection. Historical receipt host
observations and `ipgen-03/execution-status.md:12` establish expected identities,
not current verification. Read current workstation instructions before collection.

The no-subprocess collector cannot query tmux's session name. Its CLI arguments
are explicit OPERATOR ATTESTATIONS: require a live external read-only tmux query,
not a guessed string or just a nonempty TMUX variable. It compares the supplied
pane/TMUX value with its environment and independently checks host/user. It
records that it has NOT independently verified the actual tmux session name.
No argument authorizes remote connection, session creation or vendor execution.

Illustrative commands **inside the separately authorized existing remote pane**:

```bash
hostname
id -un
tmux display-message -p -t "$TMUX_PANE" '#S #{pane_id}'
# STOP unless actual host/user/session match the exact values above.
# Also independently verify the SSH endpoint identity; hostname alone is insufficient.
cd /home/uwb_student00/ahls/new_BSP/qualification/memory-generated-evidence-01
python3 -B collect-memory.py \
  --operator-verified-endpoint uwb_student00@100.101.227.97 \
  --verified-tmux-session ia840f_goal_preflight \
  --verified-tmux-pane "$TMUX_PANE" \
  --verified-tmux-value "$TMUX"
```

The shown tmux command is an operator prerequisite, NOT a collector subprocess.
There is intentionally no SSH invocation, tmux creation, Quartus/Qsys command,
header run, regeneration, speculative fix or commit in this package.

## Evidence limits and unresolved acceptance

Final-generation evidence contained 109 records but no HDL/saved IP/SOPC payloads;
synthesis report success did not establish port shapes. This collector supplies
static evidence for physical group/index and scalar CS targets, USER widths,
CSR exports and calibration/reset/clock wiring review. It does not run Qsys APIs,
prove actual API list values, generate missing OFS outputs, establish MSA semantic
contracts absent from selected files, or qualify placement, timing, SPD, reset
protocol or hardware. Raw synthesis bundle equality still cannot replace actual
OFS-generated wrapper grouping. Preserve reversed donor calibration associations
and every physical pin until separately reviewed evidence supports a change.

Tests run only with temporary synthetic trees beneath this owned directory and
remove only those fixtures. Python 3.9 grammar is checked with AST parsing; this
is not a claim of running on the workstation's Python 3.9 interpreter. The
production host/tmux gate and remote path layout remain unexercised here.
