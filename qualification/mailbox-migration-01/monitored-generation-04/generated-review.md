# Generation04: actual RTL and limited-stage integration decision

## Decision

**Accept generation04 as successful standalone mailbox, child, and enclosing-parent HDL generation, with verified top-level mailbox backpressure connectivity and separate reset wiring. Do not promote it as the minimal-delta maintained BSP or as functionally qualified RTL. `ready_for_build=false` remains unchanged.**

This is stronger evidence than parent03's saved error flag: real RTL and source manifests were produced, all three recorded commands returned 0, and the complete logs contain no Error diagnostics. Conversely, generation success does not repair parent03's saved association metadata or prove traffic/reset behavior. Prefer the already-launched generation05 candidate based on accepted refresh02 leaf/child plus ORIGINAL parent/sibling inputs if its actual results meet the finite criteria below. Generation05 outputs were neither read nor polled here; no completion is assumed.

Only this report was created. No remote access, vendor tools, tests, source edits, or readiness changes were performed.

## Evidence integrity and generation outcome

Evidence aliases are local to this directory: **R** = `result-evidence.json`, **S** = `generated-source-evidence.json`. RTL line numbers below refer to decoded content under S's exact keys, not the single-line JSON container. Also read `../monitored-parent-03/output-review.md` and `../monitored-refresh-02/output-review.md`.

- Recomputed and matched all **12 R payload hashes and 8 S payload hashes**. Each of the eight S payloads also matches its `after.json` inventory SHA-256.
- R's after inventory has **841 entries**. All **36 pre-existing input records** remain unchanged against `before.json`. Generation04 did not undo or further rewrite the parent03 input changes.
- S contains three synthesis tops, their three QIPs, and the two Qsys systems. Child SHA-256 remains `e2cdea661181a1490e938f41aaf5c62f059ee9b264d507d8847ae7591cb64bac`; parent remains `cdb982ac90486b0e820e036b97c097a9d2530524eaa2c77217d5909b30267d13`, matching parent03, not the refresh02-only child baseline.
- Invocations use Quartus/Platform Designer 26.1.1, part `AGFB027R25A2E2V`, synthesis and ModelSim simulation generation, and the custom arbiter/IRQ search paths. Generating simulation sources is **not running simulation**.

| Stage | Recorded rc | Warning occurrences | Error occurrences |
|---|---:|---:|---:|
| Leaf | 0 | 0 | 0 |
| Child | 0 | 6 | 0 |
| Parent | 0 | 51 | 0 |

Counts cover full logs, including repeated simulation/synthesis or nested generation diagnostics. They are not counts of independent defects. The leaf log reports 4 modules/5 files; child reports 56 modules/53 files; parent log explicitly reports `Done "bw_840_support" with 38 modules, 52 files` (lines 991 and 1065), then nested child completion. These are tool reports, not invented compile/test results.

## Actual interfaces and backpressure

**Leaf:** `bwbmc/ip/bmc_spi_sub/sdm_mailbox/synth/sdm_mailbox.v`, lines 6–44, exposes 4-bit address, 32-bit data, scalar read/write/readdatavalid, and scalar output `avmm_waitrequest`. Line 42 connects that output directly to the generated mailbox implementation's same port. The generated parameters retain CMD/RSP depths 1024, urgent depth 4, all three memory-block selections 1, DEBUG/URGENT/STREAM/OFFLOAD 0, STATUS 1, STREAM_WIDTH 32, and timeout 10000.

**Child:** `bwbmc/bmc_spi_sub/synth/bmc_spi_sub.v` contains this concrete, nonconstant instance-level path:

```text
sdm_mailbox.avmm_waitrequest
  -> mm_interconnect_2_sdm_mailbox_avmm_waitrequest
  -> mm_interconnect_2.sdm_mailbox_avmm_waitrequest (input)
  [generated interconnect implementation]
  -> mm_interconnect_2.sdm_pipeline_m0_waitrequest (output)
  -> sdm_pipeline_m0_waitrequest
  -> sdm_pipeline.m0_waitrequest
```

