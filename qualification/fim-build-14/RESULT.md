# Work14 full-FIM compile result

**Native compile COMPLETE, exit 0. Timing NOT ACCEPTED. Hardware NOT RUN.**

This report records actual compiler outputs; independent result review is pending. The earlier [compile-package acceptance](COMPILE-PACKAGE-ACCEPTANCE.md) authorized execution, not timing or hardware acceptance. The source change remains the independently accepted [UART-absent vendor-convention correction](../dfl-uart-fix-02/ACCEPTANCE.md), with compile-gate path retargets. W13 and its persona are preserved.

## Execution and stage results

The one authorized run started **2026-09-21 21:34:56 PDT** and ended **22:27:14 PDT**, about **52 minutes 19 seconds**, in owned tmux `ia840f_mailbox_monitored_01`, window `fim14_native04` (@23/%23). Its native command, from maintained remote SOURCE, was:

```text
./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14
```

[Final native status](completion12/evidence/run/native-status.json) and [runner status](completion12/evidence/run/status.json) agree on return code 0. The [completion capture](completion12/manifest.json), taken at 2026-09-22T05:30:12Z, found no matching native/compiler processes. The [parent verification](completion12/parent-verification.json) rechecked all 16 captured files and found no source-defined gate rejection markers in the complete native log. These are terminal software-execution observations, not live FPGA tests.

| Stage | Tool result | Errors | Warnings |
|---|---|---:|---:|
| IP generation | Successful | 0 | 0 |
| Synthesis | Successful | 0 | 81 |
| Fitter | Successful | 0 | 222 |
| Main Timing Analyzer | Analysis completed; timing requirements **not met** | 0 | 260 |
| Post-module Timing Analyzer | Tool execution successful; not a replacement signoff | 0 | 201 |
| Assembler | Successful | 0 | 1 |
| Full compile | Successful tool execution | 0 | 978 |

Counts are separately reported invocations, not values to sum. The [full native log gzip](completion12/evidence/run/native.log.gz), exact uncompressed SHA256 `6920c32b3af0c50bc7df55f6af3b04a58081d6f21e3c45a5eef5722e8a390e5a`, retains all diagnostics; raw 3,178,851-byte log stays local. [Flow](completion12/project/output_files/ofs_top.flow.rpt) and [assembler](completion12/project/output_files/ofs_top.asm.rpt) identify Quartus Prime Pro **26.1.1 Build 130** and **AGFB027R25A2E2V**. Assembler Warning 20536 says the legacy `GENERATE_RBF_FILE` setting is ignored; the completed output directory nevertheless contains the stable, hash-captured RBF listed below. The warning alone does not establish the absence of that file, and its presence is not runtime-PR validation.

## Timing and constraint disposition

[Initial detailed timing findings](FIT-TIMING-INITIAL.md) and [full-summary analysis](reports11/timing-summary-analysis.json): worst setup **+0.015 ns**, hold **−0.004 ns**, recovery **+0.214 ns**, removal **+0.132 ns**, minimum pulse width **0.000 ns**. The hold failure is EMIF1 PHY clock at **Fast vid2 100C**. DDR and unconstrained-path closure are also marked Fail; high-severity Design Assistant and PCIe `set_net_delay` diagnostics remain unresolved.

The complete STA and fitter reports were captured in [reports11](reports11/manifest.json); their hashes were checked again after native completion and were unchanged. They were **not rebuilt or retransferred**. Exact signoff, synthesized and partitioned DRC reports plus SDC-constraint report are in [reports13](reports13/manifest.json). No warning waiver, timing exception, frequency reduction, seed change or new build has been applied.

## Generated interface and artifact identities

[Native build metadata](completion12/project/build_env_db.txt) now records FIM interface UUID **`5c04f735-4245-5537-88d6-380f16bcc372`**. The [FME MIF](completion12/project/fme_id.mif) contains corresponding low/high words, and native log lines 9212–9255 record the normal post-fit interface-ID update and MIF update. This is build metadata, **not current live card identity**.

The existing [W13 persona report](../fim-build-13/persona-build-01/REPORT.md) records interface **`c281e23b-5a95-5aa9-8678-d2ecf1f80f6c`**. That persona is **not a matching Work14 PR artifact**. Do not edit its metadata to force compatibility or use Work14's base green-region RBF as a substitute AHLS persona. Fresh matching release/persona work is still required after the relevant FIM result gate; no finish/package/persona build has been launched here.

Remote artifact root:
`/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_14/syn/board/ia840f/syn_top/output_files/`.

| Artifact | Bytes | SHA256 |
|---|---:|---|
| `ofs_top.sof` | 7,837,547 | `5e4192340cabd6cbf915a857476480988452364b995768de4c5f2753b2293250` |
| `ofs_top.green_region.rbf` | 7,254,016 | `8f34a7285021387de61e1a540a596fd37d0aa827335901d216c5906c157517e1` |
| `ofs_top.green_region.pmsf` | 7,186,783 | `b69d57703c8b3dce597548d41990684c0936ed09a6013deab4708922ece334ce` |
| `ofs_top.static.msf` | 3,269,060 | `baf978a4b5b0b706c897915fddd60f5750134851761bc34b8898db1bb9486746` |

The last two are assembler intermediates, not interchangeable programming images. Artifact sizes/hashes were measured from stable remote ordinary files by the [finite collector](collect_completion12.py); bitstreams were not downloaded or committed. No JIC or AHLS GBS was produced by this compile.

## Remaining gates

1. Independent result/constraint review and source-supported disposition of failures. Preserve these outputs; do not repeat the unchanged compile.
2. Matching FIM/AFU PR interface, source-proven supported OPAE access and reviewed finite live sequence.
3. **Verified independent host recovery** before potentially host-stranding operations. Flash/reboot permission has already been granted; recovery availability is still unanswered.
4. Real discovery/MMIO, both 16 GiB DDR channels independently and simultaneously, numerical host↔DDR transfers, exact repeated/boundary AHLS results, sustained operation and QSPI power-cycle boot.

DDR simulation remains **SKIPPED BY USER**; dummy-CSR exercising remains excluded. No flashing, reboot, live OPAE execution, udev activation or device access occurred. **The standing hardware mission is not complete.**
