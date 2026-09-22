# Work14 PCIe clock binding — independent local-evidence research

## Decision

**The obsolete hierarchy is proved, and a divide-by-two generated relationship to the existing CSR clock is source-supported. An applicable, exception-safe correction is not yet proved.** The modern divider cell is present in Work14. However, the available local evidence does not establish the exact final input/output pin collections, equivalence of `clock_div2` and `clock_div2x`, or all four invalid FIFO destination groups' clock connectivity. Restoring the name `avmm_clock0` would also revive existing asynchronous-group constraints and multicycles; it is not merely a harmless selector repair.

**Deliverable: research/proposal only, not a candidate or authorization.** Only this report was created. No maintained source, candidate, bound evidence, gates or git were changed. No remote access, vendor command, hardware access, simulation, Tcl/HDL execution, new post-fit query or timing experiment was performed. Query04 or a renamed equivalent is not proposed. DDR simulation and dummy-CSR testing remain excluded. The separate EMIF1 hold failure is not addressed or waived.

## 1. Evidence binding and citation conventions

`N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`. All citations below are **1-based original source/report lines**; JSON payload citations refer to decoded text lines, not container lines.

- **S** = `N/ofs-agx7-pcie-attach`.
- **STA / FIT** = `N/qualification/fim-build-14/reports11/output_files/ofs_top.sta.rpt` / `ofs_top.fit.rpt`.
- **AUTH** = `N/qualification/fim-build-14/status-readback05/compile-authorization.json`.
- **LIVE06** = `N/qualification/pcie-generated-evidence-01/pcie-rendered-constraints-live06.json`.
- **LIVE10** = `N/qualification/pcie-generated-evidence-01/pcie-synthesis-chain-live10.json`.
- **OLD01 / OLD03** = `N/qualification/fim-build-08/pcie-clock-review-01/sources-01.json` / `sources-03.json`. Their relevant source payloads were independently matched to **Work14 AUTH**, not assumed current because Work08 used them. `sources-02.json` is excluded: its historical report identifies it as stale duplicate retrieval.
- **QIP** = LIVE06 payload `ipss/pcie/qip/pcie_ss/pcie_ss.qip`.
- **PCIe-SDC** = LIVE06 payload `ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss.sdc`.
- **TOP** = LIVE10 payload `ipss/pcie/qip/pcie_ss/synth/pcie_ss.v`.
- **AXI** = LIVE10 payload `ipss/pcie/qip/pcie_ss/intel_pcie_ss_axi_500/synth/pcie_ss_intel_pcie_ss_axi_500_gycdipy.sv`.

Independently recomputed these principal identities:

| Evidence | Bytes | SHA256 |
|---|---:|---|
| Work14 independent timing review | 16501 | `37b5a62ceb38f6c8013496e4fa339eeefcc7c202143409f5b3937c346674eace` |
| Work14 result-review-inputs01.json | 7940 | `99f58803c9b05c4c37a4203701176d517d866d9969d649c51fa4244ef1ede744` |
| AUTH | 1461896 | `42cb4974f9e6aba80aa25e5df385de1faac09251dd6695123448d0db931127be` |
| STA | 48068193 | `8c51a45bcff167fb80feb39a9338c62691401d0fa7be36d7a2caa0d94969c5e6` |
| FIT | 19940793 | `32b311d2216c1675bf1cfc8813b93d1a55346977dd773a674ff9e8bee9b073ad` |
| S/syn/shared_config/top.sdc | 8874 | `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d` |

This review verifies the result-manifest file identity, not a new review of all its bound files. The prior independent timing review supplies that broader result review.

Eight unique generated source payloads used here were reconstructed as UTF-8 bytes, hashed and matched to the exact `AUTH.work_inventory` entries:

| Payload (under `ipss/pcie/qip/pcie_ss/`) | SHA256 |
|---|---|
| `pcie_ss.qip` | `97d4cd6d42bd823437e9e221d0c6987e670ba45124e49c3e72cae69730b332df` |
| `intel_pcie_ss_axi_500/synth/pcie_ss.sdc` (59669 bytes) | `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265` |
| `synth/pcie_ss.v` | `c64ce327ff29f6a92c9af4bbf8ede410fe6b94c88796f6bf774866e85c3c8e9f` |
| `intel_pcie_ss_axi_500/synth/pcie_ss_intel_pcie_ss_axi_500_gycdipy.sv` | `ea4e45e5539f8153dbb0590c01c75f3f2c36103e83d989894033d567eaf55536` |
| `intel_pcie_ss_axi_500/synth/hip_if_adaptor/pciess_clock_divider.sv` | `604f5ed9a6d0c2c89bed6c190693d7c6e018fa372c735d741f4c4f2f500e166c` |
| `intel_pcie_ss_axi_500/synth/pciess_hip_if_adaptor.sv` | `74566e6c2f02ddf69ad9884997f0918eda05d619c98432bdfe3ea1530b8cedf9` |
| `intel_pcie_ss_axi_500/synth/pciess.sv` | `d54933a17a6e80cfa6a8ae3afd566c23f0d1be4be5888da19ee96005f6a370df` |
| `intel_pcie_ss_axi_500/synth/intel_pciess_ptile_wrapper.sv` | `a9d7478613eccc680aeee4944ddf6af77699504beb661eeb9d603457b7b456df` |

The last four are retained protected vendor bodies in OLD01/OLD03, **not readable implementation evidence**. No decryption was attempted. Simulation counterparts are not substituted: AUTH records different simulation/synthesis hashes for several of these protected files.

Five maintained files were also matched to both AUTH's nested `source_sha256` inventories and its `work_inventory`: `syn/shared_config/top.sdc`, `src/board/ia840f/top.sv`, and `ofs-common/src/fpga_family/agilex/pcie_ss/{pcie_wrapper,pcie_ss_axis_top,pcie_ss_dm_top}.sv`. Thus the source wiring below is bound to Work14 rather than to an unverified local revision.

## 2. Exact modern hierarchy and the three distinct object representations

Define literal prefixes (no wildcard):

```text
H = pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss
P = H|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif
D = P|u_pciess_clock_divider
```

`H`, `P` and `D` above are explanatory substitutions, not names of new Tcl variables or created artifacts.

| Object | Exact spelling after expanding H/P/D | Evidence and limit |
|---|---|---|
| Divider cell | `D|clkdiv_inst` | FIT:31723 identifies this as the source node, type CLKDIVBLOCK (:31724), location `CLKDIVBLOCK_X11_Y330_N106` (:31725). |
| Vendor generated-clock target | `D|clkdiv_inst|clock_div2` | PCIe-SDC:191–192. This is the vendor's intended output-pin spelling, not a successful Work14 pin lookup. |
| Existing integration source-pin suffix | `D|clkdiv_inst|inclk` | The `inclk` suffix is retained from S/syn/shared_config/top.sdc:36, with the obsolete intermediate hierarchy corrected. Its modern full collection has **not** been demonstrated to match. |
| Fitter clock/net label | `D|clock_div2x` | FIT:9588,31151,31722; fanout 355. This is not written as a `clkdiv_inst` pin in the report. |
| STA clock-like register | `D|clkdiv_inst~div_reg` | STA:209097,209862: clock without an assignment, reported unconstrained. It is not a substitute output-pin name. |

The maintained SDC:35–37 instead uses:

```text
pcie_wrapper|pcie_ss.top|*|pcie_ss|u_pciess_p0|gen_sub.u_hipif|...
```

The missing modern pieces are **`EP_PFTILE_WRAPPER.gen_pciess.` before `u_pciess_p0`, and `|u_pciess` before `|gen_sub.u_hipif`**. This is more than replacing the outer `*` with `host_pcie.pcie_ss`. STA:208866–208872 explicitly reports zero source/target matches and rejects the generated-clock command. The modern intermediate hierarchy is corroborated independently by the generated SDC and Work14 physical reports.

TOP:180,183 selects P-TILE/EP. AXI:4530–4533 selects `EP_PFTILE_WRAPPER.gen_pciess`, and :4687 names `u_pciess_p0`. The deeper hierarchy is report/constraint evidence, because the next implementation body is protected.

**Do not equate `clock_div2`, `clock_div2x` and `~div_reg`.** They describe different report/constraint representations. Matching location, common ancestry and similar names establish a focused target, not pin-alias equivalence. Do not broaden the final selector to `clock_div2*` or target the unconstrained register merely to make a collection nonempty.

## 3. Source, master, input and output semantics

### Readable source chain

The bound source establishes this chain up to the protected P-Tile wrapper:

1. Board `top.sv:511–516`: `sys_pll.outclk_1` drives `clk_100m`.
2. `top.sv:302`: `assign clk_csr = clk_100m`; :589–592 passes `clk_csr` into `pcie_wrapper.csr_clk`.
3. `pcie_wrapper.sv:266–270,290–305`: both DM and AXIS choices use the same `.csr_clk(csr_clk)` forwarding.
4. `pcie_ss_axis_top.sv:715–718`: `.p0_axi_lite_clk(csr_clk)`. The alternative DM macro independently has the same CSR connection at `pcie_ss_dm_top.sv:231–234`; its streaming-clock connection differs, so streaming and Lite clocks must not be conflated.
5. TOP:14,1169,1177 declares/forwards `p0_axi_lite_clk` into instance `pcie_ss`.
6. AXI:1138,4687–4694 passes it into `EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0.axi_lite_clk`.

**Readable implementation stops here.** QIP:166 selects `intel_pciess_ptile_wrapper.sv`; QIP:216 selects `hip_if_adaptor/pciess_clock_divider.sv`. Those and the intervening `pciess.sv` / `pciess_hip_if_adaptor.sv` are protected in the existing captures. There is no cleartext proof here of the last internal wire to `clkdiv_inst.inclk`, its output alias wiring or its FIFO fanout. This is a connectivity-evidence limit, not a demand to requalify or decrypt vendor internals.

### Actual Work14 clock versus nominal parameter

STA:2706 identifies the evaluated CSR clock as:

```text
Clock name: sys_pll|iopll_0_clk_100m
Reported period/frequency: 9.929 ns / 100.71 MHz
Master of that PLL-generated clock: sys_pll|iopll_0_n_cnt_clk
Source: sys_pll|iopll_0|tennm_pll~ncntr_reg
Target: sys_pll|iopll_0|tennm_pll|outclk[2]
```

The wrapper's logical `outclk_1` and the fitted PLL's physical `outclk[2]` are different naming levels. Neither may be silently rewritten to the other's index.

For the proposed **PCIe divider** relationship, the expected upstream master is the existing **`sys_pll|iopll_0_clk_100m` clock object**, not that object's own upstream `n_cnt_clk`, not `SYS_REFCLK`, not PCIe reference clocks, and not the 500-MHz `rx_ch15` domain reported at STA:2704. A generated clock's `-source` names a source node; `-master_clock` selects an existing clock object on that source path. The intended divider input node and its actual clock association still need evidence. Merely supplying a plausible `-master_clock` does not prove connectivity.

The divide-by-two relationship is established by **PCIe-SDC:191–192**, not inferred from `clock_div2x`. Any eventual definition should inherit the real existing master waveform/precision and divide it by two. Do not create a replacement 100-MHz base clock, hard-code a 50-MHz output, use the report's rounded period as a new constraint, or retune the PLL. No new numerical clock period is proposed here.

One actual output load is already known: STA:209098 explicitly says `D|clkdiv_inst~div_reg` clocks

```text
H|gen_ptile.u_ptile|intel_pcie_ptile_ast_qhip|inst|inst|maib_and_tile|avmm2_3~maib_ss_lib/x0/u5_2/pld_avmm2_clk_rowclk.reg
```

This confirms an active downstream load, but does not identify the four FIFO destination groups as additional loads.

## 4. Exact generated-SDC creation conditions and ordering

QIP:345 registers PCIe-SDC as an **entity SDC with `-no_sdc_promotion`**. Work14 STA:208749 confirms it is read for instance `H`. The system PLL SDC is read earlier (:208697); integration `top.sdc` is read later (:208862).

The relevant generated Tcl has separate port and clock tests:

