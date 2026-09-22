# Disposition of Work13's three native metadata changes

Preparation attempt01 rejected before creating Work14 or copying candidate files. Preserve its result and both inventories. No SOURCE, Work13 or persona file was changed and no vendor tool ran.

The finite [metadata02 collection](metadata02.json) supplied actual bytes for Work13 and comparison Work12 files. All three Work12 copies exactly match Work13's **pre-compile** issued inventory hashes, giving a byte-bound before state rather than a guessed reconstruction. One lookup failure (SOURCE `fme_id.mif` at the project root) is retained; that path was not used as evidence.

## Exact differences

- `syn/board/ia840f/syn_top/build_env_db.txt`: only `FME_IFC_ID` changes from `f833fdf5-533f-5f77-80c9-f0a5c2f065df` to `c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`.
- `syn/board/ia840f/syn_top/fme_id.mif`: only UUID words 02 and 03 change to the same c281e23b interface ID. All other MIF fields remain equal.
- `syn/board/ia840f/syn_top/ofs_top.qpf`: generated creation date changes and the same two project revisions exchange order. No revision added or removed; native compile explicitly selects `-c ofs_top`.

The FME change is already recorded in [Work13's compile review](../fim-build-13/compile-result-review-01.md), section Check 3. The source hook `ofs-common/scripts/common/syn/ofs_post_module_script_fim.tcl:70–83` invokes `update_fme_ifc_id.py` after fitting, then updates the MIF database. The Python script `:60–75,119–143` **replaces**, rather than retaining conditionally, the interface UUID in `build_env_db.txt`, `fme-ifc-id.txt` and `fme_id.mif`. This is ordinary file generation; no device access. These hook/source hashes must remain bound to the existing SOURCE inventory.

## Work14 preparation disposition

Accept exactly these three measured post-compile metadata states as copy inputs; pin both original and current hashes. Do not widen this to arbitrary generated-file drift. Work14 may inherit W13's current metadata as initial inputs; its own native fit must regenerate the interface identity. It is not legitimate to claim that the old W13 persona will remain PR-compatible or that the old UUID identifies Work14 or live hardware.

Copy only the 5424 named pre-compile input entries. Their inventory contains no qdb/db/output_files/incremental_db members, so no compiled database or programming image needs copying or binary rewriting. Preserve all Work13 files; relocate only exact Work13 text-root references and its two absolute symlinks. Apply the three separate candidate overlays (UART file and two gate-path retargets). SOURCE remains untouched until integration; no authorization is issued by preparing this candidate.

Metadata JSON SHA256: `d2696d1a43cc082a277a9b67f7583fad8f68b23d55c1122af9d28ce9bd26eaeb`.
Gzip SHA256: `85533ac9dd00ebe61fdb1d416c7b3c8e3372e601fa41e5f12294fe81aacdbb4f`.
The follow-up preparation verifies the preserved failed-attempt directory contains exactly its three retained evidence files before creating anything else, and refuses any existing Work14 tree. There is no deletion or blind rerun.
