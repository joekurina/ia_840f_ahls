# Bounded Work08 post-fit query attempt

## Result: blocked before fitted-netlist creation

Executed Quartus 26.1.1 `quartus_sta -t query.tcl` on a fresh copied project/database, using the unmodified copied source-bound guard. Native return code **3**. The guard rejected `unapproved checkout location`; the script explicitly stopped on the guard-result variable before `create_timing_netlist`, because Quartus downgraded the guard Tcl error to Critical Warning 125091. **No fitted PCIe pin/master/division result, no TRS absence result, and no corrective SDC acceptance were obtained.** Do not interpret the absence of resource output as resource absence.

Remote evidence root: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-01`. Owned tmux window `pcie_postfit_query`, pane `%356`, session `ia840f_mailbox_monitored_01`; host Agilex7Workstation, UID1000. Actual query ran 20:55:26–20:55:27 workstation time. Exact argv/cwd and launcher/script hashes are in `query-binding.json`; this is an invocation record, **not an accepted new authorization by the existing guard**. Existing gate was neither modified nor bypassed.

## Preservation and evidence

`before.json` and `after.json` verify identical SHA256 inventories of **2,398 regular, nonsymlink files** under original Work08 `syn/board/ia840f/syn_top`, including completed database and reports. Other original sources were only read/copied. No maintained source, Work09 binding, SDC or original project file was edited. No rebuild, simulation, hardware/driver action, install, permission change, commit or push.

Nine exact remote artifacts exported through unique tmux buffer and SHA256-verified locally: `sta-help.log`, `api-help2.log`, `atoms-help.log`, `query.tcl`, `query-binding.json`, `query.log`, `before.json`, `after.json`, `result.json`. Envelope SHA256 `ee9dfeeadadefeaaa737de6cd59c2107095f2d82f97bb2cb7a534609b48467ea`. `evidence.json` retains texts and individual hashes. Local Python drivers/captures document execution.

## Supported installed APIs / next retry

`api-help2.log` establishes `project_open -revision ofs_top ofs_top`, `create_timing_netlist` (post-fit default), `read_sdc`, `update_timing_netlist`, `get_cells -hierarchical *`, `get_cell_info -in_pin_names/-out_pin_names/-wysiwyg_type`, `get_pin_info`, `get_clock_info -master_clock/-master_clock_pin/-period/-divide_by/-targets`, and `get_fanins -stop_at_clocks`. `project_open` exposes no documented read-settings-off option here. Help must be printed as `puts [help command]`; the initial `help -long command` was incorrect and did not establish command support. `read_atom_netlist` is not an available help command after loading atoms in this executable; do not invent it as a standalone database import route.

A supported fresh-query gate dispatch/context still needs implementation and technical review; recording a JSON binding alone does not authorize it. The scratch copy intentionally included project/db, setup and guard implementation only, so project opening also reports missing referenced shared_config, IP/source Tcl and BMC files. A successful next attempt must provide the complete preserved project dependency layout (not suppress those diagnostics), use a new exclusive scratch, and bind the exact query context without altering Work09/compile contexts. This attempt stops at the explicit guard failure, not at an alleged database incompatibility.

Candidate remains the previous `../pcie-clock-review-01/candidate.sdc.disabled`: vendor-evidenced divide-by-2, inherited actual CSR PLL master (~100.71 MHz), **not nominal 100 MHz**. Exact `clock_div2` versus fitted `clock_div2x` versus STA `~div_reg` target is still unresolved. No wildcard-generated corrective clock or speculative false path was applied. The present query is only a first bounded resource/clock inventory; follow-up exact input fanin and division-property interrogation and candidate reanalysis remain required after it can load the complete netlist.
