# Work20 current checkpoint

Status: **FAILED / SPENT — elaboration, no fit/STA result**. Native finished2026-09-23T04:56:12.579572+00:00 with returncode1. Latest process/file snapshot `status02.json` at2026-09-23T05:01:20.676202+00:00 found no owned native processes. This supersedes the earlier running checkpoint; `status01.json` retains that historical observation.

The Python-only clean-environment callback fix worked: IP generation and post-IP callback completed0 errors/0 warnings. Synthesis then failed Error13907: generated remote-STP `altera_sld_host_endpoint_wrapper.sv` passes CLTAP_CONNECTION, absent from the installed25.1 endpoint declaration. The26.1.1 declaration includes it. Source/library capture is `elab-failure02.json.gz`, SHA256 `7687eae362b6d990bb3c6bd4cdccfa4e24a95752615fbe007481ada453608040`.

- Original Work18 design inputs and PIM preserved during preparation; no QSF/SDC/RTL design change in this attempt.
- Remote WORK `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_20`, evidence `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-20`; tmux `@146/%146` ended.
- Authorization `a590130022a4d4705fa282ae9b6f065f64f7dcc3cf9aa69682b75350cd674471` is spent. No rerun/in-place repair.
- `gate_rejection=true` here includes the outer guard's native-child-nonzero marker; it is not evidence that the repaired Python import failed again. First failure is actual vendor elaboration Error13907.
- Collector01 rejected the2085434-byte native log at its2MB transfer cap; no native task was retried. Collector02 retained full log bytes under a larger bound. Oversized raw log stays local-only, SHA-referenced.
- No FPGA opens, MMIO, programming, reboot, driver or permission changes. No timing/license/hardware acceptance. Independent result review pending.

Next source-side action: inspect the saved remote-STP scjio component and regenerate that leaf using25.1 in fresh scratch, preserving its intended configuration and comparing exports before any successor FIM compile. Do not edit installed primitives, disable debug/PR or infer hold closure.
