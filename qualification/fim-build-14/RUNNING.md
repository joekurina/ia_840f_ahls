# Work14 native compile — launch verified, results pending

**Native compile RUNNING at the recorded snapshot. Hardware mission NOT COMPLETE.**

The [compile package](COMPILE-PACKAGE-ACCEPTANCE.md) passed independent SPEC/QUALITY reviews and parent acceptance. The real issuer exited 0 and its exact record was read back before handing off to the unchanged reviewed runner.

- Start: **2026-09-21 21:34:56 PDT**.
- Owned tmux: `ia840f_mailbox_monitored_01`, window `fim14_native04`, **@23 / %23**.
- Runner PID **7618**; native top PID **7625**, verified start ticks **1496797**.
- Issued record SHA256 **`42cb4974f9e6aba80aa25e5df385de1faac09251dd6695123448d0db931127be`**.
- Exact command: `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14`, cwd remote maintained SOURCE.
- Actual Quartus flow PID **7644** and synthesis PID **7677** were observed in the exact Work14 project cwd with recorded native argv/executable paths. [Parent readback verification](launch-verification05.json).
- Resource check: **126528954368 bytes** available RAM, no used swap, **1376476692480 bytes** free disk, no competing native builds. [Receipt](status-readback05/launch04/resource-preflight.json).
- Snapshot **2026-09-22T04:35:56.254195+00:00**: IP-generation log reported success, **0 errors / 0 warnings**; synthesis active. This is not synthesis, fit, STA, assembly or functional acceptance.

Persistent remote logs/status: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/run/`. Launcher/issuance receipts: sibling `launch04/`. No wall-clock compile watchdog and no duplicate launch. Single-use records are consumed; do not rerun the issuer or runner.

A local completion notifier (`proc_4d60c4549249`) waits on the unique owned-tmux completion event `ia840f_fim14_native04_done`; it has no hardware access or automatic reconnect/retry. A disconnect means unknown remote state, not native termination. Completion notification is not a pass; inspect final native status and reports.

Raw `status05.json` is **2046156 bytes**, local-only: SHA256 `dbe85817a7ae7fae9d914316da114bc1f3db644274ef07d19e3ab49bbc28cca4`. Compact [gzip](status05.json.gz), SHA256 `9bc3d51ce511c32d5c093b0c5732e50489bf9941b106cccc793ee89fbab561f4`, and extracted size/hash-verified receipts are retained. Log excerpts are explicitly partial snapshots, not final logs.

No FPGA access, flashing, reboot, udev activation or native OPAE execution occurred in this launch. W13/persona are preserved. DDR simulation remains SKIPPED BY USER; dummy-CSR exercising remains excluded. All timing and hardware acceptance gates remain open.
