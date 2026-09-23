# path06 — unsupported page/burst parameter combination

Native vsim12/outer12, beforetime-stepping: page gearbox produces reversedrange[5:8]. Its captured source (ofs_plat_prim_burstcount1_mapping_gearbox.sv:236–267) explicitly requires PAGE_SIZE inlines tobe **strictly greater** than maximum sinkburst. At512bits,line64bytes,4096-bytepage64lines, the copied8-bitLEN allows256beats and violates thatcontract.

path07 changes only the addedwrapper's internal page_limited interfaceLENwidth to5:32beats/2048bytes, strictly below4096. Address/data/ID/USER andphysical memory widths stayunchanged. UseREPLICATE_MEM_PARAMS plus explicitLEN/ID/USER ratherthanduplicateparameteroverrides. The vendorrequestsplit/WLAST/NO_REPLY path handles longer upstreambursts; no counterlimit, testaddress, modelassertion orDUTkernel change. Originalbadwrapper preserved ashistory.
