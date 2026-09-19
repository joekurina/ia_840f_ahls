# IA840F first experimental execution — approval request

Status: proposed, not implemented or executed. `ready_for_build` remains false.

## Authority and scope

The active goal attachment authorizes staged build/testing, but `plan.md:103–112` separately requires approval of the exact next stage and reviewed gate change. This proposal requests **Stage C1 setup/IP generation only**. No synthesis, fit, assembler, finish/release, programming, PR, driver replacement, binding change, reboot or reset-under-traffic is included.

## Source baseline

The transferred archive is `active-sources.tar.gz`, SHA-256 `6e536c9f68cef41270e4e1e2030ea390da0ade70a441207c84ff586ceb086f17`. The remote extraction independently verified 2,393 regular files. The local finite manifest receipt checked 177 current/donor hashes with no mismatches. Neither count represents behavioral qualification. Changes implementing this proposal require a new explicit source-hash receipt; the transferred archive remains the preserved baseline.

## Proposed gate change

1. Add an explicit, source-hash-bound experimental authorization record for the single setup run, target `ia840f`, toolchain Quartus Pro 26.1.1 Build 130, FPGA `AGFB027R25A2E2V`, and the exact absent worktree below. Keep readiness false.
2. Preserve the existing PCIe component, PF/VF, preset-kind and preset-hash checks in `ofs-common/tools/ofss_config/ia840f_vendor_pcie.py`. Replace only its unconditional final rejection with a fail-closed check of that approved record, selected source hashes, tool identity, target and output path. Missing or mismatched evidence still rejects execution. No general environment-variable bypass.
3. Preserve `syn/board/ia840f/setup/build_gate.tcl` as the default rejection. Permit only the project-open/setup context needed by the reviewed setup flow under the same authorization; explicitly reject compile, synthesis, fit and finish contexts. Inspect the exact setup call chain before implementing this check rather than guessing a Quartus executable/context token. If setup can run without changing this Tcl gate, leave it closed.
4. Correct stale gate descriptions: subsystem-level PF1 BAR2 source evidence exists, but child-IP acceptance remains experimental; host pipes are not a mandatory invented AHLS ABI.
5. Independently review the implementation and exercise rejection cases before vendor-tool execution. Record all changed bytes and current hashes without replacing donor hashes.

## Exact proposed invocation

Inside a named, logged workstation tmux session, with the documented Quartus/license environment:

```bash
C=/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach
WORK=/home/uwb_student00/ahls/new_BSP/work_ia840f_ipgen_01
cd "$C"
COPY_WORK=1 OFS_ROOTDIR="$C" \
  OFS_PLATFORM_AFU_BBB=/home/uwb_student00/ahls/new_BSP/ofs-platform-afu-bbb \
  ./ofs-common/scripts/common/syn/build_top.sh --stage=setup -p \
  --ofss "nodefault,$C/syn/board/ia840f/config/ia840f.ofss" \
  ia840f "$WORK"
```

The target and stage are supported by the checked-in parser. `-p` selects the PR-capable flow; this setup-only invocation is not permission to produce a completed PR release. Do not use `-e`: the checked-in flow runs synthesis for that option. Preserve full commands, logs, exit status, generated interfaces and failed attempts in a unique qualification run directory.

## Additional prerequisites from the completed entry-point review

- Require `COPY_WORK=1`; the default symlink worktree risks writes through to maintained sources. Pin `OFS_PLATFORM_AFU_BBB` explicitly to the transferred checkout.
- Verify `PACSign`, `packager`, and `afu_json_mgr` in the approved environment before setup. Reject missing prerequisites rather than allowing `setup_opae_sdk.sh` to bootstrap dependencies from default master. No implicit installation or upstream clone is authorized by this proposal.
- Add early checks on native/direct stage entry paths so `all`, `compile`, and `finish` reject a generation-only permission before side effects. The QSF gate alone is too late to prevent worktree creation and OPAE bootstrap.
- Native setup opens the project through `quartus_ipgenerate -t .../emit_project_ip.tcl --mode=ip_lib` before OFSS deployment, then prepares PR/base revisions with `quartus_sh --prepare`. Restrict permission to these reviewed operations, not merely an inherited stage string.
- Successful setup is not complete RTL generation. OFSS deploys/configures IP, and the preset path saves components; BMC systems are registered separately. A separate reviewed generation-only invocation is required for complete PCIe/memory/BMC RTL and interface acceptance. Do not report setup as that acceptance.

## Acceptance before later stages

Review generated PCIe IDs, PF0VF0/PF1 routing, BAR0/2/4 and width/segments; memory geometry, physical grouping/pins, calibration, CSR and clock/reset exports; and BMC component resolution and reset ownership. Unexpected parameter rejection, interface differences or unsupported IP are findings, not permission to substitute another board or discard BMC.

PF1 FLR-under-traffic remains prohibited. Programming remains separately blocked pending verified BittWare image/activation/quiescence and no-JTAG recovery evidence. No gate or source change has been made by this proposal.
