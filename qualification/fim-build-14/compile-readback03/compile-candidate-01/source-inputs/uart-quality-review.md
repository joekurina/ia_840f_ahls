# Quality review 01 — APPROVED

**APPROVED for the minimal UART-absent source correction and its bounded static evidence.** No blocking or nonblocking defects requiring changes were found. This is an independent quality review, not parent acceptance or task completion.

## Exact review binding

Root `N`: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Paths below are relative to N unless stated otherwise.

- Spec prerequisite: `qualification/dfl-uart-fix-02/spec-review01.md`, verdict PASS, SHA256 `d1d9d87e0e08fb2f1fe24ce400dbfd33c9ed37fb8e3f535899741eaff225cf96`.
- Review manifest: `qualification/dfl-uart-fix-02/review-inputs01.json`, SHA256 `737cd5de8639ec44072c3a129814ea5287c9de21c6761f7c6a41e7c7375fb164`.
- Independently verified all **22 entries**, with 22 unique paths, for exact size and SHA256. Rechecked before writing this report: all 22 still matched; manifest and spec-report hashes were unchanged.
- Corrected `ofs-agx7-pcie-attach/src/board/ia840f/afu_top.sv` SHA256: `df74b8e8e04408f2009f398444c5375c0e6ed66fa01452e8f594dfe2712fd60c`.

## Findings

**Blocking: none.**

1. **Minimal, maintainable correction.** The independent original/candidate diff agrees with `uart-only.diff`: only `uart_dummy_csr` FEAT_ID at line 747 changes from `12'h24` to `12'h0`. Complete-file equality against the hash-bound original proves preservation of all other bytes, including the optional real-UART branch, revision, generated next-offset/EOL expressions, clocks/reset and master tie-offs. The vendor disabled branch explicitly uses ID zero (`vendor/afu_top.sv:620–630`, relative to this report). No shared dummy-module change or fabricated UART metadata was introduced.
2. **Checker is appropriately narrow and fail-closed.** `tests/ia840f/uart_absent/check_source.py:19–36,67–90` uses explicit exceptions rather than optimization-removable assertions, pins the original complete file, requires a unique replacement and verifies seven reference inputs before reporting PASS. It reads ordinary files only; no subprocess, simulator or device operation is present. Its literal macro checks and captured APF-link checks match the advertised static scope, not a general Tcl/RTL evaluator or full DFL walk.
3. **Evidence claims are truthful within scope.** Recorded before/after receipts agree with independently reproduced results. `REPORT.md:17,27–31` distinguishes static evidence from runtime qualification and explains the research report's pre-edit ID-0x24 observation. The inspected driver matcher uses GUID **or** type/ID matching, consistent with `driver-id0-research.md`; the report correctly retains possible generic DFL resource enumeration rather than promising universal driver immunity.

**Nonblocking: none requiring changes.** The exact-byte checker is intentionally snapshot-specific; its limited parser and captured-link coverage are documented boundaries, not reasons to expand this user-requested one-token review.

## Independently executed verification

From `/home/joe`, using absolute checker/source paths:

| Invocation | Observed result |
|---|---|
| `python3 -B <checker> --source <captured-W13-original>` | rc1; expected old-ID rejection |
| `python3 -B <checker>` | rc0; PASS, seven reference inputs |
| `python3 -O -B <checker>` | rc0; identical PASS output |
| Scoped `git diff --check HEAD -- src/board/ia840f/afu_top.sv` | rc0 |

`<checker>` is `N/tests/ia840f/uart_absent/check_source.py`; `<captured-W13-original>` is `N/qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13/src/board/ia840f/afu_top.sv`. The source-delta conclusion rests on the bound original/candidate comparison, not an assumption about the current Git baseline.

## Limits

No dummy-CSR simulation or functional exercising, compilation/build, timing analysis, remote access, installation, OPAE/device/sysfs/MMIO access, deployment or git writes occurred. The separate Work14 lane was not inspected. Compilation, timing, deployment and hardware behavior are **not qualified**. Existing hardware/recovery restrictions are unchanged. Only this named quality-review report was written; source, manifests, bound reports and unrelated files were not modified.
