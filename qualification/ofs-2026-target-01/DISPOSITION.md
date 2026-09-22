# Parent disposition — selected OFS 2026.1 target

**ACCEPTED as bounded upstream/source-selection research. No jointly qualified release or hardware success claimed.** The selected `OFS/examples-afu:ofs-2026.1-1` prerelease remains the AHLS target; prerelease labeling is not a blocker.

The parent read the full [independent review](upstream-review.md), verified all 15 `SHA256SUMS` entries, compared all recommended commits to `sources.lock.json`, and independently fetched the official examples release/tag, FIM tree and pinned `top.sdc`. [Parent verification](parent-verification01.json) records exact results and hashes. The report SHA256 is `47ce6906aafbff19a60d440bceb960a13969f3826ad7a715b8bf97cf01674870`.

## Selected source basis

- FIM `599ac052eafbc9cede22561c099233ae4a54cb7d`: public `ofs-2025.1-1` donor with maintained IA840F port.
- Common `34a8540697fdf3d66fbcaa263fa037bae17cc32f`: exact gitlink of that FIM.
- PIM `3c21189e728009d4c492fa2be54c0ab1008b06dc`: pinned PR-freeze interface update.
- Examples `4a1350e3c9e223d8bac3cb47f756a1d919ef8de1`: explicitly selected `ofs-2026.1-1`.

All four commits already match the lock; **no donor-pin change is needed**. The inspected official repositories/refs did not provide a matching four-repository 2026 release tuple. This is a bounded public-source finding, not a claim about private/unpublished releases. Keep `fim_release=ofs-2025.1-1` as accurate donor provenance; do not manufacture a 2026 FIM tag or relabel prior Work14 artifacts.

## Engineering consequences

1. Preserve Quartus Pro 26.1.1 and AHLS 2026.1.0. The official AHLS handbook requires the 26.1 Quartus family for Agilex 7, while the FIM donor documents 25.1. Exact combined IA840F qualification remains our integration work, not an upstream certification. [Review §2](upstream-review.md#2-documented-support-versus-project-qualification).
2. Fresh official `top.sdc` bytes equal the maintained file: `8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`. The obsolete divider hierarchy and dependent exceptions remain; selecting the examples release does not fix them. Continue the preserved-copy fitted diagnosis, then a source-supported narrow repair. Do not rebuild unchanged sources. [Review §3](upstream-review.md#3-pcie-generated-clock--p-tile-exact-applicability).
3. Preserve IA840F pins, both distinct DDR channels, BMC/PF/VF routing, UART/HPS absence and existing PR isolation. The new optional PR-freeze notification is not proven connected end to end by its PIM field alone; inspect the actual selected AFU wrapper before consuming it. Do not tie it inactive to conceal an interface mismatch or redesign the shell unnecessarily. [Review §4](upstream-review.md#4-relevant-2026-pr-changesand-the-integration-seam).

Publication preserves the exact upstream excerpts in `source-evidence.txt`, including original CRLF/trailing whitespace. Scoped staged whitespace diagnostics are confined to that hash-bound verbatim evidence; they are an evidence-preservation exception, not a reason to rewrite captured source. Authored documents and all other staged files must pass the whitespace check. No licensed binaries, license contents, internal transcripts or oversized payloads are included.

This disposition changes no maintained donor source, lock, consumed build record, device setting or hardware. The separate EMIF1 hold violation, other timing/CDC issues, matching persona and all live qualification gates remain open.
