# CAPS03 native AHLS host build

**Compile/link gate passed; hardware execution remains unqualified.**
The existing AHLS Ubuntu SIF built the additive CAPS03 startup launcher and strict
entry module without rebuilding or changing the accepted OPAE libraries. Native
container/configure/build/static-inspection and outer exits were zero. The run
ended at 01:16:39 UTC on 2026-09-26. [Result](native-build01-result.json),
[input bindings and exact CMake delta](native-build01-inputs.json),
[dispatch](dispatch-native-build01.json).

## Executed scope

- CMake-native Release build with GCC 11.4.0. All 11 recorded translation units
  used `-Werror` and `-UNDEBUG`; no compiler warning/error diagnostics were emitted.
  [Actual commands](native-build01-capture/build/compile_commands.json),
  [build log](native-build01-capture/build.log).
- Fourteen staged source/build files, including ten unchanged helper files.
  The original isolation frontend/launcher were preserved. The 64 bound SDK inputs,
  existing runtime binaries, SIF and local Apptainer installation remained unchanged.
  [Bindings](native-build01-inputs.json), [preservation result](native-build01-result.json).
- The compile-only container used read-only runtime/SDK/empty-CWD binds and no
  sysfs or FPGA/VFIO/UIO device nodes. No application execution, OPAE loading,
  installation, enumeration, MMIO, DMA, reset or card operation occurred.
  [Mount capture](native-build01-capture/mounts.log),
  [namespace and scope assertions](native-build01-result.json).

## Produced artifacts

Both remote artifacts remain mode `0600` under
`work_caps03_host01/build01/build/`; retained local captures are also non-executable.

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `ahls_memory_caps03_startup` | 36784 | `8f363546faff826dd63c0e1da166d34db63ea5eb36fd9bb13ec4f54e7de955f7` |
| `libahls_memory_caps03_entry_vfio_strict.so` | 39616 | `6c8427d7379e811122cd549dec40181044c2dd90b961e56b163b6c1a69daecf0` |

The launcher needs only `libjson-c.so.5` and libc; the entry needs `libopae-c.so.2`
and libc. The entry imports `ia840f_opae_initialize_vfio_strict` and defines the
three expected entry/initialize/finalize exports. These are static ELF findings,
not actual dynamic-loader observations. [ELF reports](native-build01-result.json).

The parent verified all 14 captured members against the native result envelope.
Raw payloads and embedded-source launchers remain local-only under the evidence
policy; the metadata receipt binds the original native result SHA256.

## Remaining acceptance

The [46-case inert result](RESULT01.md) and this native build are separate evidence.
Neither establishes loaded backend/transitive runtime resolution, FPGA arithmetic
or visibility, global transaction drain, nor safe VFIO teardown. Final image
reset/CDC/constraint acceptance and source-bound deployment precede any card test.
The existing [pending-transaction erratum disposition](../caps01-dma-gib01/ERRATUM11.md)
remains open.
