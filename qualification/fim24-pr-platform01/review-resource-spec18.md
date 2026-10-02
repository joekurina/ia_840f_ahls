# Resource-only SOURCE SPEC supplement — PASS

**Verdict:** PASS; no resource-SPEC blockers. This supplements the accepted `review-spec12.md` through `spec-consumed16.json`; it does not repeat the 88-file review or grant execution authority.

**Binding:** Independently verified all 24 members of `final-package-freeze17.json` (SHA256 `07105b832a8ba55e09bd579ba26dce74cc03ef359e60572b6715b72f287eeb1e`), the accepted baseline inventory/draft bindings, and all seven exports against `resource16-result.json.gz` and local readbacks. The actual `resource16-readback/resource-preparation16.json` supersedes only the historical supplement15 “not staged” status.

**Exact design delta:** Comparing complete prepared10/prepared15 inventories gives identical membership: 4,285 entries, 4,284 unchanged. Only `syn/board/ia840f/syn_top/ofs_pr_afu.qsf` differs, by this single insertion immediately after `set_global_assignment -name TOP_LEVEL_ENTITY top`:

```tcl
set_global_assignment -name NUM_PARALLEL_PROCESSORS 36
```

Byte comparison proves no other QSF edit. Before SHA256: `3972818497868e72ea15062818b2f4cd9e58917f9d3b46877f791be63bee58ab`; after: `6a3c544a3827b2e6a145242e1679e8622b7745a97f1ba40471eaf1af2b444f6e`. Base `ofs_top.qsf` already specifies 36 and is unchanged. No clock, feature, or RTL change is introduced. Gate/CMake hashes and all six contexts remain unchanged.

**Policy conformance:** The actual draft/receipt records CPUs 0–35, exactly the complete affinity captured by preparation. Static inspection of `candidate15/run-export15.py:93–106,170–187` confirms fresh live-affinity equality, full-set child affinity, and both soft/hard `RLIMIT_AS` of 68,719,476,736 bytes (64 GiB). Headroom, competing-job, identity and finite-deadline checks remain. This is per-process address-space limiting, not aggregate memory containment or an OS sandbox. Actual Quartus worker counts remain unverified.

**Freshness/preservation:** The receipt records exclusive new `prepared15`, preserved prepared10 evidence, original Work24 and five static artifacts, with `export01`/`release01` absent and no authority issued. The five artifact bindings are unchanged. The captured missing-admission rejection is preparation evidence only, not runtime integration proof.

**Boundary:** Local reads and in-memory comparisons only; no prepared-script/test execution, SSH, Git, vendor or hardware operation. Runtime QUALITY, admission, native export and result acceptance remain separate. Reviewer: GPT-6/openai-codex, substituting for unavailable GLM5.3.
