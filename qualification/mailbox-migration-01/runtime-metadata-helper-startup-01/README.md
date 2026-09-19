# Delivery helper startup candidate — local synthetic evidence only

This is a separate candidate, not a replacement for any approved sibling and not
production execution authority. Independent specification review, then quality
review, remain pending. All authorization, ready_for_build, vendor_run and
remote_execution flags are false. No real transport, launcher, collector or
metadata diagnostic was executed. No tmux, default socket, workstation session,
SSH, network, vendor tool, installation, permission change, commit or push was
used. Only this new package was written.

## Implemented boundary

`startup.command(payload, token, faults=None)` returns inert shell text. There is
no deployment CLI or production channel backend. The brace group is intended for
an existing compatible bash; it does not run a replacement shell around the
payload. Its inputs are trusted local bytes, not an authorization gate.

1. Save terminal state without mutating it. Only after the saved state is retained,
   clear ECHO/OPOST with a separate helper. Even an apply failure after mutation
   takes the saved-state restoration path.
2. Start relay, stdout encoder, then stderr encoder as named bash coprocesses.
   Each coprocess execs the fixed embedded Python helper. Each has its own private
   pipe for readiness; stdout on that pipe never carries payload data. Bash
   duplicates the data and readiness endpoints and closes the coprocess originals.
3. Each helper verifies its actual required input, readiness-output and target
   descriptors with fstat/F_GETFL, including pipe type and access mode. The relay
   requires a terminal destination. Only then does it emit its exact READY role
   record. Bash uses a 0.4-second timed read per helper. Child PID existence is
   not readiness. Any descriptor/readiness failure prevents the payload branch.
4. After all three observations, builtin printf reconstructs the exact octal
   bytes into a pipe whose final element is `/usr/bin/python3 -I -B -S -`.
   PIPESTATUS is copied immediately. No helper wraps that payload process.
5. Close acquired encoder inputs even on partial startup, wait each owned encoder,
   close relay input, and wait the owned relay. Helpers cooperate with EOF; the
   injected missing-ready helper waits for EOF with a three-second fallback.
   Record each nonzero wait independently; do not replace the primary setup error.
   Attempt saved-state restoration and compare tcgetattr with the saved state.
   Attempt descriptor closes independently and retain close errors.

Encoder records are single writes of at most 512 bytes to the shared pipe, with
288-byte raw chunks and separate O/E sequence/EOF records. The relay alone writes
those records to the terminal. Encoder output is mapped to FD 2 on the coprocess
redirection *before* its body executes. Earlier candidate revisions incorrectly
relied on FD 9 surviving into a later coprocess: real required-FD validation
rejected it and prevented dispatch. That failed experiment is retained.

The generator uses FD 3 (saved terminal output), 4 (temporary readiness), 7/8
(encoder inputs), and 9 (relay input), plus bash coprocess FDs. FD 5/6 are closed
in children. These descriptors, `d_*` variables, and HSRELAY/HSOUT/HSERR names must
be unused. It does not inspect or enforce this precondition and must not be used
in an arbitrary shell. No shell trap is installed or replaced, no process-group
signal is sent, and the candidate sends no signals at all.

## Protocol and evidence

Successful D1 O/E/S/R records retain the sibling decoder contract unchanged.
The exact hash-pinned sibling `delivery.py` decoder accepts the normal synthetic
capture and rejects all injected failure captures. No approved decoder was edited.
The S payload status is genuine pipeline element status, not bash/fixture status.
A descriptor-close failure suppresses R instead of weakening the decoder.

Additional non-D1 lines are **candidate-only auxiliary evidence**:

- `HS1 <token> DISPATCH`: the shell is about to enter the payload branch.
- `HS1 <token> P <primary> C <cleanup-list> T <restore-status>`: primary failure
  separately from cleanup failures. `none,O:74` retains the initial empty-list
  marker followed by the actual error; it does not mean cleanup succeeded.

The old decoder tolerates these non-D1 lines as transcript text; it does not parse
or certify HS1 evidence. HS1 is not a new production control protocol or permission
mechanism. Any production consumer integration requires later review. Failure to
produce a complete D1 result is incomplete even when auxiliary text exists. Raw
bytes are primary; `derived-normal/` contains separated outputs decoded from the
finished normal fixture capture without rewriting its D1 records.

## Verified tests and retained revisions

The initial tests were written before implementation. `red/` retains their
expected missing-fixture import failure (exit 1); it is a TDD missing-implementation
RED, not a reproduction of the historical sibling's asynchronous race.
`attempt-01/` through `attempt-03/` retain real FD-inheritance failures and source
snapshots (exit 1). `attempt-04/` is an earlier six-method passing suite. `green/`
binds the final five implementation/test/runner sources and the final passing
seven-method suite, covering 16 owned PTY/bash fixtures:

- Normal binary stdout and stderr, pipe EOF, direct bash parentage and status 23.
- Each of relay/O/E failing before readiness, missing readiness, and invalid
  required destination FD: nine cases; no DISPATCH or S record, decoder rejection,
  termios restoration, unchanged pre-existing synthetic USR1 trap, under 3 seconds.
