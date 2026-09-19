# DDR4 external models repaired and regenerated

**Accepted for smoke-harness preparation only. `ready_for_build=false`. No HDL compilation, elaboration, or simulation was run.**

Remote scratch: `/home/uwb_student00/ahls/new_BSP/qualification/ddr-model-repair-01`.
Local evidence: this directory; `artifacts/` is hash-verified remote readback.
All remote operations ran in owned windows of `ia840f_mailbox_monitored_01` via SSH `uwb_student00@100.101.227.97`. Work04 was read only. Normal-account monitored execution, not OS sandboxing.

## Result

Quartus 26.1.1 build 130 successfully generated both models, each with three generated modules and nine simulation HDL files. Final `qsys-generate` exit codes are zero, with no errors/assertions or portless-model warnings in final generation logs. Final `repair4` component save also completed without assertions/errors.

| Model | Pairing | Leaf wrapper bytes | Capacity | IP SHA256 |
|---|---|---:|---:|---|
| `ed_sim_mem` | EMIF0 discrete | 10105 | 17179869184 bytes (16 GiB) | `e0eeb165be0adf7c695807eee02472b2bc292d6e9c43c7823fec06e0e376c594` |
| `ed_sim_mem_group1` | EMIF1 RDIMM | 10116 | 17179869184 bytes (16 GiB) | `5370d008d02ad2855acb470746e481bd1c0ce07b3cba5c7de0baed8e386657d7` |

Both real top and leaf wrappers expose 16 DDR pin signals: A17, BA2, BG2, DQ64, DQS8, DQS_n8, DBI_n8; CK/CK_n/CKE/CS_n/ODT/reset_n/ACT_n/PAR/ALERT_n are width one. The saved locked interface was compared against the actual leaf port widths. Generated `.qgsimc` identifies `altera_emif_mem_model_core_ddr4` version 19.1, instance `core`, RTL entity `altera_emif_ddrx_model`. The vendor component definition explicitly maps that component to this RTL entity; a literal Verilog module named `altera_emif_mem_model_core_ddr4` is not expected.

The leaf wrappers instantiate the actual parameterized `altera_emif_ddrx_model`, selecting DDR4, discrete/RDIMM respectively, row17/column10, one rank, x64, tRCD20/tRTP10. All seven generated vendor model RTL dependencies were hash-compared to installed source. `source-closure.json` contains nine ordered source commands per model: seven vendor SV files, the parameterized leaf, and the top wrapper. Eighteen paths have eleven unique content hashes (the seven common model files are identical). These are inventory commands, **not executed simulator commands**.

## Why a family-only repair was insufficient

`ip_top/exports.tcl` marks inherited model parameters non-derived and removes SYSTEM_INFO bindings. Thus the model does not automatically recompute the controller's derived geometry. Setting only `SYS_INFO_DEVICE_FAMILY` made ports appear, but incorrectly retained stale A1/DQ72. That intermediate result was rejected, not presented as a repair.

The installed example workflow (`ip_top/ex_design/make_qsys.tcl`) forwards evaluated EMIF parameters to the external model. We followed that parameter-forwarding design using the existing, generated Work04 EMIF0/EMIF1 `.sopcinfo` values, through supported `load_component`, `set_component_parameter_value`, `save_component`, and `reload_component_footprint` APIs in a valid scratch project for `AGFB027R25A2E2V` / `Agilex 7`. No XML was manually patched.

Each model retains 2345 saved module parameters. The full before/after map and exact change list are in `*.full-parameter-diff.json`, with complete XML diffs in `*.xml.diff`:

- Discrete: 116 changed parameters = 108 controller-derived values plus eight device sysinfo/trait inputs.
- RDIMM: 118 changed parameters = 110 controller-derived values plus eight device sysinfo/trait inputs.
- Every refreshed value was read back and checked against its exact paired controller source. All other original model parameters remain identical, including model-specific verbosity. Existing controller/model differences in MMR/user-mode/verbosity were not blindly copied.
- No controller or PHY was edited. Refreshes such as reference-clock derivation, timing and mode-register metadata are changes to **the external model's stale inherited inputs**, not changes to the actual controller, clock, pin assignments, calibration, or PHY.
- x64/noECC, row17/column10/BA2/BG2, separate channels, fast simulation, skip-calibration, and abstract PHY off are preserved. `MEM_INTFS_LOCATION=BOT,BOT` was read back from unchanged Work04 `mem_ss.ip`.
- All 326 inventoried Work04 memory IP/Qsys/Verilog/SystemVerilog files retained their original hashes. Original two model hashes match the earlier inspection report.

## Handoff paths

Under the remote scratch root:

- `ed_sim_mem/sim/ed_sim_mem.v`
- `ed_sim_mem/altera_emif_mem_model_191/sim/ed_sim_mem_altera_emif_mem_model_191_tododxq.v`
- `ed_sim_mem_group1/sim/ed_sim_mem_group1.v`
- `ed_sim_mem_group1/altera_emif_mem_model_191/sim/ed_sim_mem_group1_altera_emif_mem_model_191_kpsc7si.v`
- Each model's `sim/common/modelsim_files.tcl` and `sim/mentor/msim_setup.tcl`.
- `source-closure.json`, `verification.json`, `*.full-parameter-diff.json`, `*.final-generation.invocation.json`, `*.final-generation.log`, `*.final-generation.status.json`, `work04-before.json`, `work04-after.json`.

Use the ordered source lists for harness preparation; do not compile the `_bb.v` or `_inst.v` templates. The existing Work04 `mem_ss` and its finite source closure remain as recorded by `ddr-smoke-01/inspection`.

## Retained issues and corrections

Early API exploration showed no `help` command. One initial script queried a component after `save_component` had unloaded it; another used unsupported Tcl `ne`. Their nonzero results and full logs are retained. Switching the previously family-invalid model to Agilex emitted duplicate-enum assertions in the intermediate save; the subsequent fresh-process save and final generations were clean. SOPCINFO list serialization must be decoded to Tcl lists, not passed as comma strings: eleven list parameters per model were corrected and then exact readback was verified. `save_component` removed its prior generated output directory; the attempted archive of that already-removed directory failed, after which both models were actually regenerated. Intermediate wrappers remain documented in `13-readback.txt`; final outputs are the paths above.

No readiness promotion, maintained-source edits, commits, pushes, programming, calibration runs, traffic, resets, or HDL simulation occurred. Functional DDR behavior is untested; this result removes the empty-model blocker, not the missing smoke-harness or simulation acceptance requirements.
