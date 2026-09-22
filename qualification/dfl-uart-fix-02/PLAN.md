# UART-absent vendor convention — source correction plan

## Authority and scope

Joe explicitly selected keeping UART absent, then directed: “We should follow the convention of the old vendor BSP's feature scope as it pertains to the UART. Continue Working.” This resolves GOAL-PROMPT.md §A.3's scope decision. The accepted diagnosis in [fix-01](../dfl-uart-fix-01/REPORT.md) remains immutable history; its scope-blocked status is superseded by this decision, not by a live-fix claim.

The parent implements. Independent reviewers may inspect ordinary source/evidence and run inert local tests. No FPGA devices, native OPAE, PCI/sysfs probing, system-rule activation, driver changes, programming or recovery actions are in scope here. DDR simulation remains SKIPPED BY USER. Existing W13 and persona artifacts remain unchanged.

## Exact proposed source delta

Target: `ofs-agx7-pcie-attach/src/board/ia840f/afu_top.sv`, the `uart_dummy_csr` instance selected when `INCLUDE_UART` is absent. Original complete-file SHA256:
`67c43a85a93c23c851a5f1136b05c1467bd541ab5bedb6da373af7d9d87d3bdc`.

Change only its explicit `.FEAT_ID (12'h24)` to `.FEAT_ID (12'h0)`. Keep the real-UART branch, FEAT_VER, generated NEXT_DFH_OFFSET/EOL expressions, clocks/resets, fabric decode, master tie-offs and every other byte unchanged. Keep `INCLUDE_UART` and `INCLUDE_HPS` absent. Do not change the common dummy module or any driver.

Vendor precedent (read-only root `../old_bsp/ia-840/IOFS_BUILD_ROOT/` relative to the project):
- `ofs-ia840f/src/afu_top/afu_top.sv:620–630`: disabled UART uses ID 0, revision 0, next offset 0x10000, EOL 0.
- Standard and USM `oneapi-asp/ia840f/hardware/{ofs_ia840f,ofs_ia840f_usm}/build/ofs_top.qsf:101–102`: UART and HPS assignments commented out.
- `ofs-ia840f/src/top/top.sv:719–752`: optional host↔HPS UART connection; not an active IA840F requirement.

The local maintained file, captured remote maintained file and captured W13 file were verified byte-identical before implementation. This does not establish fresh remote SOURCE parity; independently recheck remote ordinary source before integration/build.

## Narrowed offline validation — user correction

After this plan was written, Joe explicitly said exercising the dummy CSR logic is unnecessary. **Do not simulate or functionally exercise the dummy CSR.** No RTL simulation ran. An isolated Debian Verilator package was downloaded/extracted in local scratch before the correction; no system package was installed, and that tool is not needed for this milestone.

1. Preserve the existing 12-test diagnosis/metadata suite unchanged; do not expand it into dummy-register behavior tests.
2. Add a compact source-delta check under `tests/ia840f/uart_absent/`, binding original/corrected source, vendor precedent and generated fabric constants.
3. Run the desired UART-absent source check against the original source and retain its expected nonzero result. It must reject the old UART ID 0x24.
4. Apply the one-token source change; run the same check against corrected source and require PASS.
5. Require full-file equality with the original except for the selected ID token. This preserves the real-UART branch, revision, generated next-offset/EOL expressions, clocks/resets, neighboring features, tie-offs and AHLS route.
6. Check UART/HPS remain absent from the captured W13 macros and disabled in the maintained board QSF and vendor standard/USM QSFs. Check the source-derived APF links still reach the UART slot and then the following port-gasket slot, without claiming a full DFL walk or hardware test.
7. Keep this iteration to the before/after check and exact source-delta comparison. Joe reinforced rapid progress toward AHLS/FIM/OPAE without workstation risk; no extra dummy-CSR test suite or new build framework is required.
8. Read the captured DFL driver classification/matching and ID-zero behavior independently. No executed kernel probe, HDL simulation or live result is implied.

## Acceptance and continuation

Bind exact changed source, fixtures, tests and receipts to a manifest. Obtain independent spec review, then quality review; fix important findings and rebind/review as needed. Parent acceptance is limited to the source/offline milestone. Update current checkpoint docs without rewriting bound historical reports. Commit/push the reviewed UART source gate with explicit paths, preserving unrelated prompt/ignore/crash-review changes, and read back remote main after push.

Then prepare a fresh source-bound FIM build for this actual RTL delta using the maintained native flow and existing reviewed gate patterns. Recheck source/tool identities, task ownership and resource headroom in the owned remote tmux session. Preserve old worktrees; do not reuse a consumed authorization or claim current timing success from W13. Generation, compilation, fit/STA and assembly results require their own evidence/review. Deployment and live DFL/OPAE qualification remain blocked behind their existing safety gates.
