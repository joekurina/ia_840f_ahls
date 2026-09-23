# Work19 failed-result evidence acceptance

## Accepted gate

**ACCEPTED: fidelity of the failed native attempt and the bounded Python-loader diagnostic. Work19 remains FAILED / SPENT.** This acceptance does not qualify synthesis, license checkout, fit, timing, assembly, or hardware operation.

The parent consumed [independent result review 01](result-independent-review01.md), SHA256 `546c8cd89252c51880a2abee3ac76fe69fc8517bba59b198b49b861b1e5790d5`, and recomputed all **9/9** members of [the review freeze](result-review-freeze01.json) without a mismatch. The earlier [RESULT.md](RESULT.md), startup snapshot, and persisted runner labels remain byte-preserved historical evidence; their pending-review wording is superseded by this disposition.

## What the evidence establishes

- The actual Quartus 25.1 attempt failed because its injected loader path supplied a `libcrypto.so.3` lacking `OPENSSL_3.4.0` to host Python's `_hashlib`. Rejection first appears before the main Quartus banner and recurs in later callbacks; it was not confined to the post-IP callback. Quartus warning 125091 allowed execution to continue, so the parent stopped the exact recorded owned process tree. [Review, actual failure and termination](result-independent-review01.md#actual-native-failure).
- The directly waited native launcher returned `-15`; the preserved runner converts this to outer status 143. The frozen package does not independently capture every vendor subprocess exit or a separate outer-shell wait receipt. The recorded final identity check found no remaining owned non-zombie processes; it is not a claim about all possible processes or current workstation state. [Termination evidence](stop-failed01.json).
- The real no-project diagnostic reproduced the raw import error and a clean import using `/usr/bin/env -u LD_LIBRARY_PATH /usr/bin/python3`. `RAW_RC` and `CLEAN_RC` are Tcl `catch` statuses, not separately captured Python wait statuses. The successful imports and computed digest/UUID support the child-only environment correction. [Diagnostic source](python-env-diagnostic01.py), [captured result](python-env-diagnostic01.json.gz), and [review interpretation](result-independent-review01.md#bounded-remedy-evidence).
- The source-supported remedy is limited to the two identified Python callback invocations. It does not alter Quartus's own loader environment, installed libraries, RTL, QSF, SDC, or the broader behavior that can downgrade a future callback failure. The review corroborated Work20's four-file preparation delta, without creating or reopening a successor launch gate. [Remedy-delta review](result-independent-review01.md#work20-remedy-delta-corroboration-read-only).

## Preserved bindings

| Artifact | SHA256 |
|---|---|
| Issued Work19 authorization | `2857a86b1afc244af7b7b2d59f0945dfa36dd5a8dd80ba1497e0f3f5fadd1b7e` |
| Preparation archive | `cc25b714b1fd338879bc6651a154bd5dfd51c6fe6775b6d23ff50ff8b2d19762` |
| Native log, captured during terminated synthesis | `cd10bf85ac3e220ada5627ab47fe6d93ef35a821392f0e9cd4709b6a182f2f4c` |
| Paired Python diagnostic archive | `3b7ca2a2b75ff3d2fc52a54134ef30b2106d471424af6efb41ce4d6fd76662f7` |
| Review freeze | `f2334fdd8a6026e89e518cac9a4f48f6c056d6f9af9560e1c96cbb46df6df574` |

No Work19 rerun is authorized by this acceptance. The later Work20 elaboration result, remote-debug regeneration, and AHLS memory-IP result have separate evidence packages and dispositions. No FPGA device access, flashing, reboot, or driver change was performed for this gate.
