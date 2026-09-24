# Target01 — AHLS-image startup compile/link result

**Native build passed; independent/parent acceptance pending.**

The fresh target01 run used the unchanged Ubuntu AHLS SIF and existing accepted
OPAE2.13 SDK/core artifacts. Native/effective/outer status **0/0/0**, all13 inner
commands rc0, no timeout or owned survivors. Six maintained application files
were byte-preserved; only the additive target CMake recipe controls this build.
No SDK/FIM rebuild, installation, backend loading or application execution.
[Scope](TARGET-SCOPE01.md), [dispatch](dispatch-target01.json),
[outer receipt](outer-target01.json), [parent check](target-parent-verification01.json).

## Actual static outputs

| Artifact | Bytes | SHA256 |
|---|---:|---|
| ahls_memory_startup | 36592 | 14e33130d072b0007874effce3e78133962d48d711e283ef45e9ddce09329ee6 |
| libahls_memory_entry.so | 26128 | ea31d2b187a57263cf6569a81ff23df6777415d31ac191bff066a023b27eb1e5 |

Both output modes were set to0600. Launcher direct NEEDED entries are
`libjson-c.so.5`, `libc.so.6`; entry direct NEEDED entries are
`libopae-c.so.2`, `libc.so.6`. Static dynsym confirms the three bridge exports
and22 referenced OPAE exports in the prebuilt core. Linker `-z defs` was active.
The launcher does not link an OPAE initializer/plugin manager/backend.

Explicit RUNPATHs on these **new outputs only** contain no empty elements:
- Launcher: `/work/prefix/usr/lib/x86_64-linux-gnu`.
- Entry: `/work/sdk-build/lib:/work/prefix/usr/lib/x86_64-linux-gnu`.

The prebuilt SDK libraries were not relinked: their inherited trailing-colon
RUNPATH findings remain. These are build-context paths, not an installed runtime
or an attested loader namespace. Do not load either output as a test, even for help.

The native recipe uses O2/Wall/Wextra/Werror/UNDEBUG without inert-test UBSan.
Compiler/tool identities, command lines, maps and ELF diagnostics are captured.
The CMake unused FETCHCONTENT_FULLY_DISCONNECTED option is retained; this custom
recipe has no fetch/download/install commands. Do not call this warning-free.

## Preservation, isolation and limits

All1177 bound SDK entries, accepted original build inventory, copied prerequisite
files, SIF/runtime identities and seven submitted inputs remained unchanged.
The run used all36 allowed CPUs and64GiB per-process address-space limits with
resource preflight and finite command/group supervision. All13 inner commands
are compiler/version/link/static-inspection calls; resulting entry/launcher are
not invoked. Minimal `/dev` and absent sysfs mount were captured, not inferred
from flags alone. Normal-account source guards are not a generic sandbox.

This is target-environment compatibility, not mapped/runtime equivalence,
transitive dependency attestation, real OPAE initialization/finalization or
no-hang hardware approval. Startup review's real `opae_parse_libopae_config`
fallback/partial-init limitations remain: a sealed input does not eliminate
later read/allocation/parser failure. No DFL/OPAE discovery, MMIO, DDR/DMA,
AHLS numerical hardware, lifecycle, full-signoff or flash boot acceptance.
Vendor DDR simulation remains SKIPPED BY USER.
