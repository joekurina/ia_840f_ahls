# Work22 — independent completed-generation review21

## Decision: ACCEPT WITH FINDINGS

Accept the **completed Quartus Prime Pro 26.1.1 Build 130 IP generation**, with
structural eligibility to proceed to separately authorized native implementation.
No unfinished-generation, native-error, wrong-effective-device or QIP-closure
blocker was found. This is **not** synthesis/elaboration, Fitter, STA, functional,
data-copy-readiness or hardware acceptance; `ready_for_build=false` is not overridden.

Scope: immutable local generation/source captures only, campaign
`migration-ofs-2026.1-quartus26.1`. No workstation/SSH, vendor tools, source/test
execution, git mutation or hardware access. Only this report was written.
Reviewer: **gpt-6-astra-900k / openai-codex**, substituted for preferred GLM5.3,
which was unavailable through the configured delegation tool (already disclosed).

Source context is the consumed [reconciliation04](ip-source-reconciliation04.md)
and [receipt07](ip-review-consumed07.json): FIM
`866c25bb166810f65aae4f6b15374d0a89810e69`, common
`147cae890b7d1245301cf5cde229f761b287b70d`, retained PIM
`3c21189e728009d4c492fa2be54c0ab1008b06dc`.
The captured generation authority agrees with **39 preserved / 44 changed**
selected definitions; its preserved set includes all 26 BMC and eight remote-STP
inputs. The 40 additional donor imports are outside the selected 83-entry set.
The selected four-line PCIe divider SDC is retained, not the parked guarded
alternative; its bound SHA-256 is
`3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814`.

## Independently verified acceptance evidence

- **Actual completion:** [N] lines 31–114 and all generation-completion records
  reconcile to the same **83 unique inputs** in [I]; all 83 primary calls completed.
  All **94** primary/nested generation reports state 26.1.1 build130, explicit
  `Agilex 7 / AGFB027R25A2E2V`, and synthesis-fileset completion. [N]:3038–3044
  records **0 errors / 820 warnings**. [S] and
  [completion-event](regeneration11-completion-event.json) give
  **native/effective/outer = 0/0/0**. No error/critical-warning or reused-generation
  message was found. The regeneration17 snapshot records no active vendor
  process or native lock; this review did not inspect current workstation state.
- **Byte bindings:** independently hashed both compressed payloads against their
  collection receipts, then compared all **9 regeneration readbacks** and
  **295 metadata readbacks** to the embedded bytes, sizes and hashes. The metadata
  capture contains exactly 94 QIPs, 94 SOPCINFOs, 94 generation reports and 13
  selected PLL/debug auxiliaries: **17,679,803 bytes**, all matching [MP] and [I].
  [I] inventories **2,106 unique generated files across 83 nonempty roots**.
  This verifies the captured inventory and the collected subset, not a local
  rehash of all 2,106 remote file bodies.
- **Full captured QIP closure:** independently parsed every `*_FILE` assignment
  in all 94 QIPs, including instance-level SDC assignments; traversed from the
  83 selected roots. All **94 QIPs are reachable**, with **1,519 file edges**:
  1,376 to inventoried generated outputs and 143 to authority-bound source inputs.
  No unparsed file expression, missing hash or target outside WORK. The independently
  reconstructed edge/path/hash set equals [C]. This is QIP file-reference closure,
  not execution/elaboration of referenced Tcl or RTL.
- **Effective target:** every SOPCINFO root has board family/OPN/speed **Agilex 7 /
  AGFB027R25A2E2V / 2**. Also checked every nested sysinfo `DEVICE_FAMILY`,
  `DEVICE` and `DEVICE_SPEEDGRADE` parameter: no conflict. Generic interface
  `deviceFamily=UNKNOWN` or saved model sentinels are not competing device targets.

## High-risk native evidence

