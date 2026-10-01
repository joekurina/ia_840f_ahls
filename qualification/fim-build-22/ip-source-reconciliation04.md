# Work21 saved-IP / OFS 2026.1 source reconciliation

## Result and scope

**Do not bulk-overlay the new donor IP files onto the qualified board configuration.**
The 83 captured declarations are complete (6 QSYS + 77 IP): **46 intersect the
vendor01 delta; 44 of those are byte-identical to the old donor, but `sys_pll.ip`
and `ed_sim_mem.ip` contain real Work21 overrides.** The other 37 comprise
26 board-owned BMC definitions, 8 unchanged remote-STP definitions, and 3
board-generated definitions absent at the same paths in both upstream donors.

This is local source analysis only: no remote contact, repository scripts/tests,
vendor tools, native regeneration, synthesis, fit, timing, or hardware operation.
No native proof is supplied. The selected **four-line PCIe constraint** is unchanged;
this report does not select the parked guarded alternative or issue authorization.

### Bound inputs and method

Repository: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.
All IP paths below are relative to `qualification/fim-build-22/ipinputs03-readback/`
for Work21, or `ofs-agx7-pcie-attach/` for the maintained source. Old/new common
paths are resolved inside the nested common Git repository, not through its gitlink.

- Accepted maintained source: `5110937a78e88251a0d3056182f0be002527e869`.
- FIM: `599ac052eafbc9cede22561c099233ae4a54cb7d` → `866c25bb166810f65aae4f6b15374d0a89810e69`.
- Common: `34a8540697fdf3d66fbcaa263fa037bae17cc32f` → `147cae890b7d1245301cf5cde229f761b287b70d`.
- PIM pin supplied by the campaign: `3c21189e728009d4c492fa2be54c0ab1008b06dc`; PIM internals are outside this IP comparison.

Verified the compressed capture against `ipinputs03-collection.json`, all 83
payload/readback sizes and SHA-256 values (12,988,691 input bytes), and exact
inventory membership. All 46 old/new blob hashes match
`qualification/migration-source-01/vendor01/manifest.json`; all 46 new blobs also
match the accepted maintained commit. Duplicate inputs02 copies of PLL, PCIe,
memory and SCJIO are byte-identical to ipinputs03.

Comparisons preserve XML module/submodule, interface and connection identity.
Embedded `componentDefinition`, `generationInfoDefinition` and `systemInfos`
XML were inspected separately. Repeated parameter names were **not** flattened
across modules: notably `mem_ss` contains five separately named saved submodules.

## Board settings that must survive

### 1. `ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip`

Preserve the complete Work21 saved PLL definition as the board-intent baseline.
All three sources request seven outputs, but their requested frequencies differ:

| Source | Requested outclk0..6, MHz | Saved target |
|---|---|---|
| Old donor | 500, 100, 250, 630, 50, 125, 350 | AGFB014R24A2E2V |
| Work21 | **470, 100, 235, 630, 50, 117.5, 350** | **AGFB027R25A2E2V / Agilex 7** |
| New donor | 250, 100, 125, 630, 50, 62.5, 350 | A5ED065BB32AE6SR0 / Agilex 5 |

Work21 already has `altera_iopll` 21.1.0, like the new donor (old: 20.0.0),
and the new saved fields `gui_multiply_fraction=0`,
`gui_set_locked_as_reset=false`, `gui_use_fractional_division=false`, and both
`gui_use_slvs_refclk*` false. It does not need the donor's 250 MHz/family change.

Keep the 100 MHz reference and seven-output footprint. Work21 interface
`clockRate` values are 470000000, 100714286, 235000000, 705000000, 50357143,
117500000, 352500000 Hz. These are consistent with the campaign's **1410 MHz
expected VCO** divided by 3,14,6,2,28,12,4; that arithmetic is not native proof.
The saved GUI also contains inactive/default-looking `gui_vco_frequency=600.0`
and `gui_fix_vco_frequency=false`: do not mistake this field for the solved VCO,
or rewrite requested values from rounded interface metadata. Require fresh native
readback of the actual solution, all seven outputs and unchanged 3.000 ns policy.

