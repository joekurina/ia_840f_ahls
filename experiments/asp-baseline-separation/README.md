# Archived ASP experiment and baseline separation evidence

**Inactive historical source, not a supported transport or executable workflow.**
Do not run scripts preserved under `pre-edit/`. The application-specific DMA
hostchannel experiment was removed from the active common ASP only after full
file copies and hashes were verified. No build, simulation or hardware
qualification was performed.

- `pre-edit/`: lossless original bytes, including every pre-edit ASP delta from
  pinned upstream and related ABI/application/documentation context. Inclusion
  does not mean every archived file was experimental: legitimate board files and
  identity selection were deliberately saved too.
- `preservation-manifest.json`: original source paths, SHA-256, size, modes and
  corresponding pinned-upstream metadata. Never repin this historical manifest.
- `pre-edit-active-inventory.json`: entire active ASP pre-edit content inventory
  excluding Git administrative files.
- `preserve.py`: the one-shot source-only preservation operation used here;
  refuses to overwrite an existing manifest. It is not an install/build script.
- `static-audit.py`: source-only parsing/hashing/diff checker; no project code or
  vendor tools are invoked. It writes `static-check-evidence.json` and
  `baseline-separation.diff` when explicitly run.
- `static-check-evidence.json`: checked references, 145 check outcomes, standard
  and USM contracts, retained gates and exact active changes.
- `baseline-separation.diff`: full pre-edit-to-active textual difference.
- `changed-files.json`: complete worker-owned added/modified/deleted path list.

See [the modernization review](../../docs/asp-modernization-review.md) for
reference provenance, exact restored/removed paths, qualification gaps and the
nine retained board-local gate files. Original reference trees were not modified.
The other files under `new/interfaces`, `new/afu` and earlier `new/docs` remain
outside this worker's edit scope; their snapshot here does not change those
original paths or establish board support.
