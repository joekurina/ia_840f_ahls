# SOURCE-REVIEW129 — timing126 pending-notification source/spec review

## Verdict and boundary

**PASS — independent source/spec review only.** The frozen additive mailbox implements the request and response payload-before-notification behavior specified in `DESIGN126.md:15–20`. No concrete functional defect requiring correction was found in the reviewed delta. **Smallest correction: none.**

This verdict is based on reading both complete mailbox sources, checking their exact byte delta, and reasoning about their clocked/nonblocking assignments. It is **not** a simulation, formal-proof, synthesis, fit/STA, CDC/RDC/MTBF, integrated Questa, or hardware acceptance. No implementation, fixture, constraint, source selector, or production file was modified. No tests, vendor tools, remote operations, git operations, or device operations were executed. Parent-owned functional results were neither awaited nor inspected.

`PUBLISH_SUPPORTED=0` remains required. Physical qualification remains open, including the new local pending-control paths and preservation of the intended source-cycle separation after implementation.

## Reviewed identities

Root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new`.

SHA-256 values below were calculated from the actual local file bytes, not copied from the manifest. The original/candidate mailbox and original/candidate fixture hashes match all four corresponding fields of `source126.json`. A freshly calculated unified mailbox diff is byte-identical to `mailbox126.diff`.

| File, relative to root | Observed SHA-256 |
|---|---|
| `afu/ahls_memory/control/ia840f_ahls_observer_mailbox_csr.sv` | `0b43f0028c99afa6d13cdd39a632be16fb49fb86efe686eb2e270cbddd2698ff` |
| `afu/ahls_memory/control/ia840f_ahls_observer_mailbox_timing126.sv` | `d521d67614ab2d405ac9fd39852ee0f1d968adb3dadba87d816057b8c562b627` |
| `qualification/caps02-mailbox-timing126/DESIGN126.md` | `378a62b834b5946fcc618a0684ce838c753ceb776d6ba926ccdf1cf58392d41e` |
| `qualification/caps02-mailbox-timing126/source126.json` | `31d382f988de9bcd3545dfdf6b6c9989c498621d4e395c6ee9497837ec2e7103` |
| `qualification/caps02-mailbox-timing126/mailbox126.diff` | `c5c910b5364f3a3cc4ac07ceda0d347910eacf46e96eba8190e51d89789ed3e4` |
| `qualification/caps02-observer-timing48/tb_mailbox_timing56.sv` | `0570777e38dcd10797ae7da1b84930a36ca4788755ee1ab9b28070be96cd6f2e` |
| `qualification/caps02-mailbox-timing126/tb_mailbox_timing127.sv` | `0a63274c9dc71febf74db82344287bc6a6fd9d7d081f04cc6da7b239b871206d` |

Additional inspected integration identities:

| File, relative to root | Observed SHA-256 |
|---|---|
| `afu/ahls_memory/control/ia840f_ahls_write_observer_timing46.sv` | `20cfd22f082a0924b7130d3721b2483a1308aa1e619bd1a3c2a548393a8e515b` |
| `afu/ahls_memory/control/ia840f_ahls_publication_endpoint_timing46.sv` | `c0472ee63123a68b1e9870a3da3fdd3e1e75243e2b20292a12cd2f1e07f60a0d` |
| `afu/ahls_memory/control/ia840f_ahls_publication_endpoint.sv` | `24a9381f7c18e743521f7c5f93ff2f0b8fc5027133ea5a29a456e95d158f158f` |
| `afu/ahls_memory/pim/ofs_plat_afu_publication_timing46.sv` | `2ba4248dacdbb3658ffdea0ac9bbff0742a5b185ca5d1f1a4286e4fa248bd268` |
| `afu/ahls_memory/pim/ofs_plat_afu_publication.sv` | `b6444c12f1e2959dd918cc44ef2ee3c4fc6b15da2a48c3866499faa8f6081ad9` |

Unless otherwise named, line citations below refer to `ia840f_ahls_observer_mailbox_timing126.sv` at the hash above. Conclusions assume reset-initialized RTL state and the existing qualified observer-acknowledgement contract; they do not model analog metastability or physical reset timing.

## 1. Request staging and completion inhibition — PASS

- **Installation edge:** `source_accept` is unchanged (`56`, `63–64`). At the accepting core edge, the entire `{core_cmd,core_expected,core_token}` bundle is installed in `request_hold`, `request_pending` and `core_busy` become one, and `core_valid` becomes zero (`119–122`). This branch no longer writes `request_toggle`.
- **Exactly next source edge:** `if(request_pending)` reads the pre-edge register value (`123–125`). It therefore cannot publish the newly accepted request on its installation edge. On the next active core edge, absent intervening reset, it toggles `request_toggle` and clears pending unconditionally. It does not wait for a bank edge, current command inputs, or a fault-free status.
- **Busy ownership is continuous:** pending is set with busy (`121`); `core_ready` excludes busy (`63–64`). The completion predicate explicitly excludes pending (`57–58`). Consequently neither a second acceptance nor completion can remove ownership during the installation-to-publication interval.
- **Stale equality is blocked:** immediately after acceptance, the previous synchronized ACK can still equal the unpublished request toggle. The added `!request_pending` prevents that equality from installing an old snapshot, pulsing `core_done`, advancing sequence, or closing an epoch. The publication edge itself also evaluates the old pending value and cannot complete. After its nonblocking updates, the request toggle has changed, so the old ACK no longer matches.
- **Payload immutability:** outside reset, `request_hold` is written only by acceptance (`120`). Busy prevents another acceptance until completion. Inputs may change during staging, publication, bank service, or ACK return without overwriting the accepted bundle.

A source-level edge witness is:

| Edge | Request hold | Pending | Request notification | Completion |
|---|---|---|---|---|
| Accepting core edge | Install accepted bundle | Set | Unchanged | Old busy is zero; not a completion |
| Next active core edge | Retained | Clear | Toggle once | Old pending is one; inhibited |
| Later matching synchronized ACK edge | Retained | Zero | Retained | Install response once and clear busy |

These are RTL scheduling deductions, not observed waveform results.

## 2. Response staging, ACK target and capture-once — PASS

- **One outstanding bank command:** `148–149` installs `bank_request`, asserts `bank_cmd_valid`, and sets `waiting_bank_ack` only while not waiting and while the synchronized request differs from the published ACK. `bank_cmd_valid` defaults low on every subsequent active bank edge (`145`).
- **Qualified response installation:** with waiting asserted and observer ACK high, `150–152` captures the complete `bank_snapshot`, `bank_armed`, and `bank_error` into their held registers and sets `response_pending`. It does **not** change `ack_toggle` or clear `waiting_bank_ack` on that edge.
- **Exactly next bank-source edge:** the pending-publication branch is first in the mutually exclusive chain (`146–152`). On the next active bank edge it publishes the ACK and clears both pending and waiting (`147`). Because it evaluates old pending, capture and publication cannot occur on the same edge.
- **Held ACK cannot recapture this response:** publication wins over the `waiting_bank_ack && bank_cmd_ack` branch. If ACK remains high and live payload/flags change, none of those held registers are rewritten on the publication edge. Afterwards waiting is zero and synchronized request equals ACK, so neither another command strobe nor response recapture is caused by the still-high ACK alone.
- **Reading `request_sync[1]` at publication is stable:** a bank command was issued only after that value differed from ACK. The core cannot issue a later toggle before the current ACK returns and completion clears busy. Pending cannot complete prematurely. Thus the synchronized request target cannot advance to another transaction during response pending. A common reset cancels both domains instead of letting this publication target survive into a new transaction. A separate saved ACK-target bit is not functionally necessary under this single-outstanding protocol.
- **Complete response hold interval:** `response_hold`, `return_armed`, and `return_error` have no non-reset writer except the qualified capture (`151`). They survive publication and core installation. A later transaction cannot overwrite them before the current one has completed and released core ownership.

This is capture-once for the outstanding response, not a newly added ACK edge detector. As in the original, an arbitrary stale ACK held through a distinct later transaction is not a substitute for the observer's transaction-qualified acknowledgement.

## 3. Completion cardinality and unchanged interface — PASS

At completion, `126–131` copies the snapshot and both flags together, clears busy, and sets done; `118` defaults done low on subsequent active core edges. Clearing busy makes `source_complete` false, so an unchanged matching ACK cannot install twice or increment sequence twice. A new acceptance cannot occur on that same completion edge because pre-edge busy still makes ready false. Faulted completions still retire once and retain the original invalid-result semantics; reset-cancelled transactions do not owe a completion.

The bank waiting state blocks duplicate command strobes before response capture. Response pending retains that waiting state, and publication has priority over command issue. After publication request equals ACK, so the old toggle cannot be rediscovered as a fresh command. This argument applies to either toggle polarity.

Mechanical byte comparisons confirmed the following unchanged blocks:

| Block | Original lines | Candidate lines | Comparison |
|---|---|---|---|
| Parameters and all public ports/widths | `6–30` | `6–30` | Byte-identical |
| Combined reset and local release pipes | `31–40` | `31–40` | Byte-identical |
| ACK/request and other synchronizer processes | `72–87` | `74–89` | Byte-identical |
| Fault, epoch and sequence process | `89–108` | `91–110` | Byte-identical |
| Completion installation and final fault override | `121–129` | `126–134` | Byte-identical |

The module name changes at `5`; there are no new ports. ACK and request remain two-register synchronizers (`50–51`, `74–89`), as do bank-up/error and DMA-fault transport. This preserves the **RTL** synchronizer topology, not proof of vendor recognition, fitted chain preservation, resolution time, or MTBF.

## 4. Reset cancellation, history and paused clocks — PASS

**Cancellation and replay:** `common_reset_n` combines both external resets (`31`), asynchronously clears both local release pipes (`34–39`), and therefore clears the mailbox state in both domains even if a clock is stopped. Core reset of the mailbox includes pending, request toggle/hold, busy/valid/done and installed response (`113–116`); bank reset includes response pending, ACK, command state, waiting, held snapshot and flags (`140–143`). The synchronizers also clear (`74–89`). Pending is reset in the same local process as its payload/toggle.

Accordingly an unpublished request or response is discarded, not published after reset release. Equal zero toggles plus cleared synchronizers/waiting do not synthesize a bank command, and cleared busy does not synthesize completion. Resumption requires a fresh accepted command. A command that already reached the observer before reset is not retrospectively “unexecuted”; the connected observer is itself reset by `bank_link_reset_n` (`ia840f_ahls_publication_endpoint_timing46.sv:46–50`). No rollback or physical reset-fence claim is made.

**History priorities:** only `core_reset_n` resets errors, epoch window, DMA sticky state and sequence (`93–95`). A bank-only reset invalidates mailbox state without rewinding sequence or erasing epoch history. While an epoch is open, sampling the stretched low core link sets the reset-history fault (`98`). Local synchronous release cannot pass through a paused core clock, so restarting that clock still encounters the low link before release. Recovery/removal, reset distribution and fitted reset-sequence requirements remain outside this source verdict.

**Paused clocks:**

- Stop the core clock after request installation: pending, payload and busy remain; no notification occurs until the next active core edge. A running bank sees no new toggle meanwhile.
- Stop the bank clock during request staging/service: request publication can still occur in core, but busy remains until bank service and ACK return. No timeout, overwrite or self-completion is introduced.
- Stop the bank clock after response capture: pending and waiting both remain asserted, and payload/flags stay fixed. Publication occurs on the first resumed bank edge, without recapture.
- Stop the core clock after request publication: the bank may finish and publish while core is paused, but the held response is not overwritten because core cannot accept a successor. Core synchronizers/install resume later.
- A stopped clock can stretch a registered strobe/done level in wall time; it does not create extra active-edge command consumptions or sequence updates. Reset can still cancel asynchronously.

## 5. Same-edge faults, RELEASE history and overflow — PASS

The additional notification edges do not create new validity or epoch-closing paths. They only move notification; existing fault processing remains active.

- **DMA at ARM acceptance:** `dma_now` includes an accepted ARM even before old `epoch_window` becomes one (`59–60`). Sticky error and DMA state set on that edge (`99`), and ARM opens the window (`101`).
- **DMA at request notification:** ARM already opened the window at acceptance. A DMA attempt on its later notification edge therefore contaminates the epoch. Request publication still drains the accepted transaction; errors prevent successful validation.
- **Rejected busy command or local access fault at notification:** `source_reject` includes both conditions (`61`). Busy prevents payload replacement, the sticky reject bit is set (`97`), and the final validity override remains active (`133–134`). Pending publication is not cancelled merely because the command has become invalid; reset is the cancellation mechanism.
- **Fault on the RELEASE installation/completion edge:** closure requires not only old `core_errors==0`, but also `!dma_now`, `!bank_error_sync[1]`, `!sequence_full`, and `!source_reject`, plus a RELEASE request and successful/unarmed response (`105–107`). Thus a same-edge rejected command or `core_access_fault` cannot exploit nonblocking sticky-bit latency to close history. The window remains open to catch later DMA and bank-reset events. The completion validity predicate has the same current-edge guards (`130–134`).
- **Response publication versus current core faults:** response publication does not change the core epoch or install validity. Core fault monitoring continues independently; a coincident core sampling edge uses the same guards as before. `return_error` captures the response-time flag, while synchronized live bank error remains a separate invalidating path (`100`, `130–134`).
- **Sequence exhaustion:** `sequence_full` and its limit are unchanged (`53–55`). Completion at the limit sets overflow without incrementing/wrapping (`102–104`), cannot validate (`130–131`), and cannot close a RELEASE window (`106`). An unsuccessful completion can still advance sequence before exhaustion, exactly as in the original.

The delay changes transaction latency and hence when a bank snapshot is taken relative to unrelated ongoing activity. It does not promise cycle-equivalence with the original mailbox; the preserved contract is the stated staged handshake and unchanged fault/history priorities.

## 6. Fixture and source-selection boundary

`tb_mailbox_timing127.sv` is the old timing56 integration fixture with exactly two selector changes: top module (`2`) and mailbox module (`35`). All remaining bytes match after those substitutions, including drivers, values, assertions, timeouts and the timing46 observer instance (`47–54`). `core_access_fault` is still tied inactive (`37–39`). This fixture is not itself the separate focused staging/fault fixture, and its existence or renamed selectors do not demonstrate that staging tests ran or passed.

The observer captures command input in its A stage (`ia840f_ahls_write_observer_timing46.sv:106–109`) and registers public ACK and effects in its C process (`200–214`). The mailbox still captures after seeing that registered ACK; the new response branch delays notification rather than resampling the observer one edge later.

Both maintained endpoint sources still instantiate `ia840f_ahls_observer_mailbox` at line `39`, not timing126. Both publication top variants explicitly bind `.PUBLISH_SUPPORTED(0)` at line `38`. A local `*.qsf` source search found no `timing126` reference. These are local source-selection observations, not a claim about an uninspected remote build or programmed image.

## Remaining acceptance work

No source correction is requested. Parent-owned focused staging tests and reused integration tests must establish their own measured coverage and mutant sensitivity; this review supplies no invented results for them. Native mapping/fit/STA must subsequently establish source-bound implementation and physical bundle margins, including all payload/sidecar/direct-predicate consumers, notification replicas, pending-control paths, overwrite bounds, clock contraction, aperture/uncertainty/guard assumptions, and reset/CDC reliability. Historical original-fit measurements do not qualify this changed HDL. The design's unchanged settling target is not a timing waiver or a margin certificate.

**Final disposition: source/spec PASS; simulation/result acceptance not assessed; physical and publication acceptance open; `PUBLISH_SUPPORTED=0`.**
