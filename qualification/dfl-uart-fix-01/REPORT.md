# DFL UART: false feature advertisement, not a missing clock value

## Status

**DIAGNOSED / source-contract regression PASS; correction BLOCKED on the
explicit feature-scope decision required by GOAL-PROMPT.md §A.3.**
No RTL, driver, clock, feature ID, or hardware state was changed. There is no
implemented or live-verified UART fix. The passing positive fixture is the
existing *enabled-UART metadata contract*, not corrected W13 hardware.

## Exact evidence

Remote ordinary file reads ran inside `ia840f_mailbox_monitored_01`; collections
and hashes are retained in [source-resume-01](../source-resume-01/REPORT.md),
especially `batch01.json`, `batch02.json`, and `batch03.json`.

- Installed module name is **8250_dfl**, not `dfl_uart` (the first modinfo lookup
  failed and is retained). Installed weak-updates module and checkout
  `8250_dfl.ko` are byte-identical, SHA256
  `78a6de128a5ea15a57c0d7eb634ddf2472f1738bbb87dbf6e09aa6738b801e0b`.
  `srcversion=967FCDEF7C24114AAC80F83`; vermagic is the earlier compatible
  kernel `5.14.0-687.15.1.el9_8.x86_64`. This is not a reason to reload it.
  The source checkout is `1d01b806f5bd7c65e2e46c37d43ba4aa6a4a047c`; its
  unrelated dirty files are preserved. See `batch02.json` module records.
- Captured `drivers/tty/serial/8250/8250_dfl.c:24–29,35–106,151–169`
  requires parameter ID 2 = one 64-bit clock-frequency payload in Hz, ID 3
  = FIFO length (32/64/128), ID 4 = register layout. Missing ID 2 returns
  ENOENT before serial-port registration. The captured `dfl.c:247–251`
  matches feature type/ID even without a matching GUID.
- W13's native `fim_project_macros.tcl` has **neither INCLUDE_UART nor
  INCLUDE_HPS**. Its board `src/board/ia840f/afu_top.sv:729–755` therefore
  selects **uart_dummy_csr**, retaining feature ID `12'h24`.
  `src/afu_top/dummy_csr.sv:197–211` emits DFHv0 (version field zero), with
  no DFHv1 parameter vector. This matches the recorded missing-CLK_FRQ failure.
- This is **not** a malformed live UART parameter chain: the real `vuart_top`
  branch is inactive. Its separate INI contains parameter headers at 0x28,
  0x38, 0x48, 0x58 and payloads at 0x30, 0x40, 0x50, 0x60. Next-header
  field 0x10 corresponds to two 64-bit words; the last uses 0x11 (EOP).
  Clock payload `0x2FAF080` is **50,000,000 Hz**, despite its stale 100 MHz
  comment. `vuart_top.sv` wires the real UART/DFH to `clk_50m`; this does not
  make an active UART exist in W13. No frequency was invented or programmed.

Paths above are under the captured
`../source-resume-01/remote/home/uwb_student00/` tree, with driver sources in
`linux-dfl-backport` and W13 in `ahls/new_BSP/work_ia840f_fim_13`.

## Offline regression

[Exact command/result](offline-test-01.json):
`python3 -B qualification/dfl-uart-fix-01/test_contract.py` → **12/12 PASS**.
The suite checks disabled macros, dummy ID, required-driver contract, old
missing-parameter failure, source-derived enabled metadata, missing/short/
oversized clock parameters, early termination, FIFO/layout rejection, and
unchanged neighboring parameter bytes. It is a bounded parser model, not HDL
simulation or a boot-probe test. No neighboring DFH was edited.

## Required disposition

The prompt explicitly requires a scope decision if a feature was wrongly
advertised. Decide whether this board FIM should:

1. Keep UART absent and correct its misleading DFL advertisement while
   preserving the feature-chain topology; or
2. Implement an actual required UART with a specified safe endpoint and its
   source-proven clock/interrupt contract.

Do not blacklist 8250_dfl, add fake metadata to the dummy CSR, enable HPS,
change clocks, or choose a new feature ID merely to suppress a warning.
After the scope decision, prepare the minimal source patch and old-fail/new-pass
DFH-chain regression, then a justified fresh source-bound FIM build. Hardware
deployment and UART functional acceptance remain separately gated.
