# Independent clock-envelope and physical-rationale review128

## Disposition

**Accept reduction125 as an exact reduction of the captured original-fit clock-point observations, with a valid conditional event-relative interpretation. Do not accept it as a qualified clock envelope, Gmin/Hmin certificate, or timing pass.** The additive payload-before-notification candidate126 is a defensible way to obtain protocol separation without depending on a slow asynchronous control route. It is not proved necessary by the original negative conventional slack, and its added cycle is not yet a fitted timing guarantee.

The production absolute settling target remains **3.000ns**. No larger numerical maximum, minimum relaxation, constraint edit, source selection, native issuance or physical acceptance is authorized. `PUBLISH_SUPPORTED=0`.

This review concerns numerical interpretation and physical qualification. It does not accept the candidate's complete functional RTL behavior; that is a separate review. Only this document was written. Work consisted of ordinary local source/evidence reads and independent, bounded in-memory parsing, Decimal arithmetic and hashing. No project/analyzer/launcher code was imported or executed; no simulation, vendor tool, remote action or hardware access occurred.

Paths below use `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`, `E=N/qualification/caps02-afu-publication09`, and `C=N/qualification/caps02-mailbox-timing126`. `M` is the original `afu/ahls_memory/control/ia840f_ahls_observer_mailbox_csr.sv`; `M126` is the additive `ia840f_ahls_observer_mailbox_timing126.sv` beside it.

## 1. What was independently checked

Read `C/DESIGN126.md`, both mailbox sources, `E/analyze-clock125.py`, the two reduction125 JSON artifacts, `BUNDLE-DESIGN94.md`, `BUNDLE-RESULT124.md`, `bundle-semantics124.json`, the query118 source, and the cited captured installed25.1 help. The original native query118 plus supplement122 is complete; nothing here calls for rerunning it.

A data-only parser streamed the retained query118 `evidence.tcllist`, without evaluating its Tcl serialization. Its **153,059,699 bytes** hash to `b4b8f96f4a059c214f338cfc2160aba1a64181b8c6184c400bc5733d70981211`, matching the retained acquisition. The parser encountered **14,760 BPATH, 1,653,820 BPOINT and 4,465 BPOINT_NODE records**. It retained only the clock slices and small path/micro records needed for this review, not another full report artifact.

Independent checks found:

- **3,680 unique bundle pair/corner rows:** 130 request and 606 response pairs in each of five corners, totaling 650/3,030. Every stored branch subtraction, source-plus-destination sum, nominal allowance and per-corner minimum agrees exactly at the reported precision.
- **7,360 clock-branch comparisons** reconstructed from native point records agree with the JSON. Each clock slice has the expected single `utco` arrival or `unc` required marker, and ends at the register's clock-associated `cell` before that marker. Source and destination clock identities match the selected notification path.
- Every comparison has **19 common ordered named points** ending at the correct `ext_mem_if[0].clk` or `ext_mem_if[1].clk`. As an additional check beyond reducer125, all common-prefix recorded edge endpoint/type signatures agree, no node-less `re` point occurs inside those prefixes, and all compared terminal clock-cell transitions are `rr`.
- All **7,380 raw/timed capture-micro comparisons** independently satisfy `raw_total - ordinary_data_delay = raw_terminal_micro = -ordinary_required_micro`. The retained semantics124 also records exact reconstruction of all 7,380 ordinary slacks; that saved analyzer was not rerun.
- All five input hashes embedded in `clock-envelopes125.json` match the current local files.

These checks establish the arithmetic and its source records, not unreported transition coverage or silicon bounds. Decimal equality is equality of printed values, not proof of sub-report-resolution physical accuracy.

## 2. Clock-point reduction: correct signs, limited claim

### 2.1 The two differences have the right direction

For a payload holding register `i`, notification launch `t`, first receiving synchronizer stage `0`, and functional consumer `j`, the adverse setup-side offsets are:

```
delta_src = notification clock edge - payload launch clock edge
          >= early notification branch - late payload branch

delta_dst = consumer clock location - stage0 clock location
          >= early consumer branch - late stage0 branch
```

Reducer125 uses the **HOLD notification arrival clock** versus the **SETUP payload arrival clock** for the first expression, and the **SETUP payload required clock** versus the **HOLD stage0 required clock** for the second. These are the correct early/late senses for shrinking the event interval. The corresponding ordinary setup/hold clock models are the relevant observations; raw path totals are not clock offsets.

