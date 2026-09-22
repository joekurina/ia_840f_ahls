# Work14 preserved-copy diagnostic checkpoint

## Actual result

Ordinary-file/OS preparation, SPEC PASS, QUALITY APPROVED and [parent package acceptance](ACCEPTANCE.md) completed. Native STA ran once in `@35/%35` and returned **rc3 / INCOMPLETE** at `2026-09-22T06:48:46.491196+00:00`. [Result and preserved failure](RESULT.md). Original Work14/SOURCE/PIM all compare unchanged. The old Query04 approval timeout remains superseded; no new routine user decision is needed.

- Preflight `@33/%33`; preparation `@34/%34`, owned `ia840f_mailbox_monitored_01`.
- Remote attempt: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-14/pcie-postfit-01`.
- Preflight found no competing native tools. Ordinary Work14 file payload was 1,277,724,123 bytes; PIM 5,193,372 bytes. Available memory and disk are recorded in `preflight01.json.gz`; no FPGA device was opened.
- Exact prepared package: [prepared-manifest01.json](prepared-manifest01.json), 9 exported files. Candidate SHA256 `5e20a7a1b2be00d53a72972cdf09fa4ab1cc93d9e330f010f69c4b0954e52776`; 7,880 prelaunch file bindings, 7,757 callback file bindings, 10 symlinks. Full candidate is local-only; exact compressed export retained in `preparation01.json.gz`.
- Gzip transport SHA256 `ea27914ea09b40e29314b66bce4e1314f9c2ec707dd6ac09c58d53ad2636d283`; every exported file's size and hash checked locally.
- Original maintained SOURCE, Work14 and PIM inventories compared unchanged after copying. Initial copies were byte-identical before exactly recorded path relocations and scratch-only gate additions.
- Actual runner and dispatcher missing-authorization checks returned 1 with the expected rejection; no query claim/log or authorization was created.
- Python AST parsing passed. A `tclsh` parser check could not run because that executable is absent locally; the installed `libtcl8.6.so` `Tcl_CommandComplete` fallback returned 1 (complete syntax), without evaluating the query. [Receipt](syntax-check-result.json). This is not vendor API/runtime validation.

## Review consumption and successor

Independent [SPEC](spec-review01.md) and [QUALITY](quality-review01.md) were consumed before execution; exact hashes and nine-file/export verification are in [parent-consumption01.json](parent-consumption01.json). This authorization and claim are consumed. Native inspection confirmed the modern divider and CSR input clock, then failed because a single pin handle was iterated as a collection. Preserve this attempt unchanged. A [fresh successor](../pcie-postfit-02/AUTHORITY.md) corrects only that query-interface defect plus required isolated-path/gate retargets; fresh reviews precede its execution. No timing repair or hardware acceptance is implied.

Independent upstream review is [complete and parent-consumed](../../ofs-2026-target-01/DISPOSITION.md): the selected2026 examples pin and recommended FIM/common/PIM pins already match the lock. No inspected public2026 FIM tuple or upstream divider fix was found. Keep honest donor provenance while completing the AHLS integration; this diagnostic is preserved-baseline inspection, not a full rebuild or a jointly qualified release.

[Independent native-result review is parent-consumed](RESULT-ACCEPTANCE.md), strictly as failed-run/partial evidence. The output-clock/FIFO inventory did not finish; zero/missing evidence must not imply resolution. No clock/exception edits, new fit, FPGA device access, PR, programming, driver activation or reboot occurred here. Workstation availability remains the overriding boundary and the hardware mission is incomplete.
