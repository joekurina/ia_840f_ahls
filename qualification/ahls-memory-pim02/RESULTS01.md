# Corrected memory AFU in the real PIM — native Quartus 25.1

**Native analysis/elaboration passed; independent result review pending.** This is not mapped synthesis, timing, full FIM or hardware acceptance. [Scope](SCOPE.md), [exact source delta](source-binding01.json), [parent verification](parent-verification01.json).

## Actual run

Fresh remote `work_ahls_memory_pim25_02/elab01`, tmux @234/%234; `/opt/altera/25.1/quartus/bin/quartus_syn --analysis_and_elaboration --read_settings_files=on --write_settings_files=off ia840f_ahls_memory_pim_elab -c ia840f_ahls_memory_pim_elab`.

Quartus 25.1.0 Build 129 SC Pro, AGFB027R25A2E2V. Native/effective/outer **0/0/0**, start 2026-09-23T12:36:26.065933Z, end 12:37:28.691258Z, PID110042/start_ticks13025783. No timeout, descendant-at-leader-exit or remaining owned group. All six source/copy/platform/core/tool/QSF preservation flags true; postflight errors empty. Native banner says synthesis successful, but argv explicitly limits the result to A&E. Recorded peak virtual memory3128MB; no timing/performance claim.

Result archive SHA256 **46c5bd58c1ebbaec99cfdb9872aaa7fded565ba27c7f137a539d821aaadc5606**, 1,204,831bytes. Parent verified all13 exported members and decoded bytes. [Manifest](manifest-elab01.json). Oversized full reports and vendor/source payloads stay local/hash-referenced.

## Candidate binding and structural proof

- 274 platform/core inputs plus255 generated dependencies = **529 bound inputs**. 262 platform originals remain byte-identical, as do the255 original generated source members. Exactly two generated copies differ from that original inventory: the reset-index corrections in the read/write burst-coalesced LSUs, byte-identical to functional path08.
- Alternate `afu/ahls_memory/pim/ofs_plat_afu_pagesafe.sv` changes only the bank-shim instantiation type from the original top. It keeps one primary host mapper and both banks, clocks, joined resets,18-bit arbitration IDs and2-bit USER. Exactly one `ofs_plat_afu` implementation is selected. Added bank-wrapper bytes match functional path08 `ia840f_ahls_memory_bank_shim03.sv` exactly.
- QSF change: add the one wrapper source; remove only redundant command-line `AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU=1`, which remains in the preserved generated platform header. No clock/pin/SDC or physical DDR edits. Native QSF is unchanged after this run.
- Native parameter panels explicitly list **both** bank page-splitter instances with PAGE_SIZE4096. The underlying count-zero/count-one gearboxes use64-line pages and the intended8→5-bit AXI LEN adaptation (count-one widths9→6), preserving source ID/USER fields through the existing memory shim. Original physical interfaces retain their source-derived geometry. [Native panels](native-parameter-panels01.json).
- Original PIM sources and installed vendor files are untouched. The new wrapper uses existing PIM splitting, WLAST, NO_REPLY and clock-connector machinery; this native run proves structural consumption, not exhaustive protocol behavior.

## Diagnostics and predecessor findings

Full log contains **226 warning occurrences**:13469×90,21610×86,16788×22,21442×19,16752×2,21705×2,13461/17498/20759/21620/23762 each1. Native banner's1warning is not the detailed count. [Complete ledger](warning-ledger01.json), [source hashes](warning-source-binding01.json).

Relative to predecessor341:118 duplicate-macro warnings disappear;3 width warnings appear in the newly active bank splitter (PIM burstcount gearbox48 and map_bursts177/273). Four read-LSU warning line numbers move byone after the reset-index expansion, not four additional warnings. Copies of address/LEN fields before explicit mapped overrides and count-one to count-zero conversion explain the new sites; they remain available for independent review, not blanket-waived. All diagnostic source files are locally bound.

RES-10204 remains High1,0waived: device Reset Release is not instantiated in this standalone AFU root. Freeze remains ineffective; no lifecycle or PR safety is inferred. The full FIM must establish reset-release topology. No dummy device-level IP or waiver was added.

Predecessor F4: the changed runner now requires platform_originals_unchanged and empty postflight errors as well as all other checks. Ten inert fixtures exercise the actual acceptance expression, including the previously omitted flag, missing flag and nonempty errors. These are Python bookkeeping fixtures, not native FPGA evidence. [Fixtures](runner-acceptance-fixtures01.json), [runner delta](runner-delta01.patch).

Predecessor F5: this run exports the two CMP metadata files, reset-controller SDC and parameter-assert header that were missing from the predecessor's local generated mirror. All four match the original recorded hashes; they are stored under artifacts-elab01/generated. This is recovery by ordinary file reads, not regeneration or a change to the old evidence. Functional preparation had independently located matching SDC/header bytes in older captures.

## Still open

The separate path08 simulation passed91 sums and1088 copied bytes; its independent review is pending and is not manufactured by this native result. Actual primary PCIe mapper execution, host-visible MMIO rejection/posted fault telemetry, error codes/control/drain/fences, buffer lifetime, freeze/PR, mapped/full-FIM build/fit/STA and physical DDR/OPAE/durable boot remain unqualified. FIM Work21 signoff findings remain unwaived. No FPGA access, programming, driver change or reboot occurred. Vendor DDR simulation remains **SKIPPED BY USER**.
