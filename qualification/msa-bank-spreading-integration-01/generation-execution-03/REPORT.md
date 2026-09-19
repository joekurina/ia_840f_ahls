# Candidate03 native execution result

**Completed exactly once; independent result review remains required.**

- Staged and remotely hash-read back all 36 reviewed files. Both accepted review hashes were verified before exclusive consumption. Consumed-review SHA256: `bbe12720169ac351807210689003e7c4f3d92aa9fc04e7ff0302fe0cbb6e2102`. Manifest unchanged: `8da56f00d8e49f95fe1d3fbd90812440cd7c5af39f8bd4d267b3c360e9b9543c`.
- Live preflight, native save/reload, native synthesis generation and outer runner all exited **0**. Owned tmux session `ia840f_mailbox_monitored_01`, fresh native window `msa03-native-cd26b24c4c`. Claim retains runner PID 164118, start ticks 9987439 and exact argv/cwd. No retry or reused WORK/RUN.
- Strict saved comparison passed: 3,016 parameters; exactly two serialized changes, scoped NUM_BANK_FIFOS 8→0. Both NUM_COPIES remain 1. First-save/reload byte-identical, SHA256 `58b2409deb345a56a34b557d735d532d9b61b93b4a58c9dce2c5ab26f02e45c4`.
- Full fresh output inventory: 284 files. All 17 captured synthesis counterparts exist. Both MSA wrappers pass zero/copies1/full ordered parameter-and-connection-map preservation; all four wrappers preserve ports. Top wrappers have no parameter/connection changes. Captured SOPCINFO differences are 12 timestamp comments plus the two expected MSA FIFO values; saved IP has its two expected changes. No other serialized interface/clock/reset/connection drift in compared artifacts. Full deltas remain retained and unapproved.
- Post-run verification: 1,360 SOURCE files, 530 PIM entries and 419 dependencies unchanged. QSF SHA256 `ad68b5bf4666731449b2ae326a0f307065d112fb6bb0a9a0a072a0cd6cb1516c` remains bound (hold ON, seed2, maximum placement effort). No SOURCE/gate/pin/clock/geometry/calibration/PCIe edits. Also verified 21 captured Work11 targets and all 34 candidate02 manifest entries unchanged.
- Retrieved all actual WORK outputs, full logs/invocations/status/comparison maps and consumption evidence: 302 files individually remote/local size and SHA256 verified. Archive `actual-results.tar.gz`: 2351038 bytes; SHA256 `4fce51d6111f5e160f8576de259cf4533d1b1174a9051b42626e789d0e5775a0`. Separate post-export preservation readback: `baseline-preservation.json` and transfer envelope. Reproduced saved/generated comparisons locally on retrieved actual outputs; Python tuples were JSON-roundtripped for equality with the serialized report. No native retry was involved.

## Evidence paths

Local root: `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification/msa-bank-spreading-integration-01/generation-execution-03`
Remote package: `/home/uwb_student00/ahls/new_BSP/qualification/msa-bank-spreading-integration-01/generation-candidate-03`
Remote WORK: `/home/uwb_student00/ahls/new_BSP/work_ia840f_msa_generation_01`

- `actual-results/package/run/result.json`: SHA256 `25528e967ba7b1451af2608b3515db959fd23ea643d86eb183f5b94f7ab82247`
- `actual-results/package/run/saved-comparison.json`: SHA256 `5a6e66c9968977c0734c507569de9b1d9eeed727a0e090e2e58ae8685bc6bb36`
- `actual-results/package/run/generated-comparison.json`: SHA256 `dfa10442e7ef225d7178cb77c0ded7f5c1e26d36fd9f9f3b3f2616e858931767`
- `transfer-inventory.json`, `transfer-meta.json`, `stage-readback.json`, `consumption-readback.json`, `verification-summary.json`.

## Limits and next barrier

No native execution blocker. The warning that no Quartus project was specified is retained: this is the reviewed standalone context. No Query04/equivalent, full compile, DDR simulation, hardware action, installation, permissions change, commit or push. No checker/package relaxation. All execution/functional/timing/constraint readiness remains false and generated_acceptance=false. Calibration association remains unresolved; preserved wiring does not establish functional correctness. Independent actual-result drift/interface review is next.
