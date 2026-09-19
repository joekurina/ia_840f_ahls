# Calibration producer packing: bounded retained-source review

## Outcome

**The representation edge cannot be closed from the finite retained inputs.** The first missing active controller modules are now identified exactly at **F51:52 → F65:818** and **F54:50 → F71:818**. The captured wrappers forward a whole `calbus_seq_param_tbl` net; they do not implement the string-to-table conversion. No padding, byte order, truncation, synthesis/simulation selection or packed-field interpretation is established. This is a concrete dependency stop, not a claim that the producer is a primitive or encrypted.

`ready_for_build=false`; no correction proposed. Slot-permutation safety, physical equivalence, calibration acceptance and generated-interface acceptance remain false. Preserve channel0 discrete/P1 16 GiB, channel1 RDIMM 16 GiB, BOT/BOT, AGFB027R25A2E2V, pins and application identity topology. Generated whole pairs remain 0→0 and 1→1; the donor's reversed whole pairs are prior context, not permission to swap anything.

## Scope and integrity

Read the live05 review/disposition and statically parsed only the retained `memory-artifacts.json` and `calibration-endpoints-live05.json` payloads. No remote access, new acquisition, Tcl/HDL/vendor execution, simulation, tests, firmware disassembly, decryption, source/pin/permission change or commit. Only the two new producer-review outputs are written.

Aliases retain the prior convention: `F<n>:line` and `L<n>:line` are decoded `files[n].content` lines, not JSON-container lines. Python verified byte lengths and SHA-256 for **all 87 captured payloads among 99 F records, and all seven L payloads**, before source inspection. Full receipt hashes:

* `memory-artifacts.json`: `a333f976a8f95024b37ad918051b379c3922bd66b91e123e09fc575e95eb60ae` (9004434 bytes).
* `calibration-endpoints-live05.json`: `1c2179d1adb8a3c16b03d30f9ac2e9034e1ab6fb2187075ceff74de1f3f8d956` (609575 bytes).

The companion JSON binds every cited payload to its original path, size and verified hash. These are capture-origin paths, not claims about current remote filesystem existence.

## 1. What the producer-side inputs actually establish

| Evidence | Controller0 | Controller1 |
|---|---|---|
| `SEQ_PT_SYN_CONTENT` | F66:39160–39167 | F72:39036–39043 |
| Serialized metadata type | `java.lang.String` | `java.lang.String` |
| Hexadecimal digit count | 560 | 600 |
| Bytes represented by paired hex digits | 280 | 300 |
| Bits represented by those hex digits | 2240 | 2400 |
| Table-width metadata | F66:51976–51983 = 4096 | F72:51852–51859 = 4096 |
| Actual visible wrapper port | F51:48 `[4095:0]` | F54:46 `[4095:0]` |

The character counts and hex-encoded byte counts were calculated from the complete XML values. They are **not** HDL expression widths: no retained HDL declaration or assignment of `SEQ_PT_SYN_CONTENT` establishes whether or how those characters become numeric data. The adjacent simulation strings exist at F66:39168–39175 and F72:39044–39051; their presence does not prove controller-side mode selection. In particular, neither zero extension of a hex literal nor packing of ASCII characters may be assumed. No output words were synthesized from these strings.

## 2. Exact active graph and missing producer edge

F61:205 and 261 instantiate the controller wrappers whose bodies are F51 and F54. The table nets are explicitly `[4095:0]` at F61:145,151; controller outputs and calibration inputs connect those same nets at F61:247,301,321,327.

* **Controller0:** F51:48 declares the output. F51:52 instantiates `mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_fm_280_bb7nfma emif_0`. F51:94 connects `.calbus_seq_param_tbl(calbus_seq_param_tbl)` directly.
* **Controller1:** F54:46 declares the output. F54:50 instantiates `mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_fm_280_gdk3rhy emif_1`. F54:90 connects the same named port directly.

These expressions contain no slice, concatenation, cast, extension or reversal. They prove whole-net forwarding at the visible wrapper, not the unseen child port declaration, driver, or a conversion inside it. A finite search of the captured HDL found no `SEQ_PT_SYN_CONTENT` occurrence and no definition of either named child module. Neither child filename is a retained payload path or captured basename in F or L.

The next literal source references are:

* **F65:818:** `altera_emif_fm_280/synth/mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_fm_280_bb7nfma.v`
* **F71:818:** `altera_emif_fm_280/synth/mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_fm_280_gdk3rhy.v`

Both are `VERILOG_FILE` assignments in library `altera_emif_fm_280`, joined to `$::quartus(qip_path)`. The companion JSON includes the exact statements and full lexical resolutions against each containing QIP directory. No Tcl was sourced. The named bodies are **uncaptured**, so this review stops there; it does not skip across them to assert that a QIP-listed architecture or sequence-interface file is the active packer. QIP listing alone is not an instantiation trace.

## 3. Distinct global initialization edge

**F77:51** names the actual synthesis GPT artifact:

`altera_emif_cal_iossm_280/synth/mem_ss_mem_ss_501_qm5zaka_emif_cal_bot_altera_emif_cal_iossm_280_th76pdq_synth_global_param_tbl.hex`

Its complete original-path resolution is recorded in the companion JSON. It is absent from both finite receipts, including basename checks. L4:180 supplies the matching basename; L4:177 sets `SEQ_USE_SIM_PARAMS="off"`, L3:28 sets `USE_SYNTH_FOR_SIM=0`, and L5:214–215 selects this synthesis filename for L5:334 `tennm_iossm.parameter_table_hex_file`. That establishes a filename edge, **not captured initialization words or proof of compiled loading**.

The adjacent `.txt` at F77:52 is L2, which explicitly says it is informational and unused in compilation/simulation (L2:1–2). It must not substitute for the `.hex`. Likewise the local controller hex references F65/F71:814 do not prove that either is the calbus producer without the missing driver body. No hex contents were invented or reconstructed.

## 4. Boundary and disposition

The previous paired endpoint trace to `tennm_iossm` remains intact; it is not repeated here. L5:324–340 names a primitive and forwards initialization/firmware parameters, rather than exposing its implementation. That opaque consumer boundary is separate from the newly localized missing controller bodies. Absence of those bodies is not evidence that they are encrypted, primitive-only, or pass-through internally.

The representation questions still needing the exact driver are: parameter declaration/type, chosen mode, character/numeric conversion if any, destination width, explicit index ordering, slice/concatenation, and any extension/truncation. Even resolving all of them would **not** resolve the primitive/firmware endpoint-identity contract, pointer units/field allocations, scheduling constraints or donor-version compatibility. Nothing here assigns meaning to `0x64` or `0x10264`, interprets local coordinates as absolute physical resources, or accepts a slot permutation.

`calibration-producer-next-reads.json` records only two immediate missing controller-module reads and the separately known GPT hex dependency. It is a bounded proposal, **not acquisition authorization**. Follow deeper dependencies only when an actually read active body supplies them; if protected source is encountered, stop without decryption and seek an authoritative documented contract. No generic scan, configuration correction, build or experiment is authorized.
