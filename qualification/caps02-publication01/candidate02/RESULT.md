# Passive observer counter slice — actual RTL tests passed

`test-final.json` binds source/test SHA256 and exact local Icarus12.0 invocation. Production64-bit configuration: **23 cases,109 checks, native0**. Narrow8-bit overflow configuration: **26 cases,115 checks, native0**. Both compile with `-g2012 -Wall` and no diagnostic output.

`negative-control.json` records an intentional mutant that declares an empty native boundary sufficient: it compiles, then fails the very first armed-but-no-output case (native1). This demonstrates that the test rejects the original *kind* of false-retirement inference; it is not a rerun of the cancelled HLS gap study or the original CAPS01 design. Initial missing-module elaboration returned2, preserved as initial missing-feature evidence, not a functional negative baseline.

New module drives no AXI channel signals. It counts nativeAW, declared beats, acceptedW/WLAST, enabledWSTRB bytes and everyB; certifies bytes only at clean complete checkpoints; requires exact epoch volume and fresh token; latches non-OKAY response, identity/accounting/overflow/excess/contamination/link/command faults. Existing modules and image are untouched.

Directed cases cover delayed W/B, zero-output upstream gap, partial masks including upper-half lanes, split-fragment accounting/error, W-before-AW, simultaneous update arithmetic, wrong IDs, uncreditedB, excess output, DMA contamination, link fault, reset, invalid/replayed commands and successful release. Burst/page splitting itself is not instantiated: fragment observations are injected at the declared native boundary. No waveform/protocol verification of the vendor path is claimed.

**NOT INTEGRATED / NOT HARDWARE-QUALIFIED.** The two-clock mailbox/reset-lineage machinery, additive CSR decoder and integration wiring are not implemented in this slice. No vendor synthesis/fitter/STA, numerical kernel start, card access or reset occurred. No PUBLISHED capability exists; controller post-B visibility remains a distinct evidence question. No global-drain/reset guarantee. Independent spec/quality reviews still required before adoption.

Package extracted locally without system installation: Debian trixie iverilog12.0-2+b1; SHA256febe027d2d3f5a7e570844d55758339ab5490acc09f404f214a8719d89d07056. Simulator package/binaries/output files are local-only, not milestone source.
