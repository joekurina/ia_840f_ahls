# Generated closure and retained-simulation review23

**Reviewer:** GPT-6/openai-codex, substituting for unavailable GLM-5.3. Local byte, AST/literal and HDL inspection only; no capsule import, native invocation, test, SSH, Git or hardware operation. Only this report is written.

**Disposition:** No captured-file/QIP-closure or corrected-HLS-preservation blocker found. The retained integrated fixture is a source-compatible starting point, **not an already-qualified simulation of the migrated fabric**. Fresh binding, compilation/elaboration and both behavioral runs remain required. Geometry/IP-flag review is separate; generation does not establish synthesis, timing, physical DDR or hardware acceptance.

Paths below: **G** = `completion17-readback/generated`; **S** = `../fim24-caps03-simulation01`; **P** = `../fim24-pr-platform01`.

## Independently verified

- Rehashed all **324** members of `actual-result-freeze21.json`: no mismatch. Reconciled all **294** generated/input-metadata files against the captured native result: **13,244,203 bytes**, no mismatch.
- Independently parsed both QIPs: `G/ahls_memory_dma_fabric/ahls_memory_dma_fabric.qip` and `G/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/ahls_memory_dma_fabric_fabric.qip`. All **265** file assignments resolve to **264** captured, hash-matching targets; no unsupported file-assignment syntax. Counts: 233 SYSTEMVERILOG, 24 VERILOG, two SOPCINFO, four MISC, one OCS_IP and one SDC_ENTITY. This agrees with `qip-closure18.json`, including the instance-assigned reset SDC and `-no_sdc_promotion`.
- All **155** HLS files independently match admitted `current_sha256`, `hls-generated-binding20.json`, and the hash-verified old sim05 capsule. Exactly the admitted three differ from original-HLS hashes: `lsu_burst_coalesced_pipelined_read.sv`, `lsu_burst_coalesced_pipelined_write.sv`, `lsu_ic_top.sv`. No new HLS edit or resynthesis is needed.
- Captured operation logs and both complete generation reports contain no Warning/Error/Fatal/rejection/failure diagnostics. Import and generation completion markers agree with recorded zero native/effective/outer results. Generation's eight width/burst adaptation messages (`completion17-readback/operation/generate.log:44–51`) are informational, not evidence that masks or response timing work. No live Java-process witness is inferred.

## Generated HDL and ordering

The top QIP contains only its wrapper HDL, **not a recursive child-QIP inclusion**. Select both closures; exclude unassigned `*_inst.v`, black-box and VHDL templates. Preserve non-HDL assignments as provenance/implementation dependencies rather than passing them to vlog.

There are **257 HDL assignments**, including `acl_parameter_assert.svh`. The only repeated basenames are pipeline-base (three copies), address-alignment (four), and burst-uncompressor (three); each group's bodies are byte-identical. The historical flat `work` recipe is exactly first-occurrence QIP ordering with these duplicates removed. Reapplying that rule to current bytes yields **250 entries**, including the header; preserving the other 208 retained entries would again yield 458. That arithmetic is not a new binding or acceptance of the old paths. Keep every original QIP library attribution; never deduplicate unequal bodies by basename.

No new package-order dependency was identified. Retain FIM packages before dependent PIM packages/interfaces, `dma_pkg` before AFU consumers, and `acl_ecc_pkg.sv` before its consumers (child QIP:639,642–645); retain the HLS include directory. Derive the generated block anew, not from old hashed filenames.

Nine library revisions changed: AXI bridge 1993→19103; Merlin AXI translator 1974→1988, master NI 19100→19121, slave NI 19112→19134, slave agent 1930→1940, burst adapter 1940→1950, master agent 1931→1951, traffic limiter 1921→1922, width adapter 1950→1970. These are not merely renames: current width adapters pass `USED_IN_WIDTH_ADAPTER=1` to the updated burst-uncompressor; address-alignment adds a SELECT_BITS-zero branch; reorder-memory changes sequential/read-during-write handling. These changes are visible in the current `altera_merlin_width_adapter_1970/synth` and `altera_merlin_traffic_limiter_1922/synth` sources. Mixing old support bodies with new wrappers is unsafe.

Both 245-port wrapper ABIs independently match the old capsule, including final comma-less ports. `dut.fabric.fabric.fabric` still resolves through the same instance names, and all ten HLS-monitor nets remain declared with matching widths. No fixture/core rewrite is justified by these checks; native elaboration must confirm binding.

## PIM/source-selection compatibility

Rechecked `S/platform-rebind-map01.json` against the accepted 3,454-entry release inventory: **242 identical, two changed, 17 absent**. Current captured PIM bodies support reuse; absence is not export corruption. Fourteen omitted FIM dependencies independently match Work24 inventory hashes and verified old payloads; bind their current Work24 origins before use. The other three are setup/application selections: both `platform_if_addenda.qsf` locations and `platform_afu_top_config.vh`. The latter is directly included by current `ofs_plat_if_top_config.vh:109`; bind fresh matching setup/configuration, not an unexplained historical header.

Under `P/closure32-readback/release/hw/lib/build/platform/ofs_plat_if`, the two changed `sim/platform_if_{addenda,includes}.txt` files now delegate through `-F` to FIM lists/macros and `ofs_plat_if_*`. The latter retains the old PIM list/order with the include-filename rename. Do not blindly expand the full-platform wrapper into this curated fixture: resolve relative `-F` paths and current macro differences explicitly. `P/config33-readback/hw/lib/build/platform/sim/fim_project_macros.txt` additionally supplies INCLUDE_LOCAL_MEM, PR_COMPILE, SHARED_AFU_MAIN_TO_PORT_AFU_INSTANCES and AFU_MAIN_HAS_PF_VF_MUX.

All 19 `S/baseline01` test/AFU files match the verified capsule; the 15 shared HDL selections match `../caps03-persona01/source-selection01.json`. Retain its tested bank0 shim, completion shim/guard/reset and core/DMA, not similarly named originals. The separate offline top's COMPLETION_SUPPORTED change is not exercised by this fixture.

## Required next simulation evidence

1. Fresh-bind actual Questa **2024.3** executables, INI and library contents; retain `-L altera_mf_ver -L altera_lnsim_ver` ordering. The historical `/opt/altera/25.1/questa_fe` directory is not its version. New generated OEM pragmas and changed vendor bodies require real compile/elaboration compatibility evidence; no demonstrated need exists to rebuild physical-DDR models. Keep assertions enabled. The old literal `+ISOLATE` was not consumed by sim05's actual argv; do not mistake recovered configuration for invocation.
2. Retain numerical cases **1,8,17,65,9,33**, **133 integers/1600 copied bytes/30 DMA descriptors**, full-width size/alignment, masks, backpressure and final-W/page-split coverage. Require actual B-error and premature-GO rejection, split-error observation **AW/W/B=2/4/2; upstream B=1**, and bank1-only idle-reset invalidation. Preserve finite watchdogs, exact pass markers and native/effective/outer/preservation checks. Retain one exclusive owner, ordered programming and no outstanding DMA at launch; these tests do not establish concurrent-owner safety.
3. Triage fresh diagnostics rather than suppress them: historical sim05 had 36 compile warnings, 261 main-run warnings and zero split-run warnings, including out-of-range-select and missing-port families. These are comparison evidence, not a blanket waiver. Bank0 read-error telemetry, stopped-clock/active-reset recovery, full PCIe mapper/`ofs_plat_afu`/`pr_slot`, physical visibility and hardware remain outside this acceptance.
