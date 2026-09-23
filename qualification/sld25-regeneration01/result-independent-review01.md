# Independent result review: Work20 failure and native 25.1 scjio regeneration

## Verdict

**ACCEPT the Work20 evidence as a failed elaboration, and independently ACCEPT the native 25.1 regenerated scjio leaf as suitable for integration into a fresh offline FIM comparison. No blocking defect was found in this bounded regeneration result.**

This is acceptance of captured native results, not a new source-approval framework, execution authorization, or gate-status transition. It does not accept full-FIM elaboration, fitting, timing, debug operation, PR, or hardware behavior. A hardware test is not a prerequisite to the next offline compile.

## Evidence integrity

All checks below were local-only; no SSH, vendor execution, hardware access, installed-library edit, or git write was performed.

- Recomputed all **39** entries in `result-review-freeze01.json`: zero mismatches. Manifest SHA256: `be052fa6b32eefce27aac669f2e89f153dd3c93ca26ca6bc2b1f7354ab2cf68a`.
- Verified `../fim-build-20/elab-failure02.json.gz` against the supplied SHA256 and checked all **19** embedded files against their declared hashes/sizes and matching `failure-readback02` bytes: zero mismatches.
- Verified all **18** embedded input captures against their declared hashes and `captured/` bytes, and all **14** generated files against declared hashes/sizes and `generated01/` bytes: zero mismatches.
- Recomputed the native generation log hash from the captured log text; it matches the recorded hash. Independently recomputed every QIP file edge and reconciled it with `parent-observations01.json`.

| Evidence | SHA256 |
|---|---|
| Work20 `elab-failure02.json.gz` | `7687eae362b6d990bb3c6bd4cdccfa4e24a95752615fbe007481ada453608040` |
| `inputs01.json.gz` | `6931fcd79ff6b3173b6ead4af5d230534f4811d6e643e98fd26aad5adcccd8d4` |
| `generation01.json.gz` | `c3e4b9ac9dbed00008264bd96077f1a205b6dd197308819905d87093ee0d5ae4` |
| Native generation log, within that record | `bf7a33889303fca61e9148a775867acef4b87b40b3141c35f1e7da3ccc033b08` |
| Saved/copied/source `scjio_agilex.ip` | `e2ec4b3fdd48e0ee2f76cdd16c6becd3fb6e19a53b9fd3668af591d98be7a1d3` |
| New `scjio_agilex.qip` | `b24c7efaabe6807dc9dff51a16dc1190581625240f973fdc5eebd8d28cf4c7b2` |

Hashes establish the captured bytes, not a new live-workstation inventory.

## Work20: actual failure accepted, not a successful build

The captured `run/native-status.json` records native return code **1**, ending `2026-09-23T04:56:12.577214+00:00`. `ofs_top.flow.rpt` identifies Quartus **25.1.0 Build 129** and **Synthesis Failed**. This agrees with `CURRENT.md`; there is no fit/STA result to accept.

The preserved `run/native.log` (SHA256 `54368a1c5218719477cb30852e02df329b14941f5524e11d4b48a15dc984c509`, 2085434 bytes) establishes:

- Lines 168–169: the inherited scjio synthesis output was found and **generation was skipped**. The successful IP-generation stage did not rebuild this leaf for 25.1.
- Lines 300 and 310–324: IP generation and the post-IP Tcl callback completed with zero errors/zero warnings. No `125091`, `_hashlib`, or `OPENSSL_3` failure occurs in the captured log. The observed failure is not a recurrence of the earlier Python-environment problem; this does not qualify unexecuted later callbacks.
- Line 6296: **Error (13907)**, `CLTAP_CONNECTION` has no corresponding generic in `/opt/altera/25.1/quartus/libraries/megafunctions/altera_sld_host_endpoint.vhd(122)`. Subsequent errors report elaboration/synthesis/flow failure. The full shell summary retains five warnings; the earlier zero-warning stage summaries are not a claim that the whole run was warning-free.

The captured old generated top/child identify **26.1.1 Build 130**. Their endpoint wrapper forwards `CLTAP_CONNECTION` even when its value is zero. The captured 25.1 VHDL entity, lines 122–135, has no such generic; the 26.1.1 declaration does. This directly supports a generated-leaf/library-version mismatch. `gate_rejection=true` in the outer status must not be mistaken for proof that the Python callback failed again.

## Regeneration: actual native result and target

`generation01.json.gz` records native **rc0**, with matching start/end metadata and this invocation in fresh `work_sld25_regeneration01`:

```text
/opt/altera/25.1/quartus/sopc_builder/bin/qsys-generate /home/uwb_student00/ahls/new_BSP/work_sld25_regeneration01/scjio_agilex.ip --synthesis=VERILOG --part=AGFB027R25A2E2V --parallel=off
```

The captured installed help supports these options. The native log and `scjio_agilex_generation.rpt:1–11` identify **25.1 build 129**, the explicit target, successful completion, and **3 modules / 3 HDL files**. The sole generation warning is the missing Quartus project, consistent with intentional standalone generation. There are no reported generation errors.

The saved IP still contains donor `AGFB014R24A2E2V`; it was not silently rewritten. However, the native invocation/report and evaluated generated XML (`scjio_agilex.xml:80–89,116–127`) identify **AGFB027R25A2E2V**, also present in the SOPCINFO. The XML perimeter default retains the donor part; do not misread that default as the evaluated generation target. Source/Work20 input captures and the generated saved IP are byte-identical, and the native result explicitly records both original-IP and copied-IP preservation.