- **:23–40**: `pcie_port_existence` returns whether `get_ports -nowarn $port_name` has nonzero collection size.
- **:43–60**: `pcie_clk_existence` separately uses `get_clocks -nowarn`.
- **:63–79,133**: collects a snapshot of existing clock targets.
- **:161–164**: tests `p*_axi_lite_clk` port existence, and performs `lsearch -exact $pcie_clock_target_list p*_axi_lite_clk`; if the port exists and search returns −1, it creates `p0_axi_lite_clk` using the nominal Lite period. **`lsearch -exact` treats the asterisk literally; this is not a robust glob-based duplicate-clock guard.** The configured Lite frequency is 100 at :90, but that alone does not impose an effective Work14 clock.
- **:187**: computes `pcie_axi_lite_clk_ext` (clock existence).
- **:188**: nevertheless gates the divider block on **`pcie_axi_lite_clk_port_ext` (port existence)**, not the clock-existence result and not the presence of the divider cell.
- **:189–192**: inside that gate, P/F-Tile and Native Endpoint select `avmm_clock0`, `-source p0_axi_lite_clk`, `-master_clock p0_axi_lite_clk`, `-divide_by 2`, modern `D|clkdiv_inst|clock_div2`, and `-add`.
- **:193–202**: additional divider clocks require other topologies; the captured Gen4 1x16 selection (:83) does not select these extra clocks.
- **:218**: within the same port-gated block, also declares `avmm_clock0` asynchronous to `p0_axi_lite_clk`.
- **:289–299**: separately, under P-Tile and Lite **clock** existence, declares Lite and AVMM asynchronous to `rx_ch15`.

The board top has no `p0_axi_lite_clk` port or token; its CSR clock is internal. The full Work14 clock-summary table (80 parsed rows beginning at STA:2631) has neither `p0_axi_lite_clk` nor `avmm_clock0`. Combined with the missing divider assignment, this strongly supports a **standalone-port applicability mismatch** in the generated creation branch, followed by failure of the obsolete integration fallback.

**Limit:** no retained Work14 evaluation records the exact scoped port collection or those Tcl boolean values. Therefore the literal branch behavior is known, and the no-clock outcome is known, but the runtime branch predicate is not directly observed. Do not claim that editing :188 to use the clock-existence flag would repair integration: the nominal name `p0_axi_lite_clk` is also absent, while the real propagated master is named `sys_pll|iopll_0_clk_100m`.

Do not alter the generated vendor SDC. A board-integration correction should supply the missing relationship only when that relationship is not already defined correctly. `-add` is not an absence check or proof that duplicate clocks are harmless. A future definition must reconcile existing target/master/ratio/name rather than blindly create another clock on the same node.

## 5. Reviving avmm_clock0 changes exception applicability

S/syn/shared_config/top.sdc:35 creates the name `pcie_wrapper|pcie_ss.top|*|pcie_ss|avmm_clock0`. The `*` in the **name argument** is not an instruction to expand the name into concrete instance names. The group/clock lookup patterns are separate selectors. An eventual explicit name `H|avmm_clock0` would also match the existing wildcard selectors, so using a concrete name does **not** avoid the effects below.

| Existing line(s) | What becomes resolvable if the name is restored | Implication |
|---|---|---|
| 49 | AVMM ↔ PCIe `rx_ch15` asynchronous groups | Cuts normal intergroup setup/hold timing; not merely clock bookkeeping. PCIe-SDC:299 supplies matching vendor intent for standalone named clocks, but the actual integrated crossing scope must remain accounted for. |
| 51 | CSR `sys_pll|iopll_0_clk_100m` ↔ AVMM asynchronous groups | Cuts normal timing even though the proposed AVMM clock is generated from CSR. PCIe-SDC:218 shows this treatment is deliberate in the vendor's named-clock context; frequency relationship alone is not proof either that the cut is wrong or that every integrated crossing is safe. |
| 57–58 | AVMM → CSR, setup 2 / hold 1, both `-end` | Alters the relationship using destination-clock cycles if those paths are timed. |
| 59–60 | CSR → AVMM, setup 2 / hold 1, both `-start` | Alters the relationship using source-clock cycles if those paths are timed. |

STA:208882–208899 explicitly records today's missing AVMM collections and ignored multicycles. The group diagnostics say “accepted but has some problems”; do not assume every partial command has no effect. The relevant **AVMM membership** is missing today and would change after a repair.

An active asynchronous clock-group cut takes precedence over multicycle setup/hold relaxation on the same clock pair. Consequently :57–60 do not provide a safety backstop for :51 and should not be described as four newly effective timing checks while that asynchronous cut applies. Conversely, removing :51 to make the multicycles operative would be a separate timing-policy change needing an actual transfer/cycle contract. There is no such complete contract in these local captures.

**Do not approve a blind two-selector edit while treating dependent constraints as unchanged behavior.** The generated SDC supports vendor CDC intent, but the bounded evidence does not enumerate all newly cut integrated paths or establish the global multicycles' functional necessity. No new false path, broadened group, waiver or copied vendor cut is recommended. Renaming the new clock merely to evade existing exception selectors would also be an unreviewed semantic change, not closure.

