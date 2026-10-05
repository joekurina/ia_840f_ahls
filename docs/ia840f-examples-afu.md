# IA-840F OFS tutorial AFUs — instructions and results

This supplement covers all eight RTL variants under `examples-afu/tutorial/afu_types/01_pim_ifc/` on the migrated **IA-840F CAPS03 v2.0.0 FIM**, OFS 2026.1 and **Quartus Prime Pro 26.1.1 Build130**. It is separate from the older Work21/Quartus25.1 memory-HLS application guide and from the standalone AHLS GettingStarted samples.

The original six passing gates and the later repaired copy/DMA gates together give **eight scoped hardware passes**. The initial campaign's six-pass/two-failure report remains historical evidence, not the latest result. `PIM_advanced` is README-only and explicitly skipped; it is not a ninth AFU. [Initial campaign](../qualification/examples-afu-01/FINAL-SUMMARY121.md), [repair summary](../qualification/examples-afu-debug-01/FINAL-SUMMARY43.md).

## 1. Results and acceptance limits

| Variant | Recorded native build / final PR / host | Verified check | Acceptance |
|---|---|---|---|
| hello_world / avalon | 0 / 0 / 0 | Full64-byte DMA greeting, NUL and zero padding | [Avalon63](../qualification/examples-afu-01/hello_world-avalon/ACCEPTANCE63.json) |
| hello_world / ccip | 0 / 0 / 0 | Same full greeting through CCI-P mapping | [CCI-P77](../qualification/examples-afu-01/hello_world-ccip/ACCEPTANCE77.json) |
| hello_world / axi | 0 / 0 / 0 | Same full greeting through AXI mapping | [AXI77](../qualification/examples-afu-01/hello_world-axi/ACCEPTANCE77.json) |
| clocks / single | 0 / 0 / 0 | Relative-clock/divider checks; packaged759MHz user target within tolerance | [Clock93](../qualification/examples-afu-01/clocks-single/ACCEPTANCE93.json) |
| local_memory / avalon | 0 / 0 / 0,0 | Commanded-data checks on banks0 and1 | [Memory86](../qualification/examples-afu-01/local_memory-avalon/FINAL-DISPOSITION86.json) |
| local_memory / axi | 0 / 0 / 0,0 | Commanded-data checks on banks0 and1 | [Memory105](../qualification/examples-afu-01/local_memory-axi/ACCEPTANCE105.json) |
| copy_engine / capped | 0 / 0 / 0 | 32×4096bytes, maxreq8, completion1;2048 read/write lines;131072bytes match bitwise NOT | [Copy43](../qualification/examples-afu-debug-01/copy_engine-cap27/FINAL-ACCEPTANCE43.json) |
| dma / corrected+capped | 0 / 0 / 0 | Bank0, one1024byteH2D + one1024byteD2H descriptor, all128words match; no host chunking | [DMA43](../qualification/examples-afu-debug-01/dma-cap27/FINAL-ACCEPTANCE43.json) |

Hello-world is an **MMIO-triggered DMA greeting**, not a literal register write/read roundtrip. Clock470MHz is reference metadata, not independent absolute metrology. Local-memory covers nine nonzero-mask and two zero-mask commanded cases per bank, not full capacity, isolation or sustained traffic. Copy's current byte pattern repeats every256bytes; general fragment-permutation coverage is not established. DMA is aligned full-width WRAP, bank0 and low32IOVAs, not all-bank/performance/error-injection coverage.

## 2. Platform and runtime prerequisites

On the recorded workstation, establish these before hardware use:

