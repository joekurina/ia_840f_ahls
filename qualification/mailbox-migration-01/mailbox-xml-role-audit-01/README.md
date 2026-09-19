# Independent mailbox XML role audit

**Preparation and local static observation only. Awaiting fresh specification review, then quality review.** All authorization, readiness, migration-approval, vendor-execution, diagnostic-execution and RTL-certification flags remain false. Nothing here modifies or approves the migration harness.

## Delivered result

- `audit.py`: standalone stdlib Python CLI; explicit leaf/child/parent paths; no migration, collector or vendor imports or execution.
- `test_audit.py`: 24 passing local tests, including mutations of actual retained XML layouts.
- `verification-01/results.json`: final verified local run, exact argv/return codes, interpreter identity/hash, source snapshots/hashes and pre/post reference hashes.
- `verification-01/baseline/report.json`: authoritative final baseline report. Exit **2**, intentionally not an upgraded pass.
- `verification-01/baseline/{leaf,child,parent}.input.xml`: complete original input bytes, not rewritten or synthesized.
- `manifest.json`: SHA-256 of every delivered regular file except itself. Each CLI run also has its own manifest.

The final baseline has **four missing-waitrequest findings**: leaf IP-XACT, leaf locked boundary, child component boundary and child default boundary. Readdatavalid is retained in those representations. No duplicate Avalon role or physical-name collision was found in the parsed baseline role representations. The two representations within the leaf agree, as do the two within the child; agreement does not make the old interface upgraded.

There are also **three explicit incomplete-interpretation findings**, not hidden passes: two IP-XACT address-metadata components without physical port maps (one in each Qsys file), and one parent-file `cmsisInfo` child on another component's interface. These structures and full raw source are retained. Address-space metadata can repeat interface references; it is not treated as a port-map role list. Full XML semantic coverage is always false.

## Baseline coverage matrix

| Input / representation | Expected actual layout | Observed disposition |
|---|---|---|
| Leaf `sdm_mailbox.ip` IP-XACT | 1685-2014 component / busInterfaces / abstractionTypes / abstractionType / portMaps; model / ports declarations | Covered; waitrequest missing, readvalid retained |
| Leaf `lockedInterfaceDefinition` | Decoded boundaryDefinition / interfaces / interface / ports / port | Covered; waitrequest missing, readvalid retained |
| Child module `sdm_mailbox`, `componentDefinition` | Decoded componentDefinition / boundary / interfaces | Covered; waitrequest missing, readvalid retained |
| Child module `sdm_mailbox`, `defaultBoundary` | Decoded boundaryDefinition / interfaces | Covered; waitrequest missing, readvalid retained |
| Parent module `bmc_spi_sub_0`, `componentDefinition` | Decoded componentDefinition / boundary / interfaces | Covered; enumerates external Avalon/proxy mappings, not internal mailbox waitrequest |
| Parent module `bmc_spi_sub_0`, `defaultBoundary` | Parameter explicitly present but empty in actual source | `explicitly_empty_observed`; **not** a parsed boundary and never silently inferred |

All required rows were found exactly once. Wrong nesting, missing required data and duplicate target parameters prevent coverage completion. Optional parent defaultBoundary is accepted only as exactly one explicitly empty parameter or one actual parsed representation; disappearance is not accepted as emptiness.

The scanner parses entire documents, not just target modules: leaf 2 role representations / 3 embedded documents, child 35 / 95, parent 16 / 43. Counts include explicitly unimplemented address metadata. `parse_complete` means XML parsing finished, and `required_coverage_complete` means the named structural representations were found. Neither means complete semantic coverage or approval.

## Interpretation rules

Every mapping is retained as an ordered list entry before `Counter`-based uniqueness checks. No role-keyed dictionary can overwrite a duplicate. Reports include qualified, indexed source paths, `::embedded` transitions, module/parameter context, exact logical and physical names, declared widths/directions, raw port XML and per-representation finding indices. Unknown role-bearing nesting is retained in `unmatched`; document inventories include all element-tag counts. A normalized direction is accompanied by the original XML; observed boundary `Bidir` means `inout`.

Avalon roles must be unique **within each interface**; identical roles in different interfaces are normal. Conduit roles are not subjected to the Avalon duplicate-role rule; physical names must still be distinct. Collision checks cover each boundary and each IP-XACT component independently, not different representations of the same signal. IP-XACT maps must resolve to exactly one physical declaration. Vector expressions and unfamiliar mapping layouts are not evaluated or guessed.

