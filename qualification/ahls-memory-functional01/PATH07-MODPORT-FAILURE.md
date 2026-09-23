# path07 — wrapper modport boundary

Page-size/maxburst configuration nowelaborates, butQuesta3908rejects passing the outerto_source_clk modport directly to burstmapper'sto_source formal. Nativevsim12/outer12; nofunctional run. This is ourwrapper, notavendorRTLfault.

path08 uses the same PIMofs_plat_axi_mem_if_connect_sink_clk pattern already used bythe native local-memory shim: internalfull afu_if receives the downstreamclock/reset, connector supplies the outerclock-driving modport, andthe burstmapper takes the internalinterface. No handshake logic, requestgeometry, testcase orassertion changes. Priorwrapper versions preserved; no suppression.
