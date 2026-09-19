# Independent specification review

## Disposition

**PASS — bounded LOCAL fake-channel acquisition-to-receiver scope only.** No mandatory specification gap found against the review dispatch. This is not a quality review, live transport validation, production execution decision, or authorization. `authorization`, `ready_for_build`, and `vendor_run` remain false.

Reviewed current controller SHA-256: `4efbc12f982d32c0827a1c91b16502dc62d91875c18134ee7631b6d277147e78` (9686 bytes). All relative citations below are within this package unless a sibling path is named.

## Review method and reconstruction limit

I read the controller, tests, runner, README, manifest, validation record, retained RED/GREEN output and source bindings, and the approved delivery decoder and receiver. I used only local read operations and reviewer-authored Python standard-library hashing, JSON inspection, and AST parsing; no reviewed module was imported or executed and no test was rerun. No network, remote, vendor, process-startup/signalling, permission change, commit, push, or sibling edit was performed by this review. The sole created artifact is this review.

The original implementation dispatch at `/home/joe/.hermes/cache/delegation/live/deleg_33ff3c80/task-0.log:7` explicitly truncates its context by 2680 characters. Its tool records are also abbreviated. Consequently I cannot certify a verbatim reconstruction of every original dispatch requirement or audit all historical actions from that log. This disposition uses the complete specification supplied to this independent review; it does not substitute the implementer's README for missing original instructions. The log supports the recorded development sequence, not exhaustive historical proof.

## Specification findings

- **Local-only, inert imports, immutable dependencies:** `controller.py:6–27` contains imports, constants and the identity sentinel; acquisition I/O is inside explicit functions. `controller.py:30–46,75` reads bounded source bytes, verifies length and SHA-256 for all six bindings before executing only the exact delivery and receiver source in non-main namespaces. It never invokes the transport, launcher, collector or fixture. `controller.py:53–218` contains no SSH/tmux backend, process launch/signalling, source mutation or retry. The runner's subprocess at `check_local.py:36–37` runs the explicitly requested local synthetic unittest suite, not a production backend. Source-drift and import tests are at `test_controller.py:235–245,266–281`.

- **Complete acquired bytes and finite limits:** `controller.py:71–74,127–157` validates finite bounds, requests at most 65536 bytes and remaining cap plus one, and retains accepted bytes before attempting persistence. It does not decode or accept an early completion-looking prefix. A cap-crossing byte is retained and fails; unread bytes after a failure and overlarge contract-violating returns are not misrepresented as captured (`README.md:58–64`). The default raw cap is 32 MiB, not the smaller envelope cap. Exact 3 MiB envelope framing and byte fragmentation are exercised at `test_controller.py:196–206`. Derived maximum file content is 42,008,577 bytes, consistent with `controller.py:22–25`, decoder/receiver stream caps and `README.md:130–139`.

- **CAPTURE_END is an isolated fake/local boundary:** The sentinel is not byte EOF, a frame parser result or remote readiness (`controller.py:26–27,55–61,141–151`; `README.md:17–37`). Empty reads are disconnect even after valid S/R frames. Missing boundary adds an acquisition error (`controller.py:166–167`). Fake channels may automatically emit the sentinel after their synthetic event list (`test_controller.py:69–77`); that is not evidence of real draining or live closure. This is compliant only within the stated trusted cooperative channel contract. A future real backend still needs independent boundary/error-delivery/ownership design and review.

- **Late errors and cleanup fail closed:** Setup/read/deadline errors are captured; writes are checked for short results without retry; flush and close are attempted separately so one does not mask the other (`controller.py:86–165`). Cleanup precedes decoding. The final receiver evaluation follows receiver-file and metadata persistence and receives accumulated acquisition, cleanup and persistence errors (`controller.py:181–218`). Tests cover post-prefix disconnect/reset, lag and malformed suffixes, individually failing sinks, and simultaneous late read, sink-close and channel-close errors (`test_controller.py:136–167,176–184,208–233`). The latter asserts each error reaches receiver `transport_error:` issues, not merely the controller receipt.

