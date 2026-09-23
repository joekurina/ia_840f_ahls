# CSR path query01 — failed diagnostic setup, preserved

Native/effective/outer3/3/3; Error332000 missing `::userClocks::u_clk_fmax`, failed read_sdc before register/path inventory. Bound inputs/original fit/release/tools unchanged; no postflight errors, timeout or owned survivors. No numerical path claim follows. This does not invalidate the completed finalSTA.

Captured generated user_clock_defs.tcl defines relative `namespace eval userClocks`, including u_clk_fmax800. Evaluating it inside the diagnostic namespace does not populate the expected global namespace. Inert Tcl with the exact captured definitions confirms this distinction. Successor query02 sources these unchanged definitions and invokes read_sdc at global scope using uplevel#0. This changes diagnostic invocation context, not SDC or clock settings. Fresh copy of completedfit01; no failed-query database reuse. Query01 preserved.
