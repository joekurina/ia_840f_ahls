# IA840F PF1 BAR2 source trace

## Conclusion

The board-scoped source overlay now copies the vendor's exact
`core16_pf1_bar2_type_user_hwtcl = 64-bit prefetchable memory` and
`core16_pf1_bar2_address_width_user_hwtcl = 28` values. Installed Quartus Pro
26.1.1 `intel_pcie_ss_axi` source resolves these subsystem names, allowed values
and the P-Tile forwarding path. This is source evidence, not executed validation
or downstream child-IP acceptance. All execution gates remain closed.

## Vendor identity and preserved contract

Paths below are relative to `new/ofs-agx7-pcie-attach/` unless stated otherwise.
The read-only vendor root is `../old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f`
relative to `new/`. Its `ipss/pcie/qip/pcie_ss.ip` explicitly sets `TILE=P-TILE`;
IA840F is not the F-Tile CII reference. The same IP supplies the BAR2 values.
PF1 BAR0 remains disabled, BAR4 remains 64-bit prefetchable memory/width 14,
PF0VF0/PF1-no-VF counts and all existing BittWare identities are unchanged.
Only the two BAR2 user fields are added to the PCIe XML overlay.

## Hash-bound installed source evidence

`new/reference/quartus-26.1.1-pcie/manifest.json` records 16 copied installed
files, their source host/root, sizes and SHA-256 digests. All 16 copied hashes
were checked locally. `ipss/ia840f/derive_presets.py` pins four defining file
hashes, checks them against the copied manifest and bytes, and records the
manifest plus those files in `preset_derivation.json` input hashes:

- `hwtcl/qhip_hwtcl/intel_pcie_common_core16_parameters.tcl:689–702` declares
  both exact user names and the required values; line 5018 encodes 64-bit
  prefetchable memory as type 1.
- `hwtcl/qhip_hwtcl/intel_pcie_common_core16_validation_callback.tcl:957–1015`
  handles P-Tile. For an enabled endpoint PF it copies user BAR type/width to
  base fields, permits width 28 for 64-bit memory, and disables the paired
  BAR3 when BAR2 is 64-bit. Disabled/root-port cases have different behavior.
- `hwtcl/pcie_ss_parameters.tcl:13582–13626` forwards the core16 BAR parameter
  list through `set_qhip_param_list` on the P-Tile path.
- `hwtcl/pcie_ss_fileset.tcl:64–68,146–154` selects
  `intel_pcie_ptile_ast` version `11.*.*`, instantiates it and transfers the
  cleaned `qhip_param` dictionary using `set_instance_parameter_value`.

No Tcl was executed. These excerpts establish the subsystem source path,
not successful execution of its callbacks or the full dependency closure.
Missing local dependencies include the `intel_pcie_ptile_ast 11.*.*` child
component definition, external Lampas/WHR helpers and
`rtl/ptile_pciess_top.sv.terp`. Child acceptance, generated interfaces and
full capability/device/topology behavior remain unqualified.

## Source overlay and fail-closed integration

`ofs-common/tools/ofss_config/ofs_ip.py:106–125` emits the component-parameter
dictionary; `pcie_ip.py` has the IA840F-only hook after PF/VF processing.
The generic Python parameter dictionaries are a configuration-key subset,
not the complete IP schema. They were not extended or edited. The derivation
adds only the two installed-evidence-backed names to the board-local preset;
remaining unmapped vendor fields stay inventory-only.

`ofs-common/tools/ofss_config/ia840f_vendor_pcie.py` retains its component,
PF/VF, preset-kind and overlay-hash checks and an unconditional rejection.
Its reason now names downstream child-IP, capability/generated-interface and
AHLS/OFS/Quartus 26.1.1 qualification, rather than missing BAR2 names.

PF1/non-VF routing remains in `src/board/ia840f/fim_afu_instances.sv`.
The board-local 17-bit CSR path and upstream function/BAR filtering were not
changed; neither independently proves the advertised BAR aperture. MSI-X
BAR4 layout was preserved. No CII capability interception was introduced.

## Authorization and qualification boundary

The latest user authorization permits read-only remote inspection of the
installed definitions and supersedes the earlier blanket workstation-read
prohibition. The copied evidence records that authorized acquisition; this
patch uses the local copies only. It grants no build/setup/configure,
vendor-tool/IP-generation, HDL/Tcl execution, simulation/test, installation,
programming, commit or push permission. Existing execution-policy flags and
all gates remain unchanged. The historical workstation flag in
`sources.lock.json` is not an updated record of this narrow read authorization.

Only inspected deterministic XML/JSON source derivation, source inventory,
hash checks, XML and Python AST parsing were performed. Memory/simulation
preset bytes remain unchanged. No toolchain, generated IP, RTL behavior or
hardware qualification is claimed. Original donors remain read-only.

FIM pin: `599ac052eafbc9cede22561c099233ae4a54cb7d`; OFS common pin:
`34a8540697fdf3d66fbcaa263fa037bae17cc32f`. Earlier trace:
`deleg_90564c1f`; installed-source review: `deleg_cab1e033`.
