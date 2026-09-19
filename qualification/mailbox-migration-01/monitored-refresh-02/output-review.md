# Refreshed mailbox saved-state integration review

## Disposition

**Accept this saved child state as the input to the next authorized enclosing-parent footprint refresh and standalone/nested RTL-generation experiments.** The previously stale mailbox footprint is repaired. No additional approval framework or runtime/hardware proof is needed before those experiments. This is saved-state acceptance, not generated-RTL or BSP qualification: **all readiness flags remain false; actual source generation remains pending.** No vendor tools, harness, network, or project checker were executed for this review; inspection used local evidence and XML only. Maintained sources were not changed.

## Evidence and preservation

Reviewed `monitored-refresh-02/result-evidence.json`, `monitored-upgrade-01/result-evidence.json`, the maintained `new_bsp/new/ofs-agx7-pcie-attach/ipss/ia840f/bwbmc` files, and `successor-first-u01/parent.tcl`.

- All nine refresh payload SHA-256 values recompute correctly. The seven prior payload hashes also match. Refresh inputs for the child and leaf match the prior upgrade outputs.
- Actual recorded `qsys-script` return code is 0. The log records `load_system`, `load_component sdm_mailbox`, `save_component`, `reload_component_footprint sdm_mailbox`, `validate_component_footprint sdm_mailbox`, and `save_system`; it explicitly reports **“Generic Component validation successful.”** This establishes save/reload/footprint validation, not RTL generation.
- Reviewed child SHA-256: `e3571b6d6b0e04bcc488be3c0a309571c2ccb6a0564c530f43b41dabe4cfd82a`; leaf: `b6b28be4555938f513102b9a32ac99dc40a61083bb6b063c8f2c20b03e54a8c6`.
- Of existing inputs, only `mailbox_migration.qsf`, `bwbmc/bmc_spi_sub.qsys`, and `bwbmc/ip/bmc_spi_sub/sdm_mailbox.ip` changed during refresh. QSF now includes `QSYS_FILE bwbmc/bmc_spi_sub.qsys`, retaining `FAMILY "Agilex 7"`, `DEVICE AGFB027R25A2E2V`, and the power-management assignments. QPF is unchanged. Recorded hashes of every other inventoried `bwbmc` input match the maintained local files, including the enclosing parent, sibling IP, custom components, wrapper, and design-file Tcl.

### Mailbox configuration and interface

All original leaf module parameters are preserved without value changes or removals:

| Parameter | Saved value |
|---|---|
| DEVICE_FAMILY / AUTO_DEVICE / AUTO_DEVICE_SPEEDGRADE | Agilex 7 / AGFB027R25A2E2V / 2 |
| CMD_FIFO_DEPTH / CMD_USE_MEMORY_BLOCKS | 1024 / 1 |
| RSP_FIFO_DEPTH / RSP_USE_MEMORY_BLOCKS | 1024 / 1 |
| URG_FIFO_DEPTH / URG_USE_MEMORY_BLOCKS | 4 / 1 |
| DEBUG / HAS_URGENT / HAS_STATUS | 0 / 0 / 1 |
| HAS_STREAM / STREAM_WIDTH / HAS_OFFLOAD | 0 / 32 / 0 |
| CRYPTO_MEMORY_TIMEOUT_VALUE | 10000 |

`AUTO_BOARD=default` is the additional upgrade-era parameter; it is not a changed feature selection. The leaf remains mailbox IP 23.0.0, and the child’s `originalModuleInfo` now agrees (previously 20.2.2).

Decoded XML confirms agreement among the leaf `lockedInterfaceDefinition` and the child mailbox `componentDefinition.boundary` and `defaultBoundary`. Each Avalon boundary contains exactly one of each role: address (4-bit input), write/read (1-bit inputs), writedata (32-bit input), readdata (32-bit output), readdatavalid and **waitrequest (1-bit outputs)**. Clock/reset inputs and IRQ output remain scalar. `avmm_waitrequest` has lower bound 0 and `STD_LOGIC` type. The leaf IP-XACT logical `waitrequest` maps to physical `avmm_waitrequest`; its model declares a scalar output, and its interface-boundary mapping retains the same internal name.

