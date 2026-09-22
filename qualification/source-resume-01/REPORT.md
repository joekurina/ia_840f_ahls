# Source-side continuation checkpoint

## Scope and result

Resumed under GOAL-PROMPT.md: source/config/log collection, inert regressions,
and one native host-software compile/link. **No FPGA device was opened; no
OPAE runtime/discovery, MMIO, PCI configuration access, PR, programming, reset,
VF creation/rebinding, udev activation, service change, or host recovery was
performed.** All remote work ran in owned tmux session
`ia840f_mailbox_monitored_01`, separate windows; commands and pane receipts are
retained. No full FIM/persona build was restarted.

| Work item | Status | Evidence |
|---|---|---|
| Exact saved W13 source binding | PASS for selected 116 files | [comparison](w13-source-binding.json), prior W13 inventory |
| UART contract diagnosis | PASS diagnosis; fix BLOCKED on scope decision | [UART report](../dfl-uart-fix-01/REPORT.md), 12 parser/source fixtures |
| udev minimal candidate | Implemented, 12 inert fixtures PASS; not activated | [udev report](../dfl-udev-fix-01/REPORT.md) |
| AFU PF/VF/BAR and backend source path | Source-established; current hardware identity unknown | [access map](../ahls-host-offline-01/HOST-ACCESS-MAP.md) |
| Additive AHLS host test | Offline suites PASS; native OPAE-linked binary built, not executed | [host report](../ahls-host-offline-01/REPORT.md) |
| W13/persona timing | FAIL/open, not accepted | Existing summaries and path excerpts below |
| Hardware qualification and durable boot | NOT RUN in this continuation / BLOCKED | No live authorization/recovery assumed |
| DDR simulation | SKIPPED BY USER | Existing DDR hardware gate unchanged |

## Collected evidence

Seven finite, read-only source batches are preserved as `batch01.json` through
`batch07.json` and matching gzip transfers. Each transfer was checked against
its remote gzip and raw-JSON SHA256 before decoding. Each exported source was
checked against its remotely measured hash. Failed pathname guesses are
retained as explicit errors; exact paths were subsequently resolved, not
silently substituted. The raw batches are the authoritative collection records.

- Batch01: OS/headroom/owned-process snapshot, actual udev rules, driver
  metadata and W13/maintained UART source. No native FPGA tool tasks appeared
  in the snapshot; it was not a continuous monitor.
- Batch02: installed-versus-built driver module hashes, exact driver source,
  installed udev help/manual, W13 PIM and board source.
- Batch03: generated AHLS CRA implementation, saved PCIe IP, build/timing
  summaries, image hashes, OPAE headers/config, device-node stat and cached
  `/run/udev/data` files (no device opens).
- Batch04: remaining routing sources, saved timing-path excerpts, OPAE source
  identity and metadata-only checks of the exact old chmod operand paths.
  No hardware-backed sysfs attribute contents were read.
- Batches05–07: OPAE configuration search and VFIO enumeration implementation,
  install/build library identities, exact native host-binary readback and ELF
  dependencies. Installed plugin whole-file hashes differ from build copies;
  GNU build-ID, `.text`, `.rodata` sections match. No libraries were dlopened.

The raw `batch03.json` is 2,304,638 bytes and stays local-only under the 2 MB
repository cap. Its SHA256 is
`7790e9ab1f5c5ae4641f7e599880decac1095b9012b7a9e4a9fda89c138972ba`;
[the byte-equivalent gzip archive](batch03.json.gz) is tracked. Other small
batch records and per-file manifests remain in the repository.

`collect01.py`–`collect07.py` and `launch01.json`–`launch07.json` are exact
collection/dispatch artifacts. The first W13 pg_csr export used Python
read_text newline conversion; its hash mismatch was detected. CRLF bytes were
reconstructed and proven against the remote original hash, recorded in
[transfer notes](batch03-transfer-notes.json). Later collectors use base64 raw
bytes. No source evidence was accepted with a mismatched hash.

