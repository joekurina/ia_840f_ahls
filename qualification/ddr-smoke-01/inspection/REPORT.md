# Work04 DDR smoke inspection — blocked on real model and harness

`ready_for_build=false`. No Quartus generation, HDL compilation, elaboration, or simulation was performed. Work04 was read only. All remote probes ran in new, owned panes of `ia840f_mailbox_monitored_01`, removed afterward; existing monitor pane was not used for commands. Only this local inspection directory was written.

Remote root: `/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_04`.

## Decisive result

The generated `ed_sim_mem` and `ed_sim_mem_group1` are **portless, empty memory models**, not runnable DDR testbenches. This is not merely a missing filename:

- `ipss/mem/qip/ed_sim/ed_sim_mem/sim/ed_sim_mem.v` instantiates a portless empty leaf; SHA256 `886b8a02de3c46cdd23306eb256df71b9a811c038c792ee89cd324bb100efc7b`.
- Leaf `ipss/mem/qip/ed_sim/ed_sim_mem/altera_emif_mem_model_191/sim/ed_sim_mem_altera_emif_mem_model_191_3rhvady.v`: 313 bytes; SHA256 `a12b1a12b25ba98a0a4ca05e3c9641c42247b1b6948f7c0d1fd81bf3048c2c19`.
- Group1 leaf `ipss/mem/qip/ed_sim/ed_sim_mem_group1/altera_emif_mem_model_191/sim/ed_sim_mem_group1_altera_emif_mem_model_191_gbuniiy.v`: 327 bytes; SHA256 `6e74ff3586dfedeee468f8852c96ac737ba3f9f7c82daf21274fd14e1c89621d`.
- Both generation reports explicitly warn: `This module has no ports or interfaces`, despite successful generation.
- Both saved model IPs have empty `SYS_INFO_DEVICE_FAMILY`, `FAMILY_ENUM=FAMILY_INVALID`, and empty derived `PHY_CONFIG_ENUM`. The installed model composition callback returns immediately when `SYS_INFO_DEVICE_FAMILY == ""`. This is a concrete source-supported cause of the empty model, not a reason to fabricate its ports.
- The reports already used `--family="Agilex 7" --part=AGFB027R25A2E2V`; simply repeating those CLI flags is not a demonstrated repair.
- Model IP SHA256: `ed_sim_mem.ip` = `c12a49e5752453ad6a89fb4a05f31fa43274b7972262a7f3820562c2b86aba65`; `ed_sim_mem_group1.ip` = `8880c23dc3742d2277542b7eba82733411a697f2638ddd5cd3e250d3b0e5780e`.

Vendor callback: `/opt/altera/26.1.1/ip/altera/emif/ip_mem_model/ip_top/main.tcl`, SHA256 `fad4ba640a0d03e8df2564f662a08862c74f7deb6f1018ec0cb7965594ca0b41`. See `07-missing.txt` for exact source.

## Actual DUT and finite dependencies

`ipss/mem/qip/mem_ss/mem_ss/sim/mem_ss.v`, SHA256 `f5fd9ee05e8cf89c202039c0bc6d5950b55aace9d0447402da17bf46c9e14e75`, provides:

- Separate `i0_*` and `i1_*` AXI interfaces: 34-bit byte addresses, 512-bit data, 64-bit strobes, 9-bit IDs, 8-bit lengths, 3-bit sizes, 14-bit AW/AR user fields; ready/valid, response, last signals are present.
- Separate `mem0_*` / `mem1_*` x64 DDR4 physical buses, DQS/DBI width 8, row address width 17, BA/BG width 2, one CK/CS/CKE/ODT.
- Separate output `mem{0,1}_ss_app_usr_clk`, `mem{0,1}_ss_app_usr_reset_n`, calibration success/fail.
- Reset inputs `app_ss_rst_req`, `app_ss_cold_rst_n`; outputs `ss_app_rst_rdy`, `ss_app_cold_rst_ack_n`.
- Generated EMIF readmes specify 33.333 MHz reference clocks, discrete group0 and RDIMM group1, both x64. Preserve independent 16GiB/noECC and BOT/BOT configuration; no pin or calibration edits were made.

Evaluated only the generated Tcl **list-returning functions** with `tclsh`, never the compile/simulation commands. `source-closure.json` contains the exact ordered commands and all source hashes: 124 existing unique HDL source paths for mem_ss, 2 for each (currently empty) model. Five mem_ss initialization HEX files also exist and are hashed in `08-deps.txt`; generated DPI list is empty. This is finite generated-source inventory, not proof of successful elaboration or complete device-library resolution.

## Acceleration and existing stimulus

Both actual EMIF wrappers set `DIAG_FAST_SIM=1`, `DIAG_USE_ABSTRACT_PHY=0`; generated readmes specify `SIM_CAL_MODE_SKIP`. Fast simulation selects a faster PLL model; it does **not** justify omitting external memory when abstract PHY is disabled. Retain these settings, do not enable full calibration or force calibration signals.