| Area | Observation and disposition |
|---|---|
| Two DDR channels | [E0]/[E1], scoped to `emif_0`/`emif_1`, retain DDR4 DQ64/DQS8, row17/column10/bank2/bank-group2/CS1, DDR4-2666, 1333.333 MHz memory / 33.333 MHz reference, ECC disabled. Formats remain **DISCRETE / RDIMM**, respectively. Both generated model SOPCINFOs retain the corresponding formats and row17 geometry. No donor row16 substitution. This does not requalify encrypted vendor internals or prove PHY placement/calibration. |
| PCIe / PF1 | [PC] retains Gen4 1x16, two PFs, PF0 VF count1 / PF1 VF count0. Independently compared the **95 selected settings** in semantic-check20 against both the bound saved PCIe XML scope and actual SOPCINFO: no differences, including PF1 BAR/MSI-X/identity fields and AXI-Lite requests **core16=100; core8/core4_0/core4_1=250**. This is configuration preservation, not PCIe operation or exact physical clock proof. |
| PLL | [P] retains requested MHz **470,100,235,630,50,117.5,350**. Its actual generated `outclk0..6` rates are **470000000,100714286,235000000,705000000,50357143,117500000,352500000 Hz**. These exactly match the captured Work21 interface rates. [PR]:285 declares **1410.0 MHz VCO**; counter/rate evidence is consistent with divisors 3,14,6,2,28,12,4. The four frequency-substitution warnings are real, not exact-request passes. Preserve the solution; check actual fitted PLL/PHY clocks, divider resolution and full timing under the retained 3.000 ns policy. Do not substitute nominal 100/630 MHz for actual rates or call generation fitted proof. |
| SCJIO | Fresh native26 wrapper [J]:42 declares `CLTAP_CONNECTION = 0`; line65 forwards it to `altera_sld_host_endpoint`. The generated soft-core leaf also declares/selects0. This closes the stale-generated-wrapper concern for **generation**; the prior25 compatibility failure is not evidence of a26 blocker. Native26 synthesis must establish primitive elaboration. No JTAG operation is requested or implied. |

## Warning reconciliation and actionable findings

Reparsed every native warning occurrence with line numbers, including repeats;
the resulting 820 rows match [W] exactly and reconcile to [N]:3039. Generation
reports repeat diagnostics and were **not** added again to the native footer count.

| Ledger class | Count | Disposition / smallest subsequent check |
|---|---:|---|
| Missing interface metadata | 184 | **Unresolved integration risk, not a generation failure.** Remote-STP18, BMC support70 and BMC SPI96 occurrences include reset/translator, narrow-transfer and waitrequest metadata ([N]:117–1365). No empty-generation symptom was found. Carry named interfaces into the ordinary native elaboration review; inspect actual connectivity/default consumption before any targeted source change. Do not silently rewrite these settings or invent adapters. |
| `capability mismatch` | 540 | **528** APF/BPF outstanding/acceptance/issuing properties are16 versus1; **12** are remote-debug DFH value mismatches, not AXI capability warnings. Native [B] still exposes16 on the BPF PCIe/FME generic proxies while their generated leaf SOPCINFOs expose1. [Source16](capability-warning-source16.json) establishes inheritance only for those two examples; it neither resolves effective behavior nor clears all540. Preserve this limitation; inspect effective generated path/backpressure and remote DFH consumers in subsequent integration evidence, without redesigning the trusted components on warning prose alone. |
| Foreign saved device | 11 | **Wrong-effective-target concern resolved for this generation**, not permission to reuse donor targeting. Native warnings name saved `A5ED065BB32AE6SR0` ([N]:1439,2670–3018); all94 actual targets above are the board. Keep explicit family/part selection in later stages. |
| Component-version selection | 17 | **Accepted native catalog selections**, all matched to generated module kind/version. Examples: MM bridge20.0.1→20.1.0, SPI bridge19.1.3→20.0.0, JOP1.2.0→1.2.2 ([N]:2295–2926). Do not describe every change as cosmetic or infer functional equivalence from version selection. Retain the selected versions for native elaboration. |
| Simulation model has no ports | 2 | **Nonblocking for this synthesis-fileset stage** ([N]:1528,1543; model reports line4). These are `ed_sim_mem{,_group1}`, not the two physical EMIF instances. No simulation-model or memory-function pass is claimed. |
| Other | 66 | Fully decomposed below; not a blanket waiver. |

The **66 other** occurrences are: project-setting mismatch38; nested memory
project/revision absent12; missing remote-debug software macros6; PLL actual-rate4;
unconnected BMC conduits3; parameterization umbrella1; advanced IOPLL reconfiguration1;
TCK-ENA support restriction1.

- **Target/settings (38+12):** effective family/part checks close the wrong-device
  concern, not consumption of all project assignments. Let the subsequent native
  project establish those assignments; no repeat generation is justified by these
  messages alone.
- **BMC3 ([N]:1226–1228):** the two `Ext_irq_interface` inputs and
  `system_arbiter.hps_gp_if` are the warned conduits, not a finding that required
  PF1 IRQ outputs vanished. Generated metadata retains the IRQ sender outputs.
  Keep the unchanged board definitions; check unused-input treatment and required
  PF1/IRQ connectivity in native elaboration, rather than disconnecting active IRQs
  or replacing BMC with donor PMCI. This snapshot does not prove tie-off behavior.
- **Debug7 and TCK-ENA1:** six missing software-macro declarations plus one
  parameterization umbrella accompany the separately counted DFH mismatches
  ([N]:126–134,495–503,522); retain them as metadata/consumer integration findings.
  The TCK-ENA message ([N]:2862) limits supported debug consumers; preserve the
  intended remote-STP configuration, without using hardware/JTAG to close this review.
