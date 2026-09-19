# Live10 calibration table producer: readable boundary closure

## Disposition

**The retained readable producer trace reaches `tennm_tile_ctrl`; no further adjacent-source chase is required by this review.** Both channels select their own SYN content, forward it unchanged through the readable hierarchy to primitive parameter `ioaux_param_table`, and select the primary tile's `param_table_data` connection for the 4096-bit table output. This closes the readable instantiation/connection trace, **not** the primitive's representation contract, successful compilation or runtime calibration. `ready_for_build=false`; all acceptance and authorization gates remain false.

Preserve AGFB027R25A2E2V, channel0 discrete/P1 16 GiB, channel1 RDIMM 16 GiB, BOT/BOT, generated whole pairs 0→0 and 1→1, application identity topology, pins and parameters. Tile index 1 is local within each controller, not a request to exchange channels or calibration slots. No permutation safety or donor2.7 compatibility follows.

## Integrity and citation convention

Citations are one-based decoded LF payload lines, with zero-based `files[]` record indices: W=`calibration-tiles-wrap-live09.json`, I=`calibration-tiles-live10.json`, A=`calibration-architecture-live07.json`, T=`calibration-architecture-top-live08.json`, C=`calibration-producer-live06.json`, F=`memory-artifacts.json`. W0/I0 belong to channel0; W1/I1 to channel1. Capture-origin paths are identities, not assertions of present remote existence.

Independently recomputed all six container sizes/hashes and all 98 available content payload sizes/hashes; every payload matches its recorded metadata. A/T/C/F containers match the prior live08 disposition; W/I match the supplied identities. F remains a partial inventory (87 available content payloads in 99 records), not a complete generated tree. W/I/A/T/C have empty capture-error lists. Exact paths, complete receipt hashes and four new payload identities are in the companion JSON.

| New receipt | Bytes | SHA-256 | Payloads |
|---|---:|---|---|
| W | 276527 | `29b1b58e8770f751e5c84f3aba28a7b4f66e6ebc96ddc31cbfdabb172e5e20de` | two, 135701 bytes each |
| I | 411431 | `b14153e7ae5b58a9b79a1a41c91db867d1441315d5e2b6ee76fd692a90ba6083` | two, 201854 bytes each |

W0/W1 independently hash to `de2dd76c686985796b8745234040b88382a067a79e524a3e4455708d4622e862`; I0/I1 independently hash to `f642fb874d1a44ba6620e233e4d2800bd0f7148e32fad9be5e63435922ed959c`. Equal bytes do not erase the separate channel paths or distinct instantiated parameters.

F65/F71:791 name the wrapper; :792 name the tiles file. Each literal `SYSTEMVERILOG_FILE [file join $::quartus(qip_path) "..."]` resolves lexically from its own QIP directory to the exact captured channel path. The JSON retains all four full literal statements. The earlier top-line correction is settled by `parent-live08-disposition.md`: top is :770, architecture body :771. Those retained literals were rechecked; no old evidence was edited.

## Readable source trace

The W/I citation positions below apply to both independently verified copies.

| Edge | Evidence and limit |
|---|---|
| Selected content | C0:76 / C1:74 supply `DIAG_SYNTH_FOR_SIM=0`; A0/A1:3821 supply top `SEQ_USE_SIM_PARAMS="off"`. T0/T1:2227 therefore selects `SEQ_PT_SYN_CONTENT`. The channel literals remain distinct (560 and 600 characters). |
| Top → wrapper | T:2957 instantiates `altera_emif_arch_fm_io_tiles_wrap`, named `io_tiles_wrap_inst` at :3473. :3354 forwards `SEQ_PT_CONTENT`, :3407 forwards width, :3503 explicitly connects `.cal_bus_seq_param_tbl(calbus_seq_param_tbl)`. |
| Wrapper declaration | W:437 is `parameter SEQ_PT_CONTENT = ""`, untyped/unranged, not an explicit `string` or table-width declaration. W:626 is `output logic [PORT_CALBUS_SEQ_PARAM_TBL_WIDTH-1:0] cal_bus_seq_param_tbl`. |
| Wrapper → tiles | W:747 instantiates `altera_emif_arch_fm_io_tiles`; :1145 forwards content, :1198 width; instance is `io_tiles_inst` at :1200. **The table port is connected by `.*` at :1243**, not a fabricated explicit named connection. Same-named W:626 and I:951 ports establish the readable wildcard binding. |
| Tiles declaration | I:830 is the same untyped/unranged `SEQ_PT_CONTENT` parameter. I:951 declares the table as an output logic vector. I:1071 declares `logic [NUM_OF_RTL_TILES-1:0][PORT_CALBUS_SEQ_PARAM_TBL_WIDTH-1:0] tile_param_tables;`—two packed dimensions, not an unpacked array. |
| Primary selection | I:1315 is exactly `assign cal_bus_seq_param_tbl = tile_param_tables[PRI_AC_TILE_INDEX];`. It selects one complete packed element, without a cast, concatenation, byte reversal or bit slice within the element. |
| Primitive input | I:1332 instantiates `tennm_tile_ctrl`; :1335 supplies `.ioaux_param_table(SEQ_PT_CONTENT)` and :1336 supplies `.param_table_valid((tile_i == PRI_AC_TILE_INDEX) ? "true" : "false")`. The same content is passed to each generated tile; the validity parameter differs. |
| Producer-side port connection | Primitive instance `tile_ctrl_inst` is named at I:1706; :1756 connects `.param_table_data(tile_param_tables[tile_i])`. This is the producer endpoint of the readable wiring. Its formal port direction/width and implementation require the primitive contract: no primitive declaration was found in the six reviewed receipts. Do not promote the connected net's dimensions into an independently verified primitive port declaration. |