The reduction stops before source `utco` and before required-path `unc`, so it does not hide clock-to-Q, setup/hold micro parameters or reported uncertainty inside a supposed clock branch. Those quantities must be accounted for separately. `get_point_info` help113 explicitly defines cumulative totals and the node-less routing-element case.

### 2.2 Common-prefix cancellation is justified as a change of event reference

The current records support using each bank's shared `ext_mem_if[N].clk` point as its local event reference. The prefix comparison preserves node identity, order, point type and transition; the additional edge-signature check above strengthens that interpretation for these actual records. Subtracting the respective cumulative totals at that common point leaves the downstream early/late branch observations. It does **not** cancel arbitrary matching suffixes, compare the two unrelated bank PLLs, or remove the entire reported inter-domain skew.

In particular, the native common prefix includes signed PLL compensation terms. Their disappearance from the branch calculation is legitimate only because the event reference has moved to the **same physical local clock point**, not because compensation or PLL latency can generally be ignored.

Two qualifications are essential:

1. A shared **same-event** upstream displacement cancels between consumers of that event. A consumer two edges later, or candidate notification one source edge later, uses a different event. Upstream **cycle-to-cycle variation does not cancel** merely because its node names match. It belongs in an explicit one-/two-/multi-cycle contraction budget referenced at these anchors.
2. These are selected native path-clock observations, not a documented all-transition early/late timing-envelope API. Reducer125 does not establish that they bound every admissible clock arc, slew, inversion, variation state, source replica or future fit. It also does not establish a silicon correlation model or a new native CCPP result. Do not add a separate CCPP credit to these normalized branches.

The reducer's named-node filter would not, by itself, prove that anonymous routing between matching names was identical in arbitrary future data. No such anonymous prefix segment exists in the reviewed records. For a changed fit, recheck the common physical event/edges or retain the unresolved contribution conservatively; never extend cancellation past a divergence by matching a later suffix.

### 2.3 Observed numerical result

All values below are ns and concern **old fit25 only**:

| Corner index | Request minimum offset sum | Response minimum offset sum |
|---|---:|---:|
| 1 | -0.796 | -0.838 |
| 2 | -0.762 | -0.798 |
| 3 | -0.521 | -0.542 |
| 4 | -0.583 | -0.615 |
| 5 | -0.618 | -0.656 |

The request worst witness is `request_hold[129]~DUPLICATE -> bank_request[129]`: source/destination offsets **-0.419/-0.377ns**. The response witness is `response_hold[356] -> core_snapshot[356]`: **-0.434/-0.404ns**. The request notification source is the actual `request_toggle~DUPLICATE`, not an assumed unduplicated RTL name.

Thus the reviewed arithmetic is:

| Direction | `6 + offset - 3` | Hypothetical `9 + old_offset - 3` |
|---|---:|---:|
| Request | 2.204 | 5.204 |
| Response | 2.162 | 5.162 |

These are **unallocated algebraic event allowances**, not slack, not a numerical SDC maximum, and not an approved budget for missing physical terms. The second column cannot establish a candidate result: both the branches and the source-cycle contraction need new qualification. Zero control-flight credit is appropriate and should be retained.

## 3. Numerical risks that must not disappear in the continuation

### 3.1 Raw path cost is not wire delay

For the observed records, `rawmax = Dmax + signed_setup` and `rawmin = Dmin - signed_hold`, where ordinary `D` already includes clock-to-Q and the entire data path. The terminal setup cost can be negative. Do not add clock-to-Q or capture micro terms twice, change a signed setup term to its absolute value, or reuse raw notification minimum as positive control-flight credit without stripping and qualifying its capture term. No such credit is needed here.

The native old-fit data-side maxima including reported uncertainty remain **2.630ns request / 2.778ns response**, leaving **0.370/0.222ns** to the unchanged 3ns target before newly required data-side allowances and guard. This is a **different budget** from the 2.204/2.162 or 5.204/5.162 event allowances. A larger event interval cannot fund data paths beyond the retained 3ns objective. Added staging therefore does not, by itself, cure the conventional setup failures or prove the absolute target achievable after fitting.

### 3.2 Pair coverage is not every transition's envelope

Query118 deliberately omitted `-nworst` and `-pairs_only` and did not saturate its finite caps. That establishes the accepted structural-pair acquisition, but not an independent enumeration of every transition/arc extremum. Its returned source `utco` transition codes illustrate the distinction:

