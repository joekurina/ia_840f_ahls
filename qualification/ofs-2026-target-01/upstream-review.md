# OFS `ofs-2026.1-1`: upstream applicability to IA840F AHLS

**Reviewed 2026-09-22 UTC. Source research only; no build, hardware, timing acceptance or authorization.**

## Decision

**Honor `OFS/examples-afu:ofs-2026.1-1` as the explicitly selected target. Its prerelease flag is metadata, not a blocker.** The official release is published, not a draft, identifies an optional PR-freeze propagation change, and resolves to the examples commit already in `sources.lock.json`.[7][8]

**There is no publicly verified four-repository `ofs-2026.1-1` release tuple.** The examples release must not be relabeled as a new FIM/common release. Direct release/tag lookups returned HTTP 404 for FIM, common and PIM. Independent public tag/branch enumeration corroborated this: FIM/common publish through `ofs-2025.1-1`; PIM has no 2026 release tag and its current `master` is the already pinned PR-freeze merge.[10][12][14] The FIM/common branch inventories likewise end at `release/ofs-2025.1`, rather than exposing a `release/ofs-2026.1` branch.[15][16]

**The obsolete `top.sdc` divider hierarchy is not fixed by selecting this examples release.** The publicly available FIM donor still contains it, byte-for-byte identical to the maintained IA840F tree's entire `top.sdc`; the examples change does not supply a replacement FIM constraint.[24][19]

**Smallest justified path:** keep all four current immutable donor pins, retain Quartus Pro **26.1.1** / AHLS **2026.1.0** as the user-selected tools, and finish the narrow board-integration clock/exception and AFU-interface work. Do not downgrade tools, discard IA840F features, substitute a development-kit board, or wait for a nonexistent public FIM tag. This is a project integration recommendation, **not** an upstream-certified combined release.

## 1. Exact pins and what each actually proves

| Component | Recommended immutable pin | Official meaning |
|---|---|---|
| FIM — `OFS/ofs-agx7-pcie-attach` | `599ac052eafbc9cede22561c099233ae4a54cb7d` | Direct commit-valued tag `ofs-2025.1-1`; retain the existing IA840F port on this donor, not a clean devkit replacement.[35] |
| Common — `OFS/ofs-fim-common` | `34a8540697fdf3d66fbcaa263fa037bae17cc32f` | Direct tag `ofs-2025.1-1` **and the exact `ofs-common` gitlink in the FIM above**.[36][20] |
| PIM — `OFS/ofs-platform-afu-bbb` | `3c21189e728009d4c492fa2be54c0ab1008b06dc` | Current official `master` snapshot, merge of PR #27, “adding PR freeze to pr wrapper”; not a 2026 tag.[17][18] |
| Examples — `OFS/examples-afu` | `4a1350e3c9e223d8bac3cb47f756a1d919ef8de1` | Direct tag `ofs-2026.1-1`; release published `2026-08-03T20:21:39Z`, `prerelease=true`, `draft=false`.[7][8] |

The FIM `.gitmodules` identifies the common repository as `https://github.com/OFS/ofs-fim-common.git`; its tree pins common rather than leaving this dependency to a branch tip.[26][20] No analogous coordinated FIM/common/PIM pin manifest was supplied by the inspected examples release; its release body is only: “Propagated pr_freeze signal to AFU. It's optional to be used in AFU”.[7]

Local `sources.lock.json` already contains all four recommended commits. Therefore **the smallest pin migration is zero commit changes**. `recommended-pins.json` records this recommendation separately; the maintained lock file was not edited. The existing lock's statement that independently selected donors are not a qualified combined release remains substantively correct. A later authorized documentation change should distinguish the selected examples target from the FIM donor release, rather than inventing `fim_release=ofs-2026.1-1`.

## 2. Documented support versus project qualification

