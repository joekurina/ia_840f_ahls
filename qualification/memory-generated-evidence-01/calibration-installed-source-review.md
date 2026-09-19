# Installed 26.1.1 memory composition: calibration disposition

**Direct generated ordering is explained by the captured FM composition routine. Donor slot association remains different; electrical equivalence, electrical failure, and a supported independent slot remap are not established. Readiness remains false. No implementation is proposed.**

## Evidence and scope

`R` is this directory. `S` denotes `/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg/ip_mem_ss`. Citations `filename:line` refer to decoded Tcl payload lines in `calibration-installed-live02.json`, not JSON container lines. `F<n>:line` denotes `memory-artifacts.json`'s decoded `files[n].content`.

Independently verified live02's 133556 bytes and SHA-256 `3b245eee4f7c3313a15aa4e363c488b2f08b869aa6931407fa091f202c994e22`, and all eight full Tcl payload byte counts and hashes. Its `errors` and `limits_hit` are empty. This is static receipt validation, not local access to the installation or execution of its code. Live01 records the missing historical `/opt/altera/26.1.1/ip/altera/subsystems/mem_ss` directory; that miss is preserved and is not a missing-memory-IP conclusion. Live02 records the actual package path above.

Read the prior review and lookup request. Selected generated payloads F6, F61, F63, F66, F72, F78 and F86 were independently hash-checked. Prior donor/pin/derivation findings are carried forward with attribution to `calibration-order-source-review.md`; this review does not claim a new donor audit. No vendor/Tcl/project execution, source imports into vendor tools, remote access, tests, generation, source/pin edits, or commits were performed. Only the two new review/request files are owned outputs.

## 1. Applicable flow is FM, not the similarly shipped FP routine

- Generated F63:1–14 identifies tool 26.1.1, kind `mem_ss`, version `5.0.1`, and Agilex 7. F6:3788–3796 saves `AGFB027R25A2E2V` / `Agilex 7`.
- `declare.tcl:29–45` declares `mem_ss` 5.0.1 for Agilex 7/9 with `MAIN_FM[0-9]*` die support; `mem_ss_fp` is a separate 1.0.0 package. `declare.tcl:225–240` maps internal family `fm` to `mem_ss`, and literal memory type `DDR4` to `fm`. Thus this is not a choice made merely from the text “Agilex 7,” which also appears on the FP package.
- `mem_ss_pkg.tcl:14–24` registers Tulip/util package roots, requires the memory package, and calls `declare $system_name`. `main.tcl:15–31` requires qsys/Tulip/util and sources declare, elaborate, and filesets. `declare.tcl:36–37` registers **ELABORATION_CALLBACK** `::mem_ss_pkg::ip_mem_ss::elaborate`; this source uses that mechanism, not a literal `COMPOSITION_CALLBACK` registration.
- `elaborate.tcl:514–535` copies parameter table values, selects `edit_qsys_fm.tcl` followed by `edit_qsys.tcl` for `fm`, and invokes the script when `RUN_COMPOSE` is true. The FP/SM/FMM alternatives are explicit at lines 525–530. `edit_qsys_fm.tcl:15` defines `compose_ip`; common `edit_qsys.tcl:427–445` restores arrays, assigns project family/device, removes existing connections/interfaces, disables instances, then calls `compose_ip`.
- These sources explain the applicable branch and agree with generated evidence; they are not a captured runtime call trace. `create_device_features` is called at `declare.tcl:223` but its implementation is outside the eight files. Package loading and generated QCP declarations are also not fully closed: `declare.tcl:16,26` sources `${ip_dir}/qcp/${system_name}_hwtcl_commands.tcl`. Do not claim those missing definitions were reviewed. The source's `package require -exact qsys 24.1` is recorded as written, not silently relabelled 26.1.1 or treated as proof of a wrong installation.

## 2. Complete calibration-list construction for the saved configuration

Saved F6:3828–3856 requests `RUN_COMPOSE=true`, `MEM_INTFS_TYPE=DDR4,DDR4`, `MEM_INTFS_LOCATION=BOT,BOT`, `APP_INTFS_TYPE=STORAGE,STORAGE`, and identity application vectors `1,0` / `0,1`.

