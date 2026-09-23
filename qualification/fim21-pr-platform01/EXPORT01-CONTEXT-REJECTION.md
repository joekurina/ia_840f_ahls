# PR export01 — retained runtime-context rejection

Version check native0 confirmed Quartus25.1.0 Build129 SC Pro. `--prepare` and archive project-open callbacks passed. Installed archive discovery selected DNI analysis/elaboration and invoked the exact runtime command below, absent from the first finite context table:

```
quartus_syn --ipc_flow=4 --ipc_mode --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu --dni --disable_all_banners --analysis_and_elaboration --dni
```

The source-bound callback rejected it. Supervisor terminated only the owned release process group; native release leader−15, outer143, no timeout and no remaining owned group. No completed archive/release is claimed. All four preservation domains true, postflight errors empty. Archive SHA256`8c6fc0923a8f7efdecf8f2605b6db2a9ec9d07b332f6ea2ec06ad3ff6e026542`; six payloads verified. [Receipt](outer-export01.json), [exact rejection](artifacts-export01/run/gate-rejections.jsonl).

Installed qpm-ccl-lib.tcl824–855 requests source-discovery A&E with disable-all-banners and conditionally adds DNI. Native receipt supplies the concrete IPC4 and duplicate DNI serialization; preserve that literal instead of normalizing options or granting arbitrary IPC/compile flags. Successor uses fresh base02/export02/release02 roots and this exact observed command. No RTL/clock/pin/QDB change is indicated. Original failed candidate and evidence remain unchanged.
