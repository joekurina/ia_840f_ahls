# Parent acceptance — connected DMA/AHLS component

**ACCEPT_NATIVE_GENERATION_AND_CONNECTED_ANALYSIS_ELABORATION_WITH_FINDINGS.** Consumed FINAL independent specificationPASS/qualityPASS_WITH_NONBLOCKING_FINDINGS, reportSHA256 `2223940db48f7e67d0c7814c6be8bc65a040e328c12dcf276e82a31837b93d25`. [Review](independent-review01.md), [verification](parent-review-verification02.json), [native result](RESULTS01.md).

Parent reverified22frozen entries, both native archives and all261fabric/7elaboration captured bodies. Both generation commands and analysis/elaboration native/effective/outer0; exact project/tool/device/input preservation remains as recorded, not a new live re-hash. Generated HDL/SOPCINFO245ports/11interfaces,171external core ports and245named connections; actualDMA/CSR/descriptor/dataFIFO/mux/reader/writer andDDRIP/CRA/LSU together. EightDMA-ID changes16→9 andnewBRESP connection are exact; bankID18/USER2 retained. Prior155HLSinventory entries unchanged;154currentcaptured bodies compare directly andtheSVH ishash-bound withmatchingpriorbody. FourQIPtargets lackcurrentcapturebodies (twoCMP,SDC,SVH), notmissingnativeinputs;255generated+25core=280boundnativeinputs. Do notcall261theentire286-output inventory.

142warning occurrences versusbanner1 retained. ResetRelease RES-10204 High1/0waived remainsfullFIMobligation, notwaived orsilencedwithduplicateIP. Source reviewfoundno newactive unwiredmemory/control field orwrongconnection atthisboundary; thisisnotnumericorhardwareacceptance.

**F1confirmed:** capability data_width512→3bits andFIFOdepth32→4bits readaszero; fixed400MHz field isnotactualclockevidence. Correct/documenttelemetry inasuccessor, notdatapathgeometry.
**F2confirmed:**9-bitone-hotwriterFSM projectedto6-bitdebugfield hideslatewait/errorstates; actualFSMandstickyerrorsarenotlost. Adoptcomplete documentedstateencoding withoutshiftingotherstatusbits. Make150→64statuspackingexplicit; separatelyreadableperformancefieldsandlowstatusbitsaredistinct.
**F3retained/highforfutureuse:** firstresponsecodes/admissionfailurepersistence absent; copiedlegacycontrolbitsarenotquiescenceacknowledgments. InternalBRESPdoesnotproveCPUvisiblepostedwritefaults. Noreset/retry/bufferreleaseclaim.
**F4retained:** inactivefields/debugdefaults/redundantpackedAR andsupplementarygeometryleafbindingsremainfuturehygiene. Finalfieldwisemuxassignments supersederedundantpackedAR; ordinaryzero-special-flagdomainonly. NoarbitraryUSER/fence/atomicproof.

Thecore'sstandalonepackagesareaprojection, notactualPIM. SuccessoractualPIM stageisseparateandnotacceptedbythisrecord. Upper20-bitMMIOalias, actualPIM/ID/USER/CDC/reset, fullkernel numericalexecution, burst/boundary/protocolchecks, globaldrain/fences/hostbuffers, mapped/FIMfit/STA, OPAE/physicalDDR/durableboot remainoutsideacceptance. CSRpredecessorisaccepted/publishedcbefc1a91b1cb417906eb360fddf0f15f33a4407; historicalpendingreviewwording supersededwithoutrewritingfrozenresults.

No unchangednativererun required. NoFPGA/device/MMIO/driver/programming/reboot. VendorDDRsimSKIPPEDBYUSER. Standinggoal incomplete.
