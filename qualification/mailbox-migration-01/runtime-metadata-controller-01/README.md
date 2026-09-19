# Local acquisition-to-receiver controller

Implemented and tested with **synthetic fake channels only**. Production execution
remains blocked. No SSH/tmux backend, deployment CLI, helper startup, process
launch/signalling, terminal mutation, retry, live attestation or authorization is
provided. Importing `controller.py` performs no acquisition or filesystem I/O.
All authorization, ready_for_build and vendor_run flags are false.

## API and ownership

`controller.acquire(channel, output, pane, token, *, seconds=90.0,
raw_cap=33554432, clock=time.monotonic, sink_open=exclusive_sink)` returns a final
in-memory receipt. This is only a local in-memory/fake captured-stream API, not
a way to run the real transport. See `test_controller.py` for the runnable fake
channel and explicitly invented, source-bound synthetic envelope.

The already-attached, trusted cooperative channel supplies:

- `setup(deadline)`: initialize local capture state only, not a connection or
  helper. It must not start commands or alter the remote environment.
- `read(maximum, deadline)`: return at most `maximum` original binary bytes, or
  the identity sentinel `controller.CAPTURE_END`. Return consumed bytes before
  reporting a subsequent error; exceptions cannot invisibly carry unread data.
  Empty bytes ALWAYS mean unexpected disconnect, even after a complete R frame.
  Other events/types, overlarge returns and raised errors fail closed.
- `close(deadline)`: release local capture resources only; do not signal, kill,
  stop, detach a process, or mutate a terminal. All pending acquisition errors
  must surface before or during this operation. It must be safe after partial
  setup, including `deadline=None` if clock initialization failed.

`CAPTURE_END` means the supplied LOCAL capture has delivered its entire agreed
acquisition interval, including every suffix/error notification. It is NOT
inferred from EOF or a successful frame prefix, and is NOT a remote readiness
attestation. A real backend cannot use this contract until its boundary, draining,
error delivery and ownership have been independently designed and reviewed.
The controller never stops reading just because the parser could accept a prefix.
It decodes only after this boundary or failure AND local channel/sink cleanup.

`pane` must be `%` plus 1–10 digits and token exactly 32 lowercase hex digits.
`seconds` must be finite and in (0,90]; `raw_cap` must be an integer in
[1,33554432]. Lower limits are useful for synthetic tests and can reject otherwise
valid envelopes. `clock` and `sink_open` are dependency-injection seams for local
tests, not untrusted or remote plugins. A sink must obey ordinary binary file
semantics, including exclusive creation, bounded operations and integer write
counts. A short write fails, with no retry. Do not supply a sink that launches
processes or writes outside the designated output.

Parameters and all pinned sources are verified before taking channel ownership.
Source drift, invalid arguments, or failure to create the fresh output directory
raise to the caller; the channel remains caller-owned. Existing outputs are
refused, not reused, removed, repaired or overwritten. After directory creation,
setup/acquisition/persistence/cleanup errors are returned. The output must reside
in a trusted local parent directory not concurrently modified by another actor;
this is not a hostile-directory or symlink-race defence.

## Evidence and final acceptance

`control.raw` is exclusively created and incrementally written/flushed. Each
accepted read is first retained in memory. Read errors and disk failures therefore
retain previously read bytes, even when the on-disk file is partial. Capture does
not drain further after a failure or retry persistence; unread channel bytes are
not claimed to have been captured. The cap-crossing byte is retained and rejected.
An overlarge read is a channel-contract violation, not an authorized unbounded
buffer; its bytes are not copied or claimed as preserved.

The exact verified `delivery.decode` implementation parses the finished retained
transcript. No alternative parser or repaired transcript is used. Lag, disconnect,
unsupported notifications, malformed/truncated records, reserved trailing D1
prefixes, missing status/restoration and parser errors fail closed. The decoder's
reviewed allowlisted notifications remain allowed. On decoder failure, raw bytes
remain but decoded stdout/stderr/status are **unavailable**, not guessed.

The exact decoded stdout (including JSON whitespace) is passed to
`receiver.evaluate`, together with the S record's true outer Python status and
ALL recorded acquisition/cleanup/persistence errors. Missing status is `None`,
never zero or the inner wait status. Command stderr is distinct, not merged with
the envelope or collector stderr. In a fresh `receiver/` subdirectory the controller
exclusively persists:

- `raw-envelope.bin`: exact outer stdout, only when delivery decoding succeeded;
- `command-stderr.bin`: exact separate outer stderr;
- `collector-stdout.bin`, `collector-stderr.bin`: receiver-returned decoded bytes
  when available, even when the receiver rejects integrity/acceptance fields.

The controller calls the receiver's in-memory API rather than its CLI, so all
local writes can be exclusive, short-write-checked and error-injected. Neither
transport, launcher, collector nor fixture is imported/executed. Their exact
source lengths and SHA-256 values are checked alongside delivery and receiver;
only the latter two verified source byte strings are compiled into non-main
module namespaces on explicit acquisition. No bytecode cache/import path can
substitute different decoder or receiver source.

`acquisition.json` records raw hash/length, status, bindings and errors known
before writing that record. It ALWAYS says INCOMPLETE and
`final_receipt_required=true`: a result file cannot testify to its own successful
flush/close. It must never be interpreted as an overall PASS. Its own write,
flush and close errors are recorded in the returned receipt. No disk-success
fallback or overwrite is attempted when the sink fails.