### Eight invalid net-delay assignments

STA:209811–209818 contains exactly eight final Design Assistant warnings: two per FIFO group. With prefix `P|`, the destinations are:

| FIFO subpath | Destination keeper suffix below `auto_generated|` |
|---|---|
| `u_pciess_cplto_if|cplto_fifo_avmm_inst` | `rs_dgwp|dffpipe*|dffe*` |
| `u_pciess_cplto_if|cplto_fifo_lite_inst` | `ws_dgrp|dffpipe*|dffe*` |
| `EP_CFG_IF.u_pciess_cfg_if|u_axi_lite_clk_to_user_avmm_clk_fifo` | `rs_dgwp|dffpipe*|dffe*` |
| `EP_CFG_IF.u_pciess_cfg_if|u_user_avmm_clk_to_axi_lite_clk_fifo` | `ws_dgrp|dffpipe*|dffe*` |

PCIe-SDC:628–641 uses destination period × 0.8 for both pointer-transfer (:631) and synchronizer-chain (:639) `set_net_delay`; these are invalid when no destination period is found. The same procedure also supplies skew and max/min-delay constraints. Giving the true clock its missing definition could make these bounds evaluable; **cutting paths does not supply the missing destination clock period**. FIFO names and direction labels are not enough to prove all destinations are on the fitted divider. Fanout 355 is an aggregate, not a receiver list. No guaranteed eight-warning cure, valid numeric limit or CDC pass is claimed.

## 6. Smallest justified proposal and precise stopping point

### Supported proposal, not an issued patch

The minimal textual target is the **existing board-integration generated-clock command in `syn/shared_config/top.sdc:35–37`**, not a second unconditional declaration and not generated vendor files. The source-supported hierarchy substitution in both node selectors is:

```text
old intermediate segment:
|u_pciess_p0|gen_sub.u_hipif|

modern intermediate segment:
|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|
```

Retain the vendor-supported divide-by-two relationship and use the actual CSR clock as upstream master **only once the source node's association is established**. Keep `inclk` and vendor `clock_div2` as distinct lookup hypotheses, not certified matches. Do not substitute `clock_div2x` simply because FIT prints it. Scope to the one observed H/D instance, preserve the existing device/PCIe/PLL contract, and make duplicate/missing/multiple clock or pin bindings explicit failures rather than guesses. A concrete clock name is preferable for an eventual explicit binding but still requires the exception review above; this report does not authorize even that name change.

### Evidence still missing for an applicable correction

1. **Work14 final input pin:** actual cardinality/name/direction of the modern `D|clkdiv_inst|inclk` collection, and its clock/fanin association to `sys_pll|iopll_0_clk_100m`. Readable source reaches the wrapper but stops before that pin.
2. **Work14 final output pin and alias:** actual name/cardinality/direction of the vendor target `D|clkdiv_inst|clock_div2`, or documented mapping to a different exact fitted pin. FIT's `D|clock_div2x` and STA's `~div_reg` do not settle this.
3. **Generated-SDC applicability/no duplication:** exact instance-scoped port/clock results or equivalent retained evaluated evidence showing why no generated clock exists and which definitions would coexist after the change. Current observed ordering is known; exact predicate values are not.
4. **Receiver and exception scope:** clock association for each of the four named FIFO destination groups, and an explicit disposition of the restored asynchronous groups versus the redundant/possibly unjustified global multicycles. Do not trade a missing-clock diagnostic for concealed untimed paths.

The already retained Work08 `pcie-postfit-query-03/query.log:476–478` does **not** close these holes: it reports fitted divider mode unavailable, prints a `tennm_clk_divider` cell, then fails with `can't set "pins": variable is array` before pin/fanin output. It is also an older fitted design. Its proposed retry in historical prose is not adopted here. No new query, renamed equivalent, experiment or acquisition is requested by this report.

**Stop at this documented proposal under the LOCAL-only scope.** Available evidence is sufficient to identify the precise obsolete hierarchy, real upstream CSR clock, vendor ratio and constraint-side risks, but not to certify a working pin binding or safely activated exception set. Source correction, timing acceptance and the separate EMIF1 hold closure remain unclaimed.
