# Independent specification review: IA840F PCIe CSR clock translation

## Decision: PASS (local source specification only)

The reviewed helper implements the requested IA840F-only translation of the donor's `100` request from `axi_lite_clk_freq_user_hwtcl` to `core16_axi_lite_clk_freq_user_hwtcl`. No implementation correction is required. This decision is not vendor execution authorization, generated-IP acceptance, or physical clock qualification. Shared gate/wrapper review is separate and was not duplicated.

Root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. All paths below are relative to this root.

## Exact source delta and identities

Reviewed actual helper `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_vendor_pcie.py`, SHA256 `8b89f1eba308d7b1de8a7a356604ded666e87a5b758a51337058f0fbf2204bc5`, and actual test `test_ia840f_pcie_csr_clock.py` in the same directory, SHA256 `aeadedc0a79cc5e578ac7e8493a2fd0436dd7d557ecc7c1b2e1e122729c72d61`.

The helper is untracked in the local nested Git repository, so an empty `git diff` is not evidence of no change. Independently reconstructed its pre-correction content in memory by removing only current lines 33–42. The resulting SHA256 is `cc03d11fb0a494667530ad9be1cdfcfb9fa05606cd3301a9340d292602072ab8`, exactly matching both `qualification/goal-initial-preflight/authorization-expected-sources.json` and the helper's `after_sha256` in `qualification/goal-initial-preflight/remote-reviewed-gate-deployment.json`. Thus the entire remaining helper is byte-identical to that recorded baseline; this establishes the narrow delta without relying on a nonexistent tracked-file diff.

That inserted block:

- Requires the hash-checked donor legacy clock to equal string `100` before mutating the caller's parameter dictionary.
- Moves that donor value to the supported port-0 key and removes the old key from effective parameters.
- Leaves the prior donor override update and subsequent `pcie_context(pcie)` invocation intact.

Existing non-IA840F early return, non-preset/component restrictions, two-PF/PF0VF0/PF1-no-VF restriction, donor SHA256 check and preset component-kind check remain unchanged. Gate exceptions still propagate. There is no generic unknown-parameter migration, change to another port's clock, or change to BAR2, IDs, PF/VF configuration beyond preexisting donor overrides. The actual call site remains `pcie_ip.py:273–274`.

## Independently checked provenance

Recomputed every file SHA256 in the correction report's source-evidence table; every entry matched. In particular, the preset remains `420f73c5c4bf1432ce39508f068bc381f4e4f2117a87a96940ca8500a93c876e`, and the derivation record remains `e58e146ea0ec90e1a2528ddffdba2553339f4168dadda0b109574844c41d2d06`.

Independently parsed the original XML rather than relying only on report excerpts:

- Legacy donor PCIe XML contains `axi_lite_clk_freq_user_hwtcl=100`.
- Decoded work02 PCIe XML in `qualification/ipgen-02/remote-deployed-ip-source-content.json` contains port-0 `core16_axi_lite_clk_freq_user_hwtcl=250`. Its recomputed SHA256 is `a41f8a7e4b2c54f4fb6720434994f305b2cc0f2cec4e9d0cec13e38c14e14341`, matching both the capture and `deployed-ip-scoped-parameters.json`. The latter explicitly records this value at component scope. Other saved port clocks are also 250; the legacy and child source-frequency keys are absent from the selected XML parameter records.
- Donor PLL and captured work02 PLL both request output 1 `100.0`, named `clk_100m`. Captured PLL XML recomputes to `80b62a76642038c38263bffa72e19ec6d2dc575e5ca4a75f51465e7a0f90b176`, matching both capture and scoped records. These are requested, not measured, frequencies.
- Local installed-source capture `reference/quartus-26.1.1-pcie/hwtcl/pcie_ss_parameters.tcl:1721` declares the port-0 field as INTEGER, default 250, range `{100:250}`. `pcie_ss_fileset.tcl:223,249` reads it and forwards it to `core16_axi_lite_source_freq_hwtcl`.
- Actual `src/board/ia840f/top.sv:300,514,590` connects PLL output 1 to `clk_100m`, then `clk_csr`, then the PCIe wrapper CSR clock. Actual `ofs-common/src/fpga_family/agilex/pcie_ss/pcie_ss_dm_top.sv:232` connects `csr_clk` to `p0_axi_lite_clk` (both under `ofs-agx7-pcie-attach`).
- Captured setup log line 316 explicitly warns that `axi_lite_clk_freq_user_hwtcl=100` was ignored. Line 287 separately warns that actual PLL output 1 differs from the requested setting.

The evidence supports preserving the donor request through a supported parameter name, not changing the PLL or asserting its output is exactly 100 MHz. Installed-source evidence is a local historical capture; no fresh remote/vendor query was performed.

## Local deterministic verification

Read the test module before executing it. It imports the helper and Python standard library, replaces the gate module in memory, and does not execute vendor tools.

Command, run from `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`:

```sh
python3 -B -m unittest -v test_ia840f_pcie_csr_clock
```

Independent execution result: **7 tests passed; exit status 0** (`Ran 7 tests in 0.046s`, `OK`). Coverage verified by reading assertions:

- Full effective dictionary equals the old donor-override result with only the legacy-to-port-0 translation; unrelated/other-port values and PF1 BAR2 are preserved.
- Gate observes corrected parameters and mocked denial propagates.
- Non-IA840F boards return without the normal source-read/gate path.
- Existing component/preset/PF restrictions reject without mutation.
- Preset hash mismatch rejects without mutation.
- Synthetic hash-consistent changed/missing donor clock rejects without mutation.
- Repeated application is stable.

The retained preset-kind rejection was also inspected directly; it is not a distinct test in this module. Mocked gate tests prove call ordering and propagation, not real authorization validity.

## Boundaries and follow-up

No source, preset, manifest, authorization, work02 artifact, or claim was edited by this reviewer. Only this review report was created. No remote operation, vendor execution, build, or commit was performed. Preexisting/concurrent repository changes were not attributed to this correction.

Before later deployment, the parent must complete its separate gate review and reviewed source inventory/rebinding; the previous helper hash no longer authorizes this source. Preserve work02 as historical evidence. Separately authorized vendor validation must confirm the corrected emitted command, saved parent value, child source-frequency value, and unchanged remaining PCIe contract. Actual PLL dividers/output frequency, generated SDC, tolerance compliance, timing closure, and hardware behavior remain unqualified.

Non-blocking documentation note: `pcie-csr-clock-correction.md:79` says the setup command excerpt is retained intact, but its displayed line 305 ends in `... [truncated]`. The complete log is available and hash-verified; use that file rather than the shortened display to establish absence of any parameter. This wording does not affect the implementation PASS.
