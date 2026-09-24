# Explicit startup candidate — inert integration results

**Completed own-logic tests; independent/parent acceptance pending.**

Two additive files, `src/host/ahls_memory_startup.c` and `ahls_memory_entry.c`,
provide a no-libopae-c launcher and an explicitly initialized shared entry.
The existing memory/scalar/core sources are unchanged. The memory frontend is
compiled into the entry with only its main symbol renamed, not rewritten.
[Source hashes and parent reduction](parent-results01.json), [commands](commands01.json).

## Implementation and measured tests

The launcher checks the exact CLI and existing strict BDF parser, reads a
regular configuration, invokes the actual SDK parser without its compiled-default
fallback, and requires the exact two-row DFL table. It makes a sealed memfd copy
of those validated bytes, sets OPAE_EXPLICIT_INITIALIZE and LIBOPAE_CFGFILE,
removes WITH_ASE/log overrides, and only then dlopens the separate entry.
The bridge initializes once, runs the unchanged frontend, then finalizes once
after successful initialization. Initialization failure makes no app call or
retry. Module residency is retained until process exit; this is not a forced
unload, cancellation, recovery or resource-lifetime proof.

- RED: a direct-linked **inert** constructor ran before the old frontend rejected
  --help. The result is preserved in `red-result01.json`; it models the observed
  SDK pre-main constructor shape, not execution of the real library.
- An initial ordinary-file rejection bug blocked on a local FIFO before fstat.
  The one-second subprocess timeout killed and waited for that owned local test.
  `fifo-red01.json` and `startup-candidate01.c` preserve it. The correction opens
  O_PATH first, checks regular type/size, then reads the held inode through its
  own /proc/self/fd path; the corrected FIFO test returns2 without a constructor.
- GREEN02: GCC14.2 O2, Wall/Wextra/Werror, UNDEBUG and UBSan; **525 inert processes
  passed**. Categories:25 API faults,448 bit mutations,12 invalid argument sets,
  28 configuration/file-type rejections,12 other startup/enumeration/module cases.
  See `matrix01/results.json` and `startup-matrix01.log`.
- The positive path records constructor(explicit=1,ase=0,logfile=0) → explicit
  initialize → exactly the existing25-call/7-read frontend sequence → finalize.
  Invalid CLI/configuration has no entry constructor. Init failure has no API
  call/finalization. Fini failure returns1. No retries occur.
- The fixture verifies all four memfd seals and the shared module's explicit
  config path/environment. A constructor mutates only its own copied input
  file; initialization still reads the previously validated sealed bytes.
- Missing module, invalid ELF and missing-entry-symbol cases remain distinct.
  A module with missing symbols can execute its constructor after validation
  but receives no explicit initialize call; ABI checks are not pre-dlopen
  attestation of arbitrary module content.

Before execution, readelf established the launcher's direct dependencies as
JSON-C/UBSan/libc only; both shared fixtures depend on UBSan/libc only. The actual
OPAE library/backends were never linked into or loaded by these fixtures. The
fixture uses local SDK parser sources bound in the predecessor config gate,
the captured OPAE headers and the unchanged inert API implementation.

## Retained limits

This is a Linux startup-ordering candidate, not a deployed or hardware-qualified
application. The new bridge has not yet received compile/link validation against
the real AHLS-image libraries. The actual runtime/constructor/plugin behavior is
source-derived, not dynamically exercised. The tested module is deliberately
inert and may not substitute for driver/backend testing.

The launcher does not cryptographically bind module bytes/dependencies, control
ambient ELF preloads or make arbitrary paths/filesystems safe. Their trusted
identity and namespace must be established by the eventual finite procedure.
Regular-file checks are not proof a pseudo-filesystem file is harmless. Config
acceptance is exact parsed table equality, not canonical-byte or full unknown-key
schema validation. BDF syntax and ID tuples are not process-wide device isolation.

The current scratch OPAE libraries retain build-context RUNPATHs including empty
path elements. Do not load them as a shortcut. Real initialization failure may
leave partial state; returning/exiting is not proven hardware cancellation or
recovery. Finalization, close, clocks/reset, IOMMU and buffer-lifetime effects
still require source/live qualification under the hardware gates.

No prior source/config/build was reverted, no installation or FPGA rebuild was
performed, and no real application/backend/device operation occurred. The overall
goal remains incomplete; vendor DDR simulation remains SKIPPED BY USER.
