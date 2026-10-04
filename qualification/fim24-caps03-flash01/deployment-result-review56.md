# FINAL — PASS WITH LIMITS

**Accept the actual deployment/activation gate only. Deployment-gate technical blockers: 0.** The completed card-only removals/VF cascade, separately verified BMC Off→On, exactly one recorded normal workstation reboot, restored card PCI/AER/ownership state and migrated cached FME identity are supported by the original receipts and bound control sources. **`hardware_ready=false`; no AFU, DDR, numerical, electrical or timing qualification is accepted.** This is independent local read/hash/AST/JSON/source analysis, not new execution authority. Only this report was written; no remote/hardware/vendor execution, project imports, tests, Git operations or executable edits occurred.

Paths below are relative to this capsule unless prefixed `../`.

## Integrity and actual-result coverage

Read `deployment-freeze55.json` first: **3341 bytes**, SHA256 **`ea9b36a4eba72e4627342054f53460c923ff89092a303978d3fbc2f09a28b45a`**. Independently verified **21/21 enumerated members**, exact bytes AND SHA256, with **0 mismatches**; declared count21 agrees. All members were inspected, including preparation-only records, prior reviews, failed receipts and both reboot records.

For every indexed capture, verified compressed-envelope SHA against index/transport, complete export-key equality, every decoded export against its local file's size/SHA, and envelope/index payload agreement. **37/37 exports across 9 captures** match; these are exported file references, not 37 distinct payloads. Command-log hashes and raw result/index projections also agree. All nine exact dispatched scripts hash-match their transport/index bindings and parse as ASTs; supplemental `reboot53.py` matches its dispatch SHA. No project code was imported or executed.

| Capture | Exports verified | Actual disposition |
|---|---:|---|
| `activation-pre43` | 9/9 | Prerequisites/daemon ownership release; outer0 |
| `quiesce44` | 2/2 | Failed readonly preflight; outer1 |
| `quiesce46` | 2/2 | Failed readonly preflight; outer1 |
| `pid1-diagnostic47` | 1/1 | Bounded ordinary PID1 diagnostic; outer0 |
| `quiesce48` | 6/6 | Real AER/PF1 effects, then local parser failure; outer1 |
| `partial-quiescence49` | 1/1 | Ordinary inventory/ownership confirmation; outer0 |
| `quiesce51` | 4/4 | Remaining PF0 removal and VF cascade verified; outer0 |
| `bmc-cycle52` | 7/7 | Off/On setters and independent readbacks verified; outer0 |
| `postboot54` | 5/5 | New boot/static identity/AER/ownership plus reboot receipts; outer0 |

`PROGRAM-ACCEPTANCE42.json` remains the accepted original program18 native0/outer0, three phases100.0 and source-defined full-input comparison gate. Its hash matches pre43's consumed acceptance; review41's programming limits remain intact. Programming was neither repeated nor requalified by a second SDK verify. Preparation review22/consumption26 and the **16/16 recorded inert guard cases** are provenance, not hardware results or permission.

## Quiescence and preserved failures

- **Fresh prerequisite binding:** pre43 establishes IA-840F serial **`8110055`**, USB VID:PID **`2528:0005`**, location **`1-3.4`**, current **`USB:0`**; root **`0000:4e:00.0`** has exactly PF0 **`0000:4f:00.0`** (`8086:bcce`, dfl-pci/group4), PF1 **`0000:4f:00.1`** (`12ba:0070`, vfio-pci/group5), VF0 **`0000:4f:00.2`** (`8086:bccf`, vfio-pci/group76), with numvfs1 and exact forward/reverse VF links. Source checks and loaded module-note/file-hash bindings agree with the actual pre43 receipt and are rechecked by removal sources.
- **Daemon exit was not clean:** stop command native0, but daemon **PID395200/start60597442** exited **1**; service retained failed/failed, MainPID0 and empty ControlGroup. The original PID was gone and post-stop holders/maps/D/errors were empty. This establishes ownership release, not daemon exit0. Postboot service is inactive/dead/MainPID0; that does not erase the earlier exit1.
- **Readonly failures stay false:** quiesce44 and46 each recorded PID1 in D and stopped after the ordinary ownership scan, before any AER/removal/power operation. Diagnostic47's five snapshots have S/S, `ep_poll` and epoll stacks; they show no persistent D in that bounded window, not its definitive cause. Quiesce48 acquired three clear snapshots before evidence-directory/status writes. Source comparison retains source/module/topology/ownership rejection conditions; it changes acquisition ordering, not permission or D-state acceptance. Startup-I/O bias remains an interpretation, not a proved global diagnosis.
- **Real partial effects stay real:** quiesce48 performed only root Surprise Down clear/mask **`0x20`**, original status/uncorrectable-mask/correctable-mask **`00000000 / 00100000 / 00002000`**, then verified masks **`00100020 / 00002000`**. PF1 removal returned native0. The subsequent whole-host inventory parser incorrectly required four-hex domains and rejected actual VMD **`10000`** tokens. Its **`success=false`, outer1, traceback and raw result** remain unchanged; this was not a hardware-command failure and not a wholly unperformed attempt.
- **Independent delta computation:** raw inventories contain **132→131→129** entries. Readback49 proves only PF1 removed, PF0/VF/root retained, no additions/unrelated removals and clear retained ownership. Corrected guard50 accepts literal 4–8-hex *host inventory* domains without normalization; card targets/removal sets remain four-hex strict. Its recorded negative controls reject additions, unrelated removals and malformed literals. Source inspection confirms those conditions; no tests were rerun.
- **Only the remaining PF0 action ran:** quiesce51 native0 removal of PF0 produced incremental removed set exactly **`{0000:4f:00.0, 0000:4f:00.2}`**; cumulative removal is exactly PF0/PF1/VF0, no additions, all unrelated host entries including the three `10000` entries unchanged, root present and subtree empty. No separate VF operation, PF1 replay or AER-write replay occurred. Captured `dfl-pci.c:451–463,486–502` explicitly invokes `pci_disable_sriov` from PF removal, corroborated by the fresh pre43 loaded-object binding and actual cascade readback. The public PCI helper selects/writes the exact endpoint, not `unplug` or root removal. This is supported driver teardown, not hardware-free teardown or universal DMA-drain/reset proof.

