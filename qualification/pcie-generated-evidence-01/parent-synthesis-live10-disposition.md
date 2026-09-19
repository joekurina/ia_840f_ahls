# PCIe synthesis source comparison: parent disposition

Accepted synthesis-chain-live10-review.md after independently comparing the actual four decoded byte strings against retained simulation payloads. All four match; the reconciliation JSON records exact paths, lengths and SHA-256s.

This closes the prior uncertainty about synthesis-vs-simulation source identity for these bodies. Effective generated P-Tile/PF/VF/BAR/datapath findings now apply to these registered synthesis sources, not just simulation sources. It does not establish compiled board selection or hardware routing.

CSR clock forwarding ends at the selected intel_pciess_ptile_wrapper AXI-lite input; BRIDGE and HIP are not a serial CSR clock path. No justified BAR, PLL or SDC correction is established. Static clock investigation is now sufficient to state the remaining evaluated-netlist/TimeQuest gate; collecting adjacent files cannot substitute for it. Defer timing acceptance until full generation, headers and authorized compilation succeed. BMC mailbox generation remains the current execution blocker.

No vendor execution, source edit or readiness promotion. ready_for_build=false.
