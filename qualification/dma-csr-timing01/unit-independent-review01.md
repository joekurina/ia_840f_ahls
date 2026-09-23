# CSR endpoint-pipeline unit independent review

Status: FINAL

**Verdict: ACCEPT the exact candidate and completed native evidence for bounded CSR functional-regression acceptance. Specification PASS; quality PASS with the nonblocking limits below. No material candidate defect or reason to stop the parent's ongoing changed synthesis was found. This is not build authorization, timing closure, or system/hardware signoff.**

Review order was specification first, then implementation/test/evidence quality. Only local source and retained evidence were examined. Python was used for AST/literal parsing, hashes, byte comparisons, log parsing and independent arithmetic/count reconciliation; no runner was imported or executed. No remote, native/vendor/simulator, hardware, Git, or task-transition operation was performed. This report, first written IN_PROGRESS and now FINAL, is the only file created or modified.

Paths below are relative to `/home/joe/Projects/Thesis/AHLS/new_bsp/new`. Within this directory, B means `csr_mgr-baseline01.sv`, C means `csr_mgr-candidate01.sv`, and T means `csr_endpoint_diff01_tb.sv`. Integration-fixture line references address the unchanged `qualification/dma-csr-admission01/inputs-test02/dma_csr_admission_tb.sv`.

## 1. Specification review — PASS

### Exact identities and scope

All 16 members of `unit-review-package01.json` matched their recorded byte lengths and SHA256 values. The manifest itself matches the requested identity. The supplied patch is byte-identical to an independently generated unified diff of B and C.

| Object | SHA256 |
|---|---|
| Unit review manifest | `228a1d38dc9e2e600a4fcd7ef9e872f93b2dfd0520b721471cf6ee973c6d0558` |
| Baseline B | `b526562f8663139a1a5654e54695ada8de67ee260b3b6a79014344ab7f3c4073` |
| Candidate C | `42d09ffffb91152b9f688014bcff9ffc13e5382cddd7f478e5f9b992da232a77` |
| Exact patch | `f47ce5640d5e949cfc436622ca68a36309aa5ccf1b8a2057b5d3857850d66b66` |
| Differential fixture T | `e5235478dc30728cadb4458a0034af977e74a0691311534ff9ef4c45d367a3a5` |
| Unchanged corrected integration fixture | `65143df8bd1a6d05780c3cd478d91d37ca07d4d19bc609a051605aba845b07e8` |

I also verified all six members of the prior source-review manifest, SHA256 `7193881157a18c67d975099feb512711a59bd6064c064bde5d890481a163317b`. `source-review01.md` remains a prior recommendation, not an approval of this candidate. AST-only decoding of `qualification/ahls-persona-work21-sta01/run-sta01.py` verified its 13 source payloads and proved B is its exact `afu/csr_mgr.sv`. Across the nine AFU sources shared with integration01, only `csr_mgr.sv` differs. The previous corrected full-top green03 runner's 25 source payloads also differ from integration01 only at CSR; its CSR is B and its fixture is the same corrected fixture, not the historical stale-WVALID driver.

### Candidate implements the intended narrow correction

C:103–129 adds two continuously updated 65-bit inclusive endpoint registers, synchronous reset to zero, and a pure arithmetic helper with explicit address/length operands. `descriptor_ok` receives the registered ends. Its start calculations, mode selection and return predicates are retained (C:130–151); only the endpoint operands in its call change (C:171).

The full diff leaves the access/value checks, DECERR-before-SLVERR precedence, freshness updates, AXI-Lite AW/W capture, B/R generation, architectural register writes, GO pulse clearing and architectural reset logic unchanged. No interface, package, engine, FIFO, clock or constraint change occurs in this patch. Nominal added state is 130 bits; mapped cost and physical timing remain unmeasured by these unit results.

The source and bound unit geometry preserve:

