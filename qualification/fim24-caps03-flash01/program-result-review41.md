# FINAL — PASS WITH LIMITS

**Accept the original `sdk-program18` programming/readback/comparison gate only. Programming-gate blockers: 0. Activation, deployment and hardware correctness are NOT accepted; `activation=false`, `hardware_ready=false`, `deployment_ready=false`.** This independent review used only local ordinary-file reads, hashes, AST/JSON analysis and raw-log parsing. No project imports, tests, vendor execution, remote access, hardware operation or executable changes occurred.

## Frozen evidence and original-result integrity

Read `program-result-freeze40.json` first. Its actual 2504 bytes have SHA256 **`c72db9536cc5d8858efe8a839e46bbf671d404b72572296342c92213a5626a63`**. Independently verified **15/15 enumerated members** against exact size AND SHA256; declared count15 agrees, **0 mismatches**. This includes the accepted file-package records, original runner, original native/process/result receipts, complete raw program log, target16 result and pre/post ownership evidence. `program-reconciliation39.json` agrees with independently recomputed duration, phases, hashes and unchanged boot; its parent's verdict flags were not substituted for inspection.

Also verified the retained `sdk-program18/envelope.json.gz`: **26084 bytes**, SHA256 **`9d15b038af0622830d62eb0d30a08d0664944ece63141c07fa5655f83f71c774`**. Its batch is `ia840f_capture_b11d33600e604cbab0844039ffc7c599`; **8/8 exports** decode byte-identically to local readbacks and match index/envelope size, SHA256 and original source path, including the additional ownership-before-readiness log. Non-export envelope fields agree with the index projection; transport and index record **outer exit0** (`sdk-program18/transport.json:2–11`, `sdk-program18/index.json:547–591`). Supplemental source/map/RPD checks below are separately identified, not additional members of freeze40.

| Original evidence | Bytes | Independently verified SHA256 |
|---|---:|---|
| `sdk-program18/readback/native-result.json` | 1000 | `4cc52c5d9d424d63a922f78bef03c0d9bc25d9261a4a0bfd07c54d4707aad93b` |
| `sdk-program18/readback/result.json` | 15968 | `10b50059e33bee03639d574ee881b3fbe5836b09fe874d70d52bb846029daf62` |
| `sdk-program18/readback/program.log` | 448203 | `a4e70063fdc90d4a2d08e53a7f32673fb40effa063d261cf3a05b6f19c436490` |

## Actual native invocation and full phase completion

Exactly **one** program command is present. The original native receipt equals the program row in the raw result; every launch/process-receipt field remains identical in the terminal receipt. Actual argv was:

```text
/home/uwb_student00/.local/bin/bw_agilex_flash_programmer -i PCI -c 0 program --force -a 0x00000000 /home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/convert05/migrated-caps03-sdk.rpd
```

Original **PID395622**, start ticks **`60884383`**, executable **`/usr/bin/python3.9`**, cwd **`/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_flash01/sdk-program18`**. The captured interpreter argv starts with `/usr/bin/python3`; this is preserved distinctly from the resolved executable, not normalized (`native-process.json:15–36`, `native-result.json:15–39`, both under `sdk-program18/readback/`). Native start **2026-10-03T20:35:35.983791+00:00**, end **2026-10-03T23:31:12.497355+00:00**, independently calculated duration **10536.513564 seconds**, **native exit0** within the recorded18000-second wait. The runner writes/fsyncs the original native receipt immediately after wait, before fallible log/postflight/export work (`sdk-program18.py:59–79`). All **5/5 recorded command native exits are0**, separately from collector outer0; no bookkeeping, timeout, unknown-execution or capture-error field is present.

Parsed the ENTIRE unchanged raw log, not a tail or display-normalized hash. It contains **10752 carriage returns**, **6 linefeeds**, and no UTF-8 replacement characters. Phase records occur in erase→program→readback order, monotonically from0.0 to final100.0:

| Named native phase | Progress records | Last emitted percentage | Last record starts at raw byte offset |
|---|---:|---:|---:|
| QSPI Erase | 164 | 100.0% | 13402 |
| QSPI Program | 2606 | 100.0% | 229441 |
| QSPI Readback | 2606 | 100.0% | 448087 |

Exactly one **`Flash programmed successfully.`** follows completed readback at raw byte offset **448172**. No refusal, error/fatal, failure, exception/traceback or mismatch diagnostic was found. Preserve the actual absl initialization WARNING and gRPC fork-handler informational preamble: this is **not** a warning-free claim. The complete log, original native0 and source-grounded comparison semantics jointly establish acceptance; neither rounded progress100.0 nor a success substring alone suffices (`result.json:420–429`; raw-log offsets above).

## Actual reviewed SDK source and comparison contract