- FPGA `AGFB027R25A2E2V`; current FIM interface UUID **`fc603c44-5c8f-5e94-bcbe-a5780030947c`** and the matching retained release `/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01`. Actual platform database selection is `ofs_agilex.ini`, not a fabricated legacy alias. [Export acceptance](../qualification/fim24-pr-platform01/EXPORT-ACCEPTANCE39.md).
- Native OPAE platform/admin tools and matching installed stock tutorial backend/libraries/configuration. These tutorial hosts use the recorded `/etc/opae/opae.cfg`; they are **not** the private strict AHLS startup/module launcher documented in `ia840f-run.md`.
- Verified current PCI identities: recorded PF0 `0000:4f:00.0` uses `dfl-pci`; managementPF1 `.1` and AFUVF0 `.2` use `vfio-pci`. VF0 was in singleton IOMMU group76. These numbers are machine/boot bindings, not automatic discovery rules. Recheck them rather than copying them to another machine.
- No competing programmer/application/device holders or mappings. Run workstation operations inside an owned `tmux`, one card operation at a time, with stdout/stderr and native exit receipts retained. Compiles may overlap; card operations may not.
- Verify configured/free2MiBhuge-page capacity and buffer allocation behavior. The tutorials document more than32huge pages; the checked copy test allocates32source buffers,32destination buffers and a completion buffer, so rounded backend allocations need additional headroom. The recorded machine had2048 free2MiBpages.
- Clock PR requires normal-user access to its exact UIO clock node. The successful gate used a backed-up, targeted UID1000read/write ACL on the verified `/dev/uio0` path; owner/group remained root/root and group/other permissions stayed closed. That ACL is not guaranteed to survive reboot. If inaccessible, record the failure and have an administrator restore only the correctly bound access—do not use broad chmod, forced PR or an unrelated driver change. [Permission evidence](../qualification/examples-afu-01/clocks-single/permission88-collection.json).
- The tested workstation is expected to negotiate Gen3x16. **Gen3 is not a256-byte payload ceiling.** The recorded PF0 configured MPS is256bytes and MRRS512bytes. The capped AFUs are qualified for that configuration; verify the active MPS before using a fixed256-byte cap on another platform.

Per-boot VF creation/binding is separate administrative work. The recorded supported sequence disables PF0autoprobe, creates oneVF, verifies it unbound and isolated, selects its `vfio-pci` override, performs exact-BDF `opae.io init`, verifies ownership/binding and restores autoprobe. Do not recreate an existingVF or rebind PF0 blindly. [Recorded VF setup](../qualification/examples-afu-01/recovery-VF114-collection.json).

## 3. Select the tested artifacts, not the rejected predecessors

Programming images, QDBs, generated collateral, licensed tools, host ELFs and oversized logs are external retained artifacts; they are not in the tag or release download. Reuse the verified images when unchanged. Do not reflash the static FIM to switch tutorials: these are green-region PR loads with `fpgaconf`.

Set these roots **only on the recorded workstation with the verified retained files**:

```bash
E=/home/uwb_student00/ahls/new_BSP/work_examples_afu01
D=/home/uwb_student00/ahls/new_BSP/work_examples_afu_debug01
G=persona/build/syn/board/ia840f/syn_top/output_files/ofs_pr_afu.green_region.gbs
export LIBOPAE_CFGFILE=/etc/opae/opae.cfg
```

| Image beneath the root | SHA256 |
|---|---|
| `$E/hello_world-avalon/$G` | `b3aeb3c6c07febad0aa08f36d17daf7b940cd2328d770323d5e03bf8f8a78bfa` |
| `$E/hello_world-ccip/$G` | `8abc7c85ae311e35bcc1efc92be95a1d5c7cd7685fbc59e20a663d31fa85e4d5` |
| `$E/hello_world-axi/$G` | `2c0335ef2be40e198dd0f728747065bc454259070a59a18342b13faf737b42e3` |
| `$E/clocks-single/$G` | `d29b3c059316aac396fe76ed6cfeaf79698a35919e4c1bb1a4f5fdfacb18ee75` |
| `$E/local_memory-avalon/$G` | `2a1990d4d1c9c3c4fce37406ccd3d869314cf7cb00753145f2940fe7bf494691` |
| `$E/local_memory-axi/$G` | `8954ef02d11c6a9e7c3d5442693dd8606e0679f3f248435a1e3536630cc53bfa` |
| `$D/copy_engine-cap27/$G` | `9ed7a4b6c900505ef555fa6c1dfbda282737d70ba46fc8f34dacd80eb0d583dc` |
| `$D/dma-cap27/$G` | `69c83b336a6b4bae3e0a8fe19b9c197d50fabd125c24893eebaad3768954abe2` |

The three hello variants share an AFU UUID. Copy and DMA also share UUID `11446c9d-aa42-4085-9b3d-4eef9429a4ad`; **UUID alone does not identify the variant or repair**. Bind image hash, source selection and matching host.

## 4. PR loading and command pairs

The following are command fragments from the accepted executions, for a freshly preflighted and supervised operation—not an unattended loop or permission to replay spent qualification scripts. Verify hashes and owner/boot first. Capture PR stdout/stderr/native return separately; only launch the host after PR0 with clean diagnostics. Installed `fpgaconf` can emit an error and later return0, so exit0 alone is insufficient. Require the actual data/frequency checks and host native0 separately.

A single-load logging fragment is:

