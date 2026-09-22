# Parent disposition — narrow PCIe clock-repair hypothesis

**Source recommendation accepted for constructing an isolated experiment. No repaired-clock native result, maintained-source promotion, constrained fit, timing pass or hardware acceptance.**

Parent read [independent research](exception-disposition-research.md), SHA256 `c2f7424e28fc91e4a7631f4a0c8c60cfb9af37825f0904143f7824b17843747f`, and consumed the independent [completed fitted-query result](../fim-build-14/pcie-postfit-02/RESULT-ACCEPTANCE.md), published at `686223f0638d37cef8b62410d743030950dd9bfb`. Parent reverified all five maintained source identities from the previous binding receipt; decoded and hashed generated `pcie_ss.sdc` to `b5fa069c1876031a8f63c1198f98b99dfabf5e7ad0cb748e5614bc235e04c265`; checked its divide-by-two command191–192, intentional Lite↔AVMM async policy218, Lite/AVMM↔rx_ch15 cuts290/299, and destination-period-derived FIFO checks628–641. This is a targeted cross-check of the independent research, not a claim of a fresh vendor-internal audit.

The minimal test is one generated clock on the actual `clock_div2` pin, sourced at actual `inclk`, with existing CSR master. Retain current exception bytes for the first A/B comparison and give dominated multicycles no safety credit. Full changed-transfer/exception coverage and numerical FIFO evidence remain empirical gates. Native negative timing on the formerly unconstrained fit is useful evidence and must not be waived or treated as disproving a correct clock binding by itself.

## Installed API discovery completed

Both finite no-project STA help captures completed native/outer rc0 in owned tmux, with installed launcher/native hashes checked. They opened no project or timing netlist and performed no device access:

- [API batch01](api-help01/verification.json): `%38`, result archive SHA256 `65139eb0317177318b4b56c7e37e6bb0458b344b9ddcec967ee35cf2d453a193`. Full raw log retained;29 command-help blocks, `report_design_assistant` unsupported in this context.
- [API batch02](api-help02/verification.json): `%39`, result archive SHA256 `f0f6032c5fd1aaba72001bb3eb6d4cae47eacfd72f8f7e3eeb3dd558fedf90c2`. Collection/escaping and constraint-check help; `get_collection`, `index_collection`, `report_drc` unsupported in this context.

`get_clocks -of_objects` explicitly returns targeting or driving clocks. `report_clock_transfers` includes clock-cut status but does not subtract path-specific false paths from ordinary transfer counts. `get_timing_paths -false_path`/`report_timing -false_path` exposes normally cut **constrained** paths without removing cuts; use structural adjacency and unconstrained reports for the baseline's missing-clock paths. `report_exceptions -report_clock_groups` exposes group precedence; `-npaths` defaults are samples unless explicitly bounded and completeness reconciled. `report_net_delay` without `-nworst` reports every matching edge per assignment. These specific semantics are retained in the [experiment specification](experiment01/SPEC.md).

The unsupported Design Assistant command names are not replaced with invented options. Documented `check_timing` is useful constraint validation, not full DRC sign-off. Original High-rule findings remain open.

## Execution boundary

Experiments01 and02 are preserved with their Q1 and S1 rejections. [Experiment03](experiment03/ACCEPTANCE.md) completed exact prepared-byte SPEC→QUALITY→parent acceptance. Its [baseline](experiment03/baseline/RESULT.md) subsequently ran once and failed native/effective/outer rc3 at a load-cardinality assertion before emitting the count; termination and original-tree preservation are confirmed. Candidate remains unissued. [Failed-result evidence is independently accepted](experiment03/baseline/RESULT-ACCEPTANCE.md); [fanout diagnosis](fanout-diagnosis01.md) supports preparing one fresh unchanged-SDC diagnostic comparing exact pin/keeper collections, not choosing a collector without measurement; no repaired-clock result exists. Changed query bytes require fresh preparation, reviews and single-use issuance. No unchanged full build, hierarchy rediscovery, exception removal, hardware probe or renewed blanket-approval request is warranted.
