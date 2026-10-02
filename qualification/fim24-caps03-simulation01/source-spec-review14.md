# Migrated simulation SOURCE/API review14

**Verdict: SPEC PASS. No source/API changes required for the scoped experiment.**

Reviewer: GPT-6 (`gpt-6-astra-900k`), provider `openai-codex`, substituting for unavailable GLM-5.3. This is source/specification acceptance, not migrated simulation acceptance, runner QUALITY approval, or execution authority.

## Evidence boundary

Reviewed `SCOPE12.md`, `source-selection10.json`, `proposed-commands12.json`, `candidate12/CMakeLists.txt`, the source/include/configuration ledgers, actual prepared bodies, and the retained qualification bar in `../caps03-completion01/ACCEPTANCE06.md` and `sim05.py:86–126`. The old capsule was parsed/literal-decoded only as data, never imported or executed.

Independent Python SHA256/size verification found **590/590 frozen members matching**: 560 prepared inputs, 12 configuration captures, and 18 metadata/code files. Prepared inputs total **15,337,338 bytes** and match both selection10 and prepared-inputs10. Binding: `source-freeze13.json` SHA256 `214e63203c1568552274787f5c05356970cdafda67d26da40d7943e5f0c60091`.

The compressed prepare10 result matches collection10's hash/size; both exported readbacks match their encoded bodies. Its recorded success/outer zero, 542 original bindings, 3443 persona entries, 19 simulator bindings, original preservation and absent native01 are preparation evidence—not a fresh remote observation or native result. The separately bound persona review-consumption18 digest also matches.

## Sources, ordering and generated API

- All **458 compile entries are unique and bound**: 178 current-release, 12 preserved-Work24 supplements, 18 unchanged AFU/test sources, and 250 current generated entries. Non-generated order equals the actual old capsule. Fourteen Work24 supplements include two headers outside compile order; they are explicit provenance, not silently assumed release files.
- Reparsed both actual QIPs: **257 HDL assignments**, with complete ordered path/library metadata matching selection06. All 265 literal QIP file edges resolve in prepared inputs. The seven omitted repeated basenames have independently equal bodies; their first-occurrence reduction reproduces exactly the 250 selected entries. QIP generation identifies 26.1.1. Flat `work` is accepted only as this retained unit recipe, not as a general replacement for generated library semantics.
- All 18 retained functional/test bodies are byte-identical to decoded sim05 inputs. The generated outer and intermediate fabric module declarations match their prior interfaces after comment/whitespace removal. The `dut.fabric.fabric.fabric` instance chain remains present, with all ten HLS signals referenced by the active source-credit checks present in its selected body. These are static API checks, not elaboration or behavioral equivalence.

## PIM configuration and simulation mode

The real matching AFU header selects `d48dde9f-f551-578d-8bb0-69483ac95ec6`, replacing only the old diagnostic UUID include; the setup interface UUID remains `fc603c44-5c8f-5e94-bcbe-a5780030947c`. The native platform header selects Agilex/Agilex7 and `ofs_plat_afu`. Actual PIM configuration retains native-axis-PCIe host declarations and native-AXI local-memory parameters; the tests instantiate the memory interfaces/shims directly, not the PCIe shell.

The **24 include directories and 13 definitions** retain the old unit arguments and include every current emitted FIM project macro. Added `INCLUDE_LOCAL_MEM`, `PR_COMPILE`, `SHARED_AFU_MAIN_TO_PORT_AFU_INSTANCES`, and `AFU_MAIN_HAS_PF_VF_MUX` have no direct selected-compile-body references. This must not be restated as globally unused: the configuration header references the local-memory alias and ASE-top choice; the excluded ASE module references the PF/VF flag.

Independent directive scanning reproduces **183 literal include edges**, no computed includes and no different-body candidate ambiguity. The sole absent `ofs_plat_hssi_wrapper.vh` is guarded by `OFS_PLAT_PARAM_HSSI_NATIVE_CLASS`, undefined in staged HDL/headers and command definitions. This establishes the stated bounded static disposition, not a complete preprocessor proof.

Omitting full-ASE `RTL_SIMULATION`/`SIM_MODE` is justified for these explicit roots: no staged HDL/header uses the former; the latter occurs only in `ofs_fim_remote_stp_node.vh`, which is outside the selected literal-include reach. Do not activate relocated reference `-F` lists or add unused historical `+ISOLATE`.

## Direct command contract

All six CMake target command vectors match commands12 exactly; vlog's ordered suffix equals selection10's arguments plus compile order. They preserve sim05's actual `vsim -version`, `vlib work`, `vdir -lib altera_lnsim_ver`, `vlog -sv -work work`, then both test roots under `vsim -c -onfinish exit -L altera_mf_ver -L altera_lnsim_ver`, with `-do "run -all; quit -f -code 2"`.

The 19 normalized simulator/INI/library bindings agree across retained records and prior qualified hashes. The unmodified prepared INI matches the bound installation. `/opt/altera/25.1/questa_fe` identifies the retained **Questa 2024.3** installation, not design-generation release 25.1; current license checkout and new-RTL compatibility remain untested.

The future runner must configure once and invoke targets serially in the declared order: these custom targets do not encode dependency ordering. Preserve exclusive native01 ownership, bound cwd/INI, clean HOME/TMPDIR, explicit PATH, unrecorded inherited licensing, all 36 allowed CPUs and 64-GiB per-process limits. Preserve 60-second configure/version/vlib/vdir deadlines, 300-second vlog, 180-second integrated and 90-second split deadlines. No suppression or RTL/model patch is admitted.

## Scoreboard and acceptance contract

`ahls_memory_path_tb.sv:251–538` retains source-credit/data/mask checks, six numerical cases, complete copyback/guard comparisons, response-retirement certificates, forced final-W stalls, both-bank write-page crossings, native B-error rejection, premature DMA-GO rejection, and bank1-only reset invalidation. Source-derived totals remain six cases, 133 integers, 1600 copied bytes and 30 descriptors. `page_split_fault_tb.sv:35–86` observes the intermediate error before NO_REPLY suppression through the actual page mapper/PIM/CDC path.

Require exactly one complete `AHLS_PATH_UNIT_PASS` with those totals and positive checks, one `BANK1_RESET_INVALIDATION_PASS checks=1`, and one `PAGE_SPLIT_ERROR_PASS native_AW=2 native_W=4 native_B=2 upstream_B=1 observed_split_errors=1`. Require native/effective/outer zero, complete preservation and logs, and reject timestamp/qualified Error/Fatal diagnostics, nonzero Errors summaries, missing/duplicate scoreboards and supervision failures. `$fatal` can coexist with native zero under `-onfinish exit`; marker-only acceptance is invalid.

Runner enforcement remains for subsequent QUALITY review, not a source/API blocker. Keep full PCIe/AFUtop/pr_slot, physical DDR, timing, hardware, stopped-clock/active-reset recovery and bank0 read-error telemetry outside the claim. The retained Quartus legacy-addenda gap requires its separately reviewed future-copy correction; direct vlog does not load that QSF. No implementation, project-script/native/test execution, remote access, Git operation or hardware access was performed.