- Request setup/rawmax: 650 `ff`; request hold/rawmin: 650 `rr`.
- Response setup/rawmax: 3,028 `ff` and two `rr`; response hold/rawmin: 3,030 `rr`.
- Each notification group: five setup/rawmax `ff` and five hold/rawmin `rr`.

Those are native **micro/data-point transition codes**, not evidence that the RTL uses a falling clock; the compared terminal clock cells are all `rr`. They nevertheless show that one selected timing path per observed pair/method is not two independently certified payload/control polarities. A worst-slack path also need not maximize the newly formed sum of local clock offsets or an event-relative cost.

The next selected fit must either establish that the relevant clock branch bounds are invariant over admissible data transitions/arc conditions, with supported model evidence, or take explicit adverse envelopes over those conditions. Cover both toggle polarities, rise/fall payload and predicate transitions, all actual D/ENA/SCLR functional arcs, all required corners and replicas, and any newly mapped consumers. Do not conflate the clock-edge selection semantics of SDC `set_max_delay -rise_from/-fall_from` with forcing data transitions in a path report.

### 3.3 Setup observations do not supply overwrite timing

Reducer125 selects bundle SETUP and notification HOLD records to examine earliest consumption. It does not calculate the adverse clock offsets along the complete next-transaction overwrite sequence. Near-zero conventional hold slack in the original fit is not `Hmin`; neither is a nominal protocol interval a hold exception value. The next-value `Dmin - h` must be paired with the actual earliest legal overwrite bound for the same consumer/arc.

## 4. Candidate126's physical rationale and required inequalities

### 4.1 Source-cycle separation is a reasonable structural choice

M126:119–125 installs request data and sets `request_pending`, then toggles notification on the following active core edge. M126:57–58 inhibits completion while pending, so the old equal ack/request values cannot legally end that pending interval. M126:146–152 captures the response/sidecars while retaining ownership, then prioritizes pending publication on the following bank edge. This is the source-side alternative described in BUNDLE-DESIGN94 section6.

That scheduling can provide useful separation even if the asynchronous notification route becomes arbitrarily fast. It requires the mapped launch ordering, ownership and complete payload immutability to survive implementation; source code alone does not prove any physical separation in ns. Normal timing of pending-to-toggle, local synchronizer interstage and stage1-to-consumption control paths remains mandatory. Reset and stopped-clock behavior are not ordinary steady-state timing exceptions.

### 4.2 Explicit Gmin budget

Let `T_S` and `T_X` denote **nominal** periods at the shared source and destination anchors; both are currently 3ns. Let `Delta_src_low` and `Delta_dst_low` be qualified all-required-condition lower branch differences. Let:

- `A_X` bound how late a notification transition at stage0 D may arrive relative to that stage0 clock edge and still be observed as new for this handshake, under the stated aperture/reliability model.
- `J_S1` bound shortening of the one source-cycle interval; `J_X2` bound shortening of the two-destination-cycle interval. Include time-varying common-tree contributions omitted by static prefix normalization.
- `Q_G` cover remaining documented envelope/model/report-resolution error, not another copy of variation already included in the branch bounds.

With **zero control-flight credit**, a candidate lower bound is:

```
Gmin_ij >= T_S + 2*T_X + Delta_src_low_ij + Delta_dst_low_ij
                         - A_X - J_S1 - J_X2 - Q_G
```

The original protocol omits `T_S` and `J_S1`. Do not use minimum-period quantities and then subtract the same contraction again. These bounds are conditional on qualified two-stage behavior; metastability can add latency, but a two-flop drawing is not a deterministic guarantee that it cannot corrupt control.

Keep the two acceptance tests separate:

```
Dmax_ij + s_j + Udata_setup_ij + Msetup <= 3.000ns
Gmin_ij >= 3.000ns
```

`Msetup` is an explicitly selected positive engineering guard. An additional event reserve may be selected, but must not be silently counted twice. `Udata_setup` contains only required residual terms not already represented in `Dmax`, signed `s`, or the event bound. The existing native 0.320ns uncertainty is not automatically this complete allocation and must not simply be added to every interval.

With the **old observed** offsets only, the hypothetical staged event loss budget is at most 5.204ns request / 5.162ns response for `A + J_S1 + J_X2 + Q_G` and any separately chosen event reserve. This is a conditional worksheet ceiling, not a recommendation to assign those missing quantities arbitrary values or spend all of it. No aperture/jitter value is qualified by reduction125.

### 4.3 Hmin must follow the actual overwrite event

