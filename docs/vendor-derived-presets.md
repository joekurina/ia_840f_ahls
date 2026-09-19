# Vendor-derived IA840F memory and PCIe source integration

## Status and execution boundary

**Source transformations implemented; not execution-ready or board-qualified.**
The memory selection now resolves to actual IA840F `mem_ss` and two model source
presets instead of a nonexistent memory preset. PCIe has a vendor-derived
modern-schema parameter set, explicit PF/VF OFSS configuration, and a narrow
integration helper plus an exact shared-file hook patch. The PCIe hook deliberately
rejects execution after applying the supported subset: the checked-in modern
schema does not establish BAR2 parameter support. No BAR2 spelling was invented
or silently omitted from an ostensibly complete working configuration.

No configure, setup, build, IP generation, HDL/Tcl execution, functional tests,
vendor tools, workstation access, installation, programming, commit or push was
performed. The Python derivation performs only XML/AST/JSON source transformations
and hashes. No generated binary, QDB, or vendor generated wrapper was imported.
Original vendor and sibling sources were read only. `source_manifest.json` is
owned by the parent integration task and was not edited here.

## Authority and reproducibility

Hardware authority, relative to `new_bsp/`:

`old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f/`

Modern API/schema authority is the preserved OFS FIM/common source set identified
in `fim-ahls-review.md` (FIM `599ac052eafbc9cede22561c099233ae4a54cb7d`, common
`34a8540697fdf3d66fbcaa263fa037bae17cc32f`). A parameter's presence in a checked-in
preset is source-schema evidence, not proof that Quartus 26.1.1 accepts its value.

All paths below are relative to `new/ofs-agx7-pcie-attach/`.
`ipss/ia840f/preset_derivation.json` records SHA-256 for twelve exact inputs,
output hashes, all exact-name copies, explicit aliases, retained modern defaults,
and **every** vendor parameter not transplanted. Inactive protocol settings and
automatic device metadata remain distinguished by their exact names/values in
that inventory; they are not silently declared migrated. The script excludes
stale consumed device metadata: vendor leaves report `AGFA006R16A2E1V`, not the
board's selected `AGFB027R25A2E2V`. Device-dependent fields must be recomputed.

The standalone source-only command, from the FIM source root, is:

```sh
python3 ipss/ia840f/derive_presets.py \
  --vendor-root /home/joe/Projects/Thesis/AHLS/new_bsp/old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f
```

This default compares regenerated source XML/JSON in memory against the four
retained artifacts. `--write` rewrites only those four artifacts. It never calls
OFS configuration/generation or imports its executable Python modules: the PCIe
schema dictionaries are extracted with `ast.literal_eval`. If the parent applies
the shared PCIe hook, rerun the source derivation with `--write` because the
recorded `pcie_ip.py` input hash changes; do not describe that ported file's new
hash as the original upstream hash.

## Memory implementation

Files:

- `ipss/ia840f/derive_presets.py`
- `ipss/ia840f/preset_derivation.json`
- `ipss/ia840f/presets/ia840f_mem.qprs`
- `ipss/ia840f/presets/ia840f_sim.qprs`
- `syn/board/ia840f/config/ia840f_memory.ofss`

The modern `iseries-dk-8g-rdimm` preset supplies the actual `mem_ss` nested
parameter schema, **not** its board values. Its discrete `emif_0` and RDIMM
`emif_2` schemas are populated from vendor `intf_0` and `intf_1`, with RDIMM
renumbered to `emif_1`. The third channel and top calibration block are not copied.
The resulting memory preset has 2,930 explicit parameters, including 1,424
exact-name source parameters per EMIF. The two model presets have 1,519 parameters
each and the required base-name/`_group1` naming. The existing OFS recursive
`$OFS_ROOTDIR/ipss/**/*` search discovers these board-local QPRS files; no shared
preset file is changed.

| Setting | Discrete channel 0 | RDIMM channel 1 |
|---|---|---|
| Modern namespace | `mem_ss|emif_0|` | `mem_ss|emif_1|` |
| DQ width; DQ/DQS | 64; 8 | 64; 8 |
| Row / column / bank / bank-group widths | 17 / 10 / 2 / 2 | 17 / 10 / 2 / 2 |
| Ranks per DIMM; ECC | 1; false | 1; false |
| Memory / reference MHz (source values) | 1333.333 / 33.333 | 1333.333 / 33.333 |
| TCL; tRCD; tRP; tRFC | 23; 15 ns; 15 ns; 550 ns | same |
| SPD 137 / 138 RCD drive settings | 101 / 5 | 101 / 5 |
| DQS intra-group board deskew flag | true | true |
| Placement region | BOT | BOT |

`BOT,BOT` is established by the vendor Qsys connections: both channel calibration
buses and clocks attach to `emif_cal_location_bottom_row`. This is more specific
than the unrelated development kit's `TOP,TOP,BOT`. The two storage-channel
identity connection vectors use the real modern two-channel
`iseries-dk-no_dimm` schema. This does **not** prove generated physical interface
group numbering or the final package-pin map.

All matching vendor timing, ODT tables, RCD/SPD, board skew, electrical and PHY
parameters are copied, not just the headline geometry. MSA row/column/bank/group
widths have explicit `DDR4_*` → modern unprefixed aliases; response widths use
vendor `AMM_DATA_WIDTH`, and copies use `NUM_WRITE_COPIES`. Exact matching MSA
scheduler/ECC parameters are retained. Modern-only/default fields and unmatched
legacy controls are enumerated in JSON rather than assigned speculative aliases.
Notably legacy `AUTO_PRECHARGE=true` is **not** blindly cast into the modern enum;
`SS_CONTROLLED` remains the reference policy pending semantic qualification.
Legacy AXI ID width, scheduler policy, CSR-enable and latency controls still need
interface review. The modern reference's top-level CSR interface defaults remain
explicit and are not evidence that the legacy CSR topology was reproduced.

