# AHLS Compile Qualification — ahls-compile-01

Date: 2026-09-19 (PDT)
Operator: Hermes subagent (standing in-scope vendor authorization; rapid iteration authorized)
Local tree: `N = /home/joe/Projects/Thesis/AHLS/new_bsp/new`
Remote: `uwb_student00@100.101.227.97` (Agilex7Workstation), `B = /home/uwb_student00/ahls/new_BSP`
tmux: owned session `ia840f_mailbox_monitored_01`, NEW window `ahls_compile_01` (window 294; no existing pane altered)
Scratch: `B/work_ahls_compile_01/` (fresh; only files authored for this task)
Evidence (remote): `B/qualification/ahls-compile-01/{logs,artifacts,src}`
Evidence (local mirror): `N/qualification/ahls-compile-01/{src,logs,artifacts}`

## Verdict

**SUCCESS — first real AHLS compile completed on the workstation.** HLS IP Gen 2026.1.0 generated a complete standalone RTL/IP report project (`qual_vec_op.report.prj/`, 150 files, 11 MB) for the IA-840F part `AGFB027R25A2E2V`, including the device-interface artifacts the OFS FIM integration needs (`*_di.sv`, `*_di_hw.tcl`, `*_di_inst.sv`, `register_map_offsets.h`, kernel register-map header, interface structs). One attempt; both compiler stages rc=0; no board/BSP flow used; no Quartus required for RTL generation.

## Toolchain and environment (verified live)

- Compiler: `HLS IP Gen, Version 2026.1.0 Build 461da9be608f74678d9c52a2dc1cbb67c58d57fa` (`ahls --version`, log lines 79–80). Backend `aoc --version` reports the same 2026.1.0 Pro Edition build.
- Install root: `/home/uwb_student00/ahls/altera_hls/aclsycl/`
- **Env init required: `source /home/uwb_student00/ahls/altera_hls/aclsycl/fpgavars.sh`** — puts `bin/` on PATH, `host/linux64/lib` on LD_LIBRARY_PATH, `include/` on CPATH. With this sourced, both `bin/ahls` and `bin/aoc` (the bundled perl env) work directly; no Apptainer image needed for the report flow. Note fpgavars also prepends Quartus **23.1** (`/opt/intelFPGA_pro/23.1`) and questa_fe to PATH — irrelevant to RTL generation (no Quartus invoked), but must not leak into later 26.1.1 synthesis contexts.
- Target part: `AGFB027R25A2E2V` (from `ofs-agx7-pcie-attach/src/board/ia840f/legacy/syn/syn_top/ofs_top.qsf` line 9).

## Invocation (pinned from hls-samples @ tag 2026.1.0, commit 0abae6d7 "2026.1 Release" — matches installed compiler)

Primary references (local clone `/home/joe/Projects/Thesis/AHLS/hls-samples`, verified `git describe` = 2026.1.0):

- `Tutorials/GettingStarted/fpga_compile/README.md` line 162 — the canonical first-report invocation:
  `ahls -DFPGA_HARDWARE -I<include> <src>.cpp -Xshardware -fsycl-link=early -Xstarget=Agilex7 -o <name>_report.a`
- `Tutorials/Tools/platform_designer/add_oneapi/CMakeLists.txt` line 97 — report link flags:
  `-Xshardware -Xstarget=${FPGA_DEVICE} -fsycl-link=early` (per-part standalone IP, no `--board`)
- `Tutorials/Tools/platform_designer/add_oneapi/src/add.cpp` — authoring dialect: SYCL single_task functor with CSR-mapped scalar args + `altera_exp::pipe` with `protocol<avalon_mm>` + `uses_ready<false>` for CSR registers.
- `ahls --help` (captured live): `-Xstarget=<board name or FPGA device family or FPGA part code>` documented; `-Xshardware`/`-fsycl-link` are clang-driver-level flags passed through to the FPGA backend.

Exact commands executed (attempt 1, both rc=0; full log `logs/attempt1.log`, 98 lines):

```
source /home/uwb_student00/ahls/altera_hls/aclsycl/fpgavars.sh
cd /home/uwb_student00/ahls/new_BSP/work_ahls_compile_01
ahls -DFPGA_HARDWARE -Wall -c qual_vec_op.cpp -o qual_vec_op.o            # rc=0
ahls -Xshardware -Xstarget=AGFB027R25A2E2V -fsycl-link=early \
     qual_vec_op.o -o qual_vec_op.report                                  # rc=0
```

Runner: `attempt1.sh` (sha256 `6be78e2c…`, hash-identical local/remote), executed via `bash attempt1.sh 2>&1 | tee …/logs/attempt1.log` in tmux window `ahls_compile_01`. Target binding proven inside the generated project: `qual_vec_op.report.prj/logs/qual_vec_op_report.log` records the actual backend command `aoc … -hardware -target=AGFB027R25A2E2V`.

## Component authored

`qual_vec_op.cpp` (sha256 `43aec33dc09cf2d5…`, hash-identical local/remote). Minimal generic element-wise vector op: kernel `IDQualVecOp`, functor `QualVecOpKernel` with 3 CSR-mapped int args (`a`, `b`, `mode`) computing `out[i] = (mode==0 ? a+i : a-i) * b` for i=0..7 unrolled, XOR-checksummed into an `avalon_mm`-protocol CS pipe (`ResultPipe`). No pointers/USM → no external memory interfaces; standalone CSR-only IP, exactly the "few args + status/control register" target of plan.md §7.2.

## Generated artifact inventory

