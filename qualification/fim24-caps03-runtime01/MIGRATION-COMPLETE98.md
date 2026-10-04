# IA-840F OFS 2026.1 / Quartus 26.1 migration — complete with retained limits

**The scoped migration goal is complete.** The accepted OFS2026.1/Quartus Prime Pro26.1.1 Build130 image meets the unchanged **3.000ns application target** under the accepted numerical/CDC trust scope, is SDK-programmed and boot-identified, and all **five named migrated-image hardware gates** are independently accepted and published. No active native/card job, UNKNOWN owner or pending review remains. This is parent goal closure, **not** a claim that raw readiness/timing flags turned true or that all electrical/reset/DRC/physical-equivalence concerns disappeared. [Mechanical aggregate](MIGRATION-COMPLETE98.json).

## Five real-card results

All five original operations returned **application/container/outer0/0/0**, exited normally, retained no owner, preserved boot and passed active payload/guard/full-host-page checks. Each was independently reviewed and accepted **PASS WITH LIMITS**, then published with exact committed-blob/remote-branch/main-preservation verification.

| Gate | Verified actual result | Independent acceptance | Milestone |
|---|---|---|---|
| Numerical copyback | 9 signed integers,36 result bytes,156 guards,6 descriptors | [71/72](COPYBACK-ACCEPTANCE72.md) | `51dceebe` |
| Boundary/repeat coverage | 34 cases,2982 integers,11928 result bytes,5224 guards,536 descriptors | [77/78](COVERAGE-ACCEPTANCE78.md) | `59364892` |
| DDR independent/isolation/sustained | W0→W1→R0→R1,2GiB written/read per bank,67108864 descriptors; **594.000209015s**, explicit180≤elapsed<3600 | [83/84](DDR-ACCEPTANCE84.md) | `a0e8ca51` |
| Logical walking-bit/address | 30 locations per bank,120 descriptors,1920 copied-back bytes per bank | [89/90](WALK-ACCEPTANCE90.md) | `0d1e9ff2` |
| Bulk concurrent-bank functional | 65536 integers,262144 output bytes,128 guards,8324 descriptors,268 tiles,ticket1/completion0x10002 | [95/96](BULK-ACCEPTANCE96.md) | `60564071` |

The aggregate reverified **136 frozen-file references /80 exported references**; these are references, not unique-payload counts. Exact distinct-file cardinality and every acceptance/review/freeze/receipt/publication hash are in the JSON. None of the hardware fronts was repeated merely to recover context.

## Build, timing and artifact lineage

- Retained migration source/export/fabric/persona/simulation/mapped-synthesis/fit basis is reused. Native fit38, final-snapshot multicorner numericalSTA32 and current40-bundle/20-FIFO CDC73 are accepted with findings. All923 reported numerical records are nonnegative; application3.000ns propagation includes+.002ns setup paths. CDC's exact2700 typed full-name path bindings settle the scoped current FIFO endpoint/net-delay/exception discriminator; no fresh constraints/refit were added. [Fit](../fim24-caps03-physical01/FIT-ACCEPTANCE38.md), [STA](../fim24-caps03-sta01/NUMERICAL-ACCEPTANCE32.md), [CDC](../fim24-caps03-cdc03/CDC-ACCEPTANCE73.md).
- Assembler `quartus_asm ofs_top -c ofs_pr_afu` completednative/effective/outer0, with static/original/STA preservation and region-qualified outputs; GBS nativecreate/info/extract each0, payload exactly acceptedPR-RBF. [Assembly28](../fim24-caps03-assembly01/ASSEMBLY-ACCEPTANCE28.md), [GBS34](../fim24-caps03-assembly01/GBS-ACCEPTANCE34.md).
- SDKfile-package13 is complete non-RSU BOOT_INFO/P1 at0, sourceSOF SHA`00dbd01b5b8c7c0b49fb1f9340ac9464e61a634ff045a1c0c4b79a464175d46f`. SDK inputRPD SHA`96fb0dc9e0716a712f9e77a09b11161ac495a6e16436beb756bf7fd04874647e`; GBS SHA`800cc202ca5b3ce239887cd1f9939d11557235d415d470e945d42853e3815f16`. Final file-only97 rehashed retained remoteSOF/GBS/JIC/MAP/RPD against accepted sizes/hashes. JIC is retained packaging material, **never the programmer used**. [Package13](../fim24-caps03-flash01/PACKAGE-ACCEPTANCE13.md), [retained-artifact readback97](final-os97/index.json).
- Original `bw_agilex_flash_programmer` program18 native/outer0 completed erase/program/readback100% and source-defined full-input comparison. Accepted card-only quiescence/BMC Off-On independent readbacks and exactlyone normal workstation reboot followed. [Program42](../fim24-caps03-flash01/PROGRAM-ACCEPTANCE42.md), [deployment60](../fim24-caps03-flash01/DEPLOYMENT-ACCEPTANCE60.md). No JTAG, extra flash/fullverify, replayed removal or second activation/reboot was used.

