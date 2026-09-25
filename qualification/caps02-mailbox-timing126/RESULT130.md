# Mailbox staging result130 — local functional pass, physical qualification open

## Result

The parent implemented the additive `ia840f_ahls_observer_mailbox_timing126` and exercised it with the existing isolated Icarus12.0 package. **All five positive runs passed:51 cases and1522 checks. All three deliberately broken RTL mutants were rejected at their intended assertion, not at compilation.** The issued [run127.py](run127.py) exited0; [summary.json](run127/summary.json), individual results/logs, and [verification130.json](verification130.json) contain the execution and hash evidence.

**This is local functional evidence, not independently accepted physical timing or hardware qualification.** The candidate remains unselected by the production endpoint/top and QSF. No Quartus/Questa run, remote operation, FPGA programming, reset, reboot or device access occurred in this step. No clock or timing constraint was changed. `PUBLISH_SUPPORTED=0` remains unchanged.

## What changed

The [source-bound delta](mailbox126.diff) adds two pending flags to a new mailbox module, preserving the original file:

- Install a request and assert busy immediately; publish its toggle on the next core edge. Exclude the pending state from `source_complete`, because the old ACK still equals the unpublished toggle.
- Capture the complete response and sidecars on the original observer-ACK edge; retain bank ownership and publish the ACK on the next bank edge. Pending publication takes priority over a repeated observer ACK.
- Retain the two-stage synchronizers, ports, reset topology, sticky-error priority, sequence accounting and rejected-RELEASE epoch monitoring. See [DESIGN126.md](DESIGN126.md) and [source126.json](source126.json).

This explicitly adds source-side separation instead of depending on a slow asynchronous control route or enlarging the existing absolute settling target. It does **not** by itself certify the physical CDC bound.

## Real local execution

Command issued once from the repository root:

```sh
python3 -I -B qualification/caps02-mailbox-timing126/run127.py
```

| Test | Cases | Checks | Bank command strobes | Disposition |
|---|---:|---:|---:|---|
|64-bit sequence, core/bank half-periods5/7ns|10|76|15|PASS, exact timing56 reference metrics|
|64-bit sequence, half-periods7/3ns|10|76|15|PASS, exact reference metrics|
|64-bit sequence, half-periods5/17ns|10|76|15|PASS, exact reference metrics|
|8-bit sequence, half-periods5/7ns|11|847|271|PASS, including overflow|
|Focused pending-notification fixture|10|447|10|PASS|

The first four runs use [tb_mailbox_timing127.sv](tb_mailbox_timing127.sv), a copy of the accepted timing56 fixture with **only the top name and mailbox-module selector changed**. All original drivers, assertions, limits and the timing46 observer remain unchanged. Their `native_commands` log label counts simulated native-bank command strobes; it does not mean a hardware/vendor execution occurred.

The focused [tb_staging127.sv](tb_staging127.sv) uses explicit bank ACK/data inputs, not a controller or physical CDC model. It observed:

-11 request installations:10 publications and1 intentional reset cancellation.
-10 response installations:9 publications and1 intentional reset cancellation.
-10 bank strobes and9 completed core responses, matching the canceled response.
- Request publication exactly one core edge after held-data installation; response publication exactly one bank edge after snapshot/sidecar installation.
- Source stopped while request notification is pending; bank stopped while response notification is pending; correct continuation after resumption.
- Bank reset canceling an unpublished ARM while preserving poisoned epoch history; core reset canceling an installed/unpublished response; no stale replay.
- Held observer ACK with changing input data/armed flag does not recapture the response; captured return-error survives later input clearing.
- Local-CSR fault, rejected busy input and DMA contamination at request-publication edges; rejected RELEASE coincident with core installation retains monitoring for later DMA contamination.

### Non-vacuous negative controls

These are explicitly synthetic mutations of the candidate, not observed hardware defects:

| Mutant | Compile status | Simulation status | Required failing assertion |
|---|---:|---:|---|
|Remove pending-state completion inhibition|0|1|`F_PENDING_GUARD`|
|Publish request on payload-install edge|0|1|`F_REQUEST_EARLY`|
|Publish response ACK on capture edge|0|1|`F_RESPONSE_EARLY`|

All eight compile logs are empty. The parent independently rehashed all44 pinned input/tool/backend members after the run and every recorded output artifact; all matched. The baseline mailbox and observer were preserved. [verification130.json](verification130.json) binds this verification to summarySHA `6ea406c8a2a76c4b2285072ba40f951d0b896f83710ea3f01b260480bb19a543`.

## Clock evidence advanced, but no timing gate cleared

[analyze-clock125.py](../caps02-afu-publication09/analyze-clock125.py) ran locally against the already verified query118/supplement122 records, with exit0 and no native rerun. It reduced3680 bundle pair/corner observations:130 request and606 response pairs in each of five corners. Its [summary](../caps02-afu-publication09/clock-envelopes125.json) retains the per-corner witnesses, exact inputs and limitations. Detailed pair records remain in the local-only, hash-referenced `clock-envelope-pairs125.json`.

The reducer removes only an ordered common prefix ending at a named same-domain clock node; node-less routing points are not used as shared identities. Worst combined observed local offsets are−0.796ns request and−0.838ns response. The algebraic baseline allowances2.204/2.162ns become hypothetical5.204/5.162ns after an added nominal3ns source cycle, **before source-cycle contraction and new-fit remeasurement**. These values are not qualified margins or an approved aperture/jitter budget. The reducer explicitly grants zero positive control-flight credit.

First-stage aperture/reliability, uncertainty allocation, guard band, all-transition clock-envelope coverage, common-prefix interpretation, overwrite/hold bounds and the candidate's actual fitted structure still require qualification. Original-fit failures are not reclassified.

## Reviews and next boundary

- Independent ingress-result review112 was read, its result binding verified, and consumed in [ingress-result-review-consumed125.json](../caps02-afu-publication09/ingress-result-review-consumed125.json). This closes only experiment92's narrow first-stage D-only effect; no production timing gate is cleared.
- Independent clock/source reviews128/129 were dispatched as `deleg_f483e9f8`. Await their delivered results; do not poll artifacts or repeat native diagnostics.
- Independent acceptance of the completed local functional evidence remains open. An attempt to extend the source reviewer to these newly completed results reported that the child was no longer live; no result-review acceptance is inferred from that request.
- Before integration: consume the source review, independently review the local test evidence, and resolve the concrete physical-bound recommendation. A changed source requires fresh source-bound mapping/fitting; synthesis59 is not a mapped result for this candidate. Keep source selection, integrated simulation, mapping, fit/STA, reset/RDC/MTBF and hardware acceptance separate.

**Overall goal remains incomplete. No user-input blocker is established for further offline work.**
