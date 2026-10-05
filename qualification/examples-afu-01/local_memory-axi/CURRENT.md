# AXI local-memory — commanded-data FPGA Test accepted

**PASS at the named scope.** Independent FINAL `deleg_bc8d8129` accepts native build/effective/PR exits **0/0/0**, followed serially by bank 0 and bank 1 host exits **0/0**. [Acceptance105](ACCEPTANCE105.json) consumes [review manifest96](review-manifest96.json); `summary96.json` remains unchanged, including its historical pending-review flag.

## Build and source binding

Native CMake/Quartus 26.1.1 Build130 completed the AXI persona. Exactly 24/24 bound inputs are preserved; AXI QSF selection, AFU UUID `35f9452b-25c2-434c-93d5-6f8c60db361c` and FIM interface UUID `fc603c44-5c8f-5e94-bcbe-a5780030947c` agree. Native GBS payload matches the assembled RBF. GBS SHA256 is `8954ef02d11c6a9e7c3d5442693dd8606e0679f3f248435a1e3536630cc53bfa`. [Build acceptance95](build-artifacts95-readback/build-acceptance95.json), [native result](build-artifacts95-readback/compile-result.json), [collection95](build-artifacts95-collection.json).

Programming images and the oversized compile log remain remote-only, with sizes/hashes in the collection and build receipts. No rebuild was performed to consume this review.

## Actual card test

[Runner95](hardware-runner95.py), [approval95](hardware-approval95.json) and [launch95](hardware-launch95.json) bind the exact command sequence: normal `fpgaconf` on PF0 `0000:4f:00.0`, then the existing checked local-memory host with argument `0`, then argument `1`. Host SHA256 is `77231a98040014fe12d85e4bcf40f0264dbca8da4d1d97d21e25a1783da09f72`.

Each bank reports exactly one correct selection, `NUM_LOCAL_MEM_BANKS = 2`, 11 exact `No memory errors. Test passed.` markers, and terminal `Done Running Test`. Durable native exits match owner/argv/cwd identities; PR stdout/stderr and host stderr are empty. `success=true`; scoped postflight owners, maps, relevant processes, D-state and errors are empty. Same-boot acceptance is recorded through the bound runner; standalone preflight was not exported. [Runtime collection95](hardware-result95-collection.json), [result95](hardware-result95-readback/hardware-attempt95/result.json), [bank0 output](hardware-result95-readback/hardware-attempt95/host0.stdout), [bank1 output](hardware-result95-readback/hardware-attempt95/host1.stdout).

## Coverage and remaining campaign state

Acceptance covers the reviewed enabled-byte 512-bit checker: nine nonzero-mask and two zero-mask commanded cases per bank. It does **not** qualify an unchecked sweep, bank isolation, full capacity, sustained performance, universal health/no-hang, or reset behavior.

This gate is complete; no repeat test is needed. The later copy-engine completion/PR failure is separate and is not waived by this acceptance. See the [authoritative campaign checkpoint](../CURRENT.md) for the unresolved recovery boundary and DMA hardware hold. No power-cycle, reboot or reflash is authorized by this disposition.
