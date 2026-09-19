# Monitored mailbox upgrade: output review

## Decision

**Do not accept this as a completed leaf-only migration or build-ready output.** The process succeeded (`rc=0`), but the batch upgraded/resaved **both** `bmc_spi_sub.qsys` and the mailbox leaf. The Qsys now records `altera_has_errors=true`; its mailbox proxy still describes 20.2.2 without waitrequest. The upgraded 23.0.0 leaf has the real external waitrequest declaration, but its embedded locked boundary still lacks that port. Preserve the run as useful partial migration evidence, not an accepted source replacement. No RTL-generation result is established.

## Evidence and verification

Read-only local JSON/XML/hash analysis; neither `run.py`, a checker/harness, vendor tools, nor remote commands were executed. The only authored artifact is this report.

- All **seven** `result-evidence.json` payloads match their recorded SHA-256. Both supplied diffs exactly reproduce a fresh in-memory unified diff against maintained baseline `new/ofs-agx7-pcie-attach/ipss/ia840f/bwbmc`.
- All **34** maintained baseline inputs match `before.json`. Comparing before/after inventories confirms only the two named files changed; the other **32** are unchanged. Remote `result.json` reports `source_unchanged=true`, no error and `ready_for_build=false`.
- Saved Qsys SHA-256: `ab097d3c68a8eb668befa9497ad1446fe31edefca5638ee68ce945ff1c8837f5`.
- Saved leaf SHA-256: `68b08188230c1ea002ca9e0fa7b3cb7e58ec62cea5a057c6cd31d85b09a3c459`.
- `upgrade.log` explicitly lists Qsys first and leaf second, with two upgrade start/finish pairs. This is not a leaf-selection filter. Installed help says `--batch` **adds** a system or standalone IP to the list, and `--upgrade-ip-cores` upgrades all available IP in the supplied system. [E1, E3]

## Full leaf comparison

Public `altera_s10_mailbox_client` version changed **20.2.2 → 23.0.0** (both component identity and entity_info). All 16 pre-existing module parameter values survived exactly:

| Parameter | Preserved value |
|---|---|
| DEVICE_FAMILY | Agilex 7 |
| CMD_FIFO_DEPTH / RSP_FIFO_DEPTH / URG_FIFO_DEPTH | 1024 / 1024 / 4 |
| CMD_USE_MEMORY_BLOCKS / RSP_USE_MEMORY_BLOCKS / URG_USE_MEMORY_BLOCKS | 1 / 1 / 1 |
| DEBUG / HAS_URGENT / HAS_STREAM / HAS_OFFLOAD | 0 / 0 / 0 / 0 |
| HAS_STATUS | 1 |
| STREAM_WIDTH | 32 |
| CRYPTO_MEMORY_TIMEOUT_VALUE | 10000 |
| AUTO_DEVICE / AUTO_DEVICE_SPEEDGRADE | AGFB027R25A2E2V / 2 |

Only new module parameter: `AUTO_BOARD=default`. All existing interface parameter values are unchanged. AVMM acquires `waitrequestTimeout=1024` and DFH properties (GUID/group/major/minor = 0, ID = 35, type = 3, parameter fields empty). Existing 4-bit word address, 32-bit data, 64-byte span, one pending read and clock/reset associations survive. System parameters retain target/family/speed, generationId=0, hideFromIPCatalog=false and system-info definition; changes are bonusData bookkeeping and empty cpuInfo/dflBitArray.

The external IP-XACT bus port map, physical output port and Altera boundary mapping all acquire `avmm_waitrequest` (scalar output). Existing readdatavalid remains. **However, the entire decoded `lockedInterfaceDefinition` is identical to the old leaf, with only six AVMM ports and no waitrequest.** Its omission is not cured by external declarations or `altera_has_warnings=false`, `altera_has_errors=false`. The leaf is a useful input to a targeted corrective save, **not yet an accepted coherent saved leaf or proven usable generated IP**. [E1 leaf payload lines 148, 631, 800–802 onward, 1214, 1228–1229; E2 leaf diff]

