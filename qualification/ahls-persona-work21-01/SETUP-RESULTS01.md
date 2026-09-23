# Native OPAE persona setup01

**Native/effective/outer 0; parent verified.** No Quartus project compilation was performed by setup01; only the version query and the installed `afu_synth_setup` file-generation flow ran. The separate synth01 stage performs real mapping.

- Exact platform release: `/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03`.
- Fresh destination: `/home/uwb_student00/ahls/new_BSP/work_ahls_persona_work21_01/setup01/persona`.
- Installed `/usr/bin/afu_synth_setup` and its actual `platmgr`/`packager` source and database dependencies were captured and hash-bound; no guessed `opae` module API was executed. The first ordinary source collection retained that namespace inventory, but inspection of the console entrypoints identified the real packages.
- Setup produced 4925 file paths. Original release, generated sources, copied AFU inputs and installed tool bindings remained unchanged; no timeout or live owned group remained.
- All 13 selected AFU RTL sources are byte-identical to guarded-PIM03. All 255 generated fabric/HLS files match its corrected candidate. No HLS regeneration, synthetic kernel substitution, or duplicate platform-source compilation.
- The diagnostic-only UUID header was deliberately omitted. The installed JSON manager generated the real candidate header from UUID **`673c03a1-cef3-4c82-bf10-b12c247d9718`**; this is distinct from the historical scalar AFU and is not a claim of deployment.
- Metadata uses the installed schema's `afu-top-interface.class = ofs_plat_afu`. The donor's `name` field was not blindly copied. Requested user-clock ceilings are `auto-200` high / `auto-100` low MHz; these are compile requests, not measured or programmed frequencies. `power: 0` is the inherited metadata placeholder, not a measured-power claim.
- `OPAE_PLATFORM_GEN` is absent. The installed setup tool emits `AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU`, the selected wrapper class, source QSF and UUID header. Explicit FPGA family `AGILEX` comes from the release's JSON; Quartus version comes from native 25.1.0 Build 129 output. This also avoids the installed automatic-discovery code's source-visible use of `CompletedProcess.wait()`; no installed package was modified.

[Receipt](outer-setup01.json), [native setup log](artifacts-setup01/setup.log), [generated source QSF](artifacts-setup01/persona/hw/afu.qsf), [UUID header](artifacts-setup01/persona/hw/afu_json_info.vh), [metadata](ia840f_ahls_memory.json).

Native synthesis uses a fresh full copy of this configured tree, a separately bound persona-only callback and the same static QDB. The original release callback is preserved, not replayed; its owner has ended. Only the copied PR QSF callback binding and two-CPU setting change. The next native result, not source inspection, establishes whether this composition maps successfully.