The initial remote session from the old boot was absent; a new owned session
was created for this work. Initial source snapshot showed 117 GiB available
RAM and 1.3 TiB available disk. Native host compilation rechecked headroom.
It wrote only its new dedicated qualification directory and did not execute
the linked FPGA-access binary. See [native evidence](../ahls-host-offline-01/native-result01.json).

## Important corrections to the old handoff

1. **UART:** INCLUDE_UART is disabled in W13's captured native macros, but
   board `afu_top.sv` advertises feature ID 0x24 using a dummy DFHv0 CSR.
   The driver requires real clock/FIFO/layout parameters. This is false
   advertisement, not a license to invent clock metadata or blacklist a driver.
2. **udev:** the exact unpackaged `90-intel-fpga-opencl.rules` has an unmatched
   `dfl*/userclk/frequency` operand in the current metadata snapshot; the
   errors directory and device node exist. Removing the shell chmod from a
   staged least-privilege candidate does not mean the installed rule is fixed.
3. **Routing:** PF0 BAR0+0x80000 is the protocol checker, not an AHLS window.
   PF0 VF0 BAR0 is the source-proven AFU path. The old report's categorical
   claim that UUID enumeration is impossible is unsupported; the retained
   OPAE VFIO source supports standalone-AFU GUID discovery at BAR0+8/+16.
4. **Host semantics:** the finish counter is two-bit clear-on-read. The real
   AHLS computation is an eight-product XOR checksum, not plain a+b and not
   an unspecified affine operation. Old code is retained as history only.

## Existing build evidence: successful compile is not timing acceptance

These are existing saved reports, not newly run STA. Full-file hashes and
compact exact path excerpts are in `batch04.json`; summaries are in the
captured W13/persona trees from `batch03.json`.

| Artifact | Worst setup | Worst hold | Worst minimum pulse width | Disposition |
|---|---:|---:|---:|---|
| W13 base FIM | +0.185 ns | **-0.004 ns** | 0.000 ns | Timing not accepted |
| Sanctioned persona | **-0.336 ns** | **-0.004 ns** | **-0.029 ns** | Timing not accepted |

The common hold path is EMIF1 `amm_writedata_0_r[0][243]` to a PHY register
(`emif_1_phy_clk_l_0` latch clock). The persona setup path is within PIM's
registered MMIO bridge (`cmd_address[7]` to `cmd_address[12]~bsyn_ir`) in the
user-clock domain. These identify affected paths, not a proven remedy or the
cause of prior runtime PR failure. No clocks, constraints, or vendor RTL were
changed. Preserve all artifacts; do not rebuild unchanged designs or suppress
negative slack. A successor build needs a justified source/control delta and
reviewed timing disposition. The unresolved UART architecture decision can
change the required FIM delta; no speculative full compile was launched.

## Remaining gates

The UART feature-scope question was presented and received no answer; no
choice is inferred. The proposed decision is whether to correct the disabled
UART advertisement or implement an actual required UART endpoint. The prompt
requires that decision before altering a wrongly advertised feature.

No independent host-recovery path or specific live FPGA operation has been
authorized or verified. Current image, VF BDF/binding, BAR allocation,
clock/reset state and non-root VFIO ownership remain open. These are not
satisfied by source review or native linking. DDR, host transfers, AHLS live
numerics, PR, sustained testing and flash/power-cycle acceptance remain open.
The current CSR-only AFU has idle memory masters; completing its CSR test
cannot qualify memory or DMA.

The preceding crash review, old image artifacts and incident scripts are
preserved. No locator, raw-window fallback, PR retry, reset, or watcher was
started. Existing unrelated edits in `.gitignore`, `GOAL-PROMPT.md`,
`.gitignore_big`, and the prior crash-review directory are not absorbed into
this milestone without deliberate staging.
