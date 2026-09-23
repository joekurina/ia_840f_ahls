# DMA reader correction — current checkpoint

**Independently reviewed and parent accepted for source + standalone read unit only.** [Acceptance](RESULT-ACCEPTANCE.md) consumes FINAL review `deleg_b7f83e4c` / `sa-0-687fb841`, SHA256 `15f95b852b9c8c21be079ee27400a47ea94265660764be2a974afa2439d8beb2`. Frozen13-file package `7768d63c7e7cbc706c861721bef27f0469942d9e32c909134302718328a3e591` reverified unchanged.

Original source failed lost ARVALID at85ns; corrected source passed12cases/22requests/3145checked payload beats. Native rc0/fatal red distinction and unobserved red outer rc are preserved. Candidate outer0 and three warnings retained. No unchanged native rerun is pending.

The additive patch remains separate from any DMA top. Synthetic configuration, testbench completion, unexercised address bits34–56, actual FIFO/writer/error/drain,4KiB/PIM mapping, physical DDR/host visibility and all hardware gates remain unqualified. Reader acceptance does not consume the separate writer or fabric gates. No hardware operations; DDR vendor simulation SKIPPED BY USER.
