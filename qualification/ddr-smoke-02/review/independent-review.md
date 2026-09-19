# Independent bounded DDR smoke review

## Verdict

**Changes required: one reproduced false-PASS defect in the log parser. No accepted-review.json issued.** `ready_for_build=false`. No HDL compilation, elaboration, simulation, vendor generation, or remote operation was performed in this review.

**Reset decision is resolved for the next bounded experiment:** accept the current initial-reset stimulus as an explicitly assumed startup experiment, not as a source-proven vendor reset protocol. Encryption is not an additional approval/monitoring blocker. After the parser correction and hash rebinding, this review finds no other static blocker to the already-authorized short full-DUT experiment.

## Blocking defect R1 — vendor model errors can pass

`run_smoke.py:10,14–16,53,84` only recognizes bare Error:/Fatal: at the beginning of a line (optionally following `#`), Questa `** Error:/Fatal:`, and selected fixed failures. The actual accepted vendor rank model emits timestamp/instance-prefixed diagnostics:

- `ddr-model-repair-01/artifacts/ed_sim_mem/altera_emif_mem_model_core_ddr4_191/sim/altera_emif_ddrx_model_rank.sv:1379,1388`: `[%0t] [DWR=%0d%0d%0d]:  ERROR: tRCD violation ...`
- Same file, lines 1855, 1885, 1989, 2031, 2038, 2066, 2085, 2091: timestamp/instance-prefixed `Internal Error:` diagnostics.
- The second model has the same common source, independently hash-checked here.

Executed the actual Python `accepted()` function, without calling main or any child tools, using explicitly synthetic completion markers plus the following lines:

| Synthetic diagnostic added to otherwise passing fixture | Actual accepted(0, text) |
|---|---|
| `# ERROR: Invalid burst type mode 2 specified!` | false |
| `# [100] [DWR=000]:  ERROR: tRCD violation (READ) on bank @ cycle 1` | **true — incorrect** |
| `# [100] [DWR=000]:  Internal Error: Expected READ command not in queue!` | **true — incorrect** |

These `$display` diagnostics need not force a nonzero simulator exit. Thus exact scoreboard markers and rc=0 are insufficient, and both the step checker and final acceptance can miss real model errors. This violates the independently accepted model's explicit no-vendor-error requirement.

**Concrete correction:** broaden the shared error detector to recognize case-insensitive word-boundary `Error:` and `Fatal:` anywhere in a diagnostic line, including timestamp/DWR and Internal Error prefixes; retain DDR_SMOKE_FAIL, design-load and license checks. For example, `(?i)\b(?:error|fatal)\s*:` as a shared diagnostic alternative covers these observed formats without falsely rejecting the vendor informational `Parity Error Bit:` / `Number of Errors:` lines. Add negative fixtures using the exact vendor prefix formats above, for both ERROR.search and accepted(), along with existing Questa, timeout, missing-marker and duplicate-marker fixtures. Do not edit vendor models or waive their diagnostics. Recompute the runner hash and supply the corrected package for narrow re-review before execution.

## Reset acceptance and limits

Visible source establishes wiring, not protocol timing: `evidence/mem_ss_inner.v` connects the reset controller clock to EMIF0 ref_clk_out and reset_n to EMIF0 pll_locked, with independent local_reset_req/local_reset_done pairs for both channels. `evidence/reset_wrapper.sv:58–77` forwards those pairs to NUM_FM_EMIF=2. The implementation is encrypted.

`tb_mem_ss_smoke.sv:308–319` holds app_ss_rst_req=0 throughout; app_ss_cold_rst_n starts low and goes high after 100 falling reference-clock edges. At the actual 1 ps precision the reference period is 30 ns and the pulse is 3000 ns. There is no readiness wait before deassertion and no requirement to observe acknowledgment low. Consequently, this does **not** establish that a cold-reset handshake actually occurred after PLL lock, nor a minimum pulse or vendor-required ordering. ss_app_rst_rdy is connected but unused; no warm-reset request is made, so its meaning need not be invented to approve this startup experiment.

Traffic starts only when both exported user resets are exactly high, both calibration successes are exactly high, and cold acknowledgment is exactly high. This is an observation-based startup gate, not proof that reset sequencing is compliant. Calibration-fail assertion terminates the run; once enabled, each channel checks reset/success/fail with four-state comparisons on user-clock edges. Cold acknowledgment is not subsequently monitored. The experiment can therefore support only: this finite initial stimulus permits startup and two-channel readback under these models. It cannot support hardware reset qualification, reset-under-traffic correctness, readiness-handshake compliance, calibration qualification, or general DDR correctness.

