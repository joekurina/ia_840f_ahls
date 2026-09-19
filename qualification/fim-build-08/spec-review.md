# Independent Work08 specification review

## Verdict: SPECIFICATION GAP — do not advance to quality review yet

The BTI correction itself matches the original IA840F source. One required timing-scope justification is missing: replacement of the complete Ethernet SDC also removes an unqualified, non-HSSI-hierarchical oscillator exception. This is not evidence of a fitter failure, but prevents an unconditional specification PASS under the explicit requirement to establish that no needed non-Ethernet constraints were dropped.

## Independent verification

Reviewed captured source bytes and inventory hashes, not the implementer's consumed-review verdict. All 21 files in `remote-evidence-sha256.json` match their recorded SHA256 values. Each of the six candidate files matches `remote-evidence/overlay-sha256.json`. Reversing every `candidate.patch` hunk in memory reconstructs the exact `source-before.json` hashes (and absence of the new SDC). Thus the patch really is the captured remote Work07→Work08 delta, not a comparison against potentially stale local source.

Comparing the Work07 and Work08 captured authorization source inventories across all five trees yields exactly these six changed paths and no others. The 135 captured native contexts compare exactly after substituting the Work07 work-directory component with Work08. Gate code changes in `candidate.patch:61-91` are limited to the documented retarget/comment; there is no widened context policy.

Vendor-excerpt SHA256s independently match the original report/archive values for top.sv, top_loc.tcl and eth_top.sdc. Local supplemental source files used below (shared eth_top.sdc, shared top.sdc, IA840F base QSF, PR QSF and PR source list) were individually hash-matched to the Work08 captured source inventory before relying on their contents.

## Source-correct portions

Paths below are relative to `ofs-agx7-pcie-attach/`, or to the explicitly named qualification directory.

- `src/board/ia840f/top.sv:44-46` restores the unconditional input outside INCLUDE_HSSI, matching `qualification/fim-bti-clock-01/vendor-excerpts/src/top/top.sv:30`. No full Ethernet subsystem is enabled.
- `syn/board/ia840f/setup/top_loc.tcl:97-105` preserves positive CC19, negative BW19, DIFFERENTIAL LVPECL, enable_term, disable_3p3v_tol, enable_hyst, 156250000 Hz, powerdown=false and BTI TRUE. Vendor locations/electrical settings are at captured vendor `syn/setup/top_loc.tcl:105-106,254-262`. Uppercase modern BTI spelling is deliberately sourced from the captured Work07 diagnostic, not asserted equivalent to historical lowercase bti.
- `syn/board/ia840f/setup/bti_refclk.sdc:2` reproduces the vendor 6.400 ns period and 0/3.200 waveform. `syn/board/ia840f/syn_top/ofs_top_sources.tcl:63-66` replaces rather than adds to the Ethernet SDC include, so this source-list change does not itself create a duplicate qsfp clock.
- Base QSF `syn/board/ia840f/syn_top/ofs_top.qsf:11,20,103` retains AGFB027R25A2E2V, PRESERVE_UNUSED_XCVR_CHANNEL ON, and disabled INCLUDE_HSSI. The exact six-file inventory delta leaves PLL configuration (core470/seven outputs), PCIe P-Tile Gen4x16/PF/BAR contracts, DDR configuration and whole channel map unchanged from Work07. This is preservation evidence, not fresh functional qualification of inherited contracts.
- No new PR source-path gap was found: `syn/board/ia840f/syn_top/ofs_pr_afu.qsf:94-95,111-121` imports the base `ofs_top.out.sdc` and QDB, rather than directly reloading the base physical clock SDC. A future qualified base export remains required; none is claimed here.

## Blocking evidence gap S1 — scope of removed oscillator exception

`candidate.patch:47-53` / `syn/board/ia840f/syn_top/ofs_top_sources.tcl:65` removes the shared Ethernet SDC wholesale. The hash-verified removed file, `syn/shared_config/eth_top.sdc:17`, also contains:

```tcl
set_clock_groups -exclusive -group  {get_clocks ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk}
```

Unlike the HSSI hierarchy-specific constraints at lines 18 and 22-35, this exception is not scoped to hssi_wrapper. The original vendor Ethernet SDC contains the same exception at line 21. The new `bti_refclk.sdc:1-2` retains only the external reference clock. No matching oscillator exception was found elsewhere in the inspected source SDC/Tcl/RTL/QSF files. `syn/shared_config/top.sdc:43-52` contains other clock-group exceptions, not this one.

**Concrete risk:** if Quartus inserts this oscillator for preserved transceiver resources or another retained function, deleting its exception changes non-Ethernet timing analysis, potentially introducing invalid cross-clock paths or changing timing qualification. Source absence cannot establish absence of a tool-inserted clock. This review does NOT assert the exception is definitely required, nor recommend blindly retaining its inherited syntax.

**Needed to close:** source/tool-backed evidence that this exact exception is inapplicable to the no-HSSI preservation configuration (or that equivalent constraints are supplied elsewhere), or a separately reviewed correction preserving any required non-Ethernet semantics. A bounded read-only clock/constraint report from the already monitored run can resolve applicability when available; do not restart or interfere with that run. The implementation report's claim of a clock-only replacement does not supply this justification.

## Boundaries

Fitter acceptance of the modern BTI key, elimination of Error 21636, timing closure and assembly remain UNPROVEN in this specification review. Captured running status is historical evidence, not a fresh runtime observation. Readiness and functional acceptance remain false. DDR simulation remains SKIPPED BY USER. No remote connection, build, simulation, gate execution, source edit, process control, programming, commit or readiness modification was performed. Only this new independent review artifact was created. The implementer's self-review was not accepted as independent evidence.
