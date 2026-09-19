# BMC mailbox generation review — Quartus 26.1.1

## Disposition

**The saved vendor mailbox interface is stale relative to the captured installed 26.1.1 implementation. The installed component has a real, active `avmm_waitrequest` output; the saved Qsys proxy and leaf IP omit it.** Refresh/upgrade the mailbox leaf and its enclosing saved component boundaries together, preserving the existing configuration and connecting the real backpressure through the existing Avalon interface. Do not manufacture a waitrequest signal or suppress read validity.

This is an exact source correction proposal, not an applied patch or a generation acceptance. Current bound sources remain immutable. The reported work03 errors (`bmc_spi_sub.sdm_mailbox.avmm` and `bw_840_support.bmc_spi_sub_0.sdm_mailbox.avmm`, “Agent with readdatavalid must use waitrequest”, exit 3) are supplied incident context, not a tool run reproduced in this review. Both paths refer to the same nested mailbox definition, not two independently configured mailboxes.

Paths: `N=/home/joe/Projects/Thesis/AHLS/new_bsp/new`; `C=N/ofs-agx7-pcie-attach`; `B=C/ipss/ia840f/bwbmc`; `V=/home/joe/Projects/Thesis/AHLS/new_bsp/old_bsp/ia-840/IOFS_BUILD_ROOT/ofs-ia840f`. Captured installed sources are in `N/qualification/ipgen-03/installed-mailbox-source/`.

## Evidence: saved interface versus actual implementation

### Saved vendor definition

- `B/bmc_spi_sub.qsys:14433–15285` contains the `sdm_mailbox` generic-component proxy. `altera_generic_component` version **1.0** is only the proxy type. Decoded `componentDefinition/originalModuleInfo` identifies **`altera_s10_mailbox_client` 20.2.2** (around line 14810). `logicalView` points to `ip/bmc_spi_sub/sdm_mailbox.ip` (line 15282).
- Both decoded `componentDefinition/boundary` and `defaultBoundary` expose these six AVMM roles only: address input 4, write input 1, writedata input 32, read input 1, readdata output 32, readdatavalid output 1. Neither contains waitrequest. Read-valid declarations are at lines 14564 and 14984.
- `B/ip/bmc_spi_sub/sdm_mailbox.ip` identifies component/entity version **20.2.2** and `model/.../moduleName=altera_s10_mailbox_client` (line 443). Its AVMM IP-XACT port maps (lines 90–145), physical model ports (477–569), decoded `lockedInterfaceDefinition` (797–1044), and `altera_interface_boundary` mappings (1125–1133) all omit waitrequest. This is not just one stale parent cache.
- Saved AVMM properties include `addressUnits=WORDS`, `addressSpan=64`, `maximumPendingReadTransactions=1`, `maximumPendingWriteTransactions=0`, `readLatency=0`, `minimumReadLatency=1`, `minimumResponseLatency=1`, and `waitrequestAllowance=0`. A `waitrequestAllowance` property does **not** declare a waitrequest port.
- Qsys connections and leaf bus types carry **23.1** metadata; that is neither the mailbox component version nor proof of 26.1.1 compatibility.
- Python byte comparisons confirmed the active Qsys and mailbox leaf are each identical to their original `V/ipss/bwbmc/` counterpart. The omission is inherited, not a new board integration edit.

The old generated implementation corroborates that the old boundary was real for its generation era: `V/work-ofs-23.1-2-build/syn/ip_lib/ipss/bwbmc/ip/bmc_spi_sub/sdm_mailbox/synth/sdm_mailbox.v:3–41` says ACDS **23.1 115** and exposes no waitrequest. Its `altera_s10_mailbox_client_2022/synth/sdm_mailbox_altera_s10_mailbox_client_2022_p6gsvni.v:24–32,224–230` passes only those six AVMM signals. The underlying `altera_s10_mailbox_client_core_2012/synth/altera_s10_mailbox_client_core.sv` has no waitrequest text; lines 829–833 actively drive readdatavalid from `rd`. These old generated files are evidence only, not proposed compilation inputs.

### Captured installed 26.1.1 source settles the live-port question

All four local captured files were SHA-256 checked against `installed-mailbox-source.json`; all matched. The manifest records their original directory as `/opt/altera/26.1.1/ip/altera/pgm/altera_s10_mailbox_client/`. This review did not access the workstation or independently recapture that directory.

| Captured filename | SHA-256 |
|---|---|
| `altera_s10_mailbox_client_hw.tcl` | `e20fc216fb32613026c8da82e7081242dabb3ff3f0fb4c63db8a93660106973f` |
| `altera_s10_mailbox_client_core_hw.tcl` | `bb8a89c2068a5381c405e5b9480fbdbe46b69457f78586a3a809d0a21d07eda1` |
| `altera_s10_mailbox_client_core.sv` | `12692f551cb0a4e22e9dbfa5077b8a0b259826892a9cce613d09d574ea2a3ede` |
| `altera_s10_mailbox_client_sw.tcl` | `a20eac89555eadb2ae681eff42553711ce7fcb3881359e7ab3f7484a977cb00f` |

