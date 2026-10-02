# Warning-result review35 — bounded PASS

Reviewer: GPT-6 (`gpt-6-astra-900k`), `openai-codex`, substituting for unavailable GLM-5.3.

**Disposition:** the ten new warning occurrences do not block acceptance of this completed migrated explicit-list unit simulation. Both groups are source-justified expected behavior within the frozen configuration. This is neither a blanket warning waiver nor vendor-IP requalification; behavioral acceptance remains a separate review.

## Evidence and coverage

Independently recomputed SHA256 and byte counts for **669/669 members**, totaling **22,720,710 bytes**, of `actual-result-freeze33.json`; no mismatches. Freeze SHA256: `b5b51108e7ff8df145fed30a1bae2d21a0c5125ee67b2783fa4cba6bf795f48e`. This is whole-inventory identity coverage, not semantic review of every member.

Read `actual-result-index32.json`, `RESULT32.md`, `native-verification29.json`, `warning-context30.json`, and `source-spec-review14.md`. Reparsed the actual `completion28-readback/operation/{vlog,vsim,split_fault}.log` diagnostics; verified all eleven completion readbacks against their decoded capture28 bodies/hashes. Semantic source review covered the two exact warning-named NI files, their duplicate definitions and alignment connections, three selected interconnect parameter owners, and `altera-lnsim-region31.sv`. Selected sources also match admitted27 hashes and compile membership.

| Native log | Prior sim05 | Completed run | New occurrences |
|---|---:|---:|---|
| vlog | 36 | 38 | 2 × vlog-2275 |
| main vsim | 261 | 269 | 8 × vopt-2241 |
| split-fault | 0 | 0 | None |

Other ID counts remain: vlog-13314=30, vlog-13528=6; main vopt-13314=7, vopt-2685=52, vopt-2718=184, vopt-13528=8, vopt-2697=6, vsim-8315=4. Matching counts establish the census only, not unchanged semantics or acceptance of those inherited diagnostics.

## Two module-overwrite occurrences

`vlog.log:741,743` names only these files under `prepared-sources10/`:

`generated/ip/ahls_memory_dma_fabric/ahls_memory_dma_fabric_fabric/altera_merlin_axi_slave_ni_19134/synth/ahls_memory_dma_fabric_fabric_altera_merlin_axi_slave_ni_19134_{twehoqy,wxqskeq}.sv`

I independently extracted each complete raw module span from both files, rather than accepting the parent equality assertion. Including the preceding newline, both pairs match byte-for-byte and reproduce `duplicate-module-comparison31.json`:

| Definition lines in both files | Raw bytes per definition | SHA256 |
|---|---:|---|
| `burst_split_4k`, 1946–2107 | 7272 | `752bc690cd25dcb6fc3e62dbb4d26cda1c32e8eaacc0e381875acc612d0c4a4c` |
| `wr_burst_split_4k`, 2109–2280 | 8183 | `d6655c8945d5990d0637aa93cc6905e57bdbe9a1828a7e97110f63bfb2530183` |

Neither body contains macro references/directives; both files have the same `timescale`. Native `vlog -sv -work work` compiles twehoqy before wxqskeq: the overwritten definition is replaced by identical parameterized source, not a competing implementation. This disposition applies only to the retained flattened `work` recipe. Selected CSR/bank NI owners additionally set `ENABLE_SPLIT_AT_4K=0`; their helper instantiations are inside that conditional generate. Passing page-split tests must not be described as validating these disabled vendor helpers. No renaming, removal, or generated-library-policy change is warranted.

## Eight scalar-width occurrences

`vsim.log:8–15` identifies four ports at each of the two NI source sites, not eight payload-width failures. Both NI definitions instantiate `check_and_align_address_to_size` at line 1280 with `INCREMENT_ADDRESS=0`; lines 1286–1289 connect `in_valid`, `in_sop`, `in_eop`, and `out_ready` to `'h0`.

The warning-referenced installed declarations at original `altera_lnsim.sv:58339/58341/58342/58345` declare all four inputs scalar. An unsized based zero narrowed to one bit discards only zero bits and delivers `1'b0`: no data, address, or asserted handshake bit is lost. This is the decisive warning-specific argument, not the numerical pass alone.

The selected interconnect owners `_bkknk2i.v:1259`, `_tl3boyq.v:1420`, and `_kxqfnfa.v:1420` bind the CSR and both bank NIs. Their derived alignment input/output vector widths match the receiving declarations: CSR **28/19**, banks **49/40** bits. `TYPE_W`/`BURST_TYPE_W=2`; address, size and symbol-count parameters agree. These vector connections are separate from the four warned scalar ties.

Captured common logic extracts address/size and builds alignment masks (`58467–58489`); the incrementing generate at 58497 is unselected. The region ends inside that branch, before the complete non-increment output implementation: I do not claim full internal-path proof. Scalar-zero conversion remains value-preserving independently of that missing body suffix.

Region SHA256 independently matches `06b31d64f0b123d260651d6270624d7a5d8b3e739e274a217a460a7e325dd3ea`; metadata records full-source SHA256 `4409ed6e3a5eee203f66c59a1d6d67eaa7eb1631781f7f61cca2b29b91441770`. All 19 simulator/library bindings agree with admitted27 and retained preservation receipts. The post-run plaintext capture corroborates native declaration references; it is not independent proof of every precompiled/encrypted library body.

## Result boundary

Questa 2024.3 records seven CMake/effective zeros, six direct-target native zeros, configure native not applicable, and outer zero; diagnostic/postflight errors are empty. Logs retain six cases, 133 integers, 1600 copied bytes, 30 DMA descriptors, 402461 checks, and one each bank1-reset and page-split-fault pass record. These support, but do not replace, behavioral review.

No warning-specific discriminator remains necessary for this bounded acceptance. Excluded claims remain full PCIe/AFUtop/pr_slot, timing, physical DDR/hardware, stopped-clock/active-reset recovery, bank0 read-error telemetry, unsupported fault cases, and general cross-release equivalence. Capture31's recorded wrapper `KeyError: 'success'` was recovered without retry; the retained decoded region matches. No project script/test/native execution, remote/Git/hardware access, library rebuild, diagnostic suppression, or source edit was performed. Only this review was written.