Post-removal/BMC/reboot scans retain the original three BDFs and VFIO groups4/5/76, including deleted descriptor/resource-map handling; empty PCI discovery does not discard ownership scope. Recorded holders/maps/D/errors are empty and process matches are the actual batch transport, not competing card owners. These remain finite root-visible observations.

## Power, reboot and migrated identity

**BMC52:** exactly one `power -p Off`, separate OFF readback, 12-second dwell, one `power -p On`, separate ON readback and 30-second settle. All four native exits and outer exit are0. Raw logs/confirmation JSON retain **`WARNING:root:Card is not powered on`** in OFF readback and the On setter. The hash-matched captured SDK `_get_bmc:54–83` warns when initially off, before `handle_power:229–261` performs the requested action; successful final ON readback is separate evidence. This is BMC-reported state, **not measured rail waveforms/all-rail discharge**. Host boot remained unchanged throughout BMC52.

**Reboot53:** source has one direct `sudo -n /usr/bin/systemctl reboot`, exclusive receipt creation and fsync of requested/command-result files; dispatched source SHA **`0d02ce2fdfdd150b46438b4a1da1a334a4574bc4b947d9685289563487992c21`** matches locally. Requested **2026-10-04T00:21:48.823850+00:00**, returned native0 **00:21:48.879890+00:00**. The initial `requested.json` intentionally still has **`success=false`**; the separate matching `command-result.json` has success true/reboot_rc0. Both are preserved, hash-bound to BMC52 and independently read back after reboot. No second reboot/reset/rescan/reflash/JTAG action is evidenced in this episode.

**Postboot54:** boot changed from **`8121620d-a638-42f8-abab-a547aae32076`** to **`3e2d2060-d6c0-44b5-a269-1adf1e450041`**, kernel **`5.14.0-687.48.1.el9_8.x86_64`**. PF0 dfl-pci/group4 and PF1 vfio-pci/group5 returned; VF0 absent, numvfs0 and no virtfn links are expected before separate per-boot VF setup. Root AER reads are **`00000000 / 00100000 / 00002000`**, restoring original masks with **no restoration write**. Ownership is clear and the SDK service inactive.

The source-bound **single PF0 child FME region1** cached `compat_id` returned raw **`fc603c445c8f5e94bcbea5780030947c\n`**, valid before UUID formatting, hence **`fc603c44-5c8f-5e94-bcbe-a5780030947c`**, the migrated static interface. The exact PF-child path/module selection and `fpga_region`, `dfl_fme_mgr`, `dfl_fme_region` loaded notes/on-disk hashes match captured accessor evidence. Independently checked all four embedded cached-accessor C sources and retained `compat_id_show` disassembly: manager probe fills the cached words, the region inherits them and this sysfs show formats kernel RAM. **No new FPGA MMIO or AFU discovery was used by the identity check**; root PCI configuration reads are separately classified. This clears the migrated static-identity deployment discriminator, not cryptographic/bytewise running-configuration attestation or AFU qualification.

## Limits and final disposition

**FINAL — PASS WITH LIMITS: deployment gate accepted; 21/21 frozen members and 37/37 exported references verified; deployment blockers0.** All original failed/partial/preflight receipts remain failed where recorded. Existing routine authority comes from the goal, not this source review. No recovery/service repair, global drain/no-hang guarantee, independent recovery claim, new electrical proof or whole-flash/padding readback is added.

Application VF setup/binding, current clock/reset readiness, AFU identity/capabilities, DDR address-walk/bulk and numerical campaigns remain separate unperformed gates. Legacy electrical/STA/CDC/reset limits, extra3 sys7-bank concerns, and the numerical34/DDR-walk/bulk qualification boundaries are not cleared by deployment. No accelerator/task closure or benchmark acceptance is implied.
