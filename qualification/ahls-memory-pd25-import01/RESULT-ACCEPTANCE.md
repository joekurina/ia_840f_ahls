# Corrected AHLS memory IP: native import/generation acceptance

**ACCEPT_NATIVE_IMPORT_GENERATION_ONLY.** The parent consumes [FINAL independent review](independent-review02.md), SHA256 `a1143ae4ac7e683b395e05a9e343bc6c6c4086e263e58bdf72ca34ce804ae30b`. All 28 frozen review-package entries and all 22 archive members were rehashed/byte-compared locally; the retained import02 archive matches `4e86b60a26c5cd0ec19557d5aa4cde3d2fc4c31a3b7b3572416615568cb6a705`.

Native Quartus 25.1 import/validate/save and synthesis-HDL generation each returned zero. Captured preservation/source-copy evidence and the native interfaces agree with [RESULTS02.md](RESULTS02.md) and [interface ledger](interface-ledger02.json). Two logical 34-bit byte-addressed 256-bit memory hosts and a 5-bit word-addressed 64-bit CSR are established; logical interface names are not physical bank routing. The accepted backpressure correction survives generation unchanged.

Full HDL elaboration/synthesis, connected adapters, clock/reset behavior, DMA/PIM and host visibility, fit/timing and hardware remain unqualified. Clock frequency was unspecified. Keep import01 and probe01 failures; do not relabel them clean or rewrite their receipts. This gate does not accept the future memory AFU or authorize deployment. DDR simulation remains **SKIPPED BY USER**.
