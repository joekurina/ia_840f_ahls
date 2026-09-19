# Query02 independent SPEC review

**Disposition: GAPS — not SPEC PASS; do not advance to quality review or vendor launch on these bytes.**

Scope: read-only local review of exported candidate, query, runner, isolated dispatcher/gate and preparation evidence. No vendor execution, authorization issuance, remote access, quality tests, maintained-source edits or Work09 writes were performed. This review does not independently re-hash the remote scratch tree; remote preservation/dependency claims remain supported by the supplied preparation evidence.

## Exact reviewed SHA256

| Artifact | SHA256 |
|---|---|
| `candidate.json` | `67972b6001ae1434c904a2807087f8dcdc9e10fc1119d5e631bf0f0140829f96` |
| `query.tcl` | `2ec56b4b1f1109f5ce609b29a9c1ffa63c66beef363cfe6c4d15f54f50ad28e7` |
| `run-query.py` | `f6a561871a182f0bbbe761e5adcdeac61c9a904520d5910e46a6adbb7e06cae6` |
| `ia840f_query02_gate.py` | `774837b4ab3eef18edacecd466875b3ff095e9b62734aa0901997f4ac73a5e94` |
| `ia840f_experimental_gate.py` | `b262dd92f23f38639fbf02054536058839bd850a0bc3db1b07524a9a7961f36d` |

Local query/runner/both gate hashes match their entries in candidate.json. Parsed counts: 8,027 prelaunch file bindings, 7,892 callback file bindings, 11 link bindings, 135 callback exclusions. Callback digests agree with the corresponding prelaunch digests. Candidate stays approved=false and ready_for_build=false.

## Satisfied scope requirements

- Finite scratch-only dispatcher branch, exact project cwd, exact STA executable and argv; no broad vendor-tool permission or change to maintained gates. Device is fixed to AGFB027R25A2E2V. Sources, QSF/SDC, copied databases, tool launcher/executable and query/runner are bound. Runtime argv[0] convention is explicitly source-derived and still needs native confirmation; mismatch rejects rather than normalizes.
- Query opens existing revision, creates the default timing netlist, reads existing SDC and reports information. No new clock, corrective SDC, false path, synthesis, fit, programming, or logic-database write command is requested. Normal project-open/STA scratch metadata and log changes are not a claim of OS-enforced read-only containment.
- Missing-authorization evidence shows both actual dispatcher rejection and runner rejection before claim/log/vendor launch. Native closure is honestly NOT_RUN. Complete copied Work08/PIM, 87 relocations, no broken links and Work08 unchanged are reported, not confused with native acceptance.
- Excluding the enumerated existing logs/reports/QPF only at callback time does not itself widen permitted commands; full prelaunch checks retain them. Immutable QSF/SDC/database bindings remain present. No blanket database exclusion was found.

## Required minimal corrections

### S1 — exact process identity is checked, but exclusive-run ancestry is not

`ia840f_query02_gate.py:21-24` checks only its immediate parent's executable/argv/cwd. Neither this branch nor its early return through `ia840f_experimental_gate.py` verifies a live ancestor belonging to `run-query.py` or the exclusive claim. The claim contains only a constant sentence. With authorization present, a direct matching STA invocation can therefore satisfy this gate without the bounded runner or exclusive-claim lifecycle. This is a real omission against the requested ancestry contract, not a request for a generic sandbox.

Minimal repair: bind the claim to the live runner PID/start identity and exact runner command/cwd, and require the callback's STA parent to descend from that live claimed runner. Reject absent/stale/unrelated ancestry. Retain existing executable, argv, cwd, target, file/link and authorization checks. Rebind the few changed artifacts and candidate; keep readiness false. Quality testing belongs after the revised SPEC pass.

### S2 — current query cannot establish divider input/master/mode/output connectivity

`query.tcl:8-16` emits cell pin **names** and existing clock properties, not physical connectivity. A missing generated output clock is precisely the suspected fault: its absent clock object cannot provide `master_clock_pin` or `divide_by`. Name-filtered existing clocks do not prove that this divider is physically fed by the CSR PLL, nor that fitted `clock_div2x` corresponds to vendor `clock_div2` and STA `~div_reg`.

Minimal bounded addition, confined to the already identified `u_pciess_clock_divider|clkdiv_inst` hierarchy:

1. Resolve the exact fitted divider/STA alias and print collection counts, full cell/pin identifiers and pin directions; explicitly expose the `clock_div2`, `clock_div2x` and `~div_reg` mapping or report which representations are unavailable.
2. Trace the divider's actual clock-input pin upstream through any clock routing/mux nodes to its driving PLL pin; print the selected source and clocks on that input, including full master name and period. Do not rely solely on generated-clock metadata. Use installed-help-supported pin/fanin/net connectivity APIs; this review intentionally does not invent their option syntax.
3. Read the fitted divider mode/property if available through the installed read-only API. If STA does not expose it, report that limitation and retain the existing vendor-SDC divide-by-two evidence separately; do not infer mode from the `2x` name. Report the actual output pin and its associated clock collection, including an explicit zero-clock result.
4. Derive the proposed output period as twice the resolved actual input period (frequency half the actual CSR value), without creating a clock. Use the reported precision, not nominal 100 MHz. If the connected input is not the expected CSR source, stop with that finding rather than force the hypothesis.

This is one small connectivity interrogation, not another full timing scan or corrective constraint experiment. Extend the declared read_only_api list and rebind query/candidate accordingly.

### S3 — explicit TRS absence discriminator is missing

The current name-filtered scan is useful evidence, but has no explicit match counts or completion marker. Add exact and hierarchical TRS clock/resource match counts, including `ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk`, and a successful inventory-end marker. Inspect oscillator resource type as well as name during the existing cell traversal so renamed resources are not silently excluded. Keep the known unrelated `altera_int_osc_clk` distinct. If no matching resource/clock exists, report the bounded fitted-netlist absence result; if present, leave exception applicability open rather than invent a cut. No broad exception framework is required for this absence-first query.

## Acceptance boundary

A revised candidate can proceed to SPEC re-review after these bounded changes. Following that pass, the parent may perform quality checks and consume explicit exact-query authorization. Native return code and full log review remain mandatory: source-bound rejection, missing dependencies, unsupported query APIs or incomplete inventory cannot be accepted merely because a completion-looking line exists. No actual PCIe master/divide relationship, TRS absence, timing closure or build readiness is established by preparation or by this review.
