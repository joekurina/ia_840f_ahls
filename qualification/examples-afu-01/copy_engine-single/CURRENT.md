# copy_engine-single — recorded FAILED-data FPGA Test disposition accepted

**FAILED hardware data verification.** Independent FINAL `deleg_37f9cfb7/task0` accepts the failure report, not a hardware pass. [Disposition120](FINAL-DISPOSITION120.json), [frozen review119](review-manifest119.json).

Native/effective build0/0 and normal PR0 do not override the actual host exit1. Attempt115 covered 32 buffers x 64 bytes; completion frequency 1; max requests 1; noninterrupt; its output reports **2048 data mismatches**. Root cause is unresolved; no MPS/address/protocol attribution is claimed. [Runtime collection](hardware-result115-collection.json), [native/data result](hardware-result115-readback/hardware-attempt115/result.json), [stdout](hardware-result115-readback/hardware-attempt115/host0.stdout).

Recovery was explicitly authorized and performed once through card-only PCI preparation, USB BMC Off/On with separate readbacks and one normal workstation reboot. Reboot110 failed before a native reboot because its assumed module path did not exist; corrected112 performed only the remaining reboot. Modules resolve through weak-updates to the older installed directory and match the loaded build IDs. New boot `c5b29027-5b6b-4bf2-b7ed-ace79cc87e73`, cached FIM UUID and AER-mask restoration were verified. No reflash or FPGA rebuild was performed. [Recovery receipts](../recovery-postboot113-collection.json), [BMC receipts](../recovery-power110-collection.json), [VF setup](../recovery-VF114-collection.json).

Final ordinary ownership lists are empty, but material kernel warnings at `195.897734` and `310.912886` state that pending transactions timed out and VFIO performed FLR anyway. **No global DMA drain, safe/healthy-card, future-health, reset or no-hang qualification follows.** Recovery's `quiescence_verified` flag is narrow PCI/process preparation evidence, not transaction-drain proof. [Final kernel/ownership collection](../final-card119-collection.json).

Earlier attempt97 PR0/host1 completion deadline, host-only99 AFU-not-found, reset100 ineffective and PR101 native5/PR Status timeout remain unchanged. The later 64-byte attempt reached 32 read/write counts but all 2,048 checked bytes mismatched. [Original boundary104](failure-disposition104.json).

This capsule supports final recorded-failure closure under the goal policy. No further hardware action is required to publish its disposition. [Campaign checkpoint](../CURRENT.md).