The primitive's selected instance, relative to each top, is `io_tiles_wrap_inst.io_tiles_inst.tile_gen[1].tile_ctrl_inst`. The source-selected return path is `param_table_data` → `tile_param_tables[1]` → tiles output → wrapper wildcard-bound output → top explicit output connection. The prior architecture/controller whole-net connections remain as documented in live08. No readable stage on these edges parses or transforms content into the table; the unresolved representation boundary is now the primitive, not a missing wrapper.

## Actual overrides and generate guards

| Property | Channel0 | Channel1 | Forwarding/declaration citations |
|---|---|---|---|
| `NUM_OF_RTL_TILES` | 3 at C0:104 | 3 at C1:102 | A:50,2097 → T:624,3359 → W:45,1150 → I:433 |
| `PRI_AC_TILE_INDEX` | 1 at C0:109 | 1 at C1:107 | A:55,2102 → T:626,3361 → W:47,1152 → I:435 |
| Table width | 4096 at C0:1700 | 4096 at C1:1698 | A:1646,3693 → T:91,3407 → W:473,1198 → I:828 |
| `DIAG_USE_ABSTRACT_PHY` | 0 at C0:80 | 0 at C1:78 | A:26,2073 → T:77,2221–2225,3469 → W:538,1199 → I:863 |

Thus the declared tile table net is `[2:0][4095:0]`; the selected element and each readable table output are `[4095:0]`. These are static substitutions, not elaboration results. Defaults such as primary index −1 and width 1 do not apply to these captured instances.

I:1316–1319 generates `tile_gen` for `tile_i=0; tile_i<NUM_OF_RTL_TILES; ++tile_i`: three primitive instances with indices 0, 1, 2. There is no primary-only instantiation guard: the `param_table_valid` parameter is the string `"true"` for tile 1 and `"false"` for tiles 0 and 2. Its behavioral meaning, and behavior for invalid tiles, remain primitive-contract questions. I:1123–1127 is a separate ping-pong clock generate block; it does not enclose the table producer.

W:747–1244 instantiates the real tiles unconditionally. W:1246–1248 separately begins an abstract-PHY generate branch guarded by `DIAG_USE_ABSTRACT_PHY==1`, after the real instance. T:2221–2225 either retains the requested abstract-PHY value or forces zero, so the captured request of zero disables that separate abstract branch in either case. T:2957 is outside the preceding HPS generate, which ends at :2789. Neither abstract-PHY nor HPS condition removes this readable table producer. These are source-level guard findings, not tool-validated compilation behavior.

## Required vendor contract, not more guessed paths

The finite retained-source trace is closed at `tennm_tile_ctrl`. No primitive pathname is supplied or guessed; no source acquisition, protection bypass or decryption is requested. The absence of a retained primitive declaration does not prove encryption. Seek an authoritative version/device-matched vendor contract addressing:

1. **Parameter representation and coercion:** declared type/range and supported syntax of `ioaux_param_table`, interpretation of the supplied SYN literals, any language/tool coercion at the primitive boundary, accepted lengths and invalid-input handling. A parameter name is not evidence of hex decoding or ASCII packing.
2. **Output representation:** formal `param_table_data` direction, width and indexing; exact parameter-to-output mapping, bit/byte/word order, padding, truncation, extension and reserved/uninitialized bits. Obtain authoritative expected output vectors for both retained distinct literals, not values guessed from their apparent digit format.
3. **Validity and timing:** `param_table_valid` semantics for `"true"`/`"false"`, nonprimary output behavior, whether/how the table is constant or becomes valid, and any synthesis-versus-simulation differences. Confirm the interface expected by the selected 4096-bit net; readable connectivity alone cannot rule out primitive-boundary width conversion.
4. **Compatibility envelope:** bind the contract to the installed/generated EMIF/primitive version and target family/device; distinguish a specification or model guarantee from an actual compiled implementation and later runtime observation.

The separate consumer boundary remains `tennm_iossm` from live08: table/command selection, firmware GPT field meanings, pointer units, slot tags, relocation, loading/address translation and CPU byte order are not settled by this producer trace. Primary-tile selection does not establish calibration-slot permutation safety, scheduling invariance, physical equivalence, donor2.7 compatibility or runtime calibration success.

## Scope and acceptance

Performed only local retained JSON/text inspection, hashing, lexical QIP resolution and static substitutions. Created only this review and its companion disposition. No remote access, acquisition, vendor tools, HDL/Tcl execution, tests, disassembly, decryption, source/configuration changes or commits. No compilation, generated-interface or runtime acceptance is claimed. All readiness, acceptance and authorization flags remain false. The outstanding blocker is the authoritative primitive representation/behavior contract, followed by separately authorized acceptance work—not indefinite adjacent-file collection.
