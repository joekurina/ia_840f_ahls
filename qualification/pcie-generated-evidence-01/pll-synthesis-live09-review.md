# Work03 system PLL synthesis: live09 static review

**ready=false; ready_for_build=false; execution_authorized=false.** Captured synthesis PLL RTL is byte-identical to the retained simulation PLL wrapper and primitive source. Public output1 is C2, with M=141, N=10, C2=14: nominal **705000000/7 Hz**, not exactly 100 MHz. This closes captured-source identity and the previously missing system-PLL source/SDC/helper paths, not compiled-design identity or effective TimeQuest clocks. Core470 and the seven-output interface remain immutable.

## Scope and integrity

Only retained local JSON/text, SHA256/UTF-8 checks, literal parsing and Python Fraction arithmetic were used. No acquisition, workstation/network access, Tcl sourcing/evaluation, HDL/vendor execution, tests, decryption, source edits or commits. Only the two named review artifacts are written. “Simulation evidence” below is retained simulation-generated source, not a simulation run.

Read `rendered-constraints-live06-review.md` and `generated-hdl-review.md`, then independently inspected their cited `pcie-generated-live03.json` PLL payloads. All live08/live09 payload lengths/hashes and all live03 payload integrity checks pass; all three capture error arrays are empty. HIP was integrity-checked only, not re-reviewed. Live07 records 32 examined entries, three matches, no errors and complete_within_scope=true for its bounded PLL-root discovery; this is not a 32-file payload inventory or whole-design closure. Byte integrity is not remote freshness.

### Container checks

- `pll-manifest-discovery-live07.json`: 985 bytes; SHA256 `f6575a764147878b846257bdafeb4e7321c52ad01daf87e2be09e4ba89615d77`.
- `pll-synthesis-manifest-live08.json`: 15461 bytes; SHA256 `e394c363e621be8da69f3fe4db0b83bfaa59f5f7fad641f79ae022cdc428ca0e`.
- `pll-synthesis-bodies-live09.json`: 128991 bytes; SHA256 `f3bde783bdd113f9756fd2b9aa76cd39f5d71110dff17e00995eb9746c480621`.
- `pcie-generated-live03.json`: 7565580 bytes; SHA256 `9d7b704043d754e19b9d5089a28eb96f7e67060edcfb538d71d231d7aa9038ec`.

### Payload aliases

All line citations are 1-based decoded payload lines, not JSON lines.

- **Q** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/sys_pll.qip`; 7087 bytes; SHA256 `ca1cad10aa8b50fe6e6cb29da50bf8b26a5b21c19cbcb4974d9e1a836248718d`.
- **S** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/altera_iopll_2110/synth/sys_pll_altera_iopll_2110_3lkpvti.sdc`; 7038 bytes; SHA256 `038e50711591370119a751be0e290b5d6d35f46b27373347d54029cc80a58154`.
- **V** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/altera_iopll_2110/synth/sys_pll_altera_iopll_2110_3lkpvti.v`; 12573 bytes; SHA256 `b66b89ab8030a6beed7ffb593c13fca1030ef18dab1f0fc8401b06aa0a4f500d`.
- **A** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/altera_iopll_2110/synth/sys_pll_altera_iopll_2110_3lkpvti_all_ip_params.tcl`; 52297 bytes; SHA256 `c1194d1670a03b0cceb8ea4bb607ec38b433220d29ec6e73496ff9e238799ecb`.
- **P** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/altera_iopll_2110/synth/sys_pll_altera_iopll_2110_3lkpvti_parameters.tcl`; 13735 bytes; SHA256 `4f7bb129c6e20c20c610d687b5f97ee7236a982f2e624702a3d3666cc373e010`.
- **H** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/altera_iopll_2110/synth/sys_pll_altera_iopll_2110_3lkpvti_pin_map.tcl`; 42283 bytes; SHA256 `39dd38134ff2583a3a4053ae25d94a800740eb4a452e8237b3383a0dd497994b`.
- **T** = `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/synth/sys_pll.v`; 1173 bytes; SHA256 `497aeec1120e0832dd0406944aaf06f5f519cc54b88ffb98bab7918bab9ab044`.

## Literal registration and source identity

Q:45 registers V as VERILOG_FILE; Q:46 A as TCL_ENTITY_FILE; Q:47 P as TCL_ENTITY_FILE; Q:48 S as SDC_ENTITY_FILE with **no_sdc_promotion, no_auto_inst_discovery, read_during_post_syn_and_post_fit_timing_analysis**; Q:49 H as TCL_ENTITY_FILE; Q:51 T as VERILOG_FILE. All six referenced paths are captured, resolved literally relative to the QIP root; none were guessed by replacing a simulation suffix. Q:6 PRE_COMPILED_MODULE ON and Q:19 SYNTHESIS_ONLY_QIP do not prove this QIP or its source bytes were selected in an actual board compilation.

