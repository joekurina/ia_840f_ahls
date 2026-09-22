# Loaded SDC source capture — precedence evidence, not an effective-objective measurement

`loaded-sdc01.json.gz`, SHA256 `5c484ae0efec96cbe3e5370b0d62067e401d46f3bb9a80e9cf07c3cfd3f0f661`, contains all 38 unique ordinary SDC files named in completed Plan03's native log. Every file matched the bound preparation inventory; original Work15 proxy paths matched copied counterparts. No path was unavailable. See loaded-sdc-manifest01.json and loaded-sdc-observations01.json.

There are 41 textual uncertainty command/comment hits. Actual derive_clock_uncertainty calls in the two EMIF SDCs (line67), two PLL SDCs (line45), and top.sdc (line25) use no flags. The directly named SDCs loaded after generated EMIF1 contain no later direct set/remove-clock-uncertainty commands; top.sdc calls default derivation. This does not establish transitive Tcl closure, a historical effective Fitter value, or a corrective fit result. Keep application/order/physical-edge checks explicit. All reads were ordinary files in owned tmux, no vendor execution or hardware access.

This evidence was gathered after dispatch of NEXT-CORRECTION.md review; attempted steer found no live child. Parent must reconcile the returned recommendation against this additional evidence rather than assume the reviewer saw it.