- **Exact approved decoding, stream separation and real status:** `controller.py:170–182` calls the hash-bound `delivery.decode` on the full retained transcript, passes exact decoded stdout and the decoded S status to `receiver.evaluate`, and never consults an envelope status as a substitute. Decoder failure leaves status unavailable (`None`), not fabricated zero. `runtime-metadata-delivery-01/delivery.py:161–172` extracts S status and requires restoration; the generated shell source records Python PIPESTATUS separately at lines 71–81. The receiver in-memory API has no stderr parameter (`runtime-metadata-receiver-01/receiver.py:86–100`), so outer stderr is preserved separately in the receiver evidence directory and receipt (`controller.py:178–180,192–196,214–216`), never merged into stdout or collector stderr. Exact bytes and status separation are asserted at `test_controller.py:125–134,169–174,220–233`. Prior Q1/Q2 local acceptance is documented in `runtime-metadata-delivery-01/parent-q1-q2-disposition.md:3–17`; this controller does not promote that acceptance to production.

- **Fresh evidence and no premature persisted success:** Output directory and files are exclusive (`controller.py:49–50,75–78,121–125,190`). Existing outputs are refused, tested at `test_controller.py:275–286`. A partial filesystem is evidence, not a successful receipt. `acquisition.json` deliberately always says INCOMPLETE and requires the returned post-cleanup receipt; its own write/flush/close failures enter final evaluation (`controller.py:199–218`; `README.md:93–109`). No claim is made that failed storage can durably record its own failure.

- **Deadline and readiness limits are explicit:** Channel operations receive one absolute deadline, with checks around acquisition and after cleanup/evidence work (`controller.py:95–102,127–165,197–212`). This is a cooperative acquisition deadline, not a preemptive watchdog or certified whole-function wall-clock bound; filesystem/source/parser operations cannot be preempted (`README.md:141–150`). Close crossing the deadline is tested at `test_controller.py:255–264`. The receipt and persisted record force all three flags false (`controller.py:201–218`), while README lines 188–198 retain production startup, attestation, BMC mailbox and historical u03 blockers.

## Independently checked retained evidence

Reviewer-authored static verification completed with exit 0:

| Check | Result |
| --- | --- |
| Manifest artifact byte lengths and SHA-256 | 19/19 match |
| SHA256SUMS entries, including manifest | 20/20 match |
| Controller immutable source bindings | 6/6 match current sibling bytes |
| Each retained checks.json source map and output hash | All match retained snapshots/current immutable siblings; 9 source entries per stage |
| Final controller/test/runner versus green-final snapshots | Byte-identical |
| Source AST grammar | Python 3.9 grammar parses for retained source bindings; no runtime certification |
| Final validation test names/count versus AST and log | Exact agreement: 14 methods |

Recorded runs, inspected rather than reproduced:

- `red/`: exit 1, missing `controller` import, with nine test methods in the retained test source. The output's single failed unittest loader item is not nine executed failures. This is new-API RED, not a historical bug reproduction.
- `green-01/`: exit 0; all nine retained test methods appear as `ok` in the bound output.
- `green-final/`: exit 0; all 14 retained test methods appear as `ok` in the bound output, reporting 5.126 seconds. `green-final/checks.json:2–12,52–57` identifies `/usr/bin/python3`, Python 3.13.5, the unittest argv, grammar-only Python 3.9 claim and false flags.

`check_local.py:23–44` records pre-run source hashes, preserves source snapshots and binds actual captured unittest output. Static hash consistency supports provenance but does not independently authenticate execution or exclude concurrent source mutation during a historical run. No such mutation is evidenced here. Manifest exclusions expressly allow future review files (`manifest.json:3–6`); this review is not claimed to be bound by the existing manifest.

## Remaining gates

Proceed only to the separately assigned independent quality review and parent disposition. No backend, live fixture rerun, production transport/helper startup, remote acquisition, vendor execution, u03 edit/retry, readiness promotion or build authorization follows from this PASS.
