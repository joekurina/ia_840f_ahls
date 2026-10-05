# hello_world-ccip — end-to-end FPGA Test accepted

**PASS**, independently accepted by `deleg_a9a50f66`: native build/effective0/0; PR/host0/0; full64-byte greeting/NUL/zero-padding verification; empty diagnostics and scoped postflightclear. [Acceptance77](ACCEPTANCE77.json), [review manifest](review-manifest70.json).

## Exact identity and commands

- Quartus26.1.1 Build130, migrated interface `fc603c44-5c8f-5e94-bcbe-a5780030947c`, AFU UUID `c6aa954a-9b91-4a37-abc1-1d9f0709dcc3`.
- Source variant `ccip`, unchanged upstream tutorial tree; actual selected AFU QSF/source hashes and static QDB binding in [build artifacts](build-artifacts68-collection.json).
- GBS `/home/uwb_student00/ahls/new_BSP/work_examples_afu01/hello_world-ccip/persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs`, 7217479bytes SHA256 `8abc7c85ae311e35bcc1efc92be95a1d5c7cd7685fbc59e20a663d31fa85e4d5`. Container payload matches newly assembled native PR RBF. Images/oversized native log stay remote-only, hash-referenced; inherited ofs_top images are not new tutorial outputs.
- Native CMake target invokes `quartus_sh --flow compile ofs_top -c ofs_pr_afu` in the fresh persona project. Build source, actual invocation/result and retained warnings are in the collected receipts.
- Card operation: `/usr/bin/fpgaconf 0000:4f:00.0 <bound GBS>` followed serially by the reused independently qualified `hello_world_checked` binary SHA256 `2d2a32a013e7ab47d194b58a90a629c02b6bb07cb48b85d6ed1b57bc672c6bf3`.
- Exact47-byte stdout `Hello world!` and `CHECK greeting_line_bytes=64 PASS`; actual native exits durably recorded before postflight. [Hardware readbacks](hardware-result69-collection.json).

## Scope and ownership

This example has no active job. Normal OPAE/PR lifecycle and four transientD samples are retained observations, not hang verdicts. Sameboot/root-visible holders/maps/D/errors/relevantprocesses empty at postflight. No force flags, system permission/driver/link changes or reflash. Acceptance is example-specific, not blanket timing/CDC/reset/platform-health/no-hang qualification. Campaign live state remains local in `../CURRENT.md` until final closure.
