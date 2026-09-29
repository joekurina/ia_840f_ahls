# IA-840F CAPS03: BittWare SDK flashing and activation

This guide records the accepted CAPS03 deployment route for the BittWare IA-840F. It accompanies [the build guide](ia840f-build.md). It is an operator runbook, not a script to run end-to-end or permission to resume a stopped hardware task. Publication of this release does not program or reboot anything. The accepted deployment is documented in [SDK23](../qualification/caps03-flash01/SDK23.md) and [ACCEPTANCE48](../qualification/caps03-flash01/ACCEPTANCE48.md).

## 1. Route and prerequisites

**Always use `bw_agilex_flash_programmer` for IA-840F flash programming. It is the only flash route for this project.** Do not repair, retry, or continue diagnosing JTAG. `Hardware not attached` is a reason to leave the JTAG route, not to reset USB or reboot while trying to repair it. A `.jic` is conversion evidence, **not SDK-writer input**. The writer takes the correctly oriented `.rpd` generated from the accepted full-device `.sof` ([standing rule](../GOAL-PROMPT.md), [route authority](../qualification/caps03-flash01/AUTHORITY.md)).

Before a hardware operation, establish all of the following:

- The selected full-device SOF contains the intended CAPS03 persona and preserved Work21 static image. A static-only SOF, PR `.rbf`, or `.gbs` is not a substitute. Reuse an existing matching SOF/RPD rather than rebuilding or reconverting to recover context ([assembly acceptance](../qualification/caps03-persona01/ASSEMBLY-ACCEPTANCE01.md)).
- The installed BittWare CLI, RPD reader, `handle_program`, SDM mailbox implementation, VFIO service and BMC tools match the reviewed installation. The recorded installation uses user-local Python 3.9 packages; do not assume another package version has the same interface or byte-order contract ([SDK preflight](../qualification/caps03-flash01/sdk-preflight20-result.json), [deployment report](../qualification/caps03-flash01/SDK23.md)).
- The current boot, management PF, card index, driver and IOMMU group are identified from current evidence. Card indices and BDFs below are historical examples, not identifiers to copy onto another boot or machine. Root-visible file-descriptor **and memory-map** ownership checks must show no competing application, VFIO, programmer or FPGA owner. A process-name search alone is insufficient ([target receipt](../qualification/caps03-flash01/sdk-target22-result.json)).
- The intended complete non-RSU flash layout and exact erase footprint are accepted. This runbook does not select an RSU layout or preserve an RSU factory/user scheme. Retain recovery material; a previously booted image is not a fresh device backup. The accepted run had no fresh pre-write flash snapshot, and that limitation remains explicit ([deployment acceptance](../qualification/caps03-flash01/ACCEPTANCE48.md)).
- Run every workstation operation inside an owned `tmux` session with durable logs. Do not use bare remote-shell commands as an alternative. Verify paths, target, ownership and authorization before executing each hardware stage ([operating rules](../GOAL-PROMPT.md#workstation-safety--operating-rules-not-new-infrastructure)).

Do not perform JTAG, BMC, card status, flash reads, PCI removal or reboot concurrently with an active writer. If the writer's native state is uncertain, stop and recover its existing receipt; do not launch a second writer or a standalone full verification.

## 2. Image identity and layout

These are the **existing accepted artifacts**, not guaranteed hashes of a future rebuild. Bitstreams and licensed tool/runtime payloads are intentionally absent from Git and this documentation release. Obtain the retained artifact separately or perform a separately reviewed build; a clean source checkout does not contain it ([artifact record](../qualification/caps03-final01/ACCEPTANCE.md#retained-working-artifact), [publication policy](../README.md#evidence-and-repository-policy)).

| Artifact | Bytes | SHA256 |
|---|---:|---|
| CAPS03 full-device `ofs_pr_afu.sof` | 10065141 | `8f778fca292cc77f87c196deb198d4798a1bd111999d69b0245d570fa2bfe276` |
| SDK input `caps03-sdk.rpd` | 10653696 | `0319b7fd35d968d73f02f9a6f49706cb249c3559dec1759a3f2d3a37122e4bcf` |
| Writer-transformed RPD bytes | 10653696 | `766eb2697ac16ba4296f47e259b4be306b7d5bd787a1a22af5b8d9c66514fd9d` |

The locally retained SOF is at:

```text
qualification/caps03-persona01/asm01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sof
```

The accepted workstation SDK input was:

```text
/home/uwb_student00/ahls/new_BSP/work_caps03_flash01/sdk-convert21/caps03-sdk.rpd
```

Use `sha256sum` and `stat` to verify the actual local files. Do not treat a path's existence as provenance. For the accepted RPD, the flash address is **`0x00000000`**; it is **not** the RSU application-slot address `0x04000000`. Its map is BOOT_INFO `0x00000000..0x001FFFFF` and P1 `0x00200000..0x00A28FFF`. The selected flash device is **MT25QU02G**, mode **ASX4**, loader **AGFB027R25A**. The source-reviewed erase arithmetic covers 163 sectors / 10682368 bytes through `0x00A2FFFF`, including 28672 padding bytes beyond the RPD payload ([conversion receipt](../qualification/caps03-flash01/sdk-convert21-result.json), [map](../qualification/caps03-flash01/caps03.map), [erase/readback acceptance](../qualification/caps03-flash01/ACCEPTANCE48.md)).

## 3. Generate an SDK RPD only when it is missing

Conversion is a file-only operation. It does not rebuild the FPGA or program the card. The native-verified Quartus 25.1 command contract is:

```text
quartus_pfg -c <accepted-full-device.sof> <fresh-output.jic> <fresh-output.map> <fresh-output.rpd> -o device=MT25QU02G -o mode=ASX4 -o flash_loader=AGFB027R25A -o bitswap=OFF
```

**Keep `bitswap=OFF`.** The reviewed SDK RPD reader reverses each byte before writing; OFF is the input convention that produced the accepted programmed bytes. Do not pre-reverse the RPD, choose ON from intuition, or give the writer a JIC ([conversion and transformed hash](../qualification/caps03-flash01/sdk-convert21-result.json), [accepted programming](../qualification/caps03-flash01/SDK23.md#preserved-image-and-layout)).

Use a native CMake target, not a shell/Python build wrapper. The following is the recorded command expressed with relocatable input/output paths. Put it in a fresh conversion source directory as `CMakeLists.txt`:

```cmake
cmake_minimum_required(VERSION 3.20)
project(ia840f_caps03_sdk_image NONE)
set(SOF "" CACHE FILEPATH "Reviewed full-device CAPS03 SOF")
set(QUARTUS_PFG "/opt/altera/25.1/quartus/bin/quartus_pfg"
    CACHE FILEPATH "Quartus Pro 25.1 Programming File Generator")
if(NOT EXISTS "${SOF}" OR NOT EXISTS "${QUARTUS_PFG}")
    message(FATAL_ERROR "Provide the verified SOF and Quartus 25.1 executable")
endif()
add_custom_target(flash_image
    COMMAND "${QUARTUS_PFG}" -c "${SOF}"
        "${CMAKE_CURRENT_BINARY_DIR}/caps03-sdk.jic"
        "${CMAKE_CURRENT_BINARY_DIR}/caps03-sdk.map"
        "${CMAKE_CURRENT_BINARY_DIR}/caps03-sdk.rpd"
        -o device=MT25QU02G -o mode=ASX4
        -o flash_loader=AGFB027R25A -o bitswap=OFF
    VERBATIM)
```

Set `SOF`, `CONVERT_SOURCE`, and a new `CONVERT_BUILD` to absolute, owned paths before running:

```bash
cmake -S "$CONVERT_SOURCE" -B "$CONVERT_BUILD" -DSOF="$SOF"
cmake --build "$CONVERT_BUILD" --target flash_image --verbose
sha256sum "$SOF" "$CONVERT_BUILD/caps03-sdk.rpd"
```

The exact historical CMake source and successful native command/log are retained under `cmake_source` and `commands` in [sdk-convert21-result.json](../qualification/caps03-flash01/sdk-convert21-result.json). The older [flash-image-CMakeLists.txt](../qualification/caps03-flash01/flash-image-CMakeLists.txt) produces JIC/MAP only and is **not** the SDK RPD recipe. The relocatable snippet above was documented, not executed as a new conversion when this release was published.

Require the native conversion exit, expected complete outputs, part/options, SOF identity and correct map. Compare JIC/MAP against the accepted conversion when preserving this exact layout; record the input RPD hash and separately computed writer-transformed hash. Conversion success alone does not establish that an arbitrary image is safe to flash or will boot.

## 4. Establish current BittWare management access

The accepted PCI route used management PF `0000:4f:00.1`, IDs `12ba:0070`, singleton IOMMU group 5 and SDK card index 0. **Resolve these anew; do not create an application VF just to flash.** Bind the reviewed management PF/VFIO setup before starting the service. If access or identity differs, resolve that technical dependency rather than probing guessed BARs or repairing JTAG ([preflight](../qualification/caps03-flash01/sdk-preflight20-result.json), [target binding](../qualification/caps03-flash01/sdk-target22-result.json)).

On the recorded installation, after checking source identity and empty ownership:

```bash
SDK_BIN="$HOME/.local/bin"
sudo -n /usr/bin/systemctl start bittware-vfiod
/usr/bin/systemctl show bittware-vfiod \
    --property=ActiveState,SubState,MainPID,ExecMainStatus,ControlGroup
"$SDK_BIN/bw_card_list" -i PCI
```

Start the service for this operation; do not enable it at boot as a side effect. Read back its state, PID/start identity and expected VFIO holders. Set `CARD_INDEX` from the actual listing that matches the intended management BDF. If the reviewed readiness check is required, run it **before** the writer:

```bash
"$SDK_BIN/bw_agilex_flash_programmer" -i PCI -c "$CARD_INDEX" -s
```

This CONFIG_STATUS command is hardware mailbox access, not an ordinary-file read. The accepted response had `conf_done=1`, `init_done=1`, zero error/state fields and ASx4 Normal. It did not prove CAPS03 AFU identity. Recheck unchanged boot, exact RPD hash and ownership immediately before programming, allowing only the specifically bound management daemon ([target receipt](../qualification/caps03-flash01/sdk-target22-result.json)).

## 5. Program once, then require all named phases

Set `RPD` to the verified SDK input and `RUN_DIR` to a fresh evidence directory. Run the original writer once inside the owned `tmux` window, with explicit PCI transport, current card index and complete-image address:

```bash
native_rc=0
"$SDK_BIN/bw_agilex_flash_programmer" -i PCI -c "$CARD_INDEX" \
    program --force -a 0x00000000 "$RPD" \
    > "$RUN_DIR/sdk-program.log" 2>&1 || native_rc=$?
printf '%s\n' "$native_rc" > "$RUN_DIR/sdk-program.native-exit"
test "$native_rc" -eq 0
```

`--force` permits the reviewed, slow VFIO interface; **it does not disable readback/comparison**. Without it, a native-zero refusal is possible. The installed `program` operation erases, programs, reads the entire input length back and compares it. PCI/VFIO programming can take hours; observe the original log and process, not concurrent hardware queries ([actual command and writer behavior](../qualification/caps03-flash01/SDK23.md#original-sdk-operation)).

Do not activate until the **same original operation** establishes all of:

1. Native exit code **0**, saved separately from a watcher or transport exit.
2. `QSPI Erase: ... 100.0% Complete`.
3. `QSPI Program: ... 100.0% Complete`.
4. `QSPI Readback: ... 100.0% Complete`.
5. `Flash programmed successfully.` after the built-in byte comparison.
6. Unchanged boot throughout programming, correct bound input and no unexpected ownership/failure.

Keep the raw carriage-return log unchanged and hash it. A program-phase 100% line is not readback completion; readback 100% still needs comparison success and the native exit. Preserve failure or unknown state and stop without automatic retry, standalone full verify, power cycle or reboot ([verified phase/exit evidence](../qualification/caps03-flash01/ACCEPTANCE48.md#accepted-evidence), [raw native log](../qualification/caps03-flash01/sdk-program23.log)).

## 6. Activate: approved BMC Off/On, then one workstation reboot

A successful flash write leaves the running fabric intact. Activation is a separate disruptive stage. The accepted sequence below is **board/host-specific**, not a generic live power-cut recipe. Finish and collect the original programmer result first; do not repeat programming if that gate is already complete ([activation record](../qualification/caps03-flash01/SDK23.md#activation-and-reboot)).

### 6.1 Bind USB BMC and quiesce the exact card

Resolve the USB BMC identity separately from the PCI writer index. The recorded board was IA-840F serial `8110055`, USB device `USB:0`. For the recorded user-local Python installation:

```bash
SDK_PYTHONPATH="$HOME/.local/lib/python3.9/site-packages"
sudo -n /usr/bin/env "PYTHONPATH=$SDK_PYTHONPATH" \
    "PATH=$SDK_BIN:/usr/bin:/bin" "$SDK_BIN/bw_card_list" -i USB -j
```

Set `BMC_DEVICE` only from the matching current listing. Verify initial power ON, stop `bittware-vfiod`, read its state back, and establish that the original daemon and all application/device holders/maps are gone. The historical stop command returned 0 while the daemon's own exit was 1 and systemd retained `failed`; that was recorded as **stopped**, not a clean daemon exit ([pre-activation receipt](../qualification/caps03-flash01/activation-pre43-result.json)).

```bash
sudo -n /usr/bin/systemctl stop bittware-vfiod
/usr/bin/systemctl show bittware-vfiod \
    --property=ActiveState,SubState,MainPID,ExecMainStatus,ControlGroup
```

Before power Off, establish the reviewed card-only PCIe preparation. The accepted run preserved root `0000:4e:00.0`, temporarily changed only its Surprise Down AER bit `0x20`, then removed only management PF1 and application PF0. **This preparation belongs to activation, not to the preceding SDK flash write.** Resolve `ROOT_BDF`, `MGMT_BDF`, and `PF0_BDF` from the current topology and bind the installed `pci_device` helper's effects before using this recorded sequence:

```bash
sudo -n /usr/sbin/setpci -s "$ROOT_BDF" \
    ECAP_AER+0x04.L ECAP_AER+0x08.L ECAP_AER+0x14.L
# Save the original values before the following two narrowly scoped writes.
sudo -n /usr/sbin/setpci -s "$ROOT_BDF" ECAP_AER+0x04.L=20:20
sudo -n /usr/sbin/setpci -s "$ROOT_BDF" ECAP_AER+0x08.L=20:20
sudo -n /usr/sbin/setpci -s "$ROOT_BDF" ECAP_AER+0x08.L ECAP_AER+0x14.L
sudo -n /usr/bin/pci_device "$MGMT_BDF" remove
sudo -n /usr/bin/pci_device "$PF0_BDF" remove
```

Read back that only the intended card endpoints disappeared, the upstream root and every other device remain, and ownership is empty. Do not remove a shared root port, use broad AER masks, substitute `unplug`, or perform a PCI rescan. A successful remove command by itself is insufficient ([exact commands and before/after inventories](../qualification/caps03-flash01/quiesce44-result.json)).

### 6.2 Perform separate Off and On setters/readbacks

Only after the preceding conditions pass, use the current bound USB target. This Bash array preserves the recorded SDK environment:

```bash
BMC=(sudo -n /usr/bin/env "PYTHONPATH=$SDK_PYTHONPATH"
     "PATH=$SDK_BIN:/usr/bin:/bin" "$SDK_BIN/bw_bmc_configure"
     -i USB -d "$BMC_DEVICE")
"${BMC[@]}" power -p Off
"${BMC[@]}" power
# Require native 0 and explicit OFF before continuing.
sleep 12
"${BMC[@]}" power -p On
"${BMC[@]}" power
# Require native 0 and explicit ON before continuing.
sleep 30
```

Save each setter/readback and its exit separately. The recorded `Card is not powered on` warning during the Off-state query/On setup is not a substitute for the final explicit ON readback. These observations establish BMC-reported power states, not electrical rail waveforms ([BMC receipt](../qualification/caps03-flash01/bmc-cycle45-result.json)).

### 6.3 Reboot the workstation once and verify

Save the pre-reboot boot ID and all completed-stage receipts durably. Then issue the normal host reboot inside owned `tmux`:

```bash
sudo -n /usr/bin/systemctl reboot
```

After the host returns, enter a new owned `tmux` session and verify:

- `/proc/sys/kernel/random/boot_id` changed.
- The intended PF0/DFL and management PF1/VFIO identities and bindings returned; no competing owner remains.
- Original AER masks are restored. The accepted run restored them across reboot without another write; if the new readback differs, stop rather than blindly writing historical values.
- The source-bound, probe-time cached FME compatibility UUID is `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e` for Work21. Resolve the appropriate region from the intended PF rather than guessing a sysfs region number. This is **static FME identity**, not unique CAPS03 AFU or arithmetic proof.

The accepted deployment recorded these checks in [postboot47-result.json](../qualification/caps03-flash01/postboot47-result.json). An absent application VF before per-boot VF setup is expected; it is not by itself failed activation. VF creation/binding and AFU access are separate operations with their own source/ownership/reset prerequisites. Do not add another reboot, reflash, JTAG attempt or unreviewed recovery loop if the expected image is not established.

## 7. What successful flashing does—and does not—prove

Flash acceptance is complete-input readback/comparison. Deployment acceptance adds observed BMC Off/On, a new host boot and the scoped static identity check. Functional acceptance requires the independent OPAE/DFL, HLS copyback, guard, DDR and lifecycle evidence linked from [CAPS03 final acceptance](../qualification/caps03-final01/ACCEPTANCE.md).

The release retains native **Design Closure FAIL** for the disclosed physical scope and only the exact accepted VF pending-before-FLR warning. It does not qualify every upstream HLS sample, general PR/cold/stopped-clock recovery, or warning-free teardown. Publishing these instructions does not extend those claims or resume the stopped sample qualification.
