# Actual Work21 AHLS persona — fitter stage

Run the native Quartus 25.1 fitter only on a fresh exact copy of the completed actual PR-context synthesis. Do not rerun synthesis or change RTL, clock requests, signoff constraints, static QDB, pin geometry, or the inherited optimization settings. Preserve original mapping/setup/release/tool files. No assembly/GBS, programming, device access, drivers, reset or reboot. Vendor DDR simulation SKIPPED BY USER.

All 5,639 copied source/database/report paths are hash-bound before native start. The callback keeps 67 partitioned/synthesized snapshot paths and immutable source/static inputs bound, while excluding the explicitly enumerated 1,399 copied stage-owned output paths from runtime immutability. Native output mutation is recorded, not mistaken for an RTL change. This is normal-account, source-bound execution, not an OS sandbox or aggregate-memory guarantee.

Native command: `/opt/altera/25.1/quartus/bin/quartus_fit --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu`. Two-CPU affinity, 16GiB address-space limit per process, 10,800s deadline, owned-group cleanup. No post-flow packager or live operation is called. Original QSF and release callback remain preserved; the candidate points to a fresh fit-only callback with exact runtime identity and live runner ancestry.

Native synthesis's 20580 warning is retained alongside its Reconfigurable partition table, not 'fixed' through a guessed assignment. The actual fitter will establish physical partition behavior. PR initial values, dangling inputs, reset/CDC, active LSU/RAM mapping, timing/coverage and hardware obligations remain open; native fit0 alone would not clear them.
