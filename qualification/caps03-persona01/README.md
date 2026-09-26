# CAPS03 persona evidence

Accepted milestones here are **bounded mapped synthesis** and **steady-state
physical timing/CDC at the unchanged 3.000 ns target**. See
[SYNTHESIS-ACCEPTANCE02.md](SYNTHESIS-ACCEPTANCE02.md), the
[compact synthesis receipt](SYNTHESIS-RECEIPT02.json), and
[PHYSICAL-ACCEPTANCE01.md](PHYSICAL-ACCEPTANCE01.md). Reset-entry sequencing,
image deployment, hardware numerical and lifecycle acceptance remain separate.
The current work state belongs in the repository's `GOAL-PROMPT.md`; these
acceptances do not turn an active successor into a completed result.

Publication follows the repository's **2,000,000-byte per-file cap**. Full replay
capsules containing embedded payloads, full over-cap metadata, oversized native
reports, bitstreams, tool/license binaries and transport archives stay local.
Omitted captures retain exact sizes/SHA256 in the compact receipt. Raw reports
are not split to evade the cap, and the compact receipt is a summary rather than
an executable substitute for the full retained record.

Small captured files are published verbatim. Native whitespace is retained and
any `git diff --check` findings are matched to the exact manifest-bound raw paths;
newly authored code and prose must be clean. The local pretty-printed synthesis
receipt has its own byte hash; serializing its parsed object with native sorted
JSON reproduces the original remote result hash, as recorded in the compact
receipt. The selected runtime CMake capture belongs to this synthesis run, not a
claim that later maintained CMake targets have completed.

Active fitter/STA progress, unaccepted physical-stage results and the mutable goal
checkpoint are excluded from the synthesis acceptance commit. The publication
manifest names the exact selected files and hashes; all other working edits are
preserved.
