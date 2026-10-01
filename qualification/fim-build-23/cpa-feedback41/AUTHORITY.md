# CPA feedback37 — bounded existing-netlist observation

Under the ongoing migration/timing-investigation instruction, the parent permits one finite read-only observation on a preserved copy of completed Work23. This is not a refit, timing correction, programming action or hardware test.

Use the demonstrated final-snapshot STA workflow, original SDC, and Fast vid2 100C. First reproduce the known −0.004 ns hold path. Then resolve only the named CPA core output/return, three PHY-feedback input pins and DDR1 reference-clock port, with observed cardinalities capped at eight per lookup. Perform at most eight one-path raw max/min reports: rising and falling core-feedback pairs, plus rising and falling paths into the selected PHY feedback pin from the preceding keeper boundary; unavailable objects/paths remain explicit acquisition gaps. Do not run a broad clock-network fanout report, invent atom properties, change a constraint, or claim these reports expose the proprietary COMP calculation.

Original Work23 and PIM file/link inventories must be preserved. Scratch changes are limited to exact path relocation and the copied execution callback; source/electrical/clock/floorplan settings are unchanged. The native CMake target invokes only same-release quartus_sta on the copied database. Use the existing live-ancestry/source-bound callback and supervised process-group lifetime, a 600-second query budget, 64 GiB address-space limit and 64 MiB report budget. All claims and output paths are exclusive; no automatic retry.

The failed images remain undeployable. Any resulting path data is diagnostic evidence only and cannot authorize a physical override or waive the hold violation.