### 2. Memory: preserve two different channel definitions, not one flattened map

`ipss/mem/qip/mem_ss/mem_ss.ip` has **no same-path old/new donor blob**. Its
Work21 saved input is authoritative here:

- Top `MEM_INTFS_TYPE=DDR4,DDR4`, locations `BOT,BOT`, application types
  `STORAGE,STORAGE`, channel maps `MEM_CH_0_CONNS=1,0`, `MEM_CH_1_CONNS=0,1`;
  memory CSR and PMON disabled.
- Packaged `emif_0` and `emif_1`: DDR4 DQ64, row17, column10, bank-address2,
  bank-group2, one discrete-CS setting, 1333.333 MHz / DDR4-2666,
  user reference33.333 MHz, ECC disabled. **Their `MEM_DDR4_FORMAT_ENUM` differs:
  `emif_0=MEM_FORMAT_DISCRETE`, `emif_1=MEM_FORMAT_RDIMM`.** Their unique-ID
  strings also differ; all other 1,450 saved parameter values per EMIF match.
- `msa_0` and `msa_1` each retain row17/column10/bank2/bank-group2/chip-select1,
  ECC false and 512-bit response read/write widths; their 28 parameter values match.
  Retain `emif_cal_bot` as well. Do not replace these saved blocks with a generic
  preset or infer geometry from the sparse `ofs_ip_cfg_local_mem.vh` header.

`ipss/mem/qip/ed_sim/ed_sim_mem.ip` is the second true Work21/donor conflict:
134 scoped module values differ from the old donor. Old donor uses DQ32,
DQS4, CS2, bank-group1 and1200 MHz; Work21 uses DQ64/DQS8/CS1/bank-group2,
row17/column10 and1333.333 MHz. The new donor changes 145 old-donor module
values and uses **row16**, not Work21 row17, even though its DQ64/2666 settings
look superficially compatible. Preserve the captured board model and
`ipss/mem/qip/ed_sim/ed_sim_mem_group1.ip` (the latter is absent in both donors).
Group1 retains RDIMM versus group's DISCRETE format; PLL-export diagnostic
flags also differ. Do not duplicate one file over the other.

The model's `FAMILY_INVALID`, empty derived fields and negative sentinel values
are saved model metadata, not evidence that the physical EMIF configuration is
invalid or instructions to copy those values into it. Their effective meaning
requires native regeneration; no vendor-internal requalification is attempted.

### 3. `ipss/pcie/qip/pcie_ss.ip`

Also absent at the same path in both donors. Preserve the entire Work21 saved
configuration: `top_topology_hwtcl=Gen4 1x16`, two PFs, PF0VF0 count1,
PF1 VF count0 and the board PF1/BAR settings. The saved core16 AXI-Lite request
is the integer **100**; core8/core4_0/core4_1 are **250**. Do not substitute the
PLL's100.714286 MHz actual-rate metadata, round it into another setting, or
retarget the inactive core fields to100. The retained source hook
`ofs-common/tools/ofss_config/ia840f_vendor_pcie.py:33-42` explicitly maps the
legacy100 request to `core16_axi_lite_clk_freq_user_hwtcl` without claiming an
actual100 MHz PLL output. Source preservation is not acceptance of the new
PCIe implementation or divider timing.

### 4. BMC and unchanged remote-STP inputs

All **26** inventory entries under `ipss/ia840f/bwbmc/` are absent from both
pure upstream donors and **byte-identical between Work21 and accepted commit5110937**.
Keep them unchanged, including `bw_840_support.qsys`, `bmc_spi_sub.qsys`, and
all their24 captured child IPs. They are board-owned definitions, not candidates
for replacement by upstream PMCI. Fresh26.1.1-generated outputs may differ;
that does not authorize rewriting the qualified input sources or losing PF1.

