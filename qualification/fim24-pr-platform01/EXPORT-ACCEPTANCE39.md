# Work24 matching PR/PIM export — accepted with findings

**Accepted:** the completed Quartus 26.1.1 Build 130 release-only PR/PIM export, for fresh offline fabric generation, integrated simulation and compatible persona preparation. **Not accepted by this gate:** persona implementation/timing, hardware programming, PR/reset/CDC behavior or migrated DDR/numerical qualification. [Independent native result review](export-result-review35.md), [independent PIM/closure review](pim-closure-review36.md), [parent consumption](result-reviews-consumed38.json).

## Bound result

One export ran from the fresh Work24 copy using admitted record SHA256 `04a13bd88808fc1af4e4ce4864f6e3883631e681dbb2fe38bd993c25aa39b120` and corrected runner SHA256 `829ec7bb96644f3f2730bf43b571c6f40e7e011d1e42e38931f7b680b2275f14`. Configure/version/export CMake and command-effective codes are zero; the direct vendor targets propagate zero, rather than providing separately instrumented receipts for every internal child. Six accepted callbacks cover five observed contexts, including 26.1.1 IPC4 with duplicated `--dni`. All native ownership is ended. [Actual result](completion31-readback/operation/result.json), [completion](export22-completion-event.json), [374-member freeze](actual-result-freeze34.json).

Release `/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01` matches:

- Interface UUID: `fc603c44-5c8f-5e94-bcbe-a5780030947c`.
- Static QDB SHA256: `dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4`.
- Base SOF SHA256: `16812c62675e31bb7d3bdbdce80e9342c32bb7263c6a862611da427249c85195`.
- MSF/PMSF sizes and hashes match the accepted Work24 bindings; blue-bits SOF links to that matching copy. The preserved base green RBF is not asserted exported or usable as a persona payload. [Review35](export-result-review35.md).

All 6,160 original Work24 entries, 2,541 critical inputs, 276 PIM members, tools/providers and five original static artifacts pass their captured preservation checks. Release inventory has 3,454 entries. All 211 generated PIM files and 94 QIPs are bound; every one of 1,519 QIP file assignments resolves to an inventoried regular file (1,448 distinct targets), including HEX, SDC_ENTITY_FILE and TCL_ENTITY_FILE. This is declared-edge membership, not an independent local rehash of every target body or recursive encrypted-IP semantics. [Parent graph verification](routing-closure37.json), [edges](qip-edges37.json).

## Explicit disposition of the preserved raw rejection

**Raw outer/supervisor1 and `execution_clean=false` remain unchanged.** They arose solely because two pre-existing files in the owned copy changed beyond the runner's QSF/QPF allowance:

- `dni/checkpoints/manifest.txt`: the native checkpoint directory index now names `ofs_pr_afu` alongside `ofs_top`, with serialization bookkeeping changes.
- `dni/sandboxes/.properties.folder.kvp`: exact sandbox PID replacement319273→333868, matching the observed prior Work24 and export synthesis identities.

Before bytes match original Work24 and the admitted preinventory; all other 4,283 pre-existing copy entries remain identical. Existing checkpoint payloads, source and static artifacts are unchanged. Review35 accepts these exact captured changes as native A&E bookkeeping. This acceptance is a separate engineering disposition—not a rewritten success flag, blanket DNI exemption, generic Boost decoder claim or reason to rerun export. [Four exact bytestrings](closure32-readback/), [postflight index](actual-result-index34.json).

## Retained findings and routing clarification

The archive's 73 ordinary warnings reconcile exactly: IDs13461×1,24420×1,21610×70,23762×1. Empty-template PCIe/memory outputs tied to GND are not active-persona results. The 0/10 elaborated DRC result does not supersede Work24's 23/88 signoff findings or PR/electrical/reset/freeze limits. Unmatched warning/reset targets, malformed unconsumed ASP preset and proxy/leaf outstanding16-versus-1 findings remain disclosed. [Review35](export-result-review35.md), [physical acceptance](../fim-build-24/PHYSICAL-ACCEPTANCE47.md).

Review36 correctly derives the AFU route as PF0/VF0, but its proposed PF1 discrepancy conflates roles. The campaign's PF1 requirement is the static non-VF BMC function; generated routing, hash-matched board RTL and qualified CAPS03 history agree with PF0/VF0 for the AFU. No topology change is required. Fresh live identity/BDF/ownership checks remain mandatory later. [Source-grounded disposition](ROUTING-DISPOSITION37.md).

## Next boundary

Preserve this release and all spent authority. Reuse the verified corrected HLS inputs and CAPS03 sources as data, regenerate the fabric under26.1.1, bind matching simulation/PIM inputs, then implement a new persona against this UUID/QDB. Application setup supplies its AFU QSF/top configuration; unset `OPAE_PLATFORM_GEN` and `BBS_LIB_PATH`. A fresh scope must replace—not bypass or reuse—the ended release callback owner. No unchanged standalone HLS or completed native export is rerun. Deployment and all card-bound migration gates remain open.
