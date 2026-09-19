# Parent03 saved-source compatibility review

## Finding

**Parent03 completes the named save/footprint operation, but does not establish a compatible enclosing-parent boundary.** There is a concrete regression in the saved `bmc_spi_sub_0` proxy: its previously populated clock/reset associations become empty, although its ports and the actual clock/reset connections remain intact. This is a source-level suspect for the newly true parent error flag—not a proven vendor diagnostic or a reason to change permissions. The captured log does not identify the error's cause. No qualification claim is made.

This review used local captured JSON/XML and maintained read-only sources only. No vendor command, network access, test, generation launch, wait, or poll was performed. The already-launched generation-04 experiment is outside this review.

## Evidence and comparison scope

References below use JSON payload keys and XML selectors because `result-evidence.json` is a single-line container. `a` denotes `http://www.altera.com/XMLSchema/IPXact2014/extensions`; `i` denotes `http://www.accellera.org/XMLSchema/IPXACT/1685-2014`.

- **P:** this directory's `result-evidence.json`. Recomputed all **41** content SHA-256 values successfully; captured design payload hashes agree with `after.json`.
- **R:** `../monitored-refresh-02/result-evidence.json` and `output-review.md`. All nine R payload hashes recompute; P's input hashes for QPF, QSF, child and mailbox match R's outputs.
- **M:** maintained absolute root `/home/joe/Projects/Thesis/AHLS/new_bsp/new/ofs-agx7-pcie-attach/ipss/ia840f/bwbmc`. The P parent input hash matches M's parent. Maintained sources were not modified.
- **L:** `leaf-parameter-comparison.json`, independently checked against parsed `a:altera_module_parameters` in the leaf payloads and M.
- Reviewed parent SHA: `cdb982ac90486b0e820e036b97c097a9d2530524eaa2c77217d5909b30267d13`; child SHA: `e2cdea661181a1490e938f41aaf5c62f059ee9b264d507d8847ae7591cb64bac`.

P's `result.json` records rc=0 and `ready_for_build=false`. `refresh.log` records `sync_sysinfo_parameters bmc_spi_sub_0`, all 17 nested instances being synchronized, footprint reload, “All Generic Components within subsystem are valid,” and save. That message validates nested Generic Component footprints; it is not a whole-parent error-free validation. P's parent `a:altera_has_errors=true` differs from M/input `false`; the child remains `false`. Both saved systems retain warnings=true.

## Actual write footprint and configurations

The before/after inventories agree with the **19 changed inputs** in P's result: QSF, both Qsys systems and 16 child sibling IP files. The mailbox IP itself is unchanged from refresh-02. QSF adds the parent QSYS_FILE while retaining the child, Agilex 7/AGFB027R25A2E2V and power-management assignments. QPF is unchanged. Parent-level leaf IP files and wrapper remain hash-identical to M.

| Item | Observed configuration change |
|---|---|
| `bmc_spi_to_avmm.ip` | SPI 19.1.3 → 20.0.0; no module parameter differences |
| `bmc_spi_cardtest_pipe`, `bmc_spi_pipe0`, `bmc_spi_sdm_pipe`, `bmc_spi_support_pipe`, `bmc_spi_xcvr_pipe`, `host_sdm_pipe`, `host_support_pipe`, `sdm_pipeline` | Eight bridges 20.0.1 → 20.1.0; each adds `S0_WAITREQUEST_ALLOWANCE=0` and `M0_WAITREQUEST_ALLOWANCE=0`; pre-existing module parameter values retained |
| `ocmem.ip` | RAM 19.3.7 → 19.3.9; `deviceFeatures` catalog map changes; 48 feature keys added, eight removed, no values changed among shared keys; remaining module parameters retained |
| Mailbox | Still 23.0.0 with the accepted FIFO/feature choices and `AUTO_BOARD=default`; the 20.2.2 → 23.0.0 and AUTO_BOARD entries in L compare against maintained original, **not a new parent03 mailbox upgrade** |
| IRQ generators, reset/clock bridges, arbiter inside child | Files rewritten; no module parameter differences from maintained inputs; changed bytes alone must not be reported as changed functional settings |

Thus the named parent operation was not restricted to a single proxy serialization: it synchronized/upgraded nested siblings. Existing parameter preservation is necessary but does not prove implementation equivalence across those versions. RAM feature-map churn is not evidence of a user-requested memory-size change.

Sources: P `before.json`, `after.json`, `result.json`, `refresh.log`, all `bwbmc/ip/bmc_spi_sub/*.ip`; L; M matching leaf files.

## Concrete enclosing boundary regression

Decode `i:value` of `componentDefinition` in the `a:module` whose `a:entity_info/i:library` is `bmc_spi_sub_0`. Inspect `boundary/interfaces/interface/parameters/parameterValueMap/entry` by `key`:

| Interface(s) | Maintained/input association | Parent03 saved association |
|---|---|---|
| `bmc_spi_cardtest_mm`, `bmc_spi_xcvr_mm`, `host_sdm`, `host_support` | `associatedClock=system_clk`, `associatedReset=system_rst` | Keys retained, value elements absent |
| `pcie_irq`, `bmc_irq` | `associatedClock=system_clk`, `associatedReset=system_rst` | Clock value absent; reset value empty |
| `sdm_mailbox_irq` | `associatedClock=system_clk`, `associatedReset=sdm_reset` | Clock value absent; reset value empty |
| `sdm_reset`, `system_rst` | `associatedClock=system_clk` | Value absent; `synchronousEdges=DEASSERT` retained |