## Current retained workstation state

Final ordinary OS/file snapshot **2026-10-04T02:37:14.739249+00:00** returnedouter0, with no FPGA MMIO/init/config/reset/power/test call. All five original trial results remain terminal, current module-note/file identities match, cached static FME is **fc603c44-5c8f-5e94-bcbe-a5780030947c**, and boot remains **3e2d2060-d6c0-44b5-a269-1adf1e450041**. PF0 remainsDFL,managementPF1/VF0VFIO,selectedVFgroup76/literalflr,root-visibleholders/maps/D/errors empty; no active/UNKNOWN card owner or scheduled shutdown. [Final OS97](final-os97/readback/result.json).

The cached UUID is source/module-bound probe-time RAM evidence, not cryptographic bitwise attestation of live fabric. Application UUID remains **d48dde9f-f551-578d-8bb0-69483ac95ec6**. Retained hostELFs/SIF/runtime were reused unchanged; no host or FPGA rebuild was done to satisfy a stale metadata requirement.

## Limits remain explicit

1. **Only the exact existing VF pending-before-FLR warning is accepted.** Each original trial retains lifecycle_clean=false/lifecycle_accepted=true and its unsuppressed journal. Different warnings/faults remain failures; no warning suppression/statusclear/resetbypass was added. [User policy](../caps03-runtime01/ERRATUM-ACCEPTED25.md).
2. NumericalSTA positives/printedzerohold/MPW and FIFO CDC coverage are scoped evidence, not a clean all-path/DRC/MTBF certificate. Raw timing_accepted=false/coverage_accepted=false/readiness flags are untouched. Existing static signoff/unconstrained findings remain.
3. Reset support is bounded normal-idle/running initialized vendor clocks, including actual19sys/12bank0 stages and current additional3sys/7bank0 requirements; exact phase allowance remains30163/141ns. No measured waveform/globaldrain/cold/PR/stopped-clock/active-fault universal safety claim. [Review58/consumption62](../fim24-caps03-flash01/NORMAL-ENTRY-CONSUMED62.json).
4. Four electrical warnings have independently reviewed unchanged qualified-baseline carry-forward disposition, not independent SI/receiver/load certification. No new setting/refit was required or warning erased. [Electrical basis34](../fim24-caps03-sta01/electrical-basis34.md).
5. DDR is128-byte-per1KiB sparse coverage across16GiB apertures, not full-byte/all-physical-row coverage; walking is selected logical-address evidence. Bulk closes source-supported concurrentbankfunctionality, **not measured wire overlap or sustained concurrent bandwidth**. No sixth capacity/benchmark gate is invented.
6. SDK comparison covers the full input, not erase padding/wholeflash; retained fallback image is not a fresh device backup. Earlier daemonexit1,readonlypreflight failures,partial parser-failed receipts,initialrebootrequestedfalse and corrected classifications remain preserved at their original hashes.
7. Images/encoded archives/proprietary binaries and over-cap captures remain local-only/SHA-linked. Clean checkout does not include accepted native workspaces, generated databases, images or licensed tools; this is not an end-to-end clean-clone rebuild recipe. Never replay spent admissions.

**`main` remains untouched at141b9a4d064dd96f0974c5d2db498aacc602b00e.** Migration branch `migration-ofs-2026.1-quartus26.1` contains the accepted milestones and final handoff. This goal requires no further action; **the reopened release-wide hls-samples2026.1.0 goal remains incomplete and is Joe's separate later decision**. Stop the migration campaign here, not the whole research backlog.
