# Plan diagnostic01 evidence

See RESULT-ACCEPTANCE.md for independently reviewed, parent-consumed **failed/stopped native execution evidence only**. No hold-objective/timing or hardware acceptance. Successors are separate gates and not part of this milestone.

Default publication cap:2,000,000bytes/file. `.gitignore` excludes the oversized raw prepared-readback02/candidate.json; its exact bytes are losslessly recoverable from preparation02.json.gz (`files`→candidate.json→base64), with byte count/SHA256 in prepared-manifest02.json. The archive also binds every actual prepared input. result01.json.gz similarly preserves all7 result exports. Native worktree/database/bitstream payloads and raw agent transcripts are not published. No license contents, installer or runtime binaries.

Keep raw vendor SDC, logs, diffs and generated captures byte-for-byte, including original whitespace. New authored prose/code is distinct from immutable captures. Failed initial ordinary preparation is preserved as prepare01.py/preparation-failure01.json; the successful prepare02.py normalized only exact symlink record representation before creating the still-absent exclusive leaf.
