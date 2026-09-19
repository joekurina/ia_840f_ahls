# Work12 once-only compile — verified running handoff

## Outcome at 2026-09-19 11:43:01 UTC

**Native full compile launched exactly once and remains running, in synthesis.** Issuer ran once, rc0; runner/native final return codes are pending. IP Generation and its post-module hook completed with 0 errors / 0 warnings. Actual live Quartus flow and synthesis executable/argv/cwd/hash contexts and ancestry were verified, not merely launcher status. Captured native log and available stage report contain no detected Error/Fatal diagnostics, rejection markers or Critical Warning 125091. No read errors occurred in the final check.

All readiness, functional, timing, constraint-completeness and calibration-association qualification remain **false**. The AFU is the default standard exerciser, not AHLS functionality. This is launch verification, not compile/timing acceptance.

## Remote locations and persistent ownership

Host `uwb_student00@100.101.227.97`, verified `Agilex7Workstation`, UID1000.

- B: `/home/uwb_student00/ahls/new_BSP`
- E: `B/qualification/fim-build-12`
- Candidate: `E/compile-candidate-01`
- Execution evidence: `E/compile-execution-01`
- SOURCE: `B/ofs-agx7-pcie-attach`
- WORK: `B/work_ia840f_fim_12`
- Project/stage reports: `WORK/syn/board/ia840f/syn_top/output_files`
- Authorization: `E/compile-authorization.json`
- Native claim: `E/native-compile.claim.json`
- Consumed reviews: `E/compile-candidate-01/consumed-reviews.json`
- Issuance lock: `E/compile-candidate-01/authorization-issuance.lock` (retained)
- Native status/log/invocation: `E/run/status.json`, `E/run/native.log`, `E/run/invocation.json`
- Completion checkpoint when finished: `E/run/native-status.json`
- Outer command/log/completion: `E/compile-execution-01/runner-command.json`, `runner.log`, and eventual `runner-returncode.json`

Owned session: `ia840f_mailbox_monitored_01`. Persistent launch window **`@483`**, name **`w12ce01-launch`**, pane **`%483`**. Fresh ancillary windows: preflight `@481/%481`, issuer `@482/%482`, snapshot `@484/%484`, final check `@485/%485`. Existing panes were not modified. The runner is a child of the persistent tmux window, not the local agent/SSH connection; it has no watchdog. Do not resend the launch command or recreate claims. Ancillary windows retain their outputs with a sleep after completion.

Caveat: snapshot-01's untargeted `tmux display-message` returned the session's active window `@326/%326`, not the inspection window. This is a metadata-only ambiguity; final check uses `TMUX_PANE` (`%485`) and explicitly targets `%483`, confirming the launch window/session. Transport creation receipts identify all owned windows.

## Verified process identities

| Role | PID | Start ticks | Executable |
|---|---:|---:|---|
| Reviewed runner | 176866 | 10610226 | `/usr/bin/python3.9` |
| Claimed native entry | 176868 | 10610365 | `/usr/bin/bash` |
| Quartus full flow | 176885 | 10610686 | `/opt/altera/26.1.1/quartus/linux64/quartus_sh` |
| Active synthesis | 176918 | 10611622 | `/opt/altera/26.1.1/quartus/linux64/quartus_syn` |

Runner argv: `python3 -B /home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/compile-candidate-01/launch_native_compile.py`, cwd SOURCE.

Claimed native argv is `/bin/bash` followed by exactly:

```sh
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12
```

Native cwd is SOURCE. Flow argv: `quartus_sh --flow compile ofs_top -c ofs_top`. Synthesis argv: `quartus_syn --ipc_flow=17 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_top`; both cwd the WORK project. Verified ancestry: synthesis 176918 → flow 176885 → gated monitor 176884 → native compile shell 176876 → claimed entry 176868 → runner 176866 → persistent wrapper 176865 → tmux shell 176839 → tmux server 7828. Complete executable/argv/cwd/start-tick and ancestry evidence is archived.

## Review consumption, preflight and preservation

Both complete accepted reports were read, locally rehashed, exclusively transferred outside the frozen candidate and remotely read back before constructing the README-schema envelope with both exact 62-payload mappings and explicit parent acceptance. Quality links the exact spec hash. Fresh full issuer preflight passed SOURCE1361/PIM530/WORK5277/dependencies471/contexts135 and all 63 package files; authorization, native claim, run, issuance lock and consumption were absent.

