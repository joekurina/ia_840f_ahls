# Parent acceptance — bounded offline gates

## Disposition

**ACCEPTED for the separate offline gates below; hardware mission NOT COMPLETE.**
[Spec re-review02](spec-review02.md) returned PASS and the subsequent independent
[quality review01](quality-review01.md) returned APPROVED, with no critical or
important implementation defect. The parent read both reports, checked their
scope against source/receipts, and reverified the immutable input inventories.
This closes the review stage, not any live-operation authorization.

| Gate | Accepted result | Not accepted / still blocked |
|---|---|---|
| Selected source evidence | 116 selected W13 files match the build inventory; PF0 VF0 BAR0 source route and finite CSR contract established | Current live image/VF/BAR/clock/reset identity; complete native backend footprint |
| UART diagnosis | Disabled real UART is advertised by dummy DFHv0 feature 0x24; required driver metadata is absent; 12 inert regressions pass | No RTL/driver correction; explicit feature-scope decision unanswered |
| Staged udev successor02 | Snapshot-specific PF0 BDF and four PCI IDs on one parent; unrelated original fallback byte-preserved; 21 inert tests pass | Native parser/event behavior, required-node detection, installation/activation, actual permissions; no VFIO access grant |
| Additive host software | Exact numerical oracle, aligned finite accesses, clear-on-read completion and fail-closed application control; CTest 2/2; native compile/link evidence | Native binary never executed; no hardware numerical, DDR or transfer qualification |
| ELF identity supplement | Independent consistency review PASS for two installed/build pairs, code/rodata/build-ID equality and retained metadata differences | Not whole-file equality or full dependency/runtime safety closure; xfpga pre-filter access remains a blocker |

The original candidate01 is **rejected**, not an alternative activatable rule.
The successor02 missing-required-node check is an external fixture/acceptance
model; actual native detection is **UNVERIFIED**. DFL PF0 node permissions are
not the AHLS VF's VFIO permissions. See [first-review response](spec-response01.md).

## Immutable review binding

- [Input manifest01](spec-input-manifest01.json): 247 files, SHA256
  `7abbdfa2047b5b3e3d926334ae52152bbec3d2d2dc52ffc1d57de0e005c5f49d`.
- Spec re-review02 SHA256:
  `408a25d0fa723e45ea98da246aa28827408dc398ae0ca104eda594abd1911a94`.
- Quality review01 SHA256:
  `714a7189b0a85a3da6efd721ab93b829cd9bdc9d013f913e3b5e16dc8cbb5bd7`.
- [ELF supplement manifest](../opae-backend-binding-01/manifest01.json): seven
  members, SHA256 `ba2385177deb2833d5f47deb3779d21aae60645305d467589941d15c3a633242`.

Parent verification found zero size/hash mismatches in both inventories.
The reports bound by those manifests remain unchanged. Their earlier
“review pending” wording and source-resume report's candidate01 row describe
pre-review checkpoints and are superseded by **this acceptance record and each
subsystem's ACCEPTANCE.md**, not silently edited to imply earlier approval.

## Final parent recheck

[Final offline-check manifest](final-offline-check01/manifest.json) and its six
step receipts preserve a fresh local scratch build and test:

1. CMake Debug, `BUILD_OPAE_FRONTEND=OFF`, captured OPAE headers; configure PASS.
2. Native local C build with warning-as-error flags; build PASS.
3. `readelf -d` confirms mock frontend NEEDED contains **only libc.so.6** before
   fixture execution.
4. CTest **2/2 PASS**.
5. UART inert tests **12/12 PASS**.
6. Udev successor02 inert tests **21/21 PASS**.

All 247 bound files remained unchanged after the check. These are mock/model
results, not measured FPGA outcomes. The already compiled native OPAE binary
was not run. The parent performed no FPGA access or system-rule activation.

## Nonblocking quality follow-ups

Retain Q1/Q2 from quality review01 without claiming they are fixed:

- **Q1:** API-failure injection checks error exits and stopping work, but cleanup
  resource assertions are disabled on injected failures. Current frontend
  cleanup is source-reviewed; strengthen release-attempt assertions separately.
- **Q2:** Python frontend fixtures use `assert`, which can be removed under
  `PYTHONOPTIMIZE`. Retained nonoptimized results stand; harden the runner before
  relying on results from a differently configured Python environment.

Neither finding was classified as a release-blocking defect for this offline
milestone. Any later implementation change needs new test/review evidence;
these approvals must not be rebound to different bytes.

## Remaining mission gates

W13/persona timing remains unaccepted (W13 hold -0.004 ns; persona setup
-0.336 ns, hold -0.004 ns, pulse width -0.029 ns). No unchanged rebuild is
justified by these offline results. DDR simulation is **SKIPPED BY USER**.
Both-bank DDR data tests, host transfers, live AHLS numerical tests, runtime
PR, sustained operation and exact-image flash/power-cycle acceptance remain
NOT RUN/BLOCKED as recorded in the feature matrix.

UART implementation needs the explicit absent-versus-real-endpoint decision.
Live work additionally needs exact current binding/backend/clock-reset evidence,
a reviewed finite supported operation, applicable authorization and currently
verified independent host recovery. Host-local JTAG/BMC is not that recovery.
No acceptance here authorizes probing, retries, reset/rebind, programming,
udev activation or broad permission changes.
