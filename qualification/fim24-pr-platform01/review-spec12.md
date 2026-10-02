# Work24 PR/PIM export — SPEC review12

**PASS — prepared SOURCE/constraint conformance only. No blocking source findings.**

Reviewer: GPT-6/openai-codex, substituting for unavailable GLM-5.3/zai. Review used local reads, hashing and in-memory data comparisons only: no prepared-script/test execution, native tools, project loading, SSH, Git or hardware access. Only this report was authored. Paths below are relative to this evidence directory unless stated otherwise.

## Frozen identity and complete delta

- Independently verified **224/224** members of `source-freeze11.json`, including every recorded size/SHA256. Manifest SHA256: `a0944c244fed12ed8a883fbabc0a5334f847284f7279aebf8ad103f253f88e67`.
- Reconciled `original-inventory01.json` (**6160** entries), `candidate-inventory01.json` (**4283**) and `prepared10-readback/prepared-inventory10.json` (**4285**). Initial exclusions exactly match the recorded prefixes; the only initial retained-entry changes are the two recorded internal symlink relocations. Preparation changes exactly **88 paths: 86 existing files plus two additions**, with no deletion and **4197** pre-existing entries unchanged.
- The exact set is **83 XML + vendor QAR script + PR QSF + QPF + two release helpers**. `prepared10-readback/source-delta10.json` SHA256: `a229dc6d77b23ebc7279b98b04ec1948e57b2d1819bda8a7e168342924b2e34b`. Prepared inventory SHA256: `016120a6f7b16d8e60e55a765ab4cd418969fd61a4f9750372d5f7b474e186d6`.
- Verified all **174 actual before/after captures** (86 before, 88 after) against both inventories, delta hashes and compressed transport members. The two added helpers correctly have no before capture. Also verified all seven prepare10 exported records and all four candidate bindings. This is independent local capture verification, not fresh remote revalidation.

## XML relocation: actual bytes, not parent assertion

Independent tree comparison covered **93,715 nodes** across all 83 changed XML files; byte-splice reconstruction reproduced every after-file exactly. All changed attributes and all eligible historical filesystem attributes reconcile to `prepared10-readback/xml-edits10.json`:

| Exact role | Changes |
|---|---:|
| `deploy/@outputDirectory` | 83 |
| `deploy/entity/sourceFiles/file/@path` | 114 |
| `deploy/entity/childSourceFiles/file/@path` | 31 |
| `deploy/entity/generatedFiles/file/@path` | 1152 |
| `deploy/entity/childGeneratedFiles/file/@path` | 1152 |
| **Total** | **2532** |

Every replacement preserves the suffix and targets the owned `base01` copy. The inventory independently establishes 2449 regular-file targets and 83 deployment directories, with no symlink ancestor or escaping path. **Zero unmapped entries** reconcile with the preparation receipt. Every other tag, attribute, text/tail, comment and byte outside those value spans is preserved; parameters/messages were not rewritten. `outputDirectory` is explicitly deployment-filesystem metadata, not an IP parameter. `candidate03/xml_source_relocation.py` classifies parsed roles and checks target type/containment; it is not the historical whole-XML regex substitution.

## Recipe, constraints and gate preservation

Exact byte reconstruction confirms only:

1. Three vendor QAR references change from `/tmp/${Q_PR_REVISION}.$$.qar` to `${TMPDIR}/${Q_PR_REVISION}.qar`. Native archive `-force` remains; no vendor target `-f` was introduced.
2. The copied PR QSF retargets its existing hook to `../setup/build_gate_release01.tcl` and adds `TEXT_FILE ../setup/ia840f_release_gate01.py`. All other PR assignments remain identical.
3. The copied QPF removes only the `ofs_top` revision, retaining `ofs_pr_afu` alone.

Original base QSF, build/compile/experimental gates, all SDC/RTL/IP inputs, static QDB and four image/intermediate bindings remain unchanged in the complete inventories. No binary QDB rewrite or global compile-gate bypass exists in this delta. The interface UUID remains `fc603c44-5c8f-5e94-bcbe-a5780030947c`.

The new Python/Tcl helpers exactly equal candidate03. They require release-only authority, build-readiness false, exact part/tool/root/self identity, native executable/hash/cwd/argv, live supervisor ancestry and critical-input hashes. `CMakeLists.txt` retains separate direct `version`/`export` targets, pinned 26.1.1 installation, explicit absolute paths and absent-target checks. Its export calls vendor Bash directly; runtime environment/ownership enforcement remains the separately reviewed runner's responsibility.

## Evidence limits and disposition

The draft consistently binds AGFB027R25A2E2V, Quartus26.1.1 Build130, 276 PIM members/head `3c21189e728009d4c492fa2be54c0ab1008b06dc`, seven tools, 15 installed provider captures and six proposed contexts. Those contexts retain five historically observed contexts; current-release IPC serialization is not yet proved.

The consumed source review and provider bytes reconcile: fileutil1.13.5 is supported by the no-project CMake/Quartus metadata receipt; immediate Tcl/cmdline edges and conditional VDS_FILE/VDS_IP_FILE collection remain correctly scoped. Filename absence does not prove VDS inactivity; lexnormalize absence is not a missing-provider finding.

Stored evidence shows 10 pure-helper cases, 20 inert gate cases, five CMake checks and actual standalone Tcl missing-authority rejection (rc1), without creating operation/target. None is vendor integration proof. Runtime QUALITY/authority, diagnostic rejection including 125091, current inherited license handling, preservation and actual export acceptance remain separate; runner absence does not block this SOURCE verdict. No launch permission, persona/DDR/CAPS03 integration or future hardware qualification is granted. The current phase5 scalar/no-DDR scope is unchanged.
