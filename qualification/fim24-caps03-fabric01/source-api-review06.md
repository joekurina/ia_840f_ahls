# CAPS03 25.1 → 26.1.1 source/API review06

**Verdict: PASS for the proposed source/API adaptation.** No additional source change is justified before the first finite native experiment. This is not execution QUALITY acceptance, launch authority, or generated-fabric qualification.

Reviewer: GPT-6 (`gpt-6-astra-900k`, provider `openai-codex`), substituted for unavailable GLM5.3. Inspection used local reads, in-memory SHA256/AST/literal-data comparisons only; no repository script, test, Tcl, native tool, SSH, Git or hardware execution.

Paths below are relative to this directory. `C` denotes `candidate05/ia840f_ahls_memory_fabric_dma_fullwidth_hw.tcl`; `A` denotes `prepare03-readback/vendor26/altera_axi_bridge_hw.tcl`; `H/` denotes `deps04-readback/`.

## Binding and provenance — PASS

Independently rehashed **29/29** declared members, checking both lengths and SHA256: no missing/mismatched entries. `source-freeze05.json` SHA256 is `f9455dbc23ffbaf59899b9e18b1568c0db2619f606d5e23339e4852c84f9d45a`.

Read `../caps02-fabric-fullwidth01/generate01.py` strictly as capsule data, never imported/executed. Its SHA256 matches `eaedd0a192affd9ebb324ebedd863b2b28eb3c1be316d7453b59465fb10d570f`. AST literal extraction reproduces all four `baseline01/` inputs byte-for-byte. Its 224-member inventory plus the exact three LSU overlays and four inputs, with only QSF `NUM_PARALLEL_PROCESSORS 36` added, exactly reproduces the captured **228-entry** prepare03 inventory; the **155-member** expected HLS map is identical. These are local/captured-evidence checks, not a fresh remote preservation measurement.

Prepare02's failure was after copying, at its absent `quartus/qsys/bin` assumption (`prepare02.py:34–46`). Prepare03 checks the complete existing file set without recopying (`prepare03.py:35–46`); its captured tools bind both `quartus/sopc_builder/bin` and sibling `qsys/bin`. All eleven prepare03 embedded files and three deps04 helpers match their local readbacks, sizes and hashes. Preparation did not import/generate fabric. The captured export-acceptance hash matches `../fim24-pr-platform01/EXPORT-ACCEPTANCE39.md`; UUID remains `fc603c44-5c8f-5e94-bcbe-a5780030947c`.

## Source contract and bridge adaptation — PASS

The complete baseline/candidate byte comparison has exactly one replacement, at C:31: `altera_axi_bridge 19.9.3` → `19.10.3`, matching A:32. All four 69-parameter role maps remain unchanged. Every explicit parameter is declared in both vendor versions with unchanged declaration type/default; none of the 102 old names disappeared (108 now). Relevant property changes are removal of ACE_LITE_SUPPORT's range restriction and USE_PIPELINE visibility, neither requiring an AXI4 value translation.

C:178–319,337–376 preserves two independent 512-bit banks with 34-bit byte addresses, DMA entry IDs 9 and bank-output internal IDs 18, full-width Avalon stages only on HLS paths, burst/pending limits 64, both response enables, zero waitrequest allowances, direct DMA paths and component-only interconnect requirements. No `noNarrowTransfer` was introduced. All eleven top exports remain (`baseline01/make-system.tcl:4–19`). Avalon module 20.1.0 remains available; comparing its complete vendor25/vendor26 descriptor shows only copyright/display-name changes.

**New settings do not select a different protocol:**

- AXI_VERSION remains AXI4 and ACE_LITE_SUPPORT=0. A:2711–2721 selects the ordinary AXI4 helpers; A:2738–2752 applies the requested capabilities, and A:2804–2905 applies selected widths rather than retaining helper placeholder widths.
- ENABLE_AXI4_READ_ONLY_INTERFACE and ENABLE_AXI4_WRITE_ONLY_INTERFACE both default to **1**, meaning enable read and enable write—not exclusive modes (A:1968–1984). Channel termination occurs only for zero (A:630–690,852–912). Do not “disable” these new flags to preserve bidirectionality.
- UNTRANSLATED_TXN changes STRING/FALSE→INTEGER/0 (vendor25 descriptor:1269–1278; A:1472–1481), but the parent never sets it. Atomic/cache-stashing defaults are 0; the selected GUI-validation branch disables untranslated/atomic/stashing and snoops (`H/altera_axi_bridge/axi_gui.tcl:382–408`). Their interface-property effects are protocol-guarded (A:426–438,605–628,713–724,812–850). Optional role-user flags default 0 and derive ROLE_BASED_USER=0 (A:2537–2567). Loading AXI5 declarations or setting internal ENABLE_AXI5 does not override AXI_VERSION.

## Direct helpers and API — PASS

A:52–53,2153 unconditionally sources all three captured helpers: shared/axi5_interface.tcl, altera_axi_bridge/axi_interface.tcl and axi_gui.tcl. No further explicit source/package statements were found in them. GUI code is material: A:3055 calls its validate_parameters. Ordinary AXI4 interfaces are defined at `H/altera_axi_bridge/axi_interface.tcl:138–302`; AXI5 procedures are not selected here. This establishes the finite source/API graph, not independent vendor RTL requalification.

Retain component qsys 17.0 and HLS descriptor 15.0/14.0 requirements: these are API versions, not release labels. `proposed-commands05.json:4–19` uses scripting package 26.1, literal standard-catalog `,$`, the bound launchers and explicit AGFB027R25A2E2V. The create_system/add_instance/validate_system method has existing 26.1.1 evidence (`../ahls-qsys-import-01/report.md:40–53`); future fabric output is not a prerequisite for this review.

## Supplemental help and remaining boundary

Outside freeze05, verified help07 capture/log hashes and successful no-project receipts. `help07-readback/generate_help.log:172–177` (SHA256 `15bcacb6e5cee3210ca5de3303dd3018f2ac96492aa1dc8c0fbe854ed5a12ced`) documents omission as best-attempt available-core parallelism. Removing historical `--parallel=off` therefore meets policy; 36-CPU affinity/QSF36 and 64 GiB per-process are not an actual-worker claim.

Prepared03 still contains the baseline: separately stage/bind candidate05 and the correct 26.1.1 environment before admission. Native acceptance must check actual eleven-interface footprints/widths, every child `altera_has_errors`, diagnostics/status, dependency/HLS coverage and preservation. Matching-PIM integrated simulation must retain full-width size/alignment, masks, responses and arbitration checks. No additional reset/DDR-internal qualification, HLS resynthesis or hardware authority is created here.
