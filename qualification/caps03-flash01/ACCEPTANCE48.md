# CAPS03 SDK deployment acceptance

Accepted after independent review `deleg_a72d3baf` and parent reconciliation of the cited receipt hashes, embedded command outputs and reboot records. This closes only the completed SDK programming/activation/deployment-reboot gate. No hardware operation was repeated while recording this acceptance ([review and checks](review48-consumed.json), [deployment report](SDK23.md)).

## Accepted evidence

- Program23's native exit is zero. The exact raw log matches the receipt and its SHA256; erase, program and readback each reach100.0%, followed by `Flash programmed successfully.` Under the already-reviewed writer contract, all10,653,696 input bytes were read back and compared. The10,682,368-byte erase footprint includes28,672 bytes of sector padding; neither quantity describes a whole-device backup ([native receipt](sdk-program23-result.json), [raw log](sdk-program23.log), [footprint reconciliation](review48-consumed.json)).
- The source SOF and SDK-compatible RPD retain their accepted size/SHA256 bindings. The package is the complete non-RSU BOOT_INFO/P1 layout at address0, not an RSU user-slot update. The actual SDK RPD-generating CMake recipe is retained in `sdk-convert21-result.json` under `cmake_source`; `flash-image-CMakeLists.txt` is the earlier JIC/MAP-only recipe ([conversion receipt](sdk-convert21-result.json), [map](caps03.map), [route authority](AUTHORITY.md)).
- The SDK daemon stop command returned0, while the daemon's own `ExecMainStatus=1`, failed state and empty cgroup are preserved. MainPID0 and empty subsequent ownership support stopped, not clean daemon exit. Quiescence removed exactly PF0/PF1 and preserved the upstream root ([activation preflight](activation-pre43-result.json), [quiescence](quiesce44-result.json)).
- Separate Off setter/readback and On setter/readback each returned0 and observed OFF then ON, with the recorded12-second dwell and30-second settle. `Card is not powered on` is retained as the expected Off-state warning. These are BMC state observations, not electrical waveform measurements ([BMC receipt](bmc-cycle45-result.json)).
- The durable request's initially false success field is not rewritten. Reboot command return0 and the changed boot establish the normal workstation reboot. PF0/dfl-pci and PF1/vfio-pci returned, original AER masks were restored, and postboot ownership was empty ([postboot and embedded receipts](postboot47-result.json)).

## Limits and historical context

The cached `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e` UUID identifies the Work21 static FME only. It does not uniquely identify CAPS03 or qualify arithmetic, DDR capacity, application reset entry, sustained traffic or lifecycle. The retained CAPS01 recovery JIC is prior-image recovery material, not a fresh pre-write device backup. Original native/effective/outer0 and the separate observer0 are recorded distinctly in the deployment report ([SDK23](SDK23.md), [parent checks](review48-consumed.json)).

`RECOVERY18.md` is preserved pre-SDK JTAG failure history. Its current-result/remaining-decision wording and SDK23's final next-work paragraph describe their original checkpoints; neither is current execution authority. The selected SDK route superseded JTAG restoration, and this acceptance must not cause another flash or reboot ([historical JTAG report](RECOVERY18.md), [selected route](AUTHORITY.md)).

Programming images and replay/source-capture payloads are excluded from Git and remain bound by exact sizes/SHA256 in the [publication manifest](../caps03-publication01/sdk02-manifest.json). Numerical and application-lifecycle results belong to separate milestones; no such acceptance is inferred here.