- Host57; two DDR banks with 34-bit byte offsets and a 35-bit aggregate address. Both stored address fields are 57 bits. Starts remain checked before downstream narrowing.
- 512-bit/64-byte beats; 20-bit stored length; 8-bit AXI LEN. Independently calculated maximum admission is `((2^9)-1)*2^8 = 130816` beats, or 8372224 bytes, not the full 20-bit length domain.
- Inclusive unsigned 65-bit arithmetic. Host start/end must fit57; DDR start bank must be below2 and inclusive end must remain in that bank. Alignment and nonzero/maximum length checks remain.
- Descriptor modes0/3 reject with or without GO; modes1/2 remain allowed. Only GO31 and mode27:26 are allowed command bits. Legacy control is a separate low32-bit register: value3 is still accepted, and any nonzero stored control blocks GO.
- Access-valid failed field writes retain the old field and invalidate only its freshness. Access-valid GO consumes all three freshness flags even when admission fails; malformed accesses do not consume them. Valid non-GO mode writes bypass admission and preserve freshness.
- FIFO-full, reader/writer error, legacy control and freshness are evaluated at the original service edge, not cached with the arithmetic.

### Why the registered endpoints are current at GO

C:254,346–395 serializes complete writes and B responses. If the last field commits at E0, it also consumes the held AW/W and sets BVALID. The endpoint registers capture pre-E0 data on E0, then catch the updated fields at E1. E1 is the earliest B handshake; AWREADY/WREADY are still low before that edge. E2 is the earliest next request capture, and E3 the earliest next write/GO service. Thus endpoints are already current before GO. Split channels or B stalls only increase this interval. Source/destination/length have no additional writer; GO itself does not update them.

Reset clears requests and freshness as well as architectural state. Zero-length endpoint underflow after reset cannot authorize GO because fresh/nonzero predicates still reject it. An invalid field update similarly cannot authorize stale derived state. FIFO enqueue remains the existing registered GO pulse on the following edge (`dma_top.sv:72–95,108–123`). No BREADY-dependent ownership transfer or extra enqueue delay was introduced.

This invariant is a maintenance condition: accepting writes while B is pending, adding another staging writer, or deepening the arithmetic pipeline requires a new schedule proof. It is not permission for a timing exception.

## 2. Quality and completed evidence review — PASS within scope

### Runner/configuration and payload integrity

Both complete runners were parsed with AST and their single literal `C` dictionaries decoded. Each runner equals its corresponding `.py.in` template with exactly `@CONFIG@` replaced by `repr(C)`; no other template delta exists. A restricted expression-only AST interpreter reconstructed the command lists and matched every recorded label/argv exactly, without executing runner statements.

All 25 integration source payloads and all 27 differential source payloads matched their declared hashes; both result input maps match those payloads. All ten embedded logs matched their byte lengths/hashes on exact UTF-8 re-encoding, with no missing/truncated log text. Shared source payloads between the two runs are byte-identical. Both candidate payloads equal C. The differential baseline equals B with only `module csr_mgr #(` renamed to `module csr_mgr_baseline #(`; its renamed hash is `06a0fe29df4778fcc477ffc4bb69c3d3dff8ca58129526df1c89b00e20bd4dd2`.

Dispatch receipts bind the exact runner hashes. Outer receipts bind the exact result bytes/hashes and report outer0. Result original/tool maps agree with their configurations. For both runs, the five commands are version/vlib/vdir/vlog/vsim, native/effective codes are all0, timeout/remaining-descendant flags are false, and owned-live-group lists are empty. Complete/unit_pass and all three preservation flags are true. These are independently checked retained receipts, not a new remote measurement of tools or process state.

| Bound artifact | SHA256 |
|---|---|
| Integration runner | `f1a88be11d27eeacb75c343ec2f4180f7c2186e1801c4266ee9561f14ca8eacf` |
| Differential runner | `a2e8b9d8f65b4bc22b662c17aa50e6790beeb9c6559cecb816bbad9f7e169c59` |
| Integration result | `d4973aff4b25a59d15b7c0620dd544b0c55d6639eced4c1649a7cdf70c758a7e` |
| Differential result | `07ddcee4932c1f1485086ce30646ef78b5d98d4754720b04ab541539f7fe97c8` |
| Integration vsim log | `6f252e5d3a425bf59dee8d1104dfb08890dd2d74c02198edb412b1f9c812ce20` |
| Differential vsim log | `c449518d9f133271d95cffa169299c0360173a918855d69446cf976863973ae9` |