The new port has `terminationValue=0`, like the other serialized ports, but no explicit termination flag is present in these port records. That value alone does **not** establish a tied-off output. The full Avalon connection remains `sdm_pipeline.m0 -> sdm_mailbox.avmm`; generation must show real backpressure wiring, not a constant substitution. The refresh also synchronizes the saved default/locked interface metadata with the already-upgraded leaf (`waitrequestTimeout=1024` and DFH fields).

Leaf `altera_has_errors=false` and `altera_has_warnings=false`; child `altera_has_errors` changes from true to false. Child `altera_has_warnings=true` remains: this is not a warning-free-system claim, and the refresh log does not identify its cause.

### Surrounding subsystem

All 17 child module instances remain; only `sdm_mailbox` changes structurally relative to the prior upgrade result. All 46 connections are unchanged by refresh, as are exported interfaces, interconnect requirements, wire-level connections, and HDL parameter mappings. Relative to maintained original XML, connection kinds/endpoints and every pre-existing connection parameter, including every base address, are preserved. Upgrade serialization adds `qsys_mm.fifoDepth=8` and `qsys_mm.splitCommandsFor4KBoundary=FALSE`, and advances connection version metadata to 26.1; it is therefore not byte-identical to the original design.

Other original generic-module settings are retained apart from upgrade-added boundary metadata and empty `fileSetFileChangeDefs` serialization; original HDL descriptors and assignments remain. Sibling leaf IP hashes are unchanged. Child naming becomes the save-time `$${FILENAME}` placeholder, and mailbox bookkeeping changes (`bspCpu=false`, `liveModuleName=sdm_mailbox`, empty transform descriptor) are not topology edits.

Reset topology is preserved, not redesigned: `sdm_reset.out_reset` feeds the mailbox; `system_rst_bridge.out_reset` remains the shared reset for the pipeline and other existing clients. The enclosing parent still connects `sysrst_bridge.out_reset` to `bmc_spi_sub_0.system_rst` and exports `bmc_spi_sub_0.sdm_reset` separately. The unchanged wrapper hash establishes that this operation did not modify any wrapper-level shared-reset wiring.

## Exact next parent footprint operation

Use the existing `successor-first-u01/parent.tcl` operation order below in the next scratch tree containing the accepted leaf and child. Its old fixed cwd (`scratch-first-7c407469a419-u01/bwbmc`) and `../evidence/parent-claim.json` existence check are historical execution bookkeeping, not reasons to request another user approval. Rebind the scratch cwd for the chosen monitored run; do not execute the old script verbatim against the wrong tree or overwrite the consumed refresh evidence.

```tcl
if {[catch {
    load_system bw_840_support.qsys
    puts "SYNC_MESSAGES [sync_sysinfo_parameters bmc_spi_sub_0]"
    puts "RELOAD_MESSAGES [reload_component_footprint bmc_spi_sub_0]"
    puts "VALIDATION_MESSAGES [validate_component_footprint bmc_spi_sub_0]"
    save_system bw_840_support.qsys
    puts MAILBOX_PARENT_SAVE_COMPLETE
} message options]} {
    puts stderr "MAILBOX_MIGRATION_ERROR: $message"
    puts stderr [dict get $options -errorinfo]
    exit 1
}
```

This refreshes the named enclosing proxy, not every instance and not the mailbox again. Review the resulting parent messages and saved XML for retained exports, addresses, device and reset connections. A successful parent refresh has not yet been demonstrated by the present payloads.

## Minimal remaining work

1. **Enclosing-parent refresh:** execute the named operation above and inspect its saved result. The current enclosing parent is unchanged, so nested acceptance cannot be claimed yet.
2. **Actual generation:** generate standalone mailbox RTL and nested subsystem RTL using the accepted saved sources (and refreshed enclosing parent for that level). Confirm generated files/manifests actually exist, correct device/features/FIFO settings reach the implementation, interfaces match the reviewed directions/widths, and mailbox `waitrequest` reaches its Avalon upstream logic without omission, duplicate role, unexpected termination, or unresolved port. Confirm the nested hierarchy resolves sibling/custom components and retains address and reset routing. Inspect actual warnings/errors, including the retained child warning flag, rather than treating rc=0 alone as sufficient.

These are the next experiments, not prerequisites demanding their results before they may run. No additional static catalog exploration, generic approval machinery, or hardware-runtime proof is needed to proceed. Build, synthesis/timing, and hardware readiness remain unestablished and false.
