# Vendor-remedy research01 — forced EMIF boundary hold

## Outcome

**Negative result:** this bounded official-source review established no applicable, documented local correction, effective-Fitter-attribute readback API, or fixed tool release for the Work18 violation. It also found **no published declaration that this exact violation is unavoidable**. Absence of a located remedy is not proof that none exists.

**Supplied baseline, not rerun:** Quartus Pro 26.1.1 Build 130; AGFB027R25A2E2V, IA840F, OFS `ofs-2026.1-1` prerelease. Work18 retains EMIF1 `amm_writedata_0_r[0][243]`→UFI→PHY hold −0.004 ns at Fast vid2 100C. The supplied evidence reports forced-boundary Hyper-Register ON and delay-chain 350; maximum/high effort, all-path/aggressive hold optimization, Fitter-only margin and exact-register retiming-OFF trials have not removed the failure. These observations are inputs, not newly verified build results.

## Applicable evidence and rejected near-matches

1. **Correct family and transfer, but no boundary override.** The F/I-Series EMIF guide says “Core to periphery (C2P) transfers have timing constraints created and are timing analyzed by the Timing Analyzer.” Section 8.1.1.1 includes the last core registers through the first periphery registers in PHY/core timing. Section 8.2 offers general performance/synthesis-speed/placement-effort settings, not a forced-Hyper-Register override or hold waiver.[2] The retrieved guide is explicitly **version 23.2**, although its UI edition date is 2026-01-26. It provides architectural context, not proof of assignment support in 26.1.1. Its generic effort advice supplies no new supported correction to this exhausted baseline.

2. **Real same-family hold fix, wrong IP.** The eSRAM release notes document adding `HYPER_REGISTER_DELAY_CHAIN 100` for a hold violation in **eSRAM IP v19.2.1**, released 2021-06-29 with **Quartus 21.2**.[3] The associated official KB names eSRAM, describes the issue in 19.3 and later, and explicitly says it is fixed starting with 21.2; its metadata separately labels “Version Found” 20.4.[4] This is not EMIF evidence. It does not authorize replacing EMIF's 350 with 100, disabling its forced boundary register, using a QSF override, or claiming a 26.1.1 EMIF fix. No such change is recommended.

3. **Current compiler notes cannot identify a matching fix.** The 26.1.1 notes list resolved Premier Support case numbers and included patch numbers without defect descriptions; the displayed important-known-issues table concerns IBIS Writer output, not EMIF hold. The notes direct readers to the Knowledge Base for further issues.[1] Their IP-regeneration list is not evidence that regeneration repairs this path. No matching defect/fix mapping was established.

4. **Correct-family IP notes are older.** The linked F/I-Series EMIF release notes resolve to version **23.2**, dated 2023-07-19; their newest entry is IP **2.7.1**, verified with Quartus 23.2.[6] The retrieved document contains no hold/Hyper-Register remedy. It cannot establish a later compiler fix. Search results for 26.1.1 EMIF release notes predominantly concerned M-Series or Agilex 5; those were not treated as F-Series evidence.

5. **BittWare coverage gap.** The discovered IA-840f product URL returned the BittWare–Molex homepage rather than board-specific release notes.[5] No public board-specific timing workaround was recovered. This is not a claim about customer-only documentation.

## Assignment/API conclusion and blocked decision

Exact-name searches supplied no official public override documentation for `FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER`; the only exact-name hit was a nonofficial 19.2 parameter inventory, rejected without substantive review. The delay-chain search yielded the eSRAM-only fix above. No reviewed source establishes HDL-versus-QSF precedence, effective fitted-attribute inspection, or an applicable replacement for the unavailable native help. Generic metadata and saved QSF values remain insufficient.

**Single blocked decision:** whether Quartus 26.1.1 supports a non-HDL override of the forced EMIF C2P Hyper-Register/delay-chain setting, with defined precedence over vendor HDL. Public evidence here does not justify that correction. Stop this branch; no seed/margin/retiming retry, source edit, timing relaxation, version change, support contact, upload or new launch-approval gate follows from this report.

## Search boundary

Eight searches, six official document/page targets examined; no additional search proposed. Topics: exact force attribute; Intel EMIF C2P hold; Altera 26.1.1 issues; BittWare timing releases; Altera EMIF core hold; exact delay-chain attribute; Agilex 7 26.1.1 EMIF releases; broader BittWare IA-840F/Quartus. A guide-fetch timeout was recovered through rendered official browser content. No vendor tools, remote hosts or hardware were executed.

## Sources

[1] [Quartus Pro 26.1.1 release notes, 2026-08-18, §§4,14–16](https://docs.altera.com/r/docs/683706/26.1.1/quartus-prime-pro-edition-version-26.1.1-software-and-device-support-release-notes/quartus-prime-pro-edition-version-26.1.1-software-and-device-support-release-notes)
[2] [Agilex 7 F/I EMIF User Guide, v23.2, §§8.1–8.2](https://docs.altera.com/r/docs/683216/23.2/external-memory-interfaces-agilextm-7-f-series-and-i-series-fpga-ip-user-guide/agilextm-7-f-series-and-i-series-fpga-emif-ip-timing-closure?section=zyx1547146209447)
[3] [eSRAM release notes, §1.3, IP v19.2.1 (2021-06-29), Quartus 21.2](https://docs.altera.com/r/docs/683604/current/esram-ip-release-notes/esram-intel-agilextm-7-fpga-ip-v19.2.1?contentId=YrB2YzmPUvLzTLYV1~UDIg)
[4] [Altera KB 343480 / Intel 000086072, eSRAM hold workaround; fixed in 21.2](https://community.altera.com/kb/knowledge-base/why-does-my-esram-intel-agilex%c2%ae-7-fpga-ip-not-meet-the-maximum-performance-speci/343480)
[5] [BittWare IA-840f product URL; retrieved as BittWare–Molex homepage (coverage gap)](https://www.bittware.com/products/ia-840f/)
[6] [Agilex 7 F/I EMIF IP release notes, v23.2, IP v2.7.1](https://docs.altera.com/r/docs/683334/23.2/external-memory-interfaces-intel-agilextm-7-f-series-and-i-series-fpga-ip-core-release-notes/external-memory-interfaces-intel-agilextm-7-f-series-and-i-series-fpga-ip-core-release-notes)