Only the returned `assessment` is a final receiver assessment, after all capture,
channel close, evidence writes and sink cleanup. The receipt also contains
`errors`, `raw`, `envelope` (None when unavailable), `command_stderr`,
`collector_streams`, `explicit_boundary`, and the three false flags. The final
receiver call includes errors from evidence/metadata persistence too. A raised
receiver exception is contained as INCOMPLETE rather than escaping with lost
raw bytes. COMPLETED means only acceptance of the supplied local report, never
live attestation, historical causation, fixture execution or production readiness.
Callers must retain the returned receipt if they need the final failure details;
a failed filesystem cannot be guaranteed to durably store its own failure.

## Bounds and deadline

The default raw bound is the reviewed delivery `RAW_CAP`: **32 MiB**, plus exactly
one retained overflow byte. Reads request at most 65536 bytes and at most the
remaining allowance plus one. No unbounded file read is used for source bindings.
The decoder caps each decoded outer stream at 3 MiB; receiver caps each decoded
collector stream at 1 MiB and its input envelope at 3 MiB.

This is not a mistaken 3 MiB raw limit. The reviewed encoder emits 288-byte chunks
as canonical base64 (384 bytes), token, channel, decimal sequence and LF, in a
single frame of at most 512 bytes. At 3 MiB per stream, 10923 nonempty frames per
stream suffice; the largest data frame here is 429 bytes. With newline octal
escaping and one control record per frame using a ten-digit pane ID, an upper
bound for the two streams' data records is 9,896,238 bytes, plus EOF/S/R records.
The 32 MiB budget additionally permits substantial acknowledgements, prompts,
echo and fragmentation. Arbitrarily fine fragmentation or other-pane noise can
exceed any fixed budget: that is explicitly INCOMPLETE, not silent truncation.
The test suite delivers a full exactly-3-MiB synthetic envelope through framing.

Total file-content storage is bounded by `DISK_CAP = 42,008,577` bytes: raw cap
plus one, two 3 MiB outer streams, two 1 MiB collector streams and 65536 bytes of
metadata. This excludes filesystem allocation/metadata overhead. Metadata has
an explicit cap and is refused rather than truncated. Parsing memory is bounded
by these fixed input caps and the reviewed parsers, not a promise that process
RSS equals 32 MiB: raw/decoded byte copies, split-line arrays and JSON objects
have implementation-dependent overhead. The controller performs one finished
parse, not repeated parses of every arriving prefix. Error accumulation is over
a fixed finite set of stages after the first acquisition error, with 256-character
exception summaries. Raw bytes are never embedded into error strings.

The monotonic acquisition deadline is checked around setup, before/after reads,
after cleanup and around evidence publication. The same absolute deadline is
passed to every channel operation. Late close/deadline errors cannot be replaced
by a previously valid transcript. This is a **cooperative deadline**, not a hard
wall-clock watchdog: Python cannot preempt a blocked supplied method, filesystem
write/flush/close, source read or parser without a different execution mechanism.
No process/thread watchdog, signals or subprocess timeout is introduced. Local
regular files and bounded cooperative channel methods are required. A blocking
backend or hostile custom method is outside this local contract and remains a
production blocker. A failed deadline does not stop the remote diagnostic.

## Verification and provenance

Only local Python unit tests were executed; no live tmux fixture, network,
transport, launcher, collector, vendor tool, commit or push was run.

- `red/`: initial tests precede implementation; expected missing-controller import
  failure, exit 1. This is a new-API TDD RED, not a reproduced historical defect.
- `green-01/`: first implementation, 9 test methods passing, exit 0.
- `green-final/`: final sources and strengthened regressions, 14 methods passing,
  exit 0. Includes all source hash AND length gates, no-I/O import, each sink
  fault alone, simultaneous read/sink-close/channel-close errors, receiver failure,
  and deadline crossing during close. These additions follow the initial TDD cycle.

Each directory retains exact test/runner/controller snapshots when present,
`unittest.txt`, and `checks.json` with actual argv, cwd, interpreter, exit status,
source SHA-256/lengths and output hash. Python 3.9 AST parsing succeeds; this is
**grammar compatibility only**, not Python 3.9 runtime certification. Recorded
execution used the interpreter identified in each checks record.

To run only the local fake tests in a NEW evidence directory:

```text
python3 -B check_local.py new-local-check-name
```

Never reuse an existing evidence directory. `manifest.json` inventories this
implementation and retained tests/evidence, deliberately excluding itself,
`SHA256SUMS`, and future review/disposition files. `SHA256SUMS` also binds the
manifest. Future independent specification review followed by independent quality
review must be supplied by separate reviewers; this implementation claims neither.

Reusable local lesson: inject failures after a fully decodable terminal prefix,
retain in-memory bytes before sink writes, propagate multiple cleanup failures,
and distinguish an explicit completed local acquisition interval from EOF or an
R frame. Never let a persisted success receipt precede its own failing cleanup.

## Unresolved production gates

Transactional remote helper startup/readiness and failure recovery/restoration
remain unsupplied and unchanged. Fresh interpreter/account/tmux/exclusive-owner
attestation, compatible uncontended shell state, a reviewed production acquisition
boundary/backend and an explicit one-shot execution decision are absent. Source
hashes, nonce and synthetic identity fields are not authentication or attestation.
The immutable siblings' guards and restrictions are not weakened by this API.
The standing IA840F build remains blocked on BMC mailbox generation; this local
controller does not fix that or establish the historical u03 cause. All work is
confined to this new controller package; no sibling/u01/u02/u03/candidate edits.