- **PLL4 and reconfiguration1:** fitted clocks remain required as above
  ([N]:2779–2782); the advanced-reconfiguration warning ([N]:2744) is not proof
  of a valid runtime clock configuration. Retain the existing configuration policy;
  this review approves neither dynamic reconfiguration nor a different clock solution.

**Next-stage boundary:** proceed with the parent's separately scoped native work,
carrying these findings. Header/UUID/persona preparation, native compile, full STA,
data-copy readiness and hardware remain unaccepted here. No new protocol campaign,
vendor-internal requalification or safety-framework review is introduced.

## Exact evidence bindings

Links below are relative to this report. SHA-256 values were computed locally;
[RR]/[MR] are the **compressed** payload hashes used by their collection receipts.

| ID / artifact | SHA-256 |
|---|---|
| [N] — Native log | `b7d9066b3c2e1f7c770ccc1563e699bdf93a09b5eb1da6d307d87af57ce237bf` |
| [S] — Native status | `662203d5cfd752b64c1dd7a4fe946c95b6ecc58f1664e0bb7d3a4a1fa587b72e` |
| [I] — Generated inventory | `0e7567161fa76fd55c60c00163badfdd44126e5c18c07ee1278c5a047e64925c` |
| [RR] — Regeneration raw capture | `0aa368ea1dde95c870e50e132f6cb00151da335909355f607e4afd43ae6ac0a2` |
| [MR] — Metadata raw capture | `c799a1ff562a40a1f85919876c1374ca0e93b7bd3dd5d6704af784f2b0cef7ae` |
| [MP] — Metadata plan / per-file hashes | `1d925a6c3d5e063c9927a02053607fbbe9580e3b817c693434c9f8faa09433b3` |
| [C] — QIP closure19 | `a12d10f4b9208aa3350aa033bf184974880aeb35660cfe83a1f6fc837a292af2` |
| [W] — Warning ledger17 | `90a37926497531915bbbd078e78bf2a708759fdf42c03377732e8f93acace00b` |
| [E0] — EMIF0 SOPCINFO | `d02dec89a289496b0adfd31ca3b848f4db8645024ced4b01a94f055fc40498d7` |
| [E1] — EMIF1 SOPCINFO | `04e99b9e3904874c584ab5496d3bbe10ca880f124360083587611b927bba63a0` |
| [PC] — PCIe SOPCINFO | `37f363b112a76a0bb89bad6fc5d06fbdd9a597d65d807dbdbedf7bc92f53555c` |
| [P] — PLL SOPCINFO | `c980a43692a89ecbafdeecb8b1c4e4bfdf7f8cc9742f18a84442715679250cf2` |
| [PR] — PLL generated RTL | `b66b89ab8030a6beed7ffb593c13fca1030ef18dab1f0fc8401b06aa0a4f500d` |
| [J] — SCJIO endpoint wrapper | `5ffe88b0519b2a940b37486d842268fa4e888fc650a859663b9ef74a84db5930` |
| [B] — BPF SOPCINFO | `48d79ec20d87c42602307443efadb68bd302db68a5ceed47cafec304c90b88ce` |

[N]: regeneration17-readback/qualification/fim-build-22/operations/ip_regeneration/native.log
[S]: regeneration17-readback/qualification/fim-build-22/operations/ip_regeneration/status.json
[I]: regeneration17-readback/qualification/fim-build-22/regeneration17/inventory.json
[RR]: regeneration17-result.json.gz
[MR]: metadata18-result.json.gz
[MP]: generation-metadata-plan18.json
[C]: generated-qip-closure19.json
[W]: generation-warning-ledger17.json
[E0]: metadata18-readback/ipss/mem/qip/mem_ss/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_0/mem_ss_mem_ss_501_qm5zaka_emif_0.sopcinfo
[E1]: metadata18-readback/ipss/mem/qip/mem_ss/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/mem_ss_mem_ss_501_qm5zaka_emif_1.sopcinfo
[PC]: metadata18-readback/ipss/pcie/qip/pcie_ss/pcie_ss.sopcinfo
[P]: metadata18-readback/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/sys_pll.sopcinfo
[PR]: metadata18-readback/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/altera_iopll_2110/synth/sys_pll_altera_iopll_2110_3lkpvti.v
[J]: metadata18-readback/ofs-common/src/fpga_family/agilex/remote_stp/AFU_debug/scjio_agilex/altera_sld_host_endpoint_10/synth/altera_sld_host_endpoint_wrapper.sv
[B]: metadata18-readback/src/pd_qsys/fabric/bpf/bpf.sopcinfo
