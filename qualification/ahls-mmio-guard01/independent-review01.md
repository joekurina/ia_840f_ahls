# Independent review: full-address MMIO guard

Status: FINAL

Verdict: **PASS — bounded connected-simulation qualification. No in-scope blocking defect found.** The final guard closes the demonstrated high-address alias at the simulated full-20-bit AXI-Lite admission boundary and retains readable fault telemetry. This is not acceptance of real-PIM top integration, Quartus A&E/synthesis/fit/STA, PCIe/OPAE operation, physical DDR, recovery, or a hardware release. Two nonblocking fixture-coverage findings are recorded below; neither requires rerunning this unchanged package.

## Scope and identity

Review order was specification, RTL, fixture, then retained evidence. This report was first written `IN_PROGRESS` and then finalized. All review operations were local static reads, AST/literal decoding, byte comparisons, hashing, and log parsing. No runner was imported or executed. No vendor/simulator/native qualification command, SSH, hardware access, source edit, git operation, or task transition was performed. This report is the sole authored file.

Paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`:

- `G` = `qualification/ahls-mmio-guard01`.
- `RTL` = `afu/ahls_memory/control/ia840f_ahls_mmio_guard02.sv`.
- `TB` = `afu/ahls_memory/control/ahls_mmio_guard02_tb.sv`.
- `I` = `G/inputs-green03` (the actual final input snapshot).

Verified frozen package: `G/review-package01.json`, SHA256 `0c6fb1be9c44df32114e0a039bf647dd09af9c6a6d9c02b651c82b84983c5195`; all **30** listed files match their byte counts and hashes.

Final identities:

| Artifact | SHA256 |
|---|---|
| Final RTL | `25512e0c4a697fa897e1ff472258eab2430dd157efd0bd94462a4a8a0824d627` |
| Final TB | `de0965b6e7da9f2f2e74faea4fcafed3b703e701492e401963171229919ce413` |
| `G/source-binding01.json` | `716734a6e32fdeed546cfc0ed1de4c57ddfc61b39c178b8a6faa9a7e8db499d9` |
| `G/result-green03.json` | `ac9f57a86cc4a8cca52a1db69b6290c0ffcb3cf914367754ac1501c15326ace0` |

The final source still declares `ia840f_ahls_mmio_guard`; the final TB still declares `ahls_mmio_guard_tb`. The unsuffixed source/test files are preserved earlier candidates, not additional active implementations. The final compile list contains one selected guard and one selected test under their copied input names.

Accepted predecessor findings remain accepted, not reopened: numerical milestone commit `3594bb42ca062c754ce68e7c0ca987069bfb30b1`, report `d5de4e1dc031bbb15e72c3c3f5e6ebee401a286a98f390f20c6212fd3583e733`; page-safe PIM02 commit `77c64e122c9c03783a428a7b31bcb3f122f5ac6b`, report `c2dded6f3eb2f1531ca556fd9a94863fdf2a7e1124a00ed003b21dd5220be04d`. Their reuse is not evidence that the new guard has already passed those integration stages.

## 1. Specification review

`G/SCOPE.md:3–11` and `G/RESULTS03.md:18–34,48–56` define a coherent narrow contract:

- Forward only DMA/identity `[0,0x10000)` and kernel `[0x10000,0x10100)`. Admit only aligned 64-bit transfers, with full write strobes. The contiguous outer allow-list is not a promise that every address/register/value inside it is legal: the real DMA CSR still supplies its own register/value responses, and kernel value/lifecycle validation is expressly absent.
- Four read-only diagnostics occupy `0x20000/08/10/18`: `MMIOGRD1`, read/write saturating 32-bit counters, first write fault, first read fault. Fault fields are valid bit 63, response 33:32, reason 27:24, full address 19:0, with remaining bits zero. Reads are nondestructive; only reset clears state.
- Independently captured AW/W, serialized operations, and write-before-read admission apply only to requests presented at this interface. They do not establish PCIe arrival order, a software fence, global drain, lifecycle enforcement, or reset safety. A missing complementary write channel or withheld response/READY can block progress; fairness and universal liveness are not promised.
- Readable telemetry is a justified addition rather than reliance on CPU-visible BRESP. The retained PIM source `I/rtl/platform/ofs_plat_if/rtl/ifc_classes/host_chan/ofs_plat_host_chan_map_as_axi_mem_if.sv:126–128` explicitly ignores MMIO write responses and holds BREADY high. That mapper is **not** exercised by this test.

All register addresses in this review are simulated AFU-relative ABI addresses, not live probing authority. Restricting this candidate to 64-bit accesses is explicit, not general qualification of 32-bit MMIO or arbitrary AXI traffic.

## 2. Active RTL review

**Admission and side effects — conforming.** `RTL:10–16` rejects unsupported address/data/ID/USER geometry. `RTL:35–53` classifies the complete 20-bit address without a low-bit projection. The union of the two forward apertures is correctly expressed by `< 20'h10100`. Diagnostics are confined to `[0x20000,0x20020)` and then alignment leaves exactly four readable words. Address rejection precedes format rejection; aligned full-width diagnostic writes receive reason 3/SLVERR, while local address/format faults receive DECERR. `RTL:114–116,130–135` routes rejects and diagnostics straight to reply, never to downstream send states; downstream AW/W/AR VALID is asserted only in send states (`86–90`). No local rejected write data is forwarded ahead of its admission decision.

