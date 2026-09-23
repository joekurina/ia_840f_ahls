# CAPS01 actual Work21 setup and mapped synthesis — parent acceptance

## Decision and identity

**ACCEPT WITH FINDINGS** the completed actual Work21 setup01 and full native mapped synthesis01 only. Independent specification PASS / quality PASS WITH FINDINGS; no substantive blocker or unchanged rerun is required. [FINAL review](synth-independent-review01.md), [scope](SYNTH-SCOPE01.md), [native results](RESULTS-SYNTH01.md).

Parent read the complete FINAL report (204 lines / 26,704 bytes), matched returned SHA256 `45e4acbdb9184dcc6b6d8e6d175b566d5ee24835d4e8919feacb1866afb8bb18`, and rehashed all **42 frozen files / 84,379,291 bytes** against package SHA256 `802e96d7a3d0f8c742d8b59b5154aae3cd34e89d0ed0fd914c9ffe0f26443834`. Both archives and all **7 setup / 11 synthesis exports** match their exact captured bytes. Parent reconstructed all **4,345 critical bindings**, verified runner/template and dispatch identities, source delta and stage preservation, and reparsed the warning and current DRC tables. [Parent verification](synth-parent-review-verification01.json), [frozen package](synth-review-package01.json).

Target: Quartus Prime Pro25.1.0 Build129, AGFB027R25A2E2V, ofs_top/top, ofs_pr_afu/PR_IMPL, matching Work21 release03. This is the actual PIM/DMA/AHLS persona, not an empty template or standalone interface diagnostic. Only `afu/csr_mgr.sv` changes: candidate SHA256 `053b9855aa860c410337f5cae7e6160c6086726903cf988a1d35f032cb7a0b93`. The other12 AFU sources and255 generated entries remain identical; clock/SDC policy is unchanged. The separate source/ABI unit gate was already accepted and published in `5c20cfb811c31a003a9cf3e586639cea591939e4`; it is not being reaccepted as mapped-functional equivalence here. [Source delta](source-delta01.json), [unit acceptance](../dma-csr-metadata01/UNIT-ACCEPTANCE.md).

Both setup and synthesis native/effective/outer **0/0/0**, completed/success true, preservation flags true, no diagnostics/postflight errors, timeout or owned survivors. Fresh synthesis discards only851 enumerated copied DNI entries after checking the full setup copy, while importing the accepted static QDB; it is not checkpoint-free synthesis. Native Reconfigurable green_region and retained CSR/guard/core/banks establish mapped-stage presence, not fitted preservation or exact constant readback. [Review sections2–3](synth-independent-review01.md).

## Findings remain open

- **Q1:** retain443 log warning occurrences (441 Warning +2 Critical Warning), separately from native footer230warnings/0errors. Current synthesized DRC is **5/13 failed enabled rules,14 violations,0 waived**, with7 disabled; partitioned is0/10 failed with1 disabled. Keep inherited exclusions, message policy and report truncation limits. No suppression, waiver or warning-clean claim.
- **Q2 / R1 / R2:** Critical20580 remains despite current Reconfigurable partition evidence. Physical PR preservation requires later fit evidence. Active LSU burstcount fan-in/OR transformation and pruned reply/credit/ID/metadata correspondence are not cleared by retained resource totals or unchanged warning IDs. No universal equivalence gate or repeated synthesis is warranted.
- **Q3:** Critical19854, PR initial values and actual reset findings remain. Failed synthesized rules are RES-30132 (2), LNT-30023 (1), LNT-30010 (6), TMC-20501 (4), TMC-20500 (1). Swept `freeze_cc` is not quiescence. Reset assertion/deassertion/CDC, descriptor/kernel drain, response retirement, posted-write fencing, PR handoff and pinned-buffer lifetime still require supported contracts.
- **Q4:** the additive tagged raw-capability words avoid reliance on legacy metadata; they do not repair raw512→3bits, raw32→4bits, packed150→64 status or clock400. Same UUID is not capability-version proof, image identity or permission for live MMIO.
- Resources are recorded affinity/requested parallelism36 and64GiB per-process AS limit. **Effective synthesis worker count is not reported**, so no36-worker claim or inherited fitter maximum is substituted. The limit is not an aggregate sandbox.

These dispositions preserve the complete exact source/native citations and limitations in [review Q1–Q4](synth-independent-review01.md); they neither waive design rules nor claim every source/mapped bit has been proven equivalent.

## Stage boundary

No fit, final STA/timing, assembly/GBS, physical PR, lifecycle, electrical, DDR/PCIe/OPAE, numerical hardware or durable-boot acceptance. Prior CSR02 constrained timing does not transfer to this changed persona. Full design/hardware goal remains incomplete. Vendor DDR simulation is **SKIPPED BY USER**.

The existing CAPS01 fitter and collector remain untouched. This completed-evidence acceptance is not an additional execution barrier: verify its result when delivered and advance promptly to eligible final STA under the standing source/resource/ownership gates. Publication is a separate milestone action, not a reason to delay native continuation.
