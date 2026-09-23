# Real PIM + DMA + AHLS native analysis/elaboration

**Native/effective/outer0; independent review pending.** Structural analysis/elaboration only, not mapped synthesis, timing, simulation, PR, deployment or hardware. [Scope](SCOPE.md), [parent verification](parent-verification01.json), [project](project01.qsf), [inputs](input-manifest01.json).

## What is now connected

The alternate `afu/ahls_memory/pim/ofs_plat_afu.sv` contains exactly one `ofs_plat_host_chan_as_axi_mem_with_mmio` primary host port0 mapper, the unchanged connected `ia840f_ahls_memory_core`, and two actual `ofs_plat_local_mem_as_axi_mem` bank shims. Unused PIM interfaces use the actual tie-off module, masks host1/banks3. Existing scalar AFU, donor RTL, completed FIM and prior component files remain unchanged. [All171connections](connections01.json).

This run uses actual Work21-generated PIM files and FIM packages/headers, not component_platform_pkg or the synthetic umbrella. Captured211platform members include157native generated source assignments; the flattened standalone source list preserves those entries and their ordering. Additional FIM packages/interfaces and headers resolve the real metadata. `afu_json.tcl` and `user_clock_config.tcl` are captured but deliberately not executed: this component analysis neither creates a PR build environment nor changes the user clock. PIM primitive SDC files are retained in the source list, but no STA ran.

Host interface57-bit byte addresses/512data/8-bitlen/9-bit IDs/4USER. Actual primary mapper explicitly sorts reads and writes, buffers read responses, and requests CDC+3timing stages. Sorting writes is an explicit supported setting beyond the donor's default, retaining the engine's ordered-response contract. MMIO uses the actual platform address width,64data,16-bit IDs/1USER. Flat AXI4-shaped core len0/INCR/single WLAST bindings represent AXI-Lite; core RLAST is an explicit unused wire. A static generated-geometry check elaborates an undefined fail-closed entity if these source-derived sizes differ; native analysis did not select that branch.

Both bank interfaces retain34-byte-address/512data/8len,**18-bit IDs/2USER** on the fabric side. Actual PIM `map_user` instances preserve user and extra IDs; physical IDs/USER are not simply sliced. Native grouped parameter panels list **both map_banks[0].shim and map_banks[1].shim** even though the representative header names bank1. They show the18-bit AFU IDs and user_ext FIM_USER_WIDTH1, FORCE_RD/WR_ID_TO_ZERO1, FORCE_USER_TO_ZERO1,512metadata entries. [Native panels](native-parameter-panels01.json). These are parameter/wiring facts, not dynamic metadata/ordering correctness proof.

Core clock is actual bank0 clock. Actual `ofs_plat_join_resets` joins bank0 reset and pClk softReset into bank0 domain. Primary and both bank shims receive that reset; bank shims retain their own bank-domain reset mapping, CDC and timing pipelines. **Reset propagation timing and live reset/drain safety have not been tested.** Full-device Reset Release must still be supplied/proven once in the eventual FIM.

## Native execution and preserved evidence

Fresh `work_ahls_memory_pim25_01/elab01`, owned tmux@223/%223. Quartus25.1.0 Build129 SC Pro, AGFB027R25A2E2V. Native command:

```
/opt/altera/25.1/quartus/bin/quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ia840f_ahls_memory_pim_elab -c ia840f_ahls_memory_pim_elab
```

2026-09-23T11:42:14.502411Z→11:43:16.122584Z, PID106956/startticks12700626. Native/effective/outer0, runner accepted; no timeout, descendants or surviving owned group.273platform/core copied inputs plus255previously generated fabric/HLS inputs =528bound inputs.262original platform/FIM files plus the existing generated fabric originals checked before/after. All preservation flags true, QSF and tools unchanged. Result archive SHA256/size in [receipt](outer-elab01.json);9captured report/log/QPF/QSF members, including the copied generated PIM QSF metadata. Oversized reports and all raw source/payload-bearing runners stay local/hash-bound.

Finite read-only capture history is explicit in [capture disposition](CAPTURE-DISPOSITION01.md). No unchanged native generation/elaboration was repeated: this is the first run adding actual PIM around the prior core.

## Diagnostics and retained risks

Banner0errors/1warning, but full log has **341diagnostic occurrences**:21425×118,13469×87,21610×86,16788×22,21442×19,16752×2,21705×2,13461×1,17498×1,20759×1,21620×1,23762×1. [Ledger](warning-ledger01.json) binds every source-bearing message to available source/hash. No suppression, count normalization or blanket vendor waiver.

-118messages21425 arise from our redundant command-line AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU define and the captured platform_afu_top_config.vh declaration. Preserve this run; remove the redundant command-line definition in the next changed project, not by mutating results or rerunning unchanged logic just to tidy counts.
-Standalone DRC RES-10204: missing Reset Release IP, High1violation/0waived. This top is still not a full-device configuration. No duplicate IP inserted and no waiver.
-Actual PIM burst mapping, request/response, FIFO/ID/USER and inherited DMA/HLS width/driver diagnostics need source/instance classification. CCI-P files are part of the generated PIM source list although active host class is native AXIS PCIe TLP; two16752potential-loop messages cannot be attributed to active instantiated logic without that check.
-Native sweep removes three reported sample hierarchies: unused write-only MMIO helper, one write-ROB RAM specialization, and **freeze_cc**. The generated HLS `_di` forwards freeze to `cra_ring_wrapper`, where it is only declared, not consumed. Do not claim effective freeze/quiescence merely because a wire exists. [Source observation](freeze-source-observation01.json). Live PR/reset/global drain remain blocked.
-The sweep panel does not show the whole core or bank shims removed. Native parameters/hierarchy include the primary mapper, both bank shims/metadata queues/CDC, real DMA top and actual DDRIP fabric. Numerical function has not been executed.

## Still outside acceptance

Upstream20-bit MMIO aliases remain (e.g. low17-bit router behavior);16-bit DMA CSR rejection cannot fix them. Readable posted-write admission/first-error reporting, control safety, pinned-host buffer extent/lifetime, fences/global drain and malformed/protocol-boundary behavior remain open. Prior synthetic endpoint tests do not prove the donor's burst encodings/4KiB handling through real Platform Designer and PIM. IRQ is explicitly unrouted; constant-zero exception is not a checker. Component-only UUID remains a non-deployed identity, not an OPAE discovery result.

The separate core review deleg_cd672a31 is pending in the last observed state. CSR-admission independent/parent acceptance is now published **cbefc1a91b1cb417906eb360fddf0f15f33a4407**; its F1/F2 limits are retained. This native PIM stage grants no broader acceptance of either.

No FPGA/MMIO/device/driver/programming/reboot. DDR vendor simulation **SKIPPED BY USER**. Both-DDR tests, host↔FPGA copies, actual AHLS numerics, full FIM/persona fit/STA, signoff and durable boot still required. Goal incomplete.