```bash
# Choose a new directory and one hash-verified image first.
mkdir -m 700 "$TRIAL"
/usr/bin/fpgaconf 0000:4f:00.0 "$IMAGE" \
    >"$TRIAL/pr.stdout" 2>"$TRIAL/pr.stderr"
pr_rc=$?
printf '%s\n' "$pr_rc" >"$TRIAL/pr.native-rc"
# Continue only after pr_rc=0 and both default nonverbose streams are empty.
# Run one selected host below under the current owner-retaining supervisor.
```

These are the exact image/host pairs. Execute **one pair at a time**, screen the load result, and preserve the host receipt before moving to another image:

```bash
# hello-world / Avalon
/usr/bin/fpgaconf 0000:4f:00.0 "$E/hello_world-avalon/$G"
"$E/hello_world-avalon/host21/build/hello_world_checked"

# hello-world / CCI-P
/usr/bin/fpgaconf 0000:4f:00.0 "$E/hello_world-ccip/$G"
"$E/hello_world-avalon/host21/build/hello_world_checked"

# hello-world / AXI
/usr/bin/fpgaconf 0000:4f:00.0 "$E/hello_world-axi/$G"
"$E/hello_world-avalon/host21/build/hello_world_checked"

# clocks: argument is the image's packaged user-clock target, not pClk470
/usr/bin/fpgaconf 0000:4f:00.0 "$E/clocks-single/$G"
"$E/clocks-single/host79/build/clock_freq_test_checked" 759

# local-memory / Avalon, then the two bank checks
/usr/bin/fpgaconf 0000:4f:00.0 "$E/local_memory-avalon/$G"
"$E/local_memory-avalon/host79/build/hello_mem_afu_checked" 0
"$E/local_memory-avalon/host79/build/hello_mem_afu_checked" 1

# local-memory / AXI, reusing the same checked host
/usr/bin/fpgaconf 0000:4f:00.0 "$E/local_memory-axi/$G"
"$E/local_memory-avalon/host79/build/hello_mem_afu_checked" 0
"$E/local_memory-avalon/host79/build/hello_mem_afu_checked" 1

# repaired copy-engine: the inversion-aware host and capped image are required
/usr/bin/fpgaconf 0000:4f:00.0 "$D/copy_engine-cap27/$G"
"$D/copy-host01/build/copy_engine_invert_checked" \
    --chunk-size=4096 --completion-freq=1 --max-reqs=8

# repaired DMA: original checked one-descriptor-per-direction host, capped image
/usr/bin/fpgaconf 0000:4f:00.0 "$D/dma-cap27/$G"
"$E/dma-single-fix73/host75/build/dma_checked"
```

The snapshot command pairs are verified from native receipts, not executed by publication. Do not paste this entire block as an automatic test sequence: a failed/retained owner must be reconciled before another load. Generic `timeout`/kill/retry is not a buffer-lifetime guarantee. The hello/DMA programs can stop and retain uncertain DMA ownership; preserve their PID/resources rather than duplicating or forcibly unpinning the operation.

Expected data markers include:

```text
CHECK greeting_line_bytes=64 PASS
CHECK copy_payload transform=bitwise_not buffers=32 bytes_per_buffer=4096 errors=0 PASS
CHECK DMA roundtrip bank=0 bytes=1024 words=128 errors=0 PASS
```

Clocks must pass its ratio/tolerance checks with the actual packaged759MHz target. Each memory bank must report its correct selection, `NUM_LOCAL_MEM_BANKS = 2`, exactly11 commanded-case pass markers, `Done Running Test`, empty stderr and native0. Do not pass a test solely by counting a substring or seeing a completion counter.

## 5. Sources and native build instructions

Original upstream tutorials remain unchanged. Their checked host alternatives and recorded corrections are in `qualification/examples-afu-01/`; repaired copy/DMA sources are in `qualification/examples-afu-debug-01/`. **Use the capped copy/DMA selections, not the original uncapped images or the diagnostic split-host workaround.**

To reconstruct the repaired source selection in a fresh owned source tree:

1. Start from the recorded tutorial pin `OFS/examples-afu@4a1350e3c9e223d8bac3cb47f756a1d919ef8de1`.
2. For DMA, retain the previously reviewed `dma_read_engine_counted.sv` and `dma_write_engine_retired.sv` contents as the selected read/write engines. Do not replace them with the unfixed originals. [Correction provenance](../qualification/examples-afu-01/dma-single/source-review-consumed73.json).
3. Add shared `packet-cap27/ia840f_host_packet_cap.sv` and the variant's `ofs_plat_afu_cap.sv`. Retain the original top on disk, but select only the alternate top in `sources.txt`. Use the collected source lists and exact before/after hashes in [source delta27](../qualification/examples-afu-debug-01/cap-source27-readback/source-delta27.json).
4. The cap retains the engine's wide burst interface; only its separate mapped sink has BURST_CNT_WIDTH2. Private USER4 preserves response ownership through the existing PIM metadata. Do not simply truncate AxLEN or nest a full mapper's default bit0 NO_REPLY. [Source acceptance29](../qualification/examples-afu-debug-01/CAP-SOURCE-ACCEPTANCE29.json).
5. Build copy with `copy_engine_invert_checked.c`, the captured checked main/header and the native CMake recipe. The identity oracle is wrong for this RTL. The original checked DMA host is retained unchanged; its full1KiB test uses one descriptor per direction.