Evidence: mailbox connection line 483; interconnect instance/type at 633, upstream output at 635 and mailbox input at 650; pipeline input at 500. Pipeline `s0_waitrequest` is separately wired to `mm_interconnect_4_sdm_pipeline_s0_waitrequest` at 490, consumed by interconnect4 at 741. Interconnect4 connects the host and SPI SDM bridge master waitrequest ports at 714 and 724. There is no constant or empty-port replacement on the mailbox-to-interconnect2-to-pipeline top-level path. A serialized `terminationValue=0` is not a tied-off waitrequest.

**Parent:** `bwbmc/bw_840_support/synth/bw_840_support.v` has **17-bit AXI AW/AR addresses and 64-bit W/R data**, lines 8, 15, 24, 32. Child `host_sdm_waitrequest` feeds `host_sdm_pipeline_m0_waitrequest` at 316; the parent pipeline consumes it at 235. This preserves actual upstream connectivity rather than merely interface names.

**Proof boundary:** these tops instantiate the implementation modules; their bodies are not among S's eight payloads. The evidence proves port connectivity, not that a downstream stall actually propagates with correct latency/allowance or that mailbox internals never substitute a constant. Do not call the entire path functionally verified from these tops alone.

## Actual reset and clock wiring

The parent connects `sysclk_bridge_out_clk_clk` into the child system clock and connects `sysrst_bridge_out_reset_reset` into child `system_rst_reset`; its separate `sdm_reset_reset` input directly feeds the child's SDM reset (parent lines 338–340). No merger of these reset domains appears in the generated parent.

Child RTL establishes:

- `system_rst_reset -> system_rst_bridge -> rst_controller -> sdm_pipeline.reset` (lines 542–545, 774–777, 489). The system controller selects `OUTPUT_RESET_SYNC_EDGES="deassert"`, depth 2, minimum assertion 3.
- `sdm_reset_reset -> sdm_reset -> rst_controller_001 -> sdm_mailbox.in_reset_reset` (514–515, 837–839, 476). This controller selects **`"both"`**, depth 2, minimum assertion 3; do not describe its generated behavior solely from the proxy's `DEASSERT` metadata.
- Interconnect2's mailbox-side reset uses `rst_controller_001_reset_out_reset` (651). Its upstream translator reset uses `rst_controller_002_reset_out_reset` (652), sourced from the system reset bridge (900–902), also configured `"both"`.
- Mailbox, pipeline, reset bridges and controllers use the system clock net.

This is real separate wiring and explicit controller configuration, **not proof of safe independent reset sequencing with transactions outstanding**. This review does not prescribe combining resets or claim external wrapper reset policy changed.

## Warning disposition and parent03 metadata

The six child warnings are two occurrences each of unconnected `bmc_to_pcie_irq_gen.Ext_irq_interface`, `pci_to_bmc_irq_gen.Ext_irq_interface`, and `system_arbiter.hps_gp_if`. Child RTL corroborates open IRQ inputs and arbiter `hps_gp_o()`/`hps_gp_i()` (e.g. 470, 533–534). These known vendor integration issues remain open, not fixed by mailbox regeneration.

Parent warning occurrences comprise:

- **10** version substitutions: two each for three bridges (20.0.1 -> 20.1.0), sysid (19.1.3 -> 20.0.0), and AXI bridge (19.3.1 -> 19.10.3).
- **35** missing interface-parameter metadata warnings: AXI m0/s0 attributes including optionalAssociatedReset, wakeup/unique-ID/poison/trace/check/security/user-data/channel-termination attributes, plus s0 noNarrowTransfer; bridge waitrequestTimeout/optimizedReadsWithBE; sysid waitrequestTimeout (parent log 895–929).
- **6** repeated nested child open-conduit warnings.

Thus ORIGINAL saved sibling inputs do not guarantee original implementation versions under the new catalog: even unchanged parent IP inputs selected newer implementations here. That distinction must survive the minimal-delta comparison.

