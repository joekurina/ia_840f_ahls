# MMIO response assertion correction

path04 retains path03's failure while printing the discriminator: atbyteoffset0x48,RID0x0052andCSR-sideRID0x00052arecorrect; RLAST is0. The source-bound deployed-facing PIM interface is **ofs_plat_axi_mem_lite_if**, which has noRLAST. Its actual wrapper wires the core's flattened RLAST toanunusedwire. Both MMIO bridges useUSE_M0_RLAST0. The new functional fixture incorrectly applied anAXI4RLAST requirement to thissingle-beatAXI-Lite boundary.

path05changesonlythatfixture assertion: retain exactRID/RRESP, request/response timeouts andallother checks; stop asserting anabsent upstream signal. NoRTL,library, clock, numeric checker ormemory endpoint change. Thisdoesnotqualify genericAXI bursts or remove the required full-aperture/access-shape guard. path03/04 remain failed fixture evidence, notfalse hardware defects orpassing runs.
