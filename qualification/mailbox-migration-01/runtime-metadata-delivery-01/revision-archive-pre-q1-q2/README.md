# Exact-byte tmux delivery — local preparation only

**Implemented and synthetic-tested, NOT approved for remote execution.** This
package is owned local preparation under the standing BSP goal, not authority
from a reviewer. No workstation, SSH, native diagnostic, launcher, transport,
preflight, vendor tool, namespace or consumed fixture was executed or changed.
All `authorization`, `ready_for_build`, and `vendor_run` flags remain false.
Immutable sibling contracts remain unchanged. This adapter proposes an extension;
it does not silently supersede their prohibition on remote redirects.

## Files and mechanism

- `delivery.py`: inert command generator, pinned proposal generator, strict finished
  control-transcript decoder. Importing it executes no payload and starts nothing.
- `fixture.py`: LOCAL-only private tmux fixture; accepts only synthetic emitter or
  byte-reader mode and a new `fixture-NN` directory. Not a workstation controller.
- `test_delivery.py`: synthetic decoder/generator tests, including malformed,
  truncated, missing-status, lag/disconnect, caps and fragmented protocol records.
- `proposed-command.txt`: exact generated **UNAPPROVED, DO NOT EXECUTE** shell text.
  Its fixed review nonce is not an execution authorization or authentication key.
- `validation.json`, `SHA256SUMS`: static bindings and package evidence hashes.
- `fixture-*/`: raw captures, synthetic inputs, exact shell commands, tmux argv
  logs and successful runs' separated output and result files.

The existing bash, not a replacement shell, executes a brace group. A builtin
`printf '%b'` reconstructs short, individually octal-quoted chunks into a pipe.
The final pipeline element is exactly `/usr/bin/python3 -I -B -S -`; it remains
bash's direct child. Pipe writer closure supplies actual EOF, not a PTY Ctrl-D.
No real payload bytes were executed here. The production proposal accepts only
41045 bytes with SHA-256
`29e2864c3e4c560a737bffdf9b65db41dd5a89736e29d40718acbdbf5cdebd60`.

Two small Python process-substitution encoders read stdout and stderr separately.
They emit channel/sequence/base64 records, each at most 512 bytes in one blocking
write to the SAME pipe. Atomicity relies on POSIX PIPE_BUF, **not** on concurrent
PTY writes being atomic. A bash coprocess with a third Python relay is the sole
writer of that pipe's contents to the PTY. No remote regular files, temporary
files, FIFO paths or receipts are used. `/dev/fd` process-substitution endpoints
are in-memory descriptors; this is not remote file staging. Diagnostic FD 3/7/8/9
copies are explicitly closed after setting stdout/stderr. Original diagnostic
argv, source, environment and inner exact-child pidfd launcher are unchanged.

A fixed Python termios helper saves terminal attributes, clears ECHO and OPOST,
and another restores the saved attributes after helpers finish. Canonical input
is not disabled: generated physical input lines stay below 1024 bytes. The large
source line itself never goes through canonical input unencoded. Source-code
quoting is ASCII-only; arbitrary byte data becomes octal. Binary output becomes
ASCII base64 before the PTY; OPOST is disabled so records are not rewritten.
Restoration output explicitly tolerates the restored CRLF convention.

Immediately following the diagnostic pipeline, bash copies `PIPESTATUS`, before
any other command destroys it. The S record contains the **Python** exit status,
both encoders' statuses, and the printf writer's status. It is not `$?` from tmux,
a pipeline aggregate, or an inner collector wait status. Both channel EOF records,
consecutive sequence numbers, valid canonical base64, S, and a successful relay /
termios-restoration R record are required. A nonzero Python status is preserved,
not converted to success. Receiver acceptance still requires its own checks.

## Real local evidence

`red-results.txt` records the expected missing-module RED before implementation.
`green-results.txt` records eight passing tests. The implementation protocol gained
an explicit restoration record during construction; the initial test expectations
were extended to require it, not used to waive a failing requirement.

