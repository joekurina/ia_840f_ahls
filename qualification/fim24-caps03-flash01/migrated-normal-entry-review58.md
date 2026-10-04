# FINAL — migrated normal-idle reset-entry review58

**CONDITIONAL SUPPORT / NO INTRINSIC RESET-SEQUENCE BLOCKER in the reviewed normal-idle route.** The actual migrated source, including the PR-slot host-reset register and both application reset joins, supplies an assertion/recovery budget sufficient for the fitted **three additional `clk_sys` / seven additional bank0 cycles**. This is a bounded source/report conclusion under ordinary approved vendor/compiler semantics, not a measured waveform, universal reset qualification, hardware admission or task closure. **First VFIO acquisition/enumeration/AFU access still requires the fresh operation bindings in §5; they are not established by this local review.** No new timer, readiness CSR, source change, rebuild, probe or Quartus opening is justified by the reviewed sequence.

Scope: local ordinary-file reads, SHA256, JSON/text reductions and rational arithmetic only. No project imports, tests, native/vendor tools, Git, remote contact or device operations. Sole written artifact: this report. Repository-relative paths below resolve under `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.

## 1. Current basis, not historical reset-budget substitution

- [FIT-ACCEPTANCE38](../fim24-caps03-physical01/FIT-ACCEPTANCE38.md), [NUMERICAL-ACCEPTANCE32](../fim24-caps03-sta01/NUMERICAL-ACCEPTANCE32.md) and [CDC-ACCEPTANCE73](../fim24-caps03-cdc03/CDC-ACCEPTANCE73.md) retain the operation-bound reset obligation. The last acceptance resolves the narrow current FIFO endpoint/net-delay/exception discriminator, **not reset entry, electrical limitations, clean DRC, MTBF or hardware**.
- Independently parsed the complete native **81-row** Reset Sequence Requirement in accepted `fim24-caps03-physical01/completion30-readback/reports/ofs_pr_afu.fit.rpt:25770–25856` and `ofs_pr_afu.fit.retime.rpt:73–159`. Their ordered rows are equal. Only `sys_pll|iopll_0_clk_sys = 3` and `local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|emif_0|emif_0_core_usr_clk = 7` are nonzero. Bank1 is zero. The native note explicitly calls these **minimum additional reset-sequence cycles due to retiming**. They are not total pulse widths, a ten-cycle common-domain pulse, or a software sleep.
- [Reset-entry-basis33](../fim24-caps03-sta01/reset-entry-basis33.md) already identifies this bounded candidate. This review independently rebinds/recounts its actual source route and replaces its printed-period arithmetic with exact generated-clock-ratio notation (§3). Its conditional conclusion is supported; its `76.413 / 317.728 / 213.934ns` calculations use rounded native display periods and are not exact current clock-ratio results.
- [Hardware-reuse-ledger31 §3 item5 / §6](hardware-reuse-ledger31.md) correctly preserves the historical PR-slot omission. Old `caps03-runtime01/entry-admission.json` accounts for nominal19sys/12bank0 stages and `241.315ns`, then the old **four** extra bank0 cycles. Neither that old margin nor the four-cycle obligation is used here. RESET08 remains a narrower historical simulation, not a current full-chain cycle-exact test.
- Actual postboot54 records boot **`3e2d2060-d6c0-44b5-a269-1adf1e450041`**, cached migrated interface **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**, PF0 DFL/PF1 VFIO, application VF absent and `sriov_numvfs=0`. `hardware_ready=false`, `application_VF_created=false`, `numerical_test_launched=false`. [Deployment review56](deployment-result-review56.md) reports deployment PASS WITH LIMITS; parent consumption is separate. These observations identify the intended deployment, not present reset delivery or permission to open a VF.

## 2. Actual joined path and hold/release behavior

For source references, `C = ofs-agx7-pcie-attach/ofs-common/src`, `P = ofs-platform-afu-bbb/plat_if_develop/ofs_plat_if/src/rtl`. Selected application SVs are the accepted STA captures, **not an unbound similarly named source template**.

### Selected VF FLR → host soft reset

1. `C/common/flr/flr_rst_mgr.sv:126–188` decodes requested PF/VF, registers `vf_flr_rst_in` and active-high `vf_flr_rst`, then sends its inverse through a **three-register `clk_sys` resynchronizer**. `RST_CNT_WIDTH=7`; `rst_counter_in_rst = cnt[6] & cnt[5]`, `rst_counter_busy = cnt[6]`. Counter values127…96 give32 assertion states and95…64 give32 recovery states. The registered request/reset and registered response do not shorten the conservative32-CSR-period assertion/recovery allowances. Response readiness is gated by counter-not-busy; output response is registered. **There is no downstream receiver acknowledgment.** Sources: manager30–86,126–188,229–247; `fim_resync.sv:92–104`; `ofs_std_synchronizer_nocut.sv:116–157`. The selected resynchronizer has `TURN_OFF_ADD_PIPELINE=1`: no hidden extra duplication tree is counted.
2. `C/fpga_family/agilex/port_gasket/port_gasket.sv:146–188` selects the port's mapped VF reset, combines it with `~o_afu_softreset`, PF reset and system reset in `port_rst_in_n`, then applies a depth3 duplication tree. The tree has **three shift registers plus its separate leaf**, not three stages total (`fim_dup_tree.sv:27–38`).
3. **The real PR-slot stage is included:** `pr_slot.sv:123–126` registers `port_rst_n_t1`;338–346 connects it to `afu_main.port_rst_n`. `afu_main_std_exerciser/fim_compile/afu_main.sv:351–367` registers `port_rst_n_q1`, then applies the default depth6 duplication tree, **six registers plus leaf**. Other reset inputs are stable/inactive in this normal-idle case; their parallel cones are not added serially.
4. `afu_main_pim/port_afu_instances.sv:122–154` selects the **ordinary demultiplexed** reset path: `pcie_stream_rst_n = port_rst_n`; `plat_ifc.softReset_n = plat_ifc.clocks.pClk.reset_n`. `P/base_ifcs/clocks/ofs_plat_std_clocks.sv:79–102,208–219` registers the port reset once and uses port0 for the backward-compatible top-level clock/reset. The final fitted hierarchy expressly contains `...|clocks|port[0].r` (`fit.rpt:18363–18365`), corroborating the selected branch. Do not substitute the multiplexed branch, whose top-level reset excludes FLR.

### Host soft reset + bank0 + bank1 → application reset

The compiled wrapper is `fim24-caps03-sta01/completion24-readback/external/15-ofs_plat_afu.sv:6–28`, selected by captured `design/hw/afu.qsf:17–18`. Its **bank0 clock** is the application clock. `14-ia840f_ahls_memory_reset.sv:11–18` instantiates:

- `join_afu_reset`: local bank0 `reset_n` AND host `softReset_n` crossed from `plat_ifc.clocks.pClk.clk` into bank0;
- `join_bank1_reset`: preceding joined reset AND bank1 `reset_n` crossed into bank0.

`ofs_plat_join_resets` is actually defined in **`P/base_ifcs/clocks/ofs_plat_merge_resets.sv`**, not a file named `ofs_plat_join_resets.sv`. At33–35 its output is a registered AND. `P/utils/prims/ofs_plat_prim_clock_crossing_reg.sv:24–40,49–96` supplies **one source-domain register, three destination-domain crossing registers, six destination tree registers and a separate destination leaf**. Both assertion and release are sampled; this join is **not instantaneous asynchronous assertion or a stretcher for arbitrary short pulses**. Its initial/reset values are active-low asserted.

During the selected VF FLR the two memory resets are already stable/deasserted. Bank1's crossing is already settled; it is a parallel prerequisite, not a second serial traversal on the changing host-reset leg. Loss of either bank reset invalidates application/completion state; source comments expressly do not provide active-transaction recovery. `core_reset_n` feeds the core and the PIM shims (wrapper28,55–65,93–97).

### Real source-stage accounting on the changing host-reset leg

| Stage / source | Clock domain | Serial registers/hops |
|---|---|---:|
| FLR `fim_resync`, depth3, additional pipeline OFF | sys | 3 |
| Gasket `port_rst_in_n` | sys | 1 |
| Gasket duplication tree, depth3 + leaf | sys | 4 |
| PR-slot `port_rst_n_t1` | sys | 1 |
| AFU `port_rst_n_q1` | sys | 1 |
| AFU duplication tree, default depth6 + leaf | sys | 7 |
| PIM `softreset_n` | sys | 1 |
| First application's reset-crossing source register | sys | 1 |
| First reset crossing's destination vector | bank0 | 3 |
| First reset crossing's duplication tree | bank0 | 6 |
| First reset crossing's separate leaf | bank0 | 1 |
| First join's registered AND | bank0 | 1 |
| Second join's registered AND, bank1 leg already settled | bank0 | 1 |
| **Source totals, independently summed** | **sys / bank0** | **19 / 12** |

This is source-derived digital propagation accounting under running-clock/vendor synchronizer semantics, **not a fitted inventory of31 independently preserved physical registers** or an analog worst-case metastability bound. Duplication/retiming is handled by the accepted compiler semantics and the current additional-cycle requirement, not guessed extra hops or new equivalence gates. The unrelated `port_reset_fsm.sv:100–148` cold branch bypasses its hold state; its default hold counter is **not** credited to this VF sequence or claimed as universal cold-reset protection.

## 3. Exact current clocks and sufficient bounded allowance

The accepted `completion24-readback/reports/clocks.rpt:29,51,80–86` provides the actual generated-clock chain. Its sys reference period is10.000ns; N-clock divides by10, giving100ns. Sys divides that by141/3; CSR by141/14. Board `ofs-agx7-pcie-attach/src/board/ia840f/top.sv:302` binds `clk_csr = clk_100m`.

Use the **exact declared ratios**, not rounded frequency strings:

- `Tsys = 100×3/141 = 100/47 ns`; frequency **470MHz**. Native display is2.127ns. No PLL/frequency change is proposed.
- `Tcsr = 100×14/141 = 1400/141 ns`; frequency **705/7 MHz**. Native display is9.929ns /100.71MHz. Neither10ns nor a rounded100.714286MHz is substituted.
- `Tbank0 = Tbank1 = 3.000ns`, corroborated by their reported EMIF generated clocks. Separate200/100 user clocks are not the application domain.

Conservative sequence accounting, computed with rational arithmetic:

```text
Existing assertion phase allowance A = 32 Tcsr = 44800/141 ns
Existing recovery phase allowance  R = 32 Tcsr = 44800/141 ns

