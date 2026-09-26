# CAPS03 synthesis acceptance — bounded

Independent review `deleg_9fda88cf/task-0` found no demonstrated completion-datapath
defect requiring interruption of the running fitter or repeated synthesis.
Parent [verification](synthesis-review-verification02.json) rehashed all 14 captured
files and 16 selected payloads and independently reconciled the exact A&E/log
warning population. [Synthesis result](SYNTHESIS01.md).

Completion is genuinely enabled in the offline top and retained in synthesis:
581 combinational ALUTs / 246 dedicated registers in the native resource table.
The application clock is bank0's clock; the existing PIM still transports host
and memory clock crossings. This is not a claim that every interface is single-clock.
The selected completion monitor observes the page-limited B channel before split
response suppression. [Source selection](source-selection01.json),
[completion shim](../../afu/ahls_memory/pim/ia840f_ahls_memory_bank_completion_shim.sv).

## Physical review obligations retained

- Synthesized `LNT-30010` directly names the application reset join and mixed
  CLRN/SCLR/ENA loads. Inspect final distribution, recovery/removal and synchronous
  timing; sim05 does not qualify stopped clocks or active-transaction reset.
- `TMC-20501` explains zero implemented reset duplication despite requested depth6
  as all fanout being in one hierarchy. This is not a timing/fanout waiver.
- `Critical19854` includes explicit initial settings for the reset joins, bank
  resets and guard state. Check actual fitted/PR reset sequencing.
- The synthesis partition table retains `green_region` as Reconfigurable despite
  `Critical20580`. Require matching final partition-preservation and ignored-
  assignment evidence; synthesis's invalid root-QDB/reset targets are not proof
  that the fitter consumed or discarded them.
- Preserve the 3.000 ns requirement and inspect effective vendor FIFO delay/skew,
  recognized crossings, unconstrained paths and complete final timing.

These observations are in the hash-bound native `ofs_pr_afu.syn.rpt` and
`ofs_pr_afu.drc.synthesized.rpt` under `synth01-capture/persona/build/syn/board/ia840f/syn_top/output_files/`.

## Inherited host metadata

The selected legacy `csr_mgr.sv` assigns raw512 to a three-bit width field and
raw32 to a four-bit depth field: both read as zero after truncation. Do not treat
these legacy fields as literal capabilities. The existing raw-capability decoder
uses the versioned read-only block instead; preserve this distinction in the
new host frontend. The legacy wide status assignment retains the busy/error/
control bits used by the accepted DMA protocol; performance counters have their
own addresses. This metadata caveat does not demonstrate a CAPS03 retirement
failure. See the native warning ledger and selected source hashes above.

No physical/reset/CDC, deployment, hardware numerical or clean-teardown acceptance
is granted by this synthesis milestone. The maintained top remains disabled by
default; only the offline qualification copy enabled completion.
