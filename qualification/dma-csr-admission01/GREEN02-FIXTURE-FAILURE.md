# Preserved second attempt: stale-W fixture bug

Candidate compiled; native vsim0/outer1 at495ns, expecting partial-write DECERR but receiving OKAY. Raw logs show value0x1 on intended0xdead writes. write_checked set WVALID=!wdone on its first loop edge, before t4 supplied new data/strobes; it therefore offered stale prior data/FFstrobes. The corrected fixture gates WVALID until t>=4. No CSR source or deadline change. Red02 and green03 use the same corrected fixture; earlier red01 is not the sole causal negative control.
