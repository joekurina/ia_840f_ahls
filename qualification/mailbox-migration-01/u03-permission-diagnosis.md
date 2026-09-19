# u03 PermissionError diagnosis — static evidence only

## Finding and limits

The preserved result supports a **post-claim, pre-probe failure**, not a demonstrated kernel/user-namespace rejection. The exact operation and inaccessible pathname remain **unknown**. No remote access, source execution/import, tests, permission changes, fix, retry, or new execution decision was performed for this diagnosis. u03 is consumed; all u01/u02/u03 sources and prior evidence remain untouched.

`u03-result-evidence.json` preserves exit 2, `INCONCLUSIVE`, `attempt_count: 0`, `cleanup: []`, and `primary_error: "PermissionError(13, 'Permission denied')"`; authorization/readiness/vendor flags are false. The log reports the retained final receipt rather than `REFUSED_BEFORE_CLAIM` or `INCONCLUSIVE_POSTCLAIM_FINAL_UNAVAILABLE`.

Local static verification:

- Manifest SHA-256: `76c503a12ca7fb5772a13ce8a4dcad6481817f66c3208e3b36a6285f6df85a20`; every manifest member matches.
- Parent inputs SHA-256: `e922d9945554f6057d1b0264b91a0061da83617b356962e669f563c7ad3662d2`.
- `preflight.py`: `c3f67d5b33efc52f812a6f1d42f67b2e26594897a8ccd73dd077320c0de3c4ba`.
- `probe.py`: `6c64fcffd3efb6fa70135ec390986d861276f56e8a04ccfdebde68a81044ee5f`.
- All embedded staging payload members match their local files. The command was parsed with shlex/AST and its data decoded, never executed.
- All four embedded remote evidence contents match their recorded SHA-256 and byte lengths. Evidence container SHA-256: `37d4509d1d5cfb8b5b3f28956b2c15c61cf31ee4bec6e48ffd05ec61848edd68`.

These checks establish consistency of preserved local material, not a fresh remote observation.

## Source path and candidate failure sites

Line references are to `isolation-preflight-u03/preflight.py` unless noted.

1. **Preclaim checks completed on this source path.** Lines 519–555 validate bundle/input bindings, host/user/TMUX, tool identities, the named tmux pane, protected/reserved paths, and `bwrap --help`. That help invocation is not a namespace probe. A failure here would reach the outer handler, not the observed final receipt.
2. **Claim and its child creation completed.** `claim(ROOT)` at 557 creates the exclusive root and `rw`, `protected`, `observer` (61–67). A child-creation error would occur before the main receipt try-block and produce the outer-handler status. The normal retained final receipt instead locates the error inside the main try-block (567–608).
3. **Before the first attempt**, the following operations can encounter permission-related failures:

| Order | Source | Candidate operation(s) | Next checkpoint |
|---|---|---|---|
| 1 | 568–569; 284–293 | Exclusive open/write/close of `observer/inputs.json` | `inputs.json` |
| 2 | 570; 234–242; `probe.py` 15–27 | Load the bound `probe.py` module; read own namespace links, mountinfo, IPv4/IPv6 route files; enumerate interfaces, create AF_INET datagram sockets and issue MAC-address ioctls; read `/etc/machine-id` when detected | `host-before.json` |
| 3 | 571; 284–293 | Exclusive open/write/close of `observer/host-before.json` | `host-before.json` |
| 4 | 572–573; 177–204 | Resolve runtime roots, read mountinfo, walk `/usr` and qualifying `/bin`, `/lib`, `/lib64` roots using `lstat`, `readlink`, and directory enumeration | `runtime-before.json` |
| 5 | 574; 284–293 | Exclusive open/write/close of `observer/runtime-before.json` | `runtime-before.json` |
| 6 | 575–578 | Create `protected/ro`, write its canary, create `protected/host.fifo`, create `rw/tmp` | No dedicated receipt |
| 7 | 581–595 | Create/bind/listen/configure host TCP and UNIX listeners; change into ROOT and restore prior cwd for the pathname bind; obtain listener address | No dedicated receipt |

This is a source-level candidate set, not a claim that each operation normally returns EACCES on this host. Runtime inventory is a plausible candidate because it traverses directories recursively, but **there is no evidence yet selecting it or any particular `/usr` descendant**. It inventories metadata, not file contents, and does not follow directory symlinks encountered within the walk; the initial roots are resolved/deduplicated.