Explicitly select the current toolchain for a **new prepared native workspace**:

```bash
export QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus
export PATH=/opt/altera/26.1.1/quartus/bin:/opt/altera/26.1.1/quartus/sopc_builder/bin:/usr/bin:/bin
export OPAE_PLATFORM_ROOT=/home/uwb_student00/ahls/new_BSP/work_fim24_pr_platform01/release01
export OPAE_PLATFORM_FPGA_FAMILY=AGILEX
export QUARTUS_VERSION=26.1
export QUARTUS_VERSION_MAJOR=26
unset OPAE_PLATFORM_GEN BBS_LIB_PATH OPAE_PLATFORM_DB_PATH OPAE_AFU_TOP_IFC_DB_PATH
```

Supply installed licenses/tool dependencies privately. The actual CMake flow uses `afu_synth_setup --lib "$OPAE_PLATFORM_ROOT/hw/lib" --sources <selected-sources.txt> <fresh-persona>`, followed by native `quartus_sh --flow compile ofs_top -c ofs_pr_afu` in the prepared project. The recorded CMake entrypoints and host recipes are:

- [Copy persona CMake](../qualification/examples-afu-debug-01/copy_engine-cap27/native-prepared34-readback/cmake-source/CMakeLists.txt)
- [DMA persona CMake](../qualification/examples-afu-debug-01/dma-cap27/native-prepared34-readback/cmake-source/CMakeLists.txt)
- [Copy host CMake](../qualification/examples-afu-debug-01/copy-host-build01-readback/copy-host01/CMakeLists.txt)
- [Original checked DMA host CMake](../qualification/examples-afu-01/dma-single/host-build75-readback/host75/CMakeLists.txt)

With a **fresh correctly materialized source/CMake tree**, the native target sequence is:

```bash
cmake -S "$SOURCE" -B "$BUILD"
cmake --build "$BUILD" --target setup --parallel 1 --verbose
# Rebind the generated export callback to the current source-bound compile
# context, then verify the complete inputs/tools/static QDB before compile.
cmake --build "$BUILD" --target compile --parallel 1 --verbose
```

`SOURCE`/`BUILD` here designate a new prepared persona CMake tree, not the stock tutorial `Makefile` or an arbitrary checkout. The retained export carries a spent callback and the captured per-run gates bind PID/start/cwd/input/tool identities; those claims and completed roots cannot be replayed. Fresh preparation/rebinding is required before a new native compile. The captured CMake recipes contain absolute workspace paths; no undocumented relocation cache switches are supplied.

**A clean release/tag checkout is not a self-contained FPGA build kit.** It lacks the matching static QDB/template, complete generated platform/IP collateral, installed licensed tools/runtime, programming images and reusable preparation/issuance payloads. The successful native snapshots establish command equivalence and source selection—not a promise that a tag archive plus Quartus alone reproduces the full build. Reuse the tested retained GBS artifacts when unchanged, and do not bypass a native guard to compensate for missing workspace preparation.

## 6. Remaining warnings and release provenance

The final repaired copy/DMA runs still logged VFIO `timed out waiting for pending transaction; performing function level reset anyway` at boot-relative7639.887118/7779.246637. Both hosts exited0 and scoped ordinary ownership was empty, but hardware drain/reset safety/future health are not established. Read-RRESP observability and intermediate-BRESP aggregation remain incomplete; no warning suppression or generic reset waiver is implied. [Repair limits](../qualification/examples-afu-debug-01/FINAL-SUMMARY43.md#remaining-limitations).

The original `ia840f-caps03-v2.0.0` tag remains the historical migration snapshot. These tutorial/repair documents and sources are a **post-tag release supplement**, linked to their exact publication commits and attached assets in the latest GitHub release. The original tag's generated source archives do not acquire later commits merely because release notes are edited. Use the release supplement's pinned checkout for these instructions/results. No FPGA build, load, flash or reboot was performed to publish the supplement.
