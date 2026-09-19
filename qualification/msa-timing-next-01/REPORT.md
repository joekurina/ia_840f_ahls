# Work10 next timing experiment: bounded review, no justified patch

## Decision

**Do not spend the next compile on another seed, on re-enabling existing optimizations, or on a guessed setting.** No sufficiently supported, demonstrably different, contract-preserving setup optimization was established in this bounded static review. No candidate patch was produced and no compile or vendor diagnostic command was launched. This is a negative preparation result, not timing closure or proof that no supported solution exists.

The smallest next useful experiment is a **targeted duplication investigation of the final EMIF0 MSA combinational driver**, not blanket register duplication. Before packaging a compile, establish that an installed supported assignment can address the pre-fit node and split its actual destination group; the present full STA supplies the physical target but not a stable pre-fit assignment target. Do not issue a build until that gap is resolved. A separate router hold-effort experiment is possible in principle but does not address the dominant setup failure and is not bundled into this investigation.

## What the actual paths show

Read from the hash-verified full Work10 STA, not inferred from endpoint names. Exact complete first-path excerpts, including statistics and arrival/required paths, are in `emif0-path.txt`, `emif1-path.txt`, and `hold-path.txt`; source line numbers are retained.

| Worst path | Levels | IC delay | Cell delay | uTco | Launch fanout | Largest reported data fanout |
|---|---:|---:|---:|---:|---:|---:|
| EMIF0 write bank selection | 10 | 1.904 ns (55%) | 1.312 ns (38%) | 0.250 ns | 9 | 52 |
| EMIF1 read bank feedback | 11 | 1.896 ns (58%) | 0.979 ns (30%) | 0.367 ns | 1 | 10 |

EMIF0 is not simply one long high-fanout source-register net. The launch register `wrreq_bank_spreading|bank_fifos_dataout_out_valid[6]` feeds a 10-level scheduler path through `cmd_fifo_takes_rdcmd`, `effective_select_bank_fifo_read`, read-bank `add_*`, then write-bank `i1332`/`i1378` logic. Data interconnect segments range from 0.072 to 0.319 ns. The final combinational physical output `wrreq_bank_spreading|i1378~7xsyn~cw_la_lab/laboutb[10]` has fanout 52 (STA 156242), followed by 0.273 ns IC into the already duplicated register `wrreq_select_bank_fifo_read[1]~SynDup_8DUPLICATE`. Duplicating that destination register does not directly relieve this upstream cone and could increase its load. Manual duplication of the launch register addresses fanout 9, not the larger final driver. Generated `~xsyn` / `~cw` names are not established pre-synthesis assignment targets.

EMIF1 has an already retimed source and destination (`~RTM`), launch fanout 1, and 11 logic levels. Register duplication alone has weak evidence here. Both paths are substantially routing-limited, but their feedback/scheduling depth also matters; reducing clock frequency or adding ad hoc latency would violate the experiment constraints.

The -0.004 ns EMIF1 hold path is separate: Hyper-Register `amm_writedata_0_r[0][243]` through UFI to `lane_inst~phy_reg1`; 0.101 ns IC, 0.124 ns cells, 0.063 ns uTco. It is not the MSA setup cone.

Baseline acceptance remains failed: EMIF0 WNS -0.508 / TNS -185.081 / 711 endpoints; EMIF1 -0.170 / -29.340 / 403; hold -0.004 / one endpoint. Native exit 0, fit and assembly success do not change this.

## Installed 26.1.1 evidence and rejected shortcuts

`installed-options.json` contains read-only printable assignment-library strings with extraction indices and library hash; these are static installed help evidence, **not native project-load acceptance or a complete enum/schema**. `installed-defaults.json` captures matching source lines and the SHA256 of `assignment_defaults.qdf`.

