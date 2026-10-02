# Work24 — execution-QUALITY review04

**APPROVED for one bounded offline CLOCK_SPINE2 compile, after parent consumption and the live conditions below. No implementation change is required.** This review issues no manifest/runtime authority and grants no timing or hardware acceptance.

Reviewer: **GPT-6 (`gpt-6-astra-900k`) / `openai-codex`**, replacing unavailable GLM5.3. Independent local read-only inspection and in-memory hashing/comparison only; no project/test-script execution, SSH, native/vendor tools, Git or hardware. Only this report is written.

Paths below are relative to `qualification/fim-build-24`. Remote E=`/home/uwb_student00/ahls/new_BSP/qualification/fim-build-24`; WORK is its sibling-root `work_ia840f_fim_24` under `new_BSP`.

## Findings

1. **Frozen execution package verified:** all **39/39** sizes/SHA256s in `quality-freeze04.json` match; all earlier **32/32** bindings remain unchanged. SPEC PASS and `spec-consumed03.json` bind the same draft. Byte comparisons against `../fim-build-23` show only WORK/evidence-root retargeting in gate/runner; CMake, Tcl and top.sdc are identical. All **135 unique contexts**, **12 runtime hashes**, affinity **0–35**, nine links and runtime-output roles reconcile. The draft retains 3,393 critical and 566 preflight-only inputs, with disjoint maps and exact role coverage; inherited acceptance requirements remain, with two experiment-specific additions.

2. **Existing execution controls remain adequate:** `candidate01/CMakeLists.txt:38–42` directly invokes `quartus_sh --flow compile ofs_top -c ofs_top`, without dependencies on the separate regeneration/header targets. `candidate02/run-compile30.py:64–150` enforces compile-only admission, hashes/resources, exclusive operation/lock and readiness false. `candidate01/ia840f_migration_gate.py:35–78` checks exact native executable/argv/cwd/hash and live supervisor ancestry/PID-start identity. The reused supervisor protects post-spawn bookkeeping, retains the unreaped leader through group signaling, drains descendants and rejects late gate/125091 markers (`run-compile30.py:153–212,249–268`). Budgets remain 10,800s compile and 120s configure, with cleanup separate; 64GiB address space is **per process, not aggregate**. Raw CMake status precedes postflight; nonzero vendor status is not recoverable numerically from CMake alone. These are trusted-account guards, not an OS sandbox.

3. **Admission changes are narrow and beneficial:** `admit04.py:22–29,36–50` binds the draft, actual four review files, parent QUALITY consumption and admission-script bytes, permitting only approval false→true, four added prerequisites, authority basis and validation scope. Lines **71–81 now pin both preservation-inventory digests before parsing/iteration**, plus cardinalities 1,891 SOURCE/PIM and 3,963 Work23 entries; the previous caller-only SOURCE/PIM binding is no longer needed to supply missing enforcement. Lines 82–90 exclusively publish; partial publication remains failed/consumed, never a retry invitation.

4. **Evidence scope is correctly limited:** current-byte receipts reconcile 16 synthetic-identity gate cases, three CMake outcomes, eight actual-entry runner cases with mocked admission/CMake and inert children, and 19 AST-extracted `validate_delta` cases. The latter do **not** prove full admission, new inventory-pin execution or native integration (`test-admission04.py:12–23`; `admission-delta-tests04.json:2–8`). Prepared missing-authority/manifest rejections are retained. No tests were rerun here.

## Mandatory parent live conditions

- Consume this actual report and pinned SPEC; create real `quality-consumed05.json` binding their hashes, draft and exact admission script. Publish `E/admit04.py` once, verify its bytes and complete payload hash, then invoke **`python3 -I -B` with `PYTHONOPTIMIZE` unset**, no `-O`. Use the same unoptimized discipline for the separate runner.
- Immediately revalidate `Agilex7Workstation`, UID1000, executing pane's owned session `ia840f_mailbox_monitored_01`, affinity0–35/QSF36, `MemAvailable >80,000,000,000` bytes, disk free `>20,000,000,000` bytes, all three license variables, and no competing native operation. Require absence/non-symlink status of E's `admission04`, `operations`, `stage-inputs`, `native-operation.lock` and four destination review files before admission (`admit04.py:32–81`). Rehash every input/tool/prerequisite, verify links/containment and both pinned preservation inventories against live files. Historical receipts are not current observations.
- **Preservation supplement:** freshly compare Work23's four image/intermediate artifacts and static QDB against `prepare01-inputs.json.gz` fields `images23`/`static_qdb23` (`prepare01.py:64–66`). Admission does not repeat those artifact checks. Leave Work21/22/23 and SOURCE/PIM untouched; repeat SOURCE/PIM, Work23-input and artifact preservation checks after completion.
- Require successful admission, then read back all four published review files and `E/stage-inputs/compile.json`; verify exact bytes, manifest hash, identical top-level key set and only the four approved changes. Only then launch the reviewed runner with that hash. Retain actual native PID/start ticks/executable/hash/argv/cwd/ancestry and completion evidence. Unexpected context, rejection, timeout, partial publication or unknown termination stops progression: preserve evidence, do not rebind or auto-retry.

## Exact SHA256 bindings

| Artifact | SHA256 |
|---|---|
| `quality-freeze04.json` | `0b2f7041a1a5a06b2674bf1d491e5f19db4674a0656f631f9bd08e5d5faf8844` |
| `review-spec02.md` | `272cd79af59bb96cfb235de54c349aa036d5ed826c43b5c1d6f381e8c9dd9ca6` |
| `prepared01-readback/compile-inputs.draft01.json` | `819d316d366af66cae04fa1295022c2c308299fa0fc9b6ec947d3ad48c296546` |
| `admit04.py` | `564093c3435adb01373fdc7da77d9e79a363d91ae3460405f031d1231c414d2d` |
| `prepared01-readback/original-source-pim-inventory01.json` | `ceb6ceb87937831e78451bafaf64425effbc7a5189b41ddbd2050a2c86009ed9` |
| `../fim-build-23/completion24-readback/qualification/fim-build-23/completion24/successor-input-inventory.json` | `839222cb201dc6bfa10275c7bc244ac6a2a59a7e6bac393ed0a7f06c3634635f` |
| `prepare01-inputs.json.gz` | `75cf305ff7a7fca915c3f6154aeddffb9883f132e82fb15944920197df1669e0` |

**Not granted:** native spine2 consumption, full `SX0 SY0 SX6 SY7` region/root ownership, no ignored/illegal assignment, both CPA COMP roles, exact bit243 all-five-corner signoff and collateral PCIe/DDR/PR qualification remain empirical obligations (`ITERATION-BASIS01.md:35–41`; `candidate01/ofs_top.qsf:141–143`). Preserve seed3, clocks/interfaces, EMIF3ns and signoff constraints. PCIe spine2 overlap remains a real risk. Full CPA-equation reconstruction/vendor help are not pre-fit prerequisites; native zero is not timing acceptance, deployment authority or permission for an index sweep.
