# Parent acceptance — workstation-native memory frontend

**ACCEPT: intermediate compile/link and static ELF evidence only.**

The parent read the complete FINAL [independent review](native-independent-review01.md), specification PASS followed by acquisition/quality PASS, and independently verified all 68 frozen members (1,671,771 bytes), zero mismatches. Report SHA256 `17acbb7063d2061389640b76740c8648b27119ed11531200e3ef78e96df0685e`; package SHA256 `4bc44d9db66d966bd13cb24cfd7b5cee98e7436cfde98840affe520ff6b4a3e8`. The checks are recorded in [native-parent-review-verification01.json](native-parent-review-verification01.json).

The accepted [native result](NATIVE-RESULTS01.md) retains seven native/effective 0/0 commands, outer 0, successful source/tool/header/library preservation, and no timeout or surviving owned process group. The 40,424-byte ELF has SHA256 `a68f2e2a8b374db28fd90cffde002c4c20a9c900ef00a855592b331b396b7dd8`. It was not executed, including for help. This is the unchanged frontend already covered by [inert unit acceptance](UNIT-ACCEPTANCE.md); those tests were not rerun.

## Retained limitations

- The observed direct dependencies are `libopae-c.so.2` and `libc.so.6`; no executable RPATH/RUNPATH. Link-time identity is not loaded-runtime selection.
- Twenty direct OPAE imports match the application source. Absence of a direct write/reset/DMA import does not imply process-wide harmlessness. Retained shared-core scalar helpers are not called by this frontend; callback-based code remains in the executable.
- Compiler subprograms, startup objects, system headers, loader and transitive dependencies are not comprehensively bound. The source-bound runner is not an OS sandbox or syscall audit.
- AHLS-container build acceptance, backend initialization/enumeration/open/close effects, live image/BDF/PF/VF/BAR/clock-reset identity, independent recovery, hardware DDR/DMA/numerical operation, lifecycle and durable boot remain separate. This document does not accept them or authorize hardware access.

No blocking discrepancy or required unchanged rerun was found. Original receipts and reviewed evidence are preserved.