## Interface, settings, and 25.1 implementation support

Compared the complete old/new synthesis top and composed child, not only the port names.

- All five scalar top ports and directions match: inputs `jtag_clock_clk`, `jtag_signals_tms`, `jtag_signals_tdi`, `jtag_signals_tck_ena`; output `jtag_signals_tdo`. Top `CONTROL="host"` and the named configuration `soft_jtag`, priority `200`, TCK enable `1`, clock-rate metadata `0` remain unchanged. Zero clock-rate metadata is not timing qualification.
- **Top CONTROL versus endpoint CONTROL:** both old and new children instantiate the actual endpoint with `CONTROL="hubctrl"`. This is intentional composition, not a host-to-hubctrl regression. The captured 25.1 `intel_soft_core_jtag_io_hw.tcl:67–85` explicitly selects it and forwards name, priority, and TCK enable. Its declared priority default is 200, above the documented hard-JTAG default 100 (`:47–56`).
- The new top no longer forwards `NEGEDGE_TDO_LATCH`, but the new composed child still explicitly supplies **0** to the endpoint (`..._nlyl3tq.v:75–85`). The 25.1 endpoint Tcl (`:105–108`), wrapper (`:33–42,54–64`), and VHDL (`:125–134,182–187`) all support and retain that setting. The soft-JTAG catalog describes positive-edge TDO launch (`intel_soft_core_jtag_io_hw.tcl:20`). The omitted top-level forwarding is therefore not evidence that negative-edge latching became enabled.
- `CLTAP_CONNECTION` is absent from the regenerated HDL and the relevant 25.1 catalog/primitive interface. The old selected value was 0. This is a native older-release composition, **not** an operator deletion of a generic or proof of bit-for-bit equivalence with a newer implementation. It would be incorrect to invent a 25.1 CLTAP generic/default that does not exist.
- The child also changes `TYPE_NAME` and `INSTANCE_NAME` from string `"0"` to integer `0`, matching the captured 25.1 VHDL **natural** declarations rather than the newer string declarations. This is another reason to use the coherent native leaf rather than patching only the failing CLTAP line.
- All ten generics forwarded by the new endpoint wrapper match the 25.1 entity's declared generic names. Its wrapper bytes exactly match the captured installed 25.1 wrapper, SHA256 `8931c77addaaa6c9ecc009239e85c5b13323d283fc826c4c23f89ccc79eb3cf2`.
- JTAG clock/TMS/TDI/TDO/TCK-enable wiring is retained; `ena`, `vir_tdi`, and `select_this` remain tied low. The bridge catalog's driven-by connections and conditional TCK-enable export (`altera_sld_host_endpoint_bridge_hw.tcl:88–108,127–130`) support the generated direct connections. Debug was not removed as a workaround.

These checks support the intended interface/configuration and native compatibility correction. The VHDL itself says synthesis connects the fabric endpoint to the actual implementation (`:114–116`); inspecting it is not a substitute for completed synthesis or debug hardware validation.

## QIP closure and fresh-comparison disposition

Parsed **every `*_FILE` assignment** in the new QIP, rejecting unknown path-expression forms. All **six** file edges exist and hash-match the parent closure: SOPCINFO, CMP, saved IP, and these three HDL files:

| QIP line | Dependency | SHA256 |
|---|---|---|
| 38 | `altera_sld_host_endpoint_10/synth/altera_sld_host_endpoint_wrapper.sv` | `8931c77addaaa6c9ecc009239e85c5b13323d283fc826c4c23f89ccc79eb3cf2` |
| 39 | `intel_soft_core_jtag_io_10/synth/scjio_agilex_intel_soft_core_jtag_io_10_nlyl3tq.v` | `ea4072adf035adc6d1c559803031a6419c61ae9e10de4ad57e966fc882d75e75` |
| 40 | `synth/scjio_agilex.v` | `9fb4d784965b3fa040a87fb05b09a3dde28d6a465d941b6f520a8e25f8cce296` |

The QIP identifies version 25.1, Agilex 7, standalone, and synthesis-only. All six paths are relative to the QIP location; no missing QIP-declared dependency or unknown file-expression edge was found. This is generated-file closure, not an assertion that Quartus's built-in primitive implementation is self-contained in these three files.

**Next justified step:** integrate the complete coherent regenerated synthesis leaf/QIP into a **fresh** FIM worktree, retaining the saved IP and explicit target context; avoid mixing the new top with the old child/wrapper or selecting stale simulation HDL. Preserve Work20 and the native generation evidence. Parent-owned normal exact-delta/preflight checks remain applicable; this review adds no extra review or hardware-test prerequisite.

**Comparison classification:** a 25.1 FIM compile with a narrowly regenerated debug compatibility leaf, not a byte-identical full-FIM RTL experiment. The separate EMIF generated-byte/configuration comparison can remain intact if the successor preserves those inputs and its QSF/SDC as intended. This leaf package does not independently inventory the entire EMIF/FIM tree. Enumerate the debug-leaf delta in the eventual timing comparison rather than hiding it or claiming that it changes EMIF behavior.

**Precise blocker:** none to integrating this leaf for the next offline compile. Full-FIM success, timing/hold closure, debug function, and PR/hardware acceptance remain unestablished; any subsequent native failure must be retained and diagnosed on its own evidence. No gate flags or existing qualification records were changed by this review.
