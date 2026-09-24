# Strict core target01 — native compile/link result

**Native result passed; independent/parent acceptance pending.**

In the unchanged AHLS SIF, native CMake rebuilt only target `opae-c` using the
source-bound, read-only single-file pluginmgr overlay; then built the unchanged
launcher and sibling strict entry. Original SDK/accepted artifacts remain intact.
The overlay is the full original pluginmgr.c bytes followed by one include of
our strict addition. This is not an edit to the installed/original SDK.

Native/effective/outer0/0/0; all16 inner commands rc0;33 exported members verified.
No timeout/owned survivors. Archive SHA256
`044a42537526cfd59a3dc1496e04d44dda063269d895ea36e3a8d94edfa37121`.
[Scope](TARGET-SCOPE01.md), [receipt](outer-target01.json),
[parent check](target-parent-verification01.json).

The new core is592584bytes, SHA256
`78f625f66da37e32596507a36418fa3579945f2ecd06377b9659f68b9fd427b1`.
It supplies the private `ia840f_opae_initialize_strict` export. The new entry
requires that symbol and21 existing FPGA exports, not fpgaInitialize. It retains
the three bridge ABI exports. Linker -z defs and static ELF checks passed.
Artifact sizes/hashes and exact dependencies are retained in build-result.json.

All1177 original SDK source bindings, SIF/runtime, submitted sources and original
build inventory remain unchanged. Among66 copied prerequisite entries the only
observed change is the intended new core ELF; config.h is unchanged and every
other copied library/prefix input is preserved. No backend was rebuilt or loaded.
The actual mount record and overlay SHA bind the compiler's changed source view.

## Limits

No output was executed; no real initialization, driver/OPAE, MMIO, DDR/DMA,
numerical AHLS, lifecycle/full-signoff or boot acceptance. The39-case inert gate
is separately reviewed. Strict behavior only exists in the opt-in new API/entry;
legacy functions and their fallback remain unchanged. Partial-init cleanup and
loader prefix searches remain unqualified. Preserve native optional-dependency/
unused-option messages and SDK/core build-context RUNPATH findings; do not call
this warning-free or installation-ready. Source guards and per-process resource
limits are not an OS or aggregate-memory sandbox. Vendor DDR simulation remains
SKIPPED BY USER.
