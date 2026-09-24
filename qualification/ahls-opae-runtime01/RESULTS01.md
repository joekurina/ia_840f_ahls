# DFL-only candidate and SDK parser evidence

**Completed local tests; independent/parent acceptance pending.**

## Change and observed result

The only new runtime configuration is
[`src/host/config/ia840f_caps01_dfl.cfg`](../../src/host/config/ia840f_caps01_dfl.cfg),
858 bytes, SHA256 `9f49f4d455e672de26dc8546a8ccdc029dbdfe521bee1beca47d102cb63ef5e4`.
It is not installed. The original SDK and system configurations, memory frontend,
scalar frontend, container builds and FPGA sources are unchanged.

The test links nine byte-identical SDK source/header files (79,023 bytes) to the
actual JSON-C0.15 runtime extracted from the previously authenticated Ubuntu
packages. GCC14.2.0 compiles the inert fixture with O2, Wall/Wextra/Werror and
UBSan. The only direct ELF dependencies are `libjson-c.so.5`, `libubsan.so.1`,
`libc.so.6`; static symbol checks find no OPAE runtime initializer, plugin manager,
FPGA API, backend, dlopen/dlsym, ioctl or mmap entry. Ordinary libc file reads
remain for named JSON input. No target OPAE runtime/shared backend is loaded.
Bindings and claims: [source-and-results01.json](source-and-results01.json),
[commands03.json](commands03.json), `parser-elf01.log`, `parser-symbols01.log`
and `parser-undefined01.log`. This is a parser-source test on the agent host,
not container runtime execution or exhaustive transitive toolchain qualification.

- RED: the unmodified SDK config produces54 table rows and the exact-two-row
  predicate returns1 as intended ([receipt](red-result01.json)). This is a
  candidate-contract failure, not a claim that generic upstream configuration
  is broken.
- GREEN: the new config produces exactly2 xfpga rows for `8086:bcce/8086:1771`
  and `8086:bccf/8086:1771`, and the predicate returns0
  ([receipt](green-result01.json)).
- Matrix01 and matrix02 each pass22 cases:1 exact candidate,13 fallback cases,
  2 empty-table cases,6 accepted-but-unwanted table mutations rejected by the
  local exact predicate. The null-input default has52 rows. The local predicate
  is test code, **not an installed runtime fail-closed mechanism**.
- Matrix02 uses Python `-O` after adding an explicit missing-module-loader check
  to the harness (no assertions are used as its acceptance mechanism). All rows
  and verdicts match matrix01. One diagnostic contains its new fixture directory;
  the initial parent whole-receipt equality failed only for that exact pathname,
  which is recorded without rewriting either receipt or rerunning either matrix.
- The initial harness is retained as `test-opae-config-matrix01.py`; its static
  possibly-None import-loader finding was corrected additively in the maintained
  harness. Compiler/configure/test logs and prior receipts remain intact.

## Source findings that matter before future runtime execution

All source paths below refer to the exact SDK SHA inventory bound in
`../ahls-memory-host01/result-apptainer-backends11.json.gz`. Older source captures
were reused only after byte equality; missing sources were collected as ordinary
files in owned tmux, not by executing the library.

1. `libraries/libopae-c/init.c:179–236` contains a constructor that normally
   calls `fpgaInitialize(NULL)` before application main. Presence of
   `OPAE_EXPLICIT_INITIALIZE` suppresses that implicit path, but `WITH_ASE`
   takes precedence; the values are tested for presence, not parsed booleans.
   Log-file handling at203–213 happens earlier. Therefore argument validation
   and an application read-only API list do not control pre-main effects.
   [Captured source](../ahls-memory-host01/sdk-runtime-sources12/libraries/libopae-c/init.c).
2. `cfg-file.c:57–121` tries LIBOPAE_CFGFILE, then HOME and system paths. An
   unresolvable explicit environment path falls through to those defaults.
   `cfg-file.c:330–339` returns the compiled default table when JSON parsing
   returnsNULL. `opae-cfg.c:342–387` establishes parser ownership/freeing and
   failure cases; the inert matrices confirm these fallback observations.
   [Source binding](source-and-results01.json),
   [parser](sdk/libraries/libopae-c/opae-cfg.c),
   [configuration wrapper](sdk/libraries/libopae-c/cfg-file.c).
3. `pluginmgr.c:254–288,290–459,462–581` detects ID tuples over PCI sysfs before
   application token filtering, loads matched modules, and initializes all
   loaded adapters. Tuple selection is not BDF isolation. Its loader at60–79
   concatenates configured search prefixes and finally the empty prefix;
   the captured build config's paths include `/work/install/lib64/opae/`,
   `/work/install/lib/opae/`, `/usr/lib64/opae/`, `/usr/lib/opae/`, then empty.
   The candidate names an absolute build-context module path; no loader
   resolution or backend activation was exercised.
4. The original SDK `opae.cfg` n6001 entry matches these inherited numeric
   IDs and selects xfpga for the PF plus VFIO/UIO modules for PF/VF. Its board
   label does not turn IA-840F into an N6001. The new candidate intentionally
   does not import Intel-board management, RSU, daemon or AER command recipes.
   It is not a fallback if DFL live access fails.
5. `libraries/plugins/xfpga/plugin.c:39–50` invokes sysfs/ioctl initialization;
   at59–62 it ignores the plugin JSON configuration argument. The VFIO plugin
   similarly ignores that argument and discovers VFIO PCI devices during
   initialize (`vfio/plugin.c:48–70,83–86`). Inventing a `bdf` field inside
   the plugin object would therefore not establish isolation. The prior
   [source-to-host map](../ahls-memory-host01/HOST-ACCESS-DELTA01.md) retains
   prefilter xfpga enumeration and VFIO PCI COMMAND-write/open effects.

## Boundary and next engineering step

This closes neither runtime selection/loader behavior nor live endpoint safety.
Before eventual execution, an explicit supported startup sequence must account
for pre-main initialization, validate the exact configuration/ELF/namespace,
select the backend justified by the actual driver binding, and retain the
source-derived enumeration/open/close footprint. Current deployed image/BDF,
clock-reset, IOMMU/ownership and independent recovery remain unresolved; no
live probe is a substitute. Numeric ID labels do not prove PF/VF attachment.

Keep source defaults and all existing changes; no revert, install, FPGA rebuild,
application invocation or library-loading shortcut was performed. Physical DDR,
DMA, numerical AHLS, lifecycle and boot remain unqualified. Vendor DDR simulation
remains SKIPPED BY USER.