- T equals live03 `sim/sys_pll.v` byte-for-byte (1173 bytes, SHA256 497aeec1120e0832dd0406944aaf06f5f519cc54b88ffb98bab7918bab9ab044).
- V equals live03 `altera_iopll_2110/sim/sys_pll_altera_iopll_2110_3lkpvti.vo` byte-for-byte (12573 bytes, SHA256 b66b89ab8030a6beed7ffb593c13fca1030ef18dab1f0fc8401b06aa0a4f500d).

This supersedes generated-hdl-review's unknown synthesis identity **for these two captured PLL source bodies only**. It does not establish PCIe source identity, primitive library implementation, board hierarchy, fitted atoms, actual source selection or behavior.

## Counters, mapping and exact nominal arithmetic

T:6–29 preserves refclk/rst/locked and outclk_0 through outclk_6, directly forwarding into iopll_0; output1 is T:24. V:72–78 maps public outputs0–6 to primitive outclk[1]–[7]. V:132–140 enables C1–C7 and disables C0/C8. V:147–286 instantiates tennm_iopll; V:247 direct feedback, V:249–252 M bypass=false and high71+low70, V:256–258 N bypass=false and high5+low5. V:164–170 gives C2 bypass=false, high7+low7. V:109/312 wires dedicated refclk; V:280–285 selects clk_0, 100.0-MHz reference and 1410.0-MHz VCO. V:157–203 supplies all active C counts.

Under the explicit 100-MHz reference assumption, f=100000000×141/(10×C) Hz. Independent Fraction arithmetic reproduces every retained simulation-derived rate and rounded integer-Hz value. Request values are also literal A:168–174; actual decimal metadata A:204–210/783–789 corroborates but does not replace counters.

| Public output | Counter | C | Request MHz | Exact nominal Hz | Nominal MHz | Exact period ns | Delta % |
|---|---|---:|---:|---:|---:|---:|---:|
|outclk_0|C1|3|470|470000000|470.000000000000|100/47|0|
|outclk_1|C2|14|100|705000000/7|100.714285714286|1400/141|5/7|
|outclk_2|C3|6|235|235000000|235.000000000000|200/47|0|
|outclk_3|C4|2|630|705000000|705.000000000000|200/141|250/21|
|outclk_4|C5|28|50|352500000/7|50.357142857143|2800/141|5/7|
|outclk_5|C6|12|117.5|117500000|117.500000000000|400/47|0|
|outclk_6|C7|4|350|352500000|352.500000000000|400/141|5/7|

Output1 period is 1400/141 ns (approximately 9.929078014184396 ns), versus the PCIe conditional 10-ns request. Output3 remains 705 MHz despite the name clk_630m_noc. Names are not rate guarantees. No tolerance is granted. A:80/84 GUI M6/N1 and A:132–138 GUI C6 fields do not override the instantiated counters; A:422 and A:428–450 carry computed M141/N10, direct mode and seven clocks. A even retains hp_actual_vco_frequency_fp=600.0 at 781, illustrating why metadata fields cannot be treated indiscriminately as effective configuration.

## SDC dependency and timing procedure (text only)

1. **Closed literal Tcl-source edges:** S:31–34 sources P and H beside S; H:32–34 sources P again. Those bodies are captured. A is QIP-registered parameter metadata, but no reference to `pll_all_ip_params` occurs in S/P/H, nor is A sourced there. Do not treat A's GUI fields as the SDC runtime counter authority. P initializes the core-specific dictionaries (P:10–13).
2. **Seed data, not clock objects:** P:14–25 seeds refclk period10.000/half5.000 and unresolved IDs/flags; P:26–38 seeds N divide10. P:52–149 maps outclk1–7 to primitive pins and counter_index1–7 with multiply141 and C divisors3/14/6/2/28/12/4. In particular P:66–79 outclk2 / `__inst_name___clk_100m` is C2. All have source refclk initially; these are later rewritten, so 141/14 must not be interpreted as the final ratio directly from the reference. P:39–51 seeds m_cnt_clock divide1410; H later recomputes that from atom M (141 if atoms match source). This is an intermediate seed/runtime-update distinction, not proof of a bad final clock.
3. **Discovery and atom dependencies:** S:52–76 invokes entity mode, loads atoms/sdc_ext/design packages, attempts read_atom_netlist, clears cache and calls ai_initialize_pll_db. H:89–153 discovers `design::get_instances -entity` and populates per-instance dictionaries; H:880–891 selects the first IOPLL atom whose name starts with instname. S:95–105 later reports more than one matching atom; its “using IP generated parameter values” debug text does not negate H's actual atom reads and is not proof of uniqueness.
4. **Runtime rewrite:** H:519–559 substitutes instance names, reads atom parameters, resolves output pin/register collections, finds the first valid output and traces input clocks; no valid output invalidates generated clocks. H:289–328 requires exactly one node per pattern and checks existing defined clocks by target (H:849–878). H:565–637 traverses reference fanin with depth20 and input/user-clock searches with depth5; mux selection at H:334–378 uses ENUM_IOPLL_CLKIN_0_SRC/1_SRC. Actual instances/collections are not in these captures.
5. **Counter authority:** H:937–1005 reads atom feedback/compensated counter, TIME_IOPLL_REFCLK_TIME, M/N high+low/bypass and C0–C8 high+low/bypass/duty. Bypass means divide1, otherwise high+low. H:396–419 updates reference period/half-period rounded to three decimals. H:233–285 updates generated multiply/divide/duty from these atom values; phase remains seeded here. H:424–491 rewrites sources through N when not bypassed, using N master name in post-synthesis or N node otherwise; optional vcoph changes the source if present. This P has no vcoph entry. H:892–932 gives N 1/N, ordinary C M/C (or 1/C from vcoph), and special non-dedicated compensation alternatives. With atoms matching this direct-mode source, the intended chain is refclk → /10 N → ×141/C output, reproducing the exact table. That is a conditional static derivation, not an evaluated dictionary.
6. **Clock creation gates:** S:116–124 creates a base clock only for an FPGA input pin lacking an existing clock. S:130–174 branches on is_post_syn_sta: valid/nonexisting generated outputs use H:1042–1068 master-or-source helpers post-synthesis; M/N patterns can use virtual generated clocks (H:1025–1038/1072–1096). Other timing stages issue create_generated_clock -add with source, name, factors, phase, duty and target only if valid/nonexisting. S:45 derive_clock_uncertainty, S:49 display precision and S:176–182 reset false paths are commands, not evidence they took effect. Package/tool commands and their version semantics remain external runtime dependencies.

