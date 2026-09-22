# AHLS host correction — offline verified, native-linked, not run on FPGA

## Result

**OFFLINE PASS; native OPAE compile/link PASS; live FPGA Test NOT RUN/BLOCKED.**
The additive implementation is `src/host/ahls_qualification_core.[ch]` plus
`src/host/ahls_opae_qualification.c`. The historical `ahls_mmio_test.c` is
preserved unchanged and must not be used as the continuation test.

The [host access map](HOST-ACCESS-MAP.md) establishes the source path as PF0 VF0
BAR0 and distinguishes it from PF0's management/protocol-checker window.
The map does not claim the present card image, VF BDF or reset/clock state.

## Corrections grounded in generated source

- All accesses are aligned 64-bit operations at the finite documented offsets;
  there is no 64-bit access at 0x74 and no raw BAR or address-search mode.
- Exact UUID, accelerator type, BDF and PCI-ID filtering; every API failure and
  zero/multiple matches stops the workflow before MMIO. Property allocation,
  all setters, open/map and cleanup errors are checked.
- The generated finish register is a **two-bit clear-on-read counter**, not a
  monotonic 64-bit value. The test requires idle CSR v5, drains residual count,
  verifies zero, starts once and accepts exactly one fresh finish. It reads
  the result only after completion and an idle check.
- A monotonic software deadline and operation-count ceiling reject no-finish
  and stalled-clock fixtures; they do **not** guarantee containment of a real
  hung PCIe transaction. There is no reset or retry on failure.
- Exact reference is XOR of eight signed32 products `(a+i)*b` when mode==0,
  otherwise `(a-i)*b`, from the retained
  [AHLS source](../ahls-compile-01/src/qual_vec_op.cpp), lines 31–49. Reference arithmetic
  uses int64 intermediates and rejects inputs that would make the original
  signed32 kernel overflow. ResultPipe is a zero-padded 32-bit bit-pattern,
  and the complete 64-bit read must match.

Generated implementation evidence and line ranges are in the access map;
notably `IDQualVecOp_function_cra_agent.sv:435–471,526–546` resolves the
misleading duplicate finish-counter macro in the generated header.

## Executed offline checks

Native CMake project: `tests/ia840f/offline/CMakeLists.txt`, default live-frontend
option OFF. Local GCC 14.2 compiled with `-Wall -Wextra -Werror -pedantic`.
Assertions remain enabled for fixtures.

- [run-03-step-2.json](run-03-step-2.json): **CTest 2/2 PASS**.
- Core fixture: 12 exact numeric cases, including repeated input, both branches,
  negative arguments, zero and defined int32 boundaries. Fixed expected values
  were calculated independently with a Python integer oracle. **17 injected
  callback failures** stop at the failed operation. Additional checks cover
  UUID/DFH mismatch, stale/nonclearing or multiple completion, deadline failure,
  clock rollback/stall, high-half result corruption, invalid inputs and BDFs.
- [frontend-inert-results.json](frontend-inert-results.json): **160 process
  cases PASS**, including **151 injected API failures**, success, zero/multiple
  enumeration, wrong UUID, wrong result and four malformed BDFs. This compiles
  the real frontend against the captured installed OPAE headers and links only
  local mock functions—not libopae-c. Fixture “FPGA Test PASSED” messages are
  mocked outcomes and are not hardware evidence.
- The first test-fixture build failed `-Werror=misleading-indentation`; that
  failure is preserved in `run-01-step-1.json`. The one-line fixture formatting
  correction and passing subsequent runs are retained rather than erased.

## Executed native compile/link, no execution

[Exact commands/output](native-result01.json), tmux launch receipt
[native-launch01.json](native-launch01.json), and source payload/driver
[native_compile01.py](native_compile01.py). Remote GCC 11.5 configured and
compiled through native CMake, targeting only `ahls_opae_qualification`.
Both configure/build commands returned zero without compiler warnings.

Artifact:
`/home/uwb_student00/ahls/new_BSP/qualification/ahls-host-offline-01/native-compile-01/build/ahls_opae_qualification`

SHA256: `95ab4bcb856e68f1bc2b123024bea40b2731843352ccfff6c5cdffe2579aa0a8`.
The later ordinary-file readback in source-resume `batch06.json` independently
matches that hash. `readelf -d` lists `libopae-c.so.2` and libc as dependencies.
**The native binary was never executed**, including no --help/discovery trial.
Library loading/discovery itself may access hardware.

## Remaining acceptance

Independent review is required before the offline milestone is accepted.
Live usage remains blocked by current image/VF/backend/reset/clock identity,
separately reviewed finite authorization, and independent host recovery.
Timing is not accepted: W13's existing summary has -0.004 ns hold; the persona
has -0.336 ns setup, -0.004 ns hold, -0.029 ns minimum pulse width. See
[source-resume report](../source-resume-01/REPORT.md).

The current qualification component is CSR-only and ties host/local-memory
masters idle. These tests do not establish DDR integrity, host transfers,
runtime PR, sustained operation or durable boot. All remain NOT RUN/BLOCKED;
DDR simulation remains SKIPPED BY USER.