A broader Work04 scan found `ofs-common/src/common/mem_tg/tg_axi_mem/mem_ss_tg/mem_ss_tg_axi_100/sim/altera_emif_avl_tg_2_tb.sv`. It is a TG configuration example, **not a closed Work04 DDR harness**: it instantiates nonexistent `ed_sim`, expects `ed_sim_inst.tg_cfg_bfm0.tg_cfg_bfm0`, and requires TG parameter/configuration macros. Its unmodified traffic is larger than needed. No `module ed_sim` declaration or `params.tcl` exists anywhere under Work04. The initial file inventory covered 5565 files. Do not claim no testbench exists anywhere; the concrete discovered testbench is unusable as-is.

Installed vendor instructions `/opt/altera/26.1.1/ip/altera/emif/ip_top/ex_design/readme.txt` describe `quartus_sh -t make_sim_design.tcl VERILOG`, but installed `make_sim_design.tcl` explicitly sources sibling `params.tcl`, absent from Work04 and the listed installed template directory. Therefore running the bare installed template is **not** a functioning next command. Full example generation brings its own TG/checker and is not required for the minimal hand-written smoke.

## Exact missing harness / smallest next experiment

1. In a **fresh scratch copy only**, repair the two model components' missing family/sysinfo using the supported Platform Designer component/system workflow. Inspect installed API/help and existing reviewed generation runners before choosing commands. Match family and derived DDR4 parameters to the generated EMIF configuration; do not change topology, pins, clocks, calibration, or the preserved Work04 outputs. Acceptance: nonempty DDR4 pin ports and instantiated `altera_emif_mem_model_core_ddr4`, with its actual parameterized wrapper and seven vendor model RTL dependencies. Recheck both discrete0/RDIMM1 pairings and source hashes. No speculative vendor command is supplied as executable proof.
2. Supply a new `tb_mem_ss_smoke.sv` around **the actual mem_ss module**, two repaired memory models, both reference clocks, initial cold-reset sequence following the reset-controller source, and one finite AXI master/scoreboard per channel. This file currently does not exist; no fake runnable runner was created.
3. Minimal traffic: two aligned single-beat full-strobe writes per channel at byte addresses 0 and 64 with channel-distinct 512-bit patterns; read back both only after write responses. AWLEN/ARLEN=0, AWSIZE/ARSIZE=6, INCR bursts. Hold AW/W/AR independently until their handshakes; check BID/RID, OKAY responses, RLAST, every data bit, and absence of X/Z in accepted results. No random traffic, repeated resets, error injection, or calibration-detail checks. Fail immediately on either calibration failure; wait boundedly for both user resets to release and calibration-success outputs before issuing traffic.
4. Proposed hard caps, to be validated rather than claimed observed: 1 ms simulation watchdog, 4096 user-clock cycles per AXI response/transaction wait, 120 s elaboration/run wall-clock timeout. One initial reset only. If startup exceeds the bound, report timeout rather than silently extending or switching to full calibration.
5. Compile in fresh scratch with `/opt/altera/26.1.1/questa_fe/bin`, isolated modelsim.ini containing `[vsim] VoptFlow=1`, existing license `/home/uwb_student00/quartus_26/LR-191011_License.dat` via SALT/LM/MGLS variables. Use generated library names/order, copy the five declared initialization files into the run cwd, then elaborate the actual testbench rather than `ed_sim_mem.ed_sim_mem` or `mem_ss.mem_ss`. Generated msim scripts recommend a custom top-level script and not modifying generated scripts. Do not source multiple scripts and assume overwritten `com` aliases compile all IP; invoke each source closure explicitly in order and retain all libraries at elaboration.
6. Acceptance is explicit scoreboard completion on both channels plus nonzero failure exit for timeout, simulator error, fatal or mismatch. An empty-model `run -a` terminating normally is never a DDR pass. Keep `ready_for_build=false` regardless of this smoke result.

## Evidence and reproduction

`01-inventory.txt` through `08-deps.txt` are captured remote source/probe output. `source-closure.json` was parsed and count-checked against the returned 124/2/2 command totals. `probe.py` and each `*_probe.py` reproduce read-only inspection through the required tmux session. Example local invocation from `/home/joe`:

```sh
python3 Projects/Thesis/AHLS/new_bsp/new/qualification/ddr-smoke-01/inspection/probe.py \
  Projects/Thesis/AHLS/new_bsp/new/qualification/ddr-smoke-01/inspection/final_probe.py \
  Projects/Thesis/AHLS/new_bsp/new/qualification/ddr-smoke-01/inspection/07-missing-repeat.txt
```

No maintained file, readiness flag, Git commit, or generated Work04 output was modified. No simulator execution result is claimed.
