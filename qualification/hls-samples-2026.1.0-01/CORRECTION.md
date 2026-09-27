# Overall-goal correction and release-wide execution

Joe explicitly reaffirmed the entire requested release: https://github.com/altera-fpga/hls-samples/releases/tag/2026.1.0 . The prior closure at `eeb28d8ccbf3f383e77c6a979197989acc853154` incorrectly substituted one sample integration for the overall goal. The overall goal is **incomplete and reopened**.

The actual accepted upstream-derived kernel is `Tutorials/Features/hls_flow_interfaces/mmhost/part3_ddr_hosts/src/mmhost.cpp`, adapted for IA-840F address width and executed through OPAE. Its small, repeated and bulk invocations are variants of one kernel. Custom DDR isolation/walking/full-capacity tests are infrastructure qualification, not additional upstream samples. The earlier scalar `qual_vec_op` is custom source, not another upstream sample ([DDRIP provenance](../../afu/ahls_memory/README.md), [custom compile](../ahls-compile-01/report.md)).

Use exact release commit `0abae6d78af5daca3fe5d67e617ab037e58aff89`. Inventory actual CMake variants and documented modes across Tutorials and ReferenceDesigns; preserve missing/stale README links rather than inventing sample files. Record compilation, emulator, RTL simulation and IA-840F real-card results separately. Unsupported modes or board-specific designs remain explicitly unresolved until disposed of, not silently counted as complete.

First execution batch: the four documented `Tutorials/GettingStarted/fpga_compile` parts, using original CMake and source. Part1 is ordinary C++, not a hardware test. Parts2–4 have separate emulation/report/simulation targets; a report artifact is not an executable or real-card pass. Existing Work21/CAPS03 image and its successful tests remain preserved; do not reflash or repeat the full-DDR run for this batch.
