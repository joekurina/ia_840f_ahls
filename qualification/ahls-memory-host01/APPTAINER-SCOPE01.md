# AHLS Apptainer compile/link and backend-build scope

Review the completed `apptainer-build10` and `apptainer-backends11` acquisitions as one target-environment compile/link evidence gate, specification first and then acquisition/quality. This gate is distinct from workstation-native linking and inert frontend tests. It does not request another build or hardware execution.

The unchanged, hash-bound Ubuntu 22.04 AHLS SIF lacked OPAE in the inspected installation roots and lacked uuid/json-c development files. The bounded remedy was signed Ubuntu dependencies unpacked into user-owned scratch, then the existing OPAE SDK bound read-only and compiled inside that same SIF. No workstation-distribution library injection, SIF mutation, system install, SDK source edit, or FPGA rebuild was part of the remedy. This is a plain-C host frontend build inside the AHLS image, not an invocation of the AHLS hardware compiler.

Acceptance requires actual successful native/effective/outer receipts, signed dependency provenance, exact frontend bytes, captured SDK/source and original-tree preservation, target compiler/link logs, static ELF identities/dependencies and observed owned-child termination. Retain configuration omissions/warnings and acquisition limitations rather than claiming a complete runtime stack, exhaustive toolchain closure, generic sandbox, reproducible bitwise build, or every error branch tested.

The frontend must remain unexecuted. OPAE/backend libraries must not be dynamically loaded for inspection. Do not run ldd, help, device discovery, tests, installation, driver actions, or hardware operations. Build10's core-library link is separate from backends11's named `opae-v` and `xfpga` targets and required library dependencies. Backend compilation is not backend-selection/initialization safety.

The reviewed publication is metadata/evidence only. Raw archives, embedded-payload launchers, package payloads and binaries stay local with size/SHA references. Vendor DDR simulation remains SKIPPED BY USER. Hardware/boot qualification and full-design closure are not accepted.
