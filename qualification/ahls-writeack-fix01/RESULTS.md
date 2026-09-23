# Write-acknowledgment correction — native RTL unit results

**Observed RED → GREEN; independent acceptance pending.**

The isolated acknowledgment generator is extracted verbatim from the SHA-bound `lsu_ic_top.sv`; the fixture also instantiates the unchanged `acl_has_pending_write` with its default COUNT_WIDTH=8. The complete kernel/LSU/FIFO, DDR controllers and PIM are not simulated. See [SCOPE.md](SCOPE.md) and the source ABI review in `../ahls-memory-abi01/ABI-SOURCE-REVIEW01.md`, §6.

## Native results

| Attempt | Native evidence | Disposition |
|---|---|---|
| red01 | `result-red01.json`: vlog1 before compiling RTL, deprecated -novopt diagnostic caused by the minimal hand-authored INI | Setup failure, not reproduction |
| red02 | `result-red02.json`: compile0errors/0warnings; Fatal ACK_ACCEPTANCE_MISMATCH at106ns, cycle7, write1/waitrequest1/ack1/expected0 | Defect reproduced; native vsim and initial outer wrapper misleadingly exit0 |
| red03 | `result-red03.json`: same defect at106ns; final driver rejects Fatal/nonzero error summary/missing pass marker | Expected RED, outer exit1 even though native vsim exits0 |
| green01 | `result-green01.json`: version/vlib/vlog/vsim all0; no Error/Fatal diagnostics; scoreboard5scenarios/796cycles/2491checks/107accepted/107acknowledged | Observed GREEN, outer exit0 |

red03 and green01 use the same final driver, testbench, pending-counter bytes and installed25.1 tool/INI bindings. Their source difference is the corrected full `lsu_ic_top.sv` and its mechanically extracted acknowledgment slice. Installed default modelsim.ini is copied unchanged; no -novopt suppression is used. Questa reports Intel FPGA Edition64 2024.3. The wrapper preserves raw native return codes separately from the functional verdict: `-onfinish exit` can return0 for `$fatal`, so exit status alone is expressly insufficient.

## Source delta

`afu/ahls_memory/patches/zero_allowance_writeack.patch` qualifies a synthetic external acknowledgment by `!i_avm_waitrequest` when waitrequest allowance is zero. It preserves the allowance-enabled expression and BSP-ack branch and changes only explanatory comments otherwise. `patch-manifest01.json` binds the original, candidate and patch. This is a project-local derivative, not an edit to the AHLS installation, prior generation result or live FIM inputs.

The test covers all boolean input combinations; idle with waitrequest high; one final beat stalled for33cycles; eight output beats with first/middle/last stalls; back-to-back outputs; and64 repeated balanced transactions. The pending counter must remain asserted during the stalled final beat and drain after acceptance. The five scoreboard groups are counted by the testbench. The allowance-enabled fixture only demonstrates unchanged expression behavior, not its complete credit protocol. Burst address/data/byteenable conversion is not tested by the eight-beat pattern.

## Preservation and limits

The recorded original `lsu_ic_top.sv` and `acl_has_pending_write.sv` bytes, all staged test inputs and pinned tool files were rehashed unchanged after each run. Each native command was limited to two CPUs,16GiB address space and120seconds; owned process groups were checked after completion. These are monitored normal-account software runs, not an OS sandbox. The simulation watchdog is100microseconds. All execution stayed inside owned tmux windows in fresh directories under `work_ahls_writeack_fix01/`.

Acceptance sought is **narrow source correction plus this isolated RTL unit regression**. Full-component elaboration, actual configured FIFO/LSU interaction, complete-kernel done, native25.1 Platform Designer import, DMA ordering/host visibility, FIM/persona fit/timing and hardware numerical tests remain open. DDR simulation remains SKIPPED BY USER. No FPGA devices were accessed and no system rule, driver, clock, PR, flash or reboot operation was performed.