Locally parsed the proprietary historical capture `../caps01-bwflash01/source01-result.json`, **56091 bytes**, SHA256 **`67f61bac050d149cf00caa6ef5a9c034432598fac07a77d4ecfa9a81120d81b9`**. Independently rehashed all **3/3 embedded source texts**, checked their ASTs, and matched their exact path/hash bindings to the frozen runner's literal `C.sdk_sources`:

| Bound installed path | SHA256 |
|---|---|
| `/home/uwb_student00/.local/bin/bw_agilex_flash_programmer` | `d07c0450ce5a4b6a30bcd8b5ecad8112071ea604b2b762b920e310d89f1b92ac` |
| `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/tools/bw_agilex_flash_programmer.py` | `d114deddc47bd4daf7d0dfa4ca012f5b6e24adb27535a39f3b1c2a86a4351c63` |
| `/home/uwb_student00/.local/lib/python3.9/site-packages/bw_agilex/components/sdm_mailbox.py` | `f51ccfe1804709042dc8c221fbf8c7eca685355d7ff23e09a1a7dc3ab7c31084` |

Source citations here refer to the named embedded files' original line numbers; no proprietary source body is reproduced. Wrapper lines3–6 dispatch to the reviewed programmer. Programmer `handle_program:438–458` uses the transformed input's full length for erase/write/readback and calls `verify_flash` BEFORE printing success. `verify_flash:375–386` rejects unequal lengths and any unequal byte; `get_flash_controller:389–404` selects the SDK SDM mailbox. `--force` bypasses the VFIO slowness refusal, **not** readback/comparison. This path performs QSPI programming, not JTAG loading or an RSU image-update/activation operation.

The runner explicitly hash-checks these installed sources and the RPD before preparation, immediately before native launch, and after native completion; success is set only after these checks and postownership (`sdk-program18.py:41–55,73–79`). Its frozen SHA256 is **`f8c5e6ccb7c67b8e067d0c06ca873bbf68fc4a00b903a11ed503ddf306c0d184`**. Thus recorded actual-run preservation is established, not merely reuse of historical source names. This local review is **not a fresh live installation attestation**, exhaustive dependency audit or OS-enforced sandbox.

## Exact input, affected flash range and readback extent

The package remains the already accepted **complete non-RSU BOOT_INFO plus P1 at0x00000000**, not an RSU user-slot update at0x04000000 (`PACKAGE-ACCEPTANCE13.json:15–18,32–45`, `package-review10.md:21–38`). The runner's accepted-package and target-result hashes exactly match the frozen records. Independently rehashed the supplemental actual local RPD and MAP under `conversion06/readback/`: RPD **10670080 bytes**, SHA256 **`96fb0dc9e0716a712f9e77a09b11161ac495a6e16436beb756bf7fd04874647e`**; MAP **364 bytes**, SHA256 **`818df1df710349adf3b6720508ea3a91481a25162bb3ec304fb4eba3dcc0ffc2`**.

MAP lines3–4,15 give contiguous **byte-addressed** regions: BOOT_INFO **0x00000000..0x001FFFFF**, P1 **0x00200000..0x00A2CFFF**. The input/write/full-payload readback extent is therefore **0x00000000..0x00A2CFFF inclusive**: **10670080 bytes / 2667520 words / 2605 chunks of4096 bytes**. The input is already word/chunk aligned; no additional write/read word padding is needed (`sdm_mailbox.py:754–840`).

Independently checked **256/256 LUT entries** against per-byte bit reversal (`programmer:70–327,338–366`) and applied that LUT in memory to the actual RPD. The unchanged-length writer representation has SHA256 **`f7cc592f86182c792a5a8fdfc1347dfefd3299c538760a1d98e51fb50976772e`**, agreeing with package and actual-run records. This is bit reversal within each byte, not byte-order reversal; the original OFF RPD was the SDK input. **The transformed hash is a deterministic input calculation, not the hash of an independently exported flash dump.** The original SDK's completed full-length byte comparison supplies the readback witness; no separate readback-image export or second verify is claimed.

Recomputed the captured mailbox's **literal** erase arithmetic (`sdm_mailbox.py:207–209,631–678`): sector mask0xFFFF,16384 words/65536 bytes per sector; for this nonaligned byte length the adjustment produces **10633216 bytes**, then the literal integer-converted byte/sector ratio plus one yields **163 sectors**. Erase extent is **0x00000000..0x00A2FFFF inclusive**, **10682368 bytes**. The excess **12288 bytes**, **0x00A2D000..0x00A2FFFF**, are erased sector padding beyond the input. This is not an idealized ceiling substituted for SDK behavior. The163 erase iterations plus initial progress and2605 write/read chunks plus initial progress agree with the actual phase record counts. **Full comparison covers the input extent, NOT this sector padding, NOT the rest of the256MiB flash, and NOT a fresh prewrite backup.**

## Bound target, ownership and unchanged boot

