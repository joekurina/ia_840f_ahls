# AHLS memory component: native Quartus25.1 import/generation

**Observed import and synthesis-HDL generation success; independent acceptance pending.**

`import02` completed both native commands with return0, no Error/Fatal or Warning diagnostics in the captured import/generation logs, and explicit validation/import completion markers. Generation identifies25.1 build129 and targetAGFB027R25A2E2V. The native commands, process-group drain, input/tool preservation and222-file generated inventory are in [import02-manifest.json](import02-manifest.json);22selected captured members were byte/hash verified after transfer. The compressed original capture is `result-import02.json.gz`, SHA256 `4e86b60a26c5cd0ec19557d5aa4cde3d2fc4c31a3b7b3572416615568cb6a705`.

## Source and interface checks

The fresh copied project has224original members/33,641,784bytes. Exactly one source is replaced by the independently accepted write-ack correction; original source and every other copied input were rehashed unchanged. The generated k0 has2modules/156files; all155unique source files referenced by the334original fileset statements match their expected original or corrected hashes in the generated files. The generated top component remains SHA256 `c072b420ca510e98de233184d1fc7664b50a158714f5516b82991452e2540756`; generated `lsu_ic_top.sv` is the accepted candidate `f9defb182dcca3d3d299eb1e2ee060ce730caa24b2bd613d44f8c05abaccfdcd`. [Interface/source ledger](interface-ledger02.json).

The saved native SOPCINFO and generated system HDL establish:

| Boundary | Address bits / units | Data / byteenable | Native span | Waitrequest allowance |
|---|---|---|---|---|
| CSR |5 / WORDS |64 /8 |256bytes |0 |
| Logical memory0 |34 / SYMBOLS,8bits per symbol |256 /32 |17,179,869,184bytes |0 |
| Logical memory1 |34 / SYMBOLS,8bits per symbol |256 /32 |17,179,869,184bytes |0 |

Burstcount units are WORDS. Both memory burstcount ports remain4bits; the source contract limits bursts to8beats. Clock/reset associations are clock/resetn. Generated exports wire these ports directly, without a data/address conversion block. This resolves the earlier native-import address-unit ambiguity for this exact system; it does not prove physical-bank routing or a future connected width adapter.

Native metadata retains hidden/default fields such as master maxAddressWidth32 and deviceFamily UNKNOWN even while the actual ports/span are34bits/16GiB and the project/device generation is explicitly bound. No clipping or family mismatch is inferred from those metadata fields alone. Actual connected-interconnect behavior remains a separate integration check. CSR maximumPendingReadTransactions is1; memory-host value is0 and is recorded without treating it as a measured outstanding-depth guarantee.

## Failed attempts and limits

`import01` is preserved as a failed Tcl/API diagnostic attempt. The older interpreter rejected eq; integer-valued interface queries through get_instance_interface_property emitted Java type-cast errors. The successor uses string compare and string-valued queries, then inspects numerical properties from saved native XML. No HLS or installed vendor source was changed to accommodate those API issues. `probe01` has retained outer125 after immediate residual-group rejection; later commands allowed bounded normal helper drain, finished naturally and recorded no live owned group.

QSF native migration added linear-format power defaults, LAST_QUARTUS_VERSION, three IP_FILE entries and the QSYS_FILE entry. These are a standalone import project's native output, not edits to the IA840F FIM's board/power configuration.

This stage does not compile/elaborate every HDL module with quartus_syn, fit a persona, establish kernel completion/visibility, qualify DMA/PIM or perform numerical/hardware tests. The exported-interface standalone project is not a board image for deployment. DDR simulation remains SKIPPED BY USER; no FPGA devices were accessed.
