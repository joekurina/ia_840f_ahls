# OFS 2026.1 migration — independent integration review01

**Verdict: ACCEPT — completed source integration and preservation only. No blocking finding within that scope.** This is not compile, simulation, timing, deployment, hardware, active-PR, or publication approval. The mandatory PCIe-constraint choice remains unanswered.

## Exact reviewed state

Repository `/home/joe/Projects/Thesis/AHLS/new_bsp/new`, branch `migration-ofs-2026.1-quartus26.1`, root HEAD `1697cc289911a554a939c55f31fc05d3957703a2`.

**Accepted binding:** [`source-binding01.json`](source-binding01.json), SHA-256 **`19dcbd41f164ba73d2a8c22bf66012fab2b4f1d3b26cccb843e05c13e493397a`**. Independently rehashed all **150 source records** (148 vendor files plus lock/prompt) and **14 evidence records**, checking their recorded sizes too; no mismatch. This verdict applies to those bytes, not a subsequent edited binding.

| Component | Previous donor | Accepted target |
|---|---|---|
| FIM | `599ac052eafbc9cede22561c099233ae4a54cb7d` | `866c25bb166810f65aae4f6b15374d0a89810e69` (`ofs-2026.1-1`) |
| Common | `34a8540697fdf3d66fbcaa263fa037bae17cc32f` | `147cae890b7d1245301cf5cde229f761b287b70d` |
| PIM | `3c21189e728009d4c492fa2be54c0ab1008b06dc` | Same pin, explicitly retained by the completed interface review |

The target FIM gitlink resolves to exactly that common commit. Local immutable objects agree with the existing fetch receipt; this reviewer performed no fetch. Both release histories diverge: FIM has 2 old-only/22 new-only commits, common 1 old-only/16 new-only. Neither old pin is an ancestor of its target; the prompt correction is justified.

## Whole-delta and preservation findings

- **Exhaustive tree reconciliation:** independently enumerated both old/new donor trees, not merely the FIM summary. FIM has 100 changed entries, including its common gitlink: **73 modified files and 26 added files**. Common contributes **49 modified files**. Their union exactly equals the manifest's **148 distinct files: 122 modified, 26 added**. There are no upstream-file deletions, missing delta paths, extra migration paths, or changed-file mode mismatches.
- **Exact imports:** all **146 non-overlap files** match their target Git blob bytes, prepared copies, manifest hashes, and final binding. All 122 archived originals match the before inventory and recorded old hashes; the 26 additions have no original entry. Both archived upstream patches independently reproduce from the pinned Git objects byte-for-byte. This includes XML/IP metadata, RTL, simulation infrastructure, board settings, regression additions, and Design Assistant files—not just the PR seam.
- **Complete overlay accounting:** reconstructed the original state against **560 FIM and 917 common donor blobs**. It yields exactly the recorded **eleven modified donor files**, with no unrecorded donor modification: `syn/shared_config/top.sdc`; common's `build_fim.sh`, `build_fim_compile.sh`, `build_fim_finish.sh`, `build_fim_setup.sh`, `build_top.sh`, `pim/ofs_pim_and_afu_config.sh`, `setup_opae_sdk.sh`, `mem_ss_top.sv`, `gen_ofs_settings.py`, and `pcie_ip.py`. Nine are byte-preserved; the two overlapping scripts are correctly merged as detailed below.
- **Preservation:** independently checked hashes, file kinds, sizes and recorded modes for all **1,962 final preserved entries**. All **110 captured FIM/common additions beyond the original donor blobs** remain unchanged, including IA840F board sources/settings/presets and gate implementations. PIM's tracked tree is clean and its captured files are preserved. The 2,086-entry before inventory reconciles exactly after excluding the 122 changed existing vendor files and the deliberate lock/prompt updates. Integration's earlier 1,964 and static verification's 1,963 are valid earlier snapshots, not competing final totals.
- **Root scope:** the tracked root diff is exactly 122 vendor modifications, two deliberate metadata changes, and the two pre-existing unrelated edits. Root `.gitignore` and `docs/hw-programming-recovery.md` retain their before hashes and are excluded from this migration/publication scope. The root index has no staged delta; all captured root heads/tags are unchanged. `main` and `origin/main` resolve to `141b9a4d064dd96f0974c5d2db498aacc602b00e`; released `ia840f-caps03-v1.1.0^{}` remains `c3ddf9f595b68a022ab46008ccd4bdf0e7575e1b`. Only the detached nested donor HEADs/indexes advanced, and both old/new object sets remain readable.

Evidence: [`vendor01/manifest.json`](vendor01/manifest.json) SHA-256 `773e2c51338275e9017639787e22add06876518120a9ef762392a4e6c2d23583`; [`integration01/result.json`](integration01/result.json) SHA-256 `babf2be9daa9e1dcd939bd49b63c9ea528abedcfbea91821d44106d7c1b68812`; [`basis01/before-files.json`](basis01/before-files.json).

