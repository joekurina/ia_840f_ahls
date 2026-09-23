# Parent acceptance — actual Work21 AHLS persona fit02

**ACCEPT BOUNDED FIT02 EVIDENCE WITH FINDINGS.** This closes the completed physical fitting evidence gate, not timing, mapped function, reset/quiescence, runtime PR, electrical adequacy, or hardware acceptance.

The parent consumed the FINAL independent review `deleg_8e2b7db5`, report SHA256 `4b6a52242dcd0ba93885346e582bc73a0e6b1a15b29c7542519e05468188177e`, and reverified all **113 frozen members / 229,909,665 bytes**, all **14 compressed captures / 40 embedded payloads**, the **18 fit02 exports**, exact **4,512 immutable input bindings**, and the **13 selected RTL payloads** against the previously accepted candidate. [Independent review](independent-review01.md), [parent verification](parent-review-verification01.json).

## Accepted facts

- Native/effective/outer **0/0/0**, successful final database commitment, no timeout or surviving owned group, all setup/release/tool/bound-input preservation flags true. Actual Quartus **25.1.0 Build 129 SC Pro**, Agilex 7 **AGFB027R25A2E2V**, PR_IMPL `ofs_pr_afu`. [Native result](RESULTS-FIT02.md), [receipt](outer-fit02.json).
- **166 warnings**, including six critical occurrences, all retained. No warning-clean claim. The actual native partition table records imported root/static preservation **final** and nonempty **Reconfigurable green_region** with real Logic Lock utilization. The retained physical region answers the predecessor's missing-region question without guessing assignments. [Line-bound panels](native-panels-fit02.json), [warning ledger](warning-ledger-fit02.json).
- Whole-device resources and AFU-region accounting remain distinct. Current **46 dangling PR inputs** are not the historical template's 1,076. Source tracing explains the 40 unused physical bank-return ID/USER bits: PIM forces requests to zero IDs/USER and restores response metadata from request FIFOs. Parent checked the exact bound specialization and metadata enqueue/dequeue/restore source. This is not mapped-RAM, ordering, or runtime-PR proof. [Review F2](independent-review01.md).
- Retry provenance is accepted: fit01 OOM **5/5/5** remains intact; fit02 is a fresh completed-synthesis copy, not a failed-fit database reuse. The justified finite cap changed **16 GiB to 32 GiB**; no RTL/SDC/clock/pin/design-setting change or resynthesis. [Preserved failure](FIT01-FAILURE.md), [delta](source-delta-fit02.json).

## Findings retained — no waivers

**F1:** effective timing/CDC/exception coverage, stale literal scalar selectors versus actual core/map_banks paths, replacement order and unconstrained endpoints. **F2:** all 46 PR boundary ports; debug ownership and mapped metadata/credit-RAM attribution. **F3:** termination/slew requirements of the three exact BMC pins. **F4:** 1,098 ignored assignments, including current kernel reset/synchronizer targets, not blanket historical noise. **F5:** inherited **5/13 synthesized DRC failures and seven disabled rules**, power-up/reset/freeze/drain and R1/R2 mapped-function limits. **F6:** source-bound final-snapshot STA with explicit automatic user-clock behavior, coverage reporting and preservation. [Complete actionable findings and source/native line references](independent-review01.md).

Copied synthesis/DRC reports are not newly executed fitted checks. The 722-entry QDB hash inventory includes 284 final paths but is not local inspection of binary content; intermediate snapshot retention was disabled. No routed/retimed snapshot claim is made. [Output provenance](output-provenance-fit02.json), [QDB inventory](qdb-output-inventory-fit02.json).

## Successor and exclusions

The exact-bound `sta01` successor has been launched under standing native-iteration authority on a fresh completed-fit copy, not by replaying fit-only authority. Its result and timing acceptance are separate and pending. Requested `auto-200`/`auto-100` policy is preserved; selected rates, clock presence and any advisory fallback must be reported rather than misrepresented as fixed-frequency timing closure. [Separate STA checkpoint](../ahls-persona-work21-sta01/CURRENT.md).

No assembler/GBS, device access, programming, driver change, reset or reboot belongs to this gate. UUID `673c03a1-cef3-4c82-bf10-b12c247d9718` is not deployed. Vendor DDR simulation remains **SKIPPED BY USER**. The hardware goal is incomplete. No unchanged fit/synthesis rerun or duplicate publication is required.