The candidate's nominal no-reset, earliest-service sequences give useful starting expressions:

- **Request:** bank request capture; at least one bank edge to install response; another bank edge to publish ack; first core ack observation plus two core periods to complete; another core edge to install the next request. Thus `Hnom_req = 2*T_B + 3*T_C`.
- **Response:** core response consumption; another core edge to install a request; another core edge to notify; first bank request observation plus two bank periods to capture it; another bank edge to install the next response. Thus `Hnom_rsp = 2*T_C + 3*T_B`.

Both expressions are **15ns nominal** at the reviewed periods, versus the original protocol's 12ns starting expressions. This is source-derived conditional reasoning, not an independent functional acceptance. Do not count the next request's later notification as delaying its already earlier payload overwrite, or count the next response's later ack as delaying its payload overwrite.

Derive per-consumer adverse `Ehold` from those entire sequences, including the reverse-direction first-stage aperture, appropriate clock-location differences and multi-cycle contraction:

```
Hmin_req >= 2*T_B + 3*T_C - Ehold_req
Hmin_rsp >= 2*T_C + 3*T_B - Ehold_rsp
Hmin_ij + Dmin_ij - h_j - Udata_hold_ij >= Mhold > 0
```

Do not substitute reduction125's setup offset sums for `Ehold`, sum conventional slacks across sequential stages, or infer `Hmin` from MTBF. Async reset may overwrite held data outside the transaction protocol; reset assertion/release, recovery/removal and reset-history behavior remain separate gates. A stopped clock may delay service but supplies no additional guaranteed minimum credit beyond the proved sequence and clock-restart contract.

## 5. Smallest actionable continuation

**Do not commission another unchanged-fit diagnostic.** The next immediate deliverable should be one finite, source-bound **event-budget/coverage contract**, based on the existing capture and the selected protocol. It should close the following named inputs, not create another general clock-inventory project:

| Item to freeze before numerical acceptance | Explicit allocation/evidence required |
|---|---|
| Aperture | Separate `A_bank` and `A_core`, covering both notification polarities, actual stage0 cell/clock/data slew, PVT and the stated failure-probability model. A nominal library hold value, rawmin terminal micro, or ordinary hold slack alone is not this bound. |
| Reliability | A numerical mission reliability or failure-rate target; allocated request/ack chain failure rates and any aperture/jitter-tail contribution; actual maximum toggle-rate assumptions and fitted resolution times. Use conservative aggregation, e.g. sum allocated failure rates without assuming statistical independence. No target is supplied by the reviewed reduction/design records, so none is invented here. |
| Jitter/contraction | Per-direction `J_S1` and `J_X2` at the exact anchors, plus the intervals in each overwrite sequence. State which reference/PLL jitter, period tolerance and dynamic clock-network variation each covers, their correlation treatment and any tail probability. Static branch early/late variation is already charged in `Delta`; common-prefix naming does not remove dynamic variation. |
| Data-side uncertainty and guard | Explain which portions of native uncertainty are retained, replaced or already charged elsewhere. Assign positive `Msetup` and `Mhold`, and a report/model-resolution reserve with provenance. Prove the 3ns absolute target independently of Gmin. |
| Physical coverage | Enumerated source/notification replicas, all request captures, snapshot captures, bit704/`return_armed` epoch predicate, all three `return_error` predicate consumers and mapped successors. Include pending-state/local-control paths, both polarities and actual functional pin/arc classes. |

The aperture and jitter/reliability entries need an applicable device/vendor characterization or an explicitly reviewed conservative engineering model with its limitations. Installed timing-command help supplies report semantics, **not** those physical numbers. If those inputs are unavailable, make one focused request for that characterization/engineering decision and leave the certificate open; further unchanged Quartus reports will not manufacture it. A source staging cycle buys budget but does not eliminate this requirement.

After the independent functional review and an explicit parent source-selection/native gate, use **one justified changed-source synthesis/fit and its finite signoff batch** to populate this contract. Candidate126 changes HDL, so synthesis59 is not its mapped result. This recommendation is not an issuance. The minimum useful physical work is:

