# Work24 PR-export native-result review35

**Recommendation: ACCEPT WITH FINDINGS for the completed release-only native export. No native-result, preservation, DNI or elaborated-DRC blocker to offline persona preparation was found.** Parent acceptance and the separate PIM/QIP-closure review remain outstanding; this is not unconditional platform/persona acceptance. Do not repeat the export.

Reviewer: GPT-6/openai-codex, substituting for unavailable GLM5.3. Local reads, hashing and in-memory parsing only; no prepared-script/test/native execution, SSH, Git or hardware access. Only this report is authored. Paths below are relative to this directory; `O` = `completion31-readback/operation`, `B` = `completion31-readback/base-reports`.

## Evidence identity and completed native scope

- Independently verified **374/374** sizes/SHA256 values in `actual-result-freeze34.json`; freeze SHA256 `4819f02a84124a8079b68c8d0bdd9c6b60c8512c24051534bf7da73f8e9e30b5`. All **30** completion31 and **309** closure32 compressed transport members reproduce their local readbacks and recorded hashes.
- Admission SHA256 `04a13bd88808fc1af4e4ce4864f6e3883631e681dbb2fe38bd993c25aa39b120` and candidate24 runner SHA256 `829ec7bb96644f3f2730bf43b571c6f40e7e011d1e42e38931f7b680b2275f14` reconcile with dispatch, admission29 and actual authority/result records. Authority hash and admitted contexts/critical-input map match.
- `O/result.json` and `O/status.json` are semantically equal: `complete=true`, ended **2026-10-02T03:55:09.891779+00:00**. Configure/version/export each have CMake/effective **0/0**; configure has no vendor status, while version/export record propagated vendor zero, not separately instrumented per-child receipts. Every timeout/gate/log-bound flag is false and owned live-group lists are empty. Completion31's **03:57:17Z captured observation**, not a fresh process inspection, also found no native processes.
- `O/gate-events.jsonl` contains **six accepted events/five distinct admitted contexts**, including actual `quartus_syn --ipc_flow=4 --ipc_mode ... --dni --disable_all_banners --analysis_and_elaboration --dni`. The repeated restore callback is not another run. No Error/Fatal, gate rejection or Critical Warning125091 was found.
- `B/ofs_pr_afu.flow.rpt:42,69,86` establishes successful **Analysis & Elaboration only**. `B/ofs_pr_afu.syn.rpt:73–85,1567–1575` identifies `ofs_pr_afu`, top `top`, **AGFB027R25A2E2V**, Quartus26.1.1 Build130, root `ofs_top.qdb` and a Reconfigurable green region. This is not persona fitting, timing or assembly.

## Preservation and exact bookkeeping finding

The captured postflight code/results compare all **6,160 original Work24 entries**, **2,541 critical inputs**, **276 PIM members**, seven tools, 15 installed providers and five static artifacts. All preservation flags pass. This verifies captured remote checks, not fresh remote state.

The **3,454-entry** release inventory matches UUID `fc603c44-5c8f-5e94-bcbe-a5780030947c` and the bound QDB/SOF/MSF/PMSF sizes/hashes; the blue-bits SOF is the relative link to that SOF. The original green RBF is preserved but is **not** asserted exported. Of **4,285 pre-existing prepared entries**, **4,283 remain identical**. Exactly these two changed, under `syn/board/ia840f/syn_top/dni/`:

| Path | Before SHA256 | After SHA256 |
|---|---|---|
| `checkpoints/manifest.txt` | `0f9eaef1795ac0239724da166d51e13211adfbf33f65982b7dcb2be56c745713` | `0390b4ddc27612f1f1381439739d69dafce1d836aeaf350952a55635c1e9f92a` |
| `sandboxes/.properties.folder.kvp` | `7ac53af34917ba790cb717e4a561796c139f475b9487973f0a4f314f8af2a800` | `1cef8aaa8c2827d36db62253a25d4aa2e19e0b6a7c64bbbfe48ebfc58b1c7498` |

`closure32-readback/{dni-before,dni-after}` supplies all four bytestrings. Before hashes match both original01 and prepared15 inventories; after hashes match the actual rejection.

- Manifest: **79→110 bytes**, now naming `ofs_pr_afu` alongside `ofs_top`, with serialization metadata changes. Classify as checkpoint-directory bookkeeping associated with the new A&E revision—not a byte-append-only edit or a generically decoded Boost archive.
- Sandbox properties: **141→141 bytes**; exact replacement of `Agilex7Workstation_319273_0` by `Agilex7Workstation_333868_0` reproduces every after-byte. PID319273 is the prior Work24 synthesis identity (`../fim-build-24/execution-live10.json`); PID333868/start46231169 is the owned export synthesis identity in `startup-verification23.json`.

The copied tree inherited accepted DNI state despite excluding `db/` and `qdb/` directories. Existing checkpoint payloads/source/static artifacts are not reported changed. `candidate24/run-export24.py:120–127` allowed only QSF/QPF changes, so these two bookkeeping updates correctly caused the **sole** postflight error, `unexpected_prepared_input_changes`. Preserve **outer1**, `execution_clean=false`, and `only_expected_native_project_metadata_changed=false` immutably. Accept through this explicit bounded classification, not a raw-result rewrite, blanket DNI exemption or native rerun.

## Warnings, A&E and DRC limits

All severity-prefixed warning occurrences reconcile exactly between export.log and both synthesis reports; duplicated report copies are not additional warnings:

| ID | Occurrences | Finding |
|---|---:|---|
| 13461 | 1 | `fim_pf_vf_nmux.sv:111`: parameter M behaves as localparam |
| 24420 | 1 | PCIe request splitter line298: mixed valid/invalid pragmas |
| 21610 | 70 | Template PCIe and both external-memory interfaces have undriven outputs tied to GND |
| 23762 | 1 | Sweep removes one `fim_dup_tree` hierarchy |

These **73 ordinary warnings** equal the archive footer; prepare/restore/macro-emission footers each report **0 errors/0 warnings**. No critical/error diagnostic is hidden by those wrapper footers.

The admitted, hash-matching release recipe enables `OPAE_PLATFORM_GEN`; the hash-matching `port_afu_instances.sv:14–19,112` explicitly excludes the actual AFU. Native macro-usage rows corroborate this. The undriven-template observations are therefore not active-persona correctness evidence or grounds for speculative RTL repair.

`B/ofs_pr_afu.syn.ae.rpt:9616–9630` retains six unmatched MESSAGE_DISABLE targets and three unmatched reset REMOVE_DUPLICATE_REGISTERS targets. Later actual-persona/Fitter applicability remains unproved. `B/ofs_pr_afu.drc.partitioned.rpt:45–58` reports **0/10 elaborated rules failed**, zero violations/waivers—not full signoff DRC.

Retain Work24's accepted physical findings (`../fim-build-24/PHYSICAL-ACCEPTANCE47.md`), including 23/88 failed DRC rules and PR/electrical/reset/freeze limitations. This export clears none of them. No active-persona functionality, DDR hardware, timing, deployment or programming claim follows. No vendor-internals requalification or full CPA-model gate is warranted for offline preparation; future native persona work needs its own correctly bound scope, not reuse of this consumed release-only authority.
