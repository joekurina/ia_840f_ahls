# Live06 calibration producer representation review

## Decision

**Live06 closes the missing outer controller bodies and captures the real synthesis GPT data, but does not close controller string-to-table packing.** Both newly read controllers are wrappers around a further, exactly named architecture. The first missing active bodies are now **F65:771 / F71:771**, not the former F65:818 / F71:818 stop. No configuration correction is justified. `ready_for_build=false`; acceptance and authorization flags remain false.

Preserve physical0 discrete/P1 16 GiB, physical1 RDIMM 16 GiB, BOT/BOT, AGFB027R25A2E2V, all pins/configurations and application identity topology. Whole pairs remain 0→0 and 1→1. Neither paired wiring nor these new representation facts prove slot-permutation safety, physical equivalence, firmware pointer semantics or donor2.7 compatibility.

## Scope, integrity and notation

Read the producer packing review/next-reads and live05 review/disposition. Static local inspection only of retained receipts; no workstation/remote access, network, new captures, recursive acquisition, vendor/Tcl/HDL execution, simulation, tests, disassembly, decryption, source/configuration changes or commits. Only the two new live06 review/disposition outputs are written. Python was used for hashing, text parsing and record arithmetic, not HDL execution or a test suite.

`C<n>:line` denotes decoded `files[n].content` in `calibration-producer-live06.json`; `F<n>` in `memory-artifacts.json`; `L<n>` in `calibration-endpoints-live05.json`. These are not JSON-container line numbers. Original paths are capture-origin paths, not current remote filesystem existence claims.

Verified before tracing:

* Live06 container: 2468875 bytes, SHA-256 `f6c5ca6b937c35820ea5f7cecf2f2b1b8bfc997e73e7817a0ed7e8936447eea5`; three records, no capture errors.
* C0: 1226881 bytes, SHA-256 `78362c6c72420dab6db4c8a07e6212d0754f020fea6b3c3ebf98ab14bc62bd1d`.
* C1: 1226673 bytes, SHA-256 `9a8787b141b8e09af6a24d495a82481314da7f5e0429d7b022bd85dae6598e26`.
* C2: 512 bytes, SHA-256 `b53faaaa5f2191f70e3ed7e2be4cbecc16c28d6ebec2de4782ac84eed1a8d7e9`.
* F container: 9004434 bytes, SHA-256 `a333f976a8f95024b37ad918051b379c3922bd66b91e123e09fc575e95eb60ae`; all 87 captured payloads among 99 records verified.
* L container: 609575 bytes, SHA-256 `1c2179d1adb8a3c16b03d30f9ac2e9034e1ab6fb2187075ceff74de1f3f8d956`; all seven payloads verified.

Each C path exactly matches the preceding QIP-derived request: C0 ← F65:818, C1 ← F71:818, C2 ← F77:51. The JSON binds cited payload paths/hashes and gives literal QIP statements and full lexical resolutions for next reads.

## 1. Active producer trace: one additional wrapper, not a packer

F51:52 and F54:50 instantiate the module declarations now present at C0:9 and C1:9. Their table outputs are explicitly `output wire [4095:0] calbus_seq_param_tbl` at C0:51 and C1:49.

| Edge | Controller0 | Controller1 |
|---|---|---|
| Architecture module instantiation begins | C0:55, `mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_arch_fm_191_ekzngaq #(` | C1:53, `mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra #(` |
| Instance name | C0:1828, `) arch (` | C1:1826, `) arch (` |
| Whole-net output connection | C0:1870, `.calbus_seq_param_tbl (calbus_seq_param_tbl),` | C1:1866, same expression |
| Width parameter override | C0:1700, `.PORT_CALBUS_SEQ_PARAM_TBL_WIDTH (4096),` | C1:1698, same expression |
| Mode-related request | C0:76, `.DIAG_SYNTH_FOR_SIM (0),` | C1:74, same expression |
| Board-memory format request | C0:69, `MEM_FORMAT_DISCRETE` | C1:67, `MEM_FORMAT_RDIMM` |