- **FIM documentation:** the official `ofs-2025.1-1` release specifies **Quartus Prime Pro 25.1**, no Quartus patches, and N6000/N6001 P-Tile, Agilex 7 F-Series F-Tile and I-Series R-Tile development-kit reference shells. IA840F is not in that supported-board list. P-Tile Gen4 x16 and PR are present in the reference feature matrix, but that is not validation of IA840F's device, mixed DDR, BMC or pinout.[9]
- **AHLS documentation:** the current official handbook, whose revision history identifies the first major release as **June 2026 / 2026.1**, explicitly requires **Quartus Prime Pro Edition 26.1 for Agilex 7** and describes integration of generated IP using Quartus or Platform Designer.[40] This independently supports the chosen toolchain family and generated-RTL integration architecture; it does not certify the exact IA840F FIM + common + PIM + AHLS 2026.1.0 + Quartus 26.1.1 combination.
- **Examples/PIM:** the inspected 2026 changes are interface/source changes, not Quartus 26.1.1 or AHLS qualification reports.[18][19][37] The tutorial explicitly supports FIM integration with or without PR and describes a matching out-of-tree PR build environment; examples alone are not a replacement shell.[29]
- **No oneAPI downgrade:** the FIM release's “OneAPI has not been validated” warning concerns oneAPI, not proof that AHLS-generated component RTL is unsupported. Its recommendation of an older OFS release for oneAPI is not adopted for this AHLS task.[9]

The reported installed tool versions and Work14 result are supplied project context, not new installation/build observations. No current workstation state or hardware behavior was inspected.

## 3. PCIe generated clock / P-Tile: exact applicability

### Upstream still has the obsolete intermediate hierarchy

At FIM `599ac052…`, `syn/shared_config/top.sdc:35–37` reads:[24]

```tcl
create_generated_clock -add -name pcie_wrapper|pcie_ss.top|*|pcie_ss|avmm_clock0 \
                       -source      [get_pins {pcie_wrapper|pcie_ss.top|*|pcie_ss|u_pciess_p0|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|inclk}] \
                       -divide_by 2 [get_pins {pcie_wrapper|pcie_ss.top|*|pcie_ss|u_pciess_p0|gen_sub.u_hipif|u_pciess_clock_divider|clkdiv_inst|clock_div2}]
```

Both fetched upstream and maintained local file have SHA256:

`8255b34c200a46178174b9788bdc9231072ae829f57c34703cc63dd28ab66c3d`

Thus this is **an inherited donor constraint, not a local deviation repaired by the selected examples tag**. The source history explains a potentially misleading earlier “PCIe hierarchy” change: commit `aa850e7b8f24b58a063ae42c324362e2e94101c8` introduced an AXI-S wrapper stub and changed the outer `pcie_ss_top` spelling to `pcie_ss.top`; it did **not** introduce the modern internal P/F-Tile wrapper path.[38] The later inspected `top.sdc` change, `7c5b616b4411ab78066c6938985d35acc923f698`, changes the memory asynchronous group, not the divider binding.[39]

### Required modern path is local generated/fitted evidence, not an upstream release fix

The existing, read-only `../pcie-clock-binding-01/independent-research.md` establishes the Work14 intermediate substitution:

```text
old:    |u_pciess_p0|gen_sub.u_hipif|
modern: |EP_PFTILE_WRAPPER.gen_pciess.u_pciess_p0|u_pciess|gen_sub.u_hipif|
```

That report distinguishes the vendor target pin `clkdiv_inst|clock_div2`, fitter net `clock_div2x`, and unconstrained STA `clkdiv_inst~div_reg`; they are **not proved interchangeable**. It supports divide-by-two from the real CSR clock `sys_pll|iopll_0_clk_100m`, while leaving exact final pin collections, output aliasing and receiver/exception scope unresolved. The generated vendor SDC's standalone-port gating is not proof that it supplies a valid integrated clock. This review does not repeat or enlarge that earlier investigation.

The same public `top.sdc` contains dependent asynchronous groups at lines 49/51 and global AVMM↔CSR setup/hold multicycles at lines 57–60.[24] Restoring the clock name changes their applicability. Therefore the smallest responsible correction remains **one narrowly reviewed integration-clock change plus explicit dependent-exception disposition**, not a blind selector replacement, another unconditional clock, a blanket timing cut, or edits to generated vendor SDC. The separate Work14 EMIF1 hold result of **−0.004 ns** supplied in task context is not cured, waived or reclassified by this release selection.

## 4. Relevant 2026 PR changes—and the integration seam

