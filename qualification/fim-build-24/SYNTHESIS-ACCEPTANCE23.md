# Work24 synthesis acceptance — with findings

**Accepted gate: completed synthesis only.** Independent review [synthesis-review18.md](synthesis-review18.md), SHA256 `6df5fca368386483c5a16bf4ac14bce43ba02206e3bcf56d94e4bc883d908971`, was parent-consumed after verifying all8 frozen members and the4 native reports. [Consumption receipt](synthesis-consumed23.json); [frozen inputs](synthesis-freeze17.json).

The reports identify Quartus Pro26.1.1 Build130, AGFB027R25A2E2V, revisionofs_top/top and actual Work24 synthesis PID319273. Native synthesis reports success with0errors/81ordinary footer warnings. Resources remain62192estimatedALMs,169070registers and12post-mergingDSPs. [Native summary](synthesis15-readback/ofs_top.syn.summary).

## Complete diagnostic comparison

There are **495 severity-prefixed records**:413 frontend ordinary warnings,81 sweep/mapping ordinary warnings and one Critical Warning19854. The footer is not the total diagnostic count. Parent and reviewer independently checked complete raw-line Counters against Work23; equality holds only after the disclosed exact Work24→Work23 root pairing and verified temporary synthesis-PID directory319273→302961 pairing. There are zero added/removed diagnostics after those substitutions. [Comparison](synthesis-comparison16.json); [review evidence](synthesis-review18.md#independent-diagnostic-comparison).

Both small DRC reports differ from Work23 only in timestamps. Partitioned DRC has0/10failures; synthesized DRC retains6/13failed rules. Critical19854, initialization/preservation issues, invalid/ignored assignment panels, scalar-AFU freeze behavior, control-shadow export, PIM typing, idle DDR boundaries and BMC/host-IRQ limitations remain explicitly retained. Matching diagnostics is not their resolution. The active image is the scalar qualification AFU, not CAPS03. [Review retained findings](synthesis-review18.md#retained-findings-and-physical-boundary); [prior synthesis acceptance](../fim-build-22/SYNTHESIS-ACCEPTANCE45.md).

## Limits

The one admitted full compile continues independently of this review. Synthesis does not prove that CLOCK_SPINE2 was consumed, that the full clock region/root ownership survived implementation, or that hold/setup timing improved. Fitter, STA, assembly, exact all-five-corner bit243 no-exception evidence, both CPA compensation roles and collateral PCIe/DDR/PR/clock checks remain unaccepted. No hardware operation follows from this gate.

The complete54,688,090-byte synthesis report stays local, SHA256 `53644d50bdae21b943d148cd2d7a59d843fa1fac1b78a844e3e1813bb68ef5fb`. Small native DRC/summary files are retained byte-for-byte; native whitespace is not normalized. Raw transport archives, licensed files, databases and programming images remain excluded from publication. Reviewer model substitution: GPT6/openai-codex for unavailableGLM5.3.
