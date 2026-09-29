# IA-840F HLS 2026.1.0 LSU family compatibility overlay

This narrowly scoped configuration fix supplies the actual **Agilex 7** family to two legacy `lsu_bursting_read` instantiations in the HLS support RTL. It does not change the tutorial C++, arithmetic, interfaces, timing constraints, simulator primitive models or installed SDK. The source hash and exact part are checked before creating an owned output file ([CMake preparation](CMakeLists.txt), [two-line patch](lsu-family.patch)).

## Why it is needed

In the inspected HLS IP Gen 2026.1.0 source, `lsu_top.sv` does not set the `DEVICE` parameter at its two legacy bursting-read call sites. The child defaults to `Stratix V`; that value reaches its wrapped SCFIFOs. The installed Pro simulator library rejects that family value, producing six `Error! Unknown INTENDED_DEVICE_FAMILY=Stratix V.` messages in each affected integer tutorial even though the original numerical checks pass.

The correction passes `.DEVICE("Agilex 7")` at the call sites. This is an explicit instantiation parameter for our actual FPGA family, not a change to the vendor primitive implementation or a diagnostic-suppression flag. Only those two source lines are added. The original failure evidence is retained in the [baseline diagnostic disposition](../../../../qualification/ahls-getting-started-01/diagnostic-disposition13.json).

## Supported input

- Exact part: `AGFB027R25A2E2V`.
- Original HLS support source SHA256: `873549f18428fe6ba0797fef228c2028bf1df62076e85f1942c9dca5310cf8a0`.
- Prepared overlay SHA256: `cfee3826587686ddc36919ac18db973c620f72bfd8f555ab2f3622b19b21d333`.

A different compiler source or FPGA part is rejected. Do not bypass that check for another release; first determine whether the newer compiler already fixes the issue or needs a different, source-reviewed correction. Wrong-part and changed-source rejection were exercised without generating an overlay ([preparation checks](../../../../qualification/ahls-getting-started-fix01/prepare-validation05.json)).

## Prepare before entering the compiler namespace

Use the repository root and a fresh owned `WORK` directory from the [GettingStarted setup guide](../../README.md). The installed source path below is the recorded workstation path. This CMake project performs file preparation only; it does not run Quartus, HLS or a simulator.

```bash
export SDK_LSU=/home/uwb_student00/ahls/altera_hls/aclsycl/ip/lsu_top.sv
cmake -S "$REPO/examples/ahls/compatibility/lsu-family" \
    -B "$WORK/lsu-overlay" \
    -DFPGA_DEVICE=AGFB027R25A2E2V \
    -DAHLS_LSU_TOP="$SDK_LSU"
sha256sum "$SDK_LSU" "$WORK/lsu-overlay/lsu_top.sv"
```

The first hash must remain the original value above and the second must equal the overlay value. **Never copy the overlay over the installed SDK file.** Add this read-only bind to the existing isolated compiler-shell command, after its root bind:

```text
--ro-bind "$WORK/lsu-overlay/lsu_top.sv" "$SDK_LSU"
```

Only that private namespace sees the corrected support input. Outside it, the SDK stays unchanged. Follow the normal environment initialization and original CMake commands in the setup guide. The native verification additionally checks that the compiler-generated project copied the exact overlay bytes before running the test.

Use a **fresh build directory** for the first corrected simulator build. The upstream `-reuse-exe` mechanism can retain an existing device image; do not point the first corrected build at an older executable containing the uncorrected support RTL. Preserve the old build rather than deleting it. Subsequent host-only recompiles can reuse the already corrected image normally.

## Verification and scope

Fresh corrected builds/runs of `fpga_template` and `fpga_compile` PART2, PART3 and PART4 each returned native exit 0, passed all 256 original integer comparisons, and had zero Error/Fatal diagnostics in the complete simulator transcript. Each previously emitted six family errors. All original imported source bytes remain unchanged ([corrected simulator verification](../../../../qualification/ahls-getting-started-fix01/simulator-verification14.json)).

Other warnings, including the selected HLS 2026.1 / Quartus 25.1 compatibility warning, are retained. This workaround is empirically verified for the stated setup; it is not a claim of vendor-supported mixed-version compatibility or warning-free operation.

## Timing is a separate correction to the assessment

The HLS handbook explicitly documents that the standalone hardware flow intentionally uses a **1000 MHz** optimization constraint and is not expected to close it. Read the component Fmax from `reports/resources/quartus_data.js` / the FPGA Optimization Report Clock Summary. Do not rebuild just to make that characterization constraint pass, or infer a programmed card clock from its generic PLL-adjustment wording ([handbook quotation and actual reported Fmax](../../../../qualification/ahls-getting-started-fix01/timing-interpretation07.json)).

The old vendor BSP supplied a complete board-targeted runtime and selected valid user-clock frequencies after fitting. The current AHLS standalone flow produces IP for later OFS/PIM integration; it does not recreate that old SYCL board executable by itself. Actual integrated timing and on-card execution remain distinct from the compiler/simulator correction ([vendor baseline comparison](../../../../qualification/ahls-getting-started-fix01/vendor-baseline11.json)).