1. `declare.tcl:118–127` declares memory/application index lists as **derived**, with a `range(length(type-list))` value expression; location is a configurable string list. `elaborate.tcl:197–229` consumes the connection vectors to construct `mem_conns` and `app_conns` indexed by memory/application port. Both DDR4 rows are connected, and neither is an HPS application.
2. `edit_qsys_fm.tcl:83–98` initializes the regular-EMIF counter to zero and both calibration lists to empty.
3. Lines 105–113 traverse **memory type/index/location lists together in their existing list order**, skipping unconnected memory rows. Lines 119–138 classify HPS versus storage. Connected non-HPS DDR4 rows allocate `emif_${num_regemif}` and increment the counter at lines 141–144. It is an allocation counter, not an independently specified physical controller index.
4. Lines 177–180 append each allocated controller to `cal_top_emifs` if location is `TOP`, otherwise to `cal_bot_emifs`. For legal DDR4 location values the declaration permits TOP/BOT (`declare.tcl:253–257`); the `else` is not authorization to use arbitrary location strings. Here the bottom list becomes **`emif_0 emif_1`**.
5. HPS controllers would be appended later in the application pass (`edit_qsys_fm.tcl:333–334,476–493`), but this configuration has no HPS application. Therefore “all configurations sort by numeric EMIF suffix” would overstate the implementation. Likewise, `all_emifs = lsort(concat(top,bottom))` at line 304 belongs to reset-controller wiring at lines 310–325; it does **not** sort or replace either calibration list.
6. Lines 549–567 enable the nonempty bottom calibration component and explicitly set `NUM_CALBUS_INTERFACE` to the bottom list length, here two. Lines 579–584 set `i=0`, traverse that same list unchanged, connect the common calibration clock and `emif_cal_bot.emif_calbus_${i}` to the current controller, then increment `i`. Result: **calbus0→emif_0; calbus1→emif_1**. The top counterpart at lines 506–541 independently numbers its own list from zero.
7. Memory physical-export names follow the memory row, not a calibration suffix override: rename templates are at lines 25–31 and `<MEM_ID>=$mem_idx` binding is at lines 283–290. For these two connected regular rows, this agrees with F61:205–302: emif_0 is mem0 and emif_1 is mem1. F61:315–328 also shows return data and each sequence-parameter table consistently paired with the same controller. Whole-interface consistency explains why this is not just a printed net-name discrepancy; it does not establish the consumer's physical addressing semantics.

**Conclusion:** the observed direct connection is the deterministic result of the saved two-bottom-storage configuration under this source. There is no evidence here that donor suffix reversal was imported into an independent calibration-map parameter or accidentally lost by a random ordering operation.

## 3. Supported controls versus an unsupported correction

| Surface | Traced behavior | Calibration-correction disposition |
|---|---|---|
| `MEM_INTFS_LOCATION` | Configurable TOP/BOT grouping; append selection above | Changes calibration-block membership, not independent within-block permutation. Preserve BOT,BOT. |
| `MEM_INTFS_IDX` | Derived range expression, not an exposed ordering choice | Do not force a derived index or exchange physical rows to reproduce suffixes. |
| `MEM_CH_*_CONNS` | Application connectivity (`elaborate.tcl:197–229`); unconnected/HPS cases affect which controllers are instantiated | No dedicated calbus selector. Changing vectors changes topology, not a supported isolated repair. |
| `NUM_CALBUS_INTERFACE` | Explicitly recomputed from list length (`edit_qsys_fm.tcl:564–566`) | Already two; copying donor two cannot reverse slots. |
| `RUN_COMPOSE` | Default false in declaration; true runs composition; false removes connections/interfaces and disables enabled instances (`elaborate.tcl:534–555`) | **Not** a supported “freeze my manually rewired graph” control. Fileset callbacks reject false (`filesets.tcl:44–47,65–69`). |
| Bottom diagnostic fields | `DIAG_EXPORT_SEQ_AVALON_SLAVE` is forced disabled when CSR is disabled; toolkit/simulation calibration mode/verbosity are read from calibration IP and forwarded to each listed EMIF (`edit_qsys_fm.tcl:550–576`) | Diagnostic forwarding, not ordering. No recommendation to change calibration simulation mode. |
| `DIAG_EXTRA_PARAMETERS` | Hidden string (`declare.tcl:215–217`), parsed into a table (`elaborate.tcl:175–185`); captured consumers read example-design `BOARD_DATA_FILE` and `QUARTUS_INI_FILEPATH` (`filesets.tcl:107–110,158–162`) | No captured calibration-order consumer. Do not invent a hidden override or use arbitrary Tcl. |
| `AXM_ID_NUM`, `SEQ_GPT_COLUMN_ID`, `EMIF_n_CONN_TO_CALIP`, sequence-table addressing | No `AXM_ID_NUM`, `SEQ_GPT_COLUMN_ID`, `CONN_TO_CALIP`, or `calbus_seq_param_tbl` token occurs in these eight Tcl payloads | Their leaf derivation/consumption remains outside this capture; absence here is not proof that no lower-level control exists. |

The prior review's saved metadata still applies: donor/generated cardinality is two and AXM ID zero; the generated bottom IOSSM column field is derived and cannot be equated to board channel1 or calbus1. A Cal-IP block selector is not a proven bus-slot selector. No supported independent slot-remapping control has been established in this review. Do not patch vendor composition, generated HDL, presets, diagnostic strings, device metadata, or application wiring to force the donor's numbers.