This is scientifically defensible within the approved scope because stimulus is explicit and finite, no traffic precedes observable readiness, there is no forcing/calibration bypass added by the testbench, actual DUT/model paths are used, and failures/timeouts remain results rather than reasons to silently extend bounds. Startup timeout may mean the stimulus is unsuitable; it is not proof the hardware is defective. Do not require new generic monitoring or incremental user approval merely because the reset implementation is encrypted.

The current runner's `reset_sequence_source_accepted` field is a legacy gate name. Any later accepted record must explicitly state that its true value accepts the **source-bound bounded experiment**, not source-proven reset protocol, with a separate false protocol-proven assertion/clear reason. No true execution-gate assertion is issued while R1 remains.

## Remaining static review results

- Independently parsed actual captured `evidence/mem_ss.v` declarations and testbench connections: all 128 DUT named ports match, with correct widths. All 32 model connections agree with actual model declarations and DUT directions. ALERT_n is correctly a model-driven wire, not a testbench procedural driver; bidirectional physical pins are nets. No added model driver conflict was found.
- Read the full testbench. All AXI stimulus inputs are initialized; AW/W/AR are independently held until handshake, sampled on rising edges and retired on falling edges. B readiness waits for AW and W; R readiness waits for AR. Legal single-beat INCR, 64-byte size/alignment, full strobes, WLAST and expected channel-distinct IDs are used. Both writes precede both reads per channel, so address aliasing is exposed. Both channels run, check all 512 returned bits per beat, response/ID/last and accepted payload X/Z, and must complete before PASS. This is not an exhaustive AXI protocol checker.
- No obvious SystemVerilog syntax blocker was found by manual inspection; sized casts such as `9'(...)` and `34'(...)` are legitimate SystemVerilog. No HDL parser/compiler was run, so this is not compile acceptance.
- Independently matched the first 124 manifest commands exactly to the prior captured DUT closure, and both ordered nine-command repaired-model closures exactly to `evidence/source-closure.json`. All 142 command source paths normalize to hashed manifest inputs and use declared libraries. All 18 repaired-model input hashes independently match local accepted artifacts. Recompiling common byte-identical model units into the shared library does not create a second connected model instance.
- Manifest contains 143 source inputs plus five distinct-basename HEX inputs, 27 design libraries and 20 device-library mappings. The runner includes the generated setup's unconditional simsf_dpi.cpp compilation before IP sources and the testbench; its source is hashed. Device-library existence/loadability, C++ DPI build/link and encrypted-IP load remain actual experiment outcomes, not claimed verified here.
- Reference clocks use the captured nominal 33.333 MHz requirement and each channel uses its own exported user clock/reset. Captured final-verification2.txt records effective fast-simulation=1 / abstract-PHY=0 and 148 unchanged inputs. This is prior captured remote evidence, not a fresh remote validation. The runner checks those manifest inputs before and after execution; no generated input was edited here.
- Bounds remain 4096 user cycles per transaction, 500 us startup, 1 ms simulation watchdog, 120 s elaboration/run wall cap, 600 s total compilation with individual 120 s caps. Stopped clocks are caught by global simulation/wall bounds. No implicit extension to detailed calibration or long traffic is accepted.
- Runner checks accepted hashes and monitored session, requires fresh owned output, uses isolated mappings/license environment, copies and hashes HEX inputs, records commands/logs/tool hashes/results, kills the child process group on timeout, and requires rc=0 and exact once-only completion markers. It propagates failures and rejects mismatched before/after inputs. Tool hashes are recorded, not compared to a pinned executable allowlist; this is trusted installed-tool execution, not OS containment. R1 is the concrete blocker in the otherwise useful error/exit contract.

## Reviewed package identities

| File | SHA256 |
|---|---|
| tb_mem_ss_smoke.sv | dfd920e3b310011cbd09e91d74578c2757683f08aed71b59617237f06edd0ad0 |
| run_smoke.py | 9bb68bdaaa3b62e86331ed3b695a40864a42c083e38113def30b68d2e0c18677 |
| manifest.json | 418b6ddabd2733fe8ca68f10dd6a3b6a024977180ad1a340ca89ac71082490fe |

Only review-owned files were created. Harness, runner, pending record and generated inputs were left unchanged; no commits. The actionable next step is the small parser correction and synthetic regression, followed by a new hash-bound acceptance—not another reset-research or approval detour.
