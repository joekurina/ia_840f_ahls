# CAPS03 normal-return FPGA Test: numerical pass, lifecycle warning

## Actual result

One invocation of the original CAPS03 frontend completed on the unchanged accepted FPGA image, Work21 FIM and 3.000 ns target. The original AHLS-SIF launcher and entry module were reused, not rebuilt. The operation began at `2026-09-26T19:33:13.012272+00:00` on boot `8121620d-a638-42f8-abab-a547aae32076`. The actual native exit was **0**, while the outer exit was **1** because kernel-interval inspection rejected a clean-lifecycle claim. [Run receipt](live21-result.json), [outer receipt](live21-outer.json), [original native build](../caps03-host01/NATIVE-BUILD01.md).

The frontend passed exact identity/capability comparisons, retired and checked all six DMA descriptors, observed finish ticket 1 and completion `0x10002`, and checked the nine signed results plus all 156 non-result bytes in the returned 192-byte span. Both complete host pages were checked after each descriptor. It then completed its original buffer-release/unmap/close path and printed the original frontend pass footer. This is more than a completion banner: the unchanged frontend actively compares copied-back payload, padding and guards. [Native log](live21-native.log), [source](../../src/host/ahls_memory_caps03.c), [transfer core](../../src/host/ia840f_dma_transfer_core.c).

Postflight observed no VFIO/device holders, mapped owners, relevant application processes, D-state tasks or collector errors. This is process/resource evidence after a normal application exit, not proof that a kernel reset had no warning. [Run receipt, `ownership_after`](live21-result.json).

## Kernel warning retained

The same run interval contains exactly one concern line:

```text
2026-09-26T12:33:17-0700 Agilex7Workstation kernel: vfio-pci 0000:4f:00.2: timed out waiting for pending transaction; performing function level reset anyway
```

The other interval lines are the VFIO device-enable messages. The explicit result remains `numerical_data_pass=true`, `application_exit_passed=true`, `lifecycle_clean=false`, `success=false`, native 0, outer 1. No automatic successor, PCI configuration write, reset bypass, message suppression or further recovery was performed. [Kernel log](live21-kernel.log), [result](live21-result.json), [outer status](live21-outer.json).

This warning matches the previously documented warning class and applicable P-Tile multifunction/VF Transactions Pending status erratum. That evidence establishes a possible sticky-status explanation, not its exclusive cause in live21. It does not turn this run into warning-free teardown or prove an absence of every possible outstanding transaction. The existing independent erratum review was already consumed; its applicability question is not reopened. [Erratum disposition](../caps01-dma-gib01/ERRATUM11.md), [review](../caps01-dma-gib01/erratum11/REVIEW.md), [consumption](../caps01-dma-gib01/erratum11/review-consumed.json).

The vendor workaround is endpoint/application-side CII or Direct User Avalon-MM handling, with truthful pending upstream-MRd completion accounting before clear. It is not an arbitrary host `setpci` write, a forced-low bit, or a reset-timer change. CII is disabled in the bound Work21 IP. A bounded source inspection has not identified an already-implemented tracking-and-clear procedure to reuse; that is not an exhaustive absence proof or permission to add a new subsystem. [Vendor section, lines 21–42](../caps01-dma-gib01/erratum11/production-errata-section2-1-3-4.txt), [source observations](pending-source22.json).

## Retained live13 owner disposition and current boot

Review `deleg_6b73b417` accepted live13's finite successful state against the existing release-then-close contract; it did not infer eligibility from `0x10002` alone. The additive retained wrapper itself had no cooperative release continuation. Parent verified the review bindings, ran a fresh owner-bound preflight, and issued one ordinary OS reboot under standing authority. There was no preliminary SIGCONT, kill, BMC cycle, reflash or explicit PCI reset. [Consumed review](lifecycle-review15.json), [recovery preflight](recovery-pre15-result.json), [reboot dispatch](reboot16-dispatch.json).

Postboot17 verified the new boot above, ended old process/namespace ownership, expected Work21 FIM identity and preserved PF bindings. This is recovery evidence, not a normal exit of live13 and not proof of an electrical card cycle. Fresh preflight18 and create19/bind20 then restored the single application VF before live21. [Postboot verification](postboot17-result.json), [preflight](preflight18-result.json), [VF creation](create19-result.json), [VF binding](bind20-result.json).

## Remaining work

Independent local-only result review `deleg_474adbdd` is pending for live21's actual native-zero/data-pass/warning result. It does not authorize hardware or implementation. The workstation has no retained test owner as of live21 postflight; no hardware test is running.

Warning-free lifecycle, expanded/repeated numerical cases, full independent/isolation/simultaneous DDR coverage and sustained operation remain incomplete. Preserve the accepted image and source pins. Resolve a supported status/lifecycle route before another live test; a feature absent from the two primary reference implementations requires the scope decision specified by the maintained goal. Do not replay old retained-owner recovery instructions. [Goal](../../GOAL-PROMPT.md), [DDR gate](../../docs/ddr-hardware-validation-gate.md).
