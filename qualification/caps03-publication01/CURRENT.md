# Final publication checkpoint

The scoped CAPS03 memory-HLS qualification is complete. All actual-result reviews
are consumed, the [six normal lifecycles](../caps03-lifecycle01/reconciliation04.json)
are reconciled, and the [final acceptance](../caps03-final01/ACCEPTANCE.md) closes
the maintained goal. No build, hardware run or review is pending.

Each milestone below was separately committed and pushed. Its exact committed
path set and every blob were rechecked against the manifest; saved readbacks bind
local HEAD, origin/main and live remote main at that milestone. These are historical
branch values, not assertions that every prior commit is simultaneously current
([final verification](../caps03-final01/verification01.json)).

| Milestone | Commit | Files | Evidence |
|---|---|---:|---|
| assembly01 | `d7c2853893cdcc425c254b9a886c1dc9bcaf388f` | 21 | [manifest](assembly01-manifest.json), [remote/blob verification](assembly01-publication-verification.json) |
| sdk02 | `dc59a7269763ed4324a81cb339dc79fe50df21e6` | 20 | [manifest](sdk02-manifest.json), [remote/blob verification](sdk02-publication-verification.json) |
| normal03 | `cb5ab4269e9530f1f8cfcca99fa530b0cbe03cd6` | 130 | [manifest](normal03-manifest.json), [remote/blob verification](normal03-publication-verification.json) |
| ddr05 | `0f83bc00d654ded0c57d3d036238c330f135dacd` | 32 | [manifest](ddr05-manifest.json), [remote/blob verification](ddr05-publication-verification.json) |
| walk06 | `95bb75504c6393ac78bc62aa841502618c909628` | 29 | [manifest](walk06-manifest.json), [remote/blob verification](walk06-publication-verification.json) |
| bulk07 | `481760e65b592eff7bb7c011d63298c4286aff76` | 31 | [manifest](bulk07-manifest.json), [remote/blob verification](bulk07-publication-verification.json) |
| full08 | `68ed8ba142078bcd70864d87d86bcca1dfe2ef83` | 32 | [manifest](full08-manifest.json), [remote/blob verification](full08-publication-verification.json) |
| coverage04 | `08a849bf09f4e44b625d2073367630a5af7576e7` | 31 | [manifest](coverage04-manifest.json), [remote/blob verification](coverage04-publication-verification.json) |

This final checkpoint is committed as a separate closure of the agreed qualification,
not another hardware gate. Its own post-push exact-set/live-main readback is saved
locally as `final09-publication-verification.json`; it is generated after the commit
rather than embedding a circular self-hash here.

Native Design Closure FAIL, lifecycle_clean false, original live21 outer1 and
coverage outer unknown/null remain. The excessive full-DDR runtime is a harness
defect, not bandwidth. No operation was replayed to publish these results.
Unrelated root `.gitignore` and `docs/hw-programming-recovery.md` changes are preserved
and excluded from this final commit. Payloads, bitstreams and files larger than
2,000,000bytes remain local-only and hash-bound.
