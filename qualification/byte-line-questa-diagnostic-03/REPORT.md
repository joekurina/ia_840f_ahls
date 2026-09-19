# Questa vlog-12110 diagnosis — version probes only

## Finding and smallest correction

The runner's explicitly selected 22-byte `modelsim.ini` omits `[vsim] VoptFlow = 1`. On the installed Questa Altera FPGA Edition 2025.3, that omission produces the deprecated no-optimization path even for `vlog -version`. There is no `-novopt` argument in the recorded invocation. The inspected launcher passes its argument vector through (`exec "$arg0" "$@"`); it does not append `-novopt`.

The installed `/opt/altera/26.1.1/questa_fe/modelsim.ini` explicitly documents and sets this option at lines 1035–1039:

```ini
[vsim]
; vopt flow
; Set to turn on automatic optimization of a design.
; Default is on
VoptFlow = 1
```

Despite that documented default, the bounded probes show this installation needs the explicit setting when a standalone minimal ini is selected. Do not generalize this observation to all Questa releases.

Keep the isolated ini, minimal environment, local work mapping, and existing error gates. Add only:

```ini
[vsim]
VoptFlow = 1
```

`modelsim.candidate.ini` contains the exact tested bytes. `run.py.candidate.patch` changes only the ini-writing line in a prospective fresh runner. It is **not applied** to package02 or any maintained source. Copying the entire vendor ini, inheriting ambient configuration, suppressing error 12110, accepting a nonzero version result, and adding debug flags are unnecessary for this correction.

## Actual bounded results

All operations on the remote host were performed in windows of `ia840f_mailbox_monitored_01`. Fresh scratch: `/tmp/byte-line-questa-diagnostic-03-sahkldbq`. Each process had a 15-second timeout; all completed without timeout. The probes preserve the runner's minimal environment design, including isolated HOME/TMPDIR and the same license paths.

| Configuration | Command | rc |
|---|---|---:|
| Original minimal Library-only ini | vlog -version | 1 |
| Minimal ini plus empty [vsim] section | vlog -version | 1 |
| Minimal ini plus [vsim] VoptFlow = 1 | vlog -version | 0 |
| Same corrected ini | vsim -version | 0 |
| Minimal ini plus [vsim] VoptFlow = 0 | vlog -version | 1 |
| Explicit installed modelsim.ini | vlog -version | 0 |
| No MODELSIM and no cwd ini | vlog -version | 0 |

The minimal failing log is byte-for-byte identical to run02, SHA256 `e527b1484dd96c3d546dce6ef651f50487b7fc767e72629179a554b14cfb3bda`. All passing vlog logs contain only the version banner, SHA256 `fe880d850b719fedfbcbffb6a6dd24bd637ba872bd6ddf51b0fe11e6014414a3`. Corrected ini SHA256: `f2ed7c069d77dfbbb5339733f6fd4a058dcf51dbe849357c6fe6aeda2d953756`.

This isolates the missing configuration rather than blaming the license, HDL, PATH, or launcher. Installed-default and no-explicit-ini probes also explain why earlier ordinary-environment version checks could pass.

## Evidence and checks

- `inspect.result.json`: installed ini excerpts with source line numbers; launcher content; installation inventory and hashes.
- `probes.result.json`: exact argv, cwd, environment, outputs, return codes, durations, ini bytes/hashes, protected-file inventory, tool hashes, and remote scratch artifact hashes.
- `*.launch.json`: exact SSH/tmux launch commands and pane identifiers.
- `inspect.py`, `probes.py`, `remote_probe.py`: reproducible diagnostic procedure, no HDL tool stages beyond version queries.
- `verify.py`, `verification.json`: exact one-line patch validation, candidate AST parsing without executing runner, byte-for-byte failure comparison, output-hash checks, and candidate-ini match to remote success.
- All 108 files in remote run01, run02, package01, and package02 were unchanged by before/after SHA256 inventories. Launcher, installed ini files, and actual linux_x86_64 vlog/vsim binaries were also unchanged.
- Local package02 runner SHA256 matches the remote package02 runner. Original local package02 and transfer evidence were only read.

## Limits and handoff

No vlib creation, HDL compilation, optimization of a design, license checkout test, simulator HDL run, calibration, traffic test, reset/error test, programming, source modification, or commit was performed. Version success is **not** evidence that licensing or the bounded HDL simulation passes.

For a subsequent reviewed candidate package, apply only the supplied line change to a fresh copy, regenerate that copy's package manifest, and retain existing timeout/diagnostic/scenario gates. Run in a fresh output directory only after parent acceptance; do not alter old packages or run evidence. Any later compile or elaboration failure is a separate diagnostic, not grounds to suppress this one.

Collection issue: the first two read-only inspection captures failed locally because tmux pads captured lines with spaces; the framing parser was corrected and the inspection repeated successfully. No diagnostic version process was duplicated by that issue. Diagnostic windows are left idle for inspection, not running simulator jobs.

Reusable lesson: a self-contained simulator ini must explicitly preserve necessary optimization-flow settings; inspect the installed ini and contrast bounded version probes before modifying HDL, licensing, or diagnostic gates.
