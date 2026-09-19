# Work11 RUNNING handoff

## Verified outcome
One real experimental authorization issued, one reviewed runner launch, one native compile claim. Running at 2026-09-19T07:16:18.298599+00:00; no final exit code yet. Startup synthesis identity/ancestry verified at 2026-09-19T07:15:18.448217+00:00. Return is intentionally bounded startup verification, not full-build completion.

- Host `Agilex7Workstation`, UID 1000, SSH `uwb_student00@100.101.227.97`.
- Owned session `ia840f_mailbox_monitored_01`; fresh execution window `build11_execution`, pane `%397`; observer window `build11_observer`, pane `%396`. Existing panes were not touched.
- SOURCE `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`; fresh WORK `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11`; remote evidence `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-11`.
- `approved=true`, `accepted_execution=true`, reviews consumed; **ready_for_build=false**, timing/constraint/functional acceptance false.
- Exactly the reviewed hold-only `TDC_AGGRESSIVE_HOLD_CLOSURE_EFFORT ON` experiment; seed 2, maximum placement, clocks/RTL/SDC/geometry/PF/BAR/pins preserved. No Query04, DDR simulation, hardware, installs, permissions changes or commits.

## Issuance and launch
Remote cwd `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-11`:
```sh
/usr/bin/python3 issue_authorization.py /home/uwb_student00/ahls/new_BSP/qualification/fim-build-11/consumed-reviews.json
/usr/bin/python3 launch_native_compile.py
```
Unchanged reviewed issuer SHA256 `e773fb2d445da6b92c0cddbc9c6b707faf31184364700cf6df9470a43a00c07a`; runner `f4d41bf2c0a5ab48912ce669a86b0c0d91fa5b18affdf4a8d62d992fbeb57389`; draft `10fa545ac9be6b79b75e26619ad3361939c30383ef8dafbb584c08a865d44300`.
Authorization SHA256 `c8efbbfc0c850b95ffe21746b123717f388bfece3c0d822bd3754f182d838213`.
Consumed reviews SHA256 `17916f41a879b6090a013fb68cae11e38b0c69496a41acd973f5342fd4dbc28a`.
Spec `efac69b5d115982c247fa7f225e501605869efa9f4030883a4dd814228efe8be`; quality `44de35f852981daa6b2626346dd079ffd514a877b8c4e4c3cabe2110566292a7`.

Issuer was called once after full live SOURCE against Work10 issued baseline, PIM, all 5,564 WORK entries, 106 dependencies, outer/inner tools and executable-context hashes passed. No pre-existing Work11 authorization/lock/claim/run or active native compile was found. Inherited Work05 accepted three-file source review was read and hash-checked. Source QSF baseline `35e3d429ab77bd51f64beec6724138dc654be3e8f17aa5ab1d8955884b9b2293` was checked. Source overlay synchronization/readback succeeded; only three source files have changed bytes. Original review package (65 entries, 44 exports) remains hash-identical.

Environment: QUARTUS_ROOTDIR_OVERRIDE `/opt/altera/26.1.1/quartus`; PATH `/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/local/bin:/usr/bin:/bin`; LM_LICENSE_FILE/MGLS_LICENSE_FILE/SALT_LICENSE_SERVER all `/home/uwb_student00/quartus_26/LR-191011_License.dat`. No wall-clock watchdog.

## Live identities
| PID | /proc start ticks | Real executable |
|---|---|---|
| 151868 | 9008051 | `/usr/bin/python3.9` |
| 151870 | 9008184 | `/usr/bin/bash` |
| 151879 | 9008319 | `/usr/bin/bash` |
| 151888 | 9008492 | `/opt/altera/26.1.1/quartus/linux64/quartus_sh` |
| 152020 | 9009427 | `/opt/altera/26.1.1/quartus/linux64/quartus_syn` |
| 152150 | 9010261 | `/opt/altera/26.1.1/quartus/linux64/quartus_sh` |

