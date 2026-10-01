# Work22 IP generation and fresh headers — accepted with findings

**Accepted for native IP generation and compile preparation only.** Synthesis/elaboration, physical implementation, timing, new-image/persona compatibility and real-card qualification remain separate gates.

## Actual native result

The completed 26.1.1 Build 130 generation produced all **83 selected primary inputs** and their nested collateral. Native/effective/outer status is **0/0/0**, with **0 errors and 820 warnings**. The original inputs remained unchanged and no vendor processes or operation lock remained after collection. [Native collection](regeneration17-collection.json), [completion receipt](regeneration11-completion-event.json).

The captured inventory contains **2,106 generated files**, and all **94 primary/nested SOPCINFO reports** identify **Agilex 7, AGFB027R25A2E2V, speed grade 2**. The complete generated QIP graph has 83 roots, 94 reachable QIPs and 1,519 file-reference edges, including the non-RTL file assignment classes. Every target has a bound existing-file identity within WORK. [Target checks](generated-targets19.json), [dependency closure](generated-qip-closure19.json).

[Board checks](generation-semantic-check20.json) verify distinct DISCRETE/RDIMM DDR4 channels with DQ64, row17/column10, BA2/BG2 and ECC disabled; 95 selected PCIe/PF1/clock-request settings are unchanged. The generated PLL retains seven outputs and a 1410.0 MHz VCO declaration. Its generated rates match Work21, including 100714286 Hz rather than nominal100 MHz. The fresh SCJIO endpoint wrapper declares and forwards `CLTAP_CONNECTION`. **Generated clocks are not fitted-clock or timing proof**, and primitive elaboration is not claimed by generation alone.

## Independent review and warnings

The parent consumed [independent review21](generation-review21.md), `deleg_74fc75b9`, report SHA256 `6ee119e22f2b72b31ae812aa19dce5f4cb7930d93c5cfb551d0371c894566306`. All 15 cited artifact bindings were rechecked. [Parent consumption](generation-review-consumed29.json).

All 820 native warning occurrences reconcile to the footer, without adding duplicated per-IP report diagnostics. Findings remain explicit:

- Missing interface metadata: 184 occurrences; inspect selected connectivity/default consumption in native elaboration.
- Mismatch class: 528 APF/BPF capability observations plus 12 remote-debug DFH observations. Two BPF examples predate the migration, but that is not blanket clearance or functional equivalence.
- Foreign saved-device metadata: 11; the wrong-effective-device concern is resolved for this generation by all 94 actual metadata targets, not by assuming donor defaults are valid.
- Native catalog version selections: 17; record the actual selected versions, not cosmetic-equivalence claims.
- Simulation-model no-port warnings: two; not the physical EMIF instances and not a simulation pass.
- Other 66: project-setting/nested-project metadata, remote-debug software metadata, four actual PLL rate substitutions, unused BMC conduits, advanced reconfiguration and TCK-ENA limitations. See the exact review dispositions and [warning ledger](generation-warning-ledger17.json).

No new protocol, interface tie-off, clock retuning, vendor-internal requalification or warning waiver was introduced. The review approves no active-PR or runtime clock-reconfiguration behavior.

## Fresh header result and retained ASP defect

The copied configuration directory and three `sv_wrapper` directories were archived before native header extraction to defeat timestamp skips. The header operation completed **0/0/0**, with native **0 errors / 0 warnings**, no immutable-input drift, no remaining owner and 21 fresh output files. All **21 are byte-identical** to their retained Work21 counterparts. [Header preparation](headers-prep22-collection.json), [native capture](headers27-collection.json), [complete comparison](header-comparison28.json).

The malformed `ofs_ip_cfg_local_mem_asp.qprs` and entity-only local-memory header were reproduced exactly; the ASP file still fails XML parsing at line22. They are **not repaired or called valid**. The prior [independent consumer review](../fim-build-12/compile-candidate-01/header-result-review-02.md) establishes that the selected FIM/PIM path obtains geometry from the generated wrapper/package macros and does not parse this ASP collateral. The applicable exporters/consumer path and regenerated header bytes remain unchanged. This is a retained nonblocking ASP defect, not an active FIM-header regression or acceptance for an ASP workflow.

## Preservation and next boundary

The maintained donor source, PIM, original Work21 inputs and published fallback were preserved. The four-line PCIe constraint and exact fit-only 10 ps margin/signoff-skip overlay remain selected. Full native implementation uses fresh run authority; its result must independently establish synthesis, fit, assembly and all-corner3.000 ns timing, including the exact EMIF1 transfer and PCIe clock/exception/net-delay coverage.

Raw transport archives, complete copied tool/generated inputs and oversized files remain local-only with hash references. No programming or card operation occurred. Reviews used the disclosed GPT-6/openai-codex substitution, not GLM-5.3.
