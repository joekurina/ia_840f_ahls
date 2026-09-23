# Independent review — Quartus 25.1 AHLS DDRIP import/generation

**FINAL — ACCEPT_NATIVE_IMPORT_GENERATION_ONLY.** No blocker found within this scope. This accepts native import, validation/save and synthesis-HDL generation of the corrected AHLS2026.1.0 component, **not HDL elaboration, a working kernel, DDR integration or hardware**.

## Evidence identity and preservation

Independently rehashed all **28 frozen entries** (22 captured native/generated files plus six evidence files), decoded and byte-compared all **22 archive members**, and reconciled the manifest with the original capture: no mismatch.

- `review-package02.json` SHA256: `48dd5379e0554eb97a7a73f047ebe9eba53d17e8ec534fcc11bb7bde8d47a669`.
- `result-import02.json.gz`: **124104 bytes**; SHA256: `4e86b60a26c5cd0ec19557d5aa4cde3d2fc4c31a3b7b3572416615568cb6a705`.
- Generated `lsu_ic_top.sv` is byte-identical to the previously accepted candidate; SHA256: `f9defb182dcca3d3d299eb1e2ee060ce730caa24b2bd613d44f8c05abaccfdcd`. Its source/unit acceptance remains bounded by [RESULT-ACCEPTANCE.md](../ahls-writeack-fix01/RESULT-ACCEPTANCE.md).

The captured original project inventory contains **224 files / 33,641,784 bytes** and exactly matches the prior AHLS generation inventory. Launcher inspection confirms only `ip/lsu_ic_top.sv` is replaced in the fresh copy. Captured postflight checks report original/copied bound inputs, diagnostic script and tool launchers preserved, with no postflight errors. Independently reconciled **334 original fileset statements → 155 unique source references → matching original/corrected hashes** in the 222-entry output inventory. The k0 QIP lists these 155 files plus its generated wrapper, consistent with the native **2 modules / 156 files** report. This is captured inventory/preservation evidence, not a new remote rehash of uncaptured source bytes.

## Native result and interface checks

Both captured commands have **native/effective return 0**, no timeout and no live final owned group: Quartus25.1 `qsys-script` import/validate/save, then `qsys-generate --part=AGFB027R25A2E2V --synthesis=VERILOG --parallel=off`. Helpers observed immediately after launcher exit drained under the original deadline. The full import/generation logs contain no Warning/Error/Fatal diagnostics; import has both completion markers. Generation identifies **25.1 build129**, Agilex7 and the specified device. See [manifest](import02-manifest.json), `artifacts-import02/import.log:72–79` and `generate.log:37–72`.

Native k0 SOPCINFO independently agrees with [interface-ledger02.json](interface-ledger02.json); every Avalon exported HDL port matches its width, direction and direct binding:

| Boundary | Address / units | Data / byteenable | Byte span | Pending-read metadata |
|---|---|---|---|---|
| CSR | 5 bits / WORDS | 64 / 8 bits | 256 | 1 |
| Logical memory0 | 34 bits / SYMBOLS, 8 bits/symbol | 256 / 32 bits | 17,179,869,184 | 0 |
| Logical memory1 | 34 bits / SYMBOLS, 8 bits/symbol | 256 / 32 bits | 17,179,869,184 | 0 |

All three have waitrequest allowance0 and clock/reset associations `clock`/`resetn`; burstcount units are WORDS and both memory burstcount ports are 4 bits. Memory pending-read metadata0 is not a measured outstanding-depth guarantee. The memory interfaces are logical hosts, **not physical DDR-bank assignments**. No connected address/data-width adapter is exercised. Hidden/default `maxAddressWidth=32` and `deviceFamily=UNKNOWN` do not establish truncation or a family mismatch against the actual ports, spans, device bindings and QIP.

Clock bridge `EXPLICIT_CLOCK_RATE=0` leaves frequency unspecified, not timing-qualified. Reset bridge is active-low with DEASSERT metadata; k0 requires BOTH edges. Generated HDL supplies an `altera_reset_controller` with BOTH-edge synchronization, depth2, minimum assertion3, and the correct active-low inversions (`ahls_memory_import.v:40–117`). This establishes generated structure, not functional reset verification.

## Disposition and unresolved items

- `import01` remains failed (native/effective1): integer-property Java casts and unsupported Tcl `eq`. The successor changes only diagnostic queries/comparisons; no design metadata is patched. `probe01` remains native0/effective125, **not clean success**.
- Native standalone QSF additions are power defaults, `LAST_QUARTUS_VERSION`, three `IP_FILE` assignments and `QSYS_FILE`; original assignments remain. These are not FIM board-setting edits.
- **Integration/hardware holds remain:** complete `quartus_syn` HDL elaboration and synthesis; connected interconnect/address projection, width conversion and physical-bank routing; actual clock/reset constraints; fit/timing; full LSU/kernel completion and DMA/PIM/host-memory visibility; numerical DDR/hardware validation. Prior acknowledgment-unit acceptance does not clear these holds.
- **DDR simulation: SKIPPED BY USER.** This verdict grants no deployment or hardware authority and changes no readiness flags.

Review was local-only, with no vendor/simulator execution, SSH, hardware, source edits, git operations or task transitions. Only this report was written; raw sources and payload-bearing launchers were not copied or published.