Initial `fixture-01` reached both stream EOFs, Python status 23, and restoration,
but its original decoder misidentified a shell-echoed printf format as a damaged
frame. It timed out and was classified INCOMPLETE; its original raw capture and
command log remain. Decoder correction ignores pre-frame prompt echo, while
rejecting misalignment after framing starts. The explicit regression is
`test_prompt_echo_is_not_a_frame`. Subsequent fixture directories are deliberate
local debugging/verification runs, not automatic retries and not remote retries.

Final fixture commands (from this directory):

```text
python3 -B -m unittest -v test_delivery
python3 -B fixture.py fixture-06 emitter
python3 -B fixture.py fixture-07 reader
```

These names now exist; fixture.py refuses to overwrite/reuse them. A future
separately requested local rerun needs a fresh directory name.

- Fixture 06 runs a harmless **41045-byte synthetic Python program**, including a
  long comment line, with the fixed interpreter argv. It proves direct parent
  equality to its own existing bash pane and observes stdin EOF. It emits all byte
  values repeatedly and concurrently across separately captured stdout/stderr;
  exact byte comparisons pass. Python exits **23**, although tmux operations exit
  zero. Capture is **9807627 bytes**, beyond 3 MiB, without scrollback.
- Fixture 07 deliberately substitutes a fixed harmless `-c` byte-reader for the
  source interpreter, ONLY in that synthetic fixture. It receives **41045 arbitrary
  bytes**, including NUL, CR/LF, backslash and all high bytes; length and SHA-256
  match independently prepared input, and a second read confirms EOF. SHA-256 is
  `779c97ceef79cd099b28c4b4bee82d995f82bb4906793a1b356c7aea74a2bece`.
  Parent equality, separate 256-byte stderr and Python status **7** pass.
- Both final fixtures compare complete termios attribute structures before/after;
  restoration passes, including nonzero diagnostic exit. These are LOCAL tmux
  3.5a / bash 5.2 / Python 3.13.5 observations, not target compatibility evidence.
- Fixture 08 repeats the byte-reader against the final cleanup code. Early fixture
  servers had exited successfully but left stale socket inodes under the private
  scratch directories. `owned-cleanup.json` records exact-socket no-server queries
  and removal of only those owned stale sockets. Cleanup now verifies its owned
  server stopped, removes only its socket inode, and fixture 08 confirms absence.
- Fake tests separately cover exactly 3 MiB decoded stdout in a larger encoded
  channel, every octet escape, one-byte `%output` fragmentation, cap violations,
  missing EOF/status/restoration, invalid sequence/base64/escapes, explicit lag,
  client exit, command error and truncated protocol/frame records.

## Capture limits and receiver handoff

The fixture starts continuous `tmux -C` capture BEFORE loading or pasting the
command. It never uses capture-pane or screenshots. Each decoded stream has a
3 MiB cap; raw control capture has a 32 MiB budget (plus at most one 64 KiB
overshoot read, retained but rejected). That budget includes base64, octal protocol
escaping, framing, command echo and acknowledgements, rather than confusing the
3 MiB envelope allowance with a complete transport budget. Unusual fragmentation
can exceed this budget; that is INCOMPLETE, never silent truncation or a retry.
Capture has a 90-second deadline, with a 75-second fixture completion wait.
These bounds stop LOCAL capture, not the diagnostic. They do not replace the
unchanged launcher's exact-child pidfd timeout, and no SSH timeout is substituted.

`control.raw` is every byte read through capture completion; successful completion
requires both channel EOFs, actual Python status, helper completion and terminal
restoration. `control-full.raw` in the final fixtures additionally retains all
unread client stdout drained during deliberate LOCAL client shutdown;
`control-shutdown-tail.raw` separates that suffix. Shutdown is outside the
completed diagnostic acquisition. An unexpected disconnect/lag during acquisition
is always INCOMPLETE. Client stderr is separately retained. The full transcript
is primary evidence; separated `stdout.bin`, `stderr.bin` and status are derived.
Incomplete runs retain raw data rather than pretending missing stream/status
information was empty or zero. Disk/I/O errors or helper/setup failures can leave
partial artifacts; they are never a completed capture.