### Important simulation inconsistency found

The vendor `ed_sim_mem.ip` has `MEM_DDR4_TCL=19`; both actual vendor EMIF leaves
have `MEM_DDR4_TCL=23`. It is therefore unsafe to reuse that old simulation model
or copy a development kit's derived mode-register image. Model source presets
use the actual EMIF parameters and a small explicit generic DDR4 alias map
(format, clocks, rate, mimic-HPS, data width, mask). **Derived model latency,
mode-register words, RDIMM configuration and other flattened values are not
invented.** Their exact untransplanted reference fields are recorded. Recompute
and compare them during later authorized IP qualification before claiming the
model presets complete for simulation. `memory_groups=2` is only the model request.

Remaining EMIF DDR4 names lacking modern-reference counterparts include
`PHY_DDR4_CONFIG_ENUM`, `CTRL_DDR4_ADDR_ORDER_ENUM`,
`CTRL_DDR4_ECC_READDATAERROR_EN`, `CTRL_DDR4_MMR_EN`, and several `DIAG_DDR4_*`
controls. JSON retains their exact original values and the complete inventory.
Thus this is a concrete, reviewed source migration, **not a claim that all old
controller/debug semantics or generated interfaces have been qualified**.

## PCIe implementation and guarded integration

Files:

- `ipss/ia840f/presets/ia840f_pcie_known_schema.qprs` — 102 source parameters,
  kind `intel_pcie_ss_axi`; intentionally named known-schema subset.
- `syn/board/ia840f/config/ia840f_pcie_vendor_source.ofss` — ordinary modern
  PF/VF processing, Gen4 1x16, PF0 with one VF and PF1 with zero VFs.
- `ofs-common/tools/ofss_config/ia840f_vendor_pcie.py` — narrow board-specific
  override helper, hash check, topology check, explicit unconditional source gate.
- `ofs-common/tools/ofss_config/ia840f_vendor_pcie_hook.patch` — exact parent
  handoff touching the shared generator and switching the board OFSS selection
  **together**. This worker did not edit the shared existing generator.

The active selection remains the prior nonexistent PCIe preset until the parent
applies both patch hunks. Do not switch only the OFSS line: unmodified upstream
PF processing would enable PF1 BAR0 and silently omit BAR2. After the hook is
applied, ordinary PF/VF configuration runs, the helper overlays all known-schema
vendor parameters, then raises before deployment because BAR2 is unresolved.
This preserves a real source integration path without advertising readiness.

| Function | Preserved source contract |
|---|---|
| PF0 | BAR0 prefetchable 64-bit width 20; BAR4 width 14; `8086:bcce`, subsystem `8086:1771` |
| PF0VF0 | One VF, BAR0 width 20; BAR4 width 14; VF device `bccf` |
| PF1 BMC | Enabled PF, zero VFs; BAR0 **disabled**, inactive width 12; BAR4 width 14; `12ba:0070`, subsystem `12ba:b5d4` |
| PF1 BAR2 | Required prefetchable 64-bit width **28**; exact vendor names/values retained as unresolved, not asserted supported |

Vendor MSI-X table/PBA fields, identity/class/revision fields and supported
capabilities are overlaid by exact modern-schema names. Modern duplicate vendor
ID/revision/VF BAR-type fields have explicit base-field mappings. The modern
Gen4x16 `core16_dwidth_byte_user_hwtcl=64` and `core16_num_seg_user_hwtcl=2`
workaround is retained explicitly. The ordinary OFSS path avoids the upstream
preset branch's PF/VF-processing bypass.

The decisive unresolved keys are
`core16_pf1_bar2_type_user_hwtcl=64-bit prefetchable memory` and
`core16_pf1_bar2_address_width_user_hwtcl=28`. They exist in the vendor `pcie_ss`
and modern tree's **legacy-kind** preset, but are absent from the selected
`intel_pcie_ss_axi` Python schema. Other BAR fields and all remaining vendor
capabilities are retained in JSON for full migration review. There is no claim
that renaming a legacy preset establishes modern support.

No BMC RTL, routing table, AXI aperture, reset, IRQ or AHLS interface was changed
by this work. The local BMC AXI aperture must not be enlarged to 28 simply because
PCIe BAR2 advertises that width. PF0VF0/PF1 routing and generated PCIe packet/clock
interfaces still require qualification together with the separately integrated
BMC implementation and AHLS/PIM binding.

## Static verification performed

- Re-derived all four source artifacts and compared their exact bytes.
- Verified twelve input hashes and three preset output hashes.
- Parsed every new QPRS and checked unique parameter names.
- Compared critical geometry, timing, RCD, electrical, MSA and PF/VF/identity
  fields directly to vendor source; confirmed unknown BAR2 is absent from the
  purported modern-schema subset, while its exact required value is inventoried.
- Parsed both new Python sources with AST; no configuration module execution.
- `git apply --check` accepted the paired integration patch without changing files.

These are source checks, not tests or IP acceptance evidence. Existing board
execution gates and false readiness are retained. Full memory model derivation,
PCIe BAR/capability schema qualification, generated port/pin resolution,
clock/reset/PR timing, BMC contract and AHLS/OFS/Quartus 26.1.1 qualification remain
closed dependencies.
