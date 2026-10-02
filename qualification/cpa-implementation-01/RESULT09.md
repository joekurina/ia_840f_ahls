# CPA implementation investigation — findings and decision

## Verdict and scope

**Five parallel research lanes are complete and parent-checked. A documented physical-routing candidate has been identified: select clock spine 2 for EMIF1's actual global source, preserving its existing full-device region. It is not a proven correction, and no fit or setting change was performed.** Work23 timing remains rejected at **−0.004 ns**, Fast vid2 100C; the migration is not complete.

The latest user instruction authorized investigation, inspection and evaluation, not implementation. Parent performed finite ordinary-file reads through the owned Agilex tmux session; subagents worked on local evidence and public documentation. No Quartus project/native command, device operation, programming, refit, parameter change, service setup or vendor submission occurred in this investigation. Research outputs are local-only; no publication is claimed. GPT-6/openai-codex substituted for unavailable GLM5.3.

## 1. Supported physical candidate

### What changed in the implementation

| Native Place-stage field | Passing Work21 / Quartus25.1 | Work23 / Quartus26.1.1 |
|---|---|---|
| CPA source site | TILECTRL_X172_Y0_N298 | Same |
| Terminating clock spine | **2** | **1** |
| Clock region | **SX0 SY0 SX6 SY7** | Same |
| Region size | 56 sectors | 56 sectors |
| Clock ownership | root_partition | root_partition |
| Promotion | Mandatory | Mandatory |
| Source-to-tree layer jumps | 2 | 1 |

These rows are directly verified in [Work21 Fitter lines31118–31133](../fim-build-21/final-capture01/ofs_top.fit.rpt) and [Work23 Fitter lines31195–31211](../fim-build-23/timing22-readback/output_files/ofs_top.fit.rpt). They are **Place-stage summary fields**, not an assertion that every final route is identical apart from its index. Paired final routing reports independently show changed core topology; all four explicit-edge PHY comparisons retain identical ordered rows. See [topology analysis](02-clock-topology.md) and [parent verification](parent-evidence-verification08.json).

The 26.1.1 Settings File Reference documents **CLOCK_SPINE** as selection of the SCLK wire index for a targeted global signal, with legal indices0–31 and explicit Agilex7 support. It recommends pairing it with CLOCK_REGION so the driven sectors remain constrained. This is a physical allocation/routing control, not an STA latency assertion or CPA phase-offset override.[1] Clock-region constraints control tree coverage; preserving coverage matters here because the root-owned clock serves the PR region.[2][3]

### Recommended later experiment — not launched

- Keep Work23's **Quartus26.1.1, seed3, effort, clocks, both DDR banks, PR/static geometry and signoff requirements** fixed.
- Target **signal A**, the exact source-and-Fitter-backed net spelled out in [lane03 lines15–20](03-clock-controls.md). It ends in `core_clks_from_cpa_pri_nonabphy` bit0; do not target an SDC clock object or a guessed physical-resource name.
- Request **CLOCK_SPINE 2**, preserving **CLOCK_REGION "SX0 SY0 SX6 SY7"**. If made explicit, the matching region companion is a second assignment record—not a falsely described one-line patch or a region-shrink trial.
- Require actual completed-fit consumption: intended source, spine2, unchanged region/ownership and no ignored/illegal target. Inspect the resulting core routing, launch branch and both CPA compensation roles, not only the old failing slack.
- Require unchanged all-corner timing and the retained wider project/hardware gates. A changed COMP value or successful compilation alone is not acceptance.

**Known collateral risk:** Work23's PCIe clocks also occupy spine2 in sectors(0,1) and(0,3). Requesting spine2 for the full EMIF region can require allocation changes or fail fitting. It must not trigger a silent index sweep, pin move, region change or timing exception. The older pass is evidence of a meaningful physical dimension, **not proof that spine2 causes closure**. [Native PCIe rows31451–31462,31547–31558](../fim-build-23/timing22-readback/output_files/ofs_top.fit.rpt); [candidate matrix](03-clock-controls.md).

### Inherited-assignment check

