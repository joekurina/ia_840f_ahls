# Raw-capability candidate — verified unit results, review pending

Source delta: only additive constants/elaboration representability check, four read cases, and expansion of raw-address read eligibility through0xb0. No existing state update, write admission, endpoint arithmetic or control changed. [Patch](raw-capabilities01.patch), [ABI](ABI01.md).

- RED: native stages all0, but expected simulator fatal `new capability absent or legacy response changed` at cycle8450/test307. Native vsim0 did NOT mean pass: effective functional outer1 retained. Inputs/originals/tools unchanged and no survivors.
- GREEN: version/vlib/vdir/vlog/vsim all native/effective0, outer0, no diagnostic errors, all preservation flags true and no survivors. Scoreboard:311cases,1536writes,51reads,85enqueues,226endpoint-check events,674minimum-gap events,138B-stall/255R-stall observations,251resets,8955cycles,58635checks,16capability reads. `min_gap` is the retained scoreboard event count, not latency. Public status inputs/platform constants remain explicitly synthetic; no physical DDR/PCIe/OPAE/global drain was exercised.
- Each native attempt binds27source payload hashes and5log size/hash pairs. Some inherited source records specify hashes only; their sizes are derived rather than falsely treated as declared. [Verification](parent-payload-verification01.json).
- GREEN native simulation:0errors/2warnings, both vopt-13314 port-kind defaults (candidate and baseline). No warning suppression.
- Local host decoder: GCC14.2, -O0 and -O2, strict warnings-as-errors and UBSan, each accepted the expected record and rejected256single-bit mutations plus2null-argument cases; rejection preserves output bytes. Both executables link no OPAE/MPF/FPGA library. [Host results](host-test-results01.json). These are pure data tests, not an enumeration or host-I/O test.

Fresh actual-Work21 PR setup completed0/0/0 with4925inventory entries and7exports. Changed native Quartus25.1 mapped synthesis is separately running under `../ahls-persona-work21-caps01/`; no result claimed here. The accepted CSR02 image/evidence is unchanged.

Overall goal incomplete. Hardware unavailable to this test by design; vendor DDR simulation remains SKIPPED BY USER. Prior CSR timing and other signoff findings are not automatically transferred or cleared for the changed persona.
