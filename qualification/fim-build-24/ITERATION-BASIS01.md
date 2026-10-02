# Work24 — exact EMIF1 clock-spine experiment

## Authority and objective

Joe explicitly directed: **“Let's proceed with the recommended next experiment. Request CLOCK_SPINE 2 on the exact EMIF1 global source.”** This authorizes one bounded offline native successor to Work23, not a blind seed/index sweep or hardware programming. It is the third full compile in the current migration budget, with seed3 unchanged. No further scope question is needed to execute this reviewed experiment.

The recommendation and supporting manual/native evidence are in [CPA investigation RESULT09](../cpa-implementation-01/RESULT09.md), particularly the [17-control evaluation](../cpa-implementation-01/03-clock-controls.md). The signal is matched to both generated source and native Fitter reports; CLOCK_SPINE is explicitly supported for Agilex7 in26.1.1 and the proposed2 lies within0–31. No new hidden CPA control, latency/uncertainty waiver, operating-point change or vendor RTL edit is introduced.

## Exact physical-setting delta

Baseline: completed, timing-rejected Work23 under Quartus26.1.1 Build130, seed3, AGFB027R25A2E2V. Work23 and Work22 retain the exact−0.004ns Fast vid2 100C EMIF1 bit243 hold failure. Passing Work21/25.1 used clock spine2; current Work23 uses1. This comparison motivates a physical dimension, not proof of causality or a promised repair.

New QSF appends exactly these two instance assignments:

```tcl
set_instance_assignment -name CLOCK_SPINE 2 -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]}
set_instance_assignment -name CLOCK_REGION "SX0 SY0 SX6 SY7" -to {local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_1|emif_1|arch|arch_inst|io_tiles_wrap_inst|io_tiles_inst|core_clks_from_cpa_pri_nonabphy[0]}
```

The CLOCK_REGION companion explicitly preserves the observed56-sector extent/root ownership and future PR clock access; it is **a second assignment record**, not a region shrink. The delta file is [clock-routing-delta01.qsf](clock-routing-delta01.qsf). The standalone Tcl fixture verifies literal argument parsing only; native eligibility/consumption remains a build-result obligation.

**Known risk:** current PCIe clocks use spine2 in overlapping sectors. Fitter reallocation or rejection is an honest experiment result, not permission to move board pins, change PR/static boundaries, choose another spine, increase timing margins or alter the constraint contract.

## Invariants and prepared implementation

- Fresh remote WORK: `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_24`; evidence: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-24`.
- Copy only the recorded3963 Work23 successor input entries; no inherited db/qdb/output_files/dni/incremental_db. Generated IP remains the qualified26.1.1 set; no IP source regeneration is needed for this physical-only trial.
- Preserve maintained SOURCE/PIM, Work21/Work22/Work23, existing programming images/static QDB, original SDC, four-line divider, fit-only10ps/STA-skip overlay, exact bit243 retiming-OFF, both DDR banks, PLL operating points, clocks and floorplan.
- Relevant3ns is the EMIF core/low-rate PHY operating point, not a requirement that every AFU clock run at333MHz. Inherited acceptance wording is retained, not used to retune any domain.
- Reuse the accepted native CMake entry, gate, runner and135 closed executable/argv/cwd contexts. Only fresh WORK/evidence roots change in gate/runner code. Generated text/link root relocations are recorded separately from the QSF experiment.
- Current preparation verifies original inputs,1891 SOURCE/PIM entries and four images/static QDB before/after; it issues **no** compile authority. Independent SPEC then execution QUALITY, parent consumption and fresh live revalidation precede one admission/launch.
- Existing supervisor limits remain unchanged, including10800s full-compile deadline and the recorded36-CPU affinity. Inspect the actual Fitter-reported internal CPU cap separately; do not conflate it with affinity.
- Local checks:16 synthetic gate cases,3 CMake checks,8 actual inert-child runner cases passed without native vendor execution. Remote preparation passed exact two-call Tcl parsing plus missing-authority/missing-manifest rejection; original states remained preserved.

## Actual-result acceptance

1. Require native execution completion and independently inspect diagnostics. A successful compile/assembly is not a timing pass.
2. Require the exact global source to consume spine2, retain the full region and root ownership, and have no ignored/illegal assignment. Confirm final routing as needed; Place-stage summary alone is not all final-route identity.
3. Compare both CPA COMP roles across corners, launch/feedback/data/capture terms and exact bit243 transfer. If native worst-path panels omit the now-nonworst exact path, use a separately bound finite copied-netlist query rather than assuming it passed.
4. Preserve all-corner signoff, the no-exception requirement, collateral clock/PCIe/DDR checks and existing later qualification gates. Incomplete fitted CPA property visibility is a diagnostic gap, not a prerequisite to reconstruct the full equation before this trial.
5. Record reallocation/rejection or a changed route with unchanged failure as bounded negative evidence. No automatic retry/index sweep and no deployment follow from this attempt.

## Review roles

Parent alone implemented/prepared and operates the workstation. Reviewers inspect the frozen local package only: no SSH, vendor tools, tests, executable edits or hardware. Preferred GLM5.3 is not selectable in this runtime; reviewers use GPT6/openai-codex, with substitution disclosed. Original approval records are provenance, not authority to replay their operations.
