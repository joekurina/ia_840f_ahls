# Router native capability check — close router-ON branch

## Decision
**ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION is not an available Agilex 7 assignment in installed Quartus Pro 26.1.1. Do not prepare or compile an ON overlay for this setting.** This conclusion comes from the documented native family-filtered assignment API, not assignment persistence or inferred ELF family indices.

In a new standalone project with FAMILY `Agilex 7`, DEVICE `AGFB027R25A2E2V`:
- `get_part_info -family AGFB027R25A2E2V` returned `{Agilex 7}`.
- `get_all_assignment_names` includes the router assignment.
- `get_all_assignment_names -family {Agilex 7}` excludes it, as do the family-filtered global and fitter lists.
- `get_assignment_name_info` exposes generic legal values Auto, Off, On and descriptive help. Generic metadata does **not** override the family exclusion.
- `ROUTER_REGISTER_DUPLICATION` and `POST_ROUTE_PHYSICAL_SYNTHESIS` are also excluded from the Agilex 7 list. These are not supported substitute toggles.

The family bitmap indices 15/55 were not reverse-engineered further; the supported API directly answers the target-family question. This is assignment availability evidence, not a claim that the similarly named fitter transformation cannot run internally.

## Smallest supported alternative
The native Agilex 7 global/fitter capability lists include `TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT`. Native metadata states legal values On/Off and: “Instructs the Fitter to aggressively optimize for hold timing closure.” Native default enumeration in the exact-device scratch project returned **OFF**. Setting ON, closing and reopening this scratch project returned **ON**.

Thus a meaningful, supported one-setting **hold-only** experiment is:

```tcl
set_global_assignment -name TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON
```

This is **not a setup-recovery candidate** for the dominant EMIF MSA failures, and it may worsen setup/area/runtime. It is a supported next experiment only if addressing the separate hold violation is useful. No proof of timing improvement is required to justify this experiment, but none is claimed. No alternate overlay or full compile was launched.

The captured SOURCE baseline `../msa-router-candidate-01/remote-source-baseline.qsf` was locally rehashed to `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293`; it has no explicit aggressive-hold assignment and retains seed 2, maximum-placement source spelling, and MAXIMUM router timing optimization. This validates the captured baseline only, not a new live SOURCE inventory. Any later packaging must preserve all other configuration and existing gates/readiness=false.

`DUPLICATE_ATOM` and `DUPLICATE_REGISTER` are supported Agilex 7 fitter instance assignments, but this experiment does not establish valid source/destination targets for the physical MSA aliases. `MAX_FANOUT` is family-supported but not in the fitter list. No new setup-oriented one-setting candidate was established.

## Native execution and evidence
All six native invocations exited **0**, with zero reported errors/warnings. Each ran under `timeout --kill-after=5 60` using `/opt/altera/26.1.1/quartus/bin/quartus_sh -t <script>`; actual arguments, cwd, scripts, full logs and recorded hashes are preserved in `remote-evidence/`. Main project capability invocation completed in about one second. No synthesis, fit, full compile or Q04 was executed.

The scratch project was created exclusively at:
`/home/uwb_student00/quartus_26/qualification/router-native-capability-01`

All remote operations were in owned pane `%392`, window `router-native-capability-01`, existing session `ia840f_mailbox_monitored_01`. Each dispatched batch asserted hostname `Agilex7Workstation` and UID 1000. Explicit environment follows the instructions read inside that pane; copied instructions/environment are preserved. Existing panes were not modified.

Before/after inventories are in `capability.json` and `alternative.json`; capability Tcl input remained byte-identical. Initial discovery omitted `puts` around `help`, so the return strings were not logged; subsequent successful help invocations captured complete documented syntax before capability calls.

On opening the new scratch project Quartus emitted informational 22747 and auto-added `PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"` and `PWRMGT_LINEAR_FORMAT_N "-12"`. These are **native scratch initialization effects**, not intended experiment settings or recommended SOURCE deltas. The final scratch QSF therefore is not itself a one-setting SOURCE overlay. Assignment readback is recorded only as persistence; applicability is separately established by the family-filtered API.

### Key SHA256s
- Capability full log: `0280128b32ebb3ee36bf8df7fc92b1805afdbb2229d1bc3c9790f91c418c4872`
- Alternative/default/readback full log: `5e921d58401880e1f46537837782c0eaa2144b44cd8bd83bb1a7d303b03b3a3e`
- Quartus launcher: `06c1bd805bc078d9636015c472e09a054160c405f3f06b7c555e7a4b6f7d3f14`
- Native linux64/quartus_sh: `5740e47134517eac623c1391837761d12ab18b99a2db78be790cf764af3e3bce`
- libdb_acf.so: `ff83ee6769849c55ebb83a6c6567e3d2f9e063210deee7b83bc6698221929f16`
- assignment_defaults.qdf: `6bf28d61aacedcc91ed126e50bcfe2af597841caefad36f70f3859edd1a818c7`
- Full remote export: `7881b6b6221ebf3475fa6ad84c759cbee61e2e2ae6a497f846e7c918d0985bf8`

The unique tmux buffer export was checked against its remote SHA256; all **36** exported files passed individual SHA256 checks. `verification.json` records the complete inventory. Local runners and exact remote Python payloads are retained alongside the report. No maintained SOURCE/WORK, installed tools, execution gate, authorization, RTL, SDC, DDR simulation, hardware permissions, install or commit was touched. Normal-account monitored execution is not represented as an OS sandbox.
