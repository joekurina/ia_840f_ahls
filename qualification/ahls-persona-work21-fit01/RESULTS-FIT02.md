# Actual Work21 AHLS persona — completed fit02

**Native fitter completed successfully; independent bounded-result acceptance pending.** This is not STA, functional, reset/PR or hardware acceptance.

## Native result and provenance

- Native/effective/outer **0/0/0**, `success=true`, no timeout, descendants or surviving owned group; no postflight errors. Started2026-09-23T15:20:28.655108Z, ended2026-09-23T16:41:54.011294Z. Native elapsed **01:21:23**, peak virtual memory **24,234MB**. [Receipt](outer-fit02.json), [native log](artifacts-fit02/fitting.log), [parent acquisition verification](parent-capture-verification-fit02.json).
- Quartus **25.1.0 Build129 SC Pro**, Agilex7 **AGFB027R25A2E2V**, top `top`, project `ofs_top`, PR_IMPL revision `ofs_pr_afu`. The native command is `quartus_fit --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu`. [Summary](artifacts-fit02/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.fit.summary).
- Archive SHA256 `ff6e3e6a5a92b41e655900862638ca03bb89751ae561e8b6cdeb74db8e4c4aab`; **18/18** embedded files rehashed against decoded files. Exact reconstruction of **4,512 immutable bindings**, with all setup/release/tools/bound-input preservation flags true. [Parent verification](parent-capture-verification-fit02.json).
- Fresh copy of completed synth01; no resynthesis and no interrupted fit01 database reuse. Prelaunch **5,639 entries**, runtime mutable-role exclusions **1,399**, protected synthesized/partitioned entries **67**. Retain the predecessor's native/effective/outer5/5/5 OOM. fit02 changes only fresh run/authority paths and finite per-process cap16GiB→32GiB, with CPUs0–1 and80GB minimum available-memory precondition. [Exact delta](source-delta-fit02.json), [failure](FIT01-FAILURE.md). Original SCOPE.md's16GiB describes fit01, not fit02.
- Final native database committed. **722 QDB file entries** captured by size/hash, including284 paths under `/final/`; raw QDB contents remain remote, not independently inspected locally. Intermediate snapshot retention is Off: no claim of preserved routed or retimed snapshots. [QDB inventory](qdb-output-inventory-fit02.json).

## Physical partition and resources

The native **Fitter Partition Summary** reports imported `root_partition` preservation **final** from `ofs_top.qdb`, `auto_fab_0` final, and nonempty **Reconfigurable green_region**. Logic Lock Constraints and Usage retain the named AFU region with real utilization. This narrows interpretation of the inherited20580 and current15706 warnings; it does not prove runtime PR compatibility. [Exact panels with original line numbers](native-panels-fit02.json).

Whole-design resource report: **124,781 ALMs needed**, **106,524 ALMs used in final placement**, **263,456 dedicated logic registers**, **469 M20Ks**, **321 pins**. Region accounting separately reports **34,449.3 ALMs needed**, **39,980.0 ALMs used in final placement**, **96,752 registers**, **178 M20Ks**. Do not label whole-design totals AFU-only or round away the native fractional region estimates. [Native panels](native-panels-fit02.json).

## Warnings and unresolved acceptance gates

**166 warning occurrences, matching footer166; six Critical Warning occurrences.** [Full line-numbered ledger](warning-ledger-fit02.json):20727×5,18502×17,15714×1,332174×40,332054×41,332049×58,332158×1,15705×1,15706×1,171167×1.

- **PR dangling inputs:** this actual-persona report lists **46**, not the historical static template's1,076: four clock inputs, both banks' nine-bit BID/RID plus one-bit BUSER/RUSER, and two debug inputs. The clocks, metadata reconstruction and unused debug semantics require matching-source dispositions; a smaller count is not safety acceptance.
- **BMC pins:** the I/O Assignment Warnings panel names `bwbmc_bmc_irq`, `bwbmc_bmc_mst_en_n`, `bwbmc_fpga_max_miso`, each missing termination and slew-rate settings. Do not invent electrical constraints.
- **Constraints:**17 SDC assignment differences from the imported base, ignored filters/skew constraints, overwritten clocks/I/O delays and missing collections remain unwaived. Some literal exported SDC selectors reference predecessor scalar-AFU hierarchy (`ahls_binding|board`), not this candidate's `core`/page-shim structure. Source/effective STA analysis must distinguish stale inherited selectors from active-path coverage; fit0 is not proof of correct constraints.
- **Ignored assignments:**1,098 rows in the native panel:18 programmable de-emphasis,1 global signal,4 periphery→core Hyper-Register,502 delay-chain,500 core→periphery Hyper-Register and73 synchronizer identification. The counts are not waiver decisions. [Exact panel](native-panels-fit02.json).
- Both DRC reports and all synthesis reports in this archive are **byte-identical copies from synth01**, not new fitter DRC passes. [Per-output provenance](output-provenance-fit02.json). Native logs say Design Assistant had no enabled rule for plan/place/finalize. Prior5/13 synthesized failures and7 disabled rules remain inherited limitations.

**Next safe gate:** exact-source-bound STA on an isolated copy of the completed final database, preserving current clock/constraint intent and reporting numeric timing AND coverage/CDC/reset/exception gaps. First consume the bounded fit review; no unchanged fit/synthesis rerun. No assembler/GBS or deployment occurred. Candidate UUID `673c03a1-cef3-4c82-bf10-b12c247d9718` remains not deployed. Vendor DDR simulation SKIPPED BY USER; all physical FPGA Tests remain gated.
