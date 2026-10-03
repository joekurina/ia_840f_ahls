# Migrated CAPS03 assembly — accepted

## Gate closed

One standalone CMake-native assembler operation on the accepted Quartus **26.1.1 Build 130** final STA corpus completed and its actual artifacts are independently accepted **PASS WITH LIMITS**. Native/effective/outer were **0/0/0**, with native zero propagated through the direct CMake target; callback and owned drain passed. No synthesis, fitting, STA, or unchanged predecessor operation was repeated. [Actual result](assembly19/readback/result.json), [independent review26](result-review26.md), [parent acceptance28](assembly-acceptance28.json).

The operation was `quartus_asm ofs_top -c ofs_pr_afu` in `work_fim24_caps03_assembly01/base01/build/syn/board/ia840f/syn_top`. Fresh SOURCE/API and QUALITY obligations were consumed before exact single-use admission. The two review05 corrections protect four STA databases/final reports/user clocks and require the region-qualified PMSF. General readiness and hardware flags remain false. [SOURCE disposition](source-consumed07.json), [QUALITY15](quality-review15.md), [admission receipt](admission18/index.json).

## Actual programming artifacts

These local-only image bytes are retained under `images25/readback/output_files/` and on the workstation's assembly project. Local, native, and transferred sizes/hashes agree; inherited static SOF/MSF/PMSF were preserved, not substituted. [Image acquisition25](images25/index.json), [native assembler report](assembly19/readback/output_files/ofs_pr_afu.asm.rpt).

| Image | Bytes | SHA256 |
|---|---:|---|
| `ofs_pr_afu.sof` | 10067421 | `00dbd01b5b8c7c0b49fb1f9340ac9464e61a634ff045a1c0c4b79a464175d46f` |
| `ofs_pr_afu.green_region.pmsf` | 9409866 | `598bd9e969feffb95653fd0ffef246362257a3605a32098cfe64bdbbe70f023e` |
| `ofs_pr_afu.green_region.rbf` | 10100736 | `9f7830bdf6f12cd2a1934dddaae26f7a231657e1764d3e9dc8c3e239f882964a` |

Interface UUID is `fc603c44-5c8f-5e94-bcbe-a5780030947c`; AFU UUID remains `d48dde9f-f551-578d-8bb0-69483ac95ec6`. Captured user-clock metadata is 100/200 MHz, distinct from the unchanged **3.000 ns** application target. This is captured assembly identity, not deployed-card identity. [Captured environment](assembly19/readback/build_env_db.txt), [clocks](assembly19/readback/output_files/user_clock_freq.txt).

## Preservation and findings

All required preservation domains passed: 4,014 critical bindings, 280 protected static/physical entries, originals and external inputs/tools/results. Five of 26 enumerated runtime roles changed; 21 stayed unchanged. QDB membership increased from 733 to 736 only through the three new assembler report roles; QPF was byte-identical. [Reconciliation23](assembly-reconciliation23.json), [independent preservation review](result-review26.md#3-preservation-and-actual-runtime-delta).

The native footer reports **0 errors / 19 warnings**: 17 SDC base/current assignment differences (18502), one unused optional-clock PR boundary warning (20727), and one ignored obsolete generic RBF setting (20536). Every emitted occurrence is reconciled and dispositioned. The actual PR-RBF was produced under the separate PR-RBF setting; no obsolete-setting effectiveness or warning-free result is claimed. [Complete warning review](result-review26.md#5-complete-native-warning-reconciliation-and-disposition).

## Acceptance boundary and publication policy

This milestone accepts only assembly and artifact acquisition. GBS packaging, SDK flash/readback, BMC Off/On, normal workstation reboot, and the migrated-image numerical/34-case/DDR/walking/bulk gates are separate. Existing STA/CDC, reset-entry, electrical, and static DRC findings remain unchanged. Neither this acceptance nor file integrity proves hardware behavior. `main` remains the published fallback. [Review limits](result-review26.md#6-actionable-blockers-and-acceptance-limits), [migration goal](../../GOAL-PROMPT-MIGRATION.md).

This capsule follows the repository's **2,000,000-byte** publication cap. Raw archives, programming images, native binary databases, oversized inventories, and encoded transfer launchers stay local at their original paths and are SHA-referenced by indexes/reviews and the publication manifest. Payload-free launcher projections preserve record identities without publishing encoded bodies. `.gitignore` governs publication only; it does not exclude QDB trees from runtime preservation. No secrets, licenses, licensed binaries, or agent transcripts are published.

A clean checkout does **not** contain the accepted native workspace, complete oversized input inventories, generated databases, or programming images. The retained CMake/runner sources document the exact qualified operation; they are not a claim of end-to-end clean-checkout rebuildability. Never delete spent `asm01`, reissue its admission, or replay accepted stages to recover these records.