Exact issuer CLI, invoked once separately from launch:

```sh
python3 -B /home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/compile-candidate-01/issue_authorization.py /home/uwb_student00/ahls/new_BSP/qualification/fim-build-12/compile-execution-01/parent-envelope.json
```

Issued record readback exactly equals the draft with only the reviewed approval/consumption fields and six dependency pins added. Ready/qualification flags remain false. A separate full SOURCE/PIM/WORK/dependency comparison passed immediately before invoking the reviewed runner. The runner retains its exact 26.1.1/sopc_builder PATH, three license variables and cleared overrides.

Postlaunch full maintained SOURCE/PIM inventories and all 62 frozen payload hashes remain unchanged. No source integration, WORK recreation, operator live-file edits, header replay, Query04, DDR simulation, hardware operation, installation, permission change or commit occurred. Native build outputs/logs are expected to evolve; postlaunch WORK equality is not claimed or imposed. Seed2, hold ON, maximum placement, FIFO0/copies1 and accepted clocks/SDC/geometry/PF/BAR/pins/calibration constraints were not altered. Sparse header and malformed unused ASP collateral were not repaired. Work08 docstring remains frozen.

## Readback-verified hashes

| Evidence | SHA256 |
|---|---|
| Spec report | `aa822df551a0a302e679e7bbe546d92a774d92fb26d667571d4a48cdf519ecf7` |
| Quality report | `f738066a1ab12d777cef3864a50b27aa51a7046c07b292f67bf1020faab62f46` |
| Frozen manifest | `15687a2e812b78101246a66a57edc8e5991ef596a361d4de46e898afc8cc4836` |
| Draft | `2dac6b722902eb5c141107f8f93b550f72b298f49d1b31f960acbb6c9493d5ea` |
| Issuer | `c831dd5d99b7e795d3032e3a27ea33a8e847d7ee6d297c5fad4faaa1d2ca9752` |
| Runner | `80bb3835eb77f15e0375c118c423ed57c1a2d2320620ecd150a0213d2e96664a` |
| Issued authorization | `ad16f23ca0e03041db913a5f2df45077f26fcdef15804b1c7d970f721bd256fb` |
| Envelope / consumed reviews | `20a20c58240e548f9956490247b449639ce0f6f27e20afca5d5e65f3470d553f` |
| Native claim | `b8c1d51cdd30a9412fddc686eddb3d4468d321941143198c82624ac0183e5d4f` |
| Running status snapshot | `981b7ecc2197cfd7bdfd48f11ca7cab37e94af595f3672d35f6c6ce79dc52f36` |
| Native invocation | `ed28003503acea1ba0720a63c81fc7babc92b8b9edf48cbe047eb4cc225d11f2` |
| Latest archived native log | `8c0671a407ccf42c08489314c1f127e27608d713033d9e0cc705713e6df63d9d` |
| IP Generation report | `00216ae9233774e5832db62b487d9bb78219f7cc29aa131c1a059c758fe09db9` |
| Final check | `53d9b33226577ee458d1ff68fbfa361bfc906a91d844c257b09245e741b40db4` |

## Local archive and follow-up

This directory contains operational scripts, exact tmux/SSH commands and return/output logs (`transport-*.jsonl`), window receipts and two separately verified transfers:

- `evidence-snapshot01.json`: 19 files, archive under `archive/`, each payload length and SHA checked against remotely computed bytes. Whole transfer SHA `cc0783c2e7fd0f506d9e97bd72595453f963b4970686f37e14f6f1ccf1e52c4c`.
- `evidence-finalcheck01.json`: 5 files, archive under `archive-finalcheck/`, independently checked. Whole transfer SHA `fe484ce0eaeb60f90ef9ac5c4c103bd16fe73c10e2cbb5686c9f23877c8ea8df`.
- `archive-verified-sha256.json` and `finalcheck-verified-sha256.json` enumerate every exact remote path/hash. Earlier and later snapshots are preserved separately, not overwritten.

**Parent follow-up is required:** monitor in fresh owned tmux windows; read native status/log and actual synthesis, fit, STA, assembly and flow reports. Buffered stdout may lag stage progress. On completion capture raw native and outer return codes plus all stage diagnostics, including gate markers/125091 even if native exits zero. Compare actual full STA against Work11. No automatic retry, gate weakening, claim rewrite or baseline restoration is permitted. No timing, calibration association, constraint completeness, functional acceptance or hardware readiness is established by this running handoff.