**Capture, ordering, and response ownership — conforming for compliant peers.** AW and W have separate full-payload buffers and occupancy flags (`21–29,106–112`); both are required before classification. Each downstream write channel stops asserting VALID after its own handshake, and the FSM waits for both before accepting B (`118–126`). There is no dependence on a changing upstream payload after acceptance. Read request/response storage is similarly retained (`130–142`). Source B/R payloads and VALID remain held in reply states until READY. Source reads cannot be admitted with either write channel already buffered, either new write VALID presented, or any prior write still awaiting B retirement (`79–82,127`). A read already in progress blocks new write capture. These state conditions prevent concurrent read/write fault updates and stale diagnostic snapshots relative to an already-presented completed write; they do not order traffic not yet at the interface.

**IDs and USER — consistent with the selected OFS interface.** Local B responses echo captured AW ID/USER, not W USER; local R responses echo AR ID/USER. Forwarded responses retain downstream ID/USER (`94–96,107–108,124,131,140`). This agrees with the address-channel USER convention in `I/rtl/platform/ofs_plat_if/rtl/base_ifcs/axi/ofs_plat_axi_mem_lite_if.sv:69–76,109–145`. The guard does not detect a malicious or malformed downstream response ID; it is not a response-protocol firewall. Directed tests use IDs `0x31/0x52` and USER 1, not an exhaustive ID-space test.

**Telemetry — conforming.** Local write faults count once at classification, local read faults at AR acceptance, and forwarded faults once when the guard consumes the non-OKAY downstream response (`71–74,144–155`). The corresponding state transition removes the event condition on the next cycle; source response stalls therefore do not repeatedly increment counters. The retained original address is used for downstream faults. Counter saturation, first-valid protection, reserved-zero construction, and synchronous reset clearing are visible in `54–68,99–104,144–155`. Diagnostic sampling is inside the clocked read-acceptance branch; its references to telemetry registers are not the earlier continuously evaluated zero-argument classifier defect.

The guard uses the upstream clock/reset and does not drive the downstream clock/reset. The fixture correctly supplies the same clock/reset (`TB:18,38`). Real-top integration must preserve that domain relationship and the exact supported geometry rather than treating this module as a CDC adapter.

## 3. Fixture review and actionable findings

**Connected, not a kernel substitute.** `TB:14–89` places the guard immediately before the flat generated core MMIO ports. The MMIO interfaces are genuinely AXI-Lite; flat-core LEN is explicitly zero, BURST is INCR, and RLAST is unused because the upstream interface has none. Actual generated kernel/DMA/fabric and real bank shims remain connected; only host/bank storage endpoints are byte-memory models (`32–50`).

Read-only comparison with the accepted `run-path08.py` literal payloads found **528 predecessor inputs**, no removals, one added guard, and only the test changed among common inputs. The memory model is byte-identical. The `dma_copy`/arithmetic/copyback region differs only in two case-marker strings and whitespace; the numerical oracle, endpoints, and drain observation are not weakened.

