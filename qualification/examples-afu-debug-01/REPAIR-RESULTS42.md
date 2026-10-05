# Copy-engine and corrected DMA: verified functional repair results

## Actual results (independent final reviews pending)

The source-defined copy inversion oracle was corrected separately from the RTL packet cap. The new shared AFU-side mapper limits host-facing fragments to four64-byte beats, without changing original engine widths, FIM/export or PCIe configuration.

| Test | Original outcome | New capped-image outcome |
|---|---|---|
| Copy32×4KiB, maxreq8, completion1 | Completion deadline before data checking | NativePR0/host0; read/write2048lines; all131072checkedbytes match bitwise-NOT expectation |
| DMA bank0, one1KiBH2D +one1KiBD2H | All128destinationwords mismatch, later diagnostic shows unchangedpoison | NativePR0/host0; all128words correct with same originalhost andsingle-descriptor shape, nohostchunkworkaround |

[Copy success39](copy_engine-cap27/actual-success39.json), [DMA success41](dma-cap27/actual-success41.json). CopyGBS `9ed7a4b6c900505ef555fa6c1dfbda282737d70ba46fc8f34dacd80eb0d583dc`; DMAGBS `69c83b336a6b4bae3e0a8fe19b9c197d50fabd125c24893eebaad3768954abe2`. Native/effectivebuild0/0, all44copy and47DMA boundinputs preserved; validGBS/nativeRBFpairs andsource/UUID sanity. Sourceimplementationreview `deleg_282d4632` acceptedcandidate27 beforebuild.

## Debugging interpretation

The priorcopyidentitychecker was wrong because the tutorialdata_stream_engine explicitlyinvertsbits. Its recorded2048mismatchesalone didnot establishhardwarecorruption. The unchangedimagepasses32×64bytes with theproperoracle; originaluncapturedbytesarenotreconstructed. Larger4KiBtimeoutwasaseparatefailure.

ActualDMA pinned snapshots/source controls localized a size-dependenthost-bound failure:128/256byteD2Hpasses,512/1024leavepoison. KeepingH2Dunchanged andsplittingonlyD2H256made512/1024fullpayloadsucceed. ActualcompiledPIM/FIMsources showedPUencoding andstatic512bytewritepacketallowance, versusconfiguredPF0MPS256/MRRS512. The AFU-sidecap now makesbothoriginallargershapespass withouta hostchunkworkaround. This stronglysupports the packetsizingdiagnosis; actualonwireTLPsizes/rejectionwerenotcaptured. Gen3 itselfdoesnot impose256B MPS.

## Changes and preserved originals

- Separate `copy_engine_invert_checked.c` corrects only the byteoracle, boundedmismatchsamples andtransformmarker. Existing reviewedhost remains intact.
- Additive `packet-cap27/ia840f_host_packet_cap.sv` uses directpublic map_bursts, a private unusedUSER4 flag, PAGE_SIZE4096 andNATURAL_ALIGNMENT0. A separateBURST_CNT_WIDTH2sink retainsaddress/data/masks/IDs/USERwidths andclocks/reset, ahead oftheexistingprimaryPIMsorting/buffering. Originalwideengine interfaces remain.
- New alternate `ofs_plat_afu_cap.sv` tops are selected by copiedsource lists; originaltopfiles/tutorials remainunchanged. CorrectedDMA count/Bretirement overlaysremain. IntermediateBerrorsarenotaggregated; no genericFIXED/unalignedWRAPconversionisclaimed. Copy'soriginalAxBURST remainszero—not explicitINCR.
- Freshnativeworkspaces: `/home/uwb_student00/ahls/new_BSP/work_examples_afu_debug01/copy_engine-cap27` and `dma-cap27`. Images/oversizedlogs stay remote andhash-bound; theseevidencecapsulesarenotclean-checkoutbuildpackages.

## Material unresolved lifecycle warning

BothpassingtestsstilllognewVFIOpendingtransactiontimeouts duringcleanup: copyat7639.887118 andDMAat7779.246637, with “performing function level reset anyway.” Their nativehostexits0 andordinarypostflightowners/maps/errors/relevantprocesslistsareempty. ThisdoesnotestablishglobalDMA-drain, safe reset, futurehealth or no-hangqualification. No driver/BIOS/AERmask/link/MPSforcepasschange wasmade forthisrepair. [Copykerneldelta39](copy_engine-cap27/kernel-delta39.log), [DMAkerneldelta41](dma-cap27/kernel-delta41.log).

Coverageisfunctional32×4KiBcopywiththecurrentbytepattern andbank0low32IOVA1KiBDMA, not capacity/isolation/performance orerror-injectionqualification. Copy'sbytepattern repeatswithin256B, so donotclaimgenericfragmentpermutationcoverage. OriginalDMAread-RRESPerrorobservability remains incomplete.

## Next action

Consume finalindependentactual-resultdispositions `deleg_394c8322` (copytask0, DMAtask1), recordscopedacceptance andfinalhandoff withoutrewriting theclosedcampaign'srawfailures. Neitherthenativebuildwaiter norPASStextalone replaces thenative/data/hash receipts.
