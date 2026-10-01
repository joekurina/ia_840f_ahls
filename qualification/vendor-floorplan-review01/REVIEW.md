# BittWare IA-840F floorplanning review

**Disposition:** the current build already implements the vendor-style minimized, stepped static/PR floorplan. This review does not establish an exact match to the document's screenshot, approve a changed region, or attribute Work22's hold failure to floorplan congestion. No source/constraint changes, native tool runs or hardware access were performed for this review.

## Primary document, including embedded figures

Reviewed `IA-840F FIM Notes.docx`, 621,993 bytes, SHA256 `1a6560c2c8a46e97ad8430fc299f7804d7576b6f8c43108583dd586fa90cbbf7`. The original and all three extracted vendor figures stay local-only. [Source and figure identities](source-manifest.json).

The **Floorplanning** text says the minimized design removes HPS/Copy Engine, 8×25G HSSI and host exercisers where possible; packs the FIM into the bottom-left; and leaves the top-right HPS memory bank enabled but essentially unused. It claims approximately 14% of AGF027 resources for the locked-down, floorplanned FIM portion. This is a vendor claim about their configuration, not a measurement of ours.

The actual floorplan figure, `word/media/image2.png`, shows a large PR region labelled with the `afu_main` hierarchy, and a stepped lower-left area labelled with `afu_intf_inst`. It does **not** supply a numeric coordinate grid, Tcl assignments, timing evidence, tool version or build identity from which exact effective constraints can be recovered. Its blue/purple fill must not be treated as a quantitative congestion map.

The functional diagram, `word/media/image1.png`, says its OpenCL/oneAPI USM goal was reduced to one DDR4 bank and excludes the other three, whereas the surrounding floorplanning paragraph says the current FIM supports two DDR banks. That disagreement is present in the primary source, including text embedded in the figure. It cannot authorize disabling either of our two required banks. The upper-right HPS-bank remark also does not identify our failing EMIF1 instance.

## Current source and actual fitted boundaries

The selected [`pr_assignments.tcl`](../../ofs-agx7-pcie-attach/syn/board/ia840f/setup/pr_assignments.tcl), lines24–33, binds `green_region` to `afu_top|pg_afu.port_gasket|pr_slot|afu_main`, with `CORE_ONLY_PLACE_REGION`, `RESERVE_PLACE_REGION` and `PARTIAL_RECONFIGURATION_PARTITION` all ON. Its active constraints are:

```tcl
PLACE_REGION "X0 Y101 X390 Y333; X101 Y21 X390 Y100; X301 Y0 X390 Y20"
ROUTE_REGION "X0 Y0 X390 Y333"
```

Work22's native **Logic Lock Region Constraints** and **Usage Summary** panels confirm precisely those three placement rectangles and the full-core route rectangle: [fit excerpts](fit-excerpts.txt), native lines38663–38694. Thus placement reservation and routing extent are different; the small static placement footprint is not evidence that every static signal is confined to a corresponding small routing box.

The placement complement within the stated core bounds is the stepped lower-left footprint: `X0 Y0 X100 Y100` plus `X101 Y0 X300 Y20`. The per-static-block placement examples and alternative PR geometries in this Tcl are commented out, not active constraints.

The maintained Tcl has SHA256 `ee691738de4804222453ee1bacf82535ed7c57df6b05819008b6a97df8e6cd61`, verified against Work22's frozen compile manifest. It is byte-equivalent to the retained [legacy board Tcl](../../ofs-agx7-pcie-attach/src/board/ia840f/legacy/syn/setup/pr_assignments.tcl), SHA256 `4eddd0cccde481eec5a3823f3f0260e5a6f2225b0869f18450fd41c8151c1e02`, after only the exact `afu_top|port_gasket` → `afu_top|pg_afu.port_gasket` hierarchy adaptation. The migration did not introduce a new region geometry. Neither this comparison nor visual resemblance proves which commented historical variant was used for the vendor screenshot. [Machine-checked comparison](comparison.json).

## The important utilization distinction

Work22's native **Partial Reconfiguration and Periphery Reuse Statistics** reports the following; percentages below are computed from those native values, not screenshot area. [Fit excerpts](fit-excerpts.txt), lines38708–38743.

| Quantity | Native evidence / interpretation |
|---|---|
| Whole-device ALM capacity | 912,800 |
| PR-region ALM capacity | 822,480, or 90.11% of the device's ALM capacity |
| Static-region ALM capacity, excluding PR | 90,320, or 9.89% of device ALM capacity |
| Static ALMs needed, after report packing estimates | 59,808.8 / 90,320, or 66.22% |
| Static ALMs used in final placement | 67,988.1 / 90,320, or 75.27% |
| Whole-image ALMs needed, including scalar AFU | 66,394.7, rounded to 66,395 in the summary (7% as reported) |

**Low whole-device utilization does not mean the static FIM has the rest of the chip freely available.** Most ALM capacity is reserved for PR; the current static allocation is about three-quarters occupied under the final-placement metric. This is a relevant floorplanning constraint, but it is not by itself evidence of local routing congestion or a timing-causal mechanism. ALM capacity percentages are not percentages of every resource type or uniform geometric area.

The earlier [vendor summary](../../docs/vendor-fim-notes.md), lines19–21 and75–76, and migration prompt line60 overstate the comparison between the vendor's approximately14% locked-down FIM claim and CAPS03's13.96% whole-image ALM utilization. Those numbers have different/insufficiently specified scope and do not establish equivalent floorplans. This review records that correction without modifying those existing documents or campaign constraints.

## Relation to the current timing failure

Work22's failing path is the EMIF1 `amm_writedata_0_r[0][243]` → `tile_gen[2].lane_gen[1].lane_inst~phy_reg1` transfer, with **−0.004 ns hold at Fast vid2 100°C**, explicitly **No SDC Exception on Path**. Its physical data path runs through:

- Hyper-Register `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32`;
- `UFI_X210_Y0_N355`;
- `IO12LANE_X184_Y0_N374`.

These locations are on the bottom side, outside the reserved PR placement rectangles—not the document's described upper-right unused HPS bank. [Native STA excerpts](sta-excerpts.txt), lines142594–142673; coordinate membership checks in [comparison.json](comparison.json).

The document does not show that moving a region boundary repairs this particular hold transfer. Nor does its screenshot establish why the Hyper-Register/UFI/PHY transfer missed by4 ps. Preserve the existing all-corner timing requirement and the prompt's boundary-preserving, bounded refit protocol. Do not silently activate a commented region variant, infer new constraints from image pixels, shrink PR, move DDR resources, inflate hold margins, or waive the path on the strength of this review.

## Review outcome and scope

The actionable finding is to assess **static-region** resource pressure separately from total FPGA utilization, while recognizing that the minimized stepped geometry is already present and natively consumed. The remaining hold failure is real and unaccepted; no floorplan fix is established here. Successor preparation was paused for this review; no successor build was launched. The independent Work22 fit/STA review remains a separate campaign deliverable.
