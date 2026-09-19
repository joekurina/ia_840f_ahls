# Work08 scoped feature delta
| Feature | State |
|---|---|
| Bank9A preservation input | Unconditional qsfp_ref_clk; CC19/BW19; differential LVPECL |
| BTI parameters | Vendor electrical settings; 156250000 Hz; modern diagnostic use_as_BTI_clock=TRUE |
| Timing | Dedicated 6.400ns clock-only SDC replaces shared Ethernet SDC in IA840F source list |
| Ethernet/HSSI | Remains disabled; no Ethernet datapath enabled |
| DDR | Existing accepted 2x16GB mapping, scalar CS_N and zero QoS unchanged |
| PLL/PTILE/AHLS | No parameter/ABI changes; core470 seven outputs, Gen4x16 PF1 retained |
| DDR simulation | SKIPPED BY USER |
| Hardware programming | Not performed |
| Readiness | false; experimental compile is not functional acceptance |

Provenance: ../fim-bti-clock-01/REPORT.md and its archive/board/fit evidence.
Historical lowercase bti differs from modern diagnostic uppercase BTI: actual native retry decides acceptance.
Work07 status gate_rejection=true is retained verbatim, but its actual failure was fitter 21636/12274; generic child-exit detection is not evidence of an actual gate marker.