Quoted snippets omit alignment whitespace only. The only table signal-bearing code lines in each new wrapper are its output declaration and architecture-port connection; comments repeat the name. No assignment, cast, concatenation, slice or reversal of this net occurs in the wrapper. This closes the outer-child declaration and forwarding edge. It does **not** establish the architecture port declaration or actual driver inside the missing child.

### Parameter representation now actually visible in HDL

C0:98–99 and C1:96–97 use `.SEQ_PT_SYN_CONTENT ("...")` and `.SEQ_PT_SIM_CONTENT ("...")`: **quoted Verilog string literals**, not `4096'h...` or other numeric hexadecimal literals. The complete literal values are retained in the companion JSON and were compared against the respective F66/F72 SOPCINFO values; both SYN and SIM strings match for each controller.

| Literal measure, both SYN and SIM | Controller0 | Controller1 |
|---|---:|---:|
| Hexadecimal characters | 560 | 600 |
| Character storage at eight bits per character | 4480 bits | 4800 bits |
| Bytes if paired hex digits are decoded | 280 | 300 |
| Bits if paired hex digits are decoded | 2240 | 2400 |

These are distinct representations. The character-storage sizes do not establish a destination parameter width; the missing architecture declaration could determine coercion/type/width. The paired-digit quantities do not prove that a hex parser is used. Neither the fact that character storage exceeds 4096 bits nor that paired-digit decoding would fit it proves truncation, extension, zero padding or ASCII packing onto the bus. The explicit output width and width override are known; the conversion is not.

`DIAG_SYNTH_FOR_SIM=0` is now a visible controller-child request, but its implementation and local SYN/SIM choice remain unseen. The IOSSM global-GPT filename choice below is independently established; do not apply that consumer choice to this missing local controller driver.

## 2. Exact immediate missing bodies

Finite retained-payload checks found neither architecture module definition nor a captured payload with either exact resolved path. The active instantiations above, followed by these literal QIP assignments, establish the next edges (no guessed filenames):

* **F65:771**:
  ```tcl
  set_global_assignment -library "altera_emif_arch_fm_191" -name SYSTEMVERILOG_FILE [file join $::quartus(qip_path) "altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_arch_fm_191_ekzngaq.sv"]
  ```
  Exact relative path: `altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_0_altera_emif_arch_fm_191_ekzngaq.sv`.

* **F71:771**:
  ```tcl
  set_global_assignment -library "altera_emif_arch_fm_191" -name SYSTEMVERILOG_FILE [file join $::quartus(qip_path) "altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra.sv"]
  ```
  Exact relative path: `altera_emif_arch_fm_191/synth/mem_ss_mem_ss_501_qm5zaka_emif_1_altera_emif_arch_fm_191_ym4dzra.sv`.

Lexical resolution against each containing QIP directory is in the JSON; no Tcl was sourced. These are only two proposed immediate reads, **not acquisition authorization**. Read the named active body before naming a deeper dependency. Required proof remains: child parameter declarations/type/coercion, child port width, mode selection, actual table driver, conversion, ordering, slices and extension/truncation. No protected implementation was encountered in live06; missing is not evidence of encryption. If a later body is protected, stop without decryption and seek a documented contract.

## 3. Actual synthesis GPT records, independent of informational text

C2 is the exact synthesis `.hex` referenced by F77:51 and L4:180. L3:28 supplies `USE_SYNTH_FOR_SIM=0`, L4:177 supplies `SEQ_USE_SIM_PARAMS="off"`, and L5:214–215 consequently selects `IOSSM_SYNTH_GPT_HEX_FILENAME`, passed to `tennm_iossm.parameter_table_hex_file` at L5:334. This closes capture of the artifact on the existing filename edge; it does not prove compiled loading or primitive internals.

C2 contains 25 four-data-byte records and one EOF record: **100 encoded data bytes in a 512-byte text file**. Each colon-prefixed record was parsed into count, 16-bit address field, type, data and checksum; all record lengths and modulo-256 checksums validate. Data records are type00/count04; EOF is type01/count00. The complete literal and parsed record set is in the JSON.

