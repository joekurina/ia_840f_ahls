# Independent review — connected AHLS memory fabric

Status: **FINAL — ACCEPT bounded fabric03 generation and connected elab01 analysis/elaboration evidence, with the ledger correction below. NOT full-AFU, functional or hardware acceptance.**

The actual kernel, separate CSR destinations, independent bank fabrics and native protocol/width adapters are instantiated and elaborate under Quartus 25.1 Build 129. No new active memory-address clipping or missing bank connection was established. A confirmed port-inventory error and unresolved integration limitations must accompany acceptance; the generic success banner is not warning-free or mapped-synthesis evidence. This FINAL supersedes the earlier IN_PROGRESS draft. No new launch-approval gate is created.

## Evidence bindings

Paths expand from `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `F=N/qualification/ahls-memory-fabric01`; `G=F/artifacts-fabric03`; `E=F/artifacts-connected-elab01`.
- `C=G/ip/ahls_memory_fabric/ahls_memory_fabric_fabric`; `T=G/ahls_memory_fabric/synth/ahls_memory_fabric.v`.
- `V=C/ia840f_ahls_memory_fabric_10/synth/ahls_memory_fabric_fabric_ia840f_ahls_memory_fabric_10_xit3k2i.v`.
- `M`, `B0`, `B1` are `C/altera_mm_interconnect_1920/synth/ahls_memory_fabric_fabric_altera_mm_interconnect_1920_` followed respectively by `l246cuq.v`, `kupnvta.v`, `spdifha.v`.
- `Rr`, `Rw` are `C/altera_merlin_router_1921/synth/ahls_memory_fabric_fabric_altera_merlin_router_1921_` followed respectively by `bknbsua.sv`, `pleb25y.sv`.
- `WA=C/altera_merlin_width_adapter_1950/synth/ahls_memory_fabric_fabric_altera_merlin_width_adapter_1950_lvsui2a.sv`.
- `L=E/elaboration.log`; `AE`, `SYN`, `DRC`, `FLOW` are `E/output_files/ahls_memory_fabric_elab.` followed by `syn.ae.rpt`, `syn.rpt`, `drc.partitioned.rpt`, `flow.rpt`.

Independent byte/size/SHA256 checks passed for **27/27 frozen package members**, **261/261 fabric archive payloads**, **7/7 elaboration archive payloads**, and the four supplemental generated captures. Both manifests reproduce their raw archive metadata after excluding encoded bodies and the added capture field. The native generation inventory has **286 entries**; this is not a claim that every inventoried output was captured.

Both QIPs were independently parsed: **254 dependency edges / 253 distinct targets + two QIPs = 255 elaboration inputs**. Every target and both QIPs are local and hash-equal to generation and elaboration inventories. QIP line/type/target records exactly match `qip-dependencies03.json`. The four supplemental files match `sources04.json` and the original native inventory.

| Bound artifact | Full-file SHA256 |
|---|---|
| `F/review-package01.json` | `68d5e4c6e35703d34563228c343888d9cbf309a224c5d6ae69849b68b40d83b1` |
| `F/result-fabric03.json.gz` | `69db8ef91de72f4ce100c5acd8ac65922d980cd6e5538393093abd56e44b8ce0` |
| `F/result-connected-elab01.json.gz` | `8e21614a83dbc3b70ebcde9785eea85a39995883bec35f91ba6e18af9e6607b5` |
| Reused `N/qualification/ahls-memory-elab25-01/independent-review01.md` | `5732305356db51da07f5adda98ebdb3700bbc588b0b80e3335869b5095a5e610` |

All **155 HLS synthesis members** match the accepted import02 native inventory and current local bytes; the prior local import capture itself is partial, so equality was not falsely claimed against 155 old local files. All **551 kernel-instance parameter maps** in connected AE equal standalone AE after removing only the enclosing hierarchy prefix. The prior HLS audit is reused, not repeated. The corrected `lsu_ic_top.sv` retains SHA256 `f9defb182dcca3d3d299eb1e2ee060ce730caa24b2bd613d44f8c05abaccfdcd` and its previous unit-only acceptance.

## Native result and preservation

- **fabric03:** import/validate/save and `qsys-generate --synthesis=VERILOG` each native/effective rc0. Actual source `make-system02.tcl:21–24` validates before printing completion markers; `G/import.log:37–43` and `G/generate.log:13–15,88–108` corroborate generation, Quartus 25.1 Build 129 and AGFB027R25A2E2V. Transient helper PIDs were observed at import/generation leader exit but drained; final timeout and surviving-owned-group fields are clear. Do not rewrite this as “no descendants ever existed.”
- **Connected elab01:** `/opt/altera/25.1/quartus/bin/quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ahls_memory_fabric_elab -c ahls_memory_fabric_elab`; native/effective/outer **0**, runner accepted, no timeout or surviving group (`manifest-connected-elab01.json:3–25,1538–1541`). Tool/time/top/part are corroborated by `L:3,18–24,98,112,120–124`, `SYN:390–400` and `FLOW:42,65–79`: **339 entities, 849 elaborated partitions**, native processing 01:23:17–01:23:54, runner UTC 08:23:16–08:23:55. `FLOW` explicitly says **Synthesis (Analysis & Elaboration)**. This is not mapped synthesis.
- Original/copied 255 inputs and tool preservation are supported by the captured postflight and the runner's checks (`run-connected-elab01.py:10–16,28–30,89–108`), not by a new remote inspection. Elaboration QSF equals its configured bytes and explicitly includes both QIPs and the two known power-format defaults. The fabric import's five appended QSF assignments are retained separately; Tcl hashes match actual authored inputs.
- **Failed fabric01 and fabric02 remain failed rc1**, with no generation command: invalid system-scope `set_interconnect_requirement`, then absent IRQ/freeze/exception exports (`artifacts-fabric01/import.log:502`; `artifacts-fabric02/import.log:32–38`). Their archive payloads still match local captures. API01 only queries interpreter commands and itself prints `PD_VALIDATE_OK`/`PD_IMPORT_COMPLETE`; it is not design validation.

## Instantiated connections and geometry

**Donor fidelity.** The cached AI donor matches provenance SHA256 `f1aaaa6bbfc34341c9b4a961bc6af0f9b7994a10630e39074ebc53c846a1862f`, pinned commit `e0e07f7b1878a477dc4d1191918db8430193e148`. All **69 parameters per bridge role** match donor source with only the documented evaluated geometry substitutions; no parameter was inferred from a similarly named bridge. Composition callback and enabled component-style IRQ/conduits are present. Donor `clockCrossingAdapter=FIFO` and `maxAdditionalLatency=2` are retained in component source lines 363–364. Their presence does not establish physical-bank CDC or achieved latency.

| Path | Independently verified instantiated evidence |
|---|---|
| MMIO → actual kernel CSR | `V:522–553,2104–2177`; `M:878–919`; `AE:3703–3737`. Kernel address is **5-bit WORDS / 64-bit data / eight byte enables**. The native translator takes byte bits `[7:3]`. Defined kernel aperture is **0x10000–0x100ff**, not 64 KiB. |
| MMIO → DMA CSR export | Separate **0x00000–0x0ffff**, 16-bit byte-address / 64-bit data bridge. Read/write routers independently distinguish it from kernel CSR (`M:1504–1534`; `Rr/Rw:214–223`; `AE:2590–2791`). There is no DMA engine behind this export yet. |
| Kernel + DMA → bank 0 | `gmem0_1` and `dma_ddr_in0` connect through `mm_interconnect_1` to `bank_out0` (`V:2179–2279`). Kernel specialization has **two read ports / zero write ports** (`AE:3039–3086`). |
| Kernel + DMA → bank 1 | `gmem1_2` and `dma_ddr_in1` connect through `mm_interconnect_2` to `bank_out1` (`V:2281–2381`). Kernel specialization has **zero read ports / one write port** (`AE:3091–3138`). B0/B1 are byte-identical after exact bank/host/entity-name substitutions. |
| Avalon → native packet/AXI fabric | Both active native master translators use **AV/UAV address width34, address-symbols1, data256, byteenable32, burstcount4 WORDS → nine-bit byte count, waitrequest allowance0** (`AE:4290–4323`). B0/B1 contain translators, master agents, traffic limiter, command/response width adapters, command arbitration and AXI slave agents—not just exported wires (`B0/B1:676–699,1249–1480,1571–1771,1887–2002`). |
| Width/burst/mask preservation | Command adapter packet address `[321:288]` → `[609:576]` remains **34 bits**; data256→512 and enables32→64. Response conversion reverses it (`AE:4847–5026`, including both banks in **All Instances**). **Command PACKING=0** shifts data and byte masks into the addressed lane; it does not prove aggregation into full-width useful transfers (`WA:1540–1577,1709–1710`). Partial write masks are not replaced with all ones. Native protocol agents carry byte-count/burst-size fields and AXI LEN8; CSR has its own burst adapter (`AE:4093–4139,4474–4800`). |
| Independent bank boundaries | Each exports address34/data512/WSTRB64, IDs18 and USER2; DMA inputs have IDs16. Native bridge and agent panels include **both banks**, acceptance/issuing capabilities64 and OOO disabled (`AE:2796–2999,4474–4800`). Generated mux source `C/altera_merlin_multiplexer_1922/synth/*_g6gxb3a.sv:277–280` instantiates round-robin arbitration. No dynamic fairness/throughput guarantee is inferred. |

Memory address range is **0–0x3ffffffff per independent bank address space (16 GiB addressability)**, not a measured installed-capacity or DDR claim. Full 34-bit fields survive native translators, adapters and AXI boundaries; this is static connectivity evidence, not exercised high-address traffic.

**MMIO decode limitation:** Rr/Rw optimize destination decoding to low **17** address bits (`:162–174`), although MMIO input is 20 bits. Thus an upstream request at **0x30000** selects the same kernel word as 0x10000. The defined apertures above are an access contract, **not exclusive protection against high-address aliases or proof of rejection outside the map**. Restrict/validate upstream addresses in the later host/PIM composition; do not confuse this MMIO issue with clipping the 34-bit memory paths.

**Work21 source geometry:** all **15 distinct captured files** match preflight01/geometry02/geometry03/sources04 bindings. `pim-capture01/ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_param_pkg.sv:6` supplies NUM_PORTS2; adjacent `mem_ss_if_info.vh:16–54` supplies address34, data512, strobes64 and **AR/AW ID9**, with address USER14. The captured PIM configuration derives its widths from these definitions. Fabric ID18/USER2 is **not a completed direct PIM binding**; final ID mapping/user semantics remain open. These files do not establish the currently deployed image or Work21 signoff.

## Confirmed ledger correction and warning disposition

**F-01 — evidence-enumeration error, not missing RTL.** `RESULTS03.md:14` and `top-ports03.json` claim **243 ports**. Independent HDL parsing and native SOPCINFO agree on **244 unique ports / 11 interfaces**, including all names, directions and widths. The ledger omits only **`input wire [1:0] bank_out1_ruser`**, the final declaration without a trailing comma (`T:250`; connection `T:497`). All 243 included entries are correct. Parent must correct the count/ledger; neither was modified by this reviewer.

**57 diagnostic occurrences = 56 Warning + one Critical Warning**, independently matching the exact warning ledger and both native report message sequences. SYN populated Count cells also sum to57 (`SYN:11256–11438`); repeated report/log presentations and indented examples are not extra occurrences.

| ID | Occurrences | Disposition |
|---|---:|---|
| 13469 | 28 | Reuse configuration-specific arithmetic/counter explanations, including active address prediction and pending-write counters; no blanket truncation waiver. |
| 16788 | 13 | Reuse the verified read-only/write-only and disabled-branch explanations, not an assumption that all undriven signals are harmless. |
| 21610 | 13 | Twelve unchanged pruned/legacy-output occurrences; **one observable 64-bit exception output tied to ground** (`L:99`). Zero exceptions cannot check errors or numerical correctness. |
| 17498 | 1 | Unchanged generate-local parameter interpretation; source-consistent. |
| Critical 20759 | 1 | Device-level Reset Release obligation, unresolved. |
| 21620 | 1 | Reports the same high-severity reset DRC, not a second distinct reset failure. |

Reuse is supported by all155 source hashes, all551 kernel-instance parameter maps and all57 diagnostic texts/source locations after normalizing only enclosing hierarchy and capture/report paths—not merely matching IDs. The new adapters are actually present in AE. The generic **0 errors / 1 warning** banner (`L:120`) remains discrepant with57 explicit diagnostics; native summary-count semantics are **unresolved**, not waived.

**Reset/clock boundary:** one external clock drives bridges, kernel and interconnect; no selected operating frequency or timing result is established. Bridges/interconnect use external reset, while k0 uses the generated conditioning controller (`V:523–524,648–649,2175–2176,2383–2411`; `AE:3004–3034`: both-edge synchronization, depth2, minimum assertion3). This is not device configuration release. **RES-10204 FAIL: zero Reset Release IP, exactly one required; one High violation, zero waived** (`DRC:45–71`). Establish the full FIM's single device-level service and reset distribution; do not blindly add a duplicate in the persona.

## Unresolved boundaries / final disposition

- Correct F-01 in the parent's evidence; preserve this review's frozen package and failed receipts rather than rewriting history.
- Compose the actual DMA engines and PIM/physical-bank CDC, with **exactly one primary host-channel0 owner**, final ID/user adaptation and bounded MMIO decoding. No DMA/PIM top or physical DDR controller/CDC is instantiated here.
- Bind full-device Reset Release, resets/clocks and existing Work21 signoff obligations. IRQ/freeze/exception ports are present and wired (`T:9–11,256–258`; `V:525–527`), not proof of host interrupt delivery, PR quiescence or error reporting.
- Preserve the prior one-in-flight/completion contract and verify acceptance/ack balance, reset/backpressure behavior, final-byte masks and downstream-write visibility. HLS native translators have **USE_WRITERESPONSE0** (`AE:4318,4584–4685`); local accepted-write accounting is not proof that AXI writes reached physical memory.
- Mapped synthesis, fit/STA, functional/numerical traffic, DDR operation and hardware acceptance remain unperformed by this result. **DDR simulation SKIPPED BY USER** remains unchanged.

**Accept the exact native generation and connected analysis/elaboration milestone with these limits.** Do not promote it to a warning-free, DRC-clean, integrated-AFU or numerical result. Source connectivity is not function acceptance. Only this report was created/updated; review activity was local reads, hashing, parsing and static arithmetic. No SSH, native vendor/simulator execution, hardware access, source edits, git operations, publication or task transitions occurred.

## Report integrity

The finalized full-file SHA256 is computed after this file is written and supplied in the review handoff. It is not embedded in its own hashed contents, which would change that digest.
