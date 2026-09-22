# Work14 pcie-postfit-01 — independent actual-result review

**Verdict: ACCEPTED AS FAILED-RUN / PARTIAL DIAGNOSTIC EVIDENCE. Native FAILURE (rc3); diagnostic INCOMPLETE; timing NOT ACCEPTED; hardware NOT RUN.** No blocking integrity discrepancy was found in the supplied result bundle. This disposition does not turn the failed native query into a diagnostic pass or authorize reuse of its consumed claim.

## Evidence identity and verification

Reviewed `RESULT.md`, the predecessor's accepted package/reviews and parent-consumption receipt, and the actual five-file `result-readback01/` bundle. Recomputed the entire log's digest and scanned its full contents for diagnostics, emitted inventory rows and completion markers; inspected the exact native failure stack against the prepared Tcl.

| Artifact | SHA256 |
|---|---|
| `result-manifest01.json` | `80041bde83a182ba46e5c8a40e46456569a2c717cbf657c24f5ff768943e76f6` |
| `result01.json.gz` | `ffdaae298232356de12fc050486cfe6c80495c110989b04c0c8e92c77c211459` |
| `result-readback01/query.log` — 137,604 bytes, 585 lines | `f0c8dce7b70dae4b917b18fbee0987bc16b699d30461e51a75fb12ac2e03e1e4` |
| `result-readback01/native-result.json` | `5c562047ee2e24bca3d8121928acd7c4da8fdcd8fe2bfc0bc4445db4a93810b1` |
| `result-readback01/preservation-after.json` | `fd8467afa1a4f3f1edad5f0daf727e290f4e08377597b0a5f401a62e57b76750` |
| Accepted `prepared-manifest01.json` | `41cacf060bbea75bf4455cb617a5f7b295d7d8c5f78079bb5553fbc0a90ed886` |
| Accepted `prepared-readback01/candidate.json` | `5e20a7a1b2be00d53a72972cdf09fa4ab1cc93d9e330f010f69c4b0954e52776` |

All **five** result exports (`query.log`, `native-result.json`, `native-process.json`, `query.claim`, `preservation-after.json`) have exact manifest size/hash matches and are byte-identical to the decoded archive exports. File sets agree; archive batch is exactly `ia840f_w14_postfit_result01`. Also reverified all nine prepared exports and predecessor SPEC/QUALITY hashes against the parent-consumption record. No old artifact was edited.

## Execution and preservation

- Native process **15634** appears in both the persistent process record and log. Its argv and cwd match the accepted candidate: Quartus 26.1.1 STA `-t` the exact attempt01 query, in the attempt01 copied project. The log reports successfully loading the final database (`query.log:34–39`); it is not a new full compile.
- Persistent claim records runner PID **15594**, parent **15567**, start ticks **2294923**, `/usr/bin/python3.9`, exact `python3 -B .../pcie-postfit-01/run-query.py` argv and attempt cwd. Its static executable/argv/cwd fields match the candidate. This local review does not independently remeasure historical live ancestry.
- `native-result.json` records start `2026-09-22T06:48:07.148514+00:00`, end `2026-09-22T06:48:46.491196+00:00`, **native_rc=3**, and `hardware_access=false`. The native log independently ends unsuccessfully with **2 errors, 201 warnings**.
- `launch-dispatch01.json` records `@35/%35`. Parent `RESULT.md` reports runner outward rc3 and return to the shell. The five-file export independently proves native rc3; it contains no separate raw outer-shell status receipt. Dispatch exit0 is not native success. The raw native failure is sufficient and unambiguous here.
- `preservation-after.json` records **true for all three original roots**: Work14, maintained `ofs-agx7-pcie-attach` SOURCE, and original `ofs-platform-afu-bbb` PIM. The reviewed runner writes raw native status before comparing those complete inventories against its candidate-bound preservation baseline. Accept this as the captured runner's preservation evidence, not an independently repeated local inventory measurement; baseline contents and the full original trees are not exported in this five-file bundle.

## Actual partial observations

The common divider cell path is exactly:

```text
pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst
```

`query.log:496–510` establishes:

