# Work24 independent physical-result review42

## Verdict — ACCEPT WITH FINDINGS; advance offline preparation

**Accept completed Fitter, reported multi-corner numerical timing, and assembly for fresh matching PR/PIM export and persona preparation. No actual physical-result blocker to that next offline step was found.** This is not clean Design Closure, electrical/PR/reset-protocol acceptance, deployment approval, or migration completion. The scalar `qual_vec_op` shell is not CAPS03 and exercises no DDR traffic.

Reviewer: **gpt-6-astra-900k / openai-codex**, disclosed substitute for unavailable GLM5.3. Local immutable captures and in-memory parsing/hashing only; no native/source/test execution, SSH, hardware, implementation or Git mutation. Only this report is written.

## Evidence and completed execution

References are relative to this directory. **F/T/TS/D** mean `timing32-readback/output_files/ofs_top.{fit.rpt,sta.rpt,sta.summary,tq.drc.signoff.rpt}`. **N/C** mean `completion34-readback/qualification/fim-build-24/operations/compile/{native.log,status.json}`; **A** is the assembler report beneath `completion34-readback/work_ia840f_fim_24/syn/board/ia840f/syn_top/output_files/`.

Independently verified **41/41** sizes/SHA256s in [freeze41](physical-result-freeze41.json), both raw archive/receipt bindings, and **9 timing + 11 completion decoded members** against readbacks. Completion metadata38 is an exact payload-free projection; comparison Work23's **36/36** frozen members also verify. Fresh preservation39's producer/receipt/archive agree: **1,891 SOURCE/PIM entries, 3,963 Work23 inputs, four images/intermediates and static QDB** preserved. This is named-domain preservation, not whole-tree proof.

C records completed **native/CMake/effective 0/0/0**, no timeout/rejection/residual group, `postflight_errors=[]`; completion-event07 records **outer0**. All **15** gate events accept; completion capture reports no active vendor process or hardware access. Fitter/Assembler/full-flow success is native (`F:43250`; `A:170`; `N:11213`). Metadata's inherited phrase “timing failure remains separate” is not a native timing verdict: **T:2775–2787 now passes timing and DDR**, while overall Design Closure remains FAIL for high-severity Design Assistant/unconstrained findings.

## Actual physical consumption

`F:31392–31409` resolves the **exact candidate QSF:142 source**, `core_clks_from_cpa_pri_nonabphy[0]`, to **spine1→2**, unchanged `TILECTRL_X172_Y0_N298`, **root_partition**, full **SX0 SY0 SX6 SY7 / 56 sectors** and static/PR consumers. All **44** final allocation blocks match Place capture26; names pair exactly with Work23. **32** spines change; DDR0 reference-clock region shrinks **2→1 sectors**. Reset-anchor sites move **FF_X280_Y4_N46→FF_X280_Y4_N16** (EMIF0) and **FF_X171_Y4_N34→FF_X171_Y4_N46** (EMIF1), independently confirming [allocation27](clock-allocation-comparison27.json). This is not unchanged routing.

Actual **seed3**, **AGFB027R25A2E2V**, **26.1.1 Build130**, effort and snapshots remain (`F:130–208`). Final QSF equals candidate bytes. All **44 bound source SDCs plus selected QSF** match completed-input hashes. The entire **1,085-row Ignored Assignments** panel equals Work23; neither new clock assignment is ignored. Original green-region/chip geometry and complete input/output/bidirectional/package-pin tables are unchanged (`F:255–1348,2495–6630,38909–38914`). Nine native fit-only **10ps applied** markers and STA's **skip/signoff_unchanged** marker preserve separation; no applied marker occurs in STA (`F:42876,43106–43240`; `T:214046`).

## Timing and coverage

All **788 Type blocks** were retained: **18 setup, 18 hold, 11 recovery, 11 removal, 74 MPW, 510 skew, 146 net-delay**. Their full Type multiset matches Work23; **zero negative records**, all present TNS values zero. All 132 conventional records agree with native summaries; remaining 656 slacks agree with native skew/net-delay tables. Missing Corner/TNS fields were not invented. Seven changed worst-corner labels are not lost checks.

Global minima, ns: **setup .166; hold .000; recovery .232; removal .109; MPW .000; net-delay 1.012**. **Displayed zero is not strictly positive physical margin.** Bank0 recovery/removal is **1.272/.175**, bank1 **1.264/.109**, not historical/global substitutes.

The exact bit243→EMIF1 `lane_inst~phy_reg1` transfer retains its launch/capture clocks, zero hold relationship and **No SDC Exception on Path**:

