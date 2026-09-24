# AHLS-container build publication

This commit closes only [APPTAINER-ACCEPTANCE.md](APPTAINER-ACCEPTANCE.md).
It does not accept the separate DFL-parser or explicit-startup candidates.

The exact selected metadata/text evidence and omitted frozen sizes/hashes are
in `APPTAINER-PUBLICATION-INVENTORY01.json`. All selected files are below the
2,000,000-byte cap. Raw result archives, ELF/package payloads and embedded-payload
launchers remain local under the directory ignore policy, hash-referenced.
Launcher projections remove only encoded payload values; reinsertion restores
the original Python AST exactly. They are metadata, not executable replacements.
Result projections omit base64 bodies but retain all other recorded values.

Native whitespace in frozen text exports is retained with path/hash-specific
dispositions in the publication audit. No source/install/runtime/hardware action
is implied. Mutable checkpoints and in-flight gate files are excluded.