## 4. Physical disposition and remaining proof obligation

`calibration-order-source-review.md:15–31,38–60` establishes donor bottom bus0→physical1/RDIMM and bus1→physical0/discrete, versus generated bus0→physical0/discrete and bus1→physical1/RDIMM. This new source explains the generated side; it does not reinterpret the older implementation or eliminate that literal discrepancy.

Retain physical0 discrete/P1 and physical1 RDIMM, their physical port identities and application topology, and every existing pin. In particular preserve refclk-positive HF23/HH48, OCT HB23/GW48 and CS HB29/GW42 respectively, as documented by the prior review's exact donor/candidate pin citations. Do not invent the unassigned RDIMM negative reference pin, swap memory formats, or infer I/O-column ordering from package coordinates.

Still needed for semantic acceptance: evidence showing how `altera_emif_cal`/IOSSM consume each logical slot's sequence table, select physical calibration destinations, and derive column/Cal-IP metadata, including any cross-version ordering constraints relevant to the donor. Neither this ascending-list algorithm nor matching cardinality proves physical/electrical equivalence, calibration success, or failure. Fitted grouping and complete OFS interface acceptance also remain unproven. All acceptance/readiness flags remain false.

## 5. Smallest next supported action (proposal only)

Authorize a **single finite read-only source-bound follow-up**, not a correction or vendor run:

- Capture exactly `S/qcp/mem_ss_hwtcl_commands.tcl`, resolving the literal include at `declare.tcl:16,26` with the verified kind `mem_ss`. Its existence/content has not been established by this review. Inspect callback/parameter/instance declarations and record any literal calibration descriptor references without following them.
- In the same bounded request, list only immediate names/types/sizes in `/opt/altera/26.1.1/ip/altera/subsystems/mem_ss_pkg/util`, the exact package root in `mem_ss_pkg.tcl:15`. This is solely to identify the missing `create_device_features` package definition through a subsequent reviewed exact request. Do not guess its filename or read all Tcl files there.

`calibration-next-evidence.json` sets the exact paths, limits and stop conditions. This small follow-up closes known declaration/package-reference gaps or returns a precise miss; it is **not promised to resolve calibration consumer semantics**. If it yields no literal consumer path, stop and request authoritative vendor clarification or a separately reviewed bounded descriptor lookup. Do not revive the absent historical mem_ss root, fabricate an `altera_emif_cal` implementation path, recursively chase includes, or broaden to another installation. No execution authorization is granted by either output.

## Source bindings

| Input | SHA-256 |
|---|---|
| calibration-installed-live02.json | `3b245eee4f7c3313a15aa4e363c488b2f08b869aa6931407fa091f202c994e22` |
| calibration-installed-live01.json | `1b50346cf4ab5cdda17a11609126f704b4c6ef5a5a7891acc8ae58eedd8a3316` |
| calibration-order-source-review.md | `574e69945ea532b636674ce978f58cca42c2cf3ae56cf936edd04761ab75cecf` |
| calibration-source-lookup.json | `5151e893eccab7047d605553d8057b624afa65a1b9763011e0cfb25da6d9c42d` |
| memory-artifacts.json | `a333f976a8f95024b37ad918051b379c3922bd66b91e123e09fc575e95eb60ae` |

All following paths are relative to S and refer to full decoded captured payloads:

| Tcl | Bytes | SHA-256 |
|---|---:|---|
| declare.tcl | 21753 | `add43724e1c35f47981bb0bbef24d2a9a6f884ecc19ab9ef6c8aff9aaf38a538` |
| edit_qsys.tcl | 14449 | `cee111b4b50b32cfc9dcd55fb8881e0b437b55b47abca18a2d2cf21abd376d99` |
| edit_qsys_fm.tcl | 32306 | `409dc24e8fef7cc752a3adbe018ec98cf4065918931917ef63cb6d583c12c551` |
| edit_qsys_fp.tcl | 20498 | `889c9e0a8df7904f4a51d208eb97610b3ae4d076d591d219b8fcae1302ac3882` |
| elaborate.tcl | 23318 | `8b2ea4c32fefc419bd3b033ff670fd393efaf39e2ecda5d4b61cbd7ceac4bf0c` |
| filesets.tcl | 10323 | `aa925d4eff51b25ab51b23254c9a4b663e48cfa14ecec6eae38493664fef494f` |
| main.tcl | 1173 | `8dc71e67a1e00a43e5a1a6e47548f155ac0f1099766fe62409accc9b71af9fad` |
| mem_ss_pkg.tcl | 1128 | `66bb9b1030ad77737caf6585549daf402868694291942278cde56b4eee594d5a` |