- Each helper returning an injected cleanup failure: three cases, individually
  retained, restoration attempted, decoder rejection.
- Partial setup E failure together with O cleanup failure and restoration failure:
  primary E_readiness, O:74 and restore:75 all retained, no payload dispatch.
- Apply failing after mutation, with successful restoration and no dispatch.
- Restoration failure after a real synthetic payload, retaining S status 23 but
  failing D1 completion acceptance with R restoration status 75.

`test_bytes_and_grammar` also independently reconstructs all-octet synthetic
payload literals, checks short physical shell lines, immediate PIPESTATUS syntax,
absence of trap replacement, token rejection, and Python 3.9 AST grammar.
The interpreter actually used is Python 3.13.5; this is not Python 3.9 runtime
certification. `/bin/bash -n` checks the inert real-byte proposal without executing
it. The local fixture uses a newly allocated PTY and fresh bash, not tmux, and
feeds shell text from a local package file. Thus it is not a canonical-line paste
or tmux-control-mode end-to-end test. For decoder testing, captured PTY octets are
mechanically encoded as a synthetic `%output %0` record.

The fixture never claims its final cleanup repairs the candidate: `restored` is
measured before fixture-owned PTY reset. Every green fixture's forced_bash_kill
flag is false. The fallback may kill only its exact Popen-owned synthetic bash;
it never claims that killing bash cleans orphan helpers. Successful waits and
closed PTYs are retained; no server-cleanup inference is made.

Exact invocation series from `/home/joe`:

```text
/usr/bin/python3 -B Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/runtime-metadata-helper-startup-01/check.py red
/usr/bin/python3 -B Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/runtime-metadata-helper-startup-01/check.py attempt-01
/usr/bin/python3 -B Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/runtime-metadata-helper-startup-01/check.py attempt-02
/usr/bin/python3 -B Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/runtime-metadata-helper-startup-01/check.py attempt-03
/usr/bin/python3 -B Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/runtime-metadata-helper-startup-01/check.py attempt-04
/usr/bin/python3 -B Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/runtime-metadata-helper-startup-01/check.py green
/usr/bin/python3 -B /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/mailbox-migration-01/runtime-metadata-helper-startup-01/validate.py
```

The runner records exact unittest argv/cwd, exits, source snapshots, source/input
hashes, raw stdout/stderr and their hashes. Each fixture retains its exact shell
text, synthetic source, raw terminal output, result and cleanup receipt. Existing
run directories are not overwritten. The validator binds 275 immutable input
files from the five sibling packages and u-prefixed evidence against the RED
baseline. It reads/hashes the actual 41045-byte transport and generates
`proposed-command.txt`, reconstructs identical bytes, and only syntax-checks the
shell. It never imports, compiles or executes that transport. The proposal is
UNAPPROVED INPUT TEXT, not a runnable deployment script.

## Limits and remaining review work

- Readiness is positive observation at a point in time, not an atomic guarantee
  against a helper dying immediately afterward. Runtime helper failures still
  make acquisition incomplete and may occur after payload dispatch.
- The candidate has fixed local-fixture-sized deadlines: 0.4 seconds per readiness
  read and 15 seconds per helper's input loop after readiness. These are not
  production timeout choices. No payload execution deadline is implemented here;
  the unchanged launcher's contract is not replaced.
- Pipe/TTY writes, exec/import startup, termios syscalls and bash waits are not
  forcibly cancellable. EOF gives bounded cleanup only for cooperative helpers;
  an unkillable syscall can prevent the restoration path. Bash SIGKILL, shell
  loss, server loss, arbitrary interruption or hostile shell behavior can prevent
  both cleanup and evidence. No impossible recovery claim or rescue command is
  supplied. No replacement traps are installed to mask those limits.
- Cleanup tests inject helper exit failures and a real skipped restore, not every
  OS-level close/fork/dup failure. The recorded close-error branches are not
  fault-injected. Terminal-save failure, shell descriptor collision, hostile
  hooks/options, stopped helpers and loss during cleanup remain untested.
- The shell must be trusted, idle, compatible non-POSIX bash without conflicting
  aliases/functions, errexit/nounset/options/hooks, occupied reserved descriptors,
  or other live coprocesses. These are preconditions, not verified attestations.
  Helpers do not close arbitrary unknown inherited shell descriptors.
- HS1 metadata is not authenticated. A production channel's terminal ownership,
  source/helper hashes, framing boundary and error propagation still need design
  and review. The existing local controller is only an approved fake-channel
  adapter; no production backend has been invented or exercised here.
- Immutable siblings and historical u01/u02/u03 evidence are unchanged. Synthetic
  success proves neither remote readiness, historical cause nor build permission.

Reusable local lesson: use a readiness pipe to validate acquired descriptors in
the final helper process, rather than relying on coprocess creation or a PID.
Keep failing source-bound experiments, preserve primary and cleanup failures, and
measure restoration before fixture cleanup can hide a candidate failure.
