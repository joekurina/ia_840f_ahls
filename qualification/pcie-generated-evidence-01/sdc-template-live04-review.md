# PCIe SDC template: first source disposition

`ready_for_build=false`. No vendor/Tcl execution, regeneration or source change.

## Capture

One explicitly selected installed file was read through existing `ia840f_migration_preflight` pane `%4` after rereading workstation instructions. Scope and command are retained in `capture-sdc-live04-{scope.json,command.txt}`. The separate metadata diagnostic was not executed or authorized by this capture.

`pcie-sdc-template-live04.json` is 62615 bytes, SHA256 `6e83ce744bec0f73ea6ae9aca68c61f6894a1c9153f1304683858ff209219750`. Its one payload is the literally referenced `/opt/altera/26.1.1/ip/altera/subsystems/intel_pcie_ss_axi/rtl/pcie_ss.sdc.terp`: 60544 bytes, SHA256 `d70c290cf64fffb61b4dd4b3a590ebc72dc301a2cdc43c849c4e8c808b822a7a`. Container and payload hashes/length were checked locally. Capture errors are empty. Remote exclusive evidence output was reread by the collector; original installed file was unchanged.

## What the template proves

All citations are decoded payload lines, not JSON lines.

- Lines 89–94 copy the source-frequency settings and derive `CORE_16_LITE_CLK_PERIOD` using `1000.0 / core16_lite_clk_freq`, formatted to three decimals.
- Lines 161–164 conditionally create `p0_axi_lite_clk` using that period. This is **not an unconditional overriding clock definition**: it requires `pcie_port_existence p*_axi_lite_clk` and an exact target-list lookup result of -1.
- The port-existence helper at lines 23–41 uses `get_ports`; the clock-target helper at lines 63–80 collects targets of defined clocks. The lookup uses `lsearch -exact` with the literal wildcard-containing string. Do not describe it as a proven comprehensive duplicate-clock guard without actual timing-tool collection semantics and objects.
- Lines 187–229 contain additional conditional P/F-Tile divided AVMM clock creation and clock-group declarations. These depend on port presence and endpoint-mode branches; their actual hierarchy/targets are not resolved by reading the template.
- All occurrences of `LITE_CLK_PERIOD` in this payload are its definitions and the conditional `create_clock` calls at lines 164/166/169/170. The template therefore establishes an actual timing-definition use for the integer setting, rather than just a generic metadata parameter.

## Decision

The template alone does not establish whether the clock-creation branch runs when this subsystem is embedded in the IA840F FIM, whether a conflicting clock is created, or whether actual PLL clocks remain authoritative. It is not a rendered Work03 SDC or TimeQuest result. Do not retune the PLL, insert a fractional PCIe parameter, change constraints or claim timing failure/pass from this source.

Next: discover actual synthesis manifest and rendered SDC names within the two already observed generated-IP roots under the separately recorded bounded scope; inspect their literal dependencies and source binding before any timing claim. The complete BMC generation failure and pending generated headers remain unchanged.
