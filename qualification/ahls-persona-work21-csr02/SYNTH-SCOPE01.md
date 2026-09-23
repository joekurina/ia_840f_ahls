# CSR02 setup and mapped-synthesis evidence gate

## Bounded specification

Qualify completed native setup01 and synth01 of the CSR-endpoint-register candidate in the matching Work21 PR persona context. Use Quartus Prime Pro25.1.0 Build129, device AGFB027R25A2E2V, revision ofs_pr_afu/PR_IMPL and application UUID673c03a1-cef3-4c82-bf10-b12c247d9718. No new execution is requested by this evidence review.

The only functional AFU delta from the preceding persona is afu/csr_mgr.sv, candidate SHA25642d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77: continuously registered65-bit inclusive endpoints. The separately accepted unit gate is ../dma-csr-timing01/UNIT-ACCEPTANCE.md; do not repeat it or broaden its queued-drain/sticky-error-recovery limits. Twelve other AFU sources,255 generated members, source-list/JSON auto200/100 policy remain unchanged. Binding details are in source-delta01.json and the inertly parsed setup/synthesis configs.

Required checks: exact package/runner/dispatch/archive/payload identities; native/effective/outer statuses; original setup/release/tool and critical-input preservation; finite ownership and absence of owned survivors; actual mapping and PR-context identity; retained endpoint/CSR hierarchy and warning/DRC accounting. Inspect native reports for actual mapping, not a success banner alone. Do not call a whole-design resource summary a green-region-only count.

The fresh synthesis root copied and verified4925 setup inventory entries, then removed only851 enumerated inherited DNI output files. The original setup and release are preserved. This is not a claim that all static checkpoint state was absent.4345 synthesis critical inputs were bound. Full command is quartus_syn --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu, not A&E-only.

## Explicit exclusions

No changed fitter/final-STA result belongs to this gate. Previous -0.367/-0.356ns setup failures remain unresolved until changed final STA. No mapped-functional, clock/reset/CDC coverage, full-FIM signoff, freeze/drain/fence/buffer-lifetime, runtimePR, packaging/deployment or hardware acceptance. UUID is not deployed. Vendor DDR simulation remains SKIPPED BY USER. Critical20580/19854, existing active LSU/RAM mapping and synthesized DRC findings remain visible and unwaived.

Independent review is local/source/evidence-only, spec first then evidence/source quality. It is not a new build-authorization barrier. The parent alone operates the existing fitter; no remote/native/simulator/device operations, Git changes, implementation edits, task transitions or writes to frozen files are permitted. Only synth-independent-review01.md is reviewer-owned. CURRENT.md and fit/STA preparation/progress files are deliberately outside the frozen package.
