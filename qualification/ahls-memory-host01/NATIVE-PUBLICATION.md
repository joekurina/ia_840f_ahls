# Workstation-native memory frontend publication

This milestone closes only [native compile/link and static ELF acceptance](NATIVE-ACCEPTANCE.md), following the FINAL independent specification/quality review. It does not include AHLS-container acceptance, source-to-host-map acceptance, or hardware access.

The explicit allowlist and size/SHA256 bindings are in `NATIVE-PUBLICATION-INVENTORY01.json`; commit-scope verification is recorded separately. All published files are below 2,000,000 bytes. Raw transport archives, the embedded-input runner, and executable remain local-only and are hash-referenced in that inventory and `native-evidence-metadata01.json`. The payload-free template and metadata projection are evidence, not replacements to execute.

Existing accepted frontend source/inert evidence is inherited from parent commit `842a52d1ec965eae122d208067fc004399dec224`. Preserve the original reviewed whitespace and receipts; use narrow manifest-bound whitespace dispositions if necessary. No system install, OPAE application execution, FPGA access or RTL change is included. Mutable CURRENT.md and the pending container review are excluded.