- PID 151868: `/usr/bin/python3 launch_native_compile.py`; cwd `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-11`; executable SHA256 `7a95e551de45a54b3b6819d80e71a7262cd7138c2a4f1ec905b4cc8895a034c2`.
- PID 151870: `/bin/bash ./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11`; cwd `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`; executable SHA256 `ec6d007d48ef11bc47ad3f372b4b20ff2f0d4e63867e7e4cc0f1b17b19fa88b2`.
- PID 151879: `/bin/bash /home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach/ofs-common/scripts/common/syn/build_fim_compile.sh ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11`; cwd `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11/syn/board/ia840f/syn_top`; executable SHA256 `ec6d007d48ef11bc47ad3f372b4b20ff2f0d4e63867e7e4cc0f1b17b19fa88b2`.
- PID 151888: `quartus_sh --flow compile ofs_top -c ofs_top`; cwd `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11/syn/board/ia840f/syn_top`; executable SHA256 `5740e47134517eac623c1391837761d12ab18b99a2db78be790cf764af3e3bce`.
- PID 152020: `quartus_syn --ipc_flow=17 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top`; cwd `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11/syn/board/ia840f/syn_top`; executable SHA256 `a552780d9319803b701771b70eaa8e42751c99f7b1bc530fac128571697c0ce8`.
- PID 152150: `/opt/altera/26.1.1/quartus/linux64/quartus_sh --ipc_sh`; cwd `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_11/syn/board/ia840f/syn_top`; executable SHA256 `5740e47134517eac623c1391837761d12ab18b99a2db78be790cf764af3e3bce`.

Claim binds native Bash PID 151870/start 9008184 to the authorization hash. Exact synthesis executable/hash/argv/cwd matched the unchanged closed context table; live parent chain reached the claimed PID, runner and owned tmux ancestry. Internal `quartus_sh --ipc_sh` is separately inventoried, not added to callback permissions.

## Durable evidence and monitoring
Remote persistent files:
- `execution-preflight.log`, `issuance-preflight.json`, `issuance.log`, `runner-console.log`.
- `compile-authorization.json`, `consumed-reviews.json`, `native-compile.claim.json`, retained `authorization-issuance.lock/`.
- `run/invocation.json`, `run/status.json`, `run/native.log`.
- `final-marker-check.json`, `startup-report-marker-scan.json`, timestamped `launch-observation-*.json` and `native-generated-qsf-*.diff`.

Local hash-verified copies are in `issued-readback/` and `startup-readback/`; transfer hashes and per-file manifest in `execution-local-verification.json`. Latest full startup scan covered 110 available native/report logs and found zero gate-rejection markers or 125091. This is startup evidence, not a future guarantee. Native IP generation advanced into live synthesis; no final fit/STA/assembly result is asserted.

For further observations, perform all remote operational reads inside an owned window of `ia840f_mailbox_monitored_01`; do not rerun issuer or runner. Preserve the claim/lock/logs even on failure. Read `run/status.json` for actual final return code when finished and inspect complete logs/reports.

## Native QSF migration
SOURCE remains reviewed QSF SHA256 `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`. Quartus natively migrated WORK to HIGH PERFORMANCE EFFORT plus GLOBAL_PLACEMENT_EFFORT MAXIMUM EFFORT, updated LAST_QUARTUS_VERSION and emitted the deprecation comment. Hold ON remains. Exact separate diff captured; no operator edit to live inputs or copying native migration into SOURCE.

## Operational notes and acceptance remaining
Two transport command-length errors occurred before execution-window creation or remote payload execution; tmux stdin-buffer transport then succeeded. No authorization or compile retry occurred. First read-only observer overmatched internal IPC helper against callback table; failure is retained in `observer-first-check-failure.txt`. Actual synthesis-only verification then passed. No gate code, reviewed runner/issuer or record grammar was changed.

Full build completion remains pending. Compare both DDR channels/all corners setup and hold WNS/TNS/failing endpoints, PHY hold, effective settings, routing/cell composition, warnings and constraint completeness against Work10. S1/TRS, PCIe-divider, BMC IRQ/JTAG and unconstrained-path questions remain open. Assembly/exit zero alone is not timing or functional acceptance and never permission to program hardware. Source-bound guards are not an OS sandbox.
