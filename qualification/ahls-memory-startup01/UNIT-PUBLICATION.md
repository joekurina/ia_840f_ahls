# Inert-startup publication policy

This commit closes only [UNIT-ACCEPTANCE.md](UNIT-ACCEPTANCE.md). Target01's real
AHLS-SIF compile/link is under separate review and deliberately excluded.
The default per-file cap is2,000,000bytes. SDK/runtime/compiled fixture payloads,
raw transport archives and embedded-payload launchers stay local/hash-referenced
regardless of size; full process matrices and special-file fixtures remain
local under this gate's frozen .gitignore policy. Nothing is split to evade caps.

[Publication inventory](unit-publication-inventory01.json) names every omitted
frozen member with its size/SHA256. [matrix01-metadata.json](matrix01-metadata.json)
is explicitly a payload-free per-case rc/hash projection, not replacement trace
evidence. Selected small immutable maps/link/ELF/compiler text are allowlist
exceptions to broad build-directory ignores. Native whitespace is retained with
exact path/hash diagnostics in the publication audit. Authored sources/prose are
clean. Frozen pending-status prose is superseded by the later acceptance without
rewriting its bytes. Mutable checkpoints and target01 artifacts are not staged.
