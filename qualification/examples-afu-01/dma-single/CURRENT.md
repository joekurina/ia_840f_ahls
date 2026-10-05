# dma-single — recorded FAILED-data FPGA Test disposition accepted

**FAILED hardware data verification.** Independent FINAL `deleg_37f9cfb7/task1` accepts the failure report, not a hardware pass. [Disposition120](FINAL-DISPOSITION120.json), [frozen review119](review-manifest119.json).

Native/effective build0/0 and normal PR0 do not override the actual host exit1. Attempt118 covered bank0 1024 bytes / 128 words / 16 beats; one descriptor each direction; separate pinned buffers; validated low32-bit IOVAs; its output reports **128 data mismatches**. Root cause is unresolved; no MPS/address/protocol attribution is claimed. [Runtime collection](hardware-result118-collection.json), [native/data result](hardware-result118-readback/hardware-attempt118/result.json), [stdout](hardware-result118-readback/hardware-attempt118/host0.stdout).

Recovery was explicitly authorized and performed once through card-only PCI preparation, USB BMC Off/On with separate readbacks and one normal workstation reboot. Reboot110 failed before a native reboot because its assumed module path did not exist; corrected112 performed only the remaining reboot. Modules resolve through weak-updates to the older installed directory and match the loaded build IDs. New boot `c5b29027-5b6b-4bf2-b7ed-ace79cc87e73`, cached FIM UUID and AER-mask restoration were verified. No reflash or FPGA rebuild was performed. [Recovery receipts](../recovery-postboot113-collection.json), [BMC receipts](../recovery-power110-collection.json), [VF setup](../recovery-VF114-collection.json).

Final ordinary ownership lists are empty, but material kernel warnings at `195.897734` and `310.912886` state that pending transactions timed out and VFIO performed FLR anyway. **No global DMA drain, safe/healthy-card, future-health, reset or no-hang qualification follows.** Recovery's `quiescence_verified` flag is narrow PCI/process preparation evidence, not transaction-drain proof. [Final kernel/ownership collection](../final-card119-collection.json).

Earlier hardware-hold103 remains historical; it is superseded by the actual failed-data attempt, not rewritten into success. Checked host source, native host build, ELF binding, response/count RTL corrections and valid GBS are retained in [host binding118](host-binding118-collection.json), [source acceptance73](source-review-consumed73.json), and [build103](build-artifacts103-collection.json).

This capsule supports final recorded-failure closure under the goal policy. No further hardware action is required to publish its disposition. [Campaign checkpoint](../CURRENT.md).