Exact implementation facts:

1. `altera_s10_mailbox_client_hw.tcl:35–36` declares the public catalog kind `altera_s10_mailbox_client`, version **23.0.0**. It creates `s10_mailbox_client_inst` of kind `altera_s10_mailbox_client_core` at line 247 and exports that instance's entire AVMM interface at lines 270–271.
2. `altera_s10_mailbox_client_core_hw.tcl:35–36` declares core version **21.0.0**. Lines 394–427 define the AVMM agent; line 425 retains `avmm_readdatavalid`, and line 427 explicitly declares:

   ```tcl
   add_interface_port avmm avmm_waitrequest waitrequest Output 1
   ```

   This declaration is unconditional. The elaboration callback does not remove or terminate it. There is no saved-settings-dependent switch needed to enable waitrequest.
3. `altera_s10_mailbox_client_core.sv:63–70` declares both real outputs. Lines 285–310 qualify write and read enables with `!avmm_waitrequest`. Lines 321–327 implement:

   ```systemverilog
   if (HAS_URGENT == 1)
       assign avmm_waitrequest = reset | !cmd_in_ready_fifo | !urg_in_ready_fifo;
   else
       assign avmm_waitrequest = reset | !cmd_in_ready_fifo;
   ```

   For this board's `HAS_URGENT=0`, the second branch applies. Backpressure is functional during reset and command FIFO unavailability; it is not an unused compatibility pin. Readdatavalid remains driven from `rd` at lines 850–857.
4. The public composition forwards FIFO depths, memory selections, urgent/stream/offload settings and width at lines 248–258. It sets core `HAS_STATUS=1`, agreeing with the saved board setting. The software driver version **1.0.0** and minimum compatible hardware version **20.0.1** in `_sw.tcl:25,31` are not hardware upgrade targets.

Consequently, “add a port to old RTL” is not the correction: the installed RTL already implements it. Nor should the old generated 23.1 wrapper be used to conclude that the installed component lacks waitrequest. The source mismatch explains the reported interface validation failure, although the exact work03 catalog resolution and generated output remain to be verified separately.

## Exact proposed source correction — not executed

Apply only in a separately authorized successor source revision, with a new source binding; never mutate the currently authorized work03 inputs in place.

1. **Upgrade/refresh `B/ip/bmc_spi_sub/sdm_mailbox.ip` against the installed public `altera_s10_mailbox_client` 23.0.0**, retaining the leaf name `sdm_mailbox` and `moduleName=altera_s10_mailbox_client`. The installed internal core is 21.0.0; do not select it as the public leaf or change the proxy version to it. Use the actual tool's supported component update/save mechanism in that later authorized pass; no unverified Tcl command is prescribed here. Changing version strings alone is insufficient.
2. **Refresh the `sdm_mailbox` proxy in `B/bmc_spi_sub.qsys` from that same leaf** so its `originalModuleInfo` records the resolved public version and both `componentDefinition/boundary` and `defaultBoundary` contain the actual port. Keep its `logicalView` path unchanged. The desired additional boundary port is exactly `name=avmm_waitrequest`, `role=waitrequest`, `direction=Output`, `width=1`, `lowerBound=0`, scalar `STD_LOGIC`; it must not be terminated. Retain all six existing roles, including readdatavalid.
3. Ensure all saved leaf representations agree: AVMM `busInterface` port map `waitrequest -> avmm_waitrequest`; physical `model/ports` output `avmm_waitrequest`; decoded `lockedInterfaceDefinition` AVMM output; and `altera_interface_boundary` mapping to the real internal `avmm_waitrequest`. Parent-only metadata changes leave the leaf's locked boundary stale; leaf-only changes leave the parent's generic-component cache stale. Let the supported refresh produce coherent saved metadata rather than editing arbitrary escaped XML/version occurrences globally.
4. Retain `sdm_pipeline.m0 -> sdm_mailbox.avmm` (`bmc_spi_sub.qsys:19135`, base address `0x0000`). `sdm_pipeline.ip` already declares `m0_waitrequest` as the host-side waitrequest role. The existing interface connection must carry the mailbox's real output through generated interconnect back to that input. Do not export a new board-level wire or hand-insert a separate wrapper. Review the refreshed nested reference in `bw_840_support.qsys`; its external boundary should not gain a waitrequest pin solely for this internal connection.