- `ALLOW_REGISTER_DUPLICATION` defaults **On**, QDF line 95. Its help permits register copies and fanout redistribution; merely adding On is not a demonstrated optimization change.
- `ALLOW_REGISTER_RETIMING` is already **On**, as are RAM/DSP retiming and Advanced Physical Synthesis in Work10's effective fitter settings (177–181). Full STA already contains retimed and synthesis-duplicated MSA nodes. Re-enabling these is not a new experiment.
- High Performance Effort already enables timing-related physical synthesis. Work10 also has maximum placement effort, SPEED synthesis, MAXIMUM router timing optimization and seed 2. `POST_ROUTE_PHYSICAL_SYNTHESIS` is present in the library and has explanatory help, but its effective current state and a supported nondefault value were not established here; do not assume it is off merely because it is absent from the QSF.
- `DUPLICATE_ATOM` / Manual Logic Duplication help describes source-to-destination duplication with a named new node. `DUPLICATE_REGISTER` describes a requested number of copies. These are more targeted than another seed, but the present evidence does not establish an accepted pre-fit target/endpoint mapping for the physical high-fanout driver. Do not invent a hierarchy target or numerical fanout threshold.
- `MAX_FANOUT`-related help describes limiting destinations; it does not establish that a generated post-fit combinational alias is a valid synthesis target. Blanket low fanout limits risk area, routing congestion and changing both controllers without isolating the cause.
- `ROUTER_LCELL_INSERTION_AND_LOGIC_DUPLICATION` defaults **Auto**, QDF 449. Help says Auto already acts when performance can improve with nominal compile-time cost. Work10's fitter transformation table actually records this optimization. A forced setting could be explored after exact enum/applicability validation, but changing Auto is not evidence that the missing 0.508 ns can be recovered; no unsupported enum is emitted.
- `OPTIMIZE_HOLD_TIMING` defaults **All Paths** specifically for Agilex 7 (QDF 395), and Work10 effective setting is All Paths (fitter 197). Setting it again is a no-op. `TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT` defaults Off (QDF 59), and installed help says it aggressively optimizes hold closure. This is an identified follow-up lead, not a validated setup fix or a license to invent its enum/applicability. Hold optimization can worsen setup and must be isolated if pursued.
- Hidden DERIVED READY_LATENCY / VALID_LATENCY remain excluded. Prior installed MSA catalog and protected-source evidence supplies no supported latency insertion control. No protected code was edited or decrypted.

## Baseline binding and unchanged constraints

Live remote SOURCE QSF was captured read-only and is **byte-equal to the previously prepared Work10 seed-2 overlay**, not the stale local SOURCE copy:

- SOURCE QSF SHA256: `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293`.
- Work10 native migrated QSF SHA256: `e1d53efd133901d7e9d6dd03fd61afca34d8db7854b66d108522cc96dea659b2`.
- Installed `libdb_acf.so`: `ff83ee6769849c55ebb83a6c6567e3d2f9e063210deee7b83bc6698221929f16`.
- Installed `assignment_defaults.qdf`: `6bf28d61aacedcc91ed126e50bcfe2af597841caefad36f70f3859edd1a818c7`.

Full STA and fitter input hashes are in `verification.json`. Source and native QSF captures are separate; native migration of the old effort-mode spelling is not an operator optimization delta.

No SOURCE, WORK, RTL, QSF, SDC, gate or authorization files were changed. Thus this review does not alter core 470 MHz / seven PLL outputs, memory 333.33 MHz, two 16-GiB x64 BOT/BOT interfaces, pins, PF/BAR or RTL contracts. These contracts must be rechecked against the complete source inventory during fresh packaging; this review is not a new whole-tree certification. Existing S1/TRS, PCIe-divider, BMC IRQ/JTAG and unconstrained-path blockers remain open.

## Testable comparison once the targeting gap is resolved

Keep Work10 seed 2 and all existing effort settings. Change exactly one supported duplication assignment affecting the identified EMIF0 cone; no simultaneous hold knob, retiming mode, pipeline or clock change. Require no ignored/unmatched assignment diagnostics and native evidence that the intended driver was duplicated and its fanout redistributed. Compare all-corner EMIF0 and EMIF1 WNS/TNS/endpoint counts, path depth, data IC/cell delay, driver fanout, hold, resource use and runtime against Work10. Improvement in only one controller is not closure. Require all constrained setup and hold nonnegative and separately resolve constraint completeness for acceptance. If the assignment is ignored or transformation absent, classify the experiment as ineffective, not a seed result.

If the pre-fit target cannot be established, the evidence-grounded alternative is vendor-supported MSA scheduler/pipeline guidance or IP revision guidance for these exact 10/11-level paths. Do not relax clocks, protocol latency, or memory geometry as a substitute.

## Scope and issues

Remote reads ran only in newly owned tmux windows `%383` (`msa-timing-next-01`) and `%384` (`msa-options-next-01`) within `ia840f_mailbox_monitored_01`; host Agilex7Workstation and UID 1000 were asserted. Existing panes were untouched. Python static file reads and unique tmux evidence buffers only; no Quartus invocation, Query04, compile, DDR simulation, hardware access, install, permission change or commit.

The initially supplied installed-option evidence path was one level short; the actual file is `fim-build-09/remote-evidence/installed-option-evidence.json`. No access/tool failure blocked the investigation. The limiting issue is support/target applicability evidence, not unavailable compute. The artifact deliberately contains no speculative patch.
