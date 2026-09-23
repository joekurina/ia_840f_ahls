# Work21 PR/PIM export03 — native generation completed

**Native/effective/outer0. Parent verified; independent result review pending.**

Remote result: `/home/uwb_student00/ahls/new_BSP/work_fim21_pr_platform01/release03`.
Static input copy: sibling`base03`; immutable run evidence: sibling`export03`. Quartus25.1.0 Build129 SC Pro. Original Work21 was not rebuilt or changed. [Verified receipt](outer-export03.json), [parent verification](parent-export03-verification01.json), [path-set preservation](shape-preservation02.json).

## Progression, preserved

1. **export01:** callback rejected archive discovery's actual IPC4/DNI invocation. Release leader−15, outer143; owned group stopped, all preservation flags true. [Failure disposition](EXPORT01-CONTEXT-REJECTION.md).
2. **export02:** actual source-discovery A&E and vendor release script completed native0, but outer125 rejected missing Python callback dependencies and restoration attempts to load the unrelated base-FIM revision. Do not call this a successful release. [Failure disposition](EXPORT02-ARCHIVE-CLOSURE-FAILURE.md).
3. **export03:** added Python gate as a TEXT_FILE archive dependency and retained only`ofs_pr_afu` in the copied QPF. All native callbacks, including both restored-project openings, succeeded. Exact native DNI argv retained, including both`--dni` occurrences. Fresh roots and process ownership; no predecessor database reuse.

The existing vendor script performs prepare, archive/source-discovery A&E, restore, macro emission and PIM generation. Copy-only corrections use ownedTMPDIR, PR-only revision scope and additive release callbacks; original build-gate file remains unchanged. Generated XML changes relocate only existing source paths, not HDL or IP parameters. Remaining inactive XML references are explicitly recorded in source-delta; do not claim all metadata paths were made portable. Binary QDB bytes are unchanged. [Runner template](run-release03.py.in), [contexts](release-contexts03.json), [native source delta](artifacts-export03/run/source-delta.json).

## Verified result and limits

- Compressed result SHA256`6ec17215ca58ffd136418de08fb45ba1700a01887f84ea7b2d93afe06ad808b9`;9exported payloads verified against embedded sizes/hashes and local files.
- Release inventory4,936file paths, including file symlinks.15selected boundary files reread from exact remote release and hash-matched. Three release symlinks stay inside the release tree; no escapes.
- Copied rootQDB83,178,648bytes SHA256`7f8f25463afe3ae95d9660ddf4c5c6755d6704f828fd400de34ae38fa2aa0fc8`. SOF/MSF/PMSF match accepted Work21. `hw/blue_bits/ofs_top.sof` resolves to the same SOF. FME interface ID`fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e` matches the base, not a newly deployed persona.
- All original7,598Work21 entries retain byte/link identities; a subsequent path-set audit confirms no added/removed entries. PIM and tools unchanged. No timeouts, surviving owned groups or postflight errors.
- Native source-discovery Flow Status Successful. Partitioned DRC **0of10rules failed, zero violations/waivers**, including ResetRelease instance count. This is the empty release template plus imported static shell, **not the guarded persona's reset/CDC acceptance**.
- **73explicit warnings:**13461×1,24420×1,21610×70,23762×1. Keep unsupported/mixed pragma and parameter findings;70undriven outputs belong to the OPAE_PLATFORM_GEN template. No Critical Warning125091, missing-helper gate rejection or other detected Error/Fatal diagnostic in successful export03. Do not report warning-free.
- No`.done`file was emitted into this release inventory. Complete native receipts/reports and output bindings establish export completion; no marker is invented. No personaGBS or new programming image was produced.

## Next execution boundary

The generated PIM preserves host address-width51 in **line units**, with native PCIe-TLP and native-AXI local-memory classes; exact widths derive from the imported packages. This does not establish live IOVA/MMIO routing.

`afu_synth_setup`, `afu_json_mgr`, `afu_platform_config` and `packager` resolve to`/usr/bin`entrypoints; only path/entrypoint-byte identities were inspected, not their package/API compatibility. Next bind those installed packages and the accepted guarded AFU sources into a fresh persona build. **Do not inherit OPAE_PLATFORM_GEN=1** into the actual AFU compile. The copied release-only gate's owner is now terminated; a future persona run requires its own bounded native scope, not bypassing or replaying this authority.

Full-FIM signoff, mapped-path R1/R2, effective freeze/globaldrain/fences/bufferlifetime, PCIe/OPAE/DDR numerical/sustained hardware and durable boot remain open. No liveFPGA/MMIO/programming/driver/reset/reboot operations occurred. VendorDDRsimulation SKIPPED BY USER.
