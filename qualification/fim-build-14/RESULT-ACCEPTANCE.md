# Parent disposition — Work14 native result evidence

**Native execution/result-evidence gate ACCEPTED. Timing gate FAIL / NOT ACCEPTED. Hardware NOT RUN / NOT QUALIFIED.**

This consumes the independent review without promoting its failed timing result to success. The one authorized native compile completed, including assembly, and its emitted programming-file identities are recorded. This is not acceptance of deployment readiness, complete synthesis/CDC correctness, a matching AHLS persona, or any hardware test.

## Review binding and parent verification

- [Immutable result package](result-review-inputs01.json): **39 unique files**, SHA256 `99f58803c9b05c4c37a4203701176d517d866d9969d649c51fa4244ef1ede744`.
- [Independent timing and bounded compile-result review](timing-independent-review01.md): SHA256 `37b5a62ceb38f6c8013496e4fa339eeefcc7c202143409f5b3937c346674eace`. It verifies the complete captured STA/fitter, completion and signoff evidence, matches the package, and supports the bounded compile-result claims while explicitly rejecting timing acceptance.
- [Parent consumption check](parent-result-consumption02.json) rehashed the 39 package files, all reports11/reports13 raw reports and reports11 compressed copies; matched eight cited maintained-source files to the issued compile inventory; and checked the actual hold-path and missing-PCIe-clock lines. The source-path lookup rejection is retained in the receipt; it wrote no source or evidence before rejection.
- [Parent DRC cross-check](parent-result-drc03.json) resolves the earlier parser's empty selection and independently reproduces **seven failing High rules, 34 violation rows, zero waived**, using rule IDs plus titles and nonzero counts. This supersedes only the empty DRC selection in the preceding receipt; the preceding file/hash checks remain valid.

The frozen [RESULT.md](RESULT.md) and [initial timing report](FIT-TIMING-INITIAL.md) retain their pending-review/historical running language as immutable evidence. This disposition and CURRENT.md provide the later status. Raw STA/fitter/native logs exceed the repository cap and remain local; exact lossless gzip copies and hash manifests are retained. SOF/RBF hashes are captured **remote ordinary-file measurements**, not local binary checks or readback from the FPGA.

## Accepted facts, not broader qualification

1. Native rc0; successful final flow and assembly, Quartus Pro **26.1.1 Build 130**, part **AGFB027R25A2E2V**. Full compile: 0 errors, 978 warnings. No gate rejection; no matching native/compiler processes at the captured completion snapshot. Do not interpret that historical snapshot as a fresh host check. [Completion evidence](completion12/manifest.json).
2. A single detailed EMIF1 write-data bit243 → PHY hold path fails **−0.004 ns, Fast vid2 100C**. The full STA already identifies its source, endpoint, clock paths and physical location. Seed2, all-path hold optimization and aggressive hold closure are already effective; repeating them is not a remedy. [Independent review §1](timing-independent-review01.md).
3. A real fitted PCIe divider remains unconstrained. Maintained `top.sdc:35–37` uses obsolete hierarchy; the generated PCIe SDC uses the current hierarchy but conditional clock creation. Eight PCIe net-delay rows have invalid clocks. JTAG/BMC IRQ constraints and the named active CDC/reset findings remain open. No failure has been waived. [Independent review §§2–3](timing-independent-review01.md).
4. New build FIM interface **`5c04f735-4245-5537-88d6-380f16bcc372`** differs from the W13 persona's **`c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`**. The old persona must not be relabelled or treated as matching, and the base green-region RBF is not an AHLS persona. This is build identity, not live card identity. [Independent review §4](timing-independent-review01.md).
5. Post-fit FME MIF update occurred before successful assembly. The later synthesis-freshness diagnostic is retained; it is not by itself reason to repeat the unchanged full build. [Independent review §4](timing-independent-review01.md).

## Next source-side action

Investigate the narrowly identified **PCIe divider clock-binding defect** first, using existing source/generated evidence. Establish the exact divider pins, incoming clock and relevant FIFO destinations; examine the dependent asynchronous groups and multicycles before enabling a previously missing clock. Do not guess a frequency, silently activate unsupported exceptions, change vendor internals, rerun the unchanged compile, or relaunch the prohibited historical Query04/equivalent. Any source candidate and subsequent vendor run need their applicable independent technical review and source-bound execution record.

Keep the EMIF1 hold failure separate. Disabled-PMCI constraint noise may be independently corrected later; it does not explain the real PCIe divider, BMC IRQ or active CDC findings. Matching PR release/persona work follows the relevant FIM gate, not mere compile success.

DDR simulation remains **SKIPPED BY USER**; dummy-CSR exercising remains excluded. Flash/reboot permission is recorded, but exact source-supported operation scope, identity and **currently verified independent host recovery** remain prerequisites. No flashing, OPAE/device access, rule activation, reconfiguration, reboot, reset or power-cycle took place in this continuation. The hardware mission remains incomplete.
