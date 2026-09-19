# Finite follow-up collector — prepared, not remotely executed

## Outcome and scope

Created `collect-followup-evidence.py` for the five queries in the pinned
`next-evidence-request.json`. No remote connection, vendor/Java/Tcl/ELF execution,
build, scratch creation, harness/template/source/proposed-binding edit, deployment,
or approval was performed. All emitted readiness, review and authorization flags
remain **false**. This evidence supports independent authorization of the **first
bounded experiment**; successful loading/API/project behavior is not a circular
prerequisite for authorizing that experiment.

Collector SHA-256:
`00129d1922120531100bb842eecd8ff264f017c5fd173c57f9dbeaacae87e12a`.

Pinned prerequisite identities (checked before installed-file collection):

- `next-evidence-request.json`:
  `8ca7745b67b51a1aadbd1ba2ad9982d14e48fee56c31a2ef6584f54659b4e9aa`.
- `binding-evidence-live02.json`:
  `0c13de271466b3db1fd10585f99d965886a662e67d8421022bceceb9c768c0ed`.
- `collect-binding-evidence.py`:
  `b47e32cdcc75e4782e9d8c2a925be7b93deafb44257a4ae989ca38266a77e717`.

The existing collector is loaded into a non-main namespace only after its exact
hash matches. Its `main()` is never called. Only its static inspection and path
helpers are used. Run isolated Python with bytecode writes disabled as below.

## Exact future invocation — NOT run

After separate authorization/deployment and byte-identical readback of the collector
and prerequisite files, run **on Agilex7Workstation as uwb_student00, already inside
existing tmux session `ia840f_migration_preflight`**:

```sh
cd /home/uwb_student00/ahls/new_BSP/qualification/mailbox-migration-01 && \
/usr/bin/python3 -I -B ./collect-followup-evidence.py \
  --receipt-name followup-evidence-live01.json
```

No SSH, tmux creation, send-keys, deployment, or vendor command is included. The
receipt basename must be unused. Main checks exact host, user, script directory,
cwd, no symlink context, TMUX/TMUX_PANE and read-only `/usr/bin/tmux -N
display-message` session/pane metadata. That metadata query is the only subprocess;
`-N` prohibits starting a tmux server. The sole intended write is the new mode-0600
JSON receipt in the existing qualification directory, opened with
`O_EXCL|O_NOFOLLOW`, then read back. No mkdir/cleanup/retry occurs. A partial receipt
is retained on failure. Ordinary filesystem read access may affect atime; this is
not a read-only mount or adversarial-race sandbox.

Deployment of the repaired help receipt was reported separately by the parent;
this task neither repeats that deployment nor independently claims remote readback.
Historical live02 identities are not relabeled as fresh observations.

## Implemented finite queries

1. **SPI/catalog declarations.** Stream directory entries under the sole requested
   IP root, without following symlink directories; skip discovery symlink files too.
   Inspect supported Tcl/index/XML/config text names (including alternate Tcl names),
   preserve all finite-kind textual/index matches and NAME/VERSION lines with path,
   content hash and line number. Keep competing matches, never infer uniqueness or
   actual selection. Full SPI-containing sources/indexes and default-search
   references share the 24-full-file cap. Caps: 250000 directory entries, 12000 text
   attempts, 2097152 bytes/file, 24 full matches. Record kinds without a text match.
2. **Launcher/classpath/package.** List candidates within the four fixed roots, depth
   four; caps: 12000 entries, 40 configs, 80 distinct archives inspected/hashed,
   250000 aggregate members, 40 resources including manifests, 2097152 bytes/resource.
   Use Python `zipfile`, never Java/jar. Manifest continuation unfolding retains
   literal Class-Path order and Main-Class lines; config/reference lines are retained
   verbatim. Resolve only safe literal manifest-relative or absolute classpath JAR
   tokens under the installation. Hash only explicitly referenced archives, not all
   enumerated JARs. No recursive manifest/classpath follow-up. Inspect bounded
   API/provider/version/package/Tcl member names and manifests, storing individual
   resource hashes/text (binary resources: identity plus API string observations).
   APIs not observed are explicitly listed. Classic ZIP EOCD prechecks member budget
   before `ZipFile` allocation; ZIP64/split files and central directories above an
   additional conservative 64 MiB limit are reported unresolved, not extracted.