The **8** selected files under
`ofs-common/src/fpga_family/agilex/remote_stp/` (including
`AFU_debug/scjio_agilex.ip` and `AFU_debug/config_reset_release.ip`) are
byte-identical across Work21, old donor and new donor. Regenerate this entire
selected set too; identical saved source is not permission to reuse generated HDL.

## Upstream changes that must not be silently discarded

**Every one of the46 changed templates has a different saved target:**12 now
name Agilex5 `A5ED065BB32AE6SR0`,34 name `AGIB027R29A1E1VB`/speed1.
Neither is IA840F's `AGFB027R25A2E2V`/Agilex7/speed2. Many Work21 leaf templates
likewise retain older donor part metadata. Therefore neither old nor new saved
metadata alone establishes the effective generated target: explicitly bind and
verify the actual board part in generation, allowing the tool to derive traits.
Do not hand-copy the new donor's family/OPN/speed/IO-bank traits.

The following are real serialized upstream deltas, not a reason to keep all44
old-identical templates unchanged:

| Exact QSYS path | Modules / connections unchanged | Newly explicit memory-mapped connection settings |
|---|---:|---:|
| `ofs-common/src/fpga_family/agilex/mem_ss/qip/axilite_ic/emif_csr_ic.qsys` | 5 / 9 | 2 connections |
| `src/pd_qsys/fabric/apf.qsys` | 12 / 41 | 20 connections |
| `src/pd_qsys/fabric/bpf.qsys` | 16 / 50 | 21 connections |

Each of those43 connections gains **`qsys_mm.fifoDepth=8`** and
**`qsys_mm.splitCommandsFor4KBoundary=FALSE`**. Module identities/enable flags,
connection endpoints, address maps (ignoring bus-version strings), exports and
global interconnect requirements compare equal. Merge these explicit settings
by `(kind,start,end)`, or prove the fresh tool emits them from the retained input.
Their equivalence to the old *implicit defaults* is **unproven** here; do not call
them cosmetic or enable4K splitting as an unsolicited feature.

The QSYS embedded generic-component descriptions and matching leaf `.ip` bus
interfaces also gain **`optionalAssociatedReset=false`**; retain their consistency
and existing reset associations. This is interface semantics, not just branding.
Other serialization additions are empty `cpuHashInfoMap`, empty ECC parameter
mappings and empty `fileSetFileChangeDefs`; these, branding and25.1→26.1 bus
version strings are ordinary tool/schema metadata, not board topology changes.
UART's `deviceFeatures` changes are nine added capability flags, not a changed
UART interface or user configuration.

Retain/accept the native component upgrades without importing foreign targets:
`cfg_mon.ip`19.4.8→19.4.9, `PR_IP.ip`19.2.4→20.0.0, and
`qph_user_clk_iopll_RF100M.ip`20.0.0→21.1.0. The latter adds the same five IOPLL
fields listed above but does not change its requested output frequencies.
`qph_user_clk_iopll_reconfig.ip` changes `device_opn`; derive it for the board,
not the donor. Family fields in FME ROM/config-monitor/PR are also target-bound,
not automatic authorization to switch families.

## Bounded reconstruction recommendation (parent implementation only)

1. Keep the accepted donor trees immutable. In a fresh Work22 staging tree,
   retain an exact83-entry saved-input overlay ledger from this capture; retain
   board source dependencies and the already-selected four-line SDC/accepted
   Work21 constraint overlays separately. **Copy no old generated HDL/QIPs,
   synthesis caches, DB/QDB/DNI or generated IP output trees.**
2. Use the captured PLL, memory/model pair, PCIe and26 BMC definitions as the
   board-intent baseline. Carry the eight unchanged remote-STP definitions.
   For the44 old-identical changed templates, use the new donor as the source
   of reviewed version/schema changes, **not an unchecked complete-file overlay**:
   preserve topology/clock/address parameters and retarget effective generation
   to the actual board. Apply the three QSYS connection additions and matching
   reset-interface metadata coherently; retain schema/version upgrades or obtain
   explicit native proof of their equivalent automatic upgrade.
