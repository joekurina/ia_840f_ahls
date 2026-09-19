# FIM integration 05 — independent focused review

## Decision

**ACCEPT the pin/QoS source corrections for handoff to the separately reviewed native compile entry. No compile-blocking defect found in this delta.** This is source-review acceptance, not authorization of a gate/worktree, successful Quartus elaboration, fit/timing, or a working hardware claim. `ready_for_build` remains false in the reviewed receipt. DDR simulation is **SKIPPED BY USER**, not required by this review.

## Spec review — PASS

- Inspected `report.md`, `changes.patch`, `receipt.json`, the before/after snapshots, checks and actual maintained source. Executed `python3 qualification/fim-integration-05/check_integration.py` locally: exit 0 / PASS.
- Exactly 118 RDIMM targets change from `ddr4_mem_group_1[0]` to `ddr4_mem[1]`; the only other target change is PIN_HB29 from `ddr4_mem[0].cs_n[0]` to scalar `ddr4_mem[0].cs_n`. All 241 unique package coordinates and their ordering are preserved. Independently verified the complete pin-file byte-level transformation apart from its first three explanatory comment lines, not merely selected matching assignments.
- Captured generated `mem_ss_sv.sv` declares scalar CS_N and one physical interface array with NUM_PORTS=2; its connections retain mem0→index0 and mem1→index1. Current board top passes `ddr4_mem` into `ddr4_mem_if`. Target-schema mismatches fall from 119 to zero. Existing reference-clock/OCT and differential-companion assignments are unchanged; Quartus acceptance of elaborated names remains a native-tool result.
- Actual generated `mem_ss_if_info.vh` defines `IFC_MEM_SS_I_AXI_MM_IF_WIDTH_AWQOS` and `IFC_MEM_SS_I_AXI_MM_IF_WIDTH_ARQOS`, each 4. Current `mem_ss_top.sv` includes `ofs_ip_cfg_db.vh`, whose captured generated content includes that header. Lines 309–312 and 337–340 independently guard the corresponding zero assignments within `axi_mm_map`. Generated interface QoS fields are four-bit inputs to the subordinate and connect separately to both channels. Unsized unbased `'0` supplies the destination width without importing potentially undriven AFU QoS.
- Removing only these two guarded blocks reproduces the original common RTL exactly. No geometry, clock, reset, calibration routing, PF/BAR or BMC change is part of this RTL delta. All ten protected baseline hashes passed at review time. Separate concurrent gate work is not covered by this acceptance.

## Quality review — PASS, with bounded evidence

- All four receipt entries match both before/after snapshots and current maintained files by SHA256. The original common RTL is independently reproduced by `git show 34a8540697fdf3d66fbcaa263fa037bae17cc32f:src/fpga_family/agilex/mem_ss/mem_ss_top.sv`, matching SHA256 `7211a02c56ba18d8bc58c749de56242c3e1eb3c94e8c92d84c42a742cf04618c`.
- Verified original pin donor bytes against retained source SHA256 `606feee0a053afa1cab1e397df963b516b0c8a416a55472e3f138e07a6171bae`. The manifest changes only its existing pin entry's current hash, prior hash and description; original donor provenance is retained.
- Reviewed generated payloads and verified their self-hashes; all five receipt/header-log hashes match captured Work04 payloads. This review used the existing remote evidence record, not a new remote read.
- The test checks exact intended target changes, unique coordinates/targets, generated signal widths, zero assignments, exact remaining RTL identity and protected files. Three negative target fixtures pass by rejecting stale group naming, scalar-as-vector CS_N and out-of-range DQ.
- No new driver collision appears in the inspected wrapper path: each QoS field has one local continuous driver per generated channel and the generated subordinate consumes it. This is source evidence, not full-design elaborated driver analysis or accepted-request behavioral proof.
- Minor test-comment nit only: the comment above the negative fixtures mentions mutated coordinates, but those fixtures mutate target names/indices. Actual coordinate preservation is independently asserted earlier; this wording does not invalidate the check or block compile.

Reviewed implementation SHA256:

| File | SHA256 |
|---|---|
| `syn/board/ia840f/setup/emif_loc.tcl` | `a48a84b89fd6c5d5fd36c87cfe5c7d03264f3dea08ea6a447151351a21b523c3` |
| `ofs-common/src/fpga_family/agilex/mem_ss/mem_ss_top.sv` | `b9b0deb0582d554cb2178ed4ee090c088d9841951b19d1223cd4ca96bd9498a1` |

## Compile entry versus functional acceptance

**Compile entry:** the report identifies the old setup-only gate and Work04 binding as not authorizing compilation. A separate worker owns the new source/worktree/tool/context binding. This review neither changes nor approves that gate. Once the separate compile entry is accepted, these pin/QoS changes need no further source correction before the bounded native attempt. Native compilation must establish include/QIP closure, actual pin-name acceptance and elaborated driver consistency. No claim is made that such results already exist.

**Functional acceptance still open, not blanket prohibitions on trying compile:** calibration-index association; PIM request/response USER semantics; effective PCIe CSR and system-PLL clocks/timing; existing BMC warnings/unused conduits/legacy leaf settings and PF1 FLR cancellation/drain restrictions. Preserve configured geometry, whole-channel mapping and PF1/BAR2 rather than changing them to obtain a fit. Compile, timing, matching PR products and eventual hardware function are distinct acceptance results; programming/recovery safety is outside this review. No DDR simulation or broad vendor-model audit is requested.

## Reviewer actions and boundaries

Local source/evidence reads, one existing static-check execution, independent hash/delta checks and read-only local git donor lookup only. No remote operation, compilation, simulation, commit, source edit or gate modification. The only file created by this review is this report.
