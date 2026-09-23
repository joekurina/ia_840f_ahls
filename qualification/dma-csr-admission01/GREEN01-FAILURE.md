# Preserved first candidate compile failure

Native vlog rc2, outer2: csr_mgr.sv(158) vlog-2730 undefined is_csr_write. The new freshness always_ff preceded the original declaration. No vsim run occurred. Successor changes only declaration ordering, with the exact same test and dependencies; no tool/deadline change.