After a separately authorized real acquisition, receiver handoff is exact
`stdout.bin` as raw envelope, `stderr.bin` as outer command stderr, and the S
record's Python integer status. Any local capture/decode/limit/timeout error must
be supplied as a receiver transport error; do not pass success merely because a
plausible envelope exists. There is intentionally no automatic receiver call,
workstation driver, attestation shortcut or executable deployment CLI here.

## Unapproved remote proposal and required bindings

`proposed-command.txt` is generated locally by `proposed_command()` from read-only,
hash-checked sibling transport bytes. It is shell INPUT TEXT, not a script to
stage or execute as another shell (which would break direct parentage).
The proposed delivery mechanism is in-memory `load-buffer -` followed by
`paste-buffer -d -r`, continuously observed with control mode, through the SAME
freshly attested socket. No remote file argument is proposed. Actual deployment
commands, account/channel selection and authorization remain unimplemented.
Do not run the local fixture's new-session/kill-server operations on the target.

An execution decision would have to bind ALL of the following, freshly:

1. Existing `Agilex7Workstation`, UID/EUID 1000 genuinely mapped to
   `uwb_student00`, unchanged USER/LOGNAME, `TMUX=/tmp/tmux-1000/default,7828,4`,
   `TMUX_PANE=%4`, session `ia840f_migration_preflight` / `$4`, server 7828,
   pane `%4`, and its still-existing bash PID **25387**. No rebinding/recreation.
2. `/usr/bin/python3` resolving to `/usr/bin/python3.9`, with executable hash
   `7a95e551de45a54b3b6819d80e71a7262cd7138c2a4f1ec905b4cc8895a034c2`, and
   `/usr/bin/tmux` hash
   `e5b9534d3dc79b2e32ad958d458f4933fead6c768a80ccf0c3203ddfa0382dc7`.
   These are historical expected bindings, not freshly verified here.
3. Transport/launcher/collector/receiver and THIS adapter/helper/command hashes,
   exact byte lengths, fixed helper argv, a fresh execution nonce and raw capture
   budget/deadline. Existing receiver and launcher independent approvals do not
   approve this adapter or extend their old contract.
4. Compatible existing bash with coproc, process substitutions, arrays and builtins;
   an idle, uncontended pane; trustworthy inherited startup/environment and stdlib;
   no conflicting traps/aliases/functions/shell hooks/errexit/nounset behavior;
   FD 3/7/8/9 unused; adapter variables and DRELAY coprocess name unused; canonical
   input and OPOST behavior verified for the actual platform. Do not modify identity
   environment values to make checks pass. No shell `exec` replacement.
5. Explicit permission for these in-memory redirections, builtin pipe, coprocess,
   stdout/stderr encoders, relay and termios helpers, and an approved continuous
   control channel/controller with correct unexpected-disconnect handling.
6. Accepted inner collector race/startup limitations, intact guard behavior, and an
   explicit one-shot metadata execution authorization. No build/vendor permission.

## Remaining limitations / review blockers

This is a demonstrated local design, not a production-ready remote controller.
There is no independent spec/quality approval for this package. Python 3.9 grammar
checking does not prove runtime compatibility. Helpers add processes and must be
included in the scope decision; their own startup is not remotely attested here.
Normal and nonzero-status terminal restoration is tested; abrupt bash death,
SIGKILL, interruption or descriptor/setup failure can prevent restoration. No
recovery command, trap replacement, signal fallback or automatic retry is supplied.
An R record is therefore required, never presumed. Setup is not a transactional
execution gate against all asynchronous helper startup failures. Execution must
remain blocked until the parent accepts or resolves those constraints.

The nonce, sequence numbers and source hashes are not authentication of a hostile
shell/server. The parser intentionally rejects unsupported control notifications,
extended-output mode and pause/lag, instead of guessing compatibility. Local
client shutdown/drain behavior is fixture-only; a real controller's acquisition
boundary and external channel errors still need independent review/integration.
Successful synthetic status capture does not prove historical u03 cause, remote
readiness, filesystem permissions, or a successful metadata diagnostic.

Reusable lessons: encode before the PTY, use a shared pipe for atomic interleaving,
copy PIPESTATUS immediately, distinguish echoed command text from output frames,
verify parentage and termios restoration empirically, and retain failures rather
than overwriting them. These notes stay within this package's ownership boundary.
