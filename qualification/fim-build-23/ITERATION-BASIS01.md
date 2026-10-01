# Work23 — one controlled seed-only trial

## Question and scope

Can a different initial placement seed close the exact EMIF1 bit243 Hyper-Register→UFI→PHY hold transfer under Quartus26.1.1, without changing timing requirements or design geometry?

This is the second full compile in the migration campaign's bounded1–3-attempt Phase4 budget. The original user instruction authorizes in-scope migration execution; the later question about seed sensitivity was not itself treated as a launch command. The current package is **prepared only: no native authority issued, no Quartus launch**.

The predecessor Work22 is finished and timing-rejected. Its [independent review](../fim-build-22/timing-review49.md), [parent consumption](../fim-build-22/review-consumed52.json) and [physical-result checkpoint](../fim-build-22/PHYSICAL-RESULT54.md) establish technical eligibility for a fresh seed3 trial, not a promised remedy or deployment approval.

## Exact changes and preservation

- Sole physical-design setting delta: `set_global_assignment -name SEED 2` → `set_global_assignment -name SEED 3` in the copied base QSF. [Exact diff](ofs_top.qsf.diff).
- Retarget only the copied Python gate and already exercised compile supervisor's evidence/WORK roots; CMake and Tcl callback bytes are unchanged. [Gate diff](ia840f_migration_gate.py.diff), [runner diff](run-compile30.py.diff).
- Copy exactly3,963 recorded input entries from completed Work22; exclude QDB/output/DB trees. Preserve generated native26.1.1 IP, HLS output and fresh header bytes except finite old-WORK-root text relocations. Do not re-run HLS generation or the explicit clear/regenerate-IP target.
-169 root-relocation entries and two overlays have a170-entry union because the gate participates in both. This is path relocation plus seed/root overlays, not170 independent functional changes. [Relocations](prepared01-readback/relocations01.json), [overlay delta](prepared01-readback/overlay-delta01.json).
- Preserve exact3.000ns target, all clock/board/DDR/PR choices, four-line PCIe divider declaration, bit243 retiming-OFF, intermediate snapshots and existing fit-only10ps/STA-skip behavior. No source feature, floorplan, margin, exception or tool-version change.
- Original Work22 input bindings, four image/intermediate hashes and static QDB hash were checked unchanged after copying. The1,891-entry original SOURCE/PIM inventory was also rechecked. Do not broaden this to unrecorded entire-tree preservation.
- Native post-fit metadata from Work22 is retained with exact hashes; a subsequent native FME identity is a new build result, never assumed compatible with an older persona.

## Preparation and guard evidence

[Preparation receipt](prepare01-collection.json) and [parent comparison](parent-preparation-check01.json) bind the actual copied inventory. The135 command contexts differ only by WORK-root retarget; executable hashes, CPU affinity and immutable/mutable key sets are preserved. Actual predecessor completion and original generation/header evidence remain prerequisite hashes, not reusable execution tokens.

The compile runner is reused with only two root constants changed. Eight real-inert child/supervisor cases passed, including nonzero status, descendant cleanup, bookkeeping failure, timeout and preservation on rejected rerun. Sixteen gate fixtures and three real local CMake configure/help/rejection checks passed. These use synthetic identity/resource admission and never execute Quartus. [Runner fixtures](compile-runner-inert30.json), [gate/CMake fixtures](candidate-inert08.json).

On the workstation, the actual copied Tcl entry rejected missing authority and the actual new runner rejected the absent stage manifest, without native tools or creating an operation/authority/lock. [Real entry rejections](prepared01-readback/real-entry-rejection01.json). The draft manifest's `parent_execution_accepted` remains **false** and no `stage-inputs/compile.json` exists. Later admission requires consumed source/execution review, exact revalidation and exclusive issuance; the native process must then be independently observed.

## Required result and stop condition

A pass requires completed native fit/STA at unchanged requirements, all summary records reconciled, and this exact transfer nonnegative at all five corners with **No SDC Exception on Path**, alongside unchanged clock/constraint coverage and fit-only/STA-skip markers. Retain assembly and process completion separately.

Compare physical sites and clock/data terms, including `pa_core_clk_out[0]` compensation. Work21's86ps advantage over Work22 decomposes into84ps compensation and2ps launch-clock interconnect in the retained detailed reports; this is not proof of a tool bug. If seed3 reproduces the same failure/path/terms, stop blind seed iteration and use that result to direct the next supported clock-compensation investigation.

Workstation availability, no device access, no duplicate operation and stop-on-real-error rules remain unchanged. Timing success would still not authorize claiming electrical/PR/persona/hardware gates passed. The new and carried PIM, PR-freeze, reset and I/O findings stay visible; they do not justify unrelated changes to this trial.
