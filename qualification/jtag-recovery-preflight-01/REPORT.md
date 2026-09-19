# IA-840F read-only JTAG/recovery preflight

## Outcome: BLOCKED — USB visible, no usable JTAG chain

On Agilex7Workstation as uwb_student00 (UID 1000), Quartus/jtagconfig **26.1.1 Build 130** was selected with QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus and explicit PATH. Host instructions were read first. All remote operations used dedicated windows of ia840f_mailbox_monitored_01. No build was touched.

- `jtagconfig --help` and `quartus_pgm --help` inspected before enumeration.
- `jtagconfig`: exit **4**, `No JTAG hardware available`.
- `quartus_pgm --list`: exit **0**, also `No JTAG hardware available`; zero exit is NOT proof of hardware detection.
- `lsusb`: **09fb:6810 Altera**, bus 001 device 017; **2528:0005 BittWare IA-840F**, bus 001 device 018. Thus the USB connection is visible but recovery is not established.
- Altera USB node `/dev/bus/usb/001/017`: root:root, mode 0664; current user read=True, write=False. BittWare node 018: root:984, mode 0660; user read/write=True. Installed BittWare rules cover 2528 devices, not the 09fb cable. This is a concrete permissions blocker, not proof it is the only blocker.
- A normal user `jtagd --user-start --config /home/uwb_student00/.jtagd.conf` process was observed after enumeration. No explicit daemon/service start, configuration, restart or kill was performed. Baseline process capture failed due to quoting, so whether this invocation auto-started it cannot be established conclusively.
- No cable index, chain position, FPGA JTAG IDCODE, actual device part, JTAG frequency, firmware mode, or recovery test was established. **Do not assume cable 1 / device @1 from vendor examples is the live chain.** USB PID 6810 alone is not sufficient evidence here to classify cable firmware readiness.
- Read-only PCI snapshot: **0000:4f:00.0 8086:bcce / subsystem 8086:1771, dfl-pci**; **0000:4f:00.1 12ba:0070 / subsystem 12ba:b5d4, vfio-pci**. No unbind, reset, rescan, SDK hardware calls, UUID assumptions, or changes to the current FIM/PF1 were made.

## Vendor-supported procedures (DOCUMENTATION ONLY; NOT EXECUTED)

Source root: `/home/uwb_student00/Documents/IA-840f installation/`.

1. `IOFS_BUILD_ROOT/oneapi-asp/ia840f/README.md`, lines **296–331**, captured in details.log:
   - SOF loading is explicitly **non-permanent across cold power-on** (304).
   - Before live-PCIe reprogramming, vendor strongly recommends disabling AER to avoid fatal-PCIe watchdog reboot (305–309). This requires separate authorization; it was not done.
   - Linux JTAG permission rules are prerequisites (310–312).
   - Vendor's historical 23.1 example disables clock auto-adjust and sets **16M**, then uses Quartus JTAG to program SOF (315–318), followed by host restart (319). These are future disruptive operations, not authorized by this preflight; 26.1.1 compatibility of the complete board workflow has not been qualified.
   - Flash update is a separate optional operation on the **user page**, assuming a factory-programmed layout (324–329): historical SDK command `bw_agilex_flash_programmer program -a 0x04000000 ia840f-ofs-23.1-2-flash-image.rpd`, then shutdown/power cycle (331). This command was only read, never invoked. Do not assume this old CLI applies unchanged to SDK 2026.1.
2. `IA-840F_Hardware_Reference_Guide.pdf`, extracted text stored locally/remotely as `IA-840F_Hardware_Reference_Guide.txt`:
   - Lines **866–882** / printed pp. 29–30: onboard MAX10 USB-Blaster II permits direct FPGA reconfiguration; QSPI programming supports Quartus **.jic** over JTAG or **.rpd** through SDM Mailbox IP. Detailed flash procedure is deferred to the FPGA Developer Guide.
   - Lines **1457–1462**: 2Gb flash, at least two images, same JIC/RPD distinction.
   - Lines **1987–2003** / pp. 68–69: USB-Blaster II drivers/permissions required; Linux default root-only access must be changed for user programming.
   - Lines **2035–2036** / p. 70: vendor recommends 16M JTAG clock.
   - The inspected materials do not establish an exact IA-840F **.pof** procedure. Do not substitute generic POF/PMCI/fpgasupdate instructions.