## Two overlap merges

For each script, verified archived `base` against the old blob, `upstream` against the target blob, and `current` against the hash-bound original. Read-only `git merge-file -p current base upstream` returned **0** and reproduced the final file exactly. Inspected both final-versus-original and final-versus-target differences.

| Common-relative file | Retained behavior and upstream addition | Final SHA-256 |
|---|---|---|
| `scripts/common/syn/build_fim_setup.sh` | Early IA840F setup-entry gate precedes board sourcing/writes; guarded `quartus_ipgenerate` and both `quartus_sh --prepare` calls and PIM error propagation remain. Upstream Design Assistant symlink-to-copy handling is added without bypassing those gates. | `2fbd8c6ad96567cfb35e9d42348982aa61c7744c631946bc7989d4ac79db0611` |
| `scripts/common/syn/setup_opae_sdk.sh` | IA840F missing-prerequisite branch still returns failure before bootstrap. Upstream conditional `qcore/linux64/libcrypto.so` path handling is retained inside the bootstrap branch. It does **not** establish live IA840F PACSign/library readiness. | `8c697370276f6b5baaf590a58514a1dfdd408d6c665e0f45d728ec5eb4456808` |

The capture/preparation/integration/verifier scripts were inspected as single-use evidence work, not executed or treated as general-purpose safety infrastructure. Their actual source-copy/merge/readback sequence supports the reported completed result. Existing native gates still require fresh run-specific binding before use.

## Interface, clock and evidence boundaries

- Consumed the completed [`pr-freeze-review01.md`](pr-freeze-review01.md) and [`pim-review-consumed01.json`](pim-review-consumed01.json), rather than reopening PIM research. The report hash remains `5c6dd08784330068165f86fda5589e55b4102017a211710edc2a8902de2f2264`; its twelve non-prompt working hashes still match. The thirteenth, historical prompt hash is intentionally superseded by the final bound documentation correction. The target-common seam files are exact target blobs. The reviewed `pr_slot` → shared `afu_main` → PIM connector → existing CAPS03 consumer source chain is consistent; historical generic AHLS modules do not consume the optional field. Notification is not shell isolation, drain acknowledgment, or active-PR safety. Generated migration selection/elaboration/runtime remain unverified.
- The maintained four-line `top.sdc` remains `b706fc11fbaa2896f66c967c96111e375c450c21b52bb6d6c57d2135dfafc3fc`. `iopll_470MHz.ofss` and `syn/board/ia840f/config/ia840f.ofss` are unchanged. The guarded candidate was not integrated. **Preservation does not select either compile route on Joe's behalf.** Prompt lines 152–157 still require his choice and, if selected, the candidate's separate review chain.
- Lock changes accurately identify an unqualified migration, explicitly retain PIM, and leave all eight execution flags false. No combined-toolchain readiness follows from this acceptance.
- [`static-checks01.json`](static-checks01.json) records **95 successful syntax checks: 86 XML, seven shell, two Python AST**. These were reviewed, not rerun; they are not RTL elaboration or native validation. The reported upstream Python SyntaxWarnings are not erased by that result. [`source-whitespace01.json`](source-whitespace01.json) retains exit **2**, not a clean check: its 91 finding paths are pristine target imports. It covers the unstaged diff only, not the new additions' eventual staged audit.
- One concrete future-use limitation in imported upstream code: `scripts/common/sim/gen_sim_files.sh` continues after an individual `qsys-generate` failure. An overall script exit alone must not later be promoted to complete IP-generation success. That workflow was not run or accepted here; this is not a source-preservation blocker.

## Separate remaining gates and reviewer scope

Publication remains the parent's separate explicit-allowlist operation, including a staged whitespace audit covering additions, exact upstream exceptions, and secret/payload/tool/bitstream/license exclusions. All currently bound source/evidence members are within the 2,000,000-byte per-file cap; the largest vendor file is `ipss/pmci/pmci_ss.qsys` at **1,633,458 bytes**. This size observation is not publication clearance. The evidence-local `.gitignore` correctly excludes redundant byte copies and raw captures; unrelated artifacts remain out of scope.

The unanswered PCIe decision, fresh native/run authorization, 26.1.1 IP regeneration, generated source selection, 3.000 ns fit/STA, new image/persona identities and all card-bound qualification gates remain open. No native or workstation operation is authorized by this report.

Review method: local file reads, independent Python hash/set/mode comparisons, immutable `git ls-tree`/`cat-file`/`show`/`diff`/ref reads, and stdout-only three-way reconstruction. All reviewer comparison batches completed with exit 0 and no mismatches. No builds, tests, vendor tools, source scripts, network/SSH/device actions, staging, commits or Git mutations were performed. **Only this report was written.** Review inherited `gpt-6-astra-900k` / `openai-codex`; it is not a GLM-5.3 review.