The actual native version is Questa2024.3 under the bound Quartus25.1 installation. Recorded CPU affinity is two CPUs and address-space limit16GiB; the template imposes120-second command deadlines. This is finite process supervision, not an OS sandbox or aggregate-memory guarantee.

Acceptance is not inferred from `-onfinish exit`/native0 alone: the runners also require complete scoreboards, diagnostic cleanliness and preservation. I independently scanned all logs for Error/Fatal diagnostics including parenthesized qualifiers, and nonzero Errors summaries; none were present. Exact terminal PASS records were parsed afresh and match the structured scoreboards.

### Numerical assertions and scheduling are substantive

**Integration01.** All eight distinct case records are present, with lengths1,257,514,1024,513,63,256,769. Independent summation gives3397 R beats,3397 W beats and19 bursts on each AR/AW/B channel. Every case retired once without error/held disposition. The scoreboard reports110977 checks,3069 R-stall samples,4908 W-stall samples, maximum buffered38, and four high-host-source/four high-host-destination cases. Its full final scoreboard matches the prior corrected baseline green03 result.

The fixture checks full address-dependent 512-bit payloads through the actual data FIFO and destination model, accepted address capacity, IDs/sizes/burst lengths, WLAST/strobes, FIFO occupancy and ordering, all copied-back words, and retirement only after the modeled pipes/responses drain (integration fixture:383–469). Bank isolation actively lowers inactive readiness and supplies wrong inactive response payloads; `+ISOLATE` is in the actual invocation. Transfers after the first data case are no-reset successors. This is numerical behavior, not merely successful status polling.

Guard counters are56 checks,32 rejected writes,4 rejected reads,20 rejected GO and20 admissions. The20 admissions include three boundary-only entries and17 entries that fill the real queue. The helper counters are not total MMIO transaction counts: the native log contains204 write services and31 read services. Maximum-length acceptance is admission-only.

**Differential01.** The final record is311 GO-oriented scenarios,1512 task-completed writes,23 reads,85 observed GO pulses,226 fresh-GO endpoint-check events,665 three-cycle service gaps,106 B-stall samples,115 R-stall samples,246 module resets,8571 cycles and54876 assertion-task calls. An endpoint-check event performs two equality assertions, not one.

Independent reconstruction from the finite stimulus sections exactly reproduces311/1512/85/226/246. The native log contains3028 paired write-service records:1514 per implementation, comprising1512 completed task writes plus two commits whose held B response is interrupted by reset. Every adjacent baseline/candidate address/data pair agrees. The46 read records similarly pair into23 reads. The minimum-gap schedule independently sums to665, and the fixed read-stall schedule gives23*5=115 samples; the directed B-stall schedule sums to106. These counters have consistent meanings and are not conflated with independent test-case counts.

For the transition matrix (T:208–219), I independently evaluated all144 cases: six field orders, three arrival styles, two directions, two banks and both validity transitions. There are72 valid and72 invalid final descriptors; every preceding staged descriptor has the opposite range verdict, and each field is last in48 cases. The near-limit arithmetic and expected responses are correct. The independent endpoint reference uses a 65-bit concatenated left shift by6 rather than calling the candidate helper (T:33–35,63–68).

Additional explicit assertions cover all mode/GO combinations, all61 reserved bits followed by clean GO to expose freshness consumption, all eight freshness combinations, invalid-access GO preserving freshness, individual bad-field invalidation, legacy control0–3, non-GO with missing fields/full/errors, invalid reads/decode/access shapes and synchronous partial-request resets (T:220–271). Both baseline and candidate passing is correct for a timing-only functional-preservation patch; no fabricated old-fails/new-passes requirement applies.