## Recovery assets: present, but NOT proven known-good rollback

Source file SHA256 values are recorded in `source-hashes.json`; binaries were hashed in place, not copied.

- `/home/uwb_student00/Documents/IA-840f installation/IOFS_BUILD_ROOT/oneapi-asp/ia840f/hardware/ofs_ia840f/build/output_files/ofs_top.sof`
  - 9,551,870 bytes; SHA256 `05f9834af21117c7774f3f086f801e8292da89fa348a7b9140a979f2359ed888`.
  - Matching copies under ofs_ia840f_usm and both IA-840f source roots.
- `/home/uwb_student00/Documents/IA-840f installation/IOFS_BUILD_ROOT/flash_image/ia840f-ofs-23.1-2-flash-image.rpd`
  - 8,478,720 bytes; SHA256 `dc66a28962fc9d1c9dd18070d0c6c0ce9f6ed75f15038bbca42bd483c4295a6a`.
  - Matching copies under both IA-840f source roots.
- These are historical vendor-tree OFS assets, **not verified backups of today's flash/current FIM**. Exact SOF target provenance for requested **AGFB027R25A2E2V**, hardware revision/security compatibility, successful prior use, factory image integrity, current boot-page layout, and factory fallback selection remain unverified.
- The hardware guide documents factory/application images, but a tested factory restoration procedure was not established. The detailed FPGA Developer Guide was not among the two inventoried PDFs. Preserve factory flash: no erase/write/readback or page-selection changes were attempted.

## Required before any future programming

1. Separately authorize and review minimal USB-Blaster permissions/driver remediation; re-enumerate normally as UID 1000 and capture actual cable/IDCODE chain. Do not use sudo programming as a workaround.
2. Confirm cable firmware state and exact FPGA/device/security/board compatibility, including AGFB027R25A2E2V. Do not guess the port UUID.
3. Obtain vendor recovery procedure and proven matching rollback image; verify factory/user layout and preservation boundaries. USB connectivity alone is insufficient.
4. Separately authorize AER/driver handling, JTAG clock changes, programming, and any reboot/power-cycle, with current FIM/PF1 preservation and restoration criteria.

## Evidence and limitations

Local directory: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/jtag-recovery-preflight-01`.
Remote directory: `/home/uwb_student00/ahls/new_BSP/qualification/jtag-recovery-preflight-01` (fresh absent-check via mkdir exist_ok=False).
Commands/log exit codes: commands.json, identity.log, programmer-help.log, jtagconfig-help.log, jtagconfig-version.log, jtagconfig-enumeration.log, programmer-list.log, usb.log, target-pci.log, details.log, jtagd.log. Source PDF text and hit extracts included. All tool subprocesses were bounded to 25 seconds (PDF extraction 20 seconds).

Initial inventory hit a broken source-tree symlink; corrected inventory skips missing paths and old work-ofs build directories, so inventory is intentionally bounded, not a universal disk search. No SDK hardware calls were made; SDK board resources were included in the inventory scope, but firmware-mode requirements were not validated against its implementation. DDR simulation SKIPPED by user instruction.

Transferred 16 evidence files through tmux output with compressed payload SHA256 verified end-to-end: `afc65ac44a2df8309a16d609a78c68188a71ff6232e34be54a8353ec7a18d8ee`; per-file hashes in transfer-verification.json. Large exploratory inventory.json/source-hits.json/pci.log remain remote only. First oversized transfer capture was truncated and rejected, not accepted as evidence. Initial identity process filter had a quoting SyntaxError (exit 1); version/host output remained valid and the process check was repeated separately.

No programming, erase, reset, JTAG parameter write, service change, install, sudo, process kill, reboot, repository edits, commits, or pushes were performed. Only qualification evidence was created.
