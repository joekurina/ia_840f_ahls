# Guarded actual-PIM top — native Quartus 25.1 analysis/elaboration

Fresh isolated work_ahls_memory_pim25_03/elab01, device AGFB027R25A2E2V, top ofs_plat_afu. Retain accepted pim02 actual primary host mapper, both page-safe local-memory shims, generated HLS reset-index overlays and connected DMA/fabric. Add exactly the FINAL-reviewed simulation guard and redirect only flat-core MMIO signals through it. Full20-bit MMIO sees admission before generated low17-bit routing. Assign downstream interface clock/reset/instance explicitly from primary-PIM MMIO; the guard adds no CDC or clock/reset-domain changes.

Original tops remain separately preserved. Compile one alternate top and one selected guard only. The source/geometry/QSF changes are exact and recorded. Same tools, resource checks, native command and lifetime supervision as accepted pim02; no installed/vendor/source-tree mutation. Existing runner export exceptions remain an acquisition limitation, not a sandbox or global host safety guarantee.

This qualifies source structure only if native result and subsequent review pass. It does not simulate the primary PCIe mapper, qualify native mapped synthesis/fit/STA, close reset release/freeze/control/global drain/buffer lifetime, or authorize live MMIO. No programming/device access/driver changes/reboot; vendor DDR simulation SKIPPED BY USER. The full hardware goal remains incomplete.

## Authorized stage extension: mapped synthesis

After elab01 completed with native/effective/outer0 and unchanged preservation flags, run the byte-identical source/QSF in fresh synth01 with explicit `--synthesis` instead of `--analysis_and_elaboration`. The installed25.1 help recognizes that option, and retained Work21 native source-context grammar includes it. This is a new native stage, not a repeat elaboration for bookkeeping. Preserve both attempts. Same twoCPU/16GiB-per-process/600s supervision, resource and original/tool checks. The project basename retains `_elab` but stage claims derive from argv and native reports, not basename/banner. Full FIM/persona fit/STA and hardware remain separate.

The stage-only synth01 failed immediately because a fresh project has no elaboration database. Preserve that invocation failure. Successor synth02 removes only `--synthesis` and uses the retained Work21 normal full-synthesis argv, running A&E plus mapping from source without a copied QDB. All sources/settings/resources and hardware exclusions remain unchanged.
