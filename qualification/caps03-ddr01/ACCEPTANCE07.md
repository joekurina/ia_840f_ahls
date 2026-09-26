# CAPS03 serial DDR — three scoped gates accepted

Independent review `deleg_79ea1085` accepts independent logical-bank operation, W0→W1→R0→R1 isolation, and serial sustained operation, with no blocking defect. The parent rechecked the exact receipt/hash chain, raw native log and unchanged bound frontend/transfer/lifetime sources before consuming the review (`review07-consumed.json`).

Each bank received2GiB of address/channel-dependent writes and verified reads spread across its16GiB aperture. Both complete write phases preceded either read phase under one owner. Four phases and64 progress records reconcile to67,108,864 page-contained128-byte descriptors and8,589,934,592 traffic bytes (`live02-native.log`, `live02-result.json`, `parent-verification06.json`).

The serial transfer/check loop lasted590.093506230s, satisfying its180≤elapsed<3600s criterion. Every descriptor required fresh completion and idle/error-free retirement; every returned payload matched its reference and both complete4096-byte host pages were checked before reuse. This is serial correctness/sustained-operation evidence, not saturated DDR bandwidth or untouched-DDR guard coverage (`../../src/host/ahls_memory_caps03_ddr.c`, `parent-verification06.json`).

Native0/outer0 and empty ownership passed. Only the exact acknowledged pending-before-FLR warning occurred: `lifecycle_clean=false`, `lifecycle_accepted=true` under [the explicit disposition](../caps03-runtime01/ERRATUM-ACCEPTED25.md). This is not warning-free teardown or proof of zero outstanding PCIe requests (`live02-kernel.log`, `live02-result.json`).

Limits remain: one-eighth of each aperture's bytes were sampled; physical all-bank/all-row coverage is conditional on protected MSA byte ordering (`address-review05-consumed.json`). Independent walking-bit hardware coverage subsequently passed and is separately awaiting review; it does not upgrade physical-row or simultaneous claims ([walking-bit result](../caps03-walk01/RESULT.md)). Simultaneous-bank acceptance remains separate ([prepared bulk test](../caps03-bulk01/RESULT.md)).

The immutable result's inherited `caps03-34-repeat-boundary-cases` label is a documented reporting defect, not the executed workload; module argv, hashes and native log identify the DDR frontend. No rerun or evidence rewrite is required. Overall qualification remains incomplete.
