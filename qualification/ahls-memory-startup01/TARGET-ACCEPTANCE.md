# Parent acceptance — original entry AHLS-image compile/link

**ACCEPT WITH FINDINGS** the completed target01 compile/link and static boundary
only. [FINAL review](target-independent-review01.md),
[parent identity verification](target-parent-review-verification01.json).

Parent read the complete FINAL, captured SHA256
`92447100ee94287dba2aa1141424a5aeea07b9ea5e0aeda01351a4c9d446a89d`, and verified
all52 frozen files /2254639bytes against packageSHA256
`7af02abc5f5c861426b7d8f211c9bf8057fa2bb075e6fbeb4c1d09a192c966c7`.
Native/effective/outer0/0/0,13 inner commands rc0,27 hash-verified payloads,
all preservation flags true and no timeout/survivors. The review independently
decoded both target ELFs and core symbols; launcher JSON-C/libc and entry
OPAE/libc direct dependencies,3 bridge exports and22 OPAE imports matched.

Retain all four review findings:
- Actual initialization's default fallback and partial-state/finalization behavior
  are not exercised or accepted. Sealing alone does not eliminate reread/parser
  allocation failure. The new opt-in strict candidate is a separate gate.
- New outputs have explicit nonempty build-context RUNPATHs; inherited SDK/core
  trailing-colon paths and transitive loader identity remain unqualified.
- CMake unused FETCHCONTENT_FULLY_DISCONNECTED warning remains. The script sets
  output modes0600, but exports do not independently attest remote modes. That
  evidence distinction needs no unchanged rerun.
- GCC11.4 target linking does not establish functional equivalence to GCC14.2
  UBSan inert tests, device isolation or hardware safety.

No source/result was rewritten, no native stage repeated, no real target/backend
executed. This closes the original startup's missing target-image compile/link
item only. No runtime/DFL/MMIO, DDR/DMA, numerical AHLS, lifecycle/full-signoff or
flash boot acceptance. Vendor DDR simulation remains SKIPPED BY USER.
