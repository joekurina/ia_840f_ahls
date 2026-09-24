# Independent review — first live CAPS01 inspection

**Verdict: ACCEPT, bounded to this completed identity/capability inspection.** No source correction or repeated hardware run is required for this result. This is not DDR integrity, DMA, numerical AHLS, sustained-operation, durable-boot or blanket future-reset qualification.

Review was local-only: retained receipts, native/loader logs, runner code and the existing frontend acceptance semantics. No remote/device operation, build, source edit, git operation or repeated full mapping/reset audit was performed. Only this review was authored. Joe's current physical-access/continuation statement in `AUTHORITY.md` supersedes historical recovery-unavailable statements; the no-host-hang/no-speculative-MMIO boundary remains.

## Result and identity

- Run interval: **2026-09-24T20:54:01.441479–20:54:03.682811 UTC**. Native application, container and saved outer transport status are **0 / 0 / 0**; inner and runner acceptance are both true. The separately saved `afu-inspect02-outer-result.json` became available during review and was checked: its `result_sha256` matches the actual result bytes. Outer evidence is therefore **present**, not inferred from the success banner or dispatch receipt.
- The actual native log contains exactly the seven ordered application read markers: `0x0, 0x8, 0x10, 0x98, 0xa0, 0xa8, 0xb0`, followed by `PASSED: banks=2 beat_bytes=64 host_address_bits=57 max_descriptor_beats=130816`. No native failure or loader error is present. Each marker is printed **before** its read; markers alone would not establish completion. Here the final pass and native zero, under the bound frontend, establish completed comparisons, decoder acceptance and successful reported cleanup/finalization.
- `src/host/ahls_memory_inspect.c:30–34,50–91,97–110` requires one accelerator token at the supplied **`0000:4f:00.2`**, GUID **`673c03a1-cef3-4c82-bf10-b12c247d9718`**, PCI tuple **`8086:bccf / 8086:1771`**. It then compares the complete DFH `0x1000010000000000` and both GUID words. The passed source predicates support that exact identity, not merely a generic capability signature. The UUID/raw words themselves are **not printed readback captures**. This identifies the expected persona contract, not a cryptographic measurement of the complete programmed bitstream.
- The four printed capability fields are supplemented by the closed decoder at `ia840f_dma_capabilities.h:26–52`: ABI tag/version `0x49413834444d0001`; data width512 bits; configured data FIFO32 beats; descriptor FIFO16 entries; banks2; bank-address34 bits; host/common-descriptor-address57 bits; length20 bits; beat64 bytes; AXI LEN8 bits; mode mask6; maximum admitted descriptor130816 beats; reserved high byte zero. These additional fields are **inferred from successful exact decoder checks**, not independently captured raw values. Advertised geometry/admission limits do not establish exercised capacity, address reach or transfer correctness.

The frontend, decoder, startup, entry and common helper bytes match the original Target01 source payloads/input hashes. Captured compile commands compile this frontend as `ahls_memory_frontend_main`; captured launcher/entry/core/plugin binary hashes match this live binding. Existing Target01/Work21/CAPS01 artifacts were reused, not rebuilt.

## Runtime, bindings and postflight

- Preflight and completed-run boot IDs agree: **`598f7b27-1798-4a88-8a79-9e4a2659c64d`**. Cached FME compatibility UUID is **`fc4bf1c1-760f-5cd7-8040-b3e86fa0d31e`**, consistent with Work21; it remains probe-time cached identity, not a new full-image or durable-boot test.
- Recorded PF0/PF1/VF drivers remain respectively **dfl-pci / vfio-pci / vfio-pci**. Preflight binds the loaded module notes/on-disk hashes and VF BAR0 of1048576 bytes; the inner preflight rechecks PF0 parentage, singleton group76 and literal `flr\n`. These are recorded run-time observations, not fresh remote observations by this reviewer.
- Container arguments and successful inner checks establish read-only `/work`, `/exec`, `/empty`, `/sys`, empty working directory, and only VFIO control plus group76 exposed from `/dev/vfio`; no DFL/FPGA/UIO/DRI entries are admitted by that check. PF0/group4 and management PF1/group5 are not exposed. PF0 remains dfl-pci, avoiding the reviewed conditional VFIO PF-companion open.
- Root ownership scans before and after return empty `d_state`, `relevant`, and `holders` lists. I verified the embedded scanner against its bound hash. It inspects process FDs for `/dev/vfio/`, `/dev/dfl`, `/dev/fpga`, `/dev/mem`, plus selected programming processes. This supports **no observed relevant holders at postflight**, not continuous exclusivity, exhaustive mapping/kernel ownership or proof of DMA drain; disappearing/inaccessible processes are skipped. Original bound runtime/config files are reported unchanged after the run.

## Actual loader selection and reset meaning