### Race/stall review

- T:80–107 initializes payloads on the falling edge before asserting the corresponding VALID. Delayed AW/W remains deasserted until its intended arrival; accepted external payloads are then deliberately poisoned. This avoids the historical stale-W driver bug and tests internal capture.
- T:37–71 compares ready/valid timing, packed valid B/R, the complete architectural map and freshness both before the active edge's NBA updates and after `#1`. Invalid response payloads are not falsely required to match.
- The previous-cycle B/R stall flags require VALID and the entire payload to remain stable through the eventual handshake edge, not just while READY stays low. Enqueue assertions after `#1` avoid a same-edge test/monitor race.
- T:143–168 really offers the next request while B is stalled, proves both request-ready signals remain low, and then requires exactly one GO and the next response's ID/USER. It does not count offered VALID as accepted traffic.
- T:170–202 changes public status between split AW/W arrivals and again after BVALID, checking the original service decision and held response/GO ownership. It does not force DUT internals. This directly addresses the risk of accidentally pipelining live predicates with arithmetic, within the sampled phases noted below.
- T:261–270 interrupts AW-only, W-only, held-B and just-committed-field cases, checks the flushed public transaction state, re-primes, and successfully issues a successor GO. These are module synchronous-reset cases only.

### Native warnings retained and classified

Integration compilation reports8 warnings; simulation/elaboration reports11. Differential compilation reports4; simulation/elaboration reports2. Port-kind warnings13314 concern unchanged typed input declarations under `-svinputport=relaxed`; there is no suppression workaround. Integration additionally has four unique-case warnings8315, all explicitly at time0, in reader/writer state decode before the first synchronous reset edge (`dma_read_engine.sv:114,212`; `dma_write_engine.sv:140,260`). Their source and occurrence support startup classification for this run, not an assertion that those warnings can always be ignored. No later such warning or native diagnostic error was found. The evidence is not warning-free.

## 3. Nonblocking limits and final disposition

1. **Actual queue/error ownership coverage remains limited.** The direct differential fixture drives synthetic public FIFO/error status; it cannot prove generation or persistence of real sticky engine faults. The full-top integration fills the actual FIFO with repeated entries and checks rejection, then resets it. It does not newly drain identifiable queued entries after rejection, exercise real response-error recovery, or prove faulted-head ownership. Those stronger recommendations in `source-review01.md` are not all completed. `RESULTS01.md:18` discloses this correctly. Do not promote these passes to full FIFO/error/reset acceptance.
2. **Directed, not exhaustive.** Late-status tests are AW-first and switch status before W arrival and after B formation, not at every possible last-half-cycle phase. Fastest-gap matrix boundaries use one/two beats; larger-length near-limit combinations and every raw invalid value are not exhausted. Differential equality alone also cannot exclude a bug shared by B and C. The exact unchanged predicates, independent endpoint/reference checks and separate numerical integration make these acceptable limits for this narrowly scoped timing change, not exhaustive proof.
3. **Platform/physical behavior remains outside the unit boundary.** Projected unit packages and synthetic linear endpoints are not the generated PIM mapper, physical DDR, hardware visibility, host-buffer lifetime, freeze/drain or PR contract. The tests do not establish maximum-length data transport or safe live reset/recovery.
4. **Timing remains unresolved.** The original bound final-STA report still contains setup slack `-0.367 ns` at the3.000ns EMIF0 clock, from CSR length[14]~ENA_dff to length[0]~DUPLICATE. That report's20 worst violated paths are capped samples. The new registers structurally split arithmetic from admission, but neither unit simulation nor source reasoning measures mapped timing. Changed fitting/final STA must establish the outcome, including new arithmetic/endpoint/admission paths and unchanged broader signoff obligations. No exception, reduced clock, predicted slack or timing waiver is accepted here.

No frozen artifact was edited. The prior source recommendation remains historical; this report supplies the independent bounded candidate/result acceptance. There is no identified material defect warranting interruption of the parent's already-started native iteration, and this report neither operates nor authorizes that build.
