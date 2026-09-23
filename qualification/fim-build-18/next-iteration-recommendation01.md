# Work18: diagnose the forced UFI boundary, not another unchanged fit

**Recommendation:** one bounded native assignment/source-classification readback for the exact launch and its downstream UFI. No corrective assignment is sufficiently supported yet. This is not launch approval.

## Actual result and causal limit

Work18 retains `ALLOW_REGISTER_RETIMING OFF` on the literal bit243 launch (Q:136), while global retiming remains ON (Q:30; F:186). The final path still uses `BLOCK_INPUT_MUX_PASSTHROUGH_X192_Y3_N0_I32` → `UFI_X210_Y0_N355` → `IO12LANE_X184_Y0_N374`: arrival/required 2.964/2.968ns, hold −0.004ns, data delay 0.288ns, uncertainty 0.030ns, no SDC exception (T:126779–126895). The summary and five detailed blocks are unchanged from Work17 (O:29–113). Work17 already established this failure after routing (R:7–9); repeating routed/final STA answers no new question.

**Newly bound explanation, not proven precedence:** the generated `c2p_350_ufi` branch explicitly applies `FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER ON` and `HYPER_REGISTER_DELAY_CHAIN 350` to its `tennm_ufi`, not to bit243 (U:58–68). U's bytes match the Work18 `work18_inputs` entry in I. The actual failing path traverses this named branch (T:126854–126856). A vendor-directed core/periphery Hyper-Register placement is therefore a stronger concrete hypothesis than ordinary late retiming. Neither the literal 350 nor the branch name proves 350ps physical delay or a legal alternative value.

The installed description of `ALLOW_REGISTER_RETIMING` promises control over moving combinational logic across register boundaries, **not forced ALM placement** (A:3–6). A:7–12 establishes family/instance support and a singleton post-synthesis lookup, not QSF target consumption. Q's braces prevent Tcl command substitution; that does not prove Quartus assignment-pattern resolution. F's Ignored Assignments panel (40616–41705) names neither bit243 nor this exact UFI. Absence there proves neither acceptance nor precedence. The captured Agilex7 assignment-name list N excludes both UFI controls; do not turn vendor HDL attributes into presumed public QSF knobs.

## Exact finite next question

**Did the OFF assignment resolve to the intended register, and does forced core→periphery implementation operate independently of that restriction?** Restrict the record to:

- Launch: the complete `From Node` in T:126786, identical to Q:136.
- UFI: the complete element in T:126854, without its terminal `|d`.
- Properties: `ALLOW_REGISTER_RETIMING`, `FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER`, `HYPER_REGISTER_DELAY_CHAIN` only.

Parent-only next action: collect the existing Work18 synthesis attribute rows for these objects and perform one installed-26.1.1 native help/assignment readback on an independent copy, without synthesis/fitting. Obtain the two UFI controls' descriptions with documented `get_assignment_name_info` (H:24–61). For target binding/precedence, require a documented resolved-node/consumed-attribute query or native report, including entity/source and literal matched name. **No effective-assignment API is established by the present captures**; help must establish it before use. A saved-QSF echo, generic metadata, or another `get_registers` singleton is not that evidence. If unavailable, return that precise limitation and stop this diagnostic—no new callback, mock framework or unchanged fit.

**Discriminator:** an explicit unmatched/overridden OFF justifies only its documented singleton targeting/precedence correction. Resolved OFF plus a documented forced-boundary exemption retires the one-register-retiming remedy; only an explicitly supported, Agilex7-applicable board-level control could justify a different fit. Do not disable the vendor force attribute or edit PHY RTL on inference. If neither is established, report “consumption/interaction unresolved,” not “retiming disproved” or “unfixable.”

Any subsequent corrected Quartus trial retains the original signoff, existing Fitter-only 10ps margin (D:151–165), global retiming and effort settings; require changed implementation and all-corner nonnegative hold without setup regression. No margin escalation, seed sweep, same-edge forcing, waiver, or invented passing legacy baseline. No remote/vendor execution, tests, hardware or Git occurred here; the frozen inputs remain unchanged.

## Citation identities

Paths relative to `qualification/`; SHA256 is full-file unless stated.

- T `fim-build-18/reports01/output_files/ofs_top.sta.rpt`: `ca2ed19589bc01e6bfac1028bd3a0cbdd50a6f0f801677cdce58ab7d42bc5020`
- F `fim-build-18/reports01/output_files/ofs_top.fit.rpt`: `86e89e3afebccd31841a274f41f923dc9ef3db2b58d5fdc807c5ca1caa54eddf`
- Q `fim-build-18/completion-readback01/project/ofs_top.qsf`: `e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f`
- O `fim-build-18/parent-observations01.json`: `0dee60b487d526d6e4a1afc42bbe301fa8a92d1d93099e1828f4b6b0182efb7d`
- I `fim-build-18/postflight-inputs01.json.gz`: `6f88366d02f19fa74a75400cd3e1bfefdab60bb0462ab265706965a07ecc15b4`
- U `msa-bank-spreading-integration-01/generation-execution-03/actual-results/work/mem_ss/mem_ss_mem_ss_501_qm5zaka/synth/ip/mem_ss_mem_ss_501_qm5zaka/mem_ss_mem_ss_501_qm5zaka_emif_1/altera_emif_arch_fm_191/synth/altera_emif_arch_fm_ufi_wrapper.sv`: `b7103541c487da1da41163db3fc1cfe9bf049af2aa5d031dce5bd923379c2755`
- A `fim-build-17/retiming-eligibility01/result-readback01/reports/audit.tcllist`: `ca556763f0b7d9491c606c20c43e3d7501f48022512fa96ce14a254e5f34eca4`
- R `fim-build-17/snapshot-compare01/RESULT-ACCEPTANCE.md`: `0152788a4f37a4347364a69ede520942f6bfda491cd5bf0edf07463574ef91fa`
- N `router-native-capability-01/remote-evidence/agilex7-assignment-names.txt`: `e4e317f026077f28e11dbac58199a602281e549d0181dcc3c81b647c59439b09`
- H `router-native-capability-01/remote-evidence/metadata.log`: `a53dadf7e96241bc8b6766b59bf939dc813092a22d5152b5b29e63432f9820af`
- D `fim-build-18/top.sdc`: `3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814`