## Full child-system / embedded comparison

All **17** generic proxy identities remain version 1.0. Every pre-existing proxy parameter other than `componentDefinition` and `generationInfoDefinition` is unchanged, including every `defaultBoundary`, logicalView, HDL parameter definition and assignment definition. Decoding all componentDefinition and generationInfoDefinition XML finds **no removed or changed pre-existing nodes/values**: additions are interface-property entries and empty fileSetFileChangeDefs. In particular:

- Mailbox proxy `originalModuleInfo` is still `altera_s10_mailbox_client` **20.2.2**. Both `componentDefinition/boundary` and `defaultBoundary` still omit waitrequest. Its logicalView is still `ip/bmc_spi_sub/sdm_mailbox.ip`. This is a stale proxy, consistent with the Qsys being saved before the leaf upgrade. [E1 Qsys payload lines 15344 onward, original version at 15767]
- The other **16 leaf files are byte-identical**, therefore all their versions and full parameter sets are preserved: eight MM bridges 20.0.1; SPI bridge 19.1.3; two IRQ generators 1.0; on-chip memory 19.3.7; two reset bridges 19.2.0; clock bridge 19.2.0; Arbiter 2.0. Their embedded originalModuleInfo also remains unchanged.
- SPI specifically remains `spi_slave_to_avalon_mm_master_bridge` 19.1.3 with `SYNC_DEPTH=2`, `DEVICE_FAMILY=Agilex 7`, `AUTO_CLK_CLOCK_RATE=100000000`. Its conduit and Avalon-master port definitions are unchanged; this is not a SPI upgrade.
- All **46 connection endpoints/kinds** and every pre-existing connection parameter value are preserved; all **16 Avalon base addresses**, the serialized addressSpaces and memoryMaps, and the entire 11-interface external boundary are unchanged. Connection schema versions change 23.1 → 26.1. Every Avalon connection adds `qsys_mm.fifoDepth=8` and `qsys_mm.splitCommandsFor4KBoundary=FALSE`.
- Preserve `sdm_pipeline.m0 → sdm_mailbox.avmm` at `0x0000`, both `host_sdm_pipe.m0` and `bmc_spi_sdm_pipe.m0 → sdm_pipeline.s0`, `system_clk_bridge.out_clk → sdm_mailbox.in_clk`, and `sdm_reset.out_reset → sdm_mailbox.in_reset`: all remain. The unchanged wrapper still assigns `reset_csr = ~reset_csr_n` and drives both `sdm_reset_reset` and `sysrst_reset` from that global reset. No PCIe-only/FLR reset substitution was found. [E4 wrapper lines 75, 118, 120]

**Not all broad edits can be called metadata-only.** Branding/schema versions, display spelling, empty CPU/live-module/transform/ECC/group fields, bonusData and empty fileset-change records are serialization metadata. But waitrequestTimeout (24 embedded interfaces), optimizedReadsWithBE=0 (nine), DFH properties (15), and the two new interconnect settings on 16 Avalon connections are semantic-capable configuration additions. They look like new-release default materialization; the old files do not establish effective old defaults, so behavioral equivalence is not proven. There is no evidence of changed existing non-mailbox functionality, but blanket equivalence would overstate the result. Independently, the leaf's new port/version is a real interface/implementation change, and Qsys `altera_has_errors` changes **false → true**. The log does not explain the saved error flag; do not assign its cause solely to the stale mailbox without a vendor diagnostic. [E1; E2 Qsys diff final hunk]

## QPF/QSF: acceptance not established

`run.py:18` creates a QPF containing `PROJECT_REVISION = "mailbox_migration"` and QSF with FAMILY `Agilex 7` and DEVICE `AGFB027R25A2E2V`. The argv supplies that scratch project/revision. However, `run.py:27–29` hashes only the 34 BMC inputs; neither project file is in the before/after inventory or seven captured payloads. Their final content, IP reference changes and absence of project-side writes are **unverified**. Successful exit and the initial strings do not establish QPF/QSF acceptance. This missing evidence also prevents calling the two changed inputs the complete write set. [E1 invocation/before/after; E2 run.py]

