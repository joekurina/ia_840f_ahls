# GettingStarted correction results

## Outcome

The simulator family-parameter defect is fixed for the four affected integer tutorial variants. Fresh `fpga_template` and `fpga_compile` PART2/PART3/PART4 builds and runs each returned exit 0, checked all 256 original integer results, and produced **zero Error/Fatal messages** in the complete simulator transcript. Each original run had six family errors. The representative corrected template hardware-characterization build also completed with the same reported clock/resource QoR data and Fmax of **667.11 MHz** ([verification18.json](verification18.json), [simulator verification](simulator-verification14.json)).

The earlier timing assessment was also corrected: failure to close the deliberately generated 1000 MHz standalone characterization constraint is expected by the HLS handbook, not an application timing regression. No constraint was relaxed, no result text was suppressed, and no FPGA image was flashed.

## 1. The timing assessment used the wrong criterion

The archived official *Altera HLS IP Gen Handbook*, §9.1.1, states:

> You can expect to see timing closure warnings in the Quartus® Prime logs because the generated project targets a clock speed of 1000 MHz to achieve the best possible placement for your design. The fMAX value presented in the FPGA Optimization Report estimates the maximum clock rate your component can cleanly close timing for.

The quotation, official source URL, archived-document hash and exact native report captures are retained in [timing-interpretation07.json](timing-interpretation07.json). The raw negative slacks remain true observations at the artificial 1 ns constraint, but treating them as failed application acceptance was incorrect. `-Xsclock` controls scheduling effort; it is not automatically the standalone Quartus signoff clock.

The original completed Optimization Reports provide these component estimates:

| Variant | Reported Fmax (MHz) |
|---|---:|
| fpga_compile PART2 | 667.11 |
| fpga_compile PART3 | 781.86 |
| fpga_compile PART4 | 772.20 |
| fast_recompile | 711.24 |
| fpga_template | 667.11 |

These are literal `clock fmax` entries from `reports/resources/quartus_data.js`, not estimates reconstructed from a single slack. The generic report wording about PLL adjustment does not prove a physical clock was programmed. Actual integrated timing at the intended operating clock remains a separate requirement ([report data and provenance](timing-interpretation07.json)).

The vendor BSP comparison supports the distinction. Its source initially uses 1.25 ns user-clock constraints, enables `DO_ADJUST_PLLS=1`, selects valid kernel frequencies after fitting, reruns timing checks and packages clock metadata with the board executable. Initial constraints/caps are not Joe's observed vector-add operating frequency. His known-working run is accepted as reported; the exact final frequency was not recovered, so no unrelated board-test frequency is substituted ([parent-checked vendor comparison](vendor-baseline11.json)).

## 2. The actual simulator defect and code change

In the inspected HLS IP Gen 2026.1.0 support RTL, `lsu_top.sv` instantiates `lsu_bursting_read` without its `DEVICE` parameter at two call sites. The child defaults to `Stratix V` and forwards that value through `lsu_bursting_pipelined_read` / `acl_scfifo_wrapped` into the SCFIFO model. The selected simulator's Pro-family validity check rejects it.

The additive configuration supplies the actual family:

```systemverilog
.DEVICE("Agilex 7"),
```

Only those two instantiation arguments are added. There is no arithmetic, interface or reset-RTL rewrite, no primitive-model change and no warning/error suppression. The exact code delta and CMake recipe are published under [examples/ahls/compatibility/lsu-family](../../examples/ahls/compatibility/lsu-family/README.md).

The preparation gate requires the exact IA-840F part and source release:

| File | SHA256 |
|---|---|
| Original installed `ip/lsu_top.sv` | `873549f18428fe6ba0797fef228c2028bf1df62076e85f1942c9dca5310cf8a0` |
| Prepared private overlay | `cfee3826587686ddc36919ac18db973c620f72bfd8f555ab2f3622b19b21d333` |

CMake prepares an owned output copy. A read-only bwrap mount changes the compiler's view of that one file; it never overwrites the installed SDK. The native test checks that the generated project actually contains the overlay hash. Wrong-part and changed-source inputs were rejected in file-only tests ([prepare-validation05.json](prepare-validation05.json), [prepared06.json](prepared06.json)).

## 3. Native results

| Corrected variant | Build exit | Run exit | Original checks | Transcript Error/Fatal |
|---|---:|---:|---|---:|
| fpga_template | 0 | 0 | 256 integers PASS | 0 |
| fpga_compile PART2 | 0 | 0 | 256 integers PASS | 0 |
| fpga_compile PART3 | 0 | 0 | 256 integers PASS | 0 |
| fpga_compile PART4 | 0 | 0 | 256 integers PASS | 0 |

These are fresh changed-input runs, not old numerical passes relabeled as clean. The captured complete transcripts and native command logs are hash-verified under [capture13](capture13/) and [collection13.json](collection13.json). The earlier errors remain in the [baseline evidence](../ahls-getting-started-01/diagnostic-disposition13.json).

The corrected `fpga_template` full-IP build returned CMake exit 0 and native Quartus full-compilation success for AGFB027R25A2E2V. Its Optimization Report clock/resource data is byte-identical to the original characterization report, including Fmax 667.11 MHz. Its `create_clock -period 1 clock` SDC is also byte-identical. This is reported-QoR equality, not a claim of bit-identical implementation databases or integrated/card timing signoff ([capture16](capture16/), [verification18.json](verification18.json)).

The worker completed all five correction jobs once. Its completion observer exited 0. Postflight found no live owned process, all original tutorial files unchanged, and the installed SDK source still at its original hash. No physical-card operation was performed ([finished06.json](finished06.json), [postflight17.json](postflight17.json)).

## 4. Scope and remaining distinctions

- The selected HLS 2026.1 / Quartus 25.1 compatibility warning and other non-error model warnings are retained. This is an empirically verified correction, not a claim of vendor-supported mixed-version compatibility or warning-free execution.
- No algorithm or imported upstream C++ file was changed. Existing CPU/emulator, fast-recompile and original characterization results remain at their recorded scope; they were not all rerun during this correction.
- The original vendor BSP supplied an MMD/OPAE board runtime, transport, PR packaging and clock selection. AHLS standalone compilation produces components for OFS/PIM integration; this correction does **not** restore a drop-in oneAPI SYCL board executable or claim new on-card execution.
- The existing CAPS03 image and `ia840f-caps03-v1.0.0` tag remain unchanged. The broader release-wide sample work remains paused.
- An initial local verification check guessed an extra newline in the SDC. It was corrected by comparing the exact captured baseline bytes; no native rerun or SDC edit resulted.

The runnable setup instructions now prepare the overlay before entering the isolated compiler shell and require a fresh build directory to avoid reuse of an older uncorrected device image ([GettingStarted README](../../examples/ahls/README.md)).
