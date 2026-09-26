# CAPS03 walking-bit follow-up — hardware PASS with accepted erratum

The additive [frontend](../../src/host/ahls_memory_caps03_walk.c) preserves the existing CAPS01 address walk and changes only CAPS03 identity, the current strict-launcher ABI flag, a fresh address/channel-dependent pattern seed and a stale introductory comment (`host-delta01.patch`). No transfer, page, visibility, retention or cleanup protocol changed.

The exact30-address corpus is zero, each single bit6..33, and the final64-byte bank-local line. All bank0/bank1 locations are written before any readback. Thus the pairs0x80/0x400,0x100/0x800,0x200/0x1000 are independently distinguished rather than correlated as in the large sparse sweep (`address-domain01.json`).

The prior frontend was RED for this corpus. Four focused inert scenarios then passed: exact full30-address walk and each of three correlated-pair alias faults retaining all resources (`tests01/result.json`). The actual live parser passed four focused local checks (`live02-parser-tests.json`). Native AHLS-SIF CMake/ELF checks passed without hardware access (`native01-metadata.json`); the35,352-byte module has SHA256 bdf5a8c78ca7583028769a71a5c12bb2f3ee0ed3f17060d4f8a5255a72e557e0.

Actual hardware live02 ran once after the large DDR sweep ended with empty ownership. Native0/outer0, all120 descriptors freshly retired, both entire host pages checked after every transfer, and all30 returned64-byte payloads per channel matched. Parent verified the exact receipt/hash in `parent-verification03.json`; raw evidence is `live02-result.json`, `live02-native.log`, and `live02-kernel.log`.

Postflight ownership is empty. The only kernel concern is the exact accepted pending-before-FLR erratum; `lifecycle_clean=false` and `lifecycle_accepted=true` remain separate under [Joe's disposition](../caps03-runtime01/ERRATUM-ACCEPTED25.md). No retained owner, retry, manual reset, reflash or FPGA rebuild occurred.

This closes the sparse logical address-bit correlation follow-up, not an exhaustive all-byte or independently decoded physical-bank/row claim. Simultaneous-bank acceptance remains separate. The follow-up is parent-verified and independently accepted by `deleg_7f0585bb`, consumed in [review04](review04-consumed.json). The earlier attempted extension to the serial-DDR review was not delivered, so do not credit that earlier review with the walking-bit result.
