# Fast native clock-repair route — design review

## Recommendation

**GO for one fresh candidate-only Work14 STA pilot; no baseline rerun and no prerequisite completion of experiment04's generic coverage framework. NO-GO for blindly wiring the unmodified guard02 verifier after full SDC: its insertion-snapshot comparison has a concrete integration mismatch to resolve first.** This is a narrow design recommendation, not actual-package SPEC/QUALITY approval, authorization, source promotion or permission to fit.

Reuse diagnostic03's accepted ORIGINAL-SDC result and Work14 identities. Its `RESULT-ACCEPTANCE.md:15–22` establishes the 80-clock baseline, absent C, upstream-M association without an explicit O/K clock definition, and the known32 native mappings. The empty clock-filtered fanout and 459-node conservative set need no further selector experiment. That baseline is sufficient for this pilot's limited comparisons, **not** a retrospectively complete A/B timing baseline.

## One integration correction before spending the run

Guard02 `clock-repair.tcl:139` stores `before_v2` at the top.sdc insertion point. Its immediate C-only comparison (`:152`) is appropriate. But `verify_created_v2:162` repeats that same comparison after all SDC, requiring no other clock additions (`:107–114`). Accepted diagnostic03 `result-readback01/query.log` shows:

- integration `top.sdc` read at line258;
- `bti_refclk.sdc` read later at line356;
- `bwbmc.sdc` and the internal-oscillator SDC read at lines483–484.

The locally retained `syn/board/ia840f/setup/bti_refclk.sdc:2` creates `qsfp_ref_clk`; `bwbmc.sdc:3` creates `bwbmc_fpga_max_sclk`. These and `altera_int_osc_clk` appear in the final accepted inventory (`audit.tcllist:81–83`). **Insertion state and final baseline state must not be treated as identical.** Component acceptance expressly did not exercise full-SDC placement (`guard02/spec-review01.md:23,79`).

Smallest correction: retain the insertion-time guards and immediate C-only delta, but make the full-SDC definition comparison explicitly use the pinned diagnostic03 final 80-clock inventory, plus C, while retaining the generated-C postconditions. Any necessary verifier successor is a narrow changed component requiring fresh exact-byte review; it cannot inherit guard02 acceptance unchanged. Do not overwrite the before-state with the candidate's own final snapshot, catch/ignore the mismatch, preload later SDCs, or move clock creation after `read_sdc`. No new native diagnostic or reporting framework is needed to resolve this distinction.

## Minimal trial shape

- Fresh copied Work14 fitted database and fresh exclusive attempt/report identities; reuse the existing **supervised** runner entry and process-group lifetime handling, not its legacy unsupervised entry. Preserve originals and spent attempts.
- Replace only original integration `top.sdc:35–37` with the bound helper source and `apply_v2` invocation. Source the helper once: re-sourcing resets its `created` state. Keep normal SDC ordering and every exception/vendor-SDC byte unchanged. Run the corrected full-SDC verifier after normal loading and timing update.
- Keep accepted D/I/O/M/C identities: target `clock_div2`, not `clock_div2x`; immediate master `sys_pll|iopll_0_clk_100m`; exact C ending `host_pcie.pcie_ss|pcie_ss|avmm_clock0`; divide-by-two without nominal period, `-add`, phase, PLL or seed changes.
- Reuse the known32 cell-derived buried-register collections and named T lookup from diagnostic03. Use `get_clocks -of_objects` on actual collections. Prefix all new temporaries; do not introduce a scalar `pins`, unset vendor arrays, reinterpret indexed names, or feed a node ID to collection iteration.

## Essential observed-result checks

1. **Native integrity:** exact prepared inputs and actual loaded SDC paths; positive creation, verification and trial-completion records; native/effective success, confirmed owned-process termination and original-preservation receipts. Required-command rejection, ignored creation, API failure or incomplete output cannot be excused by rc0. Retain warnings; warning disappearance alone proves nothing.
2. **Clock definition:** insertion guard observes absent C/no explicit O/K definition and exactly expected upstream M. After full SDC, compare every original clock's name/type/period/waveform/targets and applicable generated properties against diagnostic03, with precisely C added. Compare Tcl list values semantically while preserving raw text; do not round values or normalize identifiers. Require exact C source/target/master, ratio, non-inversion and unshifted divide-two period/waveform relation. Guard02's integer2/1 ratio expectation remains a native hypothesis: saved `get_clock_info.txt:10,21` describes base-relative properties. Preserve and reject unexpected representation rather than improvising a conversion or nominal 50-MHz clock.
3. **Propagation:** require exactly C at O, each of the 32 exact mapped receiver registers, and T. Emit actual counts before assertions. This establishes selected receivers, not all459 nodes or full C-domain coverage.
4. **Native constraints and FIFO evidence:** retain global `report_sdc` and `report_sdc -ignored`, plus numerical net-delay/max-skew reports at each selected enabled corner, with explicit corner identities. Reconcile the eight **net-delay assignments**, not eight endpoints, identified in `native-mapping-disposition03.md:104–115`: pointer→receiver and receiver-chain→same-chain for each of the four FIFO groups. Keep each assignment's selectors, actual matching edges/endpoints, clock periods, Required/Actual/Slack and SDC provenance. Check the destination-period-derived net-delay and source-period-derived pointer-skew requirements. Missing rows, `Invalid clock`, ignored assignments or nonnumerical bounds are not repair success. Negative numerical slack is useful evidence, not a pass and not a reason to discard the reports.
5. **Finite completeness:** preserve existing 256-clock/4096-node/16-corner ceilings and supervised 1800s, 64GiB address-space, 128MiB/file and 1GiB-report limits. Saved help supports `report_net_delay -nworst 20001` per assignment and `report_max_skew -npaths 20001 -detail full_path` per latest/earliest group. Inspect saturation for each relevant assignment/group, not only an aggregate return; report truncation blocks numerical completeness. Do not add generic adjacency or endpoint-pair enumeration to this pilot.

## Scope amendment and next decision

The new trial specification must explicitly replace the former **two fresh serial A/B runs and exhaustive comparison** prerequisite for this pilot with **reuse of accepted baseline evidence plus one candidate run and limited native checks**. Preserve the old decisions as history; do not claim their broader acceptance criteria have been met. Joe's speed correction supports this reduced experimental scope, not a source/exception or safety waiver.

Unchanged exception bytes can gain new effect when C exists: top.sdc:49/51 asynchronous groups and :57–60 multicycles are not semantically inert. Preserve them, give dominated multicycles no safety credit, and do not advertise full exception precedence/CDC coverage from these reports.

A successful limited result should go directly to independent review of whether the exact constraint correction justifies a **new changed-SDC fit**, rather than another unchanged retry or an automatic return to framework construction. It does not itself authorize that fit or promote maintained source. Final standard all-corner timing, CDC/DRC, unconstrained-path and hardware qualification remain unchanged, including Work14's independent EMIF1 hold issue. `ready_for_build=false` in this review.

**Work performed:** local source, accepted-result and saved-help inspection only. No fixture, native/help, SSH, hardware, git or other execution; no authorizations or source edits. Only this report was written. The verifier's insertion-versus-final snapshot mismatch is the concrete issue found; actual prepared candidate bytes remain unreviewed.
