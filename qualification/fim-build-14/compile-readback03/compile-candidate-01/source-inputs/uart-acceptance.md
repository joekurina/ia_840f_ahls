# Parent acceptance — UART-absent source correction

**ACCEPTED: the one-token source correction and bounded static evidence.** Hardware goal NOT COMPLETE. This supersedes pending-review wording in the immutable [report](REPORT.md); it does not rewrite the reviewed inputs.

Joe selected the old vendor BSP's UART-absent feature scope and excluded dummy-CSR exercising. The maintained disabled branch now uses `12'h0`, not the real UART ID `12'h24`. A private DFHv0 placeholder remains; generated next-offset/EOL, real UART branch, clocks/resets, tie-offs, surrounding logic and AHLS route are byte-preserved. No fabricated clock metadata, driver suppression or HPS enablement was introduced.

## Binding and reproduced results

- [22-file review manifest](review-inputs01.json): SHA256 `737cd5de8639ec44072c3a129814ea5287c9de21c6761f7c6a41e7c7375fb164`.
- [Independent spec review](spec-review01.md): **PASS**, SHA256 `d1d9d87e0e08fb2f1fe24ce400dbfd33c9ed37fb8e3f535899741eaff225cf96`.
- [Independent quality review](quality-review01.md): **APPROVED**, SHA256 `586cdc317207ba6b8c8ed0202b99d9e068e806a2584bbc82392c3b1628ad562a`. No blocking findings.
- Corrected complete-file SHA256: `df74b8e8e04408f2009f398444c5375c0e6ed66fa01452e8f594dfe2712fd60c`.
- Both reviewers reproduced old-ID rejection rc1, corrected-source PASS rc0 and optimized-Python PASS rc0. Parent reverified all 22 size/hash entries unchanged and reran the local static checker successfully before acceptance.
- The checker establishes an exact source delta plus captured APF links, not simulation, native compilation, a full DFL walk or hardware behavior. No dummy-CSR simulation ran; DDR simulation remains SKIPPED BY USER.

[Driver research](driver-id0-research.md) and the reviews support avoiding the captured `8250_dfl` ID/GUID match while preserving this source-described chain link. Generic DFL resource enumeration remains possible. No universal driver-immunity or runtime-safety claim is accepted.

## Next gate and authorization boundary

The source milestone justifies the fresh Work14 FIM build; it does not qualify synthesis, fit, timing or deployment. W13 and the existing persona remain historical artifacts, not accepted timing-clean images. No new native build or hardware access has occurred at this acceptance.

Joe subsequently stated: “Once it's built, you have full approval to flash the card, reboot the system, and do whatever is required to get this built and working as soon as possible!” Flashing and host reboot are therefore authorized conditional on the build being ready; those named permissions need not be requested again. This does not establish a verified independent host-recovery path, a safe finite device-access procedure or a matching image/driver/backend state. Source-bound checks, recovery prerequisites, no speculative MMIO, no blind retries and all actual hardware acceptance tests remain mandatory.

Commit scope: corrected board RTL, its static checker, this evidence directory and narrowly updated parent checkpoint documentation. Exclude unreviewed Work14 build preparation, unrelated prompt/ignore/recovery-document edits and crash-review work.

Publication preserves hash-bound vendor bytes, including their existing trailing whitespace, and the literal blank context line in `uart-only.diff`. A whole-patch whitespace check flags those three evidence files; the authored source/checker/docs check is clean. Do not alter bound evidence merely to remove these provenance-preserving whitespace warnings.
