# SDK 2026.1 IA840F inspection — bundled host CSP confirmed, DDR model blocker unchanged

**SDK 2026.1.0 includes IA840F host support, but supplies no candidate device simulation library or documented fix for the current DDR elaboration/compiler failures. No justified new rebuild, elaboration or smoke was available. `pass=false`, `ready_for_build=false`, `hardware_qualified=false`.**

## What was verified

- Target identity: `Agilex7Workstation`, UID 1000. Every remote operation used SSH BatchMode solely to interact with owned tmux windows in `ia840f_mailbox_monitored_01`; monitor panes were not touched.
- Installed RPM: `bittware-sdk-2026.1.0-1.x86_64`, built June 2, 2026. The downloaded filename is `/home/uwb_student00/IA-840f/bittware-sdk-2026.1.0-1.el9.rpm`; its SHA256 is `c106fe06946f282825a5605d17f08d42b8b0da70a35db4c3af8d49ccee7d1382`. The filename was preserved, not normalized to the installed NEVRA.
- All **151 files** under `/usr/share/bittware-sdk` were inventoried and SHA256-checked before/after inspection, unchanged. All **132 archive payloads** (wheels, ZIPs, tarballs) were member-inventoried. No `tennm`, `fmica`, `msim_setup`, `modelsim.ini`, SystemVerilog/VHDL or Questa-QDB candidate members were found. Full member inventories are retained, not merely the zero-match summary.
- IA840F support resides in `python/bw_agilex_product-0.1.49-py3-none-any.whl`: `bw_agilex/data/IA-840F/IA-840F.yml`, card-test JSON, clock projects/register headers, test-plan YAML, and `bw_agilex/products/ia840f_product.py`. The class explicitly points at these bundled data paths. These are host/card-management resources, not the encrypted DDR primitive model.
- A read-only `rpm -qpl` of the historical CSP 2024.3.1 RPM shows the corresponding older board-description/clocks/cardtest/Python packaging. **Removal of the separately installed CSP is not diagnosed as missing board support.** No `bw_pip`, vendor Python imports, card tests or hardware-access utilities were run.

## Release notes, versions and patches

`rpm -q --changelog bittware-sdk` and `rpm -qd bittware-sdk` both returned rc 0 and empty output. The installed RPM file list and archive inventory contain no SDK 2026.1 HDL-simulation release notes, simulator-version matrix, or device-model patch. This is a finding about the inspected local payload, not a claim that BittWare has no online release documentation.

The available `IA-840f_oneAPI_Support_Guide.pdf` is historical. Its verified-stack section names **oneAPI 2024.1.0, Quartus 23.1 patch 0.02iofs, and the IA840F ASP based on OFS 2023.1**. It explicitly says Quartus is installed separately. It does not establish a supported Questa version for this current generated design. SDK card-test code's Quartus minimum checks call `quartus_pgm -v`; they are programmer checks, not HDL-simulator qualification. Neither was used to justify downgrading tools or replacing the BSP.

## Concrete remaining prerequisite

The unchanged current compiler reports **Questa Altera FPGA Edition-64 vlog 2025.3 Compiler 2025.09 Sep 15 2025**, at `/opt/altera/26.1.1/questa_fe/bin/vlog`.

The current generated `msim_setup.tcl` still requires, in order, `tennm_atoms.sv`, `mentor/tennm_atoms_ncrypt.sv`, and `fmica_atoms_ncrypt.sv` for `tennm_ver`. Its hash remains `993316923cf645fc763b0daa965fe79705b6db424d451e70453cc7c3719f2860`. Fresh existence checks confirm the first two remain absent from `/opt/altera/26.1.1/quartus/eda/sim_lib`; `fmica_atoms_ncrypt.sv` exists but is not a complete library set.

**Needed:** an Altera-supplied coherent Agilex/tennm simulation source set or precompiled library explicitly supported for the current generated EMIF and Questa 2025.3, including the IOSSM interface used with `IOSSM_USE_MODEL(1)`. For source rebuilding, that means the complete generated-recipe trio above, from the matching supported distribution/patch. Alternatively, a vendor-confirmed simulator/device-model combination is needed. No exact replacement simulator release or patch is established by this SDK, so none is invented or installed.

Prior evidence was reviewed, not rerun: `ddr-library-import-01` run-05 had 24 unsupported-parameter elaboration errors; `ddr-library-rebuild-01` run-06 compiled the 23.1 wrapper but failed the protected source with four `vlog-13488` integer-literal errors, native rc 2 after about 197 seconds. The SDK supplies no new input that addresses either failure. Those outcomes do not identify the protected target's exact version. No repeated known-failing compile was launched just to produce activity.

## Evidence and boundaries

Local root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/ddr-sdk2026-01`.
Remote root: `/home/uwb_student00/ahls/new_BSP/qualification/ddr-sdk2026-01`.

Key artifacts in `readback/`:
- `result.json`, `inventory.json`, `rpm-files.txt`
- `sdk-hashes-before.json`, `sdk-hashes-after.json`
- `all-sdk-archive-inventory.json`, `wheel-inventory.json`, `wheel-hits.json`
- `documents/` and `documents-provenance.json` (full extracted historical guide and selected bundled IA840F source evidence)
- `prerequisites.json`, `tool-version.json`, `final-source-verification.json`

**21 remote evidence files** were retrieved through named tmux buffer `ddr_sdk2026_01_evidence`; the whole export and every file SHA256 were verified. Export SHA256: `3ea20ef57a6a5aa472f826fc3f92a8e865bd2c764d4a4afdc6777b937bdd7dee`. See `retrieval-verification.json`. All inspection/export/retrieval scripts and captured pane outputs are in this fresh local task directory. The initial local bare-`python` invocation failed because only `python3` is present; rerun with `python3` succeeded before any remote action from that invocation.

No maintained BSP, Work04 HDL, repaired model, prior experiment, vendor installation or vendor file was edited. No installs, sudo/groups, services, programming, reboot, commits, suppression, parameter deletion, decryption or stubs. No build-library reuse occurred. Build limits remain 1500 seconds/command and 1800 total; elaboration/simulation remains 120 seconds if a viable candidate becomes available. Geometry, reset assumption, traffic and exact pass-marker/error acceptance requirements are untouched. This inspection is not a DDR smoke or hardware qualification.
