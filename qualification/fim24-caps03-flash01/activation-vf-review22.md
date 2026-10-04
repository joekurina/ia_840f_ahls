# FINAL — established IA840F activation with one idle VF

**Verdict: supported, conditional on fresh post-program prerequisites.** The reviewed DFL PF removal path already disables SR-IOV. The existing idle VF is not, by itself, a technical blocker and does not justify a separate VF-disable/remove/rebind/reset operation. Keep the established management-PF1 removal → application-PF0 removal → USB BMC Off/readback → On/readback → one normal workstation reboot sequence. Its exact population predicates must account for PF0's one VF; the historical scripts cannot be executed unchanged.

This is an offline local source/API review, not execution authority or evidence of completed activation. No remote access, hardware/tool execution, project imports, tests, code changes, or SDK source-body publication occurred. Only this report was written.

## Source-derived effects

All paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new` unless explicitly identified as installed paths.

- **Exact endpoint selection:** `qualification/caps01-bwflash01/vfio-setup-source03/usr/lib/python3.9/site-packages/opae/admin/tools/pci_device.py` lines 47–54 select an exact BDF; 78–92 dispatch `remove` to that endpoint; 356–358 default peer selection to false. `.../opae/admin/sysfs.py` lines 506–511 write `1` only to the selected endpoint's `remove` attribute; lines 173–179 perform the attribute write. No Python VF-recursion, root removal, AER write or rescan is part of this action. Do not substitute `unplug`: the same CLI's lines 223–264 mask both root AER masks broadly and can remove the root.
- **PF0 supplies the VF teardown:** `qualification/source-resume-01/remote/home/uwb_student00/linux-dfl-backport/drivers/fpga/dfl-pci.c` lines 486–491 call `cci_pci_sriov_configure(pcidev, 0)` for a PF before removing feature devices. Lines 451–463 call the Linux PCI API `pci_disable_sriov`, then restore released ports to PF access mode. Lines 497–503 register these remove/SR-IOV callbacks. Thus the supported expected effect of removing this DFL-bound PF0 is removal of its enabled VF as part of PF teardown—not an additional operator VF command. The VF is a PCI sibling under the root, so this expectation comes from the explicit SR-IOV call, not from pretending it is a directory child of PF0.
- **Teardown is not hardware-free:** the same captured tree's `drivers/fpga/dfl.c` lines 1989–2001 restore released ports; lines 1960–1975 include FME register read/write within that supported driver path. Lines 1814–1825 remove the DFL feature devices/container. This does not authorize speculative BAR/MMIO probes or establish a universal DMA-drain, no-hang, reset, or electrical guarantee.
- **Kernel/loaded-object evidence boundary:** `qualification/caps01-work21-vf01/preflight02-result.json` records these exact source hashes and the loaded `dfl_pci` build ID `9b7b67cf8ff8950589b4cb6b500e1b4cc8b18fea`, module SHA256 `e4e786c8ad757fc9489610db23843048d58bdbca76c2e6aefe59d04502adb6da`. Its retained `cci_pci_sriov_configure` disassembly has the zero-count calls to `pci_disable_sriov` and `dfl_fpga_cdev_config_ports_pf`. This corroborates the driver's API use; it is not a fresh loaded-module binding. Exact RHEL PCI-core/VFIO implementation sources were not found in the inspected local capture, so no independent claim about every internal kernel teardown/reset step is made. The card-only cascade remains an expected API effect that must be verified by ordinary PCI inventory readback.

## Exact reviewed population and required removal readbacks

`qualification/fim24-caps03-flash01/sdk-target16/readback/result.json` lines 628–692 records kernel `5.14.0-687.48.1.el9_8.x86_64`, no application maps, only the SDK daemon's global VFIO/group5 descriptors, and this population:

| Role | BDF | IDs | Binding / singleton group |
|---|---|---|---|
| Application PF0 | `0000:4f:00.0` | `8086:bcce` | `dfl-pci` / 4 |
| Management PF1 | `0000:4f:00.1` | `12ba:0070` | `vfio-pci` / 5 |
| Existing application VF0 | `0000:4f:00.2` | `8086:bccf` | `vfio-pci` / 76 |

Fresh pre-removal evidence must establish root `0000:4e:00.0` has **exactly this three-BDF descendant set**, PF0 `sriov_numvfs=1`, exactly `virtfn0 → 0000:4f:00.2`, and the VF's reverse `physfn → 0000:4f:00.0`, with those drivers/groups and no other card children. `vfio-pci` binding alone is not an application owner; actual holders/maps still must be absent after daemon stop.

For full host PCI inventory sets `before` and `after`, require:

1. After the established PF1 removal: the only removed BDF is `0000:4f:00.1`; PF0, VF0 and root remain; no additions or unrelated removals.
2. After PF0 removal: the incremental removed set is exactly `{0000:4f:00.0, 0000:4f:00.2}`. Cumulative `before − after` is exactly `{0000:4f:00.0, 0000:4f:00.1, 0000:4f:00.2}`, `after − before` is empty, and the root remains with no PCI descendants. Verify ownership again before power Off. A leftover VF, added device, changed population, nonzero return or uncertain operation is a stop condition—not permission to disable/remove the VF separately or retry/rescan.
3. Keep the reviewed root-only Surprise Down status clear/mask `0x20`; preserve fresh original AER values and require only that mask-bit delta, unchanged correctable mask, and post-reboot restoration. No broad AER change, root removal or guessed historical mask restoration is justified.

The old `activation-pre43.py` lines 44/47 require two descendants and zero VFs. `quiesce44.py` lines 40/53 likewise require a two-function set/delta; lines 46–55 contain the established narrow AER and PF1→PF0 actions. Those predicates would reject today's valid starting population or successful VF cascade. Review only the exact one-VF population/cascade replacement in the parent's fresh activation artifact; do not alter the accepted historical files. `bmc-cycle45.py` lines 43–47 must additionally require the VF absent/root subtree empty before Off. Postboot `sriov_numvfs=0` and no VF before separate per-boot setup remain the established expectation (`postboot47.py` line 53); activation does not require recreating a VF.

## Remaining prerequisites / genuine blockers

- **Original writer completion is still required.** The retained `program-progress21/index.json` lines 12–36 identifies PID395622/start60884383 and programming progress, not completed readback/comparison/native exit. Do not overlap activation with it. Parent must consume the original program18 native exit0, all named completed phases, comparison success and unchanged boot; never reflash to reconstruct context.
- **Management ownership must be released after that completion.** Target16 records daemon PID395200/start60597442, owning group5. Stop/read back the exact service only after verified writer completion; require MainPID0, original daemon gone, no residual service owner, no application/device holders/maps or unresolved scan errors. Preserve a nonzero daemon exit separately from verified stopped state. Carry the pre-removal card/group scope through the post-removal ownership check; discovery after removing every endpoint must not silently drop the original group4/5/76 targets.
- **Fresh binding is mandatory, not another blanket permission question.** Rebind current boot, exact root/topology, installed `pci_device`/sysfs/AER and BMC/card-list sources, and current loaded DFL module identity against the evidence above before acting. Old hashes/boot/PIDs are provenance, not current facts. USB BMC must again resolve serial `8110055`, VID:PID `2528:0005`, location `1-3.4`, matching IA-840F and current USB index—not the PCI writer index (`activation-pre43.py` lines 48–59).
- **No new BMC handling is needed.** Locally inspected captured proprietary API metadata: installed `bw_bmc_utils/bmc_configuration.py`, `handle_power` lines 229–261; `bw_bmc/card.py`, setter lines 90–106/getter lines 68–88. Keep separate Off and On setters/readbacks and durable confirmations (`bmc-cycle45.py` lines 48–57), then the one normal OS reboot (`reboot46.py` lines 35–47). These establish BMC-reported states and a changed host boot, not electrical rail waveforms. Preserve fresh postboot identity/AER/ownership checks; do not reuse the predecessor's hardcoded old FME UUID as migrated-image acceptance.

**No additional VF-specific operation or intrinsic VF blocker was established.** Actual source/module/topology drift, remaining ownership, failed/incomplete original programming, unexpected cascade readback, failed BMC readback or unknown execution would block activation. The old two-function guard mismatch is a concrete implementation prerequisite to correct in the parent's fresh artifact, not a reason to mutate the currently running VF. Existing scoped routine authority is unchanged; no JTAG, recovery/retries, speculative MMIO, resets/rebinds, broad AER changes or extra reboot are added.

## Reviewed evidence SHA256

| Relative path | SHA256 |
|---|---|
| `qualification/source-resume-01/remote/home/uwb_student00/linux-dfl-backport/drivers/fpga/dfl-pci.c` | `ea9ef821cc655be5804f81480e5eac7d8a2e5a6681b4634f958b6c7dbbc68b50` |
| same captured tree, `drivers/fpga/dfl.c` | `2eb1bad280e7be5f6714955868a651559f59affef02999b05c2715aa2fb15839` |
| `qualification/caps01-work21-vf01/preflight02-result.json` | `dc70edb506fa89e3e395961de28ca6acd9728b42a7c469466d8c9f81e0eb08d8` |
| `qualification/caps03-flash01/preflight01-result.json` | `ba09188b04052ba1803e4b7b108d21b0c9017c0e8d750e4475f0ece559e5b271` |
| `qualification/caps03-flash01/activation-pre43.py` | `9b0d879eb9f1e43e63e51451a0925ee4f9bd54532ff573f86211ce195f4e9a5c` |
| `qualification/caps03-flash01/quiesce44.py` | `de757ce15acbd6a5a3854ff2b52112cb9a4cc8dd17e6e90d48f4c18ebcc8f208` |
| `qualification/caps03-flash01/bmc-cycle45.py` | `d60c237caf43f8dff4eee963588f4eb5940e25cffedf0a43cf4c1e578c42f7ff` |
| `qualification/caps03-flash01/reboot46.py` | `c3e1d37f7c1547394c4b6a3b47c1e988c6bbde0ae0830192447721d12365cb69` |
| `qualification/caps03-flash01/postboot47.py` | `bcffd6321a4a28722b05baf6383075b7a5c001a93a7ebdb4db9fe5a03c6c41b5` |
| `qualification/fim24-caps03-flash01/sdk-target16/readback/result.json` | `bcbc8297c9da1ee659a487b99362507858b938521d9da744637d7d883233face` |
| `docs/ia840f-sdk-flashing.md` (§6, lines 134–206) | `81c30ba522b4d2bfab4696961da964dc9ebc94685fedb95c41ca357972dea10e` |

The extracted public OPAE source files above exactly hash-match the source strings and file hashes in `preflight01-result.json`: CLI module `8ab8230856e51b76c733d309d11d2cbec9fe9fac78e8e86b1ed7f90cc38975df`, sysfs module `d70da0e869d7ce45ac13a15916d345841a131c0572cf1af247c2fcae32ba1151`. The installed entrypoint/AER/BMC/card-list complete path→hash bindings are preserved in `activation-pre43.py` line 31. SDK bodies stay in their local capture and are not reproduced here. Historical `quiesce44-result.json` SHA256 `b0e67fa472ac5a2687cc810e72d81bf0fbde18deaa56e38f21e3ac7bfe73c97c` verifies the old two-PF-only delta/no additions/root preservation; it does not constitute an observed one-VF cascade.