**The pointer-canary correction is justified.** `TB:21–24,418,430` observes `{arguments_1_buffered_q,arguments_0_buffered_q}` without a force, drive, or internal-state assignment. The captured CRA read mux returns status rather than argument values (`I/generated/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/mmhost_ia840f_report_di_10/synth/DDRIP_function_cra_agent.sv:548–587`); its buffered-register updates are at `838–871`. This also agrees with `qualification/ahls-memory-abi01/ABI-SOURCE-REVIEW01.md:85`. The delta replaces only the two unsupported pointer-readback checks with that observation. Real MMIO programming, rejected-AW checks, the DMA MMIO pointer canary, and numerical checks remain. This white-box observation is not advertised as a hardware readback API.

**Directed stimulus is credible.** Payloads are initialized before VALID, driving occurs at negedges and handshakes are sampled at posedges; both AW-first and W-first paths are exercised (`229–272,353–409`). The forked overlap drives disjoint read/write channels and joins before the shared read variable is reused (`447–454`). The canary/forwarding comparisons occur after task completion, not at the forwarding counter's posedge update. No blocking false-pass race was found in these checks.

The negative campaign distinguishes local rejection from actual downstream CSR rejection (`410–458`): aliases, size, strobes, alignment, RO write, unknown DMA register `0x128`, and zero length `0x38`. Exact counters include downstream errors. First write/read records are checked for the initial address/reason/response and stickiness across subsequent negative traffic. Four positive cases then verify no further fault-count increments (`467–471`).

### F1 — Low, nonblocking: response-hold coverage does not detect VALID gaps

`TB:367–370,395–398` compares retained payloads only on cycles where BVALID/RVALID is asserted. A response that incorrectly drops VALID during backpressure and later reasserts the same payload can evade that check and still complete before the deadline. The included OFS checker checks initialization, not this temporal hold property. The current RTL's reply-state logic does hold VALID correctly, so this is a coverage weakness, not an observed DUT defect.

**Action in the next changed fixture:** latch a pending-response observation from first VALID until handshake and assert VALID plus full payload stability on every intervening cycle, including the handshake cycle. Add corresponding held AW/W/AR checks if claiming request-hold coverage. Do not describe `stable_checks=107` as exhaustive AXI temporal validation.

### F2 — Low, nonblocking: overlap assertion checks visibility, not the B-retirement edge

`TB:446–454` establishes that the diagnostic read sees the new write count. However, the count is updated at local rejection, before B is consumed (`RTL:71,115,144–148`). A mutant that admitted AR after counting but before B retirement could still satisfy this assertion. The current source explicitly prevents that (`RTL:81–82,127`), so the stronger ordering conclusion is source-supported rather than separately isolated by the observed count alone.

**Action in the next changed fixture:** record the write B handshake and explicitly assert no diagnostic AR handshake while that write is still pending, including the B-stalled interval. Keep the existing count check as an independent visibility check. No PCIe fence/global-drain conclusion follows from either check.

Other limits are correctly bounded: no exhaustive saturation/reset/extreme-peer tests; first-fault reason 4 and RO/format-as-first-fault encodings are source-reviewed but not independently exercised as first records; reserved bits are constructed zero but not checked with a full-word first-record oracle; after the positive campaign the fixture rereads counts, not first records. These do not contradict the inspected sticky logic, but should not be relabeled directed coverage. The endpoint store-byte/B-inactivity wait (`TB:326–334`) remains fixture visibility observation, not a host drain ABI.

## 4. Evidence and causal quality

Independently decoded all five configs with `ast.parse`/`ast.literal_eval`, never import/eval/exec. Verified:

- **2,645** embedded source payloads across five attempts against config and result hashes; all **529** final snapshot files and all **529** baseline snapshot files against their bindings.
- Every dispatch-to-script hash, outer-to-result hash, and all **25** embedded native-log byte counts/hashes.
- All five script bodies exactly match `run-native.py.in` after replacing only the literal config assignment. Final compile order has **450 unique entries**, with no duplicate earlier/final guard definitions.
- Original bindings (**523**) and tool/library bindings (**19**) match across configs/results/source binding. Captured original/input/tool preservation flags are true for every attempt. These are verified retained receipts, not a fresh remote filesystem/tool inspection. Same-installation Quartus 25.1 `altera_mf`/`altera_lnsim` library metadata remains inherited evidence, not a new library reconstruction.
- Native command argv agrees with the literal compile list/options; no assertion suppression was introduced. The runner requires the negative marker and numerical score independently of native return codes, and rejects the captured fatal diagnostics (`run-native.py.in:103–125`).

