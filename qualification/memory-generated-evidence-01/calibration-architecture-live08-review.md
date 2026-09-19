# Live08 calibration architecture/top static review

## Disposition

**The captured active controller path selects `SEQ_PT_SYN_CONTENT` for both channels and forwards it to `altera_emif_arch_fm_io_tiles_wrap`. The string-to-4096-bit table producer remains uninspected inside or below that missing wrapper.** `ready_for_build=false`; no configuration correction, permutation acceptance or execution/acquisition authorization follows.

Preserve channel0 discrete/P1 16 GiB, channel1 RDIMM 16 GiB, BOT/BOT, AGFB027R25A2E2V, all pins/parameters and application identity topology. Paired wiring, string representation and mode selection do not prove slot permutation safety, firmware GPT meanings, physical equivalence, scheduling invariance or donor2.7 compatibility.

## Evidence and integrity

Notation uses **one-based decoded payload lines**, never JSON-container lines: A0/A1 = `files[0/1].content` in `calibration-architecture-live07.json`; T0/T1 = corresponding `calibration-architecture-top-live08.json`; C = `calibration-producer-live06.json`; F = `memory-artifacts.json`; L = `calibration-endpoints-live05.json`. Paths are capture-origin identities, not current remote existence claims.

Independently recomputed container sizes/SHA-256 and every available payload size/SHA-256 in these five receipts. New containers match the supplied identities:

| Receipt | Bytes | SHA-256 | Verified payloads / records |
|---|---:|---|---:|
| A | 498684 | `b8a12ad3709ef14bd7ac476e36890594e46d4fb43b88f4187376ceb3699aa4a2` | 2 / 2 |
| T | 584708 | `dfe6940463bcafe08339ae80ef2edd5d0289b41284a355fe612187112df4aff1` | 2 / 2 |
| F | 9004434 | `a333f976a8f95024b37ad918051b379c3922bd66b91e123e09fc575e95eb60ae` | 87 / 99 |
| C | 2468875 | `f6c5ca6b937c35820ea5f7cecf2f2b1b8bfc997e73e7817a0ed7e8936447eea5` | 3 / 3 |
| L | 609575 | `1c2179d1adb8a3c16b03d30f9ac2e9034e1ab6fb2187075ceff74de1f3f8d956` | 7 / 7 |

A0/A1 are 244349 bytes each; T0/T1 are 287142 bytes each. Their exact paths/hashes are bound in the companion disposition. A/T/C/L report no capture errors; F remains partial, not a complete generated tree. Read the prior live06 review and disposition without editing either. Only static local hashing/text inspection was performed: no network, workstation access, new capture, vendor/HDL/Tcl execution, tests, decryption, disassembly, source/configuration edits or commits. The initially attempted bare `python` was unavailable; `python3` and the tool's Python kernel performed parsing only.

## Citation audit: the reported discrepancy is not reproduced

The retained F65/F71 payloads actually place **`*_top.sv` at line770 and architecture `*.sv` at line771**. This was checked both by LF splitting and `splitlines()`; neither payload contains other line separators. Thus the prior live06 citation F65:771 / F71:771 to the architecture body is correct for this exact F hash. The task's stated parent result assigning `_top.sv` to line771 is not supported by these retained bytes. Do not silently change prior evidence to match it.

- F65:770 → `altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_arch_fm_191_ekzngaq_top.sv` → T0.
- F65:771 → `altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_arch_fm_191_ekzngaq.sv` → A0.
- F71:770 → `altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra_top.sv` → T1.
- F71:771 → `altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra.sv` → A1.

Each is a literal `SYSTEMVERILOG_FILE [file join $::quartus(qip_path) "..."]` assignment, lexically resolved against its containing QIP directory and matched exactly to the capture path. Full literal statements are retained in the new JSON. This records the audit outcome; it does not modify the old review.

## Active parameter, width and whole-net trace

The A/T line positions below apply independently to both indexed payloads.