Parent03's blank proxy association values remain in the unchanged captured parent Qsys (decoded `bmc_spi_sub_0.componentDefinition`); the saved regression is real. Nevertheless, generation04 has actual clock/reset connections and no diagnostic establishing that those blanks broke generation. The generator may infer relationships from nested implementation/wiring. Do not claim inference restored saved metadata, or promote the earlier suspected cause of `altera_has_errors` into a proven functional defect. No flag was forced false.

Parent RTL leaves cardtest and xcvr master ports open, including waitrequest (291 and 305), and the mailbox IRQ is not exported by the enclosing parent. These are known pre-existing vendor integration limitations, not newly repaired windows. No endpoint or default slave is invented here.

## Source manifests and narrowly bounded implementation closure

Normalized every `[file join $::quartus(qip_path) "..."]` reference in the three captured QIPs relative to its QIP directory: **9 leaf, 48 child, 50 parent references; all are present in the after inventory**. These counts include metadata as well as HDL references. There are no unparsed file-join expressions in these QIPs. In particular the leaf QIP names both its wrapper and mailbox core, and child QIP line 572 names the exact interconnect2 implementation. Inventory presence is evidence of generated artifacts; uncaptured bodies are **not missing generated files**. This is not a whole-project Quartus source-resolution/elaboration result.

If a stronger claim than top-level connectivity is required, the finite first implementation roots are already named and inventoried (paths relative to the recorded scratch root):

1. `bwbmc/ip/bmc_spi_sub/sdm_mailbox/altera_s10_mailbox_client_2300/synth/sdm_mailbox_altera_s10_mailbox_client_2300_liqzikq.v`
2. `bwbmc/ip/bmc_spi_sub/sdm_mailbox/altera_s10_mailbox_client_core_2100/synth/altera_s10_mailbox_client_core.sv`
3. `bwbmc/bmc_spi_sub/altera_mm_interconnect_1920/synth/bmc_spi_sub_altera_mm_interconnect_1920_wynu5pi.v`
4. `bwbmc/ip/bmc_spi_sub/sdm_pipeline/synth/sdm_pipeline.v`
5. `bwbmc/ip/bmc_spi_sub/sdm_pipeline/altera_avalon_mm_bridge_2010/synth/sdm_pipeline_altera_avalon_mm_bridge_2010_tex5a4i.v`

Trace only reachable waitrequest/ready logic from these roots, including instantiated translators/adapters if the root delegates that signal. The precise submodule dependency set cannot be asserted without those bodies. No broad acquisition of the entire generated tree is needed to resolve the immediate real-versus-constant question. A focused downstream-stall/held-command and reset exercise belongs to functional verification, not another round of catalog review; none was run here.

## Minimal-delta integration criteria

1. Prefer generation05's refresh02-only leaf/child plus original parent/siblings **if** its completed evidence demonstrates generation success and preserves the interfaces, backpressure wiring, reset split, address windows and mailbox parameters above. Do not wait/poll on generation05 as part of this report or assume it passed.
2. Compare saved-input deltas separately from catalog-selected implementation changes. Generation04 inherited parent03's broader SPI/eight-bridge/RAM changes and lost parent associations; it is not a mailbox-only candidate. Avoid importing those saved changes merely because generation04 returned 0.
3. Verify exact source manifests and generated roots used for integration; no missing-role or constant waitrequest substitution, no accidental 17/64 parent boundary change, and no collapsed SDM/system reset. Keep the original parent association metadata unless an actual required change is demonstrated.
4. Treat known open external IRQ/hps_gp_if/cardtest/xcvr issues as explicit existing scope limitations, not blockers demanding unrelated repairs before this limited mailbox stage and not solved functionality.
5. Continue with concrete RTL integration/targeted elaboration and focused backpressure/reset verification once the preferred candidate is available. Generation04 suffices as a generated-topology reference now; it does not establish synthesis, timing, simulation correctness, hardware readiness, or whole-BSP acceptance. **All readiness remains false.**