A parent-owned ordinary-file scan inspected **2,404 recorded Work23 inputs**, totaling81,221,443 bytes, restricted to `.qsf`, `.tcl`, `.qip`, `.v` and `.sv`. Every byte hash matched the admitted compile record. No literal CLOCK_SPINE or CLOCK_REGION token occurred; six GLOBAL_SIGNAL occurrences were unrelated explicit reset/SYS_REFCLK selections. See [successful capture](static05-collection.json), [raw source scan](static05-result.json.gz) and [verification](parent-evidence-verification08.json).

This settles the stated **literal-source scope**, not every dynamically constructed assignment, other file type, implicit PR constraint or resolved netlist property. The existing mandatory promotion and region are proven by Fitter reports; absence of a source line is not a default/OFF readback. The initial UTF-8-only scanner failed on vendor source encoding and is preserved as `static04-*`; the successful successor searches raw ASCII tokens as bytes and preserves raw matched-line bytes.

## 2. The compensation difference is role-dependent

For the **same CPA output and Fast vid2 100C corner**, existing final STA gives:

| CPA COMP usage | Work21 | Work23 |
|---|---:|---:|
| Hold-arrival / setup-required | −2.208 ns | −2.292 ns |
| Setup-arrival / hold-required | −1.997 ns | −1.966 ns |
| Separation between these reported values | 211 ps | 326 ps |

The opposite-sign change occurs at all five corners. Parent independently classified all **1,100 / 1,099 appearances**, including repeats, into40 corner/analysis/role groups per report. Recovery/removal groups are retained separately. Crucially, the parser uses each path's **Worst-Case Operating Conditions**, not a stale report-level Delay Model heading. [COMP verification](comp-role-verification03.json); [numerical audit](05-model-audit.md).

This rejects the interpretation that the complete effect is a single rigid −84ps phase translation. It is consistent with role-dependent early/late treatment, but does not establish the production selection equation, an implementation-independent model change, or a compiler defect. No nominal phase is inferred by averaging the two values.

The original failing-path arithmetic remains valid: **−84ps COMP plus−2ps launch-clock interconnect accounts for−86ps hold-slack change**. The data transfer still reports0.288ns and required time2.968ns. Meanwhile, selected core-feedback extrema changed only1–5ps, and launch-minus-feedback propagation changed247→246ps. Raw feedback totals are not detector-reference-plane delays and do not numerically explain the production COMP term. [Paired observations](../fim-build-23/feedback-review52.md); [topology](02-clock-topology.md).

## 3. Effective settings: what is established and what is not

The reported main EMIF1 PLL settings agree: **direct mode, High bandwidth, M40/N1, 750ps VCO period, C counters4/2/4/2/4, zero reported output phases**. The58-field comparison changes only the reference-clock duplicate alias. Stage limitation: Work21's retained block is **Plan**, while Work23 also has an equal Finalize block. This is not a complete paired final-atom dump. [Effective-settings matrix](01-effective-settings.md); [parent comparison](comp-role-verification03.json).

**Still unread as effective fitted properties:** CPA mux/divider/offset/filter/control bits, detailed unreported PLL settings and constant control-port associations. Generated source requests are not substitutes for those values. Connectivity and propagation reports likewise do not read configuration fields.

The documented next readback route is the **Technology Map Viewer, Post-Fitting → exact primitive Properties → Parameters/Ports**, limited first to TILECTRL_X172_Y0_N298, then the associated PLL only if needed. Its UI is documented; exposure of these exact hard-atom fields in26.1.1 is not yet observed. Missing fields must be recorded as *not exposed*, not zero. The owned tmux environment had no DISPLAY; no GUI/forwarding/service was started. No paired GUI extraction was performed. [Bounded request](01-requests.json); [verified documentation references](01-effective-settings.md).

This gap is **not** a new prerequisite requiring the whole CPA equation to be reconstructed before a supported physical trial. Vendor assistance remains optional, not the only possible route.

## 4. EMIF controls and installed-schema follow-up

Parent verified the actual Work22 EMIF1 SOPCINFO archive member and its hash, four generated RTL identities, and **2,344 direct leaf plus4,088 direct architecture parameter records**. The retained earlier SOPCINFO differs only by its generation-date comment. Recursive parameter counting would incorrectly mix in interface parameters. [EMIF review](04-emif-controls.md); [parent verification](parent-evidence-verification08.json).

