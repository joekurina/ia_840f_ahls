# Independent publication review — three completed evidence milestones

## Binding and disposition

Reviewed only the finite manifest/receipts and necessary local supporting references. No hardware/remote access, application execution, builds, repository-state changes or acceptance transitions were performed. This report is the sole new file.

Manifest: `qualification/caps01-publication01/manifest01.json`
Exact SHA256: `5a27e74e93081125613f8e4d940b4b14e3fb6205ba29183f028b099f8efbbe11`

All **19 distinct allowlisted files** match their actual sizes and SHA256 values; all are readable UTF-8 text/JSON. Aggregate evidence size **141,001 bytes**, below the **2,000,000-byte** cap. The manifest itself is 4,265 bytes, outside that evidence subtotal.

| Manifest group | Files / bytes | Independent evidence disposition |
|---|---:|---|
| deployment | 5 / 19,324 | **ACCEPT — recorded Work21 flash boot only** |
| vf-setup | 4 / 55,405 | **ACCEPT — recorded per-boot VF configuration only** |
| readiness | 10 / 66,272 | **ACCEPT — bounded initialization/static-loader/reset-metadata evidence only** |

These are publication evidence verdicts, **not live AFU authorization** or new observations of the workstation.

## Claims checked

- **Deployment:** `program08-result.json` contains the actual JIC `PV` argv, erase/program/verify messages, native0, successful completion and zero errors/warnings. Its full native-log hash matches; `program08-outer-result.json` independently binds outer0 to the exact result. `activate10-result.json` records OFF then ON/native0 and restored cable readbacks 24M/1. The initial ON-command warning does not negate its subsequent ON result. `postboot12-result.json` embeds reboot receipts and reports new boot `598f7b27-1798-4a88-8a79-9e4a2659c64d`, cached FME interface UUID `fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`, root AER status `00000000` and restored masks `00100000`/`00002000`. Accept static identity after flash/activation, not AFU identity, functionality or an explanation of the earlier failure.
- **VF setup:** `create03-result.json` records autoprobe suppression, exactly one VF `0000:4f:00.2`, correct reverse PF and an unbound resulting driver. `bind04-result.json` records the vfio-pci override/init, native0, actual VFIO binding, singleton group76, character node UID/GID1000:1000 and decimal mode432 = 0660. Before/after PF and management-node preservation comparisons pass; the final PF snapshot restores autoprobe1. `reset-meta08` later corroborates unchanged bindings on that same boot. `preflight02` loaded/module build IDs and recorded SR-IOV callback ordering agree. Binding/permissions do not establish safe VFIO open or successful AFU access.
- **Readiness:** `emif-init03-result.json` records only the two init-done values1 on the same boot. Local hash-bound source and ELF attribute decoding corroborate bits0/1 and the single R64 feature+8 accessor. Eight cited RTL files match their recorded hashes and Work21 original inventory. The driver cal-fail shift8 disagrees with two-channel RTL shift2; those accessors were not used. Bridge default-enabled reporting is not measured reset state. `loader06` contains native0/inner success, no application/OPAE execution, ten objects/eight owned bindings and nineteen internally closed DT_NEEDED edges. Three objects retain trailing empty RUNPATH entries; their required interpretation is an empty read-only `/empty` CWD, not deletion of the search entry. `loader-capture05` preserves a failed inner diagnostic despite successful collection. `reset-meta08` reports literal `flr\n`, D0 and unchanged `disable_idle_d3=N`, with no reset/open/write. Local hash-verified VFIO disassembly corroborates RESET09's open reset attempt, conditional release reset and conditional—not unconditional—bus fallback. This establishes neither post-FLR AFU readiness nor reset safety.

## Publication findings and accompanying note

1. **No blocking payload/security finding in the allowlist.** Content inspection and pattern checks found no embedded ELF/image/base64 payload, private SDK source body, secret credential or raw agent transcript. Diagnostic kernel disassembly/build-ID text is not a complete embedded module. Host/user paths, board serial, boot IDs and topology remain visible operational metadata; this is not an anonymized package.
2. Both metadata projections exactly equal their locally retained originals after removing **only five `files[*].base64` fields each**. Original receipt sizes/hashes and all ten decoded payload sizes/hashes verify. These checks used local-only originals; the projections retain provenance, **not published source/module proof**. Originals remain excluded even where individually below the size cap.
3. **Carry this provenance/chronology note with publication; do not rewrite frozen receipts:** only manifest-listed files are published evidence. Non-allowlisted links and image hashes reference retained local supporting material, not publicly retrievable proof. This includes deployment preparation/private-source receipts, original source01/accessors02 captures, `files/` source/module captures, Work21 inventory and earlier backend/host reviews. Their links must not cause automatic inclusion. For most stages, separate outer-return receipts and some preparation details are not in this manifest; do not describe those as independently demonstrated by the public subset. The core verdicts rely on recorded native results and concrete readbacks.
4. Earlier “VF absent,” “review in progress,” and “no commit/publication pending” wording is stage-local history, not the latest state. Later VF/readiness receipts and **VFIO-RESET09** supersede those operational statements. No mutable CURRENT document is included or treated as immutable proof here.

**Hardware work remains STOPPED:** independent host recovery is unavailable and the first AFU open/read/close boundary remains unqualified. This is not a request for blanket permission. No functional AFU UUID/capability test, DDR integrity, DMA/bidirectional transfer, numerical AHLS or sustained-operation acceptance follows from these three ACCEPT verdicts. Parent retains publication/commit and acceptance-transition control.
