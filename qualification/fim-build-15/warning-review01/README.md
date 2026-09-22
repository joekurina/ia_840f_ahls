# Work15 warning review

Actual native warnings captured while the build continues; no build inputs or running process changed. `manifest02.json` binds full native-log/summaries and diagnostic extracts from the large synthesis/fitter reports. Each selected report row retains its original line number; extracts are not full reports. `capture02.json.gz` losslessly retains all captured bytes and selected rows. The raw native log exceeds the default2MB publication cap and remains local/ignored.

`capture01.py` failed its32MiB individual-file cap on the synthesis report and returned rc1 to the shell; it did not invoke Quartus. Successor capture02 streamed report diagnostics with finite bounds. This collection failure is not a native compile failure.

`review-dispatch01.json` identifies the local-only parallel reviewer and exact snapshot. Review findings do not authorize source changes during the live build or confer timing/hardware acceptance.