## Precisely closed versus still open

The live06 paragraph saying system-PLL manifest/registered SDC/RTL paths are unknown is now superseded by live07's bounded discovery and live08/live09 literal captures. The earlier lack of system-PLL companion timing-helper contents is also closed. The PCIe-local PLL is still a different entity; these helpers do not close its missing companion sources. Prior live06 PCIe RTL requests and PCIe timing bindings remain separate review boundaries, not inferred closed by PLL equality.

No missing direct S/P/H Tcl source target remains. Q:50 additionally names an uncaptured synthesis SOURCE_FILE:

- `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_03/ofs-common/src/fpga_family/agilex/sys_pll/sys_pll/altera_iopll_2110/synth/agilex_iobank_pll.ipxact`. This is a finite literal proposal only if further source-dependency closure is authorized, not a requested acquisition or a directory scan.

Q:7/20 ../sys_pll.ip, Q:11 sys_pll.sopcinfo and Q:13 sys_pll.cmp are other literal manifest metadata references, not missing SDC source commands. The live07-observed sys_pll.qgsynthc was not inspected. No inference about its contents is made. The tool-supplied tennm_iopll implementation and TimeQuest APIs are not source-closed here; no installation paths are invented.

### Exact remaining TimeQuest/consumer contract

1. Actual selected board source/header set, QIP inclusion and evaluated SDC/TCL entity load order/scope, including any precompiled database and tool-provided procedures.
2. Entity instances, atom selection/uniqueness, reference mux/frequency, feedback and M/N/C/bypass/duty values in the actual post-synthesis/post-fit atom netlist.
3. Pin/register collection cardinalities; refclk fanin traversal; existing defined-clock targets; is_valid/exists flags and evaluated base/generated dictionaries.
4. TimeQuest generated clock names, master/source edges, multiply/divide/phase/duty/period and targets for public output1 and its CSR/PCIe sink.
5. PCIe AXI entity current instance, get_ports p*_axi_lite_clk and p0_axi_lite_clk collections, A:133 target snapshot and A:162 exact lookup, whether A:164 executes and creates/replaces/coexists at the same sink, and A:192 AVMM master/target resolution (A here denotes prior live06 AXI SDC).
6. Documented consumer acceptance/tolerance for nominal output1 100.714285714 MHz, output3 705 MHz, output4 50.357142857 MHz and output6 352.5 MHz; no inferred tolerance or request change.
7. Actual timing closure, reset/CDC behavior, reference measurement and hardware behavior; overall Work03/mailbox generation recovery remains outside this static review.

The live06 PCIe integer100-derived conditional 10-ns source clock remains a **numerical nominal discrepancy, not a proven effective timing conflict**. Neither byte identity nor atom-reading procedure text establishes actual objects or whether the PCIe branch runs on the same sink. No correction to counters, requests, clock names, SDC or output enables is justified from this review alone. Preserve core470, all seven public outputs, AGFB027R25A2E2V, PTileGen4x16, PF0VF0 AFU/PF1 BMC, PF1 BAR0 Disabled, BAR2 width28/BAR4 width14, 64-byte/two-segment datapath and existing pins/channels. No readiness promotion.
