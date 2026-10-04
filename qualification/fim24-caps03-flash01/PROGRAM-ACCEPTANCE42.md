# Migrated CAPS03 original SDK programming — accepted

Independent actual-result review accepted the single `sdk-program18` invocation **PASS WITH LIMITS**; parent42 consumed the exact frozen15-member/8-export evidence. Native and collector outer exits were **0/0**. This closes **programming/readback/comparison only**, not activation or hardware arithmetic. [FINAL review41](program-result-review41.md), [parent acceptance42](PROGRAM-ACCEPTANCE42.json), [original result](sdk-program18/readback/result.json).

The actual command used the freshly bound IA-840F PCI/VFIO card0/managementPF0000:4f:00.1:

```text
bw_agilex_flash_programmer -i PCI -c 0 program --force -a 0x00000000 <reviewed migrated-caps03-sdk.rpd>
```

Original nativePID395622/start60884383 is historical; it ran2026-10-03 20:35:35.983791UTC→23:31:12.497355UTC. `--force` permits the slow VFIO interface, not a verification bypass. Exactly one erase/program/readback sequence completed monotonically to100.0%, followed by exactly one `Flash programmed successfully.` and original native0. The raw448,203-byte CR log is preserved unchanged, SHA256 `a4e70063fdc90d4a2d08e53a7f32673fb40effa063d261cf3a05b6f19c436490`. Warning-free operation is not claimed. [Raw program log](sdk-program18/readback/program.log), [durable native receipt](sdk-program18/readback/native-result.json), [reconciliation39](program-reconciliation39.json).

## Compared bytes and limits

- Original SDK input:10,670,080bytes, SHA256 `96fb0dc9e0716a712f9e77a09b11161ac495a6e16436beb756bf7fd04874647e`; complete non-RSU BOOT_INFO/P1at0, not RSU user-slot update.
- The reviewed reader's per-byte bit-reversal representation has deterministic SHA256 `f7cc592f86182c792a5a8fdfc1347dfefd3299c538760a1d98e51fb50976772e`. That calculation is not an independently exported flash dump.
- Built-in full-input readback/length/byte comparison covers0..0x00A2CFFF.163-sector erase extends through0x00A2FFFF, with12,288padding bytes outside the input comparison. No comparison of padding/restof256MiBflash or fresh prewrite device snapshot is claimed.

The target, current SDK source/input, unchanged boot and root-visible pre/post ownership checks passed. Only the specifically bound management daemon heldVFIO/global+group5; no app holders/maps/D-state/errors were observed. These are scoped software snapshots, not global DMA-drain/no-hang/electrical guarantees. Existing idleVF1 was not changed by programming. [Full source/ownership/range review](program-result-review41.md#bound-target-ownership-and-unchanged-boot).

The accepted prior/main RPD was retained and hash-verified as recovery material, not a fresh device backup. QSPI writing leaves runningfabric intact under the reviewed route. New-image BMC activation/one normal reboot/static-FME identity and all numerical/DDR gates are separate milestones; inherited STA/CDC/reset/electrical findings remain. No JTAG, standalone full verify, reflash or replay is justified by this acceptance. Raw archives/proprietary SDK code/images and encoded transfer launchers remain local-only with SHA references; `main` remains fallback.
