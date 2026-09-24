# Parent acceptance — AHLS-image OPAE compile/link and backend builds

**ACCEPT WITH FINDINGS, completed build evidence only.**

The parent read the complete FINAL [review](apptainer-independent-review01.md)
and rehashed119 frozen files /10,094,673bytes, zero mismatches. Specification
PASS; acquisition/evidence quality sufficient within the stated gate. Report
SHA256 `da5cdfbcd392f34b22cfb35f4bc302c0af7015c7aef8a9a607a8e9fd92b49cff`; package
`637f17d46bcc365cc5378ae1aafc6ac0df0baa534ff2c71008aa1e277e2fa10e`.
[Parent verification](apptainer-parent-review-verification01.json).

Accept build10's actual SDK core and unchanged frontend compilation/link and
backends11's named opae-v/xfpga library builds inside the existing pinned AHLS
SIF. Native/effective/outer0/0/0,17/21 exports,1,177 tracked SDK entries and568
selected predecessor file/link entries are bounded observations. Original SIF,
SDK inputs and predecessor artifacts remain preserved. No unchanged rerun is
required. See [scope](APPTAINER-SCOPE01.md), [results](APPTAINER-RESULTS01.md).

Retain all five ranked review findings. In particular, literal RUNPATHs end
in colons and include empty current-directory elements; these are scratch
builds, not accepted deployment paths. Six dependency-cache entries changed
types without value changes and generated makefile count changed37→39; do not
claim identical CMake caches. The reported frontend chmod0600 was performed by
the successful script but exported byte records do not independently verify
mode. Recorded gpgv plus signed-index/package chains are accepted provenance,
not a new independent signature/unpacked-file validation. Supervision covers
observed completed paths; tracked/subtree preservation is not total filesystem
attestation, complete toolchain closure, escaped-descendant control or aggregate
resource protection. Optional dependency messages and unused RUN_LDCONFIG remain.

No frontend/OPAE-library/backend execution, runtime selection/loading, driver
or system installation, hardware safety, FPGA deployment, physical DDR/DMA/AHLS,
full design closure, lifecycle or boot is accepted. The separate DFL-config
parser and startup-ordering candidates have their own gates and are not part
of this acceptance. Vendor DDR simulation remains SKIPPED BY USER.
