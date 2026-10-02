# Actual STA timing/coverage review29

**ACCEPT WITH FINDINGS — completed numerical 3.000 ns analysis and offline assembly preparation only.** Full timing/CDC acceptance remains pending the specific current-PIM coverage discriminator below and the separate diagnostic/reset disposition. This is not assembly execution, deployment or hardware authority.

Reviewer: GPT-6 (`gpt-6-astra-900k`, `openai-codex`), substituting for unavailable GLM5.3. Local file reads, SHA256 and text/JSON reductions only; no project imports, tests, Tcl/CMake/vendor execution, remote access, Git or hardware. Runtime controls/implementation remain reviewer28’s scope; whole diagnostic/reset/electrical disposition remains reviewer30’s.

## Binding and analysis state

Independently verified **204/204 frozen members**, sizes and SHA256, zero mismatches: [freeze27](actual-result-freeze27.json#L1-L6) SHA256 `92fdf20b9ef8413426dc83bc994c988a8917582998bfda5d2fabd81e5ef0d8e9`. Raw result matches `45f6185771f6538548faaa2916c597cde5bb529c0ddd06ff5446e2dd1512a07d`. The captured 15 preservation checks are all true, including 4001 critical inputs, 280 physical/static members and original fitted/mapped/static databases. No new fit/synthesis/assembly occurred. [Acquisition](RESULT26.md#L5-L11); [protected roles](source-api-review07.md#L13-L20).

The native report identifies **final snapshot, final timing models and sign-off cell/interconnect delays**. I inspected bounded native tables using fixed column borders, not just selected-panel JSON. [Analysis state](completion24-readback/reports/ofs_pr_afu.sta.rpt#L2506-L2528); [panel inventory](report-panels25.json); [section locator](report-sections25.json).

Raw summaries independently reconcile **923 Type/Slack records**, with 127 TNS-bearing clock aggregates, 650 skew and 146 net-delay records; the hook has 635 passing/zero failing records. Every parsed Slack is finite/nonnegative and every present TNS is zero. The established full-record review reports no invalid/unresolved records. These views overlap; they are not distinct physical-path counts. [Verification](native-result-verification25.json#L15-L42); [contract](timing-coverage-review07.md#L19-L28).

## Actual application requirement

The application source selects bank0, not a user PLL. Native clock `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk` has **Period 3.000 ns**. Four actual `map_banks[1].output_bank.shim` ready→`completion|accepted_bytes[22,26,28,23]` setup paths retain that launch/capture clock, **3.000 relationship, 0.002 slack, No SDC Exception on Path**. This is propagated endpoint evidence, not merely a clock declaration or exhaustive passing-path detail. [Source](completion24-readback/external/15-ofs_plat_afu.sv#L6-L28); [clock](completion24-readback/reports/ofs_pr_afu.sta.rpt#L2784); [four exact summaries/relationships](selected-path-evidence26.json#L7-L85); [native first path](completion24-readback/reports/ofs_pr_afu.sta.rpt#L158135-L158157).

All five applicable bank0 families occur at every available corner; all TNS values are 0.000. Values below were checked against raw hook lines:

| Corner | Setup | Hold | Recovery | Removal | MPW (ns) |
|---|---:|---:|---:|---:|---:|
| [Slow vid2 100C](completion24-readback/reports/clocks.sta.pass.summary#L1-L435) | .005 | .000 | .667 | .242 | .715 |
| [Slow vid2b 100C](completion24-readback/reports/clocks.sta.pass.summary#L509-L943) | .002 | .002 | .670 | .245 | .745 |
| [Fast vid2a 0C](completion24-readback/reports/clocks.sta.pass.summary#L1025-L1455) | .852 | .007 | 1.239 | .161 | .943 |
| [Fast vid2a 100C](completion24-readback/reports/clocks.sta.pass.summary#L1533-L1963) | .678 | .004 | 1.066 | .169 | .905 |
| [Fast vid2 100C](completion24-readback/reports/clocks.sta.pass.summary#L2041-L2471) | .667 | .001 | 1.058 | .168 | .881 |

**Printed zero is not positive margin.** The 2 ps setup result is accepted without tolerance or relaxed requirements. The ordinary timing option and hook do not promise all passing endpoint detail. [Reporting limits](timing-coverage-review07.md#L36-L41).

## User-clock reconciliation and precedence

The main and post-update hook clock tables contain the same 81 complete rows; all 81 native clock-status rows say Constrained. Both show user-PLL outclk0 at **5.000 ns/200 MHz**, outclk1 at **10.000 ns/100 MHz**, and unchanged bank0 3.000 ns. Metadata is low100/high200. [Hook clocks](completion24-readback/reports/clocks.rpt#L8-L29); [status](completion24-readback/reports/ofs_pr_afu.sta.rpt#L216269-L216354); [metadata](completion24-readback/reports/user_clock_freq.txt#L1-L3).

I recomputed the Work24 comparison: identical 81-name sets, but two user outputs changed from 312.5/156.25 MHz; 34 other rows differ only in printed Frequency, not periods/other fields. Thus **not byte-equal static/current clock tables**, and not measured hardware frequency. [Comparison](clock-comparison26.json#L1-L268).

The actual helper computed user-clock Fmax values 334.89/181.68, saved 200/100 and reread SDC. The report’s 206 successful SDC-load rows are two matching 103-entry sequences; PIM and user-clock SDC appear in both. This explains repeated overwrite diagnostics but does not waive ineffective exceptions. Fmax selection excludes hold/removal; its 10000 MHz missing-data fallback receives no acceptance credit. [Actual helper](completion24-readback/operation/timing.log#L3128-L3156); [reload](completion24-readback/operation/timing.log#L3650-L3668); [implementation](copy01-readback/project/ofs_partial_reconfig/user_clock_freqs_compute.tcl#L170-L284); [SDC sequence](completion24-readback/reports/ofs_pr_afu.sta.rpt#L2542-L2752).

## Current PIM CDC, skew and net delay

**Current-instance skew coverage is real:** each corner contains the same 40 directed pointer-bundle selectors across 20 FIFOs: 20 selectors under `primary_axi`, ten under each `map_banks` instance. Both read/write pointer directions are present. Global minima within those groups are respectively **1.359/1.964/2.038 ns**; requirements are 1.701 or 2.400 ns. This replaces—not rehabilitates—the obsolete `ahls_binding` selectors. These are bundle constraints, not enumerated individual bits. [Slow table](completion24-readback/reports/ofs_pr_afu.sta.rpt#L3129-L3191); [remaining corner tables](completion24-readback/reports/ofs_pr_afu.sta.rpt#L3235-L3783).

The two **generic PIM net-delay** rows are present, not absent: read-pointer slack1.400, write-pointer slack1.407, required1.701 ns, actual .301/.294 ns, worst Slow vid2. Their exported selectors match the generic source recipe, using 0.8×destination period. Local PIM SDC additionally hashes to the admitted critical-input binding `d0eee39ec72c5cf90ac4ba9892f8129e896322cd4d2be11c94f0d871af011c2f`. However these aggregate rows do not enumerate their current-instance membership. [Native rows](completion24-readback/reports/ofs_pr_afu.sta.rpt#L3838-L3839); [export](copy01-readback/project/ofs_top.out.sdc#L1594-L1595); [binding](completion24-readback/control/prepared-inputs15.json#L13749-L13753); [PIM recipe](../../ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl/utils/quartus_ip/ofs_plat_utils_avalon_dc_fifo.sdc#L18-L39).

Across the 20 CDC matrices, bank0↔bank1 setup/hold cells each report **35 timed/one cut endpoint**, with ±200 ns relationships—not ordinary 3 ns CDC closure. Host/sys↔bank0 setup/hold cells are cut (65 bank0→sys; three sys→bank0). This is consistent with the exported global sys asynchronous group; cut transfers receive no ordinary max/min-delay pass credit, and the PIM recipe explicitly warns about such cuts. Matrix totals cannot assign every current `primary_axi` endpoint to a constraint. [Matrices](completion24-readback/reports/ofs_pr_afu.sta.rpt#L4026-L5643); [group](copy01-readback/project/ofs_top.out.sdc#L883-L885).

Metastability reports find 1164 chains per corner, zero timing-violation-uncomputable chains, but **87 excluded**, with shortest chain one register. The reported design MTBF is not complete recognition, protocol proof or a hardware reliability guarantee. Current CDC-50101 rows include intentionally cut reset/enable distributions; do not reinterpret them as data-pointer waivers. [Metastability](completion24-readback/reports/ofs_pr_afu.sta.rpt#L3941-L4018); [current cuts](completion24-readback/reports/ofs_pr_afu.sta.rpt#L219135-L219179); [primitive intent](../../ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl/utils/prims/ofs_plat_prim_clock_crossing_reg.sv#L101-L125).

The inspected high CDC panels identify static protocol-checker/PCIe/user-PLL cases, not current `primary_axi`/`map_banks` endpoints; this is bounded panel evidence, not complete CDC correctness. [High CDC details](completion24-readback/reports/ofs_pr_afu.sta.rpt#L216660-L216770).

## Retained findings and smallest discriminator

The full ignored-constraint panel contains six no-path exceptions, 14 fully overridden exceptions and 12 erroneous **old `ahls_binding` skew** assignments. The empty-filter panel has 31 rows, including 24 old FIFO endpoints; neither panel names current `primary_axi`/`map_banks`. Overridden multicycles receive no credit. Zero illegal/unconstrained clocks coexists with TDI/TMS 78 input pairs and TDO/BMCIRQ ten output pairs, in both setup/hold. No waiver is invented. [Exceptions](completion24-readback/reports/ofs_pr_afu.sta.rpt#L219014-L219093); [I/O](completion24-readback/reports/ofs_pr_afu.sta.rpt#L216255-L216396).

**Remaining full-coverage discriminator:** expand only the two existing PIM net-delay selectors at export1594–1595 against the 20 current FIFOs already named by the 40 skew selectors. Establish resolved pointer→first-stage membership, destination-clock-derived limits and effective timed/cut precedence in both directions/all five corners. This is the smallest missing endpoint-level fact; aggregate labels, source wildcards and MTBF cannot substitute for it. No new constraint, generic framework, refit or vendor-internal requalification is requested. It blocks an endpoint-complete timing/CDC acceptance claim, **not offline assembly-package preparation**; assembly execution still needs parent integrated acceptance and controls.

The missing selected EMIF1 bit243 Path Summary is **detail absence, not a failure**. Valid static carry-forward uses the unchanged physical root/SDC/EMIF clocks and accepted Work24 five-corner transfer; no CPA restart or unchanged fit is justified. [Static acceptance](../fim-build-24/PHYSICAL-ACCEPTANCE47.md#L3-L29); [preservation](RESULT26.md#L9-L11). Retain additional reset cycles **3sys/7bank0**, four electrical omissions and the unwaived signoff findings (23/88 rules failed, including 7/34 High) for reviewer30/parent disposition; hardware proof is not a prerequisite to accepting this completed analysis. [FIT obligations](../fim24-caps03-physical01/fit-diagnostic-reset-review35.md#L19-L44); [actual signoff counts](RESULT26.md#L33-L37).
