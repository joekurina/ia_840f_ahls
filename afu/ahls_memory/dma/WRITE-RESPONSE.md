# Writer-local response retirement

Use `patches/write_response_retirement02.patch` **after** the AW and elastic-W patches. The unsuffixed first response patch is failed historical evidence, not the candidate to integrate. [Source/results and limits](../../../qualification/dma-write-response01/RESULTS02.md).

The final writer counts AW/WLAST/credited B, reports sticky response errors and emits success only after the expected reply set retires. Errors hold the descriptor, finish its current traffic where replies arrive, then stop without done; reset_dispatcher cannot bypass the held error. Missing replies stay busy. Module reset is not qualified as safe system recovery.

Native standalone16-case evidence:7successful retirements,8expected error holds,1missing-response hold;7500checked data beats,44physical responses,5same-edge AW/B events and5successors without reset. Independent review pending. Actual FIFO/reader/PIM/bank/host visibility and system drain remain unqualified. Original donor and all prior stage evidence are preserved.
