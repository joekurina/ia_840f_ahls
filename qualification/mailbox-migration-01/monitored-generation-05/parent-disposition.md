# Minimal-delta generation disposition

Mailbox leaf, child and enclosing parent each generated synthesis/simulation RTL with Quartus 26.1.1, returncode 0 and no recorded Error diagnostics. Actual full logs and source inventory retained. No generation input changed. The two changed maintained-source candidates are exactly the independently accepted refresh02 mailbox leaf and child Qsys; original parent and sibling input hashes match maintained baseline.

Prefer this two-file candidate over parent03: it avoids saved association regression and explicit broader sibling upgrades. Generation still resolves some old IP versions to installed catalog versions; warnings are retained, not suppressed. Top RTL shows 17-bit address/64-bit data, mailbox waitrequest wired into interconnect2, and separate SDM versus shared system reset. Protocol behavior, effective clock/timing and full FIM integration remain unqualified. Original open management service windows/custom input warnings are not solved by this correction.

Local two-file integration and provenance update dispatched. Fresh source-bound authorization/deployment and full OFS RTL/header generation remain next; consumed work03 is not reused. ready_for_build=false.
