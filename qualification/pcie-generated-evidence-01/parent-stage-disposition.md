# Parent stage disposition after generated PCIe/PLL review

The standing build/test goal is incomplete. `ready_for_build=false`. This disposition does not authorize compilation or programming and does not modify consumed Work03 sources or claims.

## Acceptance matrix

| Criterion | Result | Evidence and boundary |
|---|---|---|
| Work03 setup / selected-IP enumeration | PASS for recorded run | [Final execution status](../ipgen-03/execution-status.md): setup exit 0, 83 assignments; not full generation |
| Complete Work03 RTL generation | FAIL | Same status: Quartus child exit 3, wrapper exit 1, missing mailbox waitrequest; final failure remains unchanged |
| OFS generated headers | NOT RUN | Generation failure stopped sequence; no substitute headers |
| Six captured PCIe/PLL HDL payloads | PASS, finite source consistency | [Parent hash reconciliation](parent-generated-evidence-reconciliation.json); distinct partial live02 and separately scoped live03 receipts retained |
| P-Tile Gen4 x16, two PFs, PF0 VF0, PF1 no VF | PASS_STATIC | [Generated HDL review](generated-hdl-review.md), active simulation-generated parameter chain; not transaction/hardware acceptance |
| Vendor IDs, PF1 BARs and 64-byte/two-segment datapath | PASS_STATIC | Same review; no source changes needed on this evidence |
| PLL outclk_1 exactly requested 100 MHz | MISMATCH_NOMINAL | M=141, N=10, C2=14 under assumed 100 MHz reference yields 705000000/7 Hz; parent independently checked mappings, counters and arithmetic |
| PLL outclk_3 exactly requested 630 MHz | MISMATCH_NOMINAL | Generated primitive reports 705 MHz; consumer activity and contract review in progress, not an assumed timing failure |
| Simulation/synthesis identity and rendered constraints | NOT VERIFIED | Rendered source-manifest/SDC binding absent from this finite capture |
| Memory calibration-slot permutation | NOT ACCEPTED | [Endpoint review](../memory-generated-evidence-01/calibration-live05-review.md) proves matching command/table pairing to primitive ports, not slot-permutation semantics |
| Mailbox correction | NOT INTEGRATED | [Work03 status](../ipgen-03/execution-status.md); separate migration preparation does not repair the failed run |
| Protocol/reset/CDC simulation, FIM synthesis/fit/timing | NOT RUN for candidate qualification | Static HDL inspection is not execution |
| AHLS component/host qualification and hardware FPGA Tests | NOT QUALIFIED | No acceptance inferred from PCIe or PLL source checks |
| Programming | NOT DONE | Supported PCIe procedure and usable no-JTAG recovery remain required |

## Immediate work and preservation

- Clock-consumer/constraint tracing completed under `deleg_5557d2c3`: [review](clock-consumer-contract-review.md). Outputs3/6 have only HBM-gated sinks in the selected maintained IA840F RTL; DDR4 selection does not enable HBM. Parent spot-checked top.sv:1252–1263, ofs_top.qsf:96–108 and mem_design_files.tcl:23–40. This is not Work03 elaboration proof. Active CSR frequency also occurs in the original donor. Parent checked the installed PCIe schema declaration at pcie_ss_parameters.tcl:1721: INTEGER {100:250}, so a fractional replacement is unsupported. No PLL retuning or tolerance approval is justified; next evidence is the literal SDC template and actual generated synthesis/constraint manifests.
- Local synthetic delivery-adapter implementation is active under `deleg_572b49ec`. It is not permission to execute the remote metadata diagnostic, alter permissions or rerun consumed u03.
- Work03, u01/u02/u03, original vendor sources and existing capture receipts remain preserved.
- Reconciliation created only the parent reconciliation JSON and this disposition. Prior artifact hashes are an explicitly finite inventory, not a complete final project inventory.
