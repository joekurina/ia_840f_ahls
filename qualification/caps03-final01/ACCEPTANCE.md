# CAPS03 final qualification acceptance

> Scope correction: the overall hls-samples2026.1.0 goal is incomplete and reopened.
> This acceptance covers only the DDRIP sample integration and supporting hardware.
> The claim that it completed the release-wide goal was incorrect.
> See [active correction](../hls-samples-2026.1.0-01/CORRECTION.md).

## Verdict and scope

The recorded IA-840F OPAE/DFL memory-HLS integration goal is complete for the accepted Work21-based CAPS03 image: Quartus Prime Pro 25.1, HLS IP Gen 2026.1.0 memory vector-add, unchanged generated HLS and unchanged 3.000 ns target. All scoped hardware results and their independent actual-result reviews are accepted. This is not a claim that every kernel in upstream `hls-samples` was built or tested ([maintained goal](../../GOAL-PROMPT.md), [final verification](verification01.json)).

The implementation uses finite producer completion plus enabled-byte and AW/W/B retirement accounting at the existing application-domain bank shim. It preserves the accepted PIM crossings and observes write retirement before DMA copyback; it does not revive the rejected CAPS02 snapshot mailbox ([functional acceptance](../caps03-completion01/ACCEPTANCE06.md), [normal numerical acceptance](../caps03-runtime01/ACCEPTANCE26.md)).

## Accepted results

| Requirement | Actual result and acceptance |
|---|---|
| Build and physical implementation | Native synthesis, fit, STA and assembly completed; bounded physical acceptance at 3.000 ns. Native Design Closure FAIL remains disclosed, not converted into PASS. [Physical](../caps03-persona01/PHYSICAL-ACCEPTANCE01.md), [assembly](../caps03-persona01/ASSEMBLY-ACCEPTANCE01.md). |
| Durable deployment | BittWare SDK full-input program/readback comparison passed; independent BMC Off/On readbacks and normal workstation reboot passed. Cached static-FME identity alone was not used as AFU numerical proof. [Deployment acceptance](../caps03-flash01/ACCEPTANCE48.md). |
| OPAE discovery, MMIO, host↔DDR and original HLS computation | Exact selected identity/capability checks, six DMA descriptors, nine signed results and 156 guard/padding bytes passed. Original application native exit 0 and empty postflight ownership. [Numerical result](../caps03-runtime01/NUMERICAL21.md), [review](../caps03-runtime01/normal-review23.json). |
| Repeated and boundary cases | 34 ordered cases, 2,982 integers, 11,928 result bytes, 5,224 guard bytes and 536 descriptors passed. Native 0; outer transport status remains unknown/null. [Actual-result acceptance](../caps03-coverage01/ACCEPTANCE04.md). |
| Independent banks, isolation and sustained traffic | Address/channel-dependent W0→W1→R0→R1, 2 GiB written/read per bank across the 16 GiB apertures, 67,108,864 descriptors and 590.093506230 seconds passed. [Acceptance](../caps03-ddr01/ACCEPTANCE07.md). |
| Logical address-pair follow-up | 30 addresses per bank, 120 descriptors, writes before reads and checked returned bytes. [Accepted walking result](../caps03-walk01/review04-consumed.json). |
| Concurrent HLS functionality | 65,536 integers, 262,144 result bytes plus 128 DDR guard bytes, 8,324 descriptors/268 tiles passed. Source-supported bank0-read/bank1-write concurrency, not measured wire overlap. [Actual-result review](../caps03-bulk01/review04-consumed.json). |
| Full configured DDR capacity | Both complete 16 GiB logical apertures written/read/compared, 536,870,912 descriptors, 64 GiB aggregate traffic and all 512 progress records verified. Native/outer 0 and no owner remaining. [Acceptance](../caps03-full-ddr01/ACCEPTANCE16.md). |
| Normal lifecycle | Six finite application lifecycles have numerical success, native exit 0 and empty postflight ownership, accepted under only the exact user-approved warning exception. [Final reconciliation](../caps03-lifecycle01/reconciliation04.json). |

Together these results satisfy the [agreed DDR hardware gate](../../docs/ddr-hardware-validation-gate.md); the build-specific memory FIFO/calibration-association deltas are resolved by hardware test. This is full configured/exposed logical-aperture coverage, not independently observed physical wire-address mapping ([combined-gate review](../caps03-full-ddr01/review16-consumed.json)).

## Exact exception and retained limits

The accepted message is:

`vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway`

Preserve `lifecycle_clean=false` and the later `lifecycle_accepted=true` disposition. Original live21 remains raw `success=false` and outer exit 1; coverage's outer status remains unavailable. No raw result was rewritten to erase those distinctions. The warning is pending-before-FLR, not a subsequent FLR-completion timeout. Its erratum explanation is consistent with the evidence, not established exclusive causation; software ownership cleanup is not a measured global PCIe-drain proof ([user policy](../caps03-runtime01/ERRATUM-ACCEPTED25.md), [reconciliation](../caps03-lifecycle01/reconciliation04.json)).

Native Design Closure FAIL and the bounded physical/reset-entry scope remain unchanged. General cold/PR entry, stopped-clock and active-transaction failure recovery are not qualified; this does not undo the actual observed QSPI/BMC/reboot deployment. Vendor DDR simulation remains skipped by user direction. The maintained top's disabled default is not permission to substitute another build for the exact qualified image ([physical scope](../caps03-persona01/PHYSICAL-ACCEPTANCE01.md), [entry scope](../caps03-runtime01/ENTRY07.md), [deployment](../caps03-flash01/ACCEPTANCE48.md)).

Full-capacity loop time was 4702.629792690 seconds (78.38 minutes). That excessive duration is a retained harness-efficiency defect, not DDR bandwidth or an acceptable performance benchmark. No efficient replacement test or bandwidth optimization is claimed, and this spent run is not to be repeated ([full-capacity result](../caps03-full-ddr01/ACCEPTANCE16.md)).

## Retained working artifact

The locally retained accepted full-device SOF is:

`qualification/caps03-persona01/asm01-capture/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.sof`

It is 10,065,141 bytes, SHA256 `8f778fca292cc77f87c196deb198d4798a1bd111999d69b0245d570fa2bfe276`; the final local check matches the original assembly. SDK input was the separately converted 10,653,696-byte RPD with SHA256 `0319b7fd35d968d73f02f9a6f49706cb249c3559dec1759a3f2d3a37122e4bcf`. JIC is not SDK-writer input. Bitstreams/binaries and embedded launch payloads remain local-only with hash-bound metadata ([verification](verification01.json), [assembly](../caps03-persona01/ASSEMBLY-ACCEPTANCE01.md), [SDK evidence](../caps03-flash01/SDK23.md)).

## Completion and stop boundary

All individual acceptance milestones were pushed and their exact path/blob sets and remote branch agreement verified. The final checkpoint brings the goal, README, DDR gate and lifecycle disposition into agreement; [publication checkpoint](../caps03-publication01/CURRENT.md) identifies those commits. Its final remote readback is retained locally after publication as `qualification/caps03-publication01/final09-publication-verification.json` rather than creating a self-referential commit hash.

Last observed empty ownership was 2026-09-26T23:12:36.315634+00:00; this is historical completion evidence, not a new hardware preflight. There is no pending build, hardware operation, collector or result-review task for this qualification. Stop here. Any different kernel, performance optimization or expanded recovery qualification is separate work, not an automatic continuation. The [preserved prior handoff](goal-before-final01.md) is historical only.