| Source delta | Verified effect | IA840F implication |
|---|---|---|
| PIM merge `3c21189e…` | Adds `logic pr_freeze_to_afu_in;` to `plat_if_develop/ofs_plat_if/src/rtl/ofs_plat_if.template.sv:32–33`, documented as optional for AFUs needing the FIM FSM freeze signal.[18][27] | An interface declaration is not a connected FIM-to-AFU signal. Keep the pin, but do not claim freeze propagation solely from it. |
| Examples merge `718be24b…` (PR #31) | Adds `pr_freeze_to_afu` input to hybrid `afu_main` wrappers and the raw `afu_main` example's `port_afu_instances`.[37] | Relevant when those interface classes/wrappers are selected; not a PCIe clock fix. |
| Examples selected merge `4a1350e…` (PR #32) | Adds the matching input in hybrid port modules, raw `afu_main`, and multi-link port module.[19] | The tag contains the follow-on port-list correction; do not stop at the earlier merge. |

The pinned common Agilex `pr_slot.sv` already implements PR isolation bridges driven by `pr_freeze`, but its `afu_main` instantiation at lines 331 onward does not pass `pr_freeze_to_afu`.[41] Its PIM `port_afu_instances.sv` assigns the normal reset/power fields but has no `pr_freeze_to_afu_in` connection.[42] The selected hybrid example uses `.*` to pass matching wrapper signals; the examined port module declares the new freeze input but does not itself consume it.[43][44]

**Distinguish existing shell isolation from optional AFU notification.** The public 2025 common donor plus 2026 PIM/examples does not, by itself, prove the new notification is driven end to end. If the actual AHLS wrapper does not use the optional sideband, retaining existing isolation avoids an unrelated PR-boundary redesign. If it does use it—or a selected new example requires a matching binding—review the exact FIM → `afu_main` → port/PIM connection and synchronization in that instance. Do not infer a drain/quiescence guarantee, tie it inactive to hide a mismatch, disable PR, or replace the board shell just to match a sample port list.

## 5. Minimum migration recommendation and stopping point

1. **Accept the authorized prerelease target without a prerelease approval gate.** Preserve the four exact pins above; explicitly describe the combination as IA840F's Quartus-26.1.1/AHLS integration using a 2025.1 FIM/common donor and the selected 2026 examples/PIM source changes. No public newer FIM/common pin was found to substitute.
2. **Preserve board authority and scope.** Keep the vendor-derived IA840F device/pins, P-Tile Gen4 x16, both distinct DDR channels, BMC and intended PR/features. Upstream devkit presets and prebuilt images are not IA840F replacements.
3. **Resolve the inherited integration constraint at its existing source point.** Use the precise modern hierarchy evidence, actual CSR-master relationship, no-duplicate clock checks and exception-scope review from the existing clock report. No upstream update removes this task. Do not weaken timing to make diagnostics disappear.
4. **Keep AHLS as component RTL/IP through PIM with OPAE/DFL host access.** Retain the current wrapper path where possible. Audit the optional PR-freeze seam only to the extent required by the actual selected AFU interface; examples membership is not a mandate to adopt every tutorial wrapper.
5. **Qualification remains separate.** A later authorized fresh FIM and matching AFU/PR-template build must establish clock binding and timing, including the independent hold failure. Numerical AHLS execution, memory/PCIe behavior and PR safety require their separately authorized verification. Neither this report nor upstream publication accepts the existing hardware image.

These are recommendations only. This task made **no maintained-source, lock, prompt, gate, other-report, git-index/ref, or remote changes**, and ran no vendor tools, builds, simulations or hardware operations.

## 6. Retained evidence and limits

All task artifacts are in this directory. JSON captures retain retrieval URLs, original response hashes where fetched directly, exact commits, selected response fields or literal source text. For projected JSON, `sha256` refers to the **original HTTP response**, not the reserialized capture file; `SHA256SUMS` binds the actual retained files. Tree inventories are intentionally filtered, not full source archives.

- `release-tag-metadata.json`: exact requested 2026 lookups, including six public HTTP 404 responses and the successful examples release/tag.
- `release-discovery.json`, `branch-commit-discovery.json`, `upstream-history-metadata.json`: corroborating release/tag/branch inventories and bounded path histories. Older unrelated release bodies are excerpted.
- `source-tree-metadata.json`, `pin-and-delta-metadata.json`: FIM gitlink, tag identities and relevant source deltas.
- `pinned-source-captures.json`, `pr-source-captures.json`: immutable upstream `top.sdc`, dependency/readme/interface and PR wrapper source.
- `ahls-handbook-excerpts.json`: live official handbook requirements, integration statement and revision history. The second direct section URL timed out; the successful full-handbook extraction supplied the actual evidence, cross-checked against the existing local handbook copy.
- `local-source-binding.json`: local lock/report/SDC/PIM fingerprints and comparison. The prior independent clock report is evidence reused within its own bounds, not a new post-fit query.
- `recommended-pins.json`, `source-evidence.txt`, `citations.json`, `SHA256SUMS`: recommendation, verbatim citation evidence and integrity records.

**Limits:** public repositories and official documentation only; no assertion about private/unpublished future FIM releases. No demonstrated native pin binding, complete exception-safe clock repair, exact-tool combined support certification, hardware acceptance or automatically safe PR sequence is claimed.

## Sources

[7] https://api.github.com/repos/OFS/examples-afu/releases/tags/ofs-2026.1-1
[8] https://api.github.com/repos/OFS/examples-afu/git/ref/tags/ofs-2026.1-1
[9] https://api.github.com/repos/OFS/ofs-agx7-pcie-attach/releases?per_page=10
[10] https://api.github.com/repos/OFS/ofs-agx7-pcie-attach/tags?per_page=30
[12] https://api.github.com/repos/OFS/ofs-fim-common/tags?per_page=30
[14] https://api.github.com/repos/OFS/ofs-platform-afu-bbb/tags?per_page=30
[15] https://api.github.com/repos/OFS/ofs-agx7-pcie-attach/branches?per_page=100
[16] https://api.github.com/repos/OFS/ofs-fim-common/branches?per_page=100
[17] https://api.github.com/repos/OFS/ofs-platform-afu-bbb/branches?per_page=100
[18] https://api.github.com/repos/OFS/ofs-platform-afu-bbb/commits/3c21189e728009d4c492fa2be54c0ab1008b06dc
[19] https://api.github.com/repos/OFS/examples-afu/commits/4a1350e3c9e223d8bac3cb47f756a1d919ef8de1
[20] https://api.github.com/repos/OFS/ofs-agx7-pcie-attach/git/trees/599ac052eafbc9cede22561c099233ae4a54cb7d
[24] https://raw.githubusercontent.com/OFS/ofs-agx7-pcie-attach/599ac052eafbc9cede22561c099233ae4a54cb7d/syn/shared_config/top.sdc
[26] https://raw.githubusercontent.com/OFS/ofs-agx7-pcie-attach/599ac052eafbc9cede22561c099233ae4a54cb7d/.gitmodules
[27] https://raw.githubusercontent.com/OFS/ofs-platform-afu-bbb/3c21189e728009d4c492fa2be54c0ab1008b06dc/plat_if_develop/ofs_plat_if/src/rtl/ofs_plat_if.template.sv
[29] https://raw.githubusercontent.com/OFS/examples-afu/4a1350e3c9e223d8bac3cb47f756a1d919ef8de1/tutorial/README.md
[35] https://api.github.com/repos/OFS/ofs-agx7-pcie-attach/git/ref/tags/ofs-2025.1-1
[36] https://api.github.com/repos/OFS/ofs-fim-common/git/ref/tags/ofs-2025.1-1
[37] https://api.github.com/repos/OFS/examples-afu/commits/718be24b073f72d4a2c49c041513b34121dc5a16
[38] https://api.github.com/repos/OFS/ofs-agx7-pcie-attach/commits/aa850e7b8f24b58a063ae42c324362e2e94101c8
[39] https://api.github.com/repos/OFS/ofs-agx7-pcie-attach/commits/7c5b616b4411ab78066c6938985d35acc923f698
[40] https://docs.altera.com/r/docs/m615048/current/hls-ip-gen-handbook/1-altera-hls-ip-gen-handbook
[41] https://raw.githubusercontent.com/OFS/ofs-fim-common/34a8540697fdf3d66fbcaa263fa037bae17cc32f/src/fpga_family/agilex/port_gasket/pr_slot.sv
[42] https://raw.githubusercontent.com/OFS/ofs-fim-common/34a8540697fdf3d66fbcaa263fa037bae17cc32f/src/fpga_family/agilex/port_gasket/afu_main_pim/port_afu_instances.sv
[43] https://raw.githubusercontent.com/OFS/examples-afu/4a1350e3c9e223d8bac3cb47f756a1d919ef8de1/tutorial/afu_types/02_hybrid/hello_world/hw/rtl/afu_main.sv
[44] https://raw.githubusercontent.com/OFS/examples-afu/4a1350e3c9e223d8bac3cb47f756a1d919ef8de1/tutorial/afu_types/02_hybrid/hello_world/hw/rtl/port_afu_instances.sv
