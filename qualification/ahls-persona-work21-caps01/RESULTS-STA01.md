# CAPS01 final STA01 — native completion and domain observations

Independent review pending. Goal incomplete; no hardware operation.

## Acquisition and preservation

Command `quartus_sta ofs_top -c ofs_pr_afu --snapshot=final --multicorner=on --do_report_timing --do_report_cdc_viewer`, Quartus25.1.0Build129, actual Work21release03, AGFB027R25A2E2V,ofs_top/top,ofs_pr_afu/PR_IMPL. Started2026-09-23T21:45:26.993246+00:00, ended2026-09-23T21:46:56.531855+00:00, PID142599/start16319879. Native/effective/outer0/0/0; no timeout/survivors/errors. All four preservation flags true. [Parent verification](sta-parent-verification01.json) binds all13 payloads,5749 critical inputs and344 protected physical paths. Result archive5747132bytes, SHA256`1b306237f3f8edebfddd23753cab0a9777f1db725d92e0e0324e2f12be990834`. Native final snapshot is from completed CAPS01fit01 archive`4807b92fdc0cf84ef015c566e9f77a350f1fd91e6f59fa7d9a80da553824f5cb`; original fit tree preserved.

Prepared STA runner's copied-QSF before-count takes fit_parallel_processors36 instead of assuming the earlier2CPU fit. Actual copied QSF changes only two execution-check file assignments, not clock/SDC/RTL. Fresh affinity36 and QSF36,64GiB AS cap. Native max24 and warning20031 reporting18 system processors do not establish36effective workers.26exact runtime-output roles include native runlog.db;5503precopy records include97PID-qualified immutable clearbox files. All source/generated/release records remain bound; ready_for_build false.

## Constrained timing observations, not full signoff

[Domain records](sta-domain-timing-records01.json): **645/645 nonnegative**,129percorner over five corners, all TNS0. Seven domain cells are exactly0.000, not positive margin. Minimum reported setup+0.216ns, hold0.000ns, recovery+0.242ns, removal+0.140ns, minimum pulse width0.000ns. Same complete domain-key set as priorCSR02. EMIF0-core slow setup domain minima are+0.319ns and+0.332ns (previousCSR02+0.375/+0.398); these are domain minima, not matched path endpoints. No frequency reduction/false path/timing waiver. All81clock-property rows and200/100requested/selected user-clock output match priorCSR02. Bank-core timing is not measured by user-clock200/100.

Native [panels](sta-native-panels01.json) report **TimingClosurePASS; DesignClosureFAIL**.22/88 enabled signoff rules fail:7High/7Medium/8Low,zero waived. Native Info22360 at sta.rpt line215637 says10rules disabled. Unconstrained2inputs/78pairs and2outputs/10pairs remain. Missing report categories, SDC/CDC/reset/exception coverage and all prior lifecycle/physical limitations remain unwaived. [Warning ledger](sta-warning-ledger01.json):380occurrences, native footer0errors/380warnings.

Source/unit, fit, STA domain summaries and detailed source-equivalent paths remain separate gates. Default reports do not establish all-bit/source-cycle mapped equivalence, reset adequacy or complete path coverage. No new defect is inferred merely from that limit. Reset additional-cycle and BMC/PR findings from completed fit remain. SynthesisQ1–Q4/R1/R2 remain; new raw capabilities leave legacy metadata unqualified. No assembly/GBS/physicalPR/hardware/DDR/OPAE/durable-boot acceptance.
