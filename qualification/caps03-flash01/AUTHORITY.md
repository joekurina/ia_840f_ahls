# CAPS03 deployment authority

Joe explicitly directs accepted-image flash, BMC card power cycle, then workstation reboot; the established process is approved and must not pause again for the same permission/recovery-availability question.

Latest route decision: Joe explicitly said “Switch to the bittware sdk flasher.” Use `bw_agilex_flash_programmer` with a writer-compatible RPD derived from the accepted CAPS03 SOF, preserving the complete non-RSU single-image layout. The old JIC/JTAG route and its transport-restoration prerequisites are retired, not repeated. JIC remains file-only conversion evidence. Preserve fresh SDK-target/ownership checks, native program/readback/compare, separate BMC Off/On readbacks and new-boot verification. The established flash → BMC cycle → workstation reboot authority remains valid; no renewed permission/recovery-availability question. Independent recovery is not claimed. No kernel/DMA or speculative MMIO in this deployment scope. Existing functional/reset-entry/lifecycle gates remain separate.

Evidence precedent: ../caps01-jtag-w13-01/RESULT.md. Source SOF and physical/assembly acceptance: ../caps03-persona01/ASSEMBLY-ACCEPTANCE01.md and PHYSICAL-ACCEPTANCE01.md.