3. **Direct native identities.** Only root/name combinations from the request, plus
   its interpreter/cache paths. Cap 100 matched paths, including those two extras;
   retain misses and capped candidates. Use pinned static Python inspector for full
   hashes, component-wise symlink chains and ELF NEEDED/RPATH/RUNPATH metadata.
   Newly observed dependencies are never queued. All identities are candidates,
   not selected loader paths. Existing live02 identities are referenced, not reread.
4. **Helper edges.** Read the five exact helpers from hash-pinned live02, not from the
   workstation filesystem. Local inspection found no noncomment literal source or
   package require/ifneeded edge requiring another file. Therefore collect **zero**
   additional helper files: within both the one-edge limit and 16-file ceiling.
   Preserve source/package/exec/fileset reference lines without Tcl evaluation or
   guessing callback activation. Perl/fileset generation references do not trigger
   recursive collection. No dynamic closure is asserted.
5. **Context.** lstat scratch and ancestors, reject existing scratch or symlink
   ancestors, record host/current named tmux metadata. Check license pathname
   readability with `os.access`, never open license contents. Record closed experiment
   environment policy and presence-only injection/license variables. Explicitly
   retain never-used-history uncertainty and absent process/external-write observer
   approval. The durable claim policy remains exclusive scratch mkdir, retention on
   failure, no automatic cleanup/reuse. No scratch or claim is created here.

All limits come from the hash-pinned request. Enumeration is filesystem order, not
an installation-wide sorting/materialization pass. Caps, inaccessible files,
oversize texts, unsupported archives, skipped links, depth exclusions and ambiguity
produce a finite unresolved list; they never trigger another pass. Historical reuse
is explicitly labeled **not a fresh identity revalidation**.

## Local verification actually performed

Ran import-safe Python fixtures with `python3 -I -B`, **not production main**:

- Recomputed pinned live02 hash; parsed 358 records; all had hashes, none had errors
  or false expected comparisons. Recomputed all complete embedded text hashes.
- Verified all ten requested exact-file identities already exist and are reused
  without new inspection; parsed all five helper bodies and confirmed no additional
  literal source/package-require/provider edge to collect.
- Fixture competing SPI definitions with alternate filenames both retained;
  oversize text, directory-entry cap and symlink skipping exercised.
- Fixture JAR manifest/provider resources parsed; only the explicitly referenced
  classpath archive was whole-file hashed; resource and aggregate member caps tested.
- Fixture direct native candidate cap exercised without recursive expansion.
- AST/syntax checks passed; sole subprocess and exclusive-output flags checked.

All fixture assertions passed (exit 0). Fixtures used temporary local directories,
were removed by their temporary-directory context, and are not installed evidence.
The workstation guard, real tmux metadata, actual installed ZIP layouts, current
scratch/license state and receipt creation/readback have **not** been exercised.

## Honest residual limits / authorization items

- Text/filename heuristics do not parse arbitrary Tcl, XML catalog schemas, shell
  expansion, Java registration or computed classpaths. Unsupported encodings,
  comments, aliases and dynamically constructed kinds may remain unresolved.
  Textual matches are not automatically declarations; declaration/index evidence is
  kept separately. Full-text cap can omit a later SPI source; the receipt records it.
- Config discovery may consume its finite budget before the most relevant file;
  archive budget likewise may leave referenced archives uncollected. Every such cap
  is explicit. No fallback installation-wide search is permitted.
- Static ELF helper parses only little-endian ELF64, with a 2 MiB metadata prefix;
  it hashes entire files but can report incomplete metadata. It is not `ldd` or an
  actual loader trace. Symlink candidate evidence does not change harness policy.
- Filesystem stability checks are observational, not atomic whole-installation
  snapshots. ZIP resources from an archive flagged changed must be rejected.
- Scratch absence cannot establish never-used history. License readability is not
  license validity/checkout behavior. Monitoring mechanism, allowed caches/logs,
  process/write boundaries, stop/retain behavior and intentional license environment
  addition still need an independent concrete decision. No monitoring was installed.
- No build or experiment is authorized by this collector or a successful receipt.
  Review the finite results and residual uncertainty once; actual API behavior,
  selected catalogs, project acceptance and serialized deltas belong to controlled
  experimental acceptance, not endless pre-experiment graph expansion.
