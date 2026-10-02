# Migrated CAPS03 mapped synthesis — accepted with findings

**Accepted:** the one completed26.1.1 mapped-synthesis operation, current AFU/PIM source integration and recorded preservation. Both independent [result32](native-result-review32.md) and [diagnostic/PR/DRC33](diagnostic-pr-review33.md) reviews are consumed after rehashing all208 frozen members. [Consumption35](result-reviews-consumed35.json).

This permits offline first-fit preparation using the existing mapped result. It does **not** issue fit/STA/assembly authority, accept a physical persona, waive diagnostics, qualify hardware or complete the migration. The original completed synthesis and all spent claims remain untouched; do not resynthesize unchanged logic.

## Accepted evidence

- Configure/version/synthesis CMake/effective statuses, native version/synthesis and outer/wait/readback statuses are zero; `execution_clean=true`, no postflight errors or owned live groups. Actual installed native executable/argv/cwd/hash and accepted owner/ancestor callback were witnessed. Runner interval339.418181s. [Result30](RESULT30.md), [verification30](native-result-verification30.json).
- All ten capture-time preservation checks pass; QPF is byte-identical.51 complete captures/82,995,026bytes and608 mapped-QDB hashes/145,218,549bytes are bound. Native database bodies remain remote. [Index26](completion-index26.json).
- All16 selected SV and two QIP bodies are present in the1933-row native source table. The completion-enabled publication core, reset joins, completion guard, DMA/fabric and distinct bank shims remain mapped. FME interface `fc603c44-5c8f-5e94-bcbe-a5780030947c` and AFU `d48dde9f-f551-578d-8bb0-69483ac95ec6` match the selected configuration/header. [Review32](native-result-review32.md), [ledger29](native-source-ledger29.json).

## Findings carried into physical qualification

**Critical20580:** current QSF explicitly selects PR_IMPL, green partition and root QDB import; native synthesis resolves green as Reconfigurable. No evidence that PR was removed and no source change is justified by this warning alone. Physical root/import/partition preservation must still be proved by the actual fit; blank synthesis Preservation cells do not provide that proof.

**Critical19854:**73 reported power-up rows, not73 individual bits; all Low and not derived from assignments. Keep initial values and evaluate the actual fitted reset/entry contract later. Safe-FSM synthesis messages do not establish reset, PCIe progress or active-transaction recovery.

**DRC:** five of13 synthesized rules fail,15 violations,zero waived; elaborated is0/10. Seven rules were disabled. Retain divider reset, MSI-X polarity, mixed reset/enable distribution and duplication limitations. Application joined-reset loads1356CLRN/1512SCLR/513ENA are real application findings. TMC-20500 reports hierarchy depth7/implementedchain6, not requesteddepth7. Require actual clock/timing, recovery/removal, reset-sequence and electrical disposition; no blanket waiver. [Review33:15–41](diagnostic-pr-review33.md).

The native footer0errors/56warnings and275 console severity occurrences have different scopes. Application CSR/DMA width diagnostics and undriven/constant-port findings remain recorded. Protected/removed/inverted tables truncate at100/5000/100. Source collateral has126 available native-MD5 matches,22 blank/unavailable comparisons and8 unavailable DNI bodies; no nonempty-MD5 mismatch, but no retroactive pre-run binding. Ledger29 corrects the earlier local parser without changing raw evidence or repeating native work.

The prior unit simulation still excludes full PCIe mapper/shell, bank0 crossing reads, native BREADY-backpressure holds and stopped-clock/active-reset recovery. Mapped structure does not close those gaps. [Unit acceptance37](../fim24-caps03-simulation01/SIMULATION-ACCEPTANCE37.md).

## Next gate

Prepare a fresh copy from the [3894-entry completed workspace snapshot](physical-copy-basis34.json), preserve the current synthesis/static inputs, and derive exact current-version immutable/runtime-output roles rather than reusing the old exclusion list. Capture the installed fitter/STA API, bind every actual executable context, keep unchanged sources/constraints/settings and resource policy, and obtain fresh execution review/admission. Fit, subsequent multicorner STA, assembly/images, deployment and every migrated real-card gate remain open. [Preparation basis34](PHYSICAL-PREPARATION34.md).
