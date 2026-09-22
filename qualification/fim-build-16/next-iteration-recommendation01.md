# Work16: next native iteration

**Recommend one diagnostic fit with intermediate snapshots enabled, then one exact-path post-route/final comparison—not a larger uncertainty margin.** No validated correction emerges from Work16. This is practical diagnostic advice, not acceptance or launch authorization.

## Result and mechanism

Work16 executed fitting and assembly successfully (L:9182,11096), but the original Fast vid2 100C hold check remains **−0.004ns**. S16:126779–126895 is byte-identical to S15 at those same lines: bit243 `amm_writedata_0_r[0][243]` → `c2p_350_ufi` → `tile_gen[2].lane_gen[1].lane_inst~phy_reg1`; arrival/required **2.964/2.968ns**. The other four corner blocks are also identical (both reports:5111–5227,35547–35663,65965–66081,96376–96492).

The reported physical path is unchanged: Hyper-Register `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32` → `UFI_X210_Y0_N355` → `IO12LANE_X184_Y0_N374`. Data delay remains **0.288ns**: 0.063 uTco + 0.101 interconnect + 0.022/0.053 UFI + 0.049 lane. Clock skew is −0.080ns; pessimism removal −0.354ns, advanced effects −0.050ns, applied signoff uncertainty **0.030ns**, and uTh 0.342ns (S16:126802–126815,126850–126858,126892–126895). This proves no reported path improvement, not identical unreported routing resources.

T:151–165 scopes 10ps to `quartus_fit`, with singleton clocks and unchanged STA. L contains nine applied markers (8811,9041,9049,9053,9129,9142,9145,9164,9173) and two STA skips (9597,10803). These establish issuance, not retention. **Repeated `-add` does not accumulate**: the last matching manual setter wins; addition is to derived uncertainty (U:66–83,150–159). The completed direct-SDC scan found no later overlapping setter/removal/overwrite; it expressly does not prove transitive/final retention (P:3–5). Nothing here supports moving the setter or blaming an overwrite.

`-enable_same_physical_edge` is installed syntax (U:25–36,75–83), but it is **not yet a justified corrective fit delta**. These two clocks share the reported VCO master and zero-phase waveform, but target different physical outputs (S16:2730,2734). Equal launch/latch timestamps and common ancestry do not establish the tool's physical-edge classification. The existing nonzero signoff uncertainty argues against blanket suppression; it cannot settle Fitter-stage applicability.

F16:205 already says hold optimization “All Paths.” Its hold-delay panels match Work15 (39155–39179,39186–39291); omission of this path from ranked panels is not proof of zero optimization. The exact clock transfer's “Meets timing requirements” row belongs to **Hyper-Retimer analysis**, not an exact hold-path certificate (F16:63–71,39676,40142). Crucially, routing ends before Hyper-Retimer and post-fit physical synthesis (L:9167–9179), while the failing final launch is a Hyper-Register. Whether this vulnerable physical path existed at route-stage hold optimization is unresolved—not a presumed explanation.

## One finite native observation

**Sole configuration delta from Work16:**

```tcl
set_global_assignment -name ENABLE_INTERMEDIATE_SNAPSHOTS ON
```

Keep Work16's 10ps overlay, seed, effort, vendor PHY, clocks, DDR, PR/PIM and final STA unchanged. This is an observability change, not a timing fix. The assignment is in the installed Agilex 7 list (A:565); native Work16 explicitly says its disabled state prevents intermediate snapshot commitment (L:9042).

Run one fresh native fit using the existing build machinery. In ordinary **quartus_sta**, compare its native-listed post-route and final snapshots at **Fast vid2 100C**, loading original signoff SDC in both. Supported snapshot selection is documented in C:25–36,53–61; do not invoke it inside Fitter or spoof executable identity. Obtain one `report_timing -hold -npaths 1 -detail full_path -show_routing` per snapshot, restricted through the exact UFI input at S16:126854 and to the exact PHY endpoint at S16:126787 (supported selectors H:1521–1562). Record actual launch identity, clocks, exceptions, arrival/required time and physical delays. A renamed upstream register must be observed, not assumed absent; unresolved path matching makes the comparison inconclusive.

**Signal/falsification:** a nonviolating post-route path becoming negative after retiming/finalization, with corresponding physical/delay changes, supports a late-stage origin. An already-negative post-route path with the same structure falsifies that explanation and establishes route-stage relevance. Require reproduction of the final failure before attributing the historical Work16 mechanism. This measures path evolution without demanding inaccessible absolute Fitter uncertainty. It does not independently prove setter retention. Stop after this comparison; do not substitute another unchanged Plan, callbacks, a seed sweep or a 4ps waiver.

## Evidence identities

Paths relative to `qualification/`; SHA256 of bytes read:

- S16 `fim-build-16/reports01/output_files/ofs_top.sta.rpt`: `29676cfeaf944a1694728d355c95d545331e6350418a54947a0b56c40819a59a`
- S15 `fim-build-15/reports01/output_files/ofs_top.sta.rpt`: `e38b1fbfae9afe8efdb3602165c9ec475a7898301172eeff47825742956778d9`
- F16 `fim-build-16/reports01/output_files/ofs_top.fit.rpt`: `8d8c0af300ba72425719de9032c7454620d0ecace2af70d7108f362bddbd7110`
- Work15 FIT, same relative report path: `a763725d71b02c4fb5687a5e5818e2714ed75ad2c21a0a5b6e6b99c742288aa3`
- L `fim-build-16/completion-readback01/evidence/run/native.log`: `35acbdaf89585ac5aa7f067d41ced8557e1ebef820c8725ab6811f2aa9eb6fcf`
- T `fim-build-16/top.sdc`: `3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814`
- U `emif-hold-objective-01/fit-help05.txt`: `e5b443155a530e5f29a9eeca203cfef1738410fbddd7a3d152c18c4e189e31ca`
- C `emif-hold-objective-01/fit-help03.txt`: `3ffde2a26cf87e6a5eb7ddb840ed5c284111cb4942fcef75293251abad13685d`
- P `emif-hold-objective-01/loaded-sdc-disposition01.md`: `a580a73c1af5df56ed4f1e9e9a938909b69ecb9b9a1851709662e6f24dff0c38`
- A `router-native-capability-01/remote-evidence/agilex7-assignment-names.txt`: `e4e317f026077f28e11dbac58199a602281e549d0181dcc3c81b647c59439b09`
- H `pcie-clock-repair-01/api-help01/readback/help.log`: `5a8989da4e1ac8fde989a0c41e39464d3d721e504870836ee23ebe8078ade335`
