# IA840F raw-capability ABI qualification

Accepted scope: the additive read-only capability RTL, native CSR RED/GREEN differential and pure offline C decoder tests. Start with [UNIT-ACCEPTANCE.md](UNIT-ACCEPTANCE.md), [ABI01.md](ABI01.md), and the [FINAL review](independent-review01.md). The old metadata fields are not repaired. No deployed image, measured clock, timing or hardware claim is made.

## Evidence publication policy

Files larger than 2,000,000 bytes remain local and are referenced by exact size/SHA256. Raw JSON transport captures, payload-bearing generated launchers, ELF test binaries, vendor/runtime binaries and license material remain local irrespective of size. No splitting bypasses the cap. The original reviewed bytes remain unchanged in this qualification directory. [Publication inventory](PUBLICATION-INVENTORY01.json) lists selected and omitted files.

`red01-config-metadata.json` and `green01-config-metadata.json` remove only source base64 bodies from the actual runner configurations; hashes and existing length fields remain. Only three payloads have declared lengths; the other 24 lengths were derived during verification. The result projections remove only embedded log text, which is published byte-identically under `artifacts-red01/` and `artifacts-green01/`. Reconstruction of each projection was verified against its original object. Metadata is not an executable replacement launcher.

Captured native whitespace is retained through exact file/hash-bound audit exceptions. Native compiler and simulator warnings are counted separately: four repeated compile occurrences and two simulation occurrences per run. Mutable CURRENT.md, active CAPS01 build state and other reviews are outside this milestone. No raw agent transcripts are published.
