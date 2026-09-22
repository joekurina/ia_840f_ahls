# Clock-trial02 — narrow final-boundary correction

clock-trial01 was prepared but NEVER issued or executed. Its SPEC PASS was not parent-accepted because parallel fast-route-review.md found a concrete integration defect. Preserve every frozen predecessor byte.

Diagnostic03 query.log258 loads top.sdc;356 loads bti_refclk.sdc;483–484 load bwbmc.sdc/internal oscillator. These create legitimate clocks included in the accepted final80-clock inventory. guard02 before_v2 is an earlier insertion snapshot. Comparing final state to that snapshot is incorrect.

The complete accepted guard02 helper remains a byte-identical prefix. apply_v2 still observes actual insertion state, creates only C, and enforces immediate C-only delta. Add verify_created_final_v3, copying every generated-C property, precision, count, propagation and no-retry postcondition from verify_created_v2. Its sole semantic change: compare the final snapshot with the externally pinned final80-clock baseline through the existing semantic inventory comparator, rather than before_v2. The query explicitly passes expected-baseline.tcl data, never a candidate-derived baseline. The old verifier remains unchanged and unused at this final boundary.

All other executable changes are mechanical fresh-attempt root/module/permission/buffer retargets. No altered clocks/exception policy, timing cap, hardware access, framework expansion or full comparison claim. Final native properties are still experimental; failures remain failures. New actual prepared package requires SPEC then QUALITY then parent acceptance and separate one-use issuer. No authorization supplied by this document. ready_for_build=false.
