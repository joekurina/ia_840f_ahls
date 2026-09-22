# Work14 fresh A/B clock comparison Implementation Plan

> **For Hermes:** Use subagent-driven-development for independent SPEC then QUALITY. The parent implements and executes; subagents do not perform workstation actions.

**Goal:** Compare original Work14 constraints with exactly one guarded modern divide-by-two clock repair, without refitting or touching hardware.

**Architecture:** Two fresh equivalent fitted copies; original A must complete before separately result-bound B can run. Retain conservative native fanout collections and independent global/new-clock coverage. Preserve originals, every existing exception and all spent evidence. [Accepted native mapping](../fanout-diagnostic03/RESULT-ACCEPTANCE.md), [source disposition](../native-mapping-disposition03.md).

**Tech Stack:** Existing Quartus26.1.1 STA/Tcl APIs, Python3.9-compatible supervised preparation/runner/gates, local libtcl8.6 inert fixtures. `ready_for_build=false`.

## 1. Add the corrected guard and regress it

Create `clock-repair.tcl` preserving all original helper functions byte-for-byte and adding `apply_v2`, `verify_created_v2` and scoped supporting functions. Create `test-guard-v2.py` with distinct object/collection mock handles. First reproduce the old rejection when O is driven by M but no definition targets O/K. Require the new entry to accept that state, reject preexisting definitions/names or unexpected associations before creation, and preserve exact creation grammar without -add. Exercise exact target/source/master/type/ratio/period/waveform checks after creation, plus rerun rejection. No vendor invocation.

Run `python3 -B test-guard-v2.py` from this directory, initially failing for the absent successor, then passing. Save both receipts, not synthetic vendor output. Native ratio/property representation and actual insertion-time state remain experimental until observed; reject unexpected representations rather than weakening checks.

## 2. Replace invalid comparison collection assumptions

Create fresh `query.tcl` retaining original functions as provenance where practical and selecting a new main. Keep actual unfiltered O/K collections, counts-before-asserts, full459-name baseline expectation and conservative union; remove transformed-name round trips. Reuse cell-derived known32 mapping. Require C propagation only at established32/T and report all others. Use type-aware global clock inventory, clock-directed C coverage, structural adjacency and exact A/B set differences. Preserve bound roots/finite limits. See source disposition sections2–3 for exact predecessor lines and API references.

## 3. Collect and assess complete bounded reports

Retain all corners; global clock/transfer/exception/UCP/check_timing reports; full affected and C-directed timed/cut/data-delay endpoint pairs with clock/edge partitioning. Record per-query/per-exception/skew/MPW saturation independently; sampled worst20 remains sampled. All eight invalid-clock FIFO assignments need matched sets, numerical Required/Actual/Slack and source/period provenance. Missing details are comparison-INCOMPLETE, not a pass. Keep256clock/4096node/50000adjacency/16corner/20001path and inherited resource caps. No new arbitrary scanner, waiver or DRC replacement.

## 4. Prepare exact runnable A/B packages

Reuse accepted supervision/preparation mechanisms, retarget every Python/Tcl/report root, add only required manifest inputs and candidate SDC block at original top.sdc35–37. Baseline SDC unchanged; candidate substitutes source of this bound helper plus `::ia840f_clock_repair::apply_v2`; all exception bytes unchanged. Preserve native/full-SDC loading. Extend inert entry-routing/guard/report-contract/candidate-gate tests, validate actual missing-authorization entries during ordinary-file preparation, export/read back complete packages, then SPEC→QUALITY→parent acceptance. No issuer or authorization while drafting.

## 5. Execute only reviewed exact attempts and consume evidence

Separately inspect an actual one-use baseline issuer, publish the accepted package milestone, run bounded A once, inspect its status/termination/preservation and completeness before result-bound B issuance. Independently review actual A/B results; separate clock-binding success, numerical timing status and missing coverage. Old experiment03 candidate stays blocked. No source promotion/refit/hardware/EMIF-hold waiver. Commit only independently accepted gates with explicit files and remote readback.
