# IA840F source port

**Not ready for build.** Both revisions load `setup/build_gate.tcl`.
See `../../../..` relative to this board directory for the repository root;
the full handoff is `../docs/fim-port.md` relative to that root.

This board selects current OFS RTL variants in `src/board/ia840f`, preserves
AGFB027R25A2E2V pins/configuration, and routes PF1 to BittWare BMC management.
Legacy source IP is retained under `ipss/ia840f`, not presented as upgraded IP.
The selected PCIe/memory source specifications in `config/` remain subject to
experimental authorization and generated-interface qualification.

`source_manifest.json` records source paths and SHA-256 values. `pin_inventory.json`
records every active physical pin. Do not copy inactive N6000/DevKit assignments,
old FIM shared RTL, or build products into this board.

Outstanding: generated mixed-memory interface/group mapping, actual PCIe PF1
BAR2 child-IP acceptance and capability/interface validation, BMC Qsys
compatibility/FLR qualification, and clocks/PR fit. Installed subsystem/child
schema evidence is not generated-IP acceptance. Host pipes are not a mandatory
workload requirement. Experimental setup/generation requires the source-bound
gate and a reviewed single-run authorization; readiness remains false. Local
Python/Bash policy tests are not Quartus generation or hardware qualification.
