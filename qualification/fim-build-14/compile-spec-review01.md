# Work14 compile package — independent SPEC review 01

**Verdict: PASS. No blocking SPEC gaps in the reviewed package.**

This is a compile-package review, **not authorization, quality approval, parent acceptance, build/timing acceptance, or deployment approval**.

## Exact binding and scope

Reviewed the actual local mirror `compile-readback03/compile-candidate-01/`, corresponding to remote `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/compile-candidate-01/`; not the earlier incomplete draft directory.

- Manifest: `review-package-sha256.json`, SHA256 **`d6323f8f243d1fceefb233680fa851a25676889b761348b0760de23b3602dc8b`**.
- Independently rehashed **14/14 entries**, all matching; manifest paths are relative and traversal-free, and listed files are not symlinks.
- Scope remains native full compile of IA840F, part `AGFB027R25A2E2V`, Quartus Prime Pro **26.1.1 Build 130**, fresh `work_ia840f_fim_14`, using the existing OFS flow.

## Verified findings

1. **Accepted UART delta only, apart from gate retargets.** The complete recorded SOURCE inventory has 1,361 entries. Symmetric old/new comparison against W13's issued record proves exactly three changed files, with no additions/deletions: `afu_top.sv` and the two gate files. All three original backups match the old pins; draft SOURCE, `source-after.json`, integration receipt and delta report agree. UART bytes differ only at `.FEAT_ID (12'h24)` → `(12'h0)` in the disabled branch. Corrected hash is `df74b8e8e04408f2009f398444c5375c0e6ed66fa01452e8f594dfe2712fd60c`. Packaged UART acceptance/spec/quality reports match the accepted originals. PIM's 530 pins are unchanged. No timing, clock, DDR, PCIe, reset, BMC or other functional change is bundled.

2. **Fresh inputs, not a recycled fit.** Draft WORK exactly equals `prepare-readback02/work14-prepared-inventory.json`: 5,424 entries, including nine internally targeted symlinks. Its key set equals W13's recorded precompile input set; no `db`, `qdb`, `output_files`, `incremental_db` entries or `.qdb` files are included. Comparison with current W13 input readback gives exactly two symlink retargets plus three overlays. The preserved first rejection and successful follow-up receipts agree. Independently hashed before/after metadata bytes establish only the documented FME UUID replacements and QPF date/revision ordering changes. Inherited metadata is an initial input, not a new image identity or old-persona compatibility result. W13 preservation is supported by the preparation receipt, not newly measured remotely by this reviewer.

3. **Finite native scope and correct successor paths.** Actual diffs against W13 candidate-02 show path-only gate/runner retargets and the bounded issuer lineage update. AST parsing and local inert gate/issuer imports passed; C/W/P definitions are intact. Recomputed `allowed_commands()` exactly matches all **135** draft contexts, with Work14 project cwd and finite 26.1.1 executable paths. Entire contexts, including hashes, equal W13's table modulo the Work13→Work14 path substitution. Native argv is `build_top.sh --stage=compile -k -p ia840f <Work14>` from SOURCE; the inner flow remains `quartus_sh --flow compile ofs_top -c ofs_top`. No setup-only, simulation or deployment substitution.

4. **Pins and fail-closed evidence are consistent.** All **483 inherited dependency pins** remain unchanged; all **seven added pins** were verified against local mirrored files (490 total). Tool maps match W13. Actual Work14 inputs are bound separately from the historical `postheader_inventory_sha256`. The retained nonconsuming issuer preflight reports PASS against this exact manifest. Four separately retained rejection receipts match `missing-record-checks.json`: actual Work14 dispatcher, native top guard, native child guard and Tcl helper each returned rc1 for the missing Work14 authorization. Receipts state no native log/claim/run and unchanged SOURCE/WORK. These remote receipts were checked locally, not re-executed.

5. **Review/launch boundaries remain intact.** All draft approval/consumption/readiness flags are false; permission is only `native-full-compile`. Issuance requires matching fresh spec and quality reports, quality binding the spec report, and explicit parent consumption before exclusive writes. Runner/gates retain exact inventories, tool/dependency checks, native ancestry, exclusive run/claim semantics and raw native-status persistence. Native exit zero remains separate from fit/assembly/timing and functional acceptance. W13 timing is not accepted by inheritance.

## Nonblocking qualifications

- The delta report's “SOURCE currently untouched” text describes preparation state; the manifest-bound integration receipt and complete post-integration inventory supersede it.
- The inherited issuer lineage loop does not itself enumerate deleted old keys. The independent symmetric comparison above verifies zero deletions in this exact package, and live inventory equality remains enforced. This is not a blocker for these bound bytes.
- No remote access, vendor execution, hardware/OPAE access, simulation, authorization issuance or parent acceptance occurred in this review. Only local reads, hashes, JSON comparisons, AST parsing and inert imports were used; no issuer preflight/main/issue or runner was invoked. DDR simulation and dummy-CSR exercising remain excluded. Any later flash/reboot permission does not enlarge this package or establish independent host recovery.

Only this review file was intentionally written. Fresh quality review and parent consumption remain outstanding gates; any package-byte change requires a new binding/review.