The requested finite installed-source follow-up retrieved exactly **six files /177,959 bytes**, following the component's package-index/provider edges without executing Tcl callbacks. The seed itself points to the F/I-Series23.2 user guide; this older guide version is not an invented substitute for an unrelated device family. Captures: `static05`, `static06`, `static07`; [schema excerpts](installed-schema-excerpts07.json).

Newly confirmed from installed26.1.1 source:

- `ip_top/phy.tcl:379–381` explicitly makes core-clock sharing invisible for FAMILY_AGILEX and asserts **CORE_CLKS_SHARING_DISABLED**. It is not merely an accidentally hidden GUI option.
- `ip_top/phy/ddr4.tcl:43,68` declares then hides the DLL core up/down option. It is not a public CPA trim.
- `ip_top/pll.tcl:35–47` permits0–4 extra outputs and distinguishes the hidden first five output fields. Extra-output phases are not CPA-output0 controls.
- Memory-rate choices and frequency bounds depend on feature tables, speed-grade limits and legal reference-frequency callbacks (`ip_top/phy.tcl:337–362,513–532`). Selected-device numeric alternatives were **not evaluated**, and remain unresolved rather than guessed.

The bounded declaration review found **no exposed CPA-phase or C2P-pipeline adjustment that preserves the complete current contract**. Lower DDR frequency, changing user rate, replacing references, or using extra PLL outputs are separate architectural/operating-point choices requiring regeneration and scope decisions. In particular, a hypothetical lower-DDR/half-rate arrangement that retains nominal3ns can change the x64 Avalon width from512 to256bits and alter byte enables/addressing; legality and integration are not qualified. [EMIF candidate matrix](04-emif-controls.md).

## 5. Closed and remaining follow-ups

| Request | Disposition |
|---|---|
| Lane02 spine semantics | Resolved by same-release manual, native family list and source/Fitter target pairing. |
| Lane03 physical-control eligibility | Seventeen-control matrix checked; strongest candidate is CLOCK_SPINE. Global promotion/effort already enabled; ordinary PLL compensation is not CPA selection; timing-only masking and unsupported Hyper-Register overrides remain excluded. |
| Lane03 inherited assignments | Literal recorded-source scan completed with zero drift. Full resolved assignment/default enumeration not performed and not claimed. Missing generic defaults do not block evaluation of documented spine2. |
| Lane04 six-file schema read | Completed within cap; family hiding/assertions confirmed. Dynamic selected-device frequency/feature tables remain a precise gap for changed-operating-point variants. |
| Lane01 effective CPA field readback | Remains unacquired; documented paired post-fitting Properties inspection specified. No claim of absent hardware or impossible access. |
| Lane05 new numerical discriminator | Completed using existing reports; no repeated native timing query needed. |
| Physical experiment / acceptance | **Not executed or authorized by this report.** Recommendation is one targeted spine2 trial, not another blind seed. Timing/deployment remain rejected. |

The five reports and request files were verified as present and valid before integration, with14/14 starting evidence hashes preserved. Parent independently checked the risky numeric, topology, public-control, generated-source and installed-declaration claims. See [initial consumption](parent-consumption02.json), [COMP matrix](comp-role-verification03.json) and [cross-check receipt](parent-evidence-verification08.json).

## Sources

[1] https://docs.altera.com/api/khub/maps/oluEHidW2n2DqYqtrU2xEw/attachments/m_7cMGotKMY2xeQeOTz9Ug-oluEHidW2n2DqYqtrU2xEw/content?download=true&locationValue=reader — Quartus Prime Pro Edition Settings File Reference Manual 26.1.1 PDF
[2] https://docs.altera.com/r/docs/683761/current — 1. Agilex® 7 FPGA F-Series and I-Series Clocking and PLL Overview • Agilex® 7 Clocking and PLL User Guide • Altera Documentation and Resources Center
[3] https://www.intel.com/content/www/us/en/docs/programmable/683641/23-3/creating-clock-region-assignments-in.html — Quartus Prime Pro Edition User Guide: Design Optimization (redirected to 25.3.1)
