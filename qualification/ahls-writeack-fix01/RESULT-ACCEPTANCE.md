# Parent acceptance: zero-allowance write acknowledgment

**ACCEPT_SCOPED_SOURCE_AND_UNIT_ONLY.** Complete-kernel, native component import, DMA/PIM, timing and hardware acceptance remain open.

The parent consumed the FINAL [independent review](independent-review01.md), SHA256 `5ef3a28732020c6baa33bd8cdb58cb2fd3b7429a0aad536d2492e22a8a9f423e`, with separate specification and quality/functional-evidence passes and no blocker within the stated scope. All21files/221,473bytes of the frozen [review package](review-package-sha256.json) were independently reverified unchanged by the parent.

Accepted source: [the patch](../../afu/ahls_memory/patches/zero_allowance_writeack.patch) changes the synthetic acknowledgment producer to count accepted output beats when allowance is zero, without changing its register/routing or other branches. Original SHA256 `35ec54a3a59e24a52b317a6cba670499061bba1ff00d5ba5e6bcc6726421ddbe`; complete candidate SHA256 `f9defb182dcca3d3d299eb1e2ee060ce730caa24b2bd613d44f8c05abaccfdcd`. The original generation and installed library remain unchanged.

Accepted evidence: [red03](result-red03.json) reproduces the original false acknowledgment at106ns with write1/waitrequest1/ack1/expected0; [green01](result-green01.json) passes5groups/796cycles/2491checks/107accepted107acknowledged. Fixture, unchanged pending counter, final driver and tool settings match; only the complete source and extracted DUT block differ. Native zero is not treated as success: final acceptance rejects Fatal/error summaries and missing/incorrect pass data. Earlier failed setup and insufficient return-propagation attempts remain preserved in [RESULTS.md](RESULTS.md).

Scope is the source-extracted acknowledgment block and the unmodified COUNT_WIDTH=8 pending-counter fixture. The107acceptances include2truth-table samples under reset and105balanced-transaction beats, not107complete-kernel invocations. Other-mode tests show expression preservation only. Full FIFO/LSU/kernel interactions and physical-memory/host visibility are not established.

Controls are bounded normal-account execution, not an OS sandbox. The16GiB limit is per process, not aggregate process-tree memory. The installed INI identity was bound and copied; the working INI lacks a separate post-execution inventory entry, so no stronger whole-environment preservation claim is made. These explicit qualifications do not invalidate the narrow observed regression result. [Independent review §§3–4](independent-review01.md#3-runner-controls-and-evidence-qualifications).

This milestone neither grants hardware authority nor changes readiness flags. DDR simulation remains SKIPPED BY USER. Native25.1 import proceeds as a separately evidenced safe offline step, not as an already accepted result.
