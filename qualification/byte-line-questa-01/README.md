# Byte-line Questa execution package — PREPARED, NOT EXECUTED

Parent spec + quality acceptance and transfer remain required. No HDL compile,
elaboration, simulation, workstation contact, install or Quartus generation was
performed during preparation. Actual HDL checked cycles: **0**. `154` and
`PASS scenarios=154 checks=160007` are prospective acceptance expectations only.

## Contents and provenance

- `inputs/`: 13 byte-identical copies: all ten maintained DUT/PIM inputs from the
  preserved `original-inputs.before.json`, the real `ccip_if_pkg.sv`, and the
  unchanged `tb.sv` plus `ofs_plat_if_top_config.vh` fixture.
- `input-manifest.json`: expanded dependency manifest, original absolute source
  paths (provenance only), portable copy paths, roles, sizes and SHA-256 values.
- `provenance/`: unchanged original before/after ten-input manifests and spec review.
- `sources.f`: relative include directory and compile order: real CCI-P package,
  real log package, real Avalon interface, real adapter, unchanged bench.
- `run.py`: bounded, fail-closed execution/evidence runner.
- `test_runner.py`, `inert-tests.log`, `inert-tests-final.log`: inert Python tests;
  synthetic strings and mocked identities/stages are **not** simulator results.
- `preparation-verification.json`: local copy/source hash and dependency check.
- `package-sha256.json`: complete package inventory excluding itself. Parent must
  retain its SHA-256 separately through review/transfer; it is an integrity
  record, not an authenticated authorization token.

The preserved original bench directory/evidence and maintained sources are not
modified. The bench's original-path comment is intentionally unchanged; execution
uses hash-identical staged copies rather than local provenance paths.

## Dependency repair (no source modifications)

The umbrella header unconditionally includes the actual CCI-P import header and
clock declarations. The real package is included, not stubbed. The unchanged
fixture disables legacy compatibility and does not enable host/local/HSSI class
wrappers. Their conditional headers are therefore not active dependencies.
All active textual includes resolve among these copies, including the recursive
umbrella/clock include protected by guards.

The runner supplies only these explicit **compile-only synthetic fixture values**:

```
+define+OFS_PLAT_PARAM_HOST_CHAN_NUM_PORTS=1
+define+OFS_PLAT_PARAM_HOST_CHAN_DATA_WIDTH=512
+define+OFS_PLAT_PARAM_HOST_CHAN_MMIO_ADDR_WIDTH=18
```

They are not generated board parameters or an ABI claim. No `SYNTHESIS`, interface
assertion suppression, dummy package, edited DUT or edited bench is used.

## Prospective execution — parent/operator only after acceptance

Transfer this entire directory without caches or extra files. Keep the reviewed
package immutable. From a genuine tmux session on `Agilex7Workstation`, real and
effective UID 1000, invoke (substitute reviewed transfer/output paths):

```
python3 -B /absolute/transferred/byte-line-questa-01/run.py \
  --execute-reviewed --output /absolute/existing-parent/fresh-exclusive-run
```

The output directory must not exist; its parent must exist; it must be outside the
package. Never rerun into failed evidence. The flag is an operator attestation,
not automatic proof that review occurred. The runtime gate checks hostname, UID
and nonempty `TMUX`; it is not an anti-spoofing security boundary or OS sandbox.
No remote execution command is included or performed by preparation.

The fixed executable paths are:

```
/opt/altera/26.1.1/questa_fe/bin/vlib
/opt/altera/26.1.1/questa_fe/bin/vlog
/opt/altera/26.1.1/questa_fe/bin/vsim
```

All three licensing variables `LM_LICENSE_FILE`, `MGLS_LICENSE_FILE`, and
`SALT_LICENSE_SERVER` are set to
`/home/uwb_student00/quartus_26/LR-191011_License.dat`.
`QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus` is explicit.
The runner uses a minimal environment with isolated HOME and an explicit fresh
`MODELSIM` ini containing only the local work-library mapping, avoiding inherited
simulation/compiler options. It records the environment, tool path/resolved path
and executable hashes, license-file hash (not contents), Python version, runtime
identity, launcher argv/cwd, and each actual stage argv/cwd. Installed launcher
hashes do not attest every shared library/internal executable loaded by Questa.

Order and outer timeouts: each tool's `-version` (15 seconds each), `vlib work`
(30 seconds), `vlog -sv -timescale 1ns/1ps -work work` with the three definitions
and `-f sources.f` (180 seconds), then `vsim -c -onfinish exit -l
simulator-transcript.log work.tb -do ...` (60 seconds). Relative file-list paths
resolve in the fresh output cwd containing byte-identical `inputs/` and
`sources.f`. The simulation do-string is exactly:

```
onerror {quit -code 1}; onbreak {quit -code 1}; run -all; quit -code 1
```

The final nonzero quit is a fallback, not a successful result. Each executed stage
has its own exclusive directory with `invocation.json`, `output.log`, and
`result.json` (rc, timeout, diagnostic gate and log hash). Version output is in
the three version-stage logs. `result.json` at run root is authoritative; stages
not reached have no vendor invocation and simulation rc remains null. Positive
native failure exit codes propagate; negative/signal exits map to runner rc 2;
timeouts kill the stage process group and return 124. No compilation after a
failed prerequisite, and **no simulation after failed compilation**, even if a
compiler emits diagnostics but incorrectly returns zero.

Acceptance requires all stages successful, zero simulation rc, exactly ordered
actual console `CHECKED 1` through `CHECKED 154` entries, exactly one full expected
PASS line, no error/fatal/failure diagnostics (zero-error summaries alone are
allowed), an existing clean native simulator transcript, and unchanged package,
staged source/configuration and tool hashes. Console `# ` prefixes are normalized;
command echoes/substrings cannot stand in for checked lines. Before/after JSON
records preserve source, configuration, package and tool comparisons.

## Limits and remaining acceptance

- Installed option/version compatibility, minimal-ini behavior, actual licensing,
  real HDL compilation/elaboration and `$finish` exit semantics are unverified.
  Any incompatibility must fail closed and be reviewed in a fresh attempt; do not
  bypass or weaken gates to turn a failed run into a pass.
- **Reset case is reset/stall overlap only.** The unchanged case named `reset mid
  stalled write` does not interrupt an already-held stalled write. It establishes
  neither stateful reset recovery nor that stronger temporal transition.
- The offset sweep alternates stall polarity; it does not cover both polarities
  for each request/offset pair. The storage/response fixture is synthetic, not a
  downstream burst memory implementation.
- Even a future PASS qualifies only this normalized combinational adapter unit
  fixture, not BSP generation, full AFU, board ABI, CDC, timing, hardware or
  integration. No Quartus generation is needed for this package.
- Inert tests exercise parser rejection, runtime identity checks, Python child
  return code/timeout handling, exclusive evidence, hash rejection, and a mocked
  compile-failure barrier. They do not establish vendor-tool correctness.
