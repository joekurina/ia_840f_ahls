# Page-safe AHLS / real-PIM candidate — Quartus 25.1

Run native analysis and elaboration of the exact successful functional candidate's two LSU reset-index corrections and final page-boundary wrapper inside the real Work21 PIM top. Keep all original source and accepted captures unchanged. This is a changed candidate, not an unchanged rerun.

The alternate `ofs_plat_afu_pagesafe.sv` retains one primary host mapper and changes only the two-bank shim type to `ia840f_ahls_memory_bank_shim`; compile it alone under the original top module name. The wrapper bytes are identical to functional path08 shim03. The two generated overlays exactly match path08; no regeneration or installed-source edit. Remove only the redundant QSF macro already defined by the preserved generated platform header.

Reuse the prior native runner with a fresh exclusive work root, hash-bound source/candidate inventories, two-core affinity, 16 GiB per-process address-space limit, 600-second command deadline, owned-group lifecycle handling and native/outer receipts. The successor fixes predecessor review F4 by requiring platform preservation and empty postflight errors in acceptance; ten inert truth-table fixtures exercise the actual expression. Read back four previously missing generated exports without modifying them. Parent only operates the remote workstation through owned tmux.

This gate does not run mapped synthesis, fitter, STA, FIM assembly, FPGA programming, MMIO, device access or drivers. Functional review is separate and still pending. Native A&E is not hardware readiness. Freeze/global drain, outer MMIO aliases and posted error visibility, telemetry, real PCIe/OPAE, physical DDR, lifecycle and full-FIM signoff remain open. Vendor DDR simulation stays SKIPPED BY USER.
