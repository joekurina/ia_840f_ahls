# Migrated CAPS03 GBS packaging — accepted

The separate offline GBS operation is **PASS WITH LIMITS**, independently reviewed and consumed by the parent. Native `create-gbs`, `gbs-info`, and `get-rbf` each returned0 and drained; outer acquisition returned0. It reused the accepted PR-RBF without opening a Quartus project or rerunning assembly/fit/STA. [Actual result30](gbs30/index.json), [FINAL review32](gbs-result-review32.md), [parent acceptance34](GBS-ACCEPTANCE34.json).

## Actual container

- GBS: `gbs30/readback/ofs_pr_afu.green_region.gbs`,10,101,127bytes, SHA256 `800cc202ca5b3ce239887cd1f9939d11557235d415d470e945d42853e3815f16`.
- Header:16-byte `XeonFPGA\xb7GBSv001`, followed by a little-endian uint32 serialized metadata length371; payload begins at byte391.
- Payload:10,100,736bytes, SHA256 `9f7830bdf6f12cd2a1934dddaae26f7a231657e1764d3e9dc8c3e239f882964a`, independently byte-identical to the complete accepted PR-RBF. Native extracted-RBF equality is a separately captured runtime assertion, not a second independently transferred extraction.
- Interface UUID `fc603c44-5c8f-5e94-bcbe-a5780030947c`; AFU UUID `d48dde9f-f551-578d-8bb0-69483ac95ec6` unchanged; user clocks100/200MHz, class `ofs_plat_afu`, version1/power0/one context; default magic `0x1d1f8680`.

Whole metadata equals the original selected JSON except interface insertion, two auto-clock strings replaced numerically in the package only, and default magic. Original JSON, clock bytes, all selected tools, design inventory, and accepted assembly result remain unchanged. [Native metadata](gbs30/readback/info.log), [source JSON](gbs30/readback/afu.json), [independent container verification](gbs-result-review32.md#4-independent-container-and-metadatapayload-verification).

## Limits and retained bytes

This is **container and payload acceptance only**. It does not authorize runtime PR or establish SDK flash/BMC/reboot deployment, reset/electrical behavior, or actual-card numerical/DDR correctness. Existing STA/CDC/reset/electrical findings remain; raw readiness/hardware/deployment flags stay false. `main` remains the fallback. [Limits](gbs-result-review32.md#5-limits-and-actionable-blockers).

The raw GBS and transport archive remain local-only under the repository's2,000,000-byte cap; sizes/hashes are retained in the result and publication manifest. Clean checkout lacks programming images and accepted native workspaces. Never replay spent `gbs01`, `asm01`, or unchanged predecessors to reconstruct this acceptance.
