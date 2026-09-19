# Query02 preparation — parent review required, NOT LAUNCHED

Remote root: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-08/pcie-postfit-query-02`. All remote operations used session `ia840f_mailbox_monitored_01`, owned window `query02_prepare`, pane `%357`; verified Agilex7Workstation UID1000.

## Concrete preparation

- Copied the entire completed Work08 tree (syn, src, ipss, ofs-common, tools and project/database) plus complete PIM into exclusive query02 scratch. No original writes. Full Work08 before/after hash/link inventories compare equal and remain remote as work08-before.json/work08-after.json.
- 87 explicit text/path or symlink relocations recorded. No broken scratch symlinks. All source Tcl files reported missing by query01 and all six explicit BMC prerequisite files now exist in their source-defined locations. Native closure acceptance remains NOT_RUN, not proven by these static checks.
- Bound 8,027 files, link targets, target AGFB027R25A2E2V, exact query script, launcher/executable/qenv hashes, copied database and full prelaunch inventory in candidate.json. Database binaries were copied unchanged, not path-edited.
- Only the copied experimental Python dispatcher gets an exact query02-cwd branch into copied ia840f_query02_gate.py. Existing QSF gate and build_gate.tcl remain active; no maintained SOURCE or Work09 gate/dispatch changes. Other copied guard branches remain present.
- Candidate remains approved=false, ready_for_build=false. No authorization.json was issued. Parent must review the query-specific policy extension before issuing authorization bound to candidate.json SHA256.
- `run-query.py` is a concrete bounded 80-second runner, with full prelaunch binding validation, exclusive claim/log creation, native return-code preservation. It was exercised only with missing authorization: rejected rc1 before claim/log or vendor invocation. The copied actual experimental-gate entry also rejected missing authorization rc1.
- Callback validation checks executable, exact argv and cwd against the record plus immutable input hashes; pre-existing output logs/reports and QPF are excluded only from callback hash checks, not full prelaunch validation. Parent review should check this distinction and runtime assumptions before approval. No positive authorized runtime fixture/native acceptance is claimed.

## Exact intended query context

Cwd: `query02/scratch/syn/board/ia840f/syn_top` under the full remote root above.

Launcher argv: `/opt/altera/26.1.1/quartus/bin/quartus_sta -t <remote-root>/query.tcl`.
Runtime executable: `/opt/altera/26.1.1/quartus/linux64/quartus_sta`; runtime argv[0] is `quartus_sta`, derived from installed launcher CMD_NAME=basename, eval exec and qenv PATH. Native confirmation remains pending, and mismatch fails closed. Launcher and qenv source snapshots are included; optional qtb.sh does not exist.

Read-only analysis requests open the copied ofs_top project, load default post-fit timing netlist and existing SDC, enumerate matching divider/TRS/oscillator cell types and pins, and report matching clock period/master/divide_by/targets/master_clock_pin. No corrective SDC, new clock, false path, build or hardware action. Exact input fanin follow-up is not yet implemented in this query. Actual ~100.71 MHz CSR master and vendor divide-by-two remain the hypothesis; clock_div2 versus clock_div2x/~div_reg is unresolved until a native result.

## Evidence

13 final remote artifacts exported and envelope SHA256 verified locally: `07cd04aad007bb6870e08ae251ed32ff91d8f7e9c61c20d54c45016dcef4b4c8`. Includes candidate, query/runner, both guards, dependency/relocation records, missing-auth tests, result and launcher/qenv/BMC source evidence. Preparation scripts are local in this directory. Query01 attempt and Work08 preserved; Work09 untouched.

Status: **PREPARED_UNREVIEWED_NOT_LAUNCHED**. Parent short review and explicit authorization record are still required. No fitted-netlist result or clock/TRS conclusion has been obtained.
