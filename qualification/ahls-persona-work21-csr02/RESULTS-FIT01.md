# CSR02 Work21 fit01 — native result, review pending

The collector completed and the parent verified all18 exported files against decoded archive payloads and local bytes. Archive SHA256 `f33d14f057fb0b5d9351eb0b5a6d9a375cf003a25e25e8c39d1a4f09e9e6d5ee`, 4107120bytes. Native/effective/outer **0/0/0**. Native PID129114/start14892150 ran 2026-09-23T17:47:29.706696+00:00 through 2026-09-23T19:07:54.310208+00:00; no timeout, descendant leak or surviving owned group. All four preservation domains true; no acquisition diagnostics or postflight errors. [Verification](fit-parent-verification01.json), [outer receipt](outer-fit01.json).

Exact command: `/opt/altera/25.1/quartus/bin/quartus_fit --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu`.

Native says final database successfully committed (Info20274), fitter successful,0errors/166warnings. Peak virtual memory22924MB; native elapsed01:20:23. Native summary: 123948/912800ALMs,278200dedicatedregisters,469RAMblocks,321pins. These include the matching static design, not AFU-only resource counts. [Native summary](artifacts-fit01/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.fit.summary).

Warning counts from fitting.log: {"15705": 1, "15706": 1, "15714": 1, "171167": 1, "18502": 17, "20727": 5, "332049": 58, "332054": 41, "332158": 1, "332174": 40}. All166occurrences retained;20727 appears5times and15714once as Critical Warning. SDC/clock findings332049/332054/332174, I/O/PR and ignored assignments remain open pending panel-level disposition. [Ledger](fit-warning-ledger01.json).

Source/setup/synthesis provenance is the already accepted CSR02 candidate; this is not another synthesis. Fit used original2CPU/32GiB settings, preserved unchanged throughout. All4512 critical bindings and67 protected synthesis paths passed runner postflight. Subsequent read-only final-STA prerequisite capture reconciled the completed QDB and all in-persona critical bindings.

**Independent review and parent fitter acceptance remain pending.** This is native completion/acquisition evidence, not timing or hardware signoff. Prior−0.367/−0.356ns setup failures and broader signoff findings are not cleared. No FPGA access, programming, driver change, reset or reboot. Vendor DDR simulation remains SKIPPED BY USER.