`attempt_count` counts successfully returned results (597–598), not launch attempts. Thus zero alone would not exclude a failed launch. Here `cleanup: []` is the additional discriminator: setup exceptions in `attempt()` append `NO_LAUNCH` (377–394), and the postfork parent path appends its cleanup report (497–507). A propagated permission failure on those ordinary attempt paths would leave a nonempty cleanup array. Taken together with the recorded primary error, the evidence supports failure before the first `attempt()` call. No controls/lifecycle payload, pidfd teardown, or userns launch denial is demonstrated. Empty cleanup does not prove no host listeners were created: successful listener closes leave no entries (610–614).

`brief()` saves only `repr(exc)` (275–276); the main handler stores no traceback or operation label (607–608). The preserved repr does not expose `filename`/`filename2`. The final receipt intentionally omits intermediate stage detail (295–298). Neither elapsed time nor exit 2 identifies the failing operation.

## Existing observer evidence that can narrow the interval

The **three exact pre-attempt checkpoints** are:

- `observer/inputs.json`: successful completion means the initial receipt was written, not that host-state capture succeeded.
- `observer/host-before.json`: successful completion means host-state capture returned and that receipt was written; inventory is next.
- `observer/runtime-before.json`: successful completion means runtime inventory returned and that receipt was written; fixture/listener setup is next.

Under the preserved ordering and absent later alteration:

| Last complete checkpoint | Remaining failure interval |
|---|---|
| None | Initial inputs receipt creation/write/close |
| Inputs only | Host-state capture or host-before receipt creation/write/close |
| Host-before | Runtime-root selection/inventory or runtime-before receipt creation/write/close |
| Runtime-before | Its close, then fixture/listener setup before first attempt |

A file merely existing or having nonzero size does not prove its write completed. Partial/malformed JSON points toward an interrupted receipt write but is not definitive attribution. Even valid JSON cannot prove its close returned successfully. An earlier complete file with a later absent checkpoint narrows an interval, not a specific syscall. No partial runtime inventory is saved: an inventory exception loses the in-memory traversal progress. Its last inaccessible pathname cannot be recovered from a missing runtime-before receipt. If checkpoints are contradictory, stop and report the contradiction rather than infer source progress.

## Smallest exact read-only remote lookup proposed — NOT executed

First request only `lstat` metadata for these **three predictable checkpoint names**, on the already-identified workstation as the same user. No directory listing is necessary, no recursion or remote preflight import is needed, and final.json need not be fetched again. This is a diagnostic lookup proposal, not authorization to execute it:

```sh
/usr/bin/python3 -I -B -S -c 'import os,json,stat
root="/home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01/preflight-isolation-7c407469a419-u03/observer"
for name in ("inputs.json","host-before.json","runtime-before.json"):
 p=root+"/"+name
 try:
  s=os.lstat(p)
  out={"path":p,"mode":oct(s.st_mode),"regular":stat.S_ISREG(s.st_mode),"uid":s.st_uid,"gid":s.st_gid,"size":s.st_size,"mtime_ns":s.st_mtime_ns,"dev":s.st_dev,"ino":s.st_ino}
 except OSError as e:
  out={"path":p,"error_type":type(e).__name__,"errno":e.errno,"filename":e.filename}
 print(json.dumps(out,sort_keys=True))'
```

This metadata-only batch is the smallest useful first lookup. It does not establish JSON completeness. If an exact present checkpoint needs validation, propose a separately bounded read of only that named regular file, with no symlink following, an aggregate ceiling of 67,108,864 bytes (the source receipt budget), SHA-256, JSON parse outcome, and compact schema summary rather than dumping a potentially large inventory. Select that follow-up only after the metadata result; do not automatically broaden to filesystem traversal, recreate host_state/runtime_inventory, invoke tools/probes, or inspect unrelated process namespaces. Reading current permissions at a guessed runtime path would not establish the historical failure.

If metadata or checkpoint contents only identify an interval, report that as the endpoint: the retained source does not guarantee enough observer detail to identify the exact failing syscall. No permission remediation, source instrumentation, retry, alternate suffix, fixture cleanup, or migration/build authorization follows from this diagnosis.
