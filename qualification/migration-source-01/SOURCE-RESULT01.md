# OFS 2026.1 source migration — result01

**Source integration completed; independent whole-delta acceptance pending. No Quartus run, RTL simulation, timing acceptance, workstation contact, programming, or hardware qualification occurred.** The mandatory pre-compile PCIe constraint choice is unanswered; retaining the existing SDC bytes is not permission to choose that route by default.

## Source decision

| Component | Selected identity | Evidence |
|---|---|---|
| FIM | `ofs-2026.1-1`, `866c25bb166810f65aae4f6b15374d0a89810e69` | Official-origin tag fetch and resolved object in [fetch receipt](basis01/fetch-results.json) |
| Common | `147cae890b7d1245301cf5cde229f761b287b70d` | Exact FIM gitlink in [verified basis](basis01/verified-basis.json) |
| PIM | Retain `3c21189e728009d4c492fa2be54c0ab1008b06dc` | [Independent interface review](pr-freeze-review01.md), [parent verification/consumption](pim-review-consumed01.json) |
| HLS samples | Unchanged `2026.1.0`, `0abae6d78af5daca3fe5d67e617ab037e58aff89` | Local tag resolution in [static checks](static-checks01.json) |

PIM is not silently reused: its existing pin is merge #27, which **adds** `pr_freeze_to_afu_in`. The new common connector supplies the missing producer connection through `pr_slot` → shared `afu_main` → PIM `port_afu_instances` → the existing CAPS03 synchronizer/core input. The historical generic `afu/ahls` modules do not consume the optional field. Existing shell isolation and AFU notification remain distinct; no new drain/acknowledgment protocol, inactive tie-off, reset substitution or active-PR safety claim is introduced. The actual newly generated platform/persona must still prove its selected source chain. [Review evidence](pr-freeze-review01.md#selected-source-path-and-signal-chain).

The fetched FIM/common histories diverge from the previous release pins: `old..new` contains 22/16 commits, while `new..old` contains 2/1. Neither old pin is an ancestor of its target. The chosen exact tag/gitlink remains the requested basis; commit counts must not be described as proof of linear ancestry. `GOAL-PROMPT-MIGRATION.md` corrects this and the PIM hypothesis without changing the user-owned compile decision or hardware rules.

## Actual delta and preservation

The upstream FIM diff names 100 entries including the common gitlink; common separately changes 49 files. Integration changes **148 actual files: 122 modifications and 26 additions**. Of these, 146 match new upstream blob bytes exactly; the two overlapping scripts below retain the pre-existing local adaptations as well. [Complete path/hash/mode manifest](vendor01/manifest.json), [integration readback](integration01/result.json).

A FIM-only diff missed ten modified common-donor files. The implementation preserved all board additions and all eleven existing modified donor-file overlays, including the four files emphasized in the prompt, not only those four:

- `syn/shared_config/top.sdc` remains SHA256 `b706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc`, the proven four-line form. The guarded candidate remains parked and untouched.
- Common's `build_fim_setup.sh` retains the early gate, guarded native calls, and error propagation while adding upstream's Design-Assistant-file copy handling.
- Common's `setup_opae_sdk.sh` retains the fail-closed IA840F no-bootstrap rule while adding upstream's `qcore/linux64` libcrypto path handling. Its bootstrap branch remains prohibited for IA840F; this does not prove live PACSign/library configuration.
- The remaining common overlays, IA840F board RTL/settings/presets, source-bound gate implementations and PIM bytes are unchanged. Existing gate identities still require fresh run-specific rebinding before native use; this milestone is not a compile package.
- `iopll_470MHz.ofss` and its board selection remain unchanged. No fitted PLL outputs are claimed for the migration.

The root Git index/refs were unchanged by integration. Only detached nested donor indexes/HEADs were advanced after byte verification; their old objects/history remain available. No existing main/release ref or accepted workspace was rewritten. The pre-existing root `.gitignore` and `docs/hw-programming-recovery.md` edits are hash-preserved and excluded from publication. Other unrelated untracked artifacts are not curated or deleted. [Before inventory](basis01/before-files.json), [integration receipt](integration01/result.json).

## Execution and checks

All commands below were local source operations; each returned **0**:

```sh
python3 -B qualification/migration-source-01/capture-basis01.py
python3 -B qualification/migration-source-01/prepare-vendor01.py
python3 -B qualification/migration-source-01/integrate-vendor01.py
python3 -B qualification/migration-source-01/verify-source01.py
```

The first three scripts retain the exact Git commands, source hashes, merge checks and readback outcomes. The verifier checked every prepared source hash and preserved inventory entry, exact lock/gitlink identities, false readiness flags, unchanged clock sources and protected main/release refs. It also performed **95 syntax checks: 86 XML parses, seven `bash -n` checks and two Python AST parses**. This is not RTL elaboration, simulation or native tool integration. Upstream Python invalid-escape SyntaxWarnings were observed; those unmodified upstream bytes remain intact. [Static result](static-checks01.json).

The verifier ran before the later explicit PIM-decision metadata and prompt corrections. Its unchanged-prompt observation describes that snapshot, not a claim that the prompt was never subsequently edited. Final publication/review binds the final lock/prompt separately.

`git diff --check` returned **2** for upstream whitespace, not a clean verdict. The full [whitespace receipt](source-whitespace01.json) is retained. Do not normalize upstream/captured bytes; the publication audit must enumerate exact hash-bound exception files and reject any authored-file finding. Newly added upstream files are included in that staged audit, not covered merely by this unstaged diff check. The largest changed vendor file is `ipss/pmci/pmci_ss.qsys`, 1,633,458 bytes, below the 2,000,000-byte limit.

## Review and outstanding work

Independent PIM review `deleg_c5f3d542` is consumed, report SHA256 `5c6dd08784330068165f86fda5589e55b4102017a211710edc2a8902de2f2264`. The parent verified all 13 declared working hashes, the three target-common seam blobs and the old missing-producer connection. The reviewed prompt's old hash is a historical snapshot; the subsequent correction is an intentional, separately bound documentation delta.

**Model disclosure:** delegation `provider` and `model` are unset in this runtime, with no per-call model selector. Reviews inherit `gpt-6-astra-900k` / `openai-codex` instead of the preferred GLM-5.3/zai. No Hermes configuration was changed. No watcher-class task was launched.

This phase leaves all native/card gates open: fresh 26.1.1 IP regeneration (including remote STP), new work/run authorization, full fit/STA at 3.000 ns, fitted clock/output/exception validation, new UUID/persona, HLS RTL simulation, SDK deployment, activation, numerical coverage and DDR gates. Do not resume release-wide sample work. The next native action cannot occur until Joe selects the proven four-line constraint or the guarded candidate; if the latter is selected, its separate pending review chain remains mandatory.
