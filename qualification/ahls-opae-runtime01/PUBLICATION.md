# DFL configuration/parser publication

This milestone closes only [ACCEPTANCE.md](ACCEPTANCE.md): the additive,
uninstalled configuration and completed parser-only results. Explicit startup,
real runtime loading and hardware are separate gates.

[PUBLICATION-INVENTORY01.json](PUBLICATION-INVENTORY01.json) binds selected files
and all omitted frozen sizes/hashes. The default per-file cap is 2,000,000 bytes.
Raw executable/runtime/package payloads, embedded-source captures and local SDK
snapshots stay local/hash-referenced even below the cap; no payload is split to
evade it. Directory .gitignore retains these exclusions. Explicitly force-added
small immutable text reports, matrix fixtures/results and link/map evidence are
allowlist exceptions, not a relaxation of the raw-payload policy.

Malformed JSON fixtures are intentional negative inputs. Native whitespace in
captured text is preserved and hash-bound in the publication audit; authored
code/prose must be clean. Historical pending text in frozen RESULTS01.md does
not supersede the later acceptance. Mutable CURRENT files and the separate
startup candidate/review are not part of this commit.
