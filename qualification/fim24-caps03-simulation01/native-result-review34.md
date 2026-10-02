# Independent actual native-result review34

**Verdict: ACCEPT WITH FINDINGS** for the retained integrated-memory/page-split unit result. No behavioral, identity or preservation blocker was found. This does not waive diagnostics; independent warning-disposition review35 remains separate, and no hardware acceptance is granted.

**Reviewer:** GPT-6 (`gpt-6-astra-900k`), provider `openai-codex`, substituting for unavailable GLM5.3. Local read-only evidence analysis and in-memory hash/counter checks only; no project-script import/execution, tests, native tools, remote access, Git, hardware or implementation changes. Only this report is authored. Paths are relative to this qualification directory.

## Frozen identity and actual execution

Independently verified **669/669** unique members in `actual-result-freeze33.json`, every declared size and SHA256, with zero missing/mismatched members. Freeze SHA256:
`b5b51108e7ff8df145fed30a1bae2d21a0c5125ee67b2783fa4cba6bf795f48e`.

All **560 prepared inputs / 15,337,338 bytes** match selection10, prepared-inputs10 and admission27. The **458 unique compile entries** reconcile as 178 current-release/PIM, 12 Work24 supplements, 18 unchanged AFU/test and 250 generated entries. Actual vlog arguments/order and both vsim command vectors match corrected candidate23 CMake; candidate/staged runner and CMake hashes match admission. The invoked postflight uses `scoreboards_exact`, not its retained substring predecessor. SPEC14→consumption19→continuity25 and QUALITY26→consumption27 bindings verify; no unchanged vendor requalification is asserted.

Admitted SHA256:
`c68c0b4df38710e8c323dbc6cb46abad0c012ff3b1fa704f556c9c9ef1c4b765`.

Native result SHA256:
`bc40d5d35e87b25ab56c589ba4b87632f75cc9ac0a7fdc8e62e87e00ea8edbe3`.

The current **26.1.1-generated fabric** ran under unchanged **Questa Intel FPGA Edition 2024.3**, not a 26.1.1 simulator. Matching native Work24/PIM header UUID is `d48dde9f-f551-578d-8bb0-69483ac95ec6`; static interface UUID remains `fc603c44-5c8f-5e94-bcbe-a5780030947c`. The installed INI and `altera_mf_ver`→`altera_lnsim_ver` order are retained; no suppression/model patch appears in the bound commands.

The single `@264/%264` operation ran **2026-10-02T09:54:45.239760Z–09:54:59.420814Z**. Configure and six serial direct targets (`version`, `vlib`, `vdir`, `vlog`, `vsim`, `split_fault`) have CMake/effective zero. Native zero is propagated through the six direct targets; configure has no native status. Unique waiter `proc_01c9ea8a7c3b` records event-wait/readback/outer zero. `complete`, `execution_clean`, and `unit_pass` are true. This is completed execution, not replay or mere dispatch success. [Result](completion28-readback/operation/result.json), [dispatch](native22-dispatch.json), [event](native22-completion-event.json).

## Exact behavior and exercised coverage

Independent full-line parsing across all seven raw logs finds **exactly one occurrence of each family**, in its required log, agreeing with the corrected runner and verification29:

```text
AHLS_PATH_UNIT_PASS cases=6 elements=133 copied_bytes=1600 dma=30 checks=402461 mmio_reads=1010 mmio_writes=161 bank0_W=40 bank1_W=56
BANK1_RESET_INVALIDATION_PASS checks=1
PAGE_SPLIT_ERROR_PASS native_AW=2 native_W=4 native_B=2 upstream_B=1 observed_split_errors=1
```

No malformed/wrong-location duplicate, Error/Fatal diagnostic, nonzero Errors summary, record error or postflight error was found. All embedded native logs match captured bytes. Native zero alone was not accepted.

Bound testbench/model inspection and actual `vsim.log` establish:

- Six numerical cases, lengths **1,8,17,65,9,33**, total 133 integers; alternating 0/32-byte offsets; complete copyback/guard comparisons total 1600 bytes. Thirty DMA retirements reconcile as four per successful case plus three per negative case.
- Actual MMIO programming/polling, HLS-source request/data/mask credit, full-width endpoint address/byte/WLAST/stall checks, and six response-retirement certificates. Synthetic host/bank memories are serial deterministic models, not DDR/PCIe models.
- HLS read/write observations **24/32**, early finishes **8**, publication snapshots **412**, final-W stalls **150/382**, bank AR stalls **47/23**. Delayed responses exercise finish-before-retirement, not just arithmetic completion.
- Page-crossing inputs **AW0=8, AW1=8, AR0=0, AR1=6**. Bank0 crossing-read coverage is absent; both bank B-hold counters are **0**, so do not claim native BREADY-backpressure coverage.
- Both negative challenges pass: native B error and premature DMA-GO rejection, with no premature bank1 read/success publication. Both integrated `split_errors` counters are **0**; intermediate NO_REPLY-error coverage comes specifically from the separate split test, which checks two native segments, retained error/busy state and no success. It is not an HLS numerical test.
- One bank1-only reset invalidates an already completed result and releases idle. Negative-fixture drain/reset is not active-reset or stopped-clock recovery qualification.

Sources: `prepared-sources10/tests/{ahls_memory_path_tb,axi_memory_model,page_split_fault_tb}.sv`; native `vsim.log:1079,1181,1281–1285`, `split_fault.log:58`.

## Preservation and retained findings

All **seven domains** pass: staged inputs, run inputs, originals, simulator tools/libraries, runtime tools, controls, setup result. Capture28 freshly checked **560 run/staged inputs, 542 originals, 19 simulator bindings, three runtime tools**. Independently verified its compressed-envelope binding and all **11** decoded native/configuration captures. Its **52 work-library entries** reconcile with inventory28; these are inventories, not locally captured library bodies. Empty operation-root/runner process matches are not exhaustive host/device proof. No live short-helper executable witness is claimed.

Warnings remain **38/269/0** versus prior **36/261/0**. Recounted IDs confirm two new `vlog-2275` duplicate definitions and eight new `vopt-2241` scalar-input width messages; remaining ID/count groups match, not necessarily semantic contexts. Independently checked both duplicate module pairs byte-identical. The two alignment instances drive four scalar inputs with `'h0`, with `INCREMENT_ADDRESS=0`; hash-bound same-installation plaintext declarations corroborate scalar widths. These support bounded triage, not blanket waiver; retain `warning-context30.json`, comparison31 and library-source31 for review35.

**Minor evidence finding:** verification29's three native-summary line numbers are one too high; actual vlog/vsim/split summary lines are **868/1289/62**. Text/counts and outcome agree; frozen evidence was not edited.

Retained duplicate-selector overreach and library-collector `success`-key mismatch are evidence-acquisition faults, not native failures; the latter recovered the completed unique hashed buffer without retry. No evidence was overwritten.

Excluded: full PCIe mapper/AFUtop/pr_slot, physical DDR, timing/hardware, stopped-clock/active-reset recovery, bank0 read-error telemetry, and the future Quartus legacy-addenda compatibility link. The explicit-list simulation does not qualify that QSF adaptation.