| Boundary | Source-grounded edge |
|---|---|
| Outer controller → architecture | C0:55 / C1:53 instantiate the modules declared at A0:1 / A1:1, with instance `arch` at C0:1828 / C1:1826. |
| Parameter form | C0:98–99 / C1:96–97 supply quoted SYN/SIM literals. A0/A1:44–45 declare `parameter SEQ_PT_SYN_CONTENT = ""` and `parameter SEQ_PT_SIM_CONTENT = ""`: no explicit type or range, not `parameter string` and not a 4096-bit declaration. |
| Architecture → top | A0/A1:2048 instantiate their respective `*_top`, declared at T0/T1:20; `arch_inst` at A0/A1:3822. SYN/SIM forward unchanged at A0/A1:2091–2092 to untyped T0/T1:84–85 parameters. |
| Mode | C0:76 / C1:74 request `DIAG_SYNTH_FOR_SIM=0`; A0/A1:22 declare it and :2069 forward it to T0/T1:67. A0/A1:3821 explicitly override top `SEQ_USE_SIM_PARAMS` to `"off"` (declaration T0/T1:83). |
| Width | C0:1700 / C1:1698 request 4096. A0/A1:1646 declare the width parameter and :3693 forward it. T0/T1:91 default to 1, but the actual override is 4096. Top output at :2183 is `[PORT_CALBUS_SEQ_PARAM_TBL_WIDTH-1:0]`, hence `[4095:0]` on this path. Architecture output is explicitly `[4095:0]` at A0/A1:2042. Outer outputs are `[4095:0]` at C0:51 / C1:49. |
| Whole-net table connection | C0:1870 / C1:1866 connect `.calbus_seq_param_tbl(calbus_seq_param_tbl)`; A0/A1:4090 repeat that whole-net connection. T0/T1:3503 connect child `.cal_bus_seq_param_tbl(calbus_seq_param_tbl)`—note the child's extra underscore. No slice, cast, concatenation or reversal is present on these explicit connections. |
| Missing producer-side child | T0/T1:2957 instantiate `altera_emif_arch_fm_io_tiles_wrap`, named `io_tiles_wrap_inst` at :3473. Selected content passes at :3354, width at :3407 and diagnostic mode at :2958. The child's declaration/direction/type/actual driver are not captured. |

### Mode selection is now visible, independently of the IOSSM filename choice

T0/T1:2227 reads exactly:

```systemverilog
localparam SEQ_PT_CONTENT = (SEQ_USE_SIM_PARAMS == "on") ? SEQ_PT_SIM_CONTENT : ((DIAG_SYNTH_FOR_SIM) ? SEQ_PT_SIM_CONTENT : SEQ_PT_SYN_CONTENT);
```

For the captured instantiated values `"off"` and `0`, the selected branch is **SYN** for each controller. If `SEQ_USE_SIM_PARAMS == "on"`, SIM wins; otherwise a true diagnostic mode selects SIM; otherwise SYN. This is static source-expression evaluation, not successful elaboration or simulation. The nearby `ENABLE_SIM_PARAMS_FOR_SIM` preprocessor block at T0/T1:2217–2225 controls abstract-PHY override, not this table selector; it does not justify replacing the explicit `"off"` with `"on"`.

Untyped parameter/localparam declarations now close the prior missing declaration-form evidence, but they are not a parser and do not declare a table-width conversion. Controller0's selected literal has 560 characters (4480 character-storage bits, or 2240 bits if hexadecimal digit pairs were decoded); controller1 has 600 (4800 versus 2400 bits). These distinct representations must not be conflated. Neither the 4096-bit output width nor the ternary establishes ASCII bus packing, hex parsing, word/byte order, padding, truncation or reversal. T0/T1:3354 only passes the selected parameter into the missing child. No table conversion function or direct assignment to the table is shown at these explicit edges.

The independent IOSSM chain still selects its synthesis GPT file using L3:28, L4:177,180 and L5:214–215,334. It does not implement this local-controller packing. L5:292,294,360,367 preserve the two table-index edges; neither this nor the previously captured C2 GPT words establishes `SEQ_GPT_INTERFACE_PAR_PTRS` field allocation, pointer units, slot tags, relocation, loading address translation or CPU byte order.

## Finite next missing edge only

For **each** channel, T0/T1:2957,3354,3407,3473,3503 establish the active next child. F65:791 / F71:791 each contain exactly:

```tcl
set_global_assignment -library "altera_emif_arch_fm_191" -name SYSTEMVERILOG_FILE [file join $::quartus(qip_path) "altera_emif_arch_fm_191/synth/altera_emif_arch_fm_io_tiles_wrap.sv"]
```

The exact two full lexical paths are in `next_reads` in the JSON; the common prefix is the corresponding QIP directory, not an inferred vendor installation. Finite inspection of 114 retained `files[].content` records across the evidence directory found neither exact-path payload nor a `module altera_emif_arch_fm_io_tiles_wrap` definition. Both copies remain missing; a shared basename is not evidence that their bytes are identical.

Required next proof is the wrapper's `SEQ_PT_CONTENT` declaration/coercion, `cal_bus_seq_param_tbl` direction/width and actual driver or active forwarding edge, including conversion, ordering, padding and truncation. **Do not request the adjacent `io_tiles.sv` merely because it appears in the QIP:** its active instantiation below the missing wrapper has not been established. No deeper filenames, automatic recursion or acquisition authorization are supplied. Missing does not mean encrypted; stop at protected material without decryption and seek a documented contract.

The separate consumer-semantic stop remains the `tennm_iossm` boundary (L5:324–367), not a guessed source path. Local SYN selection is established; table packing and runtime calibration/firmware semantics are not. All acceptance and authorization gates remain false.
