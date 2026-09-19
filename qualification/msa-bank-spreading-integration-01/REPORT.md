# Integration complete; generation candidate 02 awaits review

- Reverified all 98 current correction-manifest entries and the exact independent Q1 review SHA256. Three candidate hashes and source patch remain unchanged.
- Verified the complete live authoritative SOURCE (1,360 files) and PIM against Work11's issued record before writing. No baseline conflict. Work11 QSF remains ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c.
- Integrated exactly derive_presets.py, preset_derivation.json and presets/ia840f_mem.qprs under ipss/ia840f in local and remote SOURCE. Exact before-file backups, full remote before/after inventories and receipts are retained here. No other SOURCE file changed.
- Staged the five exact reviewed existing PCIe reference files into the previously absent remote reference/quartus-26.1.1-pcie. No fetch/install, pin relaxation or overwrite of existing dependencies.
- Verified the complete 2,930-value memory map: exactly msa_0/msa_1 NUM_BANK_FIFOS 8→0; copies1 preserved; simulation/PCIe bytes unchanged. Actual production compare-only derivation ran with /usr/bin/python3 -B, PYTHONOPTIMIZE unset and PYTHONDONTWRITEBYTECODE=1; exit0.
- Historical source_manifest.json remains unchanged. Four pre-existing stale entries are explained by exact parity with Work11's issued complete inventory; integration-receipt.json plus source-after.json explicitly supersede the three correction identities. Existing gates/claims/authorization files were not rewritten; old source-bound authorizations are not reusable.

## Authoritative artifacts

Remote integration receipt (mirrored in remote-readback/integration-receipt.json):
8357a7547a844044ceaf4b2414224c69974ab2d730a09613c24562fee626924a

Use **generation-candidate-02/** for review; generation-candidate/ is a preserved unconsumed predecessor. Candidate02 fixes native exit-status propagation discovered during final self-check; native commands/source/tool bindings and unused WORK path remain unchanged. Current package-manifest.json:
701e0ab147320934f33494bd0ee641ae33b623b5933a46df96e5550782b19a90

The current package contains run_generation.py, save_reload.tcl, compare_memory.py, actual Work11 saved/nested/SOPCINFO/wrapper evidence, exact execution bindings, unapproved review template, tests, and REVIEW.md with exact commands. Full checker covers 3,016 saved module parameters/31,812 serialized XML atoms, generated hierarchy metadata/connections/interfaces and both MSA full parameter-and-connection/port maps. Generation-only paths/UUIDs/timestamps remain itemized, not broadly normalized.

12 inert tests passed locally and remotely. All 419 live dependency hashes, full SOURCE/PIM inventories and package bytes verified. The actual remote --preflight rejected the absent independent review before scratch/log/claim creation. No vendor tool was launched. Final readback: final-verification-02.json and remote-readback/generation-package02-receipt.json.

## Remaining technical boundary

Independent specification/quality execution review of candidate02 is required; no current authorization was issued. The narrow qsys-script save/reload plus standalone qsys-generate synthesis invocation is source/help-grounded but not yet natively exercised. Strict saved comparison may stop on generation metadata; preserve and inspect that actual delta rather than relaxing it. Local tclsh was unavailable, so no separate local Tcl interpreter test is claimed. Python tests do not establish native Tcl/tool acceptance.

No WORK/run/claim was created; source constraints, failed-timing Work11 completion, readiness/timing/constraint/functional false, Query04 prohibition and DDR-simulation skip remain unchanged. No full compile, hardware action, install, permission change, commit or push. Procedural lessons on historical manifest supersession and scoped XML comparison were appended to the active source-bound-vendor-tool-gates skill.
