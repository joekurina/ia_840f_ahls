# AHLS/OFS source-preparation handoff

**Source preparation remains incomplete; no build readiness claimed.** The selected route is AHLS-generated RTL integrated through OFS/PIM, with OPAE/DFL host access. Intel oneAPI compiler/runtime compatibility is not a blocker or acceptance criterion. Quartus 26.1.1 remains intended; [scope and toolchain evidence](ahls-scope.md) distinguish the handbook's 26.1 family requirement from unverified whole-board compatibility.

## Actual changes

- Reoriented README, preparation plan and `sources.lock.json` to AHLS; donor pins and all execution restrictions retained. Prior oneAPI standard/USM work remains reference-only, not deleted.
- Added [AHLS integration documentation](ahls-integration.md) and [machine-readable interface contract](../afu/ahls/integration-contract.json). These cover invocation, register side effects, address units, local/host memory domains, streams, clock/reset and OPAE resource lifetime. They are not a generated wrapper or executable configuration.
- Added `memory_groups = 2` to `ofs-agx7-pcie-attach/syn/board/ia840f/config/ia840f_memory.ofss`, following the real OFS mixed-memory reference. Updated its manifest hash and retained the prior hash. This requests separate simulation model configurations; it does not supply the missing presets or prove physical group mapping. [FIM review](fim-ahls-review.md) records exact sources and limitations.
- Updated the FIM manifest toolchain requirement to AHLS/OFS/Quartus 26.1.1 and board-IP qualification. Gates remain closed.

## Static evidence

The parent independently ran the existing read-only source inventory after the FIM edit: exit 0, `source_consistency=pass`, all 86 manifest entries checked, no errors. Its retained ASP/XML checks apply to the preserved reference tree, not to an active AHLS BSP. The parent also parsed the AHLS contract and verified that all 31 cited source paths exist and their line ranges are valid. This checks citation integrity, not the truth of every engineering claim or HDL behavior.

The FIM worker additionally inspected 76 origin hashes and recovered the prior memory OFSS hash by removing exactly the appended block. Detailed evidence is in its review. No compiler, Tcl/HDL elaboration, simulation or executable test was used.

## Remaining source dependencies

1. **Memory:** the real `iseries-dk-8g-rdimm` preset has two discrete channels and one RDIMM with row width 16. IA840F has one of each with row width 17. It supplies a useful schema, not an interchangeable preset. Full vendor timing/electrical/controller settings and generated group/port mapping remain necessary.
2. **PCIe:** the modern `intel_pcie_ss_axi` OFSS schema lacks the required BAR0-disable and BAR2 controls. Checked-in older `pcie_ss` presets are not valid substitutes. Preserve PF1 BMC identity `12ba:0070`, subsystem `12ba:b5d4`, disabled BAR0, BAR2 width 28 and BAR4 width 14. A correct modern schema/preset is still required.
3. **BMC:** old custom IP migration, shared SPI/SDM reset ownership, in-flight PF1 FLR handling and optional interrupt integration remain unresolved. No speculative reset rewiring was introduced.
4. **AHLS binding:** no generated AHLS instantiation/register-map pair was found in the inspected sample tree. Exact ports, CSR map, source closure, endpoint adapters and a host ABI remain unbound. PIM word/line addresses cannot be wired blindly to AHLS byte addresses. No guessed wrapper or fake host library was added.
5. **System integration:** clock/reset, PR floorplan/timing and a fresh shell-matching PR template remain necessary. Old vendor QDBs are not reused.

The board project does not select a workload or fixed stream protocol. Actual component binding must use a real generated AHLS artifact set when one is available under appropriate authorization. External AHLS streams alone do not implement PCIe DMA or CPU pipes.

## Execution restrictions retained

No builds, configure/setup flows, IP generation, tests, workstation access, installation, programming, commits or pushes. No original vendor or sibling donor files were modified. The next engineering work is completing the authoritative board-IP source contracts and binding real component metadata—not restoring a oneAPI compiler dependency or opening gates prematurely.