Target16's actual PCI card-list log maps **IA-840F / VFIO index0** to management **0000:4f:00.1**, vendor/device **4794/112 =0x12ba/0x0070**, slot UID **`0000:4e:00.0/4f:00.1`**; its log hash matches the frozen target result (`sdk-target16/readback/result.json:170–203,497–627`). Program18 reuses that exact target result, then checks current cached PCI identities and fresh readiness before writing; it does not silently re-enumerate or create a VF.

Fresh CONFIG_STATUS completed native0 at **20:35:35.717602+00:00**, before the write: `conf_done=init_done=nStatus=nConfig=1`, state/error_details/error_location/seu_error0, **ASx4 Normal** (`sdk-program18/readback/fresh-config-status.log`; `result.json:27–41,291–304`). This qualifies the prewrite mailbox readiness discriminator, not boot of the newly written image; CONFIG_STATUS itself is hardware access, not an ordinary-file read.

All three original root-visible ownership logs byte-match their result objects: before readiness, immediate prewrite **20:35:35.786673+00:00**, and postprogram **23:31:12.618351+00:00** (`result.json:177–289,306–418,430–542`). Each has exactly the same bound daemon **PID395200/start `60597442`**, executable `/usr/bin/bwvfiod_server`, argv `[/usr/bin/bwvfiod_server,-d]`, cwd `/`; service readback is active/running, MainPID395200, ExecMainStatus0. Its only recorded device descriptors are fd10 **`/dev/vfio/vfio`** and fd11 **`/dev/vfio/5`**. No recorded application device holder, resource/device mapping, D-state task or acquisition error exists. Other relevant-process matches are the exact owned batch transport shell/waiter, not blanket exemptions for arbitrary shells.

The locally verified helper SHA256 **`59d48b9f7c906e10e91d4becb0d1e1a446bf3ad51c230aa06e5c5cb4d6beee9f`** matches the runner binding (`os11/readback/ownership.py:5–40`; `sdk-program18.py:31–38`). The supplemental root identity binds the daemon binary to **28127984 bytes**, SHA256 **`cdb4a69e4c89a08f87041fc8b1c2af15568d89480b87e94dfeac664f46ea0246`**, equal to installed RPM metadata (`sdk-binding15/index.json:4–23`; root-identity export hash verified). Preserve earlier binding14's permission failure and package-verification rc1/directory-mode differences: **whole-package verification is false**, not silently converted to a clean RPM result.

All three PCI snapshots are equal: management PF uses vfio-pci and singleton IOMMU group5; application PF **0000:4f:00.0** retains dfl-pci/group4 and **sriov_numvfs=1**; application VF **0000:4f:00.2** retains vfio-pci/group76 and its reverse physfn/virtfn0 relationship. No VF disabling or PCI reconfiguration occurred in this programming recipe. These are scoped root-visible ownership snapshots, **not global PCIe/DMA drain, exhaustive continuous ownership or electrical-quiescence proof**.

Before/after and all ownership records retain boot **`8121620d-a638-42f8-abab-a547aae32076`** (`result.json:117,178,307,431,544`). The original write did not replace running fabric through this source path; no BMC Off/On or host reboot is in the invocation/result. A matching boot ID is not a power-rail measurement or new-image activation witness.

## Retained limits and disposition

- Retained recovery material is the accepted prior/main image at `/home/uwb_student00/ahls/new_BSP/work_caps03_flash01/sdk-convert21/caps03-sdk.rpd`, SHA256 **`0319b7fd35d968d73f02f9a6f49706cb249c3559dec1759a3f2d3a37122e4bcf`**. The original runner verified its hash before the write (`sdk-program18.py:46`; `result.json:170–175`). No new local recovery-file hash check, fresh device backup, whole-flash snapshot or independent recovery availability is claimed.
- Actual new-image activation remains **unperformed**. The expected new static FME/interface UUID **`fc603c44-5c8f-5e94-bcbe-a5780030947c`** is a future activation discriminator, not an observed result of this write (`hardware-reuse-ledger31.md:11`). BMC power-state readbacks, the approved one-boot sequence, new boot/image identity and numerical/DDR/application tests remain separate parent-owned gates.
- Existing STA/CDC/reset/electrical and Power/VID serialization limits remain unchanged. Programming success does not establish bootability, timing closure, reset/clock readiness, memory correctness, AFU correctness or benchmark acceptance.
- Package-review10/acceptance13 remain file-package provenance; this FINAL is programming-result acceptance only, not publication of a program milestone or accelerator-task closure. It does not grant new execution authority or require reflash/second SDK verify to reconstruct evidence. No CLOCK/reset/VF-disable/probe/JTAG/RSU/retry operation was performed or authorized by this review.

**FINAL — PASS WITH LIMITS: 15/15 frozen members and8/8 original exports verified; native0 + outer0 + all three full phases + successful source-defined full-input comparison + exact target/source/input/ownership/boot bindings accepted. Programming-gate blockers0. Activation and hardware qualification remain open.**
