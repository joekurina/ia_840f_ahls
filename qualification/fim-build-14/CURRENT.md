# Work14 current checkpoint — native compile running

**Native compile RUNNING at the verified launch snapshot.** Independent spec PASS, quality APPROVED and [parent package acceptance](COMPILE-PACKAGE-ACCEPTANCE.md) are complete. Authorization was issued/read back and the reviewed runner launched once. [Actual launch and process evidence](RUNNING.md). Hardware goal remains incomplete.

## Completed

- UART-only source correction independently accepted and published: `93f1906ffe5f3a84a94f9972ea5d5ee36a8f94f7`, read back from `origin main`. [Acceptance](../dfl-uart-fix-02/ACCEPTANCE.md).
- [Attempt01](prepare-readback01/preparation-result01.json) stopped before Work14 creation on exactly three native metadata changes. [Byte-bound disposition](METADATA-DISPOSITION.md); failed evidence preserved.
- [Attempt02](prepare-readback02/preparation-result02.json) prepared Work14 in owned tmux @21/%21. Copied 5424 recorded inputs, no db/qdb/output_files/incremental_db. Exactly two absolute symlink retargets and three candidate overlays; no generated text-root relocation was needed. Original recorded W13 inputs, SOURCE and PIM unchanged by that copy. W13/persona artifacts were not modified or rebuilt.
- [Compile preparation03](compile-readback03/compile-preparation03/result.json) in @22/%22 integrated exactly the UART RTL and two compile-gate path retargets into remote SOURCE, with originals backed up. Entire before/after SOURCE inventory delta verified exactly three; PIM unchanged. Local maintained gate files are now byte-identical to the package. Their unchanged tracked baseline was Work08, not remote Work13; [inspection](local-gate-sync-inspection01.json) proved only three path literals differed, and [sync result](local-gate-sync-result01.json) records exact package hashes plus AST/diff-check PASS.
- Four **actual inert rejections** passed: fresh-WORK dispatcher, native top guard, native child guard and Tcl helper. All returned rc1 for the expected missing successor authorization; no vendor tool, native log, native claim or run directory was created. Source/work inventories unchanged by these tests.
- Existing issuer's **real nonconsuming preflight PASS** against actual remote SOURCE/WORK/PIM/tools/dependencies and 135 exact native contexts. All draft approval/readiness flags remain false. Runtime permissions are compile-only, not device access.

## Exact review package

Authoritative local readback: `compile-readback03/compile-candidate-01/`.
The earlier `compile-candidate-01/` directory is the initial four-file mechanical-retarget draft, not the completed review package.

Manifest: `compile-readback03/compile-candidate-01/review-package-sha256.json` — 14 files, SHA256 `d6323f8f243d1fceefb233680fa851a25676889b761348b0760de23b3602dc8b`.
All 14 members and all 24 exported files were size/hash verified after retrieval.

Preparation03 JSON SHA256 `9b0ae78dd49c8606b806f814b4f8296d7cb8ce148c5e47236c49e02565035c40`; gzip `f8b06a339cfa488af9a68ad390ba4443541c8da16024a70649e60713bcdefb25`.
Preparation02 JSON SHA256 `dd4d778d24bd55ddd6650481524e9d5220afae46be440202f4c6852c92c8728a`; gzip `a57d07104dc11653ebe48612e9962ea25bc32a75d447ed8c426c74751925862f`.

## Remaining critical path

The issued authorization is `42cb4974f9e6aba80aa25e5df385de1faac09251dd6695123448d0db931127be`; native compilation started 2026-09-21 21:34:56 PDT in @23/%23. Preserve consumed records and monitor the existing run; do not reissue or relaunch. Review actual synthesis/fit/STA/assembly results separately. DDR simulation and dummy-CSR exercising remain excluded. No new timing experiment is bundled. The preparation-time statements above are historical receipts, not current unconsumed-state claims.

Joe has explicitly authorized flashing and host reboot after the build is ready. Those permissions are no longer an unanswered question. The compile package does not perform either operation. Matching image/host/backend identity, a source-supported finite procedure and verified independent host recovery remain prerequisites to potentially host-stranding deployment/access. No speculative MMIO, blind PR/reset retry or withdrawn bare-RPD recipe is permitted. Timing and the complete DDR/transfer/AHLS/sustained/boot qualification remain unperformed for Work14.
