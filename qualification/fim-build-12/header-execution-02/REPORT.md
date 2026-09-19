# Work12 header execution 02 — native completed; result acceptance pending

## Outcome

Executed the reviewed header issuer and native header runner exactly once on Agilex7Workstation UID1000, using fresh owned windows in `ia840f_mailbox_monitored_01`. Issuer exit **0**, native Quartus exit **0**, outer runner exit **0**. Native log reports **0 errors, 0 warnings**, elapsed **00:02:45**. All eight required outputs were absent immediately before execution and are fresh/nonempty afterward. No gate rejection, diagnostic 125091, Critical Warning or collection error was reported. Native result acceptance flag is the runner's mechanical check, **not independent header acceptance**. `result_review_required=true`, `ready_for_build=false`, `compile_authorized=false` remain in actual results.

## Actual-output findings requiring result review

- **ASP preset is malformed XML:** Python ElementTree rejects `ofs_ip_cfg_local_mem_asp.qprs` at line 22, column 2 (`mismatched tag`). The file opens `<presets>` but closes the enclosing element with `</preset>`. Preserved unchanged; no workaround or rerun.
- `ofs_ip_cfg_local_mem.vh` contains only its include guard and `OFS_FIM_IP_CFG_LOCAL_MEM_ENTITY mem_ss`; it emits no channel/geometry configuration macros. Do not infer downstream completeness from the nonempty/fresh check. Independent review must determine applicability of this sparse export to the maintained consumers.
- Actual wrapper/package/interface macros agree on NUM_PORTS=2; AXI read/write data 512 bits, address 34, ID 9, address-user 14, strobe 64. DDR4 exposes A17, DQ64, DQS8, BA2, BG2, one CS per port. Both channel clock/reset/status and subsystem cold/warm-reset signals are connected in `mem_ss_sv.sv`.
- Saved corrected `mem_ss.ip` remains unchanged in the complete WORK inventory comparison. Its two NUM_BANK_FIFOS parameters remain 0 and two NUM_COPIES parameters remain 1. ASP's textual parameters report two AXI channels, 512-bit data and 34-bit address, but the XML is not parseable.
- Actual aggregate header includes memory interface, IP-parameter and local-memory headers alongside PCIe/sys-PLL headers. Actual include Tcl selects `ipss/mem/qip/mem_ss/sv_wrapper` and its package before wrapper. Native log selects corrected `ipss/mem/qip/mem_ss/mem_ss.ip` and freshly generates memory wrapper/configuration. Only PCIe and sys-PLL wrappers were reported already up to date; their complete WORK entries remain unchanged. No stale-memory skip occurred.
- Existing maintained `mem_ss_top.sv` includes the aggregate header and uses the generated memory interfaces/wrapper. PIM full inventory was verified unchanged before/after. No compile/elaboration or PIM functional validation was attempted.

## Preservation and consumed review bindings

Recomputed candidate 77-file set / 76 payload hashes and both actual review hashes before consumption. Verified live old 77-file package against captured original mapping and original manifest SHA256, absent issuance/run/authorization/compile/backup paths, full SOURCE/PIM/dependencies/tools/WORK and eight absent outputs. Exclusively backed up all 77 original package files to remote `header-correction-02-original-package/` and hash-verified before overlay. Original archive/spec files were absent at the remote package root (backup extra mapping is empty); local originals remain untouched.

Only runner, draft and manifest were overlaid, manifest last; full successor readback and exact three-file delta verified, with SOURCE/WORK unchanged by overlay. The unchanged issuer then integrated exactly experimental gate, compile gate and new header gate into SOURCE. Existing two gate files are backed up; the third was previously absent. The receipt records this explicitly and contains full post-integration SOURCE inventory. SOURCE QSF remains `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c`.

- Successor manifest: `ed1422e5dfc4acfddace312cfe5ab35c5575ab3dc43fcf6730a4df50d1a7c6e9`
- Specification report: `92456ef5bd6814c9d5001a951a40c1fa51ca24afd4c8c35eec4b2842cf35c0a0`
- Quality report: `dcc90dc88752de6fd56b5dceb0d0012a06c8b570cce810c018a50bb5b5c05058`
- Issued authorization: `c4da8cf0ba16e8a201574b68fce9c1e54658dbeda2511bf71827e351c6f8cc30`

Reviews were consumed in `header-execution-02/consumed-reviews.json`, binding both exact package mappings, report hashes, explicit parent acceptance and false execution/readiness/compile-result claims. Issued authorization intentionally enables only the header experiment. The retained exclusive issuance/run claims must never be reused.

