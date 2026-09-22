# Parent acceptance — Work14 native compile package

**ACCEPTED for one fresh native full-FIM compile.** This closes the bounded compile-package gate, not compilation results, timing, functional qualification, deployment or the hardware mission.

## Exact review consumption

- Actual package: [`compile-readback03/compile-candidate-01/`](compile-readback03/compile-candidate-01/), remote `qualification/fim-build-14/compile-candidate-01/`. The initial local draft is not the accepted package.
- [14-file manifest](compile-readback03/compile-candidate-01/review-package-sha256.json): SHA256 `d6323f8f243d1fceefb233680fa851a25676889b761348b0760de23b3602dc8b`.
- [Independent SPEC](compile-spec-review01.md): **PASS**, SHA256 `041caed6d7ccf49c07d96c6d011d4415f491dcaf6ec6eb15a3293579a2cbab44`.
- [Independent QUALITY](compile-quality-review01.md): **APPROVED**, SHA256 `429bf11278143fc36626ca422e075f78c58de108cfda29f9550d3fbdba0abfd0`; binds the same SPEC report. No blocking defects.
- Parent rehashed all 14 inputs unchanged and confirmed both local maintained gates byte-match the package before this acceptance.

The accepted scope is IA840F `AGFB027R25A2E2V`, Quartus Pro 26.1.1 Build 130, fresh `work_ia840f_fim_14`, native `build_top.sh --stage=compile -k -p ia840f <Work14>` → `quartus_sh --flow compile ofs_top -c ofs_top`. Source changes are exactly the already accepted UART ID correction and two gate-path retargets; no timing, board clock/reset, PCIe, DDR or BMC experiment is bundled. The 135 finite native contexts, full SOURCE/PIM/WORK/tool/dependency pins, exclusive claim and rejection markers remain enforced.

## Evidence and dispositions

[Current preparation evidence](CURRENT.md) records 5424 copied precompile inputs, no inherited compiled databases/output trees, two symlink retargets, original W13 input preservation, actual issuer preflight PASS and four actual missing-authorization rejection checks. The three native metadata changes are individually bound in [METADATA-DISPOSITION.md](METADATA-DISPOSITION.md), not blanket drift acceptance. Work14's fit must derive its own interface identity; old-persona compatibility is not assumed.

The local maintained gates still had tracked Work08 path constants. [Inspection](local-gate-sync-inspection01.json) proved no intervening local edits and only three stale literals versus the remote predecessor; [sync result](local-gate-sync-result01.json) proves exact accepted-package equality after retargeting.

Nonblocking inherited observations remain visible in the reviews: the lineage loop omits deleted-old-key enumeration, but independent symmetric checks establish identical key sets in these exact pinned bytes; report check/re-pin is not atomic, so keep inputs stable; an issuance failure consumes its exclusive attempt; historical comments and preparation-time wording do not supersede actual constants/integration receipts. This is trusted normal-account execution, not an OS sandbox. Do not silently harden/change bound code under this acceptance.

## Execution and remaining gates

After a fresh ordinary-OS resource/ownership check, transfer the exact reports and parent consumption, invoke the existing single-use issuer, read back the issued record, and launch the exact reviewed persistent runner in owned tmux. No extra native command, retry, hardware hook, or automatic deployment is authorized by this package. Preserve any failed claim/attempt.

At acceptance the native compile has not started. Run receipts establish later execution state. Native rc0 is separate from synthesis/fit/STA/assembly review; `ready_for_build` and functional acceptance remain false. Existing W13/persona timing is not accepted. DDR simulation is SKIPPED BY USER; dummy-CSR exercising is excluded.

Joe's explicit post-build flash/reboot permission is recorded in the [UART acceptance](../dfl-uart-fix-02/ACCEPTANCE.md). It is not a verified recovery path or a live-access plan. Hardware identity/backend/routing, finite supported procedures and independent host recovery remain required before potentially host-stranding operations. All DDR, transfers, numerical AHLS, sustained operation and durable-boot gates remain open.
