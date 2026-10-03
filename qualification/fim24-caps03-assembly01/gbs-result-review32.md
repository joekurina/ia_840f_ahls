# Actual offline GBS result30 review32 — FINAL — PASS WITH LIMITS

**Reviewer:** independent Hermes subagent; model `gpt-6.1-sol-900k`, provider `openai-codex`.

**FINAL: PASS WITH LIMITS — actual offline creation/info/extraction and accepted PR-RBF payload identity pass; zero in-scope corrective blockers.** No deployment/hardware/migration-completion acceptance, new execution authority or parent-task closure.

**Method:** local reads/hashes/AST/JSON/binary parsing only; no project imports, tests, native/vendor/remote/Git/hardware operation or executable change. Only this report was written. Remote preservation/extraction/drain are captured-runtime observations, not fresh remote measurements.

## 1. Frozen bytes and acquisition

Read `gbs-result-freeze31.json` first: **1783 bytes**, SHA256 **`7d71e5612a20328164d1333238eb2f203030bbde606c7b3cf362cc6c6e5d454f`**. Independently verified **11 declared / 11 enumerated / 11 exact size-and-SHA256 matches / zero mismatches**, including the actual GBS and accepted RBF. Paths below are capsule-relative. [Freeze31:2–50](gbs-result-freeze31.json#L2)

| Frozen member | Bytes | Independently verified SHA256 |
|---|---:|---|
| `assembly-acceptance28.json` | 1657 | `bea9ed759d12c101276635788ae34140b6a00f5d810f937d8ac666c174f5ed2c` |
| `gbs-input-basis21.json` | 5119 | `fb633976dc36fb98c9d0a6a275ec3343eda3d248c6abd6b178f8d7983921c348` |
| `gbs30/index.json` | 4806 | `705f0f6f7ce7a4d691a5e34591a910bd090683aef8e8bc3be666d6425c583c94` |
| `gbs30/readback/afu.json` | 391 | `4391d1756d904ab7fc9125c9cd5dac923f470130223ea21d625081414547bbab` |
| `gbs30/readback/create.log` | 102 | `67769053bdc215891e34762698b899def90df9df71ac055167912b8316bab09b` |
| `gbs30/readback/extract.log` | 88 | `8efbaf5686b9173df45581375d5275a39001bc6d4722f3f70bc1c81ab5abf0f1` |
| `gbs30/readback/info.log` | 550 | `20e96b990dac889be7b0b4763dcda71f57a02c2242e0e8ef03b20d618ef2eed5` |
| `gbs30/readback/ofs_pr_afu.green_region.gbs` | 10101127 | `800cc202ca5b3ce239887cd1f9939d11557235d415d470e945d42853e3815f16` |
| `images25/readback/output_files/ofs_pr_afu.green_region.rbf` | 10100736 | `9f7830bdf6f12cd2a1934dddaae26f7a231657e1764d3e9dc8c3e239f882964a` |
| `package27.py` | 13780 | `416d9f4923b538eb45b5236b4915e6e52cab10a075b8d797e94b4321d33e2c47` |
| `packaging-basis06.md` | 6109 | `414ab7ce74ebc99001efd45da401fc5eda818d1f535b24aebff324869b93ba3e` |

Envelope30: **7172786 bytes**, SHA256 **`0d2e7ad654d6030327a8edc58709f58ff10dd501dfe6f5c667a633f524c7f184`**, matches index/transport; **5/5** exports decode to exact local bytes/size/hash. Envelope fields equal index apart from stripped base64 and four index-only transport/script/outer/pane fields. Transport records collected state, exact package27 hash, batch `ia840f_capture_57dc89b7c80142d6811534d9b8ab9d75`, pane `@404 %404`, **outer_rc=0**. [Index30:96–126](gbs30/index.json#L96), [transport30](gbs30/transport.json)

## 2. Exact accepted inputs and source route

Parent-consumed assembly acceptance28 remains **assembly-only PASS WITH LIMITS**. Rehashed review26 is `ff1bfa9523f4a4b06dbea6add697ffe00d3c9d68d34a0e1b2d03c22def262245`; actual result is **`d8a03af543af01c422af7adac8fdc50a709fa8df4a9e6e68d058157f93760f1c`**, both matching acceptance/package bindings. All three accepted image records equal the actual result; package27 checks them before copying the persona RBF. Static-image verification/warnings remain accepted as in review26, without replay or new bit-equivalence gates. [Acceptance28:11–39](assembly-acceptance28.json#L11), [review26:111–145](result-review26.md#L111), [package27:81–95](package27.py#L81)

AST configuration preserves basis21's fields/**15** tool bindings, adding the accepted-result binding and `/usr/bin/python3`→`/usr/bin/python3.9` (15448 bytes, **`7a95e551de45a54b3b6819d80e71a7262cd7138c2a4f1ec905b4cc8895a034c2`**). **16/16** selected size/hash/realpath bindings equal captured-current `opae_tools`+`tools` in inherited and prepared maps. `/usr/bin/packager` is224 bytes, **`3a3e8a5d1747f8f0c7bc6b7663452032b9b6ceaf1477e247c5e6a1c3a940be00`**, selecting `packager.tools.packager`, not the OPAE runtime namespace. [Basis21](gbs-input-basis21.json), [package27:4,41–45](package27.py#L4), [inherited map](copy03-inputs.json.gz), [prepared map](copy03/readback/prepared-copy03.json), [entrypoint](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/bin/packager)

Exact input selection remains:

- Source JSON `/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/prepare01/afu_sources/ia840f_ahls_memory.json`:391 bytes/hash in freeze table, exactly matching external binding and unchanged export; selected first JSON MISC_FILE, not fallback. [Basis06:13–15](packaging-basis06.md#L13)
- `gen_gbs.tcl`:3786 bytes, **`b012ad8ae74a5cf79b8d50716a780cff807a320a1ae4dfec653e2469e020e21b`**, matching captured bytes/prepared binding. Its main opens the project; package27 reproduces only resolved create-gbs in fresh G, avoiding project opening/afu_synth/compile. [gen_gbs:75–125](copy03/readback/project/ofs_partial_reconfig/gen_gbs.tcl#L75), [package27:90–99](package27.py#L90)
- Completed clocks:133 bytes, **`f5ed24d88af0253192249260b91cf463d7fbdfe382e695a7d2a2c6030e2c3c71`**, locally matched to prepared/package bindings; low100/high200 MHz. JSON auto policy and separate bank0/core3.000ns remain unchanged. [Clock bytes](assembly19/readback/output_files/user_clock_freq.txt), [Basis06:15](packaging-basis06.md#L15)
- Build environment:314 bytes, **`64db499a57f720a29040970f496031b6e63a450f66af4ae56b7a7e89b2bae55b`**, matching prepared binding; `ofs_pr_afu`/`green_region`, **interface `fc603c44-5c8f-5e94-bcbe-a5780030947c`**. **AFU `d48dde9f-f551-578d-8bb0-69483ac95ec6`** is unchanged across source/acceptance/container. [Environment](assembly19/readback/build_env_db.txt), [Acceptance28](assembly-acceptance28.json)

These four historical algorithm captures are present, locally rehashed and match selected current bindings; **not missing dependencies**:

| Captured algorithm source | Bytes | SHA256 / source obligation |
|---|---:|---|
| [tools/packager.py:94–115,163–195](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/tools/packager.py#L94) | 8967 | `f8c1ee77c4bccbca2d9191fc05d39061807435c8fb5c653383d1ad355e564a49`; actual create/info/extract CLI and failure propagation |
| [utils/afu.py:97–180](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/utils/afu.py#L97) | 8940 | `34451ebfac5892e73798b7005d94ef9de9320971189feccefdfcf697dc97ecc5`; numeric package clocks, interface override, default magic |
| [utils/gbs.py:60–70,108–173](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/utils/gbs.py#L60) | 5367 | `20621b57f106c40aaea5e5f0c3609c1eb2bf9236769f62f51d2ce34106b362da`; raw RBF append/extraction and metadata boundary |
| [metadata/metadata.py:36–54](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/metadata/metadata.py#L36) | 2168 | `ae983d64f25a61fa6e88d4d8e15e9af7e1b72a4efcebe2155115e79304a3b5ac`; serialized JSON length and little-endian uint32 |

## 3. Actual native create/info/extract and preservation

All three recorded commands use `/usr/bin/packager`, cwd **`/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01/gbs01`** (G below). Exact argv are retained in index30; their semantic operands are:

| Recorded command | Exact operands after command | PID | Native rc | Timeout / remaining owned group |
|---|---|---:|---:|---|
| `create-gbs` | `--gbs=G/ofs_pr_afu.green_region.gbs --afu-json=G/afu.json --rbf=G/persona.rbf --set-value interface-uuid:fc603c44-5c8f-5e94-bcbe-a5780030947c afu-image/clock-frequency-low:100 afu-image/clock-frequency-high:200` | 389692 | 0 | false / `[]` |
| `gbs-info` | `--gbs=G/ofs_pr_afu.green_region.gbs` | 389693 | 0 | false / `[]` |
| `get-rbf` | `--gbs=G/ofs_pr_afu.green_region.gbs --rbf=G/extracted.rbf` | 389694 | 0 | false / `[]` |

Create/extract logs name those outputs; info.log contains actual metadata. Captured **success=true**, completed postflight, **outer_rc=0**; no separate numeric effective_rc field is invented. Wrapper checks native zero/no timeout/drain/no ERROR or FATAL and bounds each command60s/log2MiB/address-space64GiB per process—not sandbox/aggregate isolation. [Index30:6–59,94,123](gbs30/index.json#L6), [create log](gbs30/readback/create.log), [extract log](gbs30/readback/extract.log), [wrapper:50–76](package27.py#L50)

Success requires **complete design inventory equality before/after** (file size/hash and symlink target/resolution/target-hash), unchanged source JSON/all16 tools/clocks/gen_gbs/assembly result/acceptance28. All four preservation flags are true; originals remain outside fresh G. Full inventory bytes were not exported: preservation is the reviewed executed predicate and captured outcome, not independent full-tree readback. [package27:16–29,81–95,107–109](package27.py#L16), [Index30:2–5,61,93–95](gbs30/index.json#L2)

## 4. Independent container and metadata/payload verification

Direct local parsing of the actual10101127-byte GBS establishes:

- Exact **16-byte** `XeonFPGA\xb7GBSv001`, hex **`58656f6e46504741b747425376303031`**. Bytes16–19 are **`73010000`**, unsigned little-endian serialized JSON length **371**, not the creation object's dictionary-key count. Metadata occupies `[20,391)`; payload begins at **20+371=391**, strictly within the file. This matches the writer/reader implementation above and [constants:27–36](../ahls-persona-work21-caps01/gbs-prerequisites01/usr/lib/python3.9/site-packages/packager/metadata/constants.py#L27).
- Strict metadata has no duplicate keys/nonstandard constants; serialized bytes equal default `json.dumps` of whole source JSON with **only** interface insertion, `auto-100`→integer100/`auto-200`→integer200 MHz and default magic **`0x1d1f8680`=488605312**. Entire metadata equals info.log/index30. AFU UUID, name `ia840f_ahls_memory`, class `ofs_plat_afu`, one context, version1/power0 are unchanged. [Source JSON](gbs30/readback/afu.json), [native info](gbs30/readback/info.log), [package27:100–104](package27.py#L100)
- Payload: **10100736 bytes**, **`9f7830bdf6f12cd2a1934dddaae26f7a231657e1764d3e9dc8c3e239f882964a`**, independently **byte-for-byte equal** to complete accepted local images25 PR-RBF. Runtime also asserts payload=original=persona.rbf=native extracted.rbf. Extracted.rbf is not separately exported; its equality is the captured predicate, corroborated by independent container/RBF comparison. [package27:105–109](package27.py#L105), [Index30:88–95](gbs30/index.json#L88)

## 5. Limits and actionable blockers

**Offline packaging/acquisition blockers: none.** Do not repeat assembly, afu_synth, packaging or predecessor timing work to obtain already verified artifacts. No new QUALITY/sandbox/vendor-internal/Boolean-equivalence/timing gate is imposed by this review.

**Later blockers/limits:** SDK flash/BMC/readback/reboot and live shell/image/operation binding; reset entry (additional3sys/7bank0 cycles), both-bank initialization/containment, four electrical dispositions; actual-card numerical/34case/DDR/walking-bit/bulk/data tests. STA setup+.002ns, zero hold/MPW, static signoff/DRC and narrow40-bundle/20-FIFO CDC findings remain unchanged/unwaived. [Assembly limits:193–200](result-review26.md#L193), [CDC acceptance73:16–24](../fim24-caps03-cdc03/CDC-ACCEPTANCE73.md#L16)

Raw **hardware_access/hardware_ready/deployment_ready/ready_for_build=false** remain false. Correct container is not runtime-PR permission, safe deployment or hardware correctness. **FINAL: PASS WITH LIMITS; no task closure.** [Index30:60–67,90–95](gbs30/index.json#L60)
