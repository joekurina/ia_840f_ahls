# CAPS03 inert host frontend result

**46/46 inert cases passed; no hardware or real OPAE backend execution.** This is
host sequence/comparison/failure-retention evidence, not FPGA numerical or VFIO
lifecycle acceptance. [Machine result](green-cases01/result.json).
Independent review `deleg_88b749ca` gives bounded host-functional acceptance with
no blocking defect. It reconciled every case/log and ELF hash, the 29 post-start
API faults plus 13 semantic/data failures, preserved predecessor hashes and the
launcher-only token/description delta. The parent independently reverified all
46 case receipts, log hashes/sizes and the ELF. Native launcher/runtime and live
lifecycle qualification remain open; the inert model supplies arithmetic/visibility
and substitutes the lifetime hold.

Added `src/host/ahls_memory_caps03.c` alongside the original isolation frontend,
and `ahls_memory_caps03_startup.c` alongside its launcher. The former reuses the
unchanged DMA transfer core, raw-capability decoder, <=128-byte/page-contained
segmentation and production lifetime hold. The launcher differs only in its
operation token and description; it has not yet been compiled or exercised in the
actual target runtime. Original frontend, launcher and runtime sources remain.

The fixed nine mixed-sign inputs/reference and 192-byte DDR result/guard span
come from [the source-bound contract](../caps01-kernel-host01/HOST-CONTRACT01.md#6-candidate-only-nine-mixed-sign-integers-and-a-partial-vector).
Four upload descriptors establish both inputs and output guards. The required
sequence is HLS status at `0x10000`, the quiescent one-ticket read at `0x10030`,
then supported/error-free completion `0x10002` at `0x20028`, followed by 64+128-byte
copyback descriptors. The monitor requires the HLS-status observation; polling
only its completion CSR cannot complete. These fields/order are selected RTL:
[`ia840f_ahls_mmio_completion_guard.sv:72–95`](../../afu/ahls_memory/control/ia840f_ahls_mmio_completion_guard.sv)
and the simulation's status/finish/completion sequence in
[`ahls_memory_path_completion_tb.sv`](../caps03-completion01/ahls_memory_path_completion_tb.sv).

## Executed evidence

- The initial local build failed because the older installed-header capture lacked
  `opae/buffer.h`; [failure](setup-failure01.json) is retained. No functional result
  was inferred from it.
- Reused 34 public headers from the existing SDK capture, each matching the prior
  native isolation build's size/SHA256. No downloads, installs or vendor-source
  edits. [Bindings](header-binding02.json).
- **RED:** unchanged predecessor rejects the new option with rc2 before any OPAE
  API call. This is absent frontend functionality, not an RTL defect.
  [Exact commands/output](red02-result.json).
- **GREEN build:** real CMake/GCC with `-Wall -Wextra -Werror -UNDEBUG`, UBSan and
  non-recovering undefined-behavior checks. Configure/build rc0; no OPAE/VFIO/xfpga
  ELF dependency. [Build record](build-green01.json).
- **GREEN execution:** `python3 -I -B tests/ia840f/caps03_host/test_frontend.py
  qualification/caps03-host01/green01/caps03_frontend
  qualification/caps03-host01/green-cases01` returned0. Planned/executed/passed all46.
  Includes successful six-descriptor flow, every new post-start API failure,
  start/status errors, status/completion deadlines, bad ticket, unsupported/error/
  reset completion, absent host visibility, result/tail/guard/source corruption,
  and CLI rejection. The inert API model enforces ordering and ownership; it is
  not an FPGA timing or PCIe model.

## Lifecycle limit

Kernel uncertainty is recorded before the potentially effective start write and
survives later DMA report resets. Every tested post-start failure enters the
existing non-returning production hold path before release/unmap/close/finalize.
Inert substitution exits77 only to report the test result; it owns no device.

The candidate retains the predecessor's normal cleanup **only after** verified
completion, both copyback retirements and all numerical/DDR/host-page guards.
Those application observations do not independently establish global drain or
FLR safety. The exact live runtime/teardown operation must be admitted before any
hardware invocation; [the P-Tile erratum disposition](../caps01-dma-gib01/ERRATUM11.md)
remains separate and is not waived here. No native target build, deployment or
live execution is claimed. Final fitted timing/reset/CDC is still pending.
