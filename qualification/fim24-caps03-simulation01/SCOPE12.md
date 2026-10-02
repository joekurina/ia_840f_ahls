# Migrated integrated-memory simulation — source and command scope

Run the two existing active-scoreboard unit tests under the bound Questa Intel FPGA Edition2024.3 installation. Use matching native Work24 setup/PIM configuration and26.1.1-generated fabric, not old generated RTL. This qualifies the retained integrated memory path and page-split fault behavior; full PCIe mapper/AFUtop/pr_slot, timing, physical DDR and hardware remain excluded.

## Current sources

560 inputs (15,337,338 bytes) are staged and read back in `prepare10/inputs`, with542 source-file bindings,3443 matching-persona entries and all19 simulator/tool/INI/library bindings freshly rechecked. The local source mirror is reconstructed from byte-identical bodies after remote staged hashes pass. `source-selection10.json`, `prepare10-readback/prepared-inputs10.json` and the completed setup result are the source boundary.

The explicit458-entry compile order contains178 current-release entries,12 preserved-current-Work24 supplements,18 unchanged test/AFU sources and250 current generated entries. Non-generated ordering is unchanged. Both actual QIPs produce257 HDL assignments; seven repeated basenames are removed only after body equality. Keep QIP library provenance; this is the already-qualified flat-work unit recipe, not a general library-flattening policy. The other two Work24 supplements are headers. New native AFU UUID/header replaces the old diagnostic placeholder; no testbench or functional RTL edits are proposed.

Twenty-four explicit include directories and13 definitions preserve the prior unit mode while using every current FIM project macro. Four added project macros have no direct reference in selected compiled bodies. The183 literal include references have no different-body ambiguity or computed include expression; one absent HSSI wrapper is behind OFS_PLAT_PARAM_HSSI_NATIVE_CLASS, undefined in staged HDL/headers and command definitions. This is source inspection, not a full preprocessor/native compatibility proof. [Include ledger11](include-ledger11.json), [mode disposition12](include-mode-disposition12.json).

Current complete ASE lists also advertise RTL_SIMULATION/SIM_MODE. They are reference metadata, not active relocated -F inputs or silently added flags: retain the prior explicit unit-test mode and excluded shell scope. Direct staged-source inspection finds SIM_MODE only in remote-STP declaration macros and no RTL_SIMULATION uses. Actual native diagnostics remain decisive. The old unused C.vsim_args +ISOLATE is not part of the actual prior argv and is not added.

## Commands and acceptance

Direct CMake targets preserve the actual successful sim05 sequence: vsim-version, vlib work, vdir of altera_lnsim_ver, vlog -sv -work work plus explicit arguments/order, then two vsim -c -onfinish exit invocations. Library order remains altera_mf_ver then altera_lnsim_ver. Keep `run -all; quit -f -code 2` and the unmodified installed modelsim.ini; no warning/error suppression or vendor-source modification. [Commands12](proposed-commands12.json), [CMake](candidate12/CMakeLists.txt).

Use one exclusive native01 root with clean HOME/TMPDIR, all36 allowed CPUs and64GiB per-process. Proposed command deadlines: configure/version/vlib/vdir60s each, vlog300s, integrated180s, split90s. Source-bound early entry, owned process groups/unreaped-leader cleanup, log/diagnostic observation through drain/final exit, finite log/capture bounds, raw/native/effective/outer status and complete input/tool/original preservation are mandatory. Per-process limits are not aggregate containment.

Native zero alone is insufficient: reject Error/Fatal (including parenthesized severity and timestamp prefixes), nonzero Errors summaries, missing/duplicate scoreboards or preservation failures. Require one AHLS_PATH_UNIT_PASS with six cases,133 integer results,1600 copied bytes,30 DMA descriptors and positive checks; one BANK1_RESET_INVALIDATION_PASS checks=1; one PAGE_SPLIT_ERROR_PASS native_AW=2 native_W=4 native_B=2 upstream_B=1 observed_split_errors=1. Preserve complete logs and warnings for actual-result review.

No simulation execution is authorized by this source package. The accepted setup has a retained missing Quartus legacy-addenda filename; direct explicit-list Questa does not load that QSF and does not validate its planned future compatibility link. No copied setup mutation, persona compilation, programming or hardware access is included.
