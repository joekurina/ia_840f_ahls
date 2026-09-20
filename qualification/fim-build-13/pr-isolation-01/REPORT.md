# PR Isolation-01 — Runtime-PR A/B Matrix: W13 base rbf vs vendor persona (2026-09-19/20)

## Question

Why does runtime PR (`fpgaconf`) of our W13-built `.gbs` fail with
"PR Completion ACK timeout" while the card otherwise runs our W13 FIM perfectly
(flash boot verified, DDR calibrated)?

## Method

Forge GBS containers by hand (OPAE `packager create-gbs` rejects the OFS JSON
schema) and A/B test payloads and engines independently:

- GBS container = `"XeonFPGA"` + `"GBSv001"` + u32 LE JSON length + JSON metadata
  + **raw (uncompressed) rbf payload**. Required JSON: `version`,
  `afu-image.accelerator-clusters[].accelerator-type-uuid`, `interface-uuid`
  (must equal running FIM's Pr Interface Id), `magic-no: 488605312`.
  Builder: `pr/build_gbs3.py`.
- PR engine registers via PF0 BAR0 mmap (`pr_probe.py`, `dfh_walk.py`):
  PR_MGMT feature at offset **0x70000** (DFHv1 id=0x1005): DFH+0x00,
  PR_CTRL+0x08, PR_STS+0x10, PR_DATA+0x18, PR_ERR+0x20, INTFC_ID_L+0xA8,
  INTFC_ID_H+0xB0.

## Results

| Payload \ Engine | vendor 23.1 FIM | W13 26.1.1 FIM |
|---|---|---|
| vendor `ofs_pr_afu` persona rbf (9.1 MB) | **RC=0, silent dmesg** | timeout (cross-image) |
| vendor `ofs_top` base rbf (9.4 MB) | **RC=0** | — |
| W13 `ofs_top` base rbf (6.9 MB) | timeout ×1 | **timeout ×4** |
| W13 rbf, byte-reversed (bitswap) | timeout | — |

Key observations:

1. **Host kernel PR path is good**: vendor GBS loads RC=0 with zero dmesg
   noise. Not a driver/permission/AER problem.
2. **W13's `ofs_top.green_region.rbf` is the defective artifact** — rejected by
   both a known-good vendor PR engine and our own. It is a **base-revision
   artifact** (from the W13 full compile), not a persona-PR artifact.
3. Bitswap ruled out (same failure). Compression ruled out (entropy profiles
   of both rbfs ~21–28% zero bytes, both raw).
4. `fpgainfo port` Accelerator GUID reads zeros even after successful vendor
   PR — **not a valid failure indicator**. Ground truth: UAFU DFH at
   BAR0+0x71000 (vendor post-PR GUID `3ab49893-…` verified).
5. PR engine states: idle CTRL=0x0 STS=0x1ff ERR=0x0; post-fail CTRL=0x3000
   STS=0x51101ff ERR=0x8 (pass counter advanced but AFU never loaded). PR_RST
   handshake self-clears. `INTFC_ID` reads `c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`
   (W13) — matches GBS headers.
6. Driver protocol (`linux-dfl-backport/drivers/fpga/dfl-fme-mgr.c`):
   data pushed 32-bit via PR_DATA under credit throttling (credits flowed for
   the full 6.9 MB — the engine consumed the entire stream), then
   `write_complete` polls PR_START self-clear; timeout is only at final ACK.
   The engine accepts the data but never signals persona activation.

## Conclusion

W13's PR release tree (`pr_release_13a`) never produced a persona artifact —
`--stage=finish` was never run and no `afu_synth` persona build was performed.
The 6.9 MB rbf used in tries 1–4 was the base compile's green-region dump,
which is not a runtime-loadable persona. **Fix: build the real persona via
`afu_synth_setup` + `afu_synth` in the release tree** (in flight:
`work_ahls_persona_01`, log `/tmp/fim13-gates/persona_build.log`).

## Success criteria for the persona GBS

- `ofs_pr_afu.green_region.gbs` produced by `gen_gbs.tcl` post-flow hook;
- load on W13 via `sudo fpgaconf` → RC=0, silent dmesg;
- UAFU DFH at BAR0+0x71000 shows AFU UUID `67bc266a-56f7-440a-bb75-12b5f446d842`;
- `/tmp/ahls_mmio_test` enumerates and exercises status/start/result registers.
