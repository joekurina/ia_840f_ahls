# Work11 bounded continuation: fitter and full STA captured

Observation: 2026-09-19T08:08:35.950190+00:00 through 2026-09-19T08:13:02.603592+00:00 (five samples). Native status remains running, no final return code. Last active task: quartus_asm PID 156622/start9359480, CPU ticks1533. Final assembly and image inventory remain pending; image inventory was empty at capture. Do not rerun the compile.

## New milestones
- Fitter successful, 0 errors / 202 warnings, ended 08:07:54 UTC; elapsed 00:45:36. Final database committed.
- Post-fit MIF update progressed into STA, then assembly.
- Timing Analyzer successful, 0 errors / 240 warnings, ended 08:11:58 UTC; elapsed 00:01:27. This is execution success, NOT timing acceptance.
- Complete native STA report preserved before any later reduced report: 46834561 bytes, SHA256 `9b851e84ea597e8c7b8b846d630609ce69ed6436ce555cc853858f6ec91f838c`. Native all-corner worst-case summaries cover five delay models; 34 setup/hold clock rows parsed. Full report, summary, endpoint/path details, constraint tables and Work10 comparison are retained in `timing-analysis.json` and readback.

## Work10 comparison (ns)
All 34 clock setup/hold summary WNS/TNS/failing-endpoint/limiting-corner entries are unchanged versus hash-verified Work10 full STA.

| Domain | Type | WNS | TNS | Failing endpoints | Limiting corner |
|---|---|---:|---:|---:|---|
| DDR0 core | Setup | -0.508 | -185.081 | 711 | Slow vid2 100C |
| DDR1 core | Setup | -0.170 | -29.340 | 403 | Slow vid2 100C |
| DDR1 PHY clk_l_0 | Hold | -0.004 | -0.004 | 1 | Fast vid2 100C |

DDR0/DDR1 core hold both 0.000 ns WNS, zero TNS/endpoints. DDR0 PHY clk_l_0 hold +0.103 ns, zero TNS/endpoints. Setup, hold, DDR and unconstrained-path closure FAIL. Constraint summary: one unconstrained clock, two input ports (78 path pairs), two output ports (10 path pairs), for both setup and hold. No timing/constraint/functional acceptance claimed.

## Provenance and next baseline
Fresh owned tmux window `monitor-20260919T080835Z`, pane `%404`, session `ia840f_mailbox_monitored_01`; verified host Agilex7Workstation, UID1000. Every observed vendor process has ancestry through claim151870/start9008184, runner151868/start9008051, tmux7828. Unchanged claim authorization binding verified. All five samples have zero detected error diagnostics and zero gate-rejection/125091 markers; final scan covers 128 logs/reports.

Remote evidence `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-11/monitor-20260919T080835Z`. Local evidence `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/fim-build-11/monitor-20260919T080835Z`. Export verified: 30 manifest files, 3888582 archive bytes, SHA256 `80b226b38b110785b8e5be77d3390917ca8513cf1fed6edc4c3cbf05d0b9ac34`. Script byte identity verified. Commands, snapshots, full reports, image inventory, manifest, identity checks and comparison saved. Next baseline `readback/snapshot-04.json`; next bounded check needs final native status, assembly/flow report and programming-image size/SHA256 inventory. Reuse preserved full STA rather than any later reduced STA.

No new vendor invocation, issuer/runner rerun, process control, input/source/gate/claim/authorization edits, Query04, DDR simulation, hardware, install, permission changes or commits. Hold-only ON, seed2/max-placement unchanged; readiness false. No operational issues.
