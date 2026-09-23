# fit01 — finite native out-of-memory failure

Native/effective/outer status **5/5/5**, no timeout, no surviving owned group. Started 2026-09-23T15:01:04.756760+00:00; ended 2026-09-23T15:17:34.521245+00:00. [Outer receipt](outer-fit01.json) binds archive SHA256 `7896fb926796703827e5119f06b2b2023b696521e3c5eea5a8c0ed2cae67ea1f` (2,805,044 bytes). Parent reverified all 12 embedded payloads and their decoded local copies. Full native logs/reports remain local under `artifacts-fit01/`.

The native log ends `Out of memory in module quartus_fit (15933 megabytes used).` The runner imposed RLIMIT_AS=16GiB per process. All four source/setup/release/tool preservation flags are true; postflight errors empty. The native result is rejected, not a fit pass. The runner's Error/Fatal-colon parser did not include this OOM wording in `diagnostics`; the native code5 and absent success marker independently rejected the run. Do not equate an empty diagnostic array with an error-free run.

Periphery placement and preparation ended after the reported00:08:51; register packing completed and physical synthesis was selected. Placement/routing completion was not established. Plan report was captured. Intermediate fitter snapshots were explicitly **not committed** because the inherited assignment is disabled; no change to that assignment is being made.

The earlier accepted full Work21 native fit reported `Peak virtual memory: 21022 megabytes` in `../fim-build-21/final-capture01/ofs_top.fit.rpt:41763-41770`, alongside its successful native banner. The16GiB limit was therefore below measured previous successful FIM use. This motivates32GiB per process for a fresh fit02, not a design/constraint change or removal of limits. Keep the>80,000,000,000-byte MemAvailable preflight, no competing native jobs, two-CPU affinity and10,800s deadline. This is not aggregate OS-enforced memory containment.

fit02 re-copies the original completed **synth01** tree; it does not reuse the interrupted fitter database or rerun synthesis. All5,639 source/database/report bindings and67 protected synthesized/partitioned paths remain the same; only fresh run/root/authority contexts and the process-memory limit change. [Exact delta](source-delta-fit02.json), [template delta](runner-delta-fit02.patch). All failed bytes are preserved.

Retain20727,15705/15706 and18502 observations; final PR-region, dangling-port and SDC interpretation requires complete actual reports. No hardware operation, programming, reset or reboot occurred. Goal incomplete.