The source-grounded minimal interface delta is the real one-bit waitrequest output plus coherent component/version/boundary refresh. It is **not** permission to assert byte-for-byte semantic equivalence between old and new IP: the newer vendor implementation adds meaningful FIFO/reset backpressure. Preserve all board settings, register/address contracts, shared access and reset ownership, then qualify the installed behavior separately.

### Settings that must remain explicit

| Parameter | Retained value |
|---|---|
| `DEVICE_FAMILY` | `Agilex 7` |
| `CMD_FIFO_DEPTH`, `RSP_FIFO_DEPTH` | `1024`, `1024` |
| `URG_FIFO_DEPTH` | `4` |
| `CMD_USE_MEMORY_BLOCKS`, `RSP_USE_MEMORY_BLOCKS`, `URG_USE_MEMORY_BLOCKS` | `1`, `1`, `1` |
| `DEBUG`, `HAS_URGENT`, `HAS_STREAM`, `HAS_OFFLOAD` | `0`, `0`, `0`, `0` |
| `HAS_STATUS` | `1` |
| `STREAM_WIDTH` | `32` |
| `CRYPTO_MEMORY_TIMEOUT_VALUE` | `10000` |
| Target device / speed grade | `AGFB027R25A2E2V` / `2` |

These user-facing parameter names exist in the captured installed public component. Its FIFO range is 1:1024, stream width permits 32/64, and crypto timeout permits 10000:2147483647. Do not let default FIFO depth 16 replace the saved 1024. Auto-device/system metadata must remain consistent with the target, not be treated as new HDL parameters.

Preserve address width 4 words, data width 32, 64-byte window, one pending read, readdatavalid, IRQ behavior, and clock/reset associations. Retain installed interface timing semantics; investigate any unexpected refreshed property difference rather than silently accepting it or forcing an old cache over the live component.

### Shared SPI/SDM invariants

- `host_sdm_pipe.m0` and `bmc_spi_sdm_pipe.m0` both feed `sdm_pipeline.s0`; both must receive the real downstream backpressure via existing arbitration/interconnect.
- `system_clk_bridge.out_clk -> sdm_mailbox.in_clk` and `sdm_reset.out_reset -> sdm_mailbox.in_reset` remain unchanged (`bmc_spi_sub.qsys:19381–19382`).
- Active `C/src/board/ia840f/bwbmc_wrapper.sv:75,118,120` derives `reset_csr=~reset_csr_n` and supplies that same global reset to `sdm_reset_reset` and `sysrst_reset`. Do not substitute PF1 FLR or PCIe-only reset, reset shared SPI/SDM to cure stalls, or alter clock/reset ownership.
- No change to address maps, software ownership register, IRQ routing, unsupported SPI windows, or FLR acknowledgement is proposed. `docs/vendor-derived-bmc.md:99–122` remains the governing retained-reset/FLR context.

Explicitly rejected: disabling/removing readdatavalid; changing latency to hide the check; tying waitrequest low; terminating the real output; inventing a flow-control adapter; weakening validation/error handling; replacing BMC with a stub; copying old generated RTL into source inputs; globally replacing `20.2.2` or `23.1` strings.

## Remaining evidence and acceptance boundary

No additional installed-source information is needed to decide whether waitrequest exists or what drives it: the captured public composition, core declaration and RTL settle that question. They do not establish which catalog implementation work03 actually selected, whether a particular update command succeeds, or whether the complete generated design is correct.

A later authorized generation pass must record the resolved catalog paths/versions (public 23.0.0 and core 21.0.0 from the captured installation), refresh/save diff, preserved parameter values, actual generated mailbox port name, and continuous nonconstant waitrequest wiring from core through mailbox wrapper and interconnect to `sdm_pipeline.m0_waitrequest`. Verify both readdatavalid and waitrequest survive in the generated design and both standalone/nested systems complete without the reported error; do not equate leaf generation with nested-system acceptance. Capture shared reset connections and unchanged board boundary. Protocol/FLR/physical readiness remains a separate gate.

If update/save still leaves the old boundary, obtain the exact tool's supported upgrade/save command documentation and resolved-component report rather than guessing another XML flag. If a different catalog definition is selected, capture its full `_hw.tcl`, dependent composition/core Tcl and corresponding RTL, original paths and hashes before revising this proposal.

`docs/bmc-component-source-closure.md` established source registration, expressly not 26.1.1 interface compatibility. This finding does not contradict that finite graph closure; it supplies the installed-interface evidence that review deferred.

## Work performed and limitations

Read-only XML/embedded-XML parsing, static Tcl/SystemVerilog inspection, original byte comparison and Python SHA-256 verification only. No Tcl or HDL was executed, no vendor tools/builds/tests/remote access were used, and no commits were made. The initial bare `python` hash command was unavailable; the same read-only calculation succeeded with `python3`. Only this report was created. No bound source, original vendor source, captured source, manifest, gate or authorization record was edited. Generation correctness and build readiness are not claimed.