| Emitted finding | Actual value | Interpretation boundary |
|---|---|---|
| Exact `inclk` selector | COUNT **1** | One match for this exact pin selector. |
| Exact `clock_div2` selector | COUNT **1** | One match; not interchangeable with `clock_div2x`. |
| Exact `clock_div2x` selector | COUNT **0** | This exact selector did not match; not global absence of a divided clock. |
| Top `*axi_lite_clk*` ports | COUNT **0** | Explicitly top context, not internal entity-scope connectivity evidence. |
| Emitted divider cell | Type `tennm_clk_divider` | One cell row was emitted; final divider cardinality was never printed/checked. |
| `inclk` attributes | INPUT **1**, OUTPUT **0**, CLOCK_PIN **1**, `NET_ID {}` | Input `-net` is not connectivity proof. |
| Separate input fanin | `sys_pll|iopll_0|tennm_pll|outclk[2]`; FANIN_COUNT **1** | Directly emitted fanin evidence. |
| Input fanin target-associated clock | `sys_pll|iopll_0_clk_100m`; CLOCK_TARGET_COUNT **1** | Period **9.929 ns**, master `sys_pll|iopll_0_n_cnt_clk`, master source `sys_pll|iopll_0|tennm_pll~ncntr_reg`. Preserve the printed period rather than inferring an exact frequency from its name. |
| `clock_div2` attributes | INPUT **0**, OUTPUT **1**, CLOCK_PIN **1**, `NET_ID {_quartus_sta_net__53563}` | Output pin resolved before the helper failed; its clock-target count was not emitted. |

The relevant-clock filter additionally emitted `rx_ch15` with period **2.000 ns** and its `rx_pcs_x2_clk|ch15` master (`:503`). Those two filtered clock rows are not a complete design-wide clock inventory.

There are **zero emitted `DIVIDER OUTPUT` rows**, **zero `FIFO_GROUP_` rows**, and no final `DIVIDER CLOCK_INPUT_COUNT`, `DIVIDER_CELL_COUNT`, `QUERY_INVENTORY_END`, or `W14_POSTFIT_QUERY_COMPLETE` records. These are counts of emitted records, **not** zero-valued design cardinalities. All four FIFO receiver groups and output-clock association remain unresolved; the query stopped before their intended reporting completed.

## Exact failure and existing warning evidence

At `query.log:511–543`, Error **23035** states:

```text
Collection does not exist with name: _quartus_sta_pin__53563
```

The stack identifies `foreach_in_collection n $nodes ...` in `targets`, called by `targets $p "$label OUTPUT {$pn}"` from divider inspection. The output pin had already resolved. This is an observed Tcl node-versus-collection argument mismatch, not evidence of a missing output pin or failed FPGA hardware. Error **23031** at `:579` reports unsuccessful script evaluation; the terminal native failure follows at `:580–584`.

The full-log warning count reconciles exactly with the native summary:

| Warning code | Count | Evidence class |
|---|---:|---|
| 332049 | 133 | Ignored assignments with empty collections. |
| 332174 | 53 | Unmatched filters. |
| 332054 | 14 | Accepted clock-group assignments with problems. |
| 332060 | 1 | Divider register clock without an associated clock assignment. |

In particular, `:493` independently reports that the exact divider alias `...|clkdiv_inst~div_reg` was determined to be a clock but lacked an associated clock assignment; `:494` names a register clocked by it. This is valid negative clock-assignment evidence already emitted before the helper failure. It is **not** a completed output target-clock inventory, proof of the missing FIFO connectivity, or proof that a particular constraint patch would fix timing. No source-bound gate rejection or Warning125091 was found in the log. Absence of those diagnostics does not promote the failed query to success.

## Disposition and successor boundary

`RESULT.md` correctly classifies native failure, partial divider/input-clock evidence, preservation, and incomplete output/FIFO inspection. This review adds the exact selector/emission counts and reconciled warning inventory without changing the original result record. The original file's historical “independent result review pending” wording is superseded for this review purpose by this separate report, not edited in place.

The observed stack supports a fresh successor whose helper accepts a list of names, converts actual fanin collections to names, and supplies an output pin as `[list $pn]`. Preserve this attempt's consumed claim, reviews and results. Correcting that interface misuse does not guarantee the next native run will complete and is not authority to create clocks, change exceptions, refit or access hardware.

Timing acceptance remains open independently of this Tcl defect, including the existing unassigned-clock evidence and other parent timing issues. No MMIO, OPAE, programming, PR, reset or hardware test is established by this offline result. The selected OFS target and parent hardware objective remain unchanged and incomplete.

Reviewer actions were local reads, hashing, JSON/archive verification, static comparisons and full-log parsing only. No remote/vendor/hardware/source-modification/git action, gate/runner/query execution or authorization issuance occurred. Only this report and the requested successor SPEC review were written.
