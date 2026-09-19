# Byte-to-line adapter unit simulation preparation

**Result: BLOCKED — no local HDL simulator discovered. Actual checked scenarios: 0.**
No compile, elaboration or simulation pass is claimed. The authored bench has not been syntax-checked by an HDL simulator.

## Evidence

Runner invocation (local, working directory `/home/joe`):

```
python3 /home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/byte-line-protocol-01/run.py
```

Runner return code: **2**. Compile and simulation return codes: **not applicable / not run**. Python: 3.13.5 (GCC 14.2.0). `discovery.log` preserves PATH and actual `command -v` results: verilator, iverilog, vvp, vsim, vlog, xrun, vcs and slang were all absent. An additional filename search under `/opt` found no verilator/iverilog/vsim/vlog files. No packages installed and no workstation contacted. Simulator version is unavailable, not invented.

`result.json`, `runner.log`, `invocation.json`, `compile.log`, `simulation.log`, `version.log` and `argv.json` preserve the actual outcome. Empty simulator `argv.json` means no simulator process was invoked; it is not a pass. `run.py` contains the exact prospective Verilator `--binary --timing --assert` command and records expanded argv if a future authorized run finds it. Timeouts are 180 seconds compile, 30 seconds execution, plus a 100 us testbench watchdog.

The DUT and nine actual PIM source/header dependencies were hashed before and after runner execution, and independently rehashed afterward. All ten were unchanged. Full original paths, sizes and SHA-256 values are in `original-inputs.before.json` and `original-inputs.after.json`. The bench source list references original files directly; no DUT or interface replacement is used. `artifact-sha256.json` binds the prepared files (excluding itself).

## Prepared test — not executed

One bench, `tb.sv`, instantiates the real `ofs_plat_avalon_mem_if` on both sides of the real `ahls_avmm_byte_to_line`. Test geometry: 512-bit data, 64 byte enables, 16-bit byte address / 10-bit native-beat address, seven-bit burst count, eight-bit user metadata, two-bit independent response codes, zero waitrequest allowance. This is a unit-test geometry, not a board interface declaration.

154 planned checked cycles, independently counted from the fixed calls and deterministic loop bounds:

- Aligned read/write, full/alternating/zero byte masks, partial-write storage scoreboard, highest aligned address.
- Read burst counts including 127, a three-beat write burst with intervening stalls, a three-response read fixture.
- Downstream waitrequest held and released; no accepted write may change scoreboard storage while blocked.
- Initial misaligned reads/writes, later write-burst misalignment, misalignment while stalled and an aligned stalled write changed to misaligned. These deliberately malformed stimuli must fault and stall rather than relying on a first-beat-only Avalon assumption.
- Every nonzero sub-beat byte offset for read and write with varying downstream stalls.
- Request user and both response user/status/valid channels, including simultaneous read/write responses.
- Clock/reset/instance forwarding, reset suppression of requests and reset while stalled. Response forwarding remains checked during reset, matching this combinational adapter's contract.

Every cycle checks all forwarded fields with case equality and updates separate expected/observed byte-masked storage arrays. Storage is a **synthetic downstream scoreboard fixture**, not a full Avalon burst memory implementation: the explicit burst tests validate pass-through count/data/gating and acceptance across cycles, not a downstream memory controller's burst-address increment semantics. Responses are deterministic test fixtures, not hardware results.

`ofs_plat_if_top_config.vh` is an explicitly labeled **unit-test configuration fixture** because the checked source tree has no generated file of that name. It defines no host/local/HSSI board classes and disables legacy top-level compatibility inclusion. The actual PIM umbrella header, interface, macros and log package are retained unchanged, including interface assertions. This configuration is not BSP generation or integration certification.

## Boundary

Only normalized adapter unit behavior is targeted. Full AHLS AFU, CDC, generated board/PIM integration, hardware, UUID/application ABI and BSP readiness are out of scope. No maintained source, references or active worktree were modified; all created files are beneath this qualification directory. No commits or pushes. A supported local simulator is required before any scenario can be reported as verified.