## Minimal next vendor operation (proposal, not executed)

**Do not repeat the upgrade or refresh the enclosing `bw_840_support` yet.** First perform one targeted load/save of the already-upgraded mailbox and named footprint refresh of its immediate proxy, in a successor scratch copy retaining the observed outputs and project context. This addresses the actual remaining stale leaf/proxy state; it does not request a catalog upgrade, parameter edits, full-system synchronization or recursive closure.

The following is an exact launcher/Tcl proposal with `S` denoting that successor scratch root (not maintained baseline or the consumed run). Reuse the captured environment settings with HOME/TMPDIR rebased into S, and retain the captured license/PATH/QUARTUS_ROOTDIR. Copy/review the final QPF/QSF into S before use; the current evidence does not supply their final contents.

```sh
cd "$S/bwbmc"
/opt/altera/26.1.1/qsys/bin/qsys-script \
  --quartus-project="$S/mailbox_migration.qpf" --rev=mailbox_migration \
  --package-version=26.1 \
  --search-path="$S/bwbmc/ip/arbiter,$S/bwbmc/ip/irq_generator,\$" \
  --cmd='load_system bmc_spi_sub.qsys; if {![load_component sdm_mailbox]} {error "Cannot load sdm_mailbox"}; save_component; puts [reload_component_footprint sdm_mailbox]; puts [validate_component_footprint sdm_mailbox]; save_system bmc_spi_sub.qsys'
```

Installed `qsys-script --help` supports the launcher switches; the captured 26.1 command documentation supports `load_component`, argumentless `save_component`, named `reload_component_footprint`, validation and `save_system`. `save_component` is used here to resave the **already upgraded** actual leaf, not as an upgrade API. Whether this save repairs lockedInterfaceDefinition is an experimental result to inspect, not a documented guarantee. Installed API probing previously failed before command execution for lack of valid project context; do not label this Tcl sequence already tested. [E3; E5 §§21–49, 80–113]

Acceptance immediately after this single operation: inspect both saved files and QPF/QSF; require unchanged full parameter table and other-component settings; require real un-terminated width-1 waitrequest in leaf port map/physical ports/boundary **and decoded lock**, plus both proxy boundary representations; require proxy originalModuleInfo 23.0.0 and review all footprint messages and saved error flags. Stop rather than generate RTL if any representation stays stale. Do not add an untargeted sync, force old timing properties, or manually patch XML. Parent refresh and generation are later, separate operations after this focused save review.

If a clean replay of the original leaf-only upgrade is instead needed, the installed grammar supports a single positional `.ip` input, e.g. `qsys-generate --upgrade-ip-cores ./ip/bmc_spi_sub/sdm_mailbox.ip` with the same explicit project/part/search context and **no positional Qsys and no extra batch entry**. That is a supported input shape, not evidence it will repair the unchanged locked boundary; repeating it is not the preferred next corrective operation on this already-23.0.0 output. [E3]

## Citations

- **E1:** `result-evidence.json`, keys `result.json`, `invocation.json`, `before.json`, `after.json`, `upgrade.log`, `bwbmc/bmc_spi_sub.qsys`, `bwbmc/ip/bmc_spi_sub/sdm_mailbox.ip`. XML line references above refer to decoded payload contents, not the single-line JSON container.
- **E2:** sibling `bmc_spi_sub.qsys.diff`, `sdm_mailbox.ip.diff`, `run.py` (read statically only).
- **E3:** `../../ipgen-03/installed-refresh-tool-discovery.json`, full `qsys-generate-help.json.output` and `qsys-script-help.json.output`, and failed API-discovery records.
- **E4:** maintained read-only baseline `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach/ipss/ia840f/bwbmc`, including all inventoried `.ip` files, child Qsys and `bwbmc_wrapper.sv`.
- **E5:** `../../ipgen-03/mailbox-refresh-procedure.md`, cited vendor-command documentation and explicit limits. The installed help plus this run supersede its earlier claim that positional Qsys + batch leaf is a leaf-only filter.
