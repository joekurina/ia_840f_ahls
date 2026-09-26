# CAPS03 persona evidence

The accepted milestone here is **bounded mapped synthesis**, documented in
[SYNTHESIS-ACCEPTANCE02.md](SYNTHESIS-ACCEPTANCE02.md) and the
[compact synthesis receipt](SYNTHESIS-RECEIPT02.json). It does not grant fitted
timing/reset/CDC, image deployment, hardware numerical or lifecycle acceptance.
The current work state belongs in the repository's `GOAL-PROMPT.md`, not this
frozen milestone report.

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