1. Reconcile the selected candidate's mapped endpoints/replicas and actual two-stage control/consumption topology. Verify pending and local interstage/control setup/hold normally; retain all reset/RDC checks.
2. Obtain complete required pair/corner data-cost and clock-branch bounds, resolving the transition gap by supported transition-scoped reports or a justified invariant envelope. Reuse installed25.1 `get_path`/`-min_path`, ordinary `get_timing_paths -setup/-hold`, and `get_path_info`/`get_point_info`; use finite caps with coverage checks. Existing help exposes rise/fall/through selectors, but endpoint semantics and returned transition records must be checked rather than guessed. No `get_clock_paths` shortcut, unbounded sweep or unsupported `-hold -data_delay` combination is needed.
3. Reconcile native signed micro/uncertainty/clock terms with the physical inequalities for every covered class, preserving rounding allowance. If implementing a maximum later, use exact held-register to verified functional-input scope and the installed clock-aware `set_max_delay` semantics; no Q-pin launch shortcut and no nonexistent `-datapath_only`. Keep explicit min0 initially. **No larger numerical maximum is authorized by this review**, and no max change may be chosen simply to erase old slack. Require the same effective objective in fitter and signoff, not an STA-only waiver.
4. Inspect fitted synchronizer reliability using captured installed `report_metastability` semantics and explicit chain coverage/toggle assumptions. That help defaults to one reported chain and assumes 12.5% source-clock toggle rate unless configured; neither default is a reviewed reliability contract. Worst-case chain estimates, unresolved chains and reset failures remain visible. A native MTBF estimate is not an aperture bound or a deterministic latency guarantee.

Stop this continuation with a clear per-inequality pass/fail and the exact remaining discriminator. If the chosen fit fails the fixed absolute target or the event/hold contract, preserve the failure and choose a source/placement/protocol correction; do not loosen the target to relabel it a pass. The original observer's fitted timing, reset/RDC and hardware lifecycle/numerical qualification remain independent open gates.

## 6. Local source bindings

These SHA-256 values identify reviewed bytes, not new native receipts. All paths are relative to `N` unless abbreviated above.

| Artifact | SHA-256 |
|---|---|
| `C/DESIGN126.md` | `378a62b834b5946fcc618a0684ce838c753ceb776d6ba926ccdf1cf58392d41e` |
| M126 | `d521d67614ab2d405ac9fd39852ee0f1d968adb3dadba87d816057b8c562b627` |
| M | `0b43f0028c99afa6d13cdd39a632be16fb49fb86efe686eb2e270cbddd2698ff` |
| `E/analyze-clock125.py` | `dfbd2c28647f44dc761ac252acf12cf95e37554e6c202dbb36d02908f59cbbce` |
| `E/clock-envelopes125.json` | `1861cfaaf7a34f68abb540eb7811f15153e6f6969825f79984c2ff890961c8a7` |
| `E/clock-envelope-pairs125.json` | `594b70d958d2be7e9e7bc8086d4c274e5e6e98d9db3d436833bdb10cbd27fb2b` |
| `E/BUNDLE-DESIGN94.md` | `4a581b10102c2e4bda90be9b341834887260efa29801fe513e6ec3bb3eb23ea0` |
| `E/BUNDLE-RESULT124.md` | `0eae20bf33d04cb29283dcee947f31356e0ef511652c51d6b8c77db2d52ba303` |
| `E/bundle-semantics124.json` | `3df0de05c2f4196d3a9cd619c49df854dd5f05c9b0ed81ad52bd0c331ac00187` |
| `E/help12-capture/help/set_max_delay.txt` | `17f340c4a8a41ea5a772551fe426611fda75f6dba0901c125254b56bd9d7bcbc` |
| `E/help12-capture/help/set_min_delay.txt` | `975307d3d6b9511b0b0ddc2f861c891ab094787c9b55423deb9f750c60a8c164` |
| `E/help12-capture/help/get_timing_paths.txt` | `613130f05e830564cb23eeffe63ecfc4755d77c3257d27a29929d13b1008eb09` |
| `E/help12-capture/help/report_metastability.txt` | `5a0c489eb824eb79bfc23a72c9af515e596f893741749f0ee2347e99b5d8d66f` |
| `E/help113-capture/help/get_path.txt` | `d65eb109e38bf54d99c2201f8db71a73f8c47e5b2094eb895df914ef05342dc7` |
| `E/help113-capture/help/get_point_info.txt` | `90be2295c444351ea4b96da93bde4713ab5d2247d9ce8328fec4975a576d5cb0` |

**Final boundary:** reduction125 arithmetic/common-event normalization is accepted for its retained observations; candidate126's rationale is supported as a conditional structural option. All-transition bounds, aperture/reliability, jitter allocation, event-relative hold and the selected candidate's physical implementation remain unqualified. Publication stays disabled.
