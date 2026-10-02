# Work24 — independent synthesis review18

## Verdict: ACCEPT WITH FINDINGS — synthesis only

Completed synthesis evidence shows no new diagnostic or synthesis-resource regression against Work23. This is **not** clean-warning/DRC, Fitter, timing, PR, hardware or overall migration acceptance; parent tracking remains open.

Reviewer: **gpt-6-astra-900k / openai-codex**, substituted because preferred GLM5.3 was unavailable. Local evidence reads and in-memory Python only; no SSH, vendor/source/test execution, process interaction, hardware or Git mutation. Only this report is written.

## Evidence and identity

Independently verified declared **8/8** members, sizes and SHA256s in [synthesis-freeze17.json](synthesis-freeze17.json), including archive/receipt, comparison and startup identity. Freeze SHA256: `dcf0e4b7626f748fa641a4f3702c06b8fa109654cd998c11402ca7e6eebc5ace`. All four reports also match their decoded archive members byte-for-byte:

| `synthesis15-readback/` member | Bytes | SHA256 |
|---|---:|---|
| `ofs_top.syn.rpt` | 54688090 | `53644d50bdae21b943d148cd2d7a59d843fa1fac1b78a844e3e1813bb68ef5fb` |
| `ofs_top.syn.summary` | 363 | `450b1562db0acb55156378e7b2fd48e868ccb52e52d6c39440bb07353af57d30` |
| `ofs_top.drc.partitioned.rpt` | 7549 | `0f22c072d7120609993edb90b7eccf4319962a5ad50cf57f8946577f5bf813c3` |
| `ofs_top.drc.synthesized.rpt` | 23251 | `22898ed00a1a474989243775eb721b7cce39824556a4e0a0de197281ad225a95` |

`S` denotes the full synthesis report. `S:1338–1346,123451–123459,131493–131497` identifies **Quartus Pro 26.1.1 Build130, AGFB027R25A2E2V, ofs_top/top**, Work24 paths and PID319273, matching `execution-live10.json`. Its admitted-manifest hash and captured executable hashes agree with the admitted record; selected AFU source and candidate QSF hashes also match. Collector `outer_rc=0` is transport success, not full-compile completion.

Successful synthesis: **0 errors; 62,192 estimated ALMs, 169,070 registers, 12 post-merging DSPs**, identical to Work23. Summary differs only in timestamp; both complete DRC reports differ only in their timestamp lines.

## Independent diagnostic comparison

Reparsed every severity-prefixed record, including indentation: **495 = 413 frontend warnings + 81 sweep/mapping warnings + one Critical Warning19854**. Intervals: `S:123851–129930,130718–131467`; native footer `S:131493` reports **81 ordinary warnings**, not 81 total diagnostics. Coalesced warning tables are not additional occurrences.

Complete raw-line Counters equal Work23 only after these literal substitutions:

- `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_24` → `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_23`;
- `/tmp-clearbox/ofs_top/319273/` → `/tmp-clearbox/ofs_top/302961/`.

Both PIDs are verified at each native report's start/end. Root-only comparison leaves eight added/eight removed RAM diagnostics; the verified PID pairing leaves **zero added/removed**. No broad regex normalization. This independently confirms `synthesis-comparison16.json`, preserving Work23's path disposition rather than clearing warnings.

## Retained findings and physical boundary

Carry [Work22 acceptance45](../fim-build-22/SYNTHESIS-ACCEPTANCE45.md), [review39](../fim-build-22/synthesis-review39.md), [BMC disposition44](../fim-build-22/BMC-INPUT-DISPOSITION44.md), [PIM review42](../fim-build-22/pim-user-type-review42.md) and its hash-verified `pim-review-consumed53.json`:

- Partitioned DRC **0/10** failures; synthesized **6/13**: RES-30132=6, LNT-30023=1, LNT-30010=5, TMC-20501=4, TMC-20500=2, FLP-10500=1. Disabled rules remain **1/7**, include-IP-blocks Off. Reset/control, duplication and preservation-clock dispositions are unchanged, not waived.
- Critical19854 retains **54 grouped initialization rows**, not bits/exhaustive coverage. PR reset/freeze/quiescence remains unresolved; selected scalar AFU freeze is tied low.
- Unused control-shadow export **40→1-bit defect** remains; active MSI-X uses its separate path. Six PIM16803 findings retain ordinary compiler trust, actual **580-bit** specialization/SOP513 evidence, and unperformed categorical driver/consumer proof—not demonstrated scalar collapse or a new mandatory full-model gate.
- Native scalar **qual_vec_op**, not CAPS03, and both static EMIFs remain (`S:114241,95985,97502`). Its **48 constant DDR-boundary rows** reflect dormant requests, not qualified DDR traffic. BMC external IRQ/HPS inputs remain intentionally unused; host `pcie_irq()` remains unconnected, not an implemented MSI-X route or electrical tie-off proof. Interface/debug/clock-consumer findings remain.
- Ignored panels retain **20 Level1 + 20 message_level** invalid-name rows, six invalid-target assignments, and ignored maximum fanout; unchanged after literal root pairing (`S:6137–7061,94605–94616,130969–130970`).

The accepted physical delta remains two QSF records: **CLOCK_SPINE2 plus unchanged full CLOCK_REGION** on the exact EMIF1 source; no vendor RTL change. Synthesis does **not** establish spine consumption. Fitter must establish source/spine/region/ownership and collateral effects, followed by unchanged seed3/3ns-EMIF/two-DDR/PR/clock/all-corner signoff requirements, exact bit243 without exception, fit-only margin separation and later hardware gates. No new timing clearance follows.