| Attempt | Native/effective status, all five commands | Outer | Retained outcome |
|---|---|---:|---|
| red01, @235 | all 0 | 1 | Transparent baseline accepts `0x30080`: expected DECERR, actual OKAY, 4275 ns |
| green01, @236 | all 0 | 1 | First guard returns the same wrong response, 4335 ns |
| green02, @237 | all 0 | 1 | Alias/zero-forwarding checks pass; unsupported pointer-readback assertion fails, 4370 ns |
| red02, @238 | all 0 | 1 | Corrected final fixture with transparent baseline still fails first alias, 4275 ns |
| green03, @239 | all 0 | 0 | Corrected final fixture with final guard passes, 49480 ns |

All attempts retain false timeout/remaining-live-group flags and empty final owned-group lists. `complete=true` in failed runs means command sequence completion, not functional acceptance. Fatal-bearing native-zero runs are correctly rejected by the outer verdict.

The green01→green02 RTL delta is precisely the write classifier's explicit formal address/size/strobe arguments and corresponding call; no FSM/map/test change. The observed pair supports this narrow correction, not a universal simulator-causality claim. The final red02→green03 configs differ only in run identity and `rtl/afu/ia840f_ahls_mmio_guard.sv`; the fixture, core/model payloads, compile order/options, tools, and library bindings are identical. Failed attempts and their dispositions remain preserved.

Final embedded `vsim.log:353,802,804,806` contains:

```text
AHLS_GUARD_NEGATIVE_PASS writes=11 reads=5 stable_checks=107
AHLS_GUARD_UNIT_PASS cases=4 elements=91 copied_bytes=1088 dma=16 checks=2821 mmio_reads=275 mmio_writes=97 bank0_W=18 bank1_W=31
Time: 49480 ns
Errors: 0, Warnings: 255
```

The four case markers independently show sizes 1/8/17/65, copyback bytes 192/192/256/448, and kernel-store bytes 4/32/68/260. Totals are 91 numerical elements and 1088 byte comparisons: 364 result bytes plus 724 guard bytes, with 16 DMA transfers and no inter-case reset. Golden results remain all positive; signed-extreme coverage is not claimed.

### Warning disposition

Reparsed `warnings03.json` against every corresponding final log row; counts and per-ID totals match exactly. Final-pair warning multisets are identical, not merely equal totals.

| Stage | Native warning groups |
|---|---|
| vlog: 43, errors 0 | 13314: 30; 2275: 7; 13528: 6 |
| vsim/vopt: 255, errors 0 | 13314: 7; 2685: 52; 2718: 184; 13528: 6; 2697: 2; 8315: 4 |

These retain port-kind defaults, generated duplicate-module replacement/time-call syntax, generated omitted connections, the two existing MMIO read-address out-of-range selects, and four time-zero DMA unique-case warnings. No warning points to the new guard. Existing warning dispositions are reused with unchanged underlying sources, not globally waived or converted into proof of safe physical operation. The full-address guard prevents rejected high aliases from entering that existing fabric; it does not repair its generated internal width warnings. No unchanged rerun solely for warnings is warranted.

## 5. Acceptance boundary and next action

Accept this frozen source/evidence set for **connected CPU-only admission/telemetry simulation**, with F1/F2 recorded as nonblocking test-strengthening work. The next bounded engineering step is insertion of only the final guard implementation into the actual alternate PIM top, with exact clock/reset, widths, placement before low-bit decode, and downstream response wiring checked, followed by the separately scoped native integration qualification. This review itself grants no launch or hardware authority.

Still open: actual primary PCIe mapper/OPAE and CPU-visible ordering; generic host WRAP and intermediate split-BRESP handling; capability/state/first-bus-error encodings; kernel/DMA value/lifecycle controls; full drain/fences and buffer lifetime; reset release/freeze/PR/recovery; physical DDR/controller behavior; full-FIM fit/STA/signoff, live numerical/transfer acceptance, and durable boot. Vendor DDR simulation remains **SKIPPED BY USER**. The project goal is incomplete.
