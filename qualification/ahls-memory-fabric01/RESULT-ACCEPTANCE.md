# Parent acceptance — connected AHLS memory fabric

**ACCEPT_NATIVE_GENERATION_AND_CONNECTED_ANALYSIS_ELABORATION_WITH_FINDINGS**. [FINAL independent review](independent-review01.md), SHA256 `18ee87087553dbb82db73344aefe718d43dc3c7aaa77e7672f3f69002c36fa49`, consumed and bounded findings retained.

Parent reverified27frozen members, all261fabric03 and7elab01 archive payloads, generated top HDL/SOPCINFO port equality and the high-risk MMIO router/ID/USER boundaries. Native import/generation and connected Quartus25.1 analysis/elaboration returned0. Failed fabric01/02 remain failed, API01 is query-only. No unchanged rerun.

[Correction F-01](PORT-LEDGER-CORRECTION01.md): **244ports/11interfaces**, not243. The only previously omitted entry is final bank_out1_ruser input2bits. Corrected top-ports04.json adds it; frozen03/native bytes remain unchanged.

Important retained limits: MMIO routes use only low17bits, so0x30000 aliases kernel0x10000. The declared apertures are not high-address rejection; add explicit upstream decode before live access. Fabric bank ID18/USER2 is not Work21 PIM ID9/USER14 adaptation. Kernel hosts34byteaddress/256data feed native512-bit bank paths, but physical banks/CDC/PIM/DMA engines are not attached by this gate. Exactly one primary host-channel0 owner remains required.

Native banner0errors/1warning versus57explicit diagnostics remains unresolved; ResetRelease RES-10204 high failure and constant-zero exception output remain visible. AHLS accepted-write acknowledgment and USE_WRITERESPONSE0 do not prove physical memory visibility. Full-device reset/PR/clock/Work21 signoff findings, mapped synthesis/fit/timing, realDMA, numerical/HW and durableboot are not accepted here. DDR vendor simulation SKIPPED BY USER. No device,flash,driver or reboot operation.

Other DMA gates are independent: reader published71cb6d5, AW de594ae9d7082b175bbdb7e0ded00e1c3a78b4a3, W a38bef1300807d5abb2252f3e17b2e5f59746bd0. Response/paired-engine native candidates remain under separate reviews. Immutable pre-review wording is superseded only within this fabric gate.
