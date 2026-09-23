# CSR02 final multicorner STA01 — completed, review pending

Native/effective/outer **0/0/0**. PID131265/start15393786 ran2026-09-23T19:11:06.066296Z through2026-09-23T19:12:36.114564Z. Parent verified all13exported payloads against archive/local bytes, all preservation domains true, no acquisition diagnostics/postflight errors/timeouts/owned survivors. ArchiveSHA256`2c95ee5dd45f1f9781af202016273e1cfb333467eae12b89c356519732979f40`,5770723bytes.5749criticalbindings;344protected physical/synthesized paths. [Verification](sta-parent-verification01.json).

Command: `/opt/altera/25.1/quartus/bin/quartus_sta ofs_top -c ofs_pr_afu --snapshot=final --multicorner=on --do_report_timing --do_report_cdc_viewer`.

All645reported corner/metric/domain records are nonnegative (129percorner across5corners), same keyset as prior negativeSTA. Prior EMIF0-core-clock setup summaries−0.367ns and−0.356ns now+0.375ns and+0.398ns;TNS0.000 in both. These are domain minima, NOT exact old/new path identities. [Records](sta-domain-timing-records01.json).

Native Timing Closure panel PASS, but overall Design Closure FAIL. Unconstrained Paths FAIL:2inputs/78pairs,2outputs/10pairs for setup/hold. Signoff22/88rules failed, with high-severity CDC/reset/SDC findings retained. Missing report categories are not passes. [Panels](sta-native-panels01.json), dedicated `ofs_pr_afu.tq.drc.signoff.rpt` captured. Native0errors/380warnings; [warning ledger](sta-warning-ledger01.json).

Native clock property table exactly matches prior capture; actual auto user clocks200/100 unchanged. CPU affinity36 and QSFthreads36/64GiB verified; native Parallel Compilation panel lists36detected but maximum allowed24. No claim of36effective workers. Resource/callback delta only; no SDC/clock-policy or fitted-logic edit.

**Direct CSR cone check remains open:** default report contains no literal src_last_q/dst_last_q paths. Resolve mapped merged endpoint names and inspect original feedback/admission plus new arithmetic→endpoint and endpoint→admission paths; absence of literal names does not establish missing logic or path-specific closure. No unchanged build rerun is justified by this report-coverage limitation.

Independent review and parent bounded numerical acceptance pending; full signoff/hardware NOT accepted. No FPGA/device/MMIO/reset/programming/driver/reboot activity; vendorDDRsimulation SKIPPED BY USER.
