# Mailbox correction integration 05

## Outcome and scope

Integrated exactly the two accepted UTF-8 payloads from `../monitored-refresh-02/result-evidence.json`, keys `bwbmc/bmc_spi_sub.qsys` and `bwbmc/ip/bmc_spi_sub/sdm_mailbox.ip`, into the maintained BSP. Their hashes match generation05's input inventory and unchanged after-inventory. Updated only those two file entries plus one scoped provenance object in `source_manifest.json`. Original donor `source` and `source_sha256` fields are unchanged; `prior_sha256` records the immediately preceding maintained bytes. Full before copies of both inputs and the manifest are under `before/`.

This is integration implementation, not independent integration acceptance: follow-up spec and quality reviews remain pending. `ready_for_build` remains false; all existing blocking requirements and execution policy are unchanged. A fresh source-bound authorization must be prepared later before further gated execution; no consumed authorization was edited.

## Provenance and acceptance basis

The independent `../monitored-refresh-02/output-review.md` accepted the saved leaf/child correction. Its historical pending-generation statements are superseded only by the bounded generation05 evidence, not by any broad qualification claim. `../monitored-generation-05/result-evidence.json` records leaf, child and enclosing-parent generation each with return code 0, no exception and `errors=[]`. All payload hashes in refresh02, generation05 result evidence and generated-source evidence recompute correctly. All generation05 pre-existing inventoried inputs are unchanged afterward. All 32 other inventoried BMC inputs match the maintained BSP byte-for-byte, including the original enclosing parent and sibling IPs. No parent03 output was integrated: that experiment's broader upgrades and lost associations are excluded.

The generation05 captured HDL shows the enclosing AXI address/data boundary remains 17/64 bits; child mailbox `avmm_waitrequest` and interconnect `sdm_mailbox_avmm_waitrequest` share a real wire. Separate SDM reset remains exported through the parent and routed via `sdm_reset` in the child. These are historical captured-output observations, not a new run or hardware proof. No generated HDL, QIP, QPF or QSF was installed.

## Meaningful migration and vendor-added metadata

- Mailbox component version advances **20.2.2 -> 23.0.0** under Quartus **26.1.1**, and child `originalModuleInfo` agrees.
- Scalar output `avmm_waitrequest` is represented in the leaf logical/physical mapping, model and repaired locked interface, and the child's boundary/defaultBoundary. Backpressure is not replaced with a constant.
- Every original mailbox module parameter retains its value: device AGFB027R25A2E2V, Agilex 7, speed grade 2, command/response FIFO 1024, urgent FIFO 4, memory-block selections, status/debug/stream/offload selections and timeout. Vendor-added `AUTO_BOARD=default` is retained.
- The vendor save synchronizes `waitrequestTimeout=1024` and DFH boundary metadata; child naming uses `$${FILENAME}`, with `bspCpu=false`, `liveModuleName=sdm_mailbox`, empty transform descriptor and empty `fileSetFileChangeDefs` serialization as described in the independent refresh review.
- Original child connection kinds/endpoints and every pre-existing connection parameter, including addresses, are retained (46 connections, 17 module instances). Vendor serialization adds connection version 26.1, `qsys_mm.fifoDepth=8` and `qsys_mm.splitCommandsFor4KBoundary=FALSE`. Exports and reset associations are retained, not redesigned.
- Child saved error flag becomes false, but its warning flag remains true. Generation05 logs include sibling-version substitution warnings; rc=0/errors=[] is not a warning-free or all-IP-qualified claim.

## Verification and remaining work

Performed only local JSON/XML parsing, static comparisons and SHA-256 checks. Confirmed exact replacement bytes, unchanged donor hashes, unchanged unrelated manifest entries/top-level fields, retained readiness false, retained connection parameters and reset/mailbox endpoints, and unchanged other inventoried BMC sources. No vendor/remote execution, project-tool imports, build/test execution, hardware action or commit occurred.

Full BSP generation, synthesis/timing, PF1 FLR safety, unsupported SPI window behavior and hardware/runtime qualification remain outside this receipt. Independent integration spec/quality reviews and fresh source authorization binding remain required next steps.

## Exact maintained-file hashes

- `ofs-agx7-pcie-attach/ipss/ia840f/bwbmc/bmc_spi_sub.qsys`
  - Before: `71bcb8de75167546c7dcb0b159021fa16666f2ed92cdaacb8d9f9ed67c36f952`
  - Current: `e3571b6d6b0e04bcc488be3c0a309571c2ccb6a0564c530f43b41dabe4cfd82a`
- `ofs-agx7-pcie-attach/ipss/ia840f/bwbmc/ip/bmc_spi_sub/sdm_mailbox.ip`
  - Before: `539fc0453b109b25a820863e002a5ae6e633705c307699bfdee974f9a71222f1`
  - Current: `b6b28be4555938f513102b9a32ac99dc40a61083bb6b063c8f2c20b03e54a8c6`
- `ofs-agx7-pcie-attach/syn/board/ia840f/source_manifest.json`
  - Before: `022bb28deac0cccd1e918192faa1ba3cb151e0d13b3444be7852e9ea77e49538`
  - Current: `a56ceb0a6adcfd8317583d58329d52f9ebcad89d8cf50b95ff3b9cc4a1591b3f`

Evidence artifact hashes and before-copy inventory are recorded in `receipt.json`.
