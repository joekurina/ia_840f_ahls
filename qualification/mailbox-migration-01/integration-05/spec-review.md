# Integration 05 — independent specification review

**PASS — no integration specification gaps found.** This accepts the minimal maintained-source integration, not full BSP/build/hardware readiness or a new execution authorization.

## Verified evidence

Local read-only Python SHA-256, JSON and XML comparisons independently established:

- Both maintained files are byte-for-byte equal to the UTF-8 payloads in `../monitored-refresh-02/result-evidence.json`, independently accepted by `../monitored-refresh-02/output-review.md` (disposition and hashes, lines 5 and 13). Their hashes also equal generation05's `before.json` and `after.json` inventory entries:
  - `bwbmc/bmc_spi_sub.qsys`: `e3571b6d6b0e04bcc488be3c0a309571c2ccb6a0564c530f43b41dabe4cfd82a`
  - `bwbmc/ip/bmc_spi_sub/sdm_mailbox.ip`: `b6b28be4555938f513102b9a32ac99dc40a61083bb6b063c8f2c20b03e54a8c6`
- All 36 pre-existing generation05 inventory entries are identical afterward. Its captured leaf, child and parent results each report `returncode=0`, `exception=null`, `errors=[]`, and readiness false. Recomputed all payload hashes: refresh02 **9**, generation05 results **12**, generated-source evidence **12**.
- All **32 other BMC files** match both the before-manifest hashes and generation05 input hashes. The maintained BMC tree contains exactly these 32 files plus the two accepted replacements, with no extra generated artifacts. The enclosing parent and sibling IPs remain unchanged; parent03 broad upgrades were not integrated.
- Manifest comparison against `before/syn/board/ia840f/source_manifest.json` finds exactly two changed file entries and the new scoped `mailbox_migration_integration_05` object. The remaining **97 entries** and every other top-level field are unchanged. Original donor `source`/`source_sha256` fields are retained, `prior_sha256` equals the before hash, readiness remains false, and blocking requirements/execution policy are unchanged. Current files checked against manifest entries have no hash drift.
- Both before payload copies match their original donor bytes. Every receipt-listed current/before hash, evidence artifact hash, report hash and before-copy hash recomputes correctly, including manifest before `022bb28deac0cccd1e918192faa1ba3cb151e0d13b3444be7852e9ea77e49538` and current `a56ceb0a6adcfd8317583d58329d52f9ebcad89d8cf50b95ff3b9cc4a1591b3f`.

## Report claim checks and scope

`report.md` accurately distinguishes accepted saved-state correction, historical generation evidence and unestablished full qualification. Direct XML comparison confirms 17 child modules, 46 connections with unchanged kinds/endpoints and all pre-existing connection parameters, and all 16 original mailbox parameter values retained with only `AUTO_BOARD=default` added. Exact accepted-payload equality and the independent refresh review support the described interface/metadata correction.

Inspection of generation05's hash-verified generated-source payloads confirms the parent AXI address/data declarations remain 17/64 bits, the child mailbox output and interconnect waitrequest input share `mm_interconnect_2_sdm_mailbox_avmm_waitrequest`, and the separate SDM reset is exported through the parent and routed through the child's `sdm_reset`. These are captured-output observations, not a new vendor run or hardware proof.

“Other sources retained original” means the pre-integration maintained baseline, not that every source is verbatim legacy: `irq_generator.v` already had a documented vendor-derived modification in the before manifest. Its before/current/generation05 hashes agree; this is not an integration05 change or gap.

The parent's separately identified gate WORK path03-to-path04 and test expectation changes are outside this worker's integration scope and are not classified as scope creep. Git alone cannot prove this integration delta because the board directories are untracked; the before snapshots, original provenance and historical inventories supply the comparison basis.

No source, test, authorization or existing evidence was edited by this review. No remote/vendor/build/test execution or commit occurred. The sole new file is this report. Quality review, fresh source binding for subsequent gated execution, and full BSP/hardware qualification remain separate follow-up work; continuing user approval is not in question.
