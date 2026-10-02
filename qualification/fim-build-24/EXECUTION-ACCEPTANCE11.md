# Work24 — execution package accepted and launched

## Accepted gate

Independent SPEC and execution QUALITY accepted the exact EMIF1 **CLOCK_SPINE2** experiment with explicit unchanged full CLOCK_REGION, seed3 retained and unchanged timing/interface requirements. Parent verified all32 source-package and39 execution-package bindings and consumed both actual reports. This acceptance covers the prepared package, one-time admission and observed native launch only—not synthesis, fitting, timing, persona or hardware acceptance.

- SPEC report SHA256: `272cd79af59bb96cfb235de54c349aa036d5ed826c43b5c1d6f381e8c9dd9ca6`.
- QUALITY report SHA256: `90715b79ae77a52779834f2a59eaef7561c1d7d0a765f977670d5eaaa46a06ee`.
- Admission script SHA256: `564093c3435adb01373fdc7da77d9e79a363d91ae3460405f031d1231c414d2d`.
- Admitted manifest SHA256: `99820e60694b59639a5f542f0a8b70320015462a8d9d74c4a3fb103a6d2e480f`.

See [SPEC](review-spec02.md), [SPEC consumption](spec-consumed03.json), [QUALITY](review-quality04.md), [QUALITY consumption](quality-consumed05.json), [iteration basis](ITERATION-BASIS01.md) and [exact delta check](source-delta-check01.json).

## Fresh admission

The parent first rehashed Work23's four image/intermediate artifacts plus its static QDB against the preparation-payload identities. Admission then checked live host/UID/owned tmux, CPU affinity/QSF36, resource/license prerequisites, absence of consumed state and competing native processes, every bound input/tool/prerequisite/link, both pinned inventories and their1891 SOURCE/PIM/3963 Work23 input entries. The source/inventory pinning is enforced inside the reviewed admission program, not left solely to the caller.

The admitted manifest and all four review/consumption files were read back byte-for-byte before launch. Only the four reviewed metadata fields changed from the draft: approval, review prerequisites, authority basis and validation scope. No physical input changed during admission. Live headroom at admission was125409067008 available-memory bytes and1215844818944 free-disk bytes, affinity0–35. [Admission collection](admission06-collection.json); [admitted manifest](compile-inputs.admitted05.json).

## Actual launch

- Launched once at `2026-10-02T00:25:22.417305+00:00`; runner started at `2026-10-02T00:25:23.675417+00:00`.
- Host/session: Agilex7Workstation / `ia840f_mailbox_monitored_01`; compile window/pane **@208 / %208**.
- Runner: PID319225, start ticks44983084, `/usr/bin/python3.9`; exact invoked arguments recorded in [dispatch](compile07-dispatch.json).
- Flow: PID319240/start44983187, `/opt/altera/26.1.1/quartus/linux64/quartus_sh --flow compile ofs_top -c ofs_top`.
- Initial synthesis: PID319273/start44984190, matching the admitted `--ipc_flow=17 --ipc_mode --read_settings_files=on --write_settings_files=off` context.
- Parent checked native executable hashes, exact cwd/argv and supervisor-owned ancestry from the live startup capture. The internal `--ipc_sh` helper is separately observed, not promoted into another gated task context.
- One event-driven completion waiter: `proc_e3992c204812`; no duplicate build/waiter or retry. [Live identity receipt](execution-live10.json); [waiter](compile-waiter08.json).

The existing CMake-native supervisor retains10800s compile/120s configure deadlines,36-CPU affinity,64GiB per-process address-space limit, late gate rejection checks and owned-group termination handling. This is not an OS sandbox or aggregate memory cap.

## Result remains pending

Initial IP-generation policy reused the qualified generated files and reported zero errors/warnings; synthesis was active at the first captures. Those observations do not establish CLOCK_SPINE consumption or timing improvement. Require completed Fitter source/spine/region/ownership readback, both CPA COMP roles, exact bit243 all-corner no-exception checks and collateral DDR/PCIe/PR/clock gates. PCIe spine2 overlap remains an experimental risk; no index sweep, timing waiver or programming follows automatically.

Raw transport archives, complete logs, generated/vendor files and databases remain local. All existing failed images remain unprogrammed. Runtime status is maintained separately in [CURRENT.md](CURRENT.md); it is not an immutable result-acceptance receipt.
