# Mailbox-only upgrade and saved-boundary refresh procedure

## Disposition and scope

**A documented mechanism exists: `qsys-generate --upgrade-ip-cores <immediate-parent.qsys> --batch=<one-leaf.ip>`, followed by targeted `reload_component_footprint <instance>` and `save_system` in each enclosing system, bottom-up.** `load_component` / `save_component` expose and save the actual IP inside a generic component; they are not documented as an IP-version upgrade command. `sync_sysinfo_parameters` updates system-info parameters, not the catalog version or a substitute footprint.

This is a **proposal, not implementation or execution authorization**. Current bound sources and work03 must remain immutable. Readiness remains **false**. A later successor scratch copy, exact command/project/search-path binding, review, and reauthorization are required before any tool invocation below. No vendor tools, remote access, Tcl execution, HDL generation, or bound-source edits were performed for this report.

Definitions: `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`; source `B=N/ofs-agx7-pcie-attach/ipss/ia840f/bwbmc`. In proposed commands, `$SCRATCH_B` means a separately authorized successor copy of that directory, **not B**, and `$SCRATCH_QPF` / `$SCRATCH_REV` mean the reviewed successor project/revision. No scratch path or new project is authorized by this document.

## Grounding

Read the existing `bmc-mailbox-generation-review.md`, all three captured `installed-mailbox-source/*.tcl` files, local OFS scripting examples, parent Qsys references, and `generation-interim-evidence.json`. The latter contains captured 26.1.1 build 130 reports with both standalone and nested `Agent with readdatavalid must use waitrequest` diagnostics; this was not a new reproduction. It is interim evidence, not final project-wide acceptance.

Captured public Tcl declares `altera_s10_mailbox_client` **23.0.0** at lines 35–36, composes `altera_s10_mailbox_client_core` at line 247, and exports its AVMM interface at 270–271. Core Tcl declares **21.0.0** and unconditional `add_interface_port avmm avmm_waitrequest waitrequest Output 1` at line 427. The software driver version and minimum hardware compatibility version are not upgrade targets. The public component's `package require -exact qsys 16.0` is an API compatibility request, not the Quartus release or public component version.

Local OFS `ofs-agx7-pcie-attach/src/pd_qsys/fabric/bpf.tcl:11–17,34–43` demonstrates `add_component`, `load_component`, `set_component_parameter_value`, `save_component`, then instantiation operations. Lines 1709–1710 perform system-info sync and system save. These are **creation scripts**, not proof of upgrading an existing 20.2.2 mailbox. Do not copy their explicit old footprint reconstruction into this repair. Searching local new_bsp Tcl files for `upgrade_ip`, `upgrade_component`, `update_component`, and `reload_component` did not produce an existing selective upgrade helper.

Parent `bw_840_support.qsys` references `bmc_spi_sub.qsys` as its `logicalView` at line 3995. The required refresh chain is therefore leaf → `bmc_spi_sub.sdm_mailbox` generic proxy → `bw_840_support.bmc_spi_sub_0` subsystem proxy, not a second mailbox upgrade.

## Authoritative documentation and exact command contracts

Source: **Quartus Prime Pro Edition User Guide: Platform Designer, document 683609, version 26.1**, live Altera documentation. Normal page extraction timed out; the browser exposed the official documentation map and topic-content endpoints. Full topic bodies were read successfully from:

`https://docs.altera.com/api/khub/maps/pSFYYwd_5OIHZfgZwWYTjg/pages`

and `https://docs.altera.com/api/khub/maps/pSFYYwd_5OIHZfgZwWYTjg/topics/<contentId>/content`.

These were public read-only documentation requests, not access to the target workstation. The human-readable links below identify the same topics.

1. [8.2.1 qsys-generate options](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/qsys-generate-command-line-options), content ID `7inV5QwciSW046zaMMCp3A`:
   - `--upgrade-ip-cores` enables upgrading supported IP in the specified system.
   - **Must be used with `--batch`, indicating the IP file to upgrade.** The documented example is:
     ```sh
     qsys-generate \
       --upgrade-ip-cores prg_q.qsys \
       --batch=\./ip/prg_q/prg_q_onchip_memory2_0.ip
     ```
   - Explicit limit: **“This command has no impact on IP cores in any subsystem.”** Thus pass `bmc_spi_sub.qsys`, not only `bw_840_support.qsys`.
   - `--batch=<value>` is repeatable, but this proposal supplies exactly one mailbox leaf. Do not enumerate all project IP.
   - `--quartus-project=<value>` and `--rev=<value>` select project and revision. `--part=<value>` sets part. `--search-path=<value>` replaces the search path; a literal `$` includes the standard path.
   - The upgrade option has no documented requested-version argument. It does not prove the selected catalog is 23.0.0: capture and check actual resolution. The command is a qsys-generate operation, **not a dry run** or a promise of no generated side effects. Do not add synthesis/simulation requests to the upgrade phase without separate review.
