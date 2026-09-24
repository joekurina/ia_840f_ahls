# Original startup target01 publication

This commit closes TARGET-ACCEPTANCE.md only: original entry AHLS-image
compile/link/static boundaries. Strict API/entry/unit/target work is separate
and deliberately absent. Default cap2,000,000bytes; raw executable/runtime and
transport payloads, embedded-payload launchers remain local regardless of size.
No oversized payload is split. Selected compiler/link/map/ELF text is retained
byte-for-byte with exact hash-bound whitespace exceptions. Metadata projections
omit only embedded bodies and retain sizes/hashes; they are not executable
replacement launchers or substitutes for the local raw evidence. Inventory and
audit name the allowlist and omitted frozen members. Mutable checkpoints stay
outside this acceptance commit. Historical pending wording in frozen results
is superseded additively by TARGET-ACCEPTANCE.md.