`inner.loader_logs["loader.16"]` is complete hash/length-checked evidence, byte-identical to the extracted `loader.16`. Its **calling-init** records, not unsuccessful `trying file` search candidates, select:

- `/work/build/libahls_memory_entry_vfio_strict.so`;
- `/work/sdk-build/lib/{libopae-c.so.2,libopae-v.so,libopaevfio.so.2,libopaemem.so.2}`;
- `/work/prefix/usr/lib/x86_64-linux-gnu/{libjson-c.so.5,libuuid.so.1}`;
- `/lib/x86_64-linux-gnu/libc.so.6` and `/lib64/ld-linux-x86-64.so.2`.

Application/backend/support selections agree with the hash-checked `inspect02-binding.json` closure and retained build/copy identities. The interpreter spelling matches the captured launcher's ELF INTERP; binding records canonical `/usr/lib/...` system objects. This is loader-path plus file-binding evidence, **not independent in-memory mapping attestation**. No xfpga, UIO or ASE library is initialized in the retained log. The strict config names only `libopae-v.so` and the VF PCI tuple; IDs alone are not unique-card isolation, so the exact BDF, parent and exposed group matter. The hash-equal launcher copy is executable without changing the original mode0600 artifact.

The native “No ... reset ... performed” banner means **no explicit application reset API**. It does not mean process-wide passive reads. Reusing the existing `VFIO-RESET09.md` disposition, enumeration and application open/close traverse implicit kernel function-reset paths; the backend can enable PCI COMMAND memory/bus-master bits and map regions RW. Enumeration GUID reads also precede the seven application markers. No reset-count trace was captured, and neither exact FLR count nor absence of all conditional lower-layer effects is claimed. This one invocation returned normally, retained its boot/bindings and left no observed holders; that is empirical acceptance of this bounded access path, not general no-hang/reset/clock/CDC or DDR safety.

## SHA256 bindings checked locally

Hashes below identify actual local bytes, or the exact embedded log bytes. The separate extracted native and loader logs match their receipt payloads; all three command-output hashes also verify. Embedded runner `INNER` and `BIND` agree with their separate local files.

| Evidence/source | SHA256 |
|---|---|
| `afu-inspect02-result.json` | `953b5a67c61f6cd0ce24ed8ae64db0f35d9642fcc19a8e906cf6a7f9c54f10b4` |
| `afu-inspect02-outer-result.json` | `ee5d25daaf917549d2b5165584e83a6301577c102f3a21e940b82b90968d0842` |
| `afu-preflight01-result.json` | `fbb8e819ecc656caa6255b464b20bfe4276e7c0583ed341b20202d741ce49636` |
| Native log | `664c7cb860be3911d95861ef58bd28493935e4d40b9f344f863263bd7b8268bd` |
| `loader.16` (8713 bytes) | `8485101a8bdd2854cb440d14d0090973fd16d3e5b9e0abc4e5eb872485f59588` |
| `inspect02-binding.json` | `13109337f3838d792056a6b57edfb3d4143e41f5054f4cbd5e779ea75a7dddf0` |
| `inspect02-inner.py` | `3b216aeba7e7d1d93e9dd594c6c85a4025b8699e23402447ff6664db79aede84` |
| `afu-inspect02.py` | `0e8f57d8c2ee4c8cae13047f45aad05ce0124a5cb8155099218313bde6488eaf` |
| `src/host/ahls_memory_inspect.c` | `eb36fb35fb3e26087ba9d2bb59d02750a14f7c6fa7ad852378fc20dc268ede2b` |
| `src/host/ia840f_dma_capabilities.h` | `908907f046da9ed16fe6d10e9433bd84e85807ea80be6882c568de35d34a4c49` |
| `src/host/ahls_memory_vfio_startup.c` | `e28d1b390aa6c6aff656e088dbc33af57cb339177165ef782249850674e5ac20` |
| `src/host/ahls_memory_entry_vfio_strict.c` | `ca1ca46f034753378a36a7481bfe68f5f28a0e923c3b14d5548240e9cdd53caa` |
| `src/host/ahls_qualification_core.c` | `52e7ff9492d0432bfb1e55dceb4368720bbe17c994f6d49a60c67b660454ca74` |
| `src/host/config/ia840f_caps01_vfio.cfg` | `f947ee14eabace1d1ea0a7d5af5d11bc74ee7a5f17ec6de4fa317c25ac82b397` |
| `qualification/caps01-vfio01/target-inputs01.json` | `cd9bd907a9826448a25215416ba02a5bbeef21db39435f19b8a30d9f8b14cf36` |
| `qualification/caps01-bwflash01/native-host-target01.json.gz` | `9ad9bb10420fa9bfcb45a91969979d8a607f333fb59174f8aa235ec0910fdb5b` |

**Disposition:** accepted with the explicit measurement/inference and reset boundaries above. No outstanding evidence discrepancy blocks this first inspection's bounded acceptance; broader functional qualification remains unclaimed.
