# Work22 synthesis — accepted with findings

**Accept completed native synthesis only.** This does not accept Fitter/STA, PR operation, persona compatibility, electrical behavior or hardware. The unchanged first full-fit attempt may finish under its existing authority; no live source is changed by this disposition.

The parent read and consumed [independent review39](synthesis-review39.md), `deleg_4befc14b`, report SHA256 `cfb2e3789c0ec370c67e0f606b9b5fabdf2776b22e3ae976d3645455c149c51b`. All four native report identities were rechecked and the complete diagnostic records were independently counted. [Consumption receipt](synthesis-review-consumed41.json), [capture receipt](synthesis38-collection.json).

## Accepted observations

- Correct tool/device: Quartus26.1.1 Build130 and AGFB027R25A2E2V. Synthesis completed successfully, with no error record found.
- Native footer:81 ordinary warnings. Full report:413 front-end ordinary records plus81 sweep/mapping ordinary records and **one Critical Warning19854**, totaling495. Warning tables coalesce12 parent rows; these representations are not added together or substituted for one another.
- Partitioned DRC:0/10 enabled rules fail. Synthesized DRC:6/13 enabled rules fail. Disabled checks and include-IP-blocks Off remain disclosed; no exhaustive reset/CDC qualification follows.
- Both static EMIF instances remain. The selected base AFU is the retained scalar `qual_vec_op`, not CAPS03's future memory persona; its idle local-memory request boundaries are source-expected.
- The generated26 SCJIO parameters now elaborate; the former missing-CLTAP cross-version boundary is not a synthesis blocker for this run.

## Findings carried forward

1. **Critical19854:** explicitly initialized state in the reconfigurable green region, with54 grouped report rows—not a54-bit or exhaustive count. Reset/initial-state and freeze/quiescence obligations remain separate. The scalar AFU's freeze input is tied low; no active-PR safety is claimed.
2. **Width defect:** the40-bit control-shadow export is narrowed to an unused implicit1-bit top net. The active internal MSI-X vector has a separate source path. Preserve the defect and do not alter active fit inputs.
3. **PIM16803:** six `.user[0]` field diagnostics remain a bounded metadata-semantics risk. A targeted local source/native-type follow-up is pending; hardware probing is not a substitute for that analysis.
4. **Reset/control distribution, duplication limits, preservation clocks, interface metadata and debug findings** remain for final fitted/STA/consumer review. No blanket warning or DRC waiver is granted.
5. The [BMC unused-input follow-up](BMC-INPUT-DISPOSITION44.md) resolves the requested narrow consumer question: the selected IRQ logic ignores external causes and the selected arbiter does not consume HPS GPIO inputs. This is not electrical tie-off proof or a BMC-to-host interrupt implementation; that IRQ route remains intentionally unconnected.

The final physical result must independently establish the unchanged3.000 ns target, all five corners, exact EMIF1 transfer without a path exception, fit-only margin versus pure signoff, fitted PLL outputs, PCIe-divider/exception/net-delay coverage, actual board-pin consumption and new FME interface identity. Numerical and deployment gates remain unperformed.

The full synthesis report is54,688,090 bytes, SHA256 `d8c3f269cdf7fe5397ec109aa6d8c41e88145114028d0222db3deb95910f5478`; raw report/capture bytes remain local-only. Smaller summary/DRC reports and exact metadata may be published under the2,000,000-byte policy. No licensed tools, bitstreams or raw agent transcripts are included.
