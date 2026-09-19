# Local diagnostic receiver — preparation only

`receiver.py` is Python 3 stdlib only. It reads captured files; it never imports or
executes the launcher, transport or collector, accesses a remote system, or issues
vendor commands. Independent receiver review and a separate execution decision
are still required. Consumed u03 remains untouched and INCONCLUSIVE.

## Use after an independently approved capture exists

```sh
python3 -B receiver.py --raw captured-stdout.bin --exit-status 0 \
  --command-stderr captured-stderr.bin --output NEW-local-evidence-directory
```

`--exit-status` is the exact outer command exit code, not the tmux client's exit
code or the collector's raw wait status. Omission means missing and is INCOMPLETE.
`--transport-error TEXT` can be repeated. Never infer zero from an envelope.
The receiver's own exit code is 0 for COMPLETED, 1 for INCOMPLETE, 2 for local
I/O failure (including an existing output directory). An I/O failure may leave a
partial directory; do not treat it as completed evidence or overwrite it.

The output contains the unchanged `raw-envelope.bin`, exact decodable
`collector-stdout.bin` and `collector-stderr.bin` separately, and derived
`result.json`. Optional outer-command stderr is retained separately as
`command-stderr.bin`; omission is explicitly null, not fabricated empty evidence.
No stdout/stderr merging, newline conversion, path resolution, or raw JSON
reformatting is performed. The result JSON is a derived assessment, not original
evidence. Invalid base64 remains in the raw envelope. Decodable streams survive
hash/length failure. Oversize streams are not decoded; the raw envelope survives.

Only 3 MiB or less is parsed. An already-captured oversized input file is copied
in 64 KiB chunks, retained in full and rejected, without loading it in memory.
Disk usage for preservation follows the supplied finite capture size; this is not
an unbounded network/stdin capture service. Its caller must finish and bound
capture independently. Inputs should be immutable during ingestion.

Acceptance requires exactly one ASCII JSON object with JSON whitespace only;
duplicate keys, NaN/Infinity, nonfinite numbers, truncation, extra documents and
wrong field types fail closed. Both streams use strict, canonical base64 and are
capped at 1 MiB decoded, with exact declared lengths and SHA-256. Launcher
30087/SHA-256 `2670ff15528edcbd134b647624d335f6eca79263fa547b9e7515d7c3444ce3c2`
and collector 13851/SHA-256
`6a524fbb0793822b55ef41855ea1f97f5d1e7210c0783cee53a5176e810ff897`
are pinned, not configurable. These bindings do not authenticate a hostile sender.

The outer acceptance fields are `terminal='completed'`, `reaped=true`, integer
`wait_status=0`, `timed_out=false`, `errors=[]`, finite nonnegative `elapsed`, and
all of `authorization`, `ready_for_build`, `vendor_run` exactly false. Collector
JSON must have those false flags, terminal exactly `{'result':'completed'}`,
empty `close_errors`, passed guard, nonempty roots, well-typed counts, elapsed,
selection and expected identity values. Reported identity is not live attestation.

A coherent error envelope (outer exit 1, terminal INCOMPLETE, raw wait 256,
reaped/no timeout/no launcher errors, valid bindings/streams) containing the real
collector OSError failure shape is labeled `observed_current_filesystem_error`.
It is still overall INCOMPLETE. `collector_terminal` retains the entire failure,
including exact operation/path/filename/filename2/errno; close failures are also
retained. Stop/deadline/refusal/malformed/untrusted reports are not rebranded as
filesystem observations. Completion is a current successful traversal only.
**Neither outcome proves or excludes historical u03 cause, receipt-write failure,
or host-before-close failure. All authorization/readiness/vendor flags stay false.**

## Fixture verification

Run `python3 -B -m unittest -v test_receiver` here. All data are explicitly
synthetic. The tests execute only the receiver locally, not diagnostic code.
They cover valid JSON and trailing whitespace, both 1 MiB streams, exactly 3 MiB
outer input, every status/flag layer, missing fields, malformed and duplicate JSON,
base64/hash/length errors, oversize input, arbitrary field types, collector errors,
exact non-normalized error paths, transport failure and CLI byte preservation.
`red-results.txt` records the initial expected missing-module failure;
`test-results.txt` records the final suite. `validation.txt` records read-only
source bindings and Python 3.9 grammar checks, not target runtime compatibility.
`SHA256SUMS` covers this package except itself. No production capture exists here.

## Delivery decision — no remote command executed

**Delivery is blocked under the unchanged contract; tmux alone is insufficient.**
The local `/usr/share/man/man1/tmux.1.gz` documents `load-buffer ... -`,
`paste-buffer -r`, `pipe-pane` and control mode `%output` (octal-escaped pane bytes).
Buffers avoid remote staging, but paste still traverses the PTY: canonical input
limits threaten the transport's long line, and Ctrl-D is not pipe EOF. Control
mode can continuously capture well beyond 3 MiB without scrollback, but sees
PTY-processed/merged streams; `%end` is not the Python exit status. `pipe-pane`
adds a shell command and still does not solve child status or stream separation.

**Concrete candidate for the next scope decision, not an implemented channel:**
a verified compatible existing shell runs builtin `printf '%b'` with locally
prepared octal chunks on short continuation lines, piped to
`/usr/bin/python3 -I -B -S -`, then immediately prints a framed `$?`. This supplies
exactly 41045 transport bytes and EOF through a pipe, without a remote file.
Sender pins SHA-256
`29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60`.
Python must remain a direct child of shell PID 25387 in `%4`; never replace that
shell. Use only the freshly attested `/tmp/tmux-1000/default` socket.

Minimal decision: allow review/local inert testing of this framed shell adapter,
including any necessary in-memory descriptor redirection and temporary terminal
mode control. The immutable README currently forbids remote redirects and does
not approve this adapter. Parentage, exact bytes, separate stderr, framing and
capture throughput are unverified. A future control-mode controller must retain
the complete raw transcript locally, budget at least 3 MiB envelope **plus**
framing/protocol expansion, losslessly decode `%output %4`, and require the exact
shell status frame. Any disconnect, `too far behind`, missing status or truncation
is INCOMPLETE, never a retry permission. No screenshots, truncated scrollback,
new socket/pane/session, remote staging or permission changes. If the adapter
allowances are denied, the exact-byte/stdin-EOF/separate-stream/status requirements
remain incompatible with a bare tmux paste-and-capture path.