`qual_vec_op.report.prj/` — 150 files; complete SHA256 manifest: `artifacts/prj-file-sha256.txt` (remote + local mirror); whole-project archive `artifacts/qual_vec_op.report.prj.tgz` (4.3 MB, sha256 `99181eca7bf2976c…`, verified identical on both hosts). Key artifacts (sha256 in `artifacts/key-sha256.txt`, copies under `artifacts/extracted/`):

| Artifact | Role |
|:--|:--|
| `qual_vec_op_report_di.sv` | Device-interface top RTL (`e84d00de…`) |
| `qual_vec_op_report_di_hw.tcl` | Platform Designer HW import script; `SUPPORTED_DEVICE_FAMILIES {"Agilex 7" "Agilex"}` |
| `qual_vec_op_report_di_inst.sv` | Example instantiation template |
| `qual_vec_op_report_sys.sv` / `_sys_hw.tcl` | Kernel-system variant |
| `include/register_map_offsets.h` | Register-map root (`IDQUALVECOP_REGISTER_MAP_OFFSET 0x0`) |
| `include/kernel_headers/IDQualVecOp_register_map.h` | Full kernel register map |
| `IDQualVecOp_interface_structs.sv` | Kernel arg/CS interface structs |
| `kernel_system.sv/.tcl/.qip`, `ip/*.sv` (~50 acl_*/hld_* libs), `board_spec.xml`, `reports/` (HTML optimization report), `sim/` | Supporting RTL, IP libs, board spec, optimization report |

Note: no `.ip` file is emitted by `ahls` itself. Per the platform_designer tutorial, `_di.ip` files materialize when the generated project is imported into a Platform Designer system — that is the FIM-side follow-on step, not a gap in this compile. The `kernel_system_import.tcl` + `_di_hw.tcl` pair is the documented import entry.

## Register map summary (from `IDQualVecOp_register_map.h`, CSR version 5)

| Offset | R/W | Field |
|:--|:--|:--|
| 0x00 | R | status: bit0 reserved, bit1 done, bit2 busy, bit15 running; bits 31:16 CSR-address-map version |
| 0x08 | W | start |
| 0x30/0x34 | R | finish counter (lo/hi, clear-on-read) |
| 0x80 | W | arg_a [31:0] (packed with arg_b into 64-bit reg16: a=low, b=high per masks) |
| 0x84 | W | arg_b [31:0] |
| 0x88 | W | arg_mode [31:0] |
| 0x90 | R | ResultPipe CS register (output host-pipe data, 64-bit) |

## Top-level ports (`qual_vec_op_report_di` from `_di_inst.sv`)

- `clock` (1-bit clk in), `resetn` (1-bit active-low reset in), `freeze` (1-bit in)
- `device_exception_bus` (64-bit out), `kernel_irqs` (1-bit irq out)
- `csr_ring_root_avs` — Avalon MM slave, 64-bit data, **5-bit address**, byteenable(8), read/readdata/readdatavalid/write/writedata/waitrequest. This maps 1:1 onto the hand-written binding library's `ahls_mmio_to_avmm` 64-bit CSR agent (`N/afu/ahls/rtl/`).

## Warnings / caveats

- Compile stages emit no warnings in the captured log (`-Wall`, rc=0 both stages).
- `board_spec.xml` names device model `agfb014r24a3e3vr0_dm.xml` (generic standalone-IPA device model), while the actual backend target is `AGFB027R25A2E2V` (proven in the inner aoc log). Expected for family/part standalone flow; `_di_hw.tcl` correctly gates on Agilex 7 family.
- The optimization report's area estimates are static (report flow), not measured timing — consistent with plan.md stage 4.

## Remaining gaps / follow-on integration needs

1. **Platform Designer import** (next qualification step): import `qual_vec_op.report.prj` into a `.qsys` under Quartus **26.1.1** (`/opt/altera/26.1.1`) to produce `top_*_di.ip` and validate 26.1.1 importability of 2026.1.0-generated IP (the toolchain-compat question from ahls-afu-integration-01 gap #10). The AHLS-side `.prj` is complete and self-contained for this.
2. **Binding-library instantiation**: instantiate `qual_vec_op_report_di` behind `N/afu/ahls/` binding (`ahls_mmio_aperture` DFH/UUID + `ahls_mmio_to_avmm`); bind `AFU_UUID`, `CSR_BASE_BYTES`, `CSR_SIZE_BYTES` (gap #2 of prior research). CSR window needed: 0x00–0x97 → 256 B aperture suffices (5-bit addr = 32 B × 8 BE granules … actual decode is 5-bit word address over the 8-byte granule map; aperture sizing to be finalized against `_di.sv` decode during integration).
3. **Host-side invocation semantics**: start/done via status(0x00)/start(0x08) + finish-counter clear-on-read; args packed per masks (a=bits[31:0], b=bits[63:32] of the 0x80 quadword — note 0x80/0x84 are one 64-bit register, writes must use correct byte lanes).
4. **Clock/reset binding**: single `clock`/`resetn`/`freeze` — map to uclk_usr domain + `pr_freeze` per prior research gaps #7.
5. Emulation/simulation of the component (plan.md stages 3/5) not exercised here — this run covers stage 4 (RTL/report generation) only.

## File-by-file evidence locations

- Local: `src/qual_vec_op.cpp`, `src/attempt1.sh`, `logs/attempt1.log`, `artifacts/{key-sha256.txt, prj-file-sha256.txt, qual_vec_op.report.prj.tgz, extracted/…}`
- Remote: `B/work_ahls_compile_01/{qual_vec_op.cpp, attempt1.sh, qual_vec_op.o, qual_vec_op.report, qual_vec_op.report.prj/}`, `B/qualification/ahls-compile-01/{logs/attempt1.log, artifacts/*}`
- No source-tree mutations outside fresh scratch; no commits/pushes; vendor install dirs untouched.