2. [8.14.6.21 load_component](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/load_component), ID `20iKtRzSMWV54hE16xvVFg`: `load_component <instance>` loads the actual component inside a generic component for parameter modification; returns boolean 1 on success, 0 on failure.
3. [8.14.6.23 save_component](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/save_component), ID `JINoJZIrNvsgOHKYdU8q1Q`: `save_component`, no arguments, saves the loaded component; no return value.
4. [8.14.6.22 reload_component_footprint](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/reload_component_footprint), ID `gGBUduQyygUlpLTfdrzvpQ`: `reload_component_footprint [<instance>]` validates the specified child footprint and updates it if issues exist; returns a list of validation messages. **Omitting the instance validates all generic components**. Always name the target here.
5. [8.14.9.2 sync_sysinfo_parameters](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/sync_sysinfo_parameters), ID `M4ttg5z1K105KYpDous8YQ`: `sync_sysinfo_parameters [<instance>]` updates the named generic component's system-info parameters; returns update messages. No argument synchronizes all generic components. Use only the named target.
6. [load_system](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/load_system), ID `r03HsafcJRjORwQ710euLA`: `load_system <file>` loads a `.qsys` as the current system. [save_system](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/save_system), ID `GRg_wB7muqAn8Ycph5N_Zw`: `save_system <file>` saves it; bare `save_system` saves the file opened by `load_system`.
7. [get_component_parameter_value](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/get_component_parameter_value): `get_component_parameter_value <parameter>` reads a loaded component parameter. [set_component_parameter_value](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/set_component_parameter_value): `set_component_parameter_value <parameter> <value>` sets it. [validate_component_footprint](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/validate_component_footprint): `validate_component_footprint <instance>` returns validation messages. These messages require interpretation; a nonempty list is not documented as a boolean failure code.
8. [8.7 qsys-script](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/generate-a-platform-designer-system-with-qsys-script): documents `--script=<file>`, `--cmd=<value>`, `--system-file=<file>`, `--package-version=<value>`, `--search-path=<value>`, `--quartus-project=<value>`, `--new-quartus-project=<value>`, `--rev=<value>`. A package version must be requested with the option or `package require -exact qsys <version>` in Tcl. The system file loads before commands; `--cmd` runs before `--script` if both are supplied. The project option can add a saved system to the project: **QPF/QSF/project callbacks are within the side-effect scope**.
9. [2.3.3 Synchronizing IP File References](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/synchronizing-ip-file-references): if same-name IP exists at different locations, the Quartus project reference takes precedence. This synchronization can modify references/QSF. It is not footprint reload. A copied Qsys alone does not isolate this task from old project IP references.
10. [4.1.4.1 Upgrade IP Components to the Latest Version](https://docs.altera.com/r/docs/683609/26.1/quartus-prime-pro-edition-user-guide-platform-designer/upgrade-ip-components-to-the-latest-version), ID `gJHcv~TAhS2NclxLv7_m~A`: the GUI Upgrade IP Cores dialog supports selecting a component and clicking **Upgrade**. This is a documented selective fallback if the installed CLI cannot perform the operation, not permission to click Upgrade All.

## Proposed successor procedure — do not execute under work03 authorization

### 0. Bind the whole mutation context first

Copy the complete required source/reference structure into a new, non-symlinked successor scratch tree while preserving relative logicalView paths. Inventory original bytes and decoded semantic parameters/boundaries/connections before any vendor operation. Do not use the active work03 tree as scratch. Explicitly bind installed tool executable identity, version, device, cwd, successor QPF/QSF/revision, scripts, expected writes, and resolved search paths in the later reviewed authorization.

All project IP assignments and search results must resolve to successor copies or the reviewed installed catalog, never to mutable work03/source originals. Exclude competing old mailbox catalogs. Confirm no external reference would redirect saving outside scratch. Include project loader scripts and possible project-file edits in review. Copying a file does not authorize execution of its SOURCE_TCL_SCRIPT_FILE hooks.

The parent's installed-tool probe reports are an additional constraint: `--cmd` without a project was rejected; script-only probing attempted implicit project creation from a hyphenated script basename and failed. Do **not** retry by creating a convenient project, changing the name, or inventing a bypass. The later invocation must use an explicitly authorized successor project/revision. Public docs call the project option optional, but that does not negate observed installed behavior. Installed 26.1.1 help/API compatibility confirmation still belongs inside that future reviewed context; this research executed neither.

### 1. Upgrade exactly the immediate mailbox leaf

From the authorized successor BMC directory, the documented core operation is:

```sh
cd "$SCRATCH_B"
qsys-generate --upgrade-ip-cores bmc_spi_sub.qsys \
  --batch=./ip/bmc_spi_sub/sdm_mailbox.ip \
  --quartus-project="$SCRATCH_QPF" --rev="$SCRATCH_REV" \
  --part=AGFB027R25A2E2V \
  --search-path="$REVIEWED_SEARCH_PATH"
```

`REVIEWED_SEARCH_PATH` is an explicitly reviewed comma-separated catalog path string; if it includes the default catalog, retain `$` literally, not shell expansion of an unintended variable. These placeholders are **not final executable authorization**. The exact installed qsys-generate help and command grammar must be reconciled before binding this invocation; the flag syntax above is established by the 26.1 manual, not by an installed execution in this task.

There is no `--upgrade` option proposed for qsys-script, no invented `upgrade_component`, and no `load_system -upgrade`. Do not pass the internal core version or alter the generic proxy's version 1.0. Require actual public resolution `altera_s10_mailbox_client` 23.0.0 and internal core 21.0.0 at the captured installed paths. If unavailable, non-upgradeable, or another version resolves, stop for evidence/review. Do not patch version strings or reconstruct the leaf from defaults.

After this operation, inspect the saved `.ip` before continuing: the version, all parameters, actual waitrequest mapping, and locked boundary must be coherent. The manual documents upgrade scope, but does not guarantee that this specific old leaf upgrades successfully or enumerate every cache serialized. Do not infer success from exit code alone.

### 2. Refresh and save the immediate generic proxy

The following Tcl sequence uses documented commands. It is a **procedure fragment**, not a created or executed script; a later implementation must add guarded error/message handling and assertions based on saved pre-upgrade state.

```tcl
load_system bmc_spi_sub.qsys
if {![load_component sdm_mailbox]} {
    error "Cannot load sdm_mailbox; do not continue"
}
# Compare get_component_parameter_value results with the retained table below.
# Stop on unexpected migration; never silently accept restored defaults.
# If a reviewed correction is necessary, the supported setter is:
# set_component_parameter_value PARAMETER VALUE
save_component
puts [sync_sysinfo_parameters sdm_mailbox]
puts [reload_component_footprint sdm_mailbox]
puts [validate_component_footprint sdm_mailbox]
# Review all messages and serialized delta before accepting this scratch save.
save_system bmc_spi_sub.qsys
```

Do not omit the instance from sync/reload/validation and thereby broaden the operation. `save_component` is not a replacement for step 1, and `save_system` is not a replacement for saving the leaf. Neither command's manual promises a targeted save is byte-local; reject unexplained unrelated semantic deltas after serialization. Reopen and inspect the resulting files to establish persistence and coherent boundaries.

A documented launcher shape, only after a script and context are separately reviewed, is:

```sh
qsys-script --quartus-project="$SCRATCH_QPF" --rev="$SCRATCH_REV" \
  --package-version=26.1 --search-path="$REVIEWED_SEARCH_PATH" \
  --script="$REVIEWED_REFRESH_TCL"
```

Here `26.1` is the **proposed API compatibility level**, not an assertion that it has been tested in the installed 26.1.1 process. Confirm that package/API selection under the approved project context before execution authorization; stop rather than guessing a fallback. Alternatively place a verified `package require -exact qsys <version>` in the reviewed script and omit `--package-version`. The existing OFS 18.0 and captured mailbox 16.0 requests prove compatibility use cases, not permission to substitute those versions blindly. The fragment uses explicit `load_system`, so no implicit basename/system resolution is needed.

### 3. Refresh the enclosing subsystem proxy, bottom-up

After the child save is accepted, in a fresh/reloaded current system:

```tcl
load_system bw_840_support.qsys
puts [sync_sysinfo_parameters bmc_spi_sub_0]
puts [reload_component_footprint bmc_spi_sub_0]
puts [validate_component_footprint bmc_spi_sub_0]
save_system bw_840_support.qsys
```

Retain `logicalView=bmc_spi_sub.qsys`. This refresh does not upgrade every IP inside the subsystem. The internal mailbox change should not introduce a new board-level waitrequest export. If other enclosing saved proxies exist in the final source closure, inspect and refresh only the specific child reference at each additional level under an amended reviewed scope. Do not claim recursive refresh from a single top-level command.

### 4. Preserve these invariants explicitly

| Setting | Required retained value |
|---|---|
| DEVICE_FAMILY | Agilex 7 |
| CMD_FIFO_DEPTH / RSP_FIFO_DEPTH / URG_FIFO_DEPTH | 1024 / 1024 / 4 |
| CMD_USE_MEMORY_BLOCKS / RSP_USE_MEMORY_BLOCKS / URG_USE_MEMORY_BLOCKS | 1 / 1 / 1 |
| DEBUG / HAS_URGENT / HAS_STREAM / HAS_OFFLOAD | 0 / 0 / 0 / 0 |
| HAS_STATUS | 1 |
| STREAM_WIDTH | 32 |
| CRYPTO_MEMORY_TIMEOUT_VALUE | 10000 |
| Target / speed grade | AGFB027R25A2E2V / 2 |

Check parameters before and after every leaf save/system-info sync, including hidden parameters; default FIFO depth 16 is unacceptable. Device/system metadata remains metadata, not invented HDL parameters. No catalog-kind, leaf-name, relative-path, address-map, IRQ, software ownership, shared access, or board wrapper change is authorized.

Preserve `sdm_pipeline.m0 -> sdm_mailbox.avmm`, base `0x0000`, both `host_sdm_pipe.m0` and `bmc_spi_sdm_pipe.m0` feeding `sdm_pipeline.s0`, 4-bit word address / 32-bit data / 64-byte window / one pending read, readdatavalid, and clock/reset associations. Preserve `system_clk_bridge.out_clk -> sdm_mailbox.in_clk` and `sdm_reset.out_reset -> sdm_mailbox.in_reset`. Preserve wrapper global `reset_csr=~reset_csr_n` supplying `sdm_reset_reset` and `sysrst_reset`; no PCIe-only or PF1-FLR reset substitution.

Require real output `avmm_waitrequest`, role `waitrequest`, width 1, un-terminated, in the leaf port map, physical ports, decoded locked interface, and interface-boundary mapping, and in both saved proxy boundary representations. Do not force old timing metadata over the new live implementation; review unexpected property changes. Never disable readdatavalid, tie waitrequest low, add a dummy adapter, or import old generated RTL.

### 5. Separate save acceptance from generation acceptance

Archive exact tool/catalog identities, complete logs and return codes, source and generated output inventories, decoded before/after parameters/boundaries/connections, and all QPF/QSF changes. Read saved targets back. Reject unintended IP upgrades, target drift, unrelated component changes, rewritten paths to originals, or stale 20.2.2 locked/proxy boundaries.

Only after save-diff review and successor source rebinding may a separately authorized generation pass run. It must generate both standalone `bmc_spi_sub` and nested `bw_840_support`, show the reported validation error gone in both, and trace nonconstant real waitrequest from installed core through mailbox wrapper/interconnect to `sdm_pipeline.m0_waitrequest`, while retaining readdatavalid and both upstream requesters. Leaf-only generation, a GUI Upgrade success, or clean footprint validation alone is insufficient. Shared-reset, protocol, FLR, physical, and full-build readiness remain separate gates.

## Remaining limits

The manual establishes exact selective upgrade and footprint-reload syntax; it does not establish successful migration of this saved mailbox, installed API-package availability, what the installed tool will serialize, or full design correctness. No new project was opened/created here and no bypass was attempted. Only this report was created in the qualification directory. The blocked dynamic documentation frontend was recovered through the official public content API; no unsupported tool flags were inferred from search snippets.
