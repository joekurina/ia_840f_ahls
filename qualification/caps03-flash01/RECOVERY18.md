# CAPS03 programmer recovery — JTAG remains unavailable

## Current result

The overall goal is incomplete. No CAPS03 flash erase/program, BMC card power cycle, or kernel/DMA launch has occurred. One USB-Blaster-only reset and one normal workstation recovery reboot were executed. The workstation returned successfully, but the first post-reboot JTAG chain check still reports `Unable to read device chain - Hardware not attached` with no FPGA/TAP ID. The prepared JIC remains unchanged.

## Executed evidence

- [Native help07](jtag-help07-result.json), [help08](jtag-help08-result.json), [help09](jtag-help09-result.json): the installed25.1 server documents foreground/debug, nonpersistent configuration and serial-filtered cable discovery. Its help commands return16. The collectors' rc0/capitalized-heading assumptions rejected help output; the actual returned documentation remains available, and these are not hardware failures.
- [Debug10](jtag-debug10-result.json): only the exact `BITTW-0811-0055` USB-Blaster was exposed. USB firmware1.42 and endpoint04/88 descriptors were read. A cable parameter request returned6M, but this does not establish successful live parameter communication.
- [Clock11](jtag-clock11-result.json): reading `JtagClockAutoAdjust` failed native4, `No parameter named JtagClockAutoAdjust`. No TCK/auto-adjust setting was written and no second chain query in that stage executed. The intended16MHz experiment was not reached.
- [USB trace12](jtag-usb12-result.json): open, interface claim, set-interface, control transfers, endpoint reset/clear-halt and URB submission succeeded. The trace records four5000ms polls timing out, with no completed request reaped in the captured request sequence. The native parameter command nevertheless returned6M/native0. This locates a USB queued-transfer failure; it does not prove the physical cause or validate the returned clock value. Full85,797-byte trace SHA256 `31e76985378057737d9c73bc7eb67b891e3e84d2ff88d3b119b49ec2c7dcb10a`.
- [USB reset14](usb-reset14-result.json): one header-backed `USBDEVFS_RESET` to the exact character node `/dev/bus/usb/001/005`, major189/minor4, returned0. Its ioctl shape follows upstream [usbutils reset_device](https://raw.githubusercontent.com/gregkh/usbutils/master/usbreset.c) and the captured installed Linux UAPI header. The tiny diagnostic used that header, not a guessed request number. BMC USB descriptors and PCI PF/VF presence were unchanged. This was not a USB-hub, BMC or FPGA power reset. [Target15](target15-result.json) after that change still returned the original chain failure.
- [Recovery postboot17](recovery-postboot17-result.json) embeds the fsynced reboot request/command receipts: one `sudo -n /usr/bin/systemctl reboot` requested2026-09-26T04:07:45.275785Z and returned0. Old boot `7fa4f793-1569-4bcb-a2bb-2c95de63da9b`; verified new boot `4945ac3f-5bfd-43d3-a4bf-748af43e70b6`, same kernel5.14.0-687.48.1.el9_8.x86_64. The embedded command snapshot retains its initially false generic success field because it was persisted before that field's final assignment; native reboot_rc0 plus the different observed boot establish actual reboot completion. The postboot receipt's success/reboot_verified fields are true.
- [Target18](target18-result.json): first chain query on that new boot ended2026-09-26T04:11:12.866478Z, native0 but the same error and no FPGA/TAP ID; outer1. Result SHA256 `102ee38cf0af98801c618557718672da10ae674c5e0beb7e9b0ce9d210c4e1fc`. No program, clock-write, AER or BMC command followed it.

All instrumented foreground JTAG servers were terminated only after their clients exited; their expected SIGTERM status is retained. The ordinary jtagconfig-autostarted server uses the installed documented two-minute idle-stop behavior. No query is left in an unknown running state.

## Preserved deployment state

New-boot PF0 `0000:4f:00.0` is dfl-pci; management PF1 `0000:4f:00.1` is vfio-pci; sriov_numvfs0. The absence of a VF is expected after reboot, not failed FPGA activation. BittWare VFIO daemon is inactive, and postboot/target18 root scans found no FPGA/VFIO holders, mappings or D-state tasks. No VF has been recreated.

Prepared JIC remains `/home/uwb_student00/ahls/new_BSP/work_caps03_flash01/convert03/caps03.jic`, SHA256 `af1a2e0e54a49b9ea7881be353caf525eb65afb812f6fd2912e39224b6bc70ad`; postboot17 rehashed it. Conversion, source SOF and complete package layout are recorded in [RESULT.md](RESULT.md).

## Remaining decision

Do not repeat the ineffective USB reset, normal reboot or unchanged chain probe. Continuing requires either restoring the programmer's USB data path through a supported power/reconnection procedure, or selecting the BittWare SDK writer with source-bound current management access and equivalent CAPS03/full-image layout. The retained [SDK program02 result](../caps01-bwflash01/PROGRAM02-RESULT.md) establishes earlier program/readback success, not current CAPS03 packaging or boot acceptance. Do not silently reuse a historical flash address or substitute the unrelated RSU user-update layout.

This is a transport-route decision, not a renewed request for flash/BMC/reboot permission or independent recovery availability. Existing approval remains valid. Source/runtime reset-entry, numerical, DDR and lifecycle acceptance remain open. No commit/push was performed.