All 11 interface port subtrees compare equal to the input, including directions, widths and termination-value records. This is **lost association metadata, not missing physical ports**. No other parent's module shows a clock/reset association-value difference. The proxy also receives newer Avalon metadata such as `waitrequestTimeout=1024`, optimized-read/DFH fields and original-module version `1.0`.

The child still records bridge Avalon associations `clk/reset`; bridge reset interfaces associate with `clk`. Mailbox `avmm` and `irq` associate with `in_clk/in_reset`; the child connects `system_clk_bridge.out_clk` to mailbox `in_clk` and `sdm_reset.out_reset` to mailbox `in_reset`. These are not consistent with interpreting the new empty parent associations as an intentional clockless/resetless interface design.

**Exact correction evidence:** the table supplies the original populated values, and the child's preserved wiring supports them. If generation diagnostics identify missing clock/reset associations at this proxy, restore/rederive those mappings in scratch through the component/system mechanism and verify the saved boundary plus generated result. Do not blindly rewrite XML, force the error flag false, or assign `system_rst` to `sdm_mailbox_irq`: that IRQ's original reset association is specifically `sdm_reset`. No repair was applied or tested in this review.

**No newly missing default boundary is exposed:** `bmc_spi_sub_0.defaultBoundary` is empty both before and after. All seven other parent's modules retain their defaultBoundary strings unchanged. That pre-existing empty subsystem default does not itself establish a new defect. Likewise the mailbox's corrected waitrequest survives: its IP hash is unchanged from R, and the child footprint retains one scalar output `avmm_waitrequest`. A serialized terminationValue=0 alone does not mean that port is tied off.

Sources: P `bwbmc/bw_840_support.qsys` and `bwbmc/bmc_spi_sub.qsys`, decoded componentDefinition/defaultBoundary parameters; M parent; R child/mailbox payloads.

## Actual connections, exports and address/reset preservation

These systems serialize connections under **`a:connection`**, with namespaced `a:kind`, `a:start`, `a:end` attributes and `a:connection_parameter` children. A search only for IP-XACT `interconnections` returns no evidence and cannot establish topology preservation.

Parsed comparison establishes:

- Parent: **19 connections**, all endpoint/kind tuples and every pre-existing connection parameter unchanged from M/input. Connection versions become 26.1; Avalon connections add `qsys_mm.fifoDepth=8` and `qsys_mm.splitCommandsFor4KBoundary=FALSE`.
- Child: **46 connections**, all endpoint/kind tuples and connection parameters unchanged from R.
- Parent's seven `a:interface_mapping` records and child's eleven mappings are unchanged.

Parent Avalon routing:

| Start | End | Base address |
|---|---|---|
| `axi_bridge_0.m0` | `mm_bridge_0.s0` | `0x0000` |
| `mm_bridge_0.m0` | `sysid_qsys_0.control_slave` | `0x0000` |
| `mm_bridge_0.m0` | `host_sdm_pipeline.s0` | `0x1000` |
| `mm_bridge_0.m0` | `host_bmc_support_pipeline.s0` | `0x4000` |
| `host_sdm_pipeline.m0` | `bmc_spi_sub_0.host_sdm` | `0x0000` |
| `host_bmc_support_pipeline.m0` | `bmc_spi_sub_0.host_support` | `0x0000` |

Parent exports are `axi_s_bw→axi_bridge_0.s0`, `bmc_irq→bmc_spi_sub_0.bmc_irq`, `bmc_spi→bmc_spi_sub_0.bmc_spi_to_avmm`, `pcie_irq→bmc_spi_sub_0.pcie_irq`, `sdm_reset→bmc_spi_sub_0.sdm_reset`, `sysclk→sysclk_bridge.in_clk`, `sysrst→sysrst_bridge.in_reset`.

`sysclk_bridge.out_clk→bmc_spi_sub_0.system_clk` and `sysrst_bridge.out_reset→bmc_spi_sub_0.system_rst` remain real connections. The SDM reset remains separately exported. Within the child, `sdm_pipeline.m0→sdm_mailbox.avmm` remains at `0x0000`; pipeline shared reset and mailbox SDM reset remain distinct. Wrapper bytes are unchanged.

The subsystem's `bmc_spi_cardtest_mm`, `bmc_spi_xcvr_mm` and `sdm_mailbox_irq` are neither connected nor exported at the enclosing parent in both input and output. Their absence is not a newly dropped export. Empty consumed address-map/width entries for the two unconnected masters are also pre-existing; this evidence does not justify inventing endpoints or default slaves.

## Acceptance checks against the already-running generation experiment

1. Separate leaf, child and enclosing-parent diagnostics. Determine whether the parent reports the lost proxy clock/reset associations or another cause; the saved flag alone cannot identify the diagnostic.
2. Verify actual generated outputs/manifests and unresolved-interface diagnostics, not rc=0 alone. The positive evidence here is footprint saving, not generated RTL.
3. Confirm mailbox waitrequest is wired through `sdm_pipeline` with the upgraded bridges' zero allowance semantics, without omitted/duplicated roles or unexpected constant termination. Preserve device and mailbox features/FIFO choices.
4. Check generated parent clock/reset associations and routing against the exact table and connection records above; preserve distinct SDM reset and address windows. If corrected, read back the precise saved proxy and require diagnostics to clear rather than editing error metadata.
5. Include the SPI/bridge/RAM version refreshes in compatibility acceptance; do not treat parent03 as a mailbox-only delta. Retained parent sibling IPs and custom components must resolve in the nested generation.

The topology and existing user configuration are preserved, but the enclosing association regression prevents an unqualified source-compatibility conclusion. Actual generation diagnostics remain the next discriminator. No additional authorization framework, sandbox work, or generic infrastructure is proposed.
