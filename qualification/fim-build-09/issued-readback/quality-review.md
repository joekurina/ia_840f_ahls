# Work09 focused quality review

## Verdict: APPROVED

Approved for exact review consumption, issuance and the authorized fresh Work09 experimental compile. No critical quality defect found in the reviewed candidate, issuer, runner or draft. This is not timing closure, functional acceptance or permission to program an image. No additional incremental user approval is needed within the existing scope.

## Findings

- The candidate changes only the placement optimization mode to `SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT` and the two Work08→Work09 gate retargets. It introduces no frequency, RTL, pin, SDC, DDR or PCIe change. Its effectiveness is an experimental question, not an approval prerequisite. Installed enum evidence is not native option acceptance.
- Issuance requires exact five-file timing-review coverage, exact remaining gate-file coverage, the inherited three-file Work05 source review, and exact issuer/runner/draft hashes. It verifies overlay and copied WORK bytes against their bindings and maintained SOURCE against captured before-bytes before synchronization. The exclusive issuance lock and exclusive record creation prevent reissuance; a partial failure preserves the lock rather than silently retrying. Full maintained source inventory is checked before the authorization record is created. Consumed and inherited reviews are pinned as dependencies.
- SOURCE and WORK have distinct intended roles: issuance synchronizes the reviewed overlay to maintained SOURCE; the runner imports the SOURCE gate; native invocation starts in SOURCE and targets the exact Work09 WORK directory. The retargeted Quartus dispatcher recognizes Work09. Focused inspection found no stale Work08 runtime paths in issuer/runner or the draft outside historical dependencies. The old gate docstring is nonfunctional.
- Launch validates the required tmux session, installs the explicit 26.1.1 tool PATH (including `sopc_builder/bin`), removes build overrides/tags, fixes required environment values, validates the record and initial WORK inventory, and rejects an existing claim. An exclusive run directory and exclusive native log preserve previous evidence. The native gate exclusively creates the claim; callbacks require its record hash, PID/start-time identity, actual ancestry and exact executable/argv/cwd context. Claims are not deleted or reused.
- The finite command grammar, tool/source/dependency checks and rejection handling are unchanged. The environment guard constrains build options; it is not a hermetic environment or OS sandbox. Runner status preserves native return code and rejection-marker failure, keeps readiness/functional acceptance false, and leaves compile/fit/assembly/timing acceptance pending actual report review.

## Verification and limits

Read the actual candidate patch, issuer, runner, runtime compile gate, draft and captured handoff/final verification. Recomputed the key hashes below, confirmed draft issuer/runner dependency pins, scanned draft runtime bindings for stale Work08 roots, and parsed issuer/runner Python syntax successfully without importing or executing either. Relied on the independent specification PASS for the already verified full export/source inventory, unchanged 135 contexts and captured 40 inert cases; did not repeat that broad audit or claim fresh native integration testing.

S1/TRS, physically fitted unconstrained PCIe divider, BMC IRQ/JTAG policy and other inherited constraint-completeness questions remain open for final acceptance. They do not block this expressly authorized unchanged-constraint compile. `timing_review.accepted=true` in consumed reviews must mean acceptance for experimental execution only and retain this disposition and the spec review in accompanying evidence. Work08 timing failed despite native success. The historical assertion that its timing report was missing is incorrect: `../fim-build-08/timing-review-01/REPORT.md` exists, as recorded by the spec review. Correct subsequent reporting, not the functional candidate.

No remote access, authorization issuance, native launch, source edit, DDR simulation, hardware action, commit or push was performed. Only this quality report was created.

## Exact reviewed SHA256 bindings

Paths relative to this report's directory. Other captured package/source hashes remain those independently verified in the pinned specification review.

| File | SHA256 |
|---|---|
| `spec-review.md` | `825d42e51054b050794f69959da8db047daf6dfce6ff08c409d6163f95b6e462` |
| `candidate.patch` | `936beb30e027c06859fa5f8fc3b09a9f207afce2250f65d16cc55b09862513d4` |
| `remote-evidence/issue_authorization.py` | `83c1fd4a165e9842e7b8c5d83548bd01378ae6c89411984ad5c3969fb9af7495` |
| `remote-evidence/launch_native_compile.py` | `205f0f407fcc5ac166b45c9e5a5da6aa468a254bf693027286b36027b98421c7` |
| `remote-evidence/compile-authorization.draft.json` | `1beb87ed2dbab43412b8e4bd94da5d06364341ee4deb89bb3587b03808b3cb66` |
| `remote-evidence/source-overlay/ofs-common/tools/ofss_config/ia840f_compile_gate.py` | `fa62f29c9d4beab38bf8566f4b2ab4518deb50a56e1afdcb768b298a059610b6` |
| `remote-evidence/source-overlay/ofs-common/tools/ofss_config/ia840f_experimental_gate.py` | `4d552ad4aca740501e29578608a4d023acc930e607eb4600d2f60da951ef8b0b` |
