# Guarded actual-PIM component — mapped-synthesis diagnostic

**Native synthesis completed. Independent review pending. This standalone top is not a board-ready fit boundary.**

## Native result and provenance

- Quartus Prime Pro **25.1.0 Build 129 SC Pro**, device **AGFB027R25A2E2V**.
- Fresh `work_ahls_memory_pim25_03/synth02`; native/effective/outer **0**. Native run 2026-09-23T13:36:57.135729Z to13:39:42.776159Z; reported elapsed2m44s, peak virtual memory3539MB.
- Command: `quartus_syn --read_settings_files=on --write_settings_files=off ia840f_ahls_memory_pim_elab -c ia840f_ahls_memory_pim_elab`. The project basename is historical; actual argv, synthesized snapshot and mapped-resource/FSM panels establish the stage.
- **530 bound inputs**:275 platform/core plus255 generated; same source/QSF as successful elab01 and failed synth01. Six preservation domains true; no postflight errors, timeouts or surviving owned group. No source, tool installation, clocks, pins or SDC edited between stages.
-15 exported members verified against immutable archive SHA256 `5cbecb87a6b3e12528fb45a8733f655b274b1e523328b0e697d34d5284e2bb75`. [Manifest](manifest-synth02.json), [parent verification](parent-verification02.json), [native panels](mapped-native-panels02.json).

The earlier [synth01 failure](SYNTH01-INVOCATION-FAILURE.md) remains native/effective/outer3. Its `--synthesis` flag requested only the later stage without an elaboration database. Recognized option help was not proof of prerequisite semantics. The corrected normal invocation above runs elaboration plus mapping from source; no old QDB was modified or copied.

## What the mapped report establishes

| Native quantity | Reported value | Boundary |
|---|---:|---|
| Logic utilization estimate |32,154 ALMs /912,800 (native display4%) | Synthesis estimate, not placed/fit occupancy |
| Dedicated logic registers |79,163 | Standalone component context |
| Estimated DSP blocks |0 | Integer-add qualification kernel |
| Guard combinational ALUTs |269 | Not ALMs; exact `mmio_guard` entity row |
| Guard dedicated registers |331 | Both4-state FSMs retained and encoded |
| Top-level input/output/bidirectional pins |8 /0 /5,143 | **Artificial standalone interface boundary, not card pinout** |

The guard is actually retained in the mapped netlist: its entity resource row and both `mmio_guard|ws`/`rs` FSM panels are present. Native `Safe One-Hot` is a compiler encoding label, not a runtime reset/recovery or functional-safety guarantee. The primary PIM, bank page splitters, core and generated kernel remain under the recorded source binding. No netlist equivalence, mapped simulation, clock-rate or board-operation claim is made.

## Warnings: retain both summary and explicit counts

Native summary: **0 errors /5,391 warnings**. Parsing the full native synthesis log gives **5,616 explicit warning occurrences**. This reconciles exactly as the prior226 A&E occurrences plus5,390 newly emitted mapping occurrences; the final banner includes the A&E summary of1 plus5,390. Do not erase nested diagnostics or claim warning-clean synthesis. Full rows: [warning ledger](warning-ledger-synth02.json).

| Mapping group | Occurrences | Source/evidence disposition |
|---|---:|---|
|13039/13040 undriven bidirectional boundary pins |12 grouping +2,489 pins | Every13040 names `plat_ifc.*`; includes clocks treated as external bidirectional interface ports. This top was an A&E component boundary, not a physical shell. |
|13032/13033 constant tri-state pins |1 grouping +624 pins | Every13033 names `plat_ifc.*`, including tied sideband fields. |
|13009/13010 permanently enabled tri/open-drain buffers |1 grouping +2,070 nodes | Every13010 names `plat_ifc.*`. |
|24566 open-drain conversion |1 | Boundary conversion reported by native mapping; not an electrical design choice for the card. |
|14284/14285/14320 removed nodes/RAM |5 +5 +177 | Named PIM metadata/FIFO or generated constant logic; not blanket waived. Exact active-path impact remains a review item. |
|13046/13047 internal tri-state conversion |1 grouping +4 nodes | Generated `lsu_n_fast.sv:352`, read burstcount[3:0] fanout converted into OR gates. Source has repeated assignment of the same `request_dout` inside the per-port generate; retain transformation for review, not silently suppress or modify vendor RTL. |

The standalone boundary produces thousands of inappropriate physical-interface pins. **Do not run Fitter on this project as a board image, assign guessed pins, or remove source interfaces to quiet warnings.** The next physical step needs the matching Work21 FIM/PR persona context, where PIM interfaces are internal connections. Its release/build prerequisites and signoff still require verification.

## Design Assistant findings remain open

The partitioned snapshot retains **RES-10204 High1**, missing device-level Reset Release. Synthesized DRC has **4/13 rules failed**, zero waived:

- **RES-30134 Medium:** `5,000+` reset-unreachable registers with `max_violations=5000`. This is a saturated report, not an exact total. Standalone project lacks device-level reset release; real FIM integration must establish reachability without duplicating device-level IP.
- **FLP-10500 Low:**8 nondriving top-level input clock/reset fields in host AXI-stream interfaces. Boundary/use semantics require the real FIM context; not permission to tie clocks arbitrarily.
- **TMC-20501 Low:**3 requested reset-tree duplications not applied because all fanout is within one hierarchy; bank0/bank1 soft resets and `join_afu_reset|b_to_a|dup_leaf`. Not proof of fitted reset distribution.
- **LNT-30010 Low:**`join_afu_reset|joined_reset_n` drives both reset and enable endpoints (488 asynchronous-reset,1,376 synchronous-reset,513 enable endpoints in this panel). Keep the clock/reset review open.

Synthesized DRC reports0 combinational loops and0 inferred-latch paths for its enabled rules. That does not close CDC, reset, full-FIM unconstrained-path or timing signoff. Existing `freeze_cc` is still swept: declaration/wiring is not effective quiescence.

## Acceptance boundary

Seek review of **actual guarded-top integration and bounded standalone mapped-synthesis evidence**, with retained warning/DRC/interface limits. Do not accept this as full FIM/persona fit, timing, physical pin/electrical qualification, primary PCIe behavior, OPAE, physical DDR, host posting/fences/global drain, lifecycle/buffer lifetime, PR/reset or durable boot.

The simulation guard milestone was separately accepted/published as `ce4a40ee6c3e5867ae4d7d77e0d292ee19f1faa3`; its F1/F2 fixture limits remain. No FPGA/device/driver/programming/reboot occurred. Vendor DDR simulation is **SKIPPED BY USER**. Goal incomplete.