3. Bind before/after hashes and scoped deltas for every staged saved definition.
   Regenerate the full selected closure under26.1.1, including BMC and debug.
   If native load/save upgrades a working copy, retain the exact original seed
   and classify each saved-output change; keep qualified BMC sources untouched.
   Reject an unsupported parameter or unexpected topology change rather than
   silently dropping it. Re-enumerate the successor closure:83 is the verified
   predecessor list, not a guarantee of future generated-file cardinality.
4. Before accepting regeneration, read back effective part/family, component
   versions, seven PLL outputs/expected1410 MHz solution, exact PCIe100:250
   requests/PF routing, and both independently scoped DDR channel geometries
   and formats. Check fresh generated-file provenance and external ports, then
   let the separately authorized native compile/timing/hardware stages establish
   their own results. Saved XML flags or local structural equality are not proof.

## Exact46-path delta intersection

Action keys: **S** preserve PLL override; **E** preserve board memory-model
settings; **Q** merge explicit interconnect/interface schema changes;
**V** native component-version upgrade with board target;
**T** target/schema reconciliation, preserving unchanged user topology.
Counts: S1 + E1 + Q3 + V3 + T38 =46. Each path has old/new hashes in the bound
vendor01 manifest; the44 paths other than S/E have Work21 hash equal to old.

```text
E  ipss/mem/qip/ed_sim/ed_sim_mem.ip
T  ofs-common/src/common/fme_id_rom/fme_id_rom.ip
T  ofs-common/src/common/lib/fifo/sc_fifo_tx_sc_fifo.ip
T  ofs-common/src/fpga_family/agilex/avst_pipeline/avst_pipeline_st_pipeline_stage_0.ip
V  ofs-common/src/fpga_family/agilex/cfg_mon/cfg_mon.ip
Q  ofs-common/src/fpga_family/agilex/mem_ss/qip/axilite_ic/emif_csr_ic.qsys
T  ofs-common/src/fpga_family/agilex/mem_ss/qip/axilite_ic/ip/emif_csr_ic/emif_csr_ic_clock_in.ip
T  ofs-common/src/fpga_family/agilex/mem_ss/qip/axilite_ic/ip/emif_csr_ic/emif_csr_ic_reset_in.ip
T  ofs-common/src/fpga_family/agilex/mem_ss/qip/axilite_ic/ip/emif_csr_ic/emif_csr_slv.ip
T  ofs-common/src/fpga_family/agilex/mem_ss/qip/axilite_ic/ip/emif_csr_ic/emif_dfh_mst.ip
T  ofs-common/src/fpga_family/agilex/mem_ss/qip/axilite_ic/ip/emif_csr_ic/mem_ss_csr_mst.ip
V  ofs-common/src/fpga_family/agilex/pr/PR_IP.ip
S  ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip
T  ofs-common/src/fpga_family/agilex/uart/ip/uart.ip
V  ofs-common/src/fpga_family/agilex/user_clock/qph_user_clk_iopll_RF100M.ip
T  ofs-common/src/fpga_family/agilex/user_clock/qph_user_clk_iopll_reconfig.ip
Q  src/pd_qsys/fabric/apf.qsys
Q  src/pd_qsys/fabric/bpf.qsys
T  src/pd_qsys/fabric/ip/apf/apf_achk_slv.ip
T  src/pd_qsys/fabric/ip/apf/apf_bpf_mst.ip
T  src/pd_qsys/fabric/ip/apf/apf_bpf_slv.ip
T  src/pd_qsys/fabric/ip/apf/apf_clock_bridge.ip
T  src/pd_qsys/fabric/ip/apf/apf_default_slv.ip
T  src/pd_qsys/fabric/ip/apf/apf_mctp_mst.ip
T  src/pd_qsys/fabric/ip/apf/apf_pr_slv.ip
T  src/pd_qsys/fabric/ip/apf/apf_reset_bridge.ip
T  src/pd_qsys/fabric/ip/apf/apf_st2mm_mst.ip
T  src/pd_qsys/fabric/ip/apf/apf_st2mm_slv.ip
T  src/pd_qsys/fabric/ip/apf/apf_uart_mst.ip
T  src/pd_qsys/fabric/ip/apf/apf_uart_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_apf_mst.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_apf_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_clock_bridge.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_default_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_emif_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_fme_mst.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_fme_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_hssi_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_pcie_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_pmci_lpbk_mst.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_pmci_lpbk_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_pmci_mst.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_pmci_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_qsfp0_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_qsfp1_slv.ip
T  src/pd_qsys/fabric/ip/bpf/bpf_reset_bridge.ip
```

