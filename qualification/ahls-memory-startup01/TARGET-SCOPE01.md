# Target01 scope — AHLS SIF compile/link only

Compile the unchanged explicit-startup launcher and entry bridge, original
memory frontend/core/header/decoder, against the previously built OPAE 2.13
core and the actual SDK headers in the unchanged AHLS SIF. Native CMake builds
only the two application targets; it does not configure/rebuild/install SDK
or FPGA sources. No install, ldconfig, tests, frontend --help, ldd, OPAE library
loading or device access. Static readelf/nm inspections only.

Use a fresh exclusive target01 root and owned tmux. Bind the SIF, runtime
wrapper/ELF, accepted predecessor archive, 1,177 SDK source entries, package
prefix and prebuilt libraries. Copy the accepted library/include/prefix files;
verify originals and copies unchanged afterward. Preserve the six maintained
source files byte-for-byte. CMakeLists is an additive target recipe; no stub
symbols are linked. Target flags O2/Wall/Wextra/Werror/UNDEBUG, no UBSan unlike
the inert regression. Do not claim functional equivalence from this build.

Use all allowed CPUs, 64GiB per-process address-space limit, finite outer600s
and inner240s command deadlines, >80GB available RAM and >10GB disk free;
reject competing native builds. Source-bound supervision is not an OS sandbox.
Containall/cleanenv/no-home/no-host-sys/default-bind isolation uses only owned
scratch and read-only SDK. Record actual mount/device visibility.

Require both binaries, entry ABI exports and all referenced OPAE exports.
Launcher direct dependencies must be JSON-C/libc only, entry libopae-c/libc;
verify their explicit nonempty RUNPATHs. This fixes no inherited SDK RUNPATH,
real runtime fallback, loader namespace, transitive identity or hardware gate.
No produced executable/shared object will be invoked. Independent result review
is required before bounded acceptance/publication.
