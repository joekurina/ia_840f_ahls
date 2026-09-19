# Independent quality review: IA840F PCIe CSR clock correction

## Decision: PASS — local helper quality only

No blocking implementation finding. The correction is narrow, deterministic, and preserves the existing donor-override behavior except for the intended legacy-to-port-0 clock translation. This approval applies to the exact helper and test hashes below, not to vendor execution or physical clock qualification. **Readiness remains false.** Actual PLL output frequency remains unresolved.

Root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`; paths below are relative to it. Shared gate/wrapper reviews were deliberately not repeated. Only this report was written; no source, preset, manifest, authorization, historical work artifact, or claim was modified. No remote operation, vendor tool, or commit was performed. Python execution used `-B` to avoid bytecode writes.

## Reviewed identities

SHA256 values were computed locally from complete files after deterministic testing. The call-site file was inspected at lines 239–283; the other source/test and review documents were read in full. The derivation record was parsed to verify its preset hash rather than re-review its entire derivation.

| Path | SHA256 |
|---|---|
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/ia840f_vendor_pcie.py` | `8b89f1eba308d7b1de8a7a356604ded666e87a5b758a51337058f0fbf2204bc5` |
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/test_ia840f_pcie_csr_clock.py` | `aeadedc0a79cc5e578ac7e8493a2fd0436dd7d557ecc7c1b2e1e122729c72d61` |
| `ofs-agx7-pcie-attach/ipss/ia840f/presets/ia840f_pcie_known_schema.qprs` | `420f73c5c4bf1432ce39508f068bc381f4e4f2117a87a96940ca8500a93c876e` |
| `ofs-agx7-pcie-attach/ipss/ia840f/preset_derivation.json` | `e58e146ea0ec90e1a2528ddffdba2553339f4168dadda0b109574844c41d2d06` |
| `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config/pcie_ip.py` | `841e245d17d7db23338bf4d24d87a7b0e73b038ba45a620f3165277c03d0b239` |
| `qualification/ipgen-03/pcie-csr-clock-correction.md` | `d0fb920acd310d97c8d670461c092386dc16ae2a84a9ab6d53872d8d8c264d36` |
| `qualification/ipgen-03/pcie-csr-clock-spec-review.md` | `70c038a2b9003f159f3ed7130bbf48c44afb5e94b6f32f65157884b02f2d3b7e` |

Removing only helper lines 33–42 in memory yields SHA256 `cc03d11fb0a494667530ad9be1cdfcfb9fa05606cd3301a9340d292602072ab8`, matching the baseline identity reported by the independent specification review. No baseline or inventory file was rewritten.

## Quality findings

- **Parameter preservation:** helper lines 39–43 require donor string `100`, move precisely that donor value to `core16_axi_lite_clk_freq_user_hwtcl`, remove the effective legacy key, and perform the same existing donor dictionary update. Full-dictionary equality in the test verifies the old donor-override result with only that translation, including unrelated values, other-port clocks, IDs, PF/VF and BAR settings. PF1 BAR2 remains width `28`, type `64-bit prefetchable memory`. Existing donor overrides still intentionally override caller values; preservation is relative to that preexisting behavior, not arbitrary caller input.
- **Board boundary:** line 15 returns for anything other than exact `ia840f` before source access or gate import. The call site independently confines invocation to IA840F after normal PF/VF processing. There is no generic unknown-parameter translation or replication of the new clock field to another port.
- **Immutable preset before translation:** lines 24–31 read the source-tree donor, verify SHA256 against the derivation record, and validate the preset component before constructing/translating overrides. The source preset still contains the legacy `100` request. Its bytes and recorded digest matched after tests. Translation changes only in-memory dictionaries; there is no preset write path.
- **Existing rejection contracts:** non-preset `intel_pcie_ss_axi`, exactly two PFs, and `{'pf0': 1, 'pf1': 0}` remain required. Hash mismatch, bad/missing preset kind, and missing/non-100 donor clock fail before effective-parameter mutation or gate invocation. XML/JSON/file errors are not swallowed.
- **Exception propagation and ordering:** `pcie_context(pcie)` remains mandatory after the corrected dictionary is installed. The mocked gate sees the corrected value, and its denial propagates. A gate denial leaves the in-memory donor overrides applied, as the preexisting helper did; this helper is not transactional and callers must not suppress denial. No new catch, fallback, bypass, or successful return on denial was added.
- **Maintainability:** two explicit parameter-name constants and an exact donor contract check keep the change readable and board-specific. Repeated successful application is stable while still invoking the gate each time. No additional runtime dependency or vendor invocation was introduced.

## Independent execution

Read the helper and test module before execution. The test replaces the gate module in memory; the real gate and vendor toolchain were not imported or executed.

From `ofs-agx7-pcie-attach/ofs-common/tools/ofss_config`:

```sh
python3 -B -m unittest -v test_ia840f_pcie_csr_clock
```

Observed result: **7 tests passed**, exit status **0**:

```text
Ran 7 tests in 0.071s

OK
```

Assertions cover complete parameter delta and unchanged donor bytes/hash; gate ordering and denial; other boards; component/preset/PF/VF rejection; hash mismatch; synthetic hash-consistent missing/changed legacy request; and repeat stability.

An additional inline `python3 -B -c` probe, using only standard-library mocks and synthetic XML held in memory, also exited **0**:

```text
PASS strict board boundary: 3 additional values, both read APIs blocked
PASS hash-consistent wrong-kind, missing-preset, malformed-XML reject before mutation/gate
PASS absent caller legacy and stale port0 value corrected
```

The board probe tested `IA840F`, `ia840f-extra`, and `None` with both `Path.read_text` and `Path.read_bytes` configured to fail if called. Synthetic wrong-kind, missing-preset and malformed-XML fixtures each had a matching in-memory derivation hash; all rejected without caller-dictionary mutation or gate invocation. A positive fixture with no caller legacy key and stale port-0 `250` correctly produced string `100`. The probe finally reread the real preset, verified byte equality with its initial content, and checked its SHA256 against the real derivation record. These supplemental cases were not written into the source test file.

## Non-blocking observations and limits

The committed-to-disk test module does not separately exercise preset-kind/malformed-XML rejection or block both file-read APIs on the board boundary; the independent inline probes cover those cases for this review. Adding such persistent coverage later would be useful but is not required for this narrow correction.

The specification review's documentation note remains valid: the correction report calls the displayed setup command intact, while its displayed line ends in `[truncated]`. This quality decision does not infer parameter absence from that shortened excerpt and does not repeat the already completed evidence/specification review.

Parent must finish its separate final source inventory/rebinding before deployment; the old helper hash does not cover this correction. This report updates no authorization and does not change `ready` to true. Later separately authorized validation must establish the emitted/saved parent and child clock parameters and unchanged remaining PCIe contract. Actual PLL frequency/dividers, generated SDC, tolerance compliance, timing closure and hardware behavior remain unqualified. Mocked authorization is not real authorization, and local helper success is not vendor acceptance.
