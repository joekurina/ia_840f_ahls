# Release-template evidence publication policy

This milestone publishes the independently and parent-accepted **export03 PR/PIM release template evidence**, not a deployable persona or completion of the hardware goal. [Acceptance](RESULT-ACCEPTANCE.md) is current; preparation/pending wording in frozen predecessors remains unchanged.

The explicit [publication manifest](publication-manifest01.json) binds every included file except itself and records omitted frozen members by SHA256. Default cap is **2,000,000 bytes per published file**. All compressed transport archives, payload-bearing serialized runners, copied vendor/installed source directories, boundary source mirrors, the oversized staging manifest and full synthesis reports remain local/hash-referenced. Small reviewed native logs, result metadata, flow/DRC reports, authored collector/gate/template sources, source/tool/path inventories and acceptance documents are included. No image/QDB/runtime binary, license bytes, secret, installer or raw agent transcript is included.

Preserve native/frozen whitespace and bytes rather than normalizing them. Staging verifies the explicit set and each blob against this manifest, with per-file hash-bound exceptions for native/frozen whitespace diagnostics. Source-bound scripts are retained evidence, not permission to replay consumed native authority. Publication does not execute them.

Large remote image identities are captured receipt/inventory evidence, not claims that Git contains those files or that this publication freshly rehashed the remote workstation. Original Work21 and unrelated working-tree edits are preserved. This gate is separate from actual-persona setup, mapping, fit/STA and hardware acceptance.