Changing host-reset propagation D = 19 Tsys + 12 Tbank0
                                  = 3592/47 ns
                                  ≈ 76.425532 ns

Current fitted extension E = 3 Tsys + 7 Tbank0
                           = 1287/47 ns
                           ≈ 27.382979 ns

Conservatively charge propagation AND BOTH domain extensions
against one existing phase, without overlapping their credit:
D + E = 4879/47 ns ≈ 103.808511 ns

A − (D + E) = R − (D + E)
            = 30163/141 ns ≈ 213.921986 ns > 0
```

The per-domain3/7 obligations remain separate; adding their **time allowances** above is a pessimistic serial reservation, not merging unrelated domains into a ten-cycle pulse. The source's long assertion reaches the joined reset and leaves time for the required initialization/flush cycles; its recovery phase covers propagation of release and those reservations before a successful FLR response permits requests to resume. The changing leg has the same sampling/tree/AND route on assertion and release. Charging full latency to each phase deliberately does not rely on cancellation between edges.

**Supported conclusion:** the unchanged normal-idle VF-FLR sequence has ample source-supported allowance for the actual migrated3/7 extension. No source/report discriminator is missing for that bounded sizing conclusion. **Not supported:** measured downstream minimum pulse, instantaneous/reset-stopped-clock operation, receiver-acknowledged readiness, analog CDC/MTBF guarantee, dynamic PR, cold-release universal safety, active-fault recovery or global PCIe drain. The nominal allowance is not a software delay to add to a launcher.

## 4. Clock independence, initialization and retained limits

- Board `top.sv:186,1233–1245` routes global `rst_n_sys_mem` and DDR reference clocks to local memory; selected per-VF FLR is distributed through the port path, not that global memory reset/ref-clock path. `mem_ss_top.sv:110–160` derives subsystem reset from its memory reference clock/global reset;120–146,168–184 synchronize calibration-success/failure into the static CSR domain. This supports **running successfully initialized vendor clocks as an operating premise**, not proof from a signal name or a measured clock waveform.
- The preserved named accessor is DFL feature type0/id9 under PF0. Bound `drivers/memory/dfl-emif.c:19–24,60–70,118–119` performs one64-bit status load at its kernel-bound feature base+8 and extracts low bits0/1. Current static `mem_ss_csr.sv:43–46,207–214` keeps those two `cal_success` bits at the low end of its RO status. The historical accessor source/module receipts support this semantics; **fresh module-note/file identity, feature routing and both `inf0_init_done=1` / `inf1_init_done=1` observations are still needed for the intended new-boot operation**. Historical dfl_dev.5 numbering is not assumed current.
- These accessor reads are static hardware MMIO through a named driver, not cached RAM, and are a later parent operation—not executed here. They do not establish a reset pulse, present application reset/freeze, physical clock measurement, all-bank data correctness or absence of calibration failure. The retained driver's `cal_fail` bits8/9 disagree with this two-channel RTL's2/3 packing; do not use those accessors as a failure-free gate. Generic bridge `state` is likewise not application readiness.
- Preserve accepted current reset findings: joined-reset **1771CLRN/1081SCLR/513ENA** (`tq.drc.signoff.rpt:2928–2938`); reset-chain heads bank0/sys/bank1 **119/19/7**, not serial hop counts (`2664–2673`); joined-reset recovery **0.667ns, No SDC Exception**, bank0 recovery/removal **0.667/0.161ns** ([review30](../fim24-caps03-sta01/diagnostic-reset-review30.md):39–41). Numerical timing does not alone establish operation sequencing. The16 ignored reset-identification targets retain their accepted Lost-fanout removal disposition; no inferred sixteen-head fitted defect or noprune repair is added.
- Preserve CDC73's precise FIFO scope, setup+.002ns and zero hold/MPW limitations, disclosed unwaived static signoff/DRC findings, and the four named electrical dispositions. This reset review neither clears nor reopens those accepted/scoped findings.
- `pr_freeze_to_afu_in` passes through the wrapper's crossing with `INITIAL_VALUE=1`; unused/swept freeze logic is not a readiness or drain certificate. **No concurrent PR and normal idle/inactive freeze** remain operating premises. Do not invent a new freeze acknowledgment or pre-enumeration AFU CSR.

## 5. Minimum fresh operation binding and stop boundary

The finite remaining facts belong to the parent before reset-capable VFIO acquisition/enumeration and first AFU access—not to another universal reset-proof campaign:

1. **New deployment and boot:** bind accepted actual SDK program18/activation/reboot receipts, exact migrated artifact/interface identity, and boot `3e2d2060-d6c0-44b5-a269-1adf1e450041` or a separately reviewed successor. Application UUID remains `d48dde9f-f551-578d-8bb0-69483ac95ec6`; it does not replace static FME identity. Readback54 is a prior receipt, not an indefinitely fresh ownership/readiness snapshot.
2. **Exact target/lifecycle:** create/bind only PF0's selected application VF from actual current `numvfs=0`, with reviewed autoprobe/isolation procedure; rebind BDF, PF/VF links, PCI IDs, singleton group/node/permissions and literal `reset_method=flr\n`. Keep PF0 DFL and PF1 non-VF BMC roles. Verify actual loaded VFIO/DFL/accessor objects against the retained source/module closure. No sysfs/manual reset, reset bypass, bus fallback forced by PF rebind, PR, BAR scan or UUID sweep is inferred.
3. **Normal-idle premises:** fresh empty holders/maps/D-state/errors and no ACTIVE/UNKNOWN card owner, concurrent writer/PR, uncertain DMA or kernel work; no application transaction since new boot before first use. Both banks must successfully initialize, memory resets be stable/deasserted, and relevant clocks run. Fresh reads of the two verified named initialization accessors must precede VFIO open/enumeration. These values support the initialized-clock premise under approved vendor semantics; do not infer an asserted waveform or add a sleep from them.
4. **Finite source/runtime bindings:** retain §6's actual compiled reset/wrapper/clock/report basis; recheck the exact reusable host ELF/SIF/Apptainer/config/loader/kernel pins recovered in ledger31 and retarget boot/image/source/run identities in fresh exclusive orchestration. Historical consumed entry/live21/live02/preflight/bind receipts are provenance, not new authorization. `fpgaEnumerate` may open/read/close, acquisition can FLR, and release is reset-capable; an argv without an explicit reset is not a no-reset operation ([VFIO-RESET09 §23–38](../caps01-runtime-readiness01/VFIO-RESET09.md)). Its old hold/permission text is historical and is not reinstated as a new gate.
5. **Normal return only after finite accountability:** successful supported reset lifecycle and source-decoded identity/capability/extent checks remain required. Successful enumeration/timer response alone is insufficient. Existing fresh retirement/data/guard/completion/lifetime checks permit normal release only when obligations are accounted for; UNKNOWN/post-GO uncertainty retains the original application, namespace and buffers. No auto reset/retry/kill/release on uncertainty and no global-drain claim.
6. **Exact existing warning disposition:** retain only `vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway` under [ERRATUM-ACCEPTED25](../caps03-runtime01/ERRATUM-ACCEPTED25.md). It is a warning-only policy exception, not reset-completion success, measured zero pending traffic or permission to clear/suppress/bypass. Different BDF/message, later FLR-completion timeout, AER/IOMMU fault, unexpected response, data/guard failure, remaining owner or UNKNOWN execution stays failure.

**Decision boundary:** no intrinsic unsupported sequence gap was found in this fixed normal-idle source/report basis. The concrete not-yet-satisfied conditions here are **fresh per-boot VF route/module/ownership/runtime bindings and both named EMIF initialization observations**, plus parent admission of the exact next operation. Until supplied, this report does **not** permit first AFU/VFIO access. If an actual binding differs or initialization/reset fails, stop before AFU access and resolve that precise difference; do not infer a need for a new FIM, speculative reset probe or broader cold/PR/active-transaction proof. All five migrated hardware fronts remain unperformed; none is closed by this report.

## 6. Finite verified evidence bindings

### Actual primary reset-path source bytes

Verified **14/14** primary source files against selected Work24 static admission (`W24`), prepared STA input inventory (`P15`) or selected external-assignment/export bindings (`I24`). `C`/`P` are the source prefixes defined in §2. Counts describe file checks, not physical registers. Static admission digest matches its captured admission-metadata11 receipt.

| Source | Binding | Bytes | SHA256 |
|---|---|---:|---|
| `C/common/flr/flr_rst_mgr.sv` | W24 | 8698 | `72dae03e3f1b488e25cebf6a504101a018a78ffc63a07265230d1c711b17c1de` |
| `C/common/lib/sync/fim_resync.sv` | W24 | 3752 | `892c8577bdec7dbb7608f19291f08c7b1d937dd42a0eed9d03835f67e1b5724b` |
| `C/common/lib/sync/ofs_std_synchronizer_nocut.sv` | W24 | 5404 | `058f48af60ab74d50a297b9d4b84ae09f90317bc5a5066e8231ca03b7e7e733a` |
| `C/common/lib/sync/fim_dup_tree.sv` | W24 | 1199 | `c9481b8534e4e200e0ff43aa1a44375ee5a3e58598a40364610b6860deb518ae` |
| `C/fpga_family/agilex/port_gasket/port_gasket.sv` | W24 | 15562 | `7d38322cecdb120047a24603180d95ca69448522469d1ac79abaf8450eaed3ec` |
| `C/fpga_family/agilex/port_gasket/pr_slot.sv` | W24 | 13410 | `91f3645129c9865a9f3750f60e43a3e56f61879d42dd098dd751fee69d4ceebc` |
| `C/fpga_family/agilex/port_gasket/afu_main_std_exerciser/fim_compile/afu_main.sv` | W24 | 18198 | `530481dc6604fb5cbc1df983dd5f91ae37b02c2f981e7b35e25f24cd117069d5` |
| `C/fpga_family/agilex/port_gasket/afu_main_pim/port_afu_instances.sv` | W24 | 9845 | `afa164f17b5b89cab5020d1dc5add8df4c9d51ae56ec62877712f19eb51059e1` |
| `P/base_ifcs/clocks/ofs_plat_std_clocks.sv` | P15 | 7056 | `1039a81e48ee3ae46625cea1602c722d6d3b223b3a9663622dc91811cb4f5ee3` |
| `P/base_ifcs/clocks/ofs_plat_merge_resets.sv` | P15 | 777 | `2c298aff3e810aae1c8cf320386bf461f81baa8640d83de67cc9f4db7f597174` |
| `P/utils/prims/ofs_plat_prim_clock_crossing_reg.sv` | P15 | 3399 | `a65022ab1b5493d178c969e44a04d55c72dcabe62cd897a605ed85673355c024` |
| `ofs-agx7-pcie-attach/src/board/ia840f/top.sv` | W24 | 70433 | `6061a38dd44ed4ae935f3b0ee89a664139205446b94a441ea384e921b7be0a9d` |
| STA `completion24-readback/external/14-ia840f_ahls_memory_reset.sv` | I24 | 866 | `a1593e6a642bd4d6595859ced76749658589b2154a5fcd835826e59b5ef9b8e6` |
| STA `completion24-readback/external/15-ofs_plat_afu.sv` | I24 | 13078 | `faab025c63204d16ef5fe93614e53afafb7682ee53bab4e04ee6b09bc4c65beb` |

The external compiled paths are respectively `/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_persona01/prepare01/afu_sources/afu/ia840f_ahls_memory_reset.sv` and `.../afu/ofs_plat_afu.sv`. `src/RTL/ia840f_ahls_memory_reset.sv` is **not** the maintained path: it is `afu/ahls_memory/pim/ia840f_ahls_memory_reset.sv`, byte-equal to I24. Maintained `afu/ahls_memory/pim/ofs_plat_afu_completion.sv` hashes `20b34e61d4bd6d88e75085203e700492a502801f27a53687028927df8a054134`, not I24: the full textual diff is exactly `.COMPLETION_SUPPORTED(0)` → `(1)` at42. The reset/clock/join wiring is identical. Review uses the **selected accepted compiled `(1)` bytes**, never silently treating the maintained whole file or stale “not deployed” comments as the image binding.

Supplementary source checks: `C/common/port_gasket/port_reset_fsm.sv`7275bytes/SHA`fa7210a352b360a7a6fb1feba39e4e01c3f06dcf2b9183958a8bd9cffe6fdedc`; `C/fpga_family/agilex/mem_ss/mem_ss_top.sv`12615/SHA`b9b0deb0582d554cb2178ed4ee090c088d9841951b19d1223cd4ca96bd9498a1`; `.../mem_ss_csr.sv`7455/SHA`df2a7b23ec4d7e5ca25679025dbc6d8420afdecb289fd9b5ef4eb6bf68bd834e`; all match W24. Historical captured `qualification/caps01-runtime-readiness01/files/dfl-emif.c`7572/SHA`1051ecd48e7e40f8829781af75e0102f872591bdf5bc9d81469d2f9f17aa7649` matches `source01-result.json`'s actual driver source member. Historical module pin is `a4c380d2ce62d75e198ea9f56eb153cb6140c4ab26d7099af4104fedea065aa9`, GNU build ID`61c6d0685e6cd38c270c840f6e31641d5b26f877`; these are **not fresh loaded-object assertions**.

### Native/report and authority-record digest index

Only the selected finite corpus was reverified, not an exhaustive re-audit of every prior capsule. Freeze27's declared204 files equals its actual204 entries. Selected sources/reports below match its pins or index24's explicit reused-report bindings. Postboot's two selected members match deployment-freeze55; its declared21 equals actual21.

| Repository-relative object | SHA256 |
|---|---|
| `qualification/fim24-caps03-sta01/actual-result-freeze27.json` | `92fdf20b9ef8413426dc83bc994c988a8917582998bfda5d2fabd81e5ef0d8e9` |
| `qualification/fim24-caps03-sta01/stage15-readback/prepared-inputs15.json` | `2a051dea91cfef3f808928a1cf2bd12c6bd868d9c04b1b79c17a845e2de36e2f` |
| `qualification/fim24-caps03-sta01/completion-index24.json` | `fabb8e3645c66e3d2831054ea69b4791bd95548b8c0a315ec1877743d7884d0b` |
| `qualification/fim-build-24/compile-inputs.admitted05.json` | `99820e60694b59639a5f542f0a8b70320015462a8d9d74c4a3fb103a6d2e480f` |
| `qualification/fim-build-24/admission-metadata11.json` | `6270ae448a3797a4dd7a8ab6c812f5cf12a51c788f453372f4091bccfbc35987` |
| STA `completion24-readback/design/hw/afu.qsf` | `c69f35bf04f78ef8a14b3e181bac49c4c870b591caa5f12a45fd8070ec656cfa` |
| STA `completion24-readback/reports/clocks.rpt` | `c4525e78fca5f95d5fe26ec4d2efb9efac8a6e2d57dcf4d554212d2ddc24cac4` |
| STA `completion24-readback/reports/ofs_pr_afu.sta.rpt` | `3c6ca09ebcdda327ba995ae5ded38d9a7b972361677760a161ffd0c519e4bf4f` |
| STA `completion24-readback/reports/ofs_pr_afu.tq.drc.signoff.rpt` | `854532c0f7a3fa1c6ab6f525098dbecf6509492d0a1ba70da850e4fa9e8448e2` |
| FIT `completion30-readback/reports/ofs_pr_afu.fit.rpt` | `4d98f1b25144b6c13a4c62975dd695e045bf394002e5ef75e9dd564a6a0bc8cb` |
| FIT `completion30-readback/reports/ofs_pr_afu.fit.retime.rpt` | `04ff42b6aad03d0989c018939f8b6e8470db4bd165e110f2cb2b7537d9c5def9` |
| `qualification/fim24-caps03-physical01/FIT-ACCEPTANCE38.md` | `168ba1bfc33df0fc1ddbad6defca8b4e7a6b2422fbdd43eeb205ede868462fff` |
| `qualification/fim24-caps03-sta01/NUMERICAL-ACCEPTANCE32.md` | `d0184137067d38d46f1858f4a8faaa51cfda203fcac496424bd9b80b9584e12d` |
| `qualification/fim24-caps03-cdc03/CDC-ACCEPTANCE73.md` | `14d8068020795cf26f2bf67d73bd375bf8e624757bf2cf87e3f587cef55ea8b3` |
| `qualification/fim24-caps03-sta01/reset-entry-basis33.md` | `b1fd0e68b9da912513c2e709c02c8ebb1b33a2d430f71db59fe5d4612ded19eb` |
| `qualification/fim24-caps03-flash01/hardware-reuse-ledger31.md` | `32393e6f21604b5929536e60a5088f977638f5592b6446574e70fff0df629f05` |
| `qualification/fim24-caps03-flash01/deployment-freeze55.json` | `ea9b36a4eba72e4627342054f53460c923ff89092a303978d3fbc2f09a28b45a` |
| `qualification/fim24-caps03-flash01/deployment-result-review56.md` | `25785f8a15e9056a8244c5231b63a7197c5b4a6e36fe0fa0a21188fa5243f250` |
| `qualification/fim24-caps03-flash01/postboot54/index.json` | `776221abfb650da62093ab8d4757336dded627a3e672ed0c7138e7a44018c23f` |
| `qualification/fim24-caps03-flash01/postboot54/readback/postboot-result.json` | `da1c6f90f665862136381228b5a1044b9b3aa96417ddba1f45274f6269bbba13` |
| `qualification/caps01-runtime-readiness01/source01-result.json` | `7d9fabcacd7d4c7a1ce13052c7c6243c4c4ac6a1fd3eb28863229b46fbb59257` |
| `qualification/caps01-runtime-readiness01/accessors02-result.json` | `91cd26f7b9aad66585c1a7154fb86686791cea18b83edc16d943a1fa7520ba4b` |
| `qualification/caps03-runtime01/ERRATUM-ACCEPTED25.md` | `13dacab771d08a7d974032269db6436bf3f048612b0793f6f075fbea5e5db36d` |

`STA` / `FIT` prefixes in the table expand to `qualification/fim24-caps03-sta01/` / `qualification/fim24-caps03-physical01/`. Native reports were read as ordinary captured files; none was regenerated or queried through Quartus. Approval records/historical binaries are reuse provenance only. **FINAL: bounded normal-idle sequence supported; fresh operation premises still pending; no hardware execution or migration closure granted.**
