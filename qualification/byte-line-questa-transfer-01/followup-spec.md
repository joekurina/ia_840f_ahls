# Narrow R1 transfer-procedure follow-up

**Verdict: PASS — R1 is closed by the explicit transfer-procedure supersession.** This closes the sole remaining defect in `../byte-line-questa-01/spec-review.md`; it is procedural spec-review acceptance, not a completed transfer or HDL/simulator qualification.

## Resolution and exact-set check

`disposition.md` explicitly supersedes only the pinned README's whole-directory transfer instruction. It defines the execution payload as exactly the manifest-listed relative file paths plus `package-sha256.json`, requires remote size/hash and exact-file-set verification before execution, and supplies the separately retained manifest SHA-256 pin. Unpinned package-root and subsequent review reports remain local, outside the execution payload. Neither re-pinning to absorb reviews nor weakening runner inventory checks is permitted; the historical README and original evidence remain unchanged.

Read-only parsing and hashing of the current manifest established:

- Manifest size: **3276 bytes**.
- Manifest SHA-256: **`ec6800e15dff71f9b57ce51e39111cb1db9b4c55d9683896a7aa00bf1fae8fbe`**, matching both the original review and disposition.
- Manifest entries: **24**; transfer payload: **25 files**, including the manifest itself.
- The stipulated payload set is exactly `set(manifest) | {'package-sha256.json'}`, identical to the runner's required set at `run.py:148-151`.
- Package-root `spec-review.md` is absent from that set and must not transfer. **`provenance/spec-review.md` is a pinned manifest entry and must transfer.** The exclusion is path-specific, not a basename filter or a blanket exclusion of historical provenance reviews. The disposition's exact-manifest rule preserves this distinction.

Thus the correction removes the deterministic extra-file conflict without changing any pinned execution file or acceptance gate. No remaining gap was found within this narrow R1 scope.

## Unchanged boundaries

Actual remote readback must still establish the manifest pin, every listed file's size/hash, and exact recursive payload file-set equality before execution. This follow-up does not assert those remote checks have occurred. Named tmux, fresh exclusive execution-package and separate fresh results directories, and the prohibition on maintained-source or Work04 changes remain required by the disposition.

The prior broad review was not rerun. No package-member requalification, vendor compatibility claim, simulator PASS, or BSP qualification is inferred. Prior evidence remains **154 planned cycles, zero executed HDL cycles, four previously reported inert Python tests**; no tests were rerun here.

Only this `followup-spec.md` was written. No remote contact, vendor execution, transfer, manifest modification, source/evidence modification, or commit occurred. The initial read-only calculation could not use the unavailable bare `python` command; retrying with `python3` succeeded and left no unresolved blocker.