| Corner | Hold ns | T path start |
|---|---:|---:|
| Slow vid2 100C | +.242 | 21017 |
| Slow vid2b 100C | +.272 | 51450 |
| Fast vid2a 0C | +.118 | 81879 |
| Fast vid2a 100C | +.086 | 112299 |
| Fast vid2 100C | +.082 | 142714 |

Independently corroborated exact-transfer36/comparison40; the sixth occurrence is the aggregate repeat. The formerly −.004 path now passes, but launch remains **X192/Y3 Hyper-Register**. No claim of causal compensation equation, tool defect, or retiming-OFF removing that register follows.

All **81 clock rows** are unchanged. Both EMIF core/PHY-l pairs retain **3.000ns**. System PLL remains **1410MHz VCO**, seven outputs **470/100.714286/235/705/50.357143/117.5/352.5MHz** (`F:6638–6706`). Selected four-line PCIe divider remains **19.858ns**, divide-by2 from `sys_pll|iopll_0_clk_100m`; setup/hold **17.777/.048ns** (`T:2754`, TS). This is fitted analysis, not measured runtime frequency.

All **146 net-delay identities** and **102 skew identities/corner** persist, with no invalid-clock rows; new net-delay worst is **PCIe TX-request CDC**, not Work23's control-shadow FIFO (`T:3581`). **110 SDC-load rows** remain OK; their identities/statuses agree after exact WORK-root pairing, excluding timestamps/duration. Setup/hold/recovery/removal transfer tables preserve **108/108/35/35** pair/classification-row multisets; changed edge counts are confined to intra-clock rows. Retained **seven Asynchronous (Timed Unsafe)** rows per setup/hold and ignored rows are not CDC clearance. Matrix equality is not exhaustive endpoint proof.

## Retained findings and corrected accounting

- **Constraints:** unchanged **117 ignored/overridden + 59 empty-filter** rows, including four fully overridden PCIe multicycles and unmatched `mem_ss_inst`. Two user/system-PLL `m_cnt_clk` MPW checks remain absent despite clock presence; their missing-check explanation/readback is still unavailable, not fabricated. The tiny SDC-constraints report only lists debug-QIP source records.
- **DRC/reset:** **23/88 failed; 4,384 overlapping violations; zero waived; ten disabled rules**. Versus Work23: CDC-50001 **14→13**, FLP-40006 **15→16**, TMC-20604 **3→7**. Reset-load totals are **1,838 asynchronous / 109 synchronous / 58 enable**; additional reset cycles change user outclk1 **6→5**, oscillator **0→2** (`D:123–214,4865–4869`; `F:39800–39889`). Positive recovery/removal does not qualify reset sequencing.
- **PR/electrical/integration:** all **1,077 dangling inputs** persist, including `pr_freeze_to_afu`; Critical20727 remains. Three BMC electrical-warning pins and **SYS_REFCLK missing explicit input termination** remain (`F:6997–7000`). Carry consumed synthesis18/23: Critical19854, six synthesized DRC failures, unused shadow-export defect, PIM typing and PR initialization/freeze findings—not reopened vendor-internal qualification.
- **Unconstrained:** reserved TDI/TMS/TDO and BMC IRQ retain **78 input/10 output pairs per setup/hold** (`T:214913–215047`). The goal explicitly retains this/reset-lint/overlap posture; it is neither clean coverage nor a newly invented preparation blocker.
- **Warnings reconciled:** F's **207 ordinary + one critical** messages omit pre-banner **Warning20031 at N:8343**; including it gives footer **209**. Main signoff STA has **189**, not RESULT41's188; **188 belongs to the separate PR-SDC export hook** (`N:10464–10469,10937`). Full-flow **894 = 495 synthesis + 209 fitter + 189 STA + 1 assembly**; adding the separate hook explains raw1082. Coalesced tables are not extra occurrences. Assembly's retained warning is legacy GENERATE_RBF_FILE20536.

## Advance boundary

New interface **fc603c44-5c8f-5e94-bcbe-a5780030947c** agrees across text/build metadata/MIF. Captured, unprogrammed SOF: **7,836,539 bytes**, SHA256 **16812c62675e31bb7d3bdbdce80e9342c32bb7263c6a862611da427249c85195**. Matching static QDB SHA256: **dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4** ([captured metadata](completion-metadata38.json)).

Proceed with a **fresh export bound to this static QDB/interface**, then matching PIM/persona preparation and its independent synthesis/fit/STA acceptance. Do not reuse an old UUID's persona or infer CAPS03/DDR functionality. Electrical behavior, active PR/freeze/reset protocol, RTL simulation and migrated card/DDR gates remain later acceptance boundaries under `GOAL-PROMPT-MIGRATION.md`, not claims supplied by this result. No further unchanged fit, waiver, vendor-help prerequisite or hardware action is justified here.