For mailbox `avmm`, the necessary upgraded checks require exactly one `waitrequest` and one `readdatavalid`, each width 1, output, mapped respectively to `avmm_waitrequest` and `avmm_readdatavalid`. Boundary lowerBound must be zero. Explicit termination enables and constant/tie-off replacements are rejected; unfamiliar termination/constant-like fields are incomplete. The ubiquitous `terminationValue=0` is **not** a termination enable. `constantBurstBehavior` is a burst property, not a signal constant. Interface-level serialized markers are scanned as well as individual ports. Same-file leaf and child representations are compared without collapsing duplicate entries.

These are necessary serialized-port checks, not a complete upgrade acceptance implementation. The scanner does **not** certify absence of unrepresented constants, nonconstant generated RTL, or backpressure reaching `sdm_pipeline.m0_waitrequest`. It does not validate the complete old-port retention delta, all hidden/auto parameters, FIFO settings, timing properties, routing/addresses, resets/FLR ownership, SPI/SDM requesters, source resolution, selected versions or protected-system equality. No cross-file stage-coherence assertion is used: stale child/parent proxies can be deliberate at earlier review barriers. Independent stage-specific review is still required.

## CLI and bounds

From `/home/joe`, use explicit absolute input paths and a **fresh** output directory whose parent exists:

```sh
python3 -B /path/to/mailbox-xml-role-audit-01/audit.py \
  --leaf /actual/path/ip/bmc_spi_sub/sdm_mailbox.ip \
  --child /actual/path/bmc_spi_sub.qsys \
  --parent /actual/path/bw_840_support.qsys \
  --output /approved/local/path/fresh-audit-output
```

These example paths are placeholders, not execution instructions for vendor tools. Exact executed input paths and command lines are in `verification-01/results.json`. Re-run the retained local verification with `python3 -B verify_local.py --output "$PWD/verification-02"` from this directory, only if that direct child does not exist. The runner internally uses cwd `/home/joe` and invokes Python only. Direct tests: `python3 -B test_audit.py`.

Exit 0 means only that scoped static checks have no findings; exit 2 means findings, incomplete coverage, or parsing problems; exit 3 means an input/read failure after the exclusive output claim. An existing output directory is rejected before writes (nonzero exception exit); the retained collision test verifies its contents are unchanged. Partial output claims are retained, never reused or deleted automatically. `upgraded_acceptance` is always false, including exit 0.

Bounds per source: 32 MiB per XML payload, 128 MiB cumulative decoded payloads, 500,000 parsed nodes, 128 XML element depth, 8 embedded-document levels. DTDs, entity declarations and NUL-encoded XML are rejected before entity expansion. Embedded strings whose trimmed text starts with `<` are parsed recursively. Unknown metadata is preserved, not treated as interpreted. Input files are opened read-only, nonblocking, with leaf symlink rejection and regular-file checks; inputs are hashed again after the run. This is not a filesystem sandbox or a guarantee against hostile concurrent ancestor replacement. Output parents and invocation must be trusted. Only local output files are written; no network, remote, Tcl, HDL, install, commit or push is involved.

## Evidence history and references

`evidence/red.*` retains the initial test-first expected missing-module failure. `evidence/red-02.*` retains a later actual failing regression run and both source snapshots: three failures exposed Bidir handling, interface-level termination and hidden unexpected nested ports. These were fixed; final `verification-01/tests.stderr` records **24 tests, OK**. Additional coverage tests were added after initial implementation; not every final test is claimed to have an individually recorded red run.

`baseline-01/` is the preserved **pre-fix** exploratory output from the checker in `evidence/audit.red-02.py`. It contains superseded Bidir and address-metadata interface-name findings; use the final verification baseline for conclusions. Its raw XML snapshots remain useful reproducible test fixtures. Nothing was rewritten to make the vendor-derived leaf pass.

`evidence/reference-inputs.json` binds the three candidate XML files, read-only migration.py reference, successor README and retained installed mailbox evidence. The installed core Tcl declares `avmm_readdatavalid` and `avmm_waitrequest` as Output 1 (lines 425 and 427); public/core versions in retained Tcl are 23.0.0 / 21.0.0. These files were read as text only, not sourced or executed. This does not prove live tool/catalog resolution. `evidence/installed-reference-observations.json` records hashes and relevant source lines. All initial reference hashes still matched after verification.

Workflow for future review: inspect the exact source snapshot/hash, run synthetic regressions, make a fresh exclusive baseline observation, review coverage plus unmatched structures, then independently review stage-specific requirements. Do not use the baseline's expected missing port as permission to edit source, migrate, invoke diagnostics or promote readiness.
