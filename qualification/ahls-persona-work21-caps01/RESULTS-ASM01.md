# CAPS01 Work21 assembly01 — acquisition verified, review pending

Native/effective/outer **0/0/0**, complete/success true. Quartus25.1.0Build129, actual Work21release03 PR persona, AGFB027R25A2E2V. Native PID143823/start16410993;2026-09-23T22:00:38.140604Z–22:06:48.872269Z. Log footer0errors/19warnings, elapsed00:06:09, peakvirtual19405MB. All preservation flags true; no timeout, errors, callback rejection or recorded owned survivors. [Native log](artifacts-asm01/assembly.log),[parent verification](asm-parent-verification01.json).

Archive35648567bytes SHA256`6e59dcf930e814b09106ef4710d2c67327700a9fe4ef87193608b75b1c3430f2`;15exports verified against archive metadata and local bytes. Source13AFU/255generated records/AFUJSON match completed fit/STA. Reconstructed5762criticalbindings;5516prehash,26exact mutable paths,344protectedphysical paths all hash-bound. QSF delta only two guard-hook references. Historical resource preflight36allowedCPUs/QSF36/64GiB; no assertion of actual36worker utilization.

## Newly emitted persona images

Absent from the predecessor inventory, present in this completed stage; not substitutes for a verified deployable GBS:

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `ofs_pr_afu.green_region.pmsf` | 9222093 | `568f4927a093e78843e23bdab5e706cafbd6c15c05280d0ed06e91e5811ce783` |
| `ofs_pr_afu.green_region.rbf` | 9527296 | `25feda96e98155e39edc4e9188f70a1eb17dc1470f8b1525793bbb4d5d36b7e1` |
| `ofs_pr_afu.sof` | 9923144 | `d64f296cec0e8dbcc55292c2e566c09bef48e52fcce3a8d20287dc86b9a68f3a` |

Three inherited baseline files are byte-identical to preinventory: ofs_top.sof,ofs_top.static.msf,ofs_top.green_region.pmsf. They are not newly built here. Native log59–61 identifies their use for baseline mask/root-region checks. Native Assembler Generated Files panel explicitly lists personaSOF/PMSF; PRRBF is independently captured and was absent before this stage. No GBS is present in captured exports, and no post-flow/packager invocation appears in this native command/log; GBS completion is not claimed. [Image identities](asm-parent-verification01.json).

## Findings retained

19occurrences: **17Warning18502** current/baseSDC differences, **oneCritical20727** unusedPRinputs, **oneWarning20536** obsoleteGENERATE_RBF_FILE setting. Keep full ledger, not warning-clean. The assembler settings separately enable Generate Partial Reconfiguration Raw Binary File; the obsolete genericRBF warning does not erase the actual emittedPRRBF. No arbitrary setting correction/rerun. [Ledger](asm-warning-ledger01.json),nativeASMreport settings99/messages209/generated235–236.

The runtime success expression does not itself require image presence; the parent explicitly verified all three required new image members, their absence in preinventory and hash/size/local bytes before recording this bounded generation result. No image-presence inference from banner alone.

Fit F1–F6/Q1–Q4/R1R2, additional-reset requirements, BMC electrical gaps,46PRinputs/1098ignored assignments, reset/CDC/initialization and freeze/drain/fence/buffer lifetime remain. Separate finalSTA has645nonnegative constrained-domain records butDesignClosureFAIL22/88/10disabled/0waived and unconstrainedI/O. This assembly neither clears those nor accepts timing/functional/hardware behavior. VendorDDRsimulationSKIPPEDBYUSER. No FPGA/device/MMIO/programming/reset/driver/reboot operation.

Failed initial prerequisite captureouter125 is retained; it ran no assembler. Successful successor capture and help-only tool invocation are separate preparatory evidence. A local parent verifier initially applied `.encode()` to the configJSON dictionary; using captured exact JSON bytes resolved the schema mistake. No native rerun or evidence mutation resulted.