## SHA-256 bindings

`old`/`new` below mean the immutable donor pins above; `Work21` means the
hash-verified capture, not the maintained generic template.

| Input | Version | SHA-256 |
|---|---|---|
| `ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip` | old | `81e1ec8bdff503f6b518fb418a9618e85fd1bca2a8b18a1df7236d8b35ea3a46` |
| `ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip` | Work21 | `80b62a76642038c38263bffa72e19ec6d2dc575e5ca4a75f51465e7a0f90b176` |
| `ofs-common/src/fpga_family/agilex/sys_pll/sys_pll.ip` | new | `396a2df999cbf48337d22cf9ab9f2283414417fd2f05f3bc805982308f35aa98` |
| `ipss/mem/qip/ed_sim/ed_sim_mem.ip` | old | `3a8c3446955cb17cfc862cb96fdce2f7668e73506c93c5acb7ac18719db60384` |
| `ipss/mem/qip/ed_sim/ed_sim_mem.ip` | Work21 | `c12a49e5752453ad6a89fb4a05f31fa43274b7972262a7f3820562c2b86aba65` |
| `ipss/mem/qip/ed_sim/ed_sim_mem.ip` | new | `ac84583d70b01a82aa4756d1d03eba4bb42371668b4b9cec686b94bac726846b` |
| `ipss/mem/qip/ed_sim/ed_sim_mem_group1.ip` | Work21 | `8880c23dc3742d2277542b7eba82733411a697f2638ddd5cd3e250d3b0e5780e` |
| `ipss/mem/qip/mem_ss/mem_ss.ip` | Work21 | `58b2409deb345a56a34b557d735d532d9b61b93b4a58c9dce2c5ab26f02e45c4` |
| `ipss/pcie/qip/pcie_ss.ip` | Work21 | `7a3d6d059753bd88c4dfe905f59db15033c29667eb3df520e1016758a4fb1166` |
| `ipss/ia840f/bwbmc/bmc_spi_sub.qsys` | Work21 | `e3571b6d6b0e04bcc488be3c0a309571c2ccb6a0564c530f43b41dabe4cfd82a` |
| `ipss/ia840f/bwbmc/bw_840_support.qsys` | Work21 | `8c597695379a47c4426220fee88789e1fcce5ab84ab29612e9c10348ccd36098` |

Evidence files (paths relative to repository):

- `qualification/fim-build-22/ipinputs03-result.json.gz`: `b4ce08d65ef42ade7248aff72d6b7e429829b544bfe3e02c108bdcf3ba63816e`.
- `qualification/fim-build-22/ipinputs03-collection.json`: `42addaf2b4fc52f360534715fe3b8990ae927834c83ee6543bf48c9132de6e56`.
- `qualification/fim-build-22/ip-inventory02.json`: `dab7bb68db8d2feabe1f38a9044312269580676f4d1c48ae6d54b3cb51eaf369`.
- `qualification/migration-source-01/vendor01/manifest.json`: `773e2c51338275e9017639787e22add06876518120a9ef762392a4e6c2d23583`.

Deterministic saved-input set hashes: SHA-256 of sorted UTF-8 lines
`<file_sha256>  <inventory_relative_path>\n` (two spaces, LF):
- All83: `fcd17836d9549cd612ca9b50b35b4b74564b4bdfab8ebd843e10f2a5e12ed9b7`.
- BMC26 only: `b64b93bb6a8088d26d21e6a1911f7c26d432e7932e8e7d7af15a9bfe3933b25a`.

No implementation or native acceptance is claimed. Only this report was authored.
