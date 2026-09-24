# Strict OPAE initialization — own-code and inert SDK integration

Add an opt-in IA-840F initialization function beside unchanged original OPAE
functions. Do not alter the captured SDK, installed libraries, accepted binaries
or FPGA source. New entry must reject config read/parse/allocation failure and
nonexact tables before platform detection or plugin loading. No config discovery,
compiled-default fallback, initialization retry or silent success with no platform.
Require fresh explicit-init state and no WITH_ASE. Keep partial-backend failure
and hardware cleanup as unresolved limits, not automatic recovery.

TDD uses byte-bound actual SDK plugin manager and parser code, with explicit
local substitutes at config-read/discovery, directory/sysfs-file and dynamic
loader boundaries. They synthesize one PCI identity and an inert adapter; no
real directory walk, backend/library loading, API device call or hardware. Verify
fixture ELF before execution. Tests run locally, not on the workstation. Preserve
RED legacy behavior and GREEN evidence separately. No real strict-core/entry build
or deployment is accepted by this gate; no generic sandbox/security framework.
