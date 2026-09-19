# fim-build-13 compile-candidate-01

W13 = Work12 tree + AHLS AFU in PR slot (Stage 2 of the AHLS-FIM goal).
Package mirrors the reviewed W12 compile-candidate-01 pattern:

- `gate-copy/` — retargeted gates (mechanical fim_12->fim_13; exp gate drops
  the dead header branch, 321->317 lines; compile gate pure path retarget)
- `source-inputs/gate-swap.json` — before/after hashes of the 4 swapped files
- `source-inputs/delta-report.json` — SOURCE/W13 deltas vs W12 baselines
  (SOURCE: exactly the 2 gate files; W13: afu_with_pim assembly set only)
- `compile-authorization.draft.json` — pins SOURCE/PIM/W13 inventories,
  135 contexts, 477 dependencies (W12 set rehashed), native binding
- `launch_native_compile.py` — W12 reviewed runner, paths retargeted
- `issue_authorization.py` — W12 reviewed issuer; W12-specific cross-checks
  adapted (source pins == W12 record; work inventory == live W13)

Provenance: PR JSON UUID 67bc266a-56f7-440a-bb75-12b5f446d842; AFU tree is
the Stage-1 0-error-elaborated assembly (qualification/ahls-afu-fim-01).

Review envelope (independent reviewer fills):
- spec review: report at /home/uwb_student00/ahls/new_BSP/qualification/fim-build-13/compile-candidate-01/spec-review-01.md, verdict PASS/FAIL on the
  package vs this README + draft consistency + delta-report allowed-set audit
- quality review: report at /home/uwb_student00/ahls/new_BSP/qualification/fim-build-13/compile-candidate-01/quality-review-01.md, verdict on runner/
  issuer correctness, fail-closed behavior, no vendor launch, once-only claim
Both accepted=True required; parent then writes reviews-acceptance.json and
runs issue_authorization.py once.