## Native invocation and changes

```sh
# cwd /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12/syn/board/ia840f/syn_top
python3 -B /home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/run_headers.py
# exact native child
/opt/altera/26.1.1/quartus/bin/quartus_sh -t /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12/ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl --project=ofs_top --revision=ofs_top
```

Runner sets explicit reviewed 26.1.1 bin and sopc_builder/bin PATH, WORK OFS_ROOTDIR, PIM and all three license variables from the installed instructions. Normal-account permissions; no OS sandbox claim.

Complete postheader inventory has **14 changed/new paths**, recorded with before/after hashes in retrieved `postflight.json`: eight required outputs, memory wrapper log, configuration README, PCIe config header, WORK QSF, WORK QSF backup and QDB db_info. No other WORK entries changed. Native project opening migrated maximum-placement optimization to HIGH PERFORMANCE EFFORT plus GLOBAL_PLACEMENT_EFFORT MAXIMUM EFFORT and updated LAST_QUARTUS_VERSION. `native-qsf.diff` preserves exact delta. Hold ON and seed 2 remain; no operator QSF edits. Full SOURCE/PIM/dependencies/tools verified again after native completion. No Work04/Work11/standalone generation writes were performed; their bound dependencies remain verified, without claiming a new exhaustive inventory of every unrelated tree.

## Verified evidence

37 actual evidence/output files transferred through a unique owned-tmux buffer; compressed transfer SHA256 `b8b7f687d75860ce8b357e44accc432a46666c59db5aff315b6bf01dbdf23ae6`, 766036 bytes. Every member size/SHA256 verified locally. `transfer-verification.json` lists each artifact; `retrieved/` contains actual files including native checkpoint/result/log, full postheader WORK inventory, authorization, reviews, source backup/integration and package backup/overlay receipts. No synthesized vendor output.

### Eight required outputs

| WORK-relative path | Bytes | mtime_ns | SHA256 |
|---|---:|---:|---|
| `ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_sv.sv` | 9139 | 1789815706292596191 | `5da695996ab296ff0a1b643a18a76cfbdd74055d47538ecdc9ed4a974df4a38e` |
| `ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_param_pkg.sv` | 113 | 1789815706296596205 | `25908195980bb69b085f2ae004b490a7e6fe38dd04fe6e4779db46b321d65aa7` |
| `ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_if_info.vh` | 4703 | 1789815706298596212 | `901fa97b882f41c7aa7ae2278a47134b5972ed04df1023fca0ca3838b40a80d1` |
| `ipss/mem/qip/mem_ss/sv_wrapper/mem_ss_ip_params.vh` | 566 | 1789815706301596223 | `04440c2eca2ad57ed1997b75d562f7cd194cec354d267a34ebd42de140f42c07` |
| `syn/board/ia840f/syn_top/ofs_ip_cfg_db/ip_gen_sv_wrapper_inc.tcl` | 1078 | 1789815751507757622 | `bcb09ea6a1994a6e89699b1107afa4cc3c26816513ff041edf66f9fbc9e6e84e` |
| `syn/board/ia840f/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_db.vh` | 485 | 1789815751507757622 | `cc0a7eb7c0538185d6e15db040d9f918d482951e079208421d004ac02fa9e937` |
| `syn/board/ia840f/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_local_mem.vh` | 313 | 1789815738857712458 | `7d3afe01cbf131889cbac70de33e4d3d7d8e79c4aadd94f19c243a338df8814d` |
| `syn/board/ia840f/syn_top/ofs_ip_cfg_db/ofs_ip_cfg_local_mem_asp.qprs` | 874 | 1789815750794755076 | `d7fe1da7a427568ba5766da8268e1f8e2fac24442df56928ba9ebaead5d7cce7` |

## Issues and limits

The initial package transport hit OS argument length before its Python payload started; `stage.log` retains that failure. Switched only transport to tmux-buffer Python stdin, reran all live unconsumed/preflight checks, then performed the sole overlay/issuer/native attempt. No consumed vendor attempt was retried.

Do not issue the compile fixture, fresh compile authorization or accept headers solely from exit zero. Independent actual-result review must assess malformed ASP XML and sparse local-memory configuration first, then any separately reviewed postheader compile binding. No Query04/equivalent, DDR simulation, hardware, installs, permission changes, commits or full compile. Timing, calibration association, constraint completeness and functional readiness remain unresolved.
