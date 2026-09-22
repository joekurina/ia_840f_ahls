# Spec review 01 — PASS

**Verdict: PASS for the one-token UART-absent source correction. No blocking spec gaps found.** This is the first/spec review only, not code-quality review, parent acceptance, or build/hardware qualification.

## Reviewed binding

Root `N`: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.

- `review-inputs01.json` SHA256 independently verified as `737cd5de8639ec44072c3a129814ea5287c9de21c6761f7c6a41e7c7375fb164`.
- Machine-checked all **22 listed file hashes** with `sha256sum --check --strict`: every entry OK, rc0. Manifest entry count independently checked as 22.
- Original complete-file SHA256: `67c43a85a93c23c851a5f1136b05c1467bd541ab5bedb6da373af7d9d87d3bdc`.
- Corrected complete-file SHA256: `df74b8e8e04408f2009f398444c5375c0e6ed66fa01452e8f594dfe2712fd60c`.

Citation aliases below: `R=N/ofs-agx7-pcie-attach`; `W=N/qualification/source-resume-01/remote/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_13`; `D=N/qualification/source-resume-01/remote/home/uwb_student00/linux-dfl-backport`. Unqualified evidence paths are relative to this report.

## Spec findings

1. **Exact authorized delta, no extra RTL change.** `R/src/board/ia840f/afu_top.sv:747` changes only `uart_dummy_csr`'s `12'h24` to `12'h0`. Independently inspected `git diff HEAD` agrees with `uart-only.diff:5–13`. The rerun checker verifies complete-file byte equality to the bound original with only the unique selected token replaced (`N/tests/ia840f/uart_absent/check_source.py:14–36,67–76`). This preserves the real-UART branch, FEAT_VER, generated offset/EOL expressions, clocks/reset, master tie-offs, neighboring features, fabric wiring and AHLS route. The surrounding branch is visible at `R/src/board/ia840f/afu_top.sv:729–773`. Scoped tracked diffs show no changes to the common dummy module, board QSF, existing IA840F tests or fix-01 evidence.

2. **Vendor UART-absent scope retained.** `vendor/afu_top.sv:620–630` uses ID 0, revision 0, next offset `0x10000`, EOL 0. Both vendor QSFs disable UART/HPS (`vendor/standard_ofs_top.qsf:101–102`; `vendor/usm_ofs_top.qsf:101–102`). Maintained assignments remain commented (`R/syn/board/ia840f/syn_top/ofs_top.qsf:107–108`); neither macro occurs in captured W13 assignments (`W/syn/board/ia840f/syn_top/fim_project_macros.tcl:7–17`). This is a literal source/captured-macro check, not fresh Tcl evaluation.

3. **Generated local links preserved.** Checker PASS confirms ST2MM `0x40000` → UART slot `0x60000` → port-gasket slot `0x70000`, UART next `0x10000`, EOL 0 (`W/src/includes/fabric_width_pkg.sv:32–39,107–114`; checker:54–64). No full DFL walk is claimed.

4. **Driver rationale is appropriately limited.** Independent reads confirm private IDs are retained, including zero (`D/drivers/fpga/dfl.c:1064–1077,1286–1323`); private parsing has no ID-zero rejection, and traversal stops on EOL/zero next offset rather than ID zero (`dfl.c:1506–1524,1571–1587`). UART matches ID `0x24` or its GUID (`D/drivers/tty/serial/8250/8250_dfl.c:151–168`; `dfl.c:246–277`). This unchanged private DFHv0 dummy has no valid device GUID (`R/src/afu_top/dummy_csr.sv:12–17,197–211`; `dfl.c:398,433–434`; `D/drivers/fpga/dfl.h:513–520`). Generic enumeration/resource behavior remains possible; this is not universal driver immunity or live safety proof. `REPORT.md:27` correctly clarifies the research report's pre-edit ID observation.

## Independently reproduced checks

Executed only the local inert checker, from `/home/joe`, using its absolute path:

| Invocation | Observed result |
|---|---|
| `python3 -B <checker> --source <W/src/board/ia840f/afu_top.sv>` | rc1, expected old-ID rejection |
| `python3 -B <checker>` | rc0, PASS; seven bound reference inputs |
| `python3 -O -B <checker>` | rc0, same PASS |
| Scoped `git diff --check` for corrected RTL | rc0 |

These reproduce the claims in `before-check.json:8–11`, `after-check.json:8–10`, and `after-check-optimized.json:9–11`. No dummy-CSR behavior was exercised.

## Review limits

No native compilation, simulation, build/install, remote access, OPAE/device/sysfs/MMIO access, git writes or source modifications were performed. The parallel build lane was not inspected. Existing hardware/recovery restrictions remain unchanged. Compilation, timing, deployment and hardware operation are neither verified nor accepted here. Only this named spec-review report was written.
