# Work21 / CAPS01 — published evidence boundaries

The parent accepts the three groups in [manifest01.json](manifest01.json) for publication under the separate, bounded verdicts in [independent-review01.md](independent-review01.md). This is **not functional AFU acceptance or permission to resume live access**.

| Completed evidence group | Published result | What it establishes |
|---|---|---|
| Deployment | [Work21 flash boot](../caps01-jtag-w13-01/RESULT.md) | Recorded JIC program/verify, activation, and postboot cached Work21 FME identity. |
| VF setup | [Current-boot VF configuration](../caps01-work21-vf01/RESULT.md) | Recorded VF creation/binding, singleton group, permissions, and restored autoprobe. |
| Bounded readiness observations | [Initialization and static loader checks](../caps01-runtime-readiness01/RESULT.md), [reset boundary](../caps01-runtime-readiness01/VFIO-RESET09.md) | Two init-done flags, static runtime-library closure, and cached reset metadata only. |

Publication formatting: the original independent review is retained locally as `independent-review01-original.md` (SHA256 `697d21b26fabea1bd52f50f288aa2ff04eb56ab9422a58b384fe080cfc891146`). The published review differs only by removal of two trailing Markdown spaces on its manifest line; its findings and verdicts are unchanged. All nineteen manifest-bound evidence files remain byte-identical.

## Provenance and chronology

Only manifest-listed files constitute the reviewed evidence subset. Other relative links and image hashes identify retained **local-only supporting material**, not publicly retrievable proof. They do not authorize automatic inclusion of private SDK source, binary-containing receipts, modules, bitstreams, or raw agent transcripts. The source01/accessors02 metadata projections retain sizes and hashes while omitting payload bodies; the original source/module bytes are not published.

Some preparation details and separate outer-return receipts are absent from this subset. Do not describe those as independently demonstrated by the public files. The bounded conclusions rely on the recorded native results and concrete readbacks, as detailed in the independent review.

Earlier “VF absent,” “review in progress,” or “publication pending” wording is stage-local history. Later VF/readiness receipts and VFIO-RESET09 supersede those operational statements; frozen receipts remain unchanged. The mutable CURRENT checkpoint is not part of this publication.

**Hardware work remains stopped.** Independent host recovery is unavailable, and first AFU open/read/close remains unqualified. AFU UUID/capability inspection, DDR integrity, bidirectional transfers, numerical AHLS and sustained-operation testing have not run. The existing programmed image and VF setup are not being repeated.
