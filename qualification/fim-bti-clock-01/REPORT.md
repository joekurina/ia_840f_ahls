# IA840F bank 9A BTI reference-clock source evidence

## Result
The original IA840F BSP explicitly supplies qsfp_ref_clk at PIN_CC19 (positive), PIN_BW19 (negative), bank 9A, 156250000 Hz (156.25 MHz). This is the external reference clock, not SYS_REFCLK 100 MHz or a derived core clock. No retune is indicated.

Vendor root V: /home/uwb_student00/Documents/IA-840f installation/IOFS_BUILD_ROOT/ofs-ia840f
Current root W: /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_07

## Exact source chain and assignments
V/syn/syn_top/ofs_top.qsf:9 selects AGFB027R25A2E2V; :18 preserves unused transceiver channels; :117 includes ofs_top_sources.tcl.
V/syn/syn_top/ofs_top_sources.tcl:41 loads src/top/top.sv, :48 loads ../setup/eth_top.sdc, :72 loads ../setup/top_loc.tcl.
V/syn/setup/top_loc.tcl:105-106 assigns PIN_CC19/PIN_BW19 to qsfp_ref_clk/qsfp_ref_clk(n).
V/syn/setup/top_loc.tcl:254-262 contains:
```tcl
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL LVPECL" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_termination=enable_term" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_enable_3p3v=disable_3p3v_tol" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_disable_hysteresis=enable_hyst" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=156250000" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_powerdown_mode=false" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_bti_clock=TRUE" -to qsfp_ref_clk
```
Preserve exact historical lowercase bti. Lines 255-256 candidly say HSSI settings were inherited from N6000 and not in IA840F cardtest. This is nevertheless genuine shipped IA840F vendor source: archive-proof.json matches top_loc.tcl, top.sv and eth_top.sdc byte hashes against members read directly from ia840f-ofs-hldasp-2023.1.2-002.tar.gz (no archive extraction into vendor tree). Both installed vendor roots have identical selected files. The other 184320000/153600000/245760000 assignments are commented out, not alternative active IA840F BTI clocks.

V/syn/setup/eth_top.sdc:16 constrains this physical input to 6.400 ns. V/src/top/top.sv:30 deliberately declares qsfp_ref_clk unconditionally, with comment: included even w/o HSSI to PRESERVE_UNUSED_XCVR_CHANNEL. HSSI-specific ports begin at :41.

## Independent board/fitted evidence
IA-840F_Hardware_Reference_Guide.pdf (2025 BittWare), SHA256 46587bf900db5c8f3acb96922a4c4c0adfa88d680d9c3a184a691289b7e6d942:
- page 32 Table 6: all three QSFP-DD ports use bank 9A; PCIe x16 uses 10A.
- page 38 section 6.1: three default 156.25 MHz reference clocks feed dedicated transceiver reference pins.
- page 41 pin table: QSFP_CLK1_P / QSFPDD1_REFCLK = PIN_CC19; QSFP_CLK1_N / QSFPDD1_REFCLK(n) = PIN_BW19.
- page 52 Network Power-on Clock: Si5397 LVPECL outputs default 156.25 MHz at power-on; programmable via BMC I2C. This is documented default, not a live measurement or verification of present board programming.
Full pdftotext output and line-numbered extracts accompany this report.

V/work-ofs-23.1-2-build/syn/syn_top/output_files/ofs_top.pin:745,834 confirm BW19/CC19 and bank 9A. The vendor fit report :3 identifies Quartus 23.1.0 Build 115, patches 0.02iofs,0.10; :123 identifies same AGFB027R25A2E2V; :41618 states Info (21650): REFCLK qsfp_ref_clk at location CC19 is used to preserve unused channels. :42695 reports successful fitter. This directly establishes old successful use, rather than merely trusting an inherited comment.

## Migration gap and proposed minimal correction (NOT APPLIED)
W/src/board/ia840f/top.sv:63-65 places qsfp_ref_clk under INCLUDE_HSSI, whereas old top.sv:30 did not. W/syn/board/ia840f/syn_top/ofs_top.qsf:102 comments out INCLUDE_HSSI; :20 retains PRESERVE_UNUSED_XCVR_CHANNEL. W/syn/board/ia840f/setup/top_loc.tcl has no qsfp_ref_clk/refclk_divider matches. Restore a standalone unconditional input qsfp_ref_clk and its board-specific location/IO/HSSI assignments; do not enable the full HSSI subsystem just to obtain this clock.

The two frequency/BTI assignments with the current 26.1.1 diagnostic's spelling are:
```tcl
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_input_freq=156250000" -to qsfp_ref_clk
set_instance_assignment -name HSSI_PARAMETER "refclk_divider_use_as_BTI_clock=TRUE" -to qsfp_ref_clk
```
with the original board locations:
```tcl
set_location_assignment PIN_CC19 -to qsfp_ref_clk
set_location_assignment PIN_BW19 -to "qsfp_ref_clk(n)"
```
The paired BTI assignments alone cannot repair an absent RTL input. Retain donor electrical settings above unless a source-backed modern requirement supersedes them. Retain/reference the 6.400 ns input constraint separately; do not retune PLLs. Current diagnostic W/syn/board/ia840f/syn_top/output_files/ofs_top.fit.rpt:292-293 explicitly names bank9A, uppercase BTI key and frequency in Hz. Historical lowercase bti and modern diagnostic uppercase BTI are not silently normalized: modern parser case-equivalence and successful 26.1.1 implementation are NOT verified by this research. No installed-tool execution was performed.

The preserved network transceiver bank evidenced here is 9A, containing all three QSFP-DDs, not three separate banks needing guessed clocks. PCIe bank10A is distinct and must remain unchanged. Do not copy commented CPRI clocks or DDR/SYS_REFCLK frequencies into BTI. Leave seven-output/core470 clocks, P-Tile, all DDR mappings untouched.

## Provenance and boundaries
Archive member top_loc.tcl SHA256: 410d418a34c19a04ab575fc8b5fdb4215361564c9d8d5da99a5ec45285257b4d
Archive member top.sv SHA256: a01d9caaa644c5f60e029b7e3382237b080be8e0e9eb2e7b5dd7fe788692da50
Archive member eth_top.sdc SHA256: 272e4cc54df9e4becf52c9c3213786af92e803439723f5a8e02efec475442a8e
Vendor pin report SHA256: e6772aa71802400adcc73d90789167d8cbb841132f16a5b501b7d3646c4f41a7
Vendor fit report SHA256: ba2a3c0239359605e661afe20fd6b97bfc66aac612e49330935b789016dcb1ec
Additional hashes and exact excerpts are in JSON evidence. Host identity checked Agilex7Workstation UID1000. All remote operations were inside owned tmux session ia840f_mailbox_monitored_01. Only qualification/fim-bti-clock-01 evidence was written; no build/source edits, SDK hardware invocation, programmer, clock changes, process restarts or simulations.
