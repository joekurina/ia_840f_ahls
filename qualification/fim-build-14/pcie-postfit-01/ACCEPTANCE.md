# Parent acceptance — one bounded Work14 fitted-copy diagnostic

**ACCEPTED for one source-bound offline native STA inspection of the prepared copy.** This is execution-package acceptance, not native-result acceptance, timing acceptance, source-correction acceptance, or hardware qualification.

The renewed user authority in [AUTHORITY.md](AUTHORITY.md) clears the historical Query04 approval timeout. The parent consumes [SPEC PASS](spec-review01.md) and [QUALITY APPROVED](quality-review01.md), with no blocking findings. [Parent verification](parent-consumption01.json) independently checks all nine prepared files against the manifest and exact preparation export; no review-bound bytes changed.

- Manifest: `41cacf060bbea75bf4455cb617a5f7b295d7d8c5f78079bb5553fbc0a90ed886`.
- Candidate: `5e20a7a1b2be00d53a72972cdf09fa4ab1cc93d9e330f010f69c4b0954e52776`.
- SPEC: `9030581389e80f35927540bc516edc440718dbc5e349a0183fda5c0a7c2979a3`.
- QUALITY: `4dc6612f3bb3661a763a39165fe8310d35c7f0789364f32a034b8f48b8c8cdfe`.
- Prelaunch file bindings 7,880; callback file bindings 7,757; links 10.

## Exact operation

The parent may exclusively issue the gate's exact authorization object, after rechecking unchanged remote package/inventory and unconsumed state, then invoke the unchanged `run-query.py` once in `ia840f_mailbox_monitored_01`. The reviewed runner performs its own source/tool/link, live-context, memory-headroom and competing-process checks. It invokes only:

```text
/opt/altera/26.1.1/quartus/bin/quartus_sta -t /home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01/query.tcl
```

Native cwd is the attempt's `scratch/syn/board/ia840f/syn_top`; runner cwd is the attempt root. Candidate `approved=false` and `ready_for_build=false` remain immutable. Permission is a separate record, not readiness. Any issuance/transport failure is preserved; do not duplicate an unknown or consumed run.

## Review-note dispositions

1. Input-pin `get_pin_info -net` is not supported connectivity proof. Interpret input connectivity from the separate fanin evidence; a native API rejection or missing result is an incomplete diagnostic, not permission to infer an answer. Do not alter the reviewed query to preempt an experiment result.
2. An exceptional postflight/export can cause the outer exit to differ from native status. Require the stored `native-result.json`, full `query.log`, and `preservation-after.json` together. A missing or false preservation receipt is unresolved/failure, never a pass. Keep native status separate from transport status.

`QUERY_INVENTORY_END` precedes cardinality checks. Neither that marker nor native rc0 establishes complete pin/master/FIFO evidence or timing acceptance. Inspect all counts, gate messages and original-tree preservation before using the findings. Independent result review follows actual execution.

## Preserved boundaries

No maintained HDL/SDC, clock/exception changes, refit, assembly, device access, OPAE loading, MMIO, programming, PR, driver/huge-page configuration, reset or reboot. Original Work14/SOURCE/PIM are preservation targets; W13/persona and old consumed claims are untouched. Resource limits and source-bound guards are not an OS sandbox or a promise of immunity to vendor-tool failure.

The selected OFS `ofs-2026.1-1` examples target remains active; upstream review found no replacement FIM constraint in the inspected public donors. This operation inspects preserved Work14 evidence, not a new old-baseline build or a jointly qualified release. EMIF1 hold, other timing/CDC findings, matching persona and all hardware acceptance gates remain open.