| Decoded line | Address field | Data bytes in text order / concatenated word |
|---|---|---|
| C2:1 | `0x7400` | `00000002` / `0x00000002` |
| C2:2 | `0x7401` | `00000001` / `0x00000001` |
| C2:3 | `0x7402` | `00000001` / `0x00000001` |
| C2:4 | `0x7403` | `00000010` / `0x00000010` |
| C2:5 | `0x7404` | `0003D090` / `0x0003D090` |
| C2:6 | `0x7405` | `00000464` / `0x00000464` |
| C2:7 | `0x7406` | `00000008` / `0x00000008` |
| C2:8 | `0x7407` | `00000000` / `0x00000000` |
| C2:9 | `0x7408` | `0000001C` / `0x0000001C` |
| C2:10 | `0x7409` | `00000064` / `0x00000064` |
| C2:11 | `0x740A` | `00010264` / `0x00010264` |
| C2:12–25 | `0x740B`–`0x7418`, advancing by one | `00000000` in every record |
| C2:26 | `0x0000`, type01 | EOF, no data |

Exact decisive records:

```text
C2:10 :04740900000000641B
C2:11 :04740A000001026417
C2:26 :00000001FF
```

Thus `0x00000064` and `0x00010264` really occur as concatenated data words in the synthesis artifact, rather than merely in a report. This says nothing yet about their field allocation, pointer units, physical-interface number, slot tag or relocation.

### Address-format and endianness boundary

The envelope is Intel-HEX-style, but its data-record address fields progress **one per four-byte/32-bit word record**: `0x7400`, `0x7401`, …, `0x7418`. The informational L2:5–30 instead prints addresses advancing four per value: `0x7400`, `0x7404`, …, `0x7460`. In particular the two words are at record address fields `0x7409` / `0x740A`, versus report addresses `0x7424` / `0x7428` at L2:15–16. They are not the same address notation.

This is visible word-record progression, **not evidence of a flat byte-addressed processor memory image**. Applying an ordinary byte-addressed Intel HEX loader would make adjacent four-byte records overlap; this review does not do so. No loader body establishes address units/translation to CPU or physical space. Concatenating the four textual bytes gives the displayed word; processor-memory endianness and primitive loading behavior remain unknown. Do not multiply the whole address by four or reinterpret record fields as physical addresses without a contract.

Only after parsing the actual hex, the 25 concatenated data words were compared with the 25 reported values at L2:5–13,15–30: their ordered values agree. No data was reconstructed from L2, whose lines1–2 explicitly disclaim compilation/simulation use. This numeric agreement closes the report-versus-artifact value correspondence, not report labels' runtime semantics or a common address map.

## 4. Remaining proof and disposition

* **Closed:** formerly missing outer controller bodies, explicit 4096-bit wrapper outputs and width requests, exact quoted SYN/SIM parameter overrides, whole-net forwarding to specifically instantiated architectures, real GPT record contents/checksums and ordered numerical correspondence to the report.
* **Immediate producer stop:** the two architecture bodies at F65:771 / F71:771. Type/coercion, controller mode implementation and packing/slicing/padding remain unresolved.
* **Independent semantic stop:** L5:324–367 reaches `tennm_iossm`; live05 paired command/return/table wiring remains intact. No source here exposes its table-selection/command-selection contract or firmware interpretation of `SEQ_GPT_INTERFACE_PAR_PTRS`. Its body is absent, not proven encrypted. No primitive source path is invented.
* **Still not proven:** slot permutation, physical/coordinate equivalence, scheduling invariance, firmware pointer field meanings, address translation/processor byte order, donor2.7 compatibility or calibration behavior.
* **No corrections or authorization:** no slot swap, pointer edit, channel exchange, capacity/pin/configuration changes, donor metadata transplant, build or experiment. All readiness/acceptance/authorization flags remain false. Evidence-established booleans in the JSON are representation findings only.
