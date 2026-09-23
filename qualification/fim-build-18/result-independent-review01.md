# Work18 independent actual-result review

**PASS — narrow evidence acceptance. Native execution completed; numerical timing FAILED.** No material defect found in the frozen result evidence. This is neither hardware qualification nor permission to rerun Work18 or execute a successor.

## Scope and integrity

Local, read-only inspection and in-memory decoding/comparison of captured evidence; no project scripts, vendor tools, tests, Git commands, remote access or hardware operations were executed. Mutable checkpoints and the concurrent recommendation were excluded. Paths below are relative to this directory unless prefixed `../fim-build-17/`.

All **102 frozen files** matched both byte counts and SHA-256 at initial inspection and the closing integrity check. Freeze: `result-review-freeze01.json`, SHA-256 `ab05a7c4b43d9fca680f248f03fa2c8d95fab10459c92531877bc0ca59457290`. Reviewed `RESULT.md` and independently recomputed, rather than assumed, the material claims in `parent-observations01.json` (SHA-256 `0dee60b487d526d6e4a1afc42bbe301fa8a92d1d93099e1828f4b6b0182efb7d`).

Archive-to-manifest-to-readback closure passed for **20 preparation / 16 completion / 9 final-report / 4 postflight exports**. Checked complete membership, decoded sizes/hashes and exact local bytes, including nested gzip hashes where present. Preparation uses base64; the others use gzip_base64. Completion absolute keys were mapped by their evidence/project prefixes, not treated as local-relative paths. Archive SHA-256:

- `preparation01.json.gz`: `2fb25d707d1c8d1502a578a8dea83e4c248a70625d2a993f8922487cb4be6f2d`
- `completion01.json.gz`: `45c9b9674cd3c590bf5ed71acb3de79e24850c53e7437c1fddccf0e106a24a3c`
- `reports01.json.gz`: `9e5f8dea8e0b53a43025e2804b83f4af6d3a605f4cc8752db89ecf5b0d23d497`
- `postflight01.json.gz`: `ea0f0c846505ee2cfca7365d14d4cf757625476d3bb15a96b3116f4f8ac75761`

## Actual native result

`completion-readback01/evidence/run/{invocation,status,native-status}.json` binds the Work18 compile and native rc0; runner completion is **2026-09-23T00:33:11.447650Z**, with the raw native-status timestamp **00:33:11.438968Z**. Gate rejection is false. Native log SHA-256 `c9531afa2ebe09c579be5bb5f2b583600cd8f9264cd2d1d0cb6f47ec894b35f5`: lines 8290/9186/10464/10947/11100/11223 confirm successful synthesis, fitter, two STA invocations, assembler and full compilation, with respective warning counts 81/208/190/187/1/894; these are not additive. Fitter summary identifies Quartus 26.1.1 Build 130 and AGFB027R25A2E2V.

Completion and postflight captures show no matching active native tools **at their captured times**, not a newly checked live state. Successful execution is not successful timing.

## Preservation and experimental delta

Recomputed stored inventories against the accepted full baseline `../fim-build-17/retiming-eligibility01/prepared-readback01/preservation.json.gz`, SHA-256 `1aea41bcdb3076462e19e0990c6b2f183c836d0d7fa74afd73854e9d8ba22a67`: original Work17 **7,622 bindings** and PIM **536 bindings** are unchanged. SOURCE differs by exactly two gate path retargets and the disclosed new `build_fim_work_ia840f_fim_18.log`; SOURCE byte identity must not be claimed.

The 5,424 prepared Work18 inputs match the draft inventory. Preparation differs from original Work17 only by the two gate retargets, two recorded symlink relocations and QSF addition. Postcompile input changes are exactly generated `build_env_db.txt` and `fme_id.mif`. Exported project/report identities also match postflight inventory; QDB inventory contains 1,540 entries, not independently exercised snapshots.

Direct QSF comparison confirms the sole functional trial delta: exact EMIF1 `amm_writedata_0_r[0][243]` instance `ALLOW_REGISTER_RETIMING OFF`; global retiming remains ON. Completed QSF SHA-256 `e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f`. Unchanged `top.sdc`, SHA-256 `3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814`, retains the singleton-guarded 10ps Fitter-only margin. Native applied/STA-skipped markers corroborate unchanged signoff.

## Numerical failure and interpretation

All 788 STA-summary rows were parsed. Summary is byte-identical to Work17, SHA-256 `5d155eb3f7873329912e99966380fc3c4841be3a0fc917fa862e148bf3bee869`. Its sole negative row remains EMIF1 hold **−0.004ns**, TNS **−0.004ns**, Fast vid2 100C. Other minima: setup +0.151ns, recovery +0.274ns, removal +0.137ns, pulse width 0.000ns.

`reports01/output_files/ofs_top.sta.rpt`, SHA-256 `ca2ed19589bc01e6bfac1028bd3a0cbdd50a6f0f801677cdce58ab7d42bc5020`: all five inclusive blocks **5111–5227, 35547–35663, 65965–66081, 96376–96492, 126779–126895** equal Work17; independently recomputed LF-normalized hashes, including final LF, match the parent record. Work17 report SHA-256 `c476ad6df2779530328d4d1326b5d2cb7ab9381522ab3f9e318d401420c4ac27`, also bound to the accepted preservation inventory.

The last block still shows Hyper-Register `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32` → `UFI_X210_Y0_N355` → `IO12LANE_X184_Y0_N374`; arrival/required 2.964/2.968ns, data delay 0.288ns, uncertainty 0.030ns, no SDC exception. QSF presence and global Fitter “On” do **not** prove effective instance-assignment consumption. Unchanged physical timing proves no observed improvement, not the causal reason.

Signoff DRC, SHA-256 `a5796d041624fdd7953655c53170880dcc89d11954ca7ac107f604522aae71d8`, lines 123–214: recomputed **23/88 failing rules; 7 High failing rules, 34 High violations, zero waived**. Timing coverage, CDC/constraints, electrical, PR and functional acceptance remain unresolved. DDR simulation was skipped by user. Hardware is NOT RUN / NOT QUALIFIED; `ready_for_build=false`; authorization remains spent.
