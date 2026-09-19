# Byte-to-line bench spec review

**Verdict: NOT READY as packaged — two static compilation/dependency defects.** The behavioral oracle is consistent with the unchanged combinational DUT. No HDL compile, elaboration or simulation was performed; actual checked simulation cycles remain **0**, not 154.

## Blocking findings

1. **Missing required configuration macro.** `ofs_plat_if_top_config.vh:4-7` defines only its guard and `AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU`. However, the unchanged umbrella `ofs_plat_if.vh:23` unconditionally includes `ofs_plat_clocks.vh`; that header's non-multiplexed `t_ofs_plat_std_clocks` declaration uses `OFS_PLAT_PARAM_HOST_CHAN_NUM_PORTS` without a guard around its use. Neither `sources.f` nor `run.py:65-67` supplies the macro. This is an undefined preprocessor macro in active source, even though no clock interface is instantiated. Disabling board class wrappers and legacy compatibility does not eliminate this dependency.

2. **Missing actual CCI-P package and its configuration dependencies.** `ofs_plat_if.vh:24` unconditionally includes `ofs_plat_host_ccip_if.vh`, which executes `import ccip_if_pkg::*;` at line 40. The package is absent from `sources.f:9-12` and `run.py:19-20,35`. The real PIM package exists at `ifc_classes/host_chan/afu_ifcs/ccip/ccip_if_pkg.sv` beneath the recorded PIM RTL root; it must precede the interface and DUT. Its lines 13, 17 and 22 additionally require `OFS_PLAT_PARAM_HOST_CHAN_NUM_PORTS`, `OFS_PLAT_PARAM_HOST_CHAN_DATA_WIDTH` and `OFS_PLAT_PARAM_HOST_CHAN_MMIO_ADDR_WIDTH`. All are absent from the fixture. An empty substitute package or suppression of the real umbrella header is not an acceptable dependency repair. Include and hash the actual package in the execution manifest; the original ten-input manifest is intact but incomplete as a compilable dependency closure.

These are source-derived findings, not invented Questa diagnostics. No source was changed to repair them.

## Behavioral/self-check review

- `tb.sv:6-12` instantiates the real PIM Avalon interfaces and real adapter with consistent 512-bit/64-byte geometry, 16-bit byte addresses, 10-bit line addresses, seven-bit counts, eight-bit users, default two-bit response codes and zero waitrequest allowance. This is explicitly a unit fixture, not a board ABI.
- `cycle()` drives after the falling edge, checks settled combinational outputs, and updates storage after the rising edge. Its independent divide/modulo address oracle matches the adapter's shift/mask contract. Case-equality field checks reject unknown forwarded values for these known stimuli. All addresses fit the storage arrays.
- Request enables deliberately remain asserted through downstream stalls when aligned and out of reset; acceptance is gated by waitrequest, not by suppressing the forwarded command. The expected/observed byte-masked arrays are independently updated from stimulus and DUT outputs, respectively. Full, alternating and zero masks, stalled writes and highest aligned address are covered.
- Alignment is checked on every asserted request cycle, including deliberately malformed later burst beats and changes during stalls. Every nonzero byte offset is exercised for both read and write. The offset sweep alternates stall polarity; it does not test both stall polarities for each individual request/offset pair. Explicit burst cases additionally cover stalled and unstalled bad requests.
- Both response channels, independent status/user values, simultaneous responses, reset-time response forwarding, and both clock levels are checked. The synthetic response/storage fixture is correctly disclaimed as not a downstream burst memory implementation.
- **Coverage wording limitation:** `tb.sv:103` named `reset mid stalled write` asserts write, stall and reset together after an idle response cycle at line 102. It tests reset/stall overlap, not reset interrupting an already-held stalled write. If that temporal transition is required, add a preceding cycle with the same write/address/data, stall=1 and reset_n=1 in a separately authorized fixture revision; otherwise describe the existing coverage as overlap only. No stateful reset recovery qualification follows from this bench.
- Static expansion of the fixed calls/loops yields **154 planned cycles**. The existing bench's expected terminal marker is `PASS scenarios=154 checks=160007`. Neither number is an execution result.

## Minimum prospective Questa execution guidance

`run.py` is a Verilator-only runner: finding `vlog`/`vsim` does not select Questa. Do not use it for the remote Questa run or to overwrite the preserved local absent-simulator evidence. Its generic absence message can be misleading on a Questa-only host. Use a fresh execution directory and a distinct remote result record.

The following is a **proposed, unexecuted** command shape for an installed Questa environment. Let `Q` be the qualification directory and `PIM` the actual PIM RTL root on the execution host. If remote paths differ, create a separate path-remapped file list; the current `sources.f` contains absolute local paths. Resolve/hash the real sources before execution. The three numeric definitions below are **synthetic compile-only fixture values**, not board geometry or ABI claims. They satisfy otherwise-unused umbrella/package declarations without activating host/local/HSSI class wrappers.

```sh
# Run in a fresh scratch directory, not the preserved qualification directory.
vlib work
vlog -sv -timescale 1ns/1ps -work work \
  +define+OFS_PLAT_PARAM_HOST_CHAN_NUM_PORTS=1 \
  +define+OFS_PLAT_PARAM_HOST_CHAN_DATA_WIDTH=512 \
  +define+OFS_PLAT_PARAM_HOST_CHAN_MMIO_ADDR_WIDTH=18 \
  "+incdir+$Q" \
  "$PIM/ifc_classes/host_chan/afu_ifcs/ccip/ccip_if_pkg.sv" \
  -f "$Q/sources.f"
vsim -c -onfinish exit work.tb \
  -do 'onerror {quit -code 1}; onbreak {quit -code 1}; run -all; quit -code 1'
```

The file list already supplies the remaining order: actual log package, actual Avalon interface, actual DUT, bench; it also supplies the required header directories. Do not define `SYNTHESIS` or disable the interface validation blocks. Confirm option compatibility against installed Questa help/version when executing. Apply outer wall-clock bounds and preserve exact expanded argv, version, compile/simulation logs and return codes. Do not run simulation if compilation fails. Require successful process exits **and** the unique expected PASS marker, exactly sequential CHECKED entries 1 through 154, no fatal/error diagnostics, and unchanged input hashes. The final `quit -code 1` is a fail-closed fallback if simulation returns without reaching `$finish`; the transcript/count gate remains mandatory regardless of simulator exit semantics.

Adding the actual CCI-P package and explicit command-line fixture definitions permits attempting compilation without modifying the maintained DUT/PIM sources or this bench, but constitutes an expanded execution manifest that must be recorded. This guidance is not a claim that the command has compiled successfully.

## Verification and changes

Read REPORT.md, tb.sv, run.py, source/configuration manifests, real DUT, real interface, umbrella/include dependencies and the missing real CCI-P package. Independently rehashed all ten recorded original inputs: sizes/hashes match and before/after manifests agree. All fifteen existing artifact manifest entries also match. Python AST parsing of run.py succeeds; this is not HDL syntax checking.

Only `spec-review.md` was created. No maintained source, fixture, runner, manifest or existing result was modified. No workstation contact, installation, simulator execution or commit occurred.
