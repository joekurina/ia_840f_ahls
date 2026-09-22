# Fanout diagnostic02 — native failure, retained partial observations

**Native/effective/outer rc3; diagnostic INCOMPLETE. Independent result review pending. Timing/hardware NOT ACCEPTED. This one-use attempt is spent.**

## Execution and preservation

The separately inspected issuer recorded authorization in %51 at `2026-09-22T12:38:44.492097+00:00`, with original trees unchanged before launch. Native execution ran `2026-09-22T12:38:47.499485+00:00` through `2026-09-22T12:39:26.666361+00:00`. Supervisor reports termination confirmed, no live owned PIDs, no abort or supervision error. All three postrun original Work14/SOURCE/PIM preservation receipts are literally true. These are captured inventory/result receipts, not an OS access trace. [Completion](completion-pane01.txt), [native result](result-readback01/native-result.json), [execution status](result-readback01/execution-status.json), [preservation](result-readback01/preservation-after.json).

Result archive `result01.json.gz` SHA256 `06bad8b420d448856c9983174e21340c7ea7080a894ca7fa631311b995234abf`; all 8 exports and the single report verified against transport, manifest and report-manifest. [Verification](result-verification01.json), [manifest](result-manifest01.json). The accepted package milestone is `98c84601109c5d49ae357436131799a003cb16cb`; it did not accept this native outcome.

## Exact native failure

`query.log:496–520` reports `Error (23035): Tcl error: can't set "pins": variable is array`, while executing `set pins [get_cell_info -pins $cell]` within `::ia840f_fanout_contrast::main`. This is prepared query line159, reached for the first cell of physical group0. No pin enumeration, reverse-pin verification or buried-register mapping record was reached. Error23031 reports script failure; the completion marker is absent. [Raw log](result-readback01/query.log), [prepared query](prepared-readback01/query.tcl).

The query already used a dedicated namespace and procedure: that isolation alone did not prevent the observed `pins` collision. The precise origin/scope of the existing array is not established by this stack trace. Do not claim a global-only cause or mutate/delete vendor arrays. Preserve this package and correct forward only after source/result review.

## Useful but incomplete observations

Parent parsed the entire135-line audit as Tcl lists (without evaluating it), recomputed uniqueness and all three recorded set relations, and saved [partial-observations01.json](partial-observations01.json). The raw [audit](result-readback01/reports/audit.tcllist) SHA256 is `c85cdb0d21ac800a732c482f7e5f8e1a4d7f80c67de8cce1850340e600bac285`.

| Exact-root query | Count | Enumeration/unique count | Cap |
|---|---:|---:|---:|
| Output pin, `-clock` | 0 | 0 | 4096 |
| Output pin, default | 459 | 459 | 4096 |
| Divider keeper, `-clock` | 0 | 0 | 4096 |
| Divider keeper, default | 459 | 459 | 4096 |

Both default sets are exactly equal; each contains the named tile. The two clock-filtered sets are empty. These are different native edge-filter observations, **not proof of absent physical clock loads or a validated complete clock-only collector**. The459 default nodes are not equated with fitter Fan-Out355; default queries can include different path classes/representations.

For the first known indexed cell, each raw lookup (`get_cells`, `get_keepers`, `get_registers`) returned exactly its one expected name; each transformed `[[]` lookup returned zero. This is design-specific native matching evidence, not a universal selector rule. Physical group0 returned its expected eight cells and the first cell type was `tennm_ff`, but mapping stopped before all32 receivers were examined. The80-clock inventory and unchanged201 warnings remain evidence, not constraint or timing acceptance.

No new clocks, exceptions, maintained-source edits, fit or hardware operations occurred in this diagnostic. The inactive candidate-helper defect, complete receiver/extra-node classification, A/B numerical timing/exception coverage and all mission gates remain unresolved. The old experiment03 candidate stays unissued/blocked. This failed run cannot be retried or relabeled successful because it retained useful data.
