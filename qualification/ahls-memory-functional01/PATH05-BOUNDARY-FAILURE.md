# path05 — bank AXI page crossing

The corrected AXI-Lite fixture reaches real transfers. Two host→bank0 input copies complete, then a3-beat bank1 initialization atlocal0x3fc0 crosses0x4000; the byte-memory endpoint rejects anINCRburst crossing4KiB at7645ns. Nativevsim0withfatal, outer1. Allpriorassertionsandfullfailure retained; no kernel/numericpass.

The actual PIM local-memory shim invokes ofs_plat_axi_mem_if_map_bursts withoutPAGE_SIZE, default0. Its supported public burst mapper documentsPAGE_SIZE inbytes and handles split requests, WLAST and intermediate response/NO_REPLY flags. Anew additive bank wrapper inserts PAGE_SIZE4096 ahead of the unchanged local-memory shim, so existing user/extra-ID queues andCDC preserve split-completion metadata. No DMAcounter/length/geometry change andno vendorRTLedit.

path06 changes only the bank composition (new wrapper plus test instantiation name). The exact failing addresses, lengths, model/page assertion andnumerical/guard checks remain unchanged. Numerical results, protocol correctness andhardware acceptance remainpendingthe real run.
