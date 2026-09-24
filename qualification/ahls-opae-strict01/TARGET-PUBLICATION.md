# Target milestone publication policy

This commit closes only TARGET-ACCEPTANCE.md. Native/effective/outer 0/0/0; 16 inner commands; 33 verified exports. Compile/link and static ELF integration only, not runtime or hardware.

Per-file cap: 2,000,000 bytes. SDK/header/runtime payloads, executable images,
raw transport archives and payload-bearing launchers remain local regardless
of size. The publication inventory records omitted frozen members and hashes.
No raw artifact is split to evade the cap. Target projections are explicitly
payload-free metadata, not executable substitutes for their source evidence.
Selected native compiler/ELF text retains exact bytes; any whitespace exception
is individually hash-bound in the audit. New authored files must be clean.
Existing root and local ignore policy remains intact; only the explicit approved
allowlist is force-added. Frozen pending wording is superseded by acceptance;
mutable CURRENT/checkpoint files and other unaccepted gates are excluded.
