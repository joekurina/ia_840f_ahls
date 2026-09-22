# Work17: next native diagnostic

**Recommend one exact-launch assignment-applicability check, not another fit or snapshot comparison.** The missing fact is whether bit243 is a unique pre-fit register that the installed Agilex 7 Fitter permits targeting with instance-level `ALLOW_REGISTER_RETIMING`. No corrective assignment is yet validated.

## What changed the decision

The successful query actually loaded routed and final databases (Q:37–40,509–513,974–981). Both select the same Fast vid2 100C path: bit243 Hyper-Register → `c2p_350_ufi` → PHY, slack **−0.004ns**, arrival/required **2.964/2.968ns**, data **0.288ns**, skew **−0.080ns** (A:9–22,31–44). The entire detailed path body is byte-identical (R:36–219; F:32–215), including **0.030ns signoff uncertainty**. R:21–26 lists five models; F:21–22 lists one. This is same-selected-corner evidence, not single-corner-only routed evaluation. Fresh full signoff agrees (S:126779–126895).

**Late retiming/finalization did not create this exact failure.** Nevertheless, its already-routed launch is a Hyper-Register (R:166–179); a narrowly targeted implementation restriction remains a testable alternative to increasing uncertainty. Do not confuse that hypothesis with proof that disabling retiming forces an ALM register or fixes hold.

All-path hold optimization, high-performance mode, maximum placement/router effort are already reported (T:163–186,206); aggressive hold is already requested ON (C:128). The 10ps overlay is Fitter-only (B:151–165). Nine setter markers (L:8811,9041,9050,9054,9130,9143,9146,9166,9176) prove issuance, not effective retention; repeated `-add` is relative to derived uncertainty, not cumulative (U:66–83). The completed direct-SDC scan found no later relevant setter, without proving transitive retention (D:3–5). Neither repeat auditing nor inaccessible absolute Fitter uncertainty is the next prerequisite.

## The single bounded observation

Use the existing preserved-copy procedure for **one ordinary `quartus_sta -t` diagnostic**, without assignment writes, synthesis or fitting:

1. Query `get_assignment_name_info ALLOW_REGISTER_RETIMING` and membership in `get_all_assignment_names -family {Agilex 7} -module fit -type instance`. These are documented native queries (H:24–50,68–98); family-wide presence alone (N:217) does not establish instance scope. Capture legal values and applicability text, including any limitations.
2. Load the existing post-synthesis database with `create_timing_netlist -post_syn` (P:25–61). Resolve the **literal full launch name in A:19** with `get_registers [list $launch]`; emit raw count and every returned name. Do not suppress duplicates or silently rewrite bracket escaping (G:417–451). No timing rerun is needed.

This is one candidate-eligibility record: **instance support, legal OFF value, raw match count, exact names**. The installed retiming description says it controls Fitter register movement while maintaining component logic (I:1, `hits` entry10780); confirm that description natively rather than infer support from binary strings.

**Measurable decision:** instance support=1, OFF legal, compatible native applicability, and exactly one matching literal pre-fit register justify preparing a single-bit `ALLOW_REGISTER_RETIMING OFF` trial—not a global restriction. Any zero/multiple/wrong-name match, unsupported scope or incompatible applicability rejects that candidate; stop, do not broaden to EMIF hierarchy. Positive metadata is not proof of Fitter consumption: a later trial must show the intended launch/path implementation changed and unchanged-signoff hold reaches ≥0.000ns across all corners without setup/coverage regression. An unchanged path/slack is an ineffective trial, not permission to escalate margins.

Preserve both DDR instances and the existing 16GiB configuration, clocking, board part/speed, PR/PIM, vendor PHY, seed, effort and original signoff. No hidden controls, callbacks, identity spoofing, waiver or hardware operation. This report authorizes no execution.

## Citation identities

Paths relative to `qualification/`; full-file SHA256:

- R `fim-build-17/snapshot-compare01/result-readback01/reports/routed-hold.rpt` — `71a6cbb13e842774f18da8b01fbe98bcddbdb5838082c1bc0144cf3fcd3ebe9d`
- F `fim-build-17/snapshot-compare01/result-readback01/reports/final-hold.rpt` — `a4f0639789f2813ac82445aa1dc1db9ec1053ee0e13f5779fad3ad62b65ec032`
- A `fim-build-17/snapshot-compare01/result-readback01/reports/audit.tcllist` — `45652bebdf7936896600103c6b80eaadfbe5e6f8f9be5637e72b80dea3ca8ca4`
- Q `fim-build-17/snapshot-compare01/result-readback01/query.log` — `f9fad7f886541cad7a313c3d385c18bcd01aadd944fe929bf6d723b506fffe9b`
- S `fim-build-17/reports01/output_files/ofs_top.sta.rpt` — `c476ad6df2779530328d4d1326b5d2cb7ab9381522ab3f9e318d401420c4ac27`
- T `fim-build-17/reports01/output_files/ofs_top.fit.rpt` — `2a29087fa7aeb784fb479234122a738d8e152daa1c89cb2cc4a11c17a106a7f2`
- C `fim-build-17/completion-readback01/project/ofs_top.qsf` — `502f55c2eca4441d221851af3dce4431a63f10426a7477b73ec94724e62d3daa`
- U `emif-hold-objective-01/fit-help05.txt` — `e5b443155a530e5f29a9eeca203cfef1738410fbddd7a3d152c18c4e189e31ca`
- N `router-native-capability-01/remote-evidence/agilex7-assignment-names.txt` — `e4e317f026077f28e11dbac58199a602281e549d0181dcc3c81b647c59439b09`
- H `router-native-capability-01/remote-evidence/metadata.log` — `a53dadf7e96241bc8b6766b59bf939dc813092a22d5152b5b29e63432f9820af`
- P `emif-hold-objective-01/fit-help03.txt` — `3ffde2a26cf87e6a5eb7ddb840ed5c284111cb4942fcef75293251abad13685d`
- G `pcie-clock-repair-01/api-help01/readback/help.log` — `5a8989da4e1ac8fde989a0c41e39464d3d721e504870836ee23ebe8078ade335`
- I `msa-timing-next-01/installed-options.json` — `d44006882b668380bb16c116b4252d4d53efbe56b131e1c44f083dfe69e93f41`
- D `emif-hold-objective-01/loaded-sdc-disposition01.md` — `a580a73c1af5df56ed4f1e9e9a938909b69ecb9b9a1851709662e6f24dff0c38`
- L `fim-build-17/completion-readback01/evidence/run/native.log` — `cae130408ae47538f866a98b7585c9eac78e806e2fead1a2c97fefaf32d0f9c1`
- B `fim-build-17/top.sdc` — `3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814`
