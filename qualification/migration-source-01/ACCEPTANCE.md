# Accepted milestone — OFS 2026.1 source integration

**ACCEPTED for source integration and preservation only. The migration goal is not complete.** No native compilation, RTL simulation, timing, deployment, or real-card gate is accepted by this milestone.

The parent consumed [independent PIM/interface review](pr-freeze-review01.md) `deleg_c5f3d542` and [independent whole-delta review](integration-review01.md) `deleg_549c3c7f`. The latter accepts [source-binding01.json](source-binding01.json), SHA256 `19dcbd41f164ba73d2a8c22bf66012fab2b4f1d3b26cccb843e05c13e493397a`; review SHA256 is `d620f7fd3fc3f59816918b7c3e1312ae5b340039c66e6f6a4e31cc0e5bc70748`. Parent readback reverified every bound source/evidence member and preserved entry before acceptance. [Consumption receipt](integration-review-consumed01.json).

## Accepted result

- FIM `866c25bb166810f65aae4f6b15374d0a89810e69`, exact common gitlink `147cae890b7d1245301cf5cde229f761b287b70d`.
- PIM `3c21189e728009d4c492fa2be54c0ab1008b06dc` explicitly retained after re-deriving its compatibility with the new common's PR-freeze producer. The existing CAPS03 source consumer is connected by the new source chain; generated selection, implementation, and active-PR safety remain unproven.
- Exact upstream delta: 148 files, comprising 122 modifications and 26 additions. 146 are pristine target blobs; two retain both the upstream additions and pre-existing local gates through verified non-conflicting merges.
- All eleven donor modifications and captured board additions are preserved; clocks, reset, PF1 BMC, DDR geometry, application-clock target and existing isolation are not redesigned. The prompt and lock accurately describe the new unqualified campaign and the re-derived PIM decision.
- 95 local source-syntax checks passed: 86 XML parses, seven shell checks and two Python AST parses. These are not vendor-tool or RTL-simulation results. Upstream Python SyntaxWarnings and byte-exact whitespace findings remain disclosed.

See the immutable [source result](SOURCE-RESULT01.md) and [integration readback](integration01/result.json) for exact commands, hashes and boundaries. Its earlier “acceptance pending” wording describes the recorded pre-review state; this acceptance supersedes that status without changing the bound report.

## Open gates

**Joe's mandatory PCIe-constraint choice is unanswered.** The existing four-line SDC remains byte-identical, but preservation is not a default choice for compilation. Selecting the guarded candidate still requires its specified review chain.

All 26.1.1 regeneration, fresh per-run authority, fit/multicorner STA, new FIM UUID, compatible persona, HLS simulation, SDK deployment/activation, numerical and DDR gates remain open. No workstation contact or card operation occurred. The existing main/release fallback is unchanged; publication advances the migration branch only. The release-wide sample campaign remains paused.

Future native verification must inspect every individual IP-generation result: the imported upstream simulation-generation script can continue after an individual generator failure. A final script exit alone is not complete generation acceptance. No such generation was run here.

Reviews inherited `gpt-6-astra-900k` / `openai-codex`, not the preferred GLM-5.3; model/provider override fields were unset and no Hermes configuration was changed.
