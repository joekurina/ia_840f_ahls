# AHLS2026.1.0 DDRIP report-generation acceptance

**ACCEPT_IP_GENERATION_ONLY; HOLD_ABI_INTEGRATION_HARDWARE.** Parent verified the [independent result review](result-independent-review01.md), SHA256 `27f5e0aa865441a6979066095d7f90f4bf78bc59905a797ae2e5feb297cfef4a`, and all15 [frozen files](result-review-freeze01.json). Historical pending-review wording in RESULT.md and pre-generation provenance flags remain unchanged; this file supplies their current disposition.

The native [result archive](result01.json.gz), SHA256 `9fc5b99048d45ba2632127eec48fcdfbb40bddcb89a44e7f320c2853ea50fe59`, records HLS IP Gen2026.1.0, all three commands rc0, and inner aoc target `AGFB027R25A2E2V`. The [additive sample](../../afu/ahls_memory/) derives from hls-samples tag2026.1.0 commit `0abae6d78af5daca3fe5d67e617ab037e58aff89`, with exactly two awidth32-to34 changes and provenance comments. Existing scalar AFU sources are retained. The generated inventory has251 files, not251 RTL modules. The review checked all31 port declarations across eight interfaces, not the semantics of unexported RTL. [Source and port findings](result-independent-review01.md#compiler-target-and-exact-source).

## Boundaries that remain open

- Two Avalon memory hosts have34-bit addresses and256-bit data. The metadata spans support16GiB per-host spaces, but generated Tcl omits explicit addressUnits. Do not treat header/XML metadata alone as imported byte/word semantics or physical bank mapping.
- The second compiler-space base `0x20000000000` is not an established FIM bank aperture or CSR pointer prefix. The actual pointer datapath must settle projection onto the34-bit host.
- The generated finish-counter macro is duplicated at0x30/0x34. No unaligned64-bit read at0x34 is justified. Actual counter width/read-clear behavior, byteenable semantics and store-retirement completion need this design's RTL.
- XML device_model `agfb014r24a3e3vr0_dm.xml` differs from the requested inner backend target; preserve and disclose it rather than silently correcting or claiming validation of that model field.
- No Quartus25.1 import, persona build, OPAE/DMA execution, numerical DDR result, timing, or live hardware acceptance follows. Future signed-int test vectors must avoid addition overflow.

See the [review's detailed ABI limits](result-independent-review01.md#register-map-boundaries-not-a-deployed-mmio-abi). A separate generated-RTL acquisition/analysis follows this milestone; it must not be conflated with report-generation acceptance. No produced executable was run and no hardware operation occurred.
