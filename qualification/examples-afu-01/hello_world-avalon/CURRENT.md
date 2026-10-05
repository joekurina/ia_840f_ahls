# hello_world / Avalon — end-to-end FPGA Test accepted

Authoritative campaign ownership/next action: [parent CURRENT](../CURRENT.md). This example has no active job. FINAL `deleg_7b6cb3bd` task0 **ACCEPTS** the end-to-end gate: native build/PR/host0/0/0, complete64-byte greeting verification and clear scoped postflight ownership. [Acceptance63](ACCEPTANCE63.json), [receipts57](host-only-result57-collection.json), [end-to-end summary](end-to-end-summary57.json). The user-authorized host-only correction did not repeat PR/rebuild/explicitreset/rebind; prior rawfalse/null receipt remains unchanged.

## Exact build

Source list: `examples-afu/tutorial/afu_types/01_pim_ifc/hello_world/hw/rtl/avalon/sources.txt`. Original tutorial RTL/source tree unchanged; matching migrated Work24 release and static QDB selected. [Target source/tree hashes](../targets28.json), [source manifest](../tutorial-source-manifest03.json).

Fresh remote root: `/home/uwb_student00/ahls/new_BSP/work_examples_afu01/hello_world-avalon`. Explicit Quartus26.1.1 Build130 root/PATH, inherited license values kept private. CMake configure/setup0; native target:

```text
cmake --build <root>/cmake-build --target compile --parallel 1 --verbose
# Native CMake target invokes:
/opt/altera/26.1.1/quartus/bin/quartus_sh --flow compile ofs_top -c ofs_pr_afu
# cwd: <root>/persona/build/syn/board/ia840f/syn_top
```

Native/effective/terminal0/0/true; all23bound inputs preserved. [Raw receipt](compile-artifacts31-readback/compile-result.json), [callback delta](compile-artifacts31-readback/callback-delta07.patch), [native CMake](compile-artifacts31-readback/cmake-source/CMakeLists.txt). Source-only normal-account guard is not an OS sandbox. Original retained release/guards were untouched.

New `output_files/ofs_pr_afu.green_region.gbs`:7139655bytes, SHA256 `b3aeb3c6c07febad0aa08f36d17daf7b940cd2328d770323d5e03bf8f8a78bfa`. Interface UUID `fc603c44-5c8f-5e94-bcbe-a5780030947c`; AFU UUID `c6aa954a-9b91-4a37-abc1-1d9f0709dcc3`. Payload matches newly assembled native PR RBF exactly. [Metadata](compile-artifacts31-readback/gbs-info30.log), [build summary](build-summary32.json). Base `ofs_top` images are inherited static artifacts, not new tutorial images.

Synthesis/fitter/STA/assembler each report0errors, with65/188/181/19warnings retained.635native OFS timing-summary records are nonnegative; native failure summary empty. No full DRC/CDC/unconstrained/reset/hardware clearance is asserted. Full compile log2526296bytes remains remote-only, SHA256 `ef8cb0ab15bd35697dd342a3142368fa70c4da2fd740b3437e1fccba0e5e2bc4`. [16-member capture/hash references](compile-artifacts31-collection.json).

## Host readiness, not hardware acceptance

Original tutorial performs MMIO-triggered DMA greeting, not an MMIO write/read roundtrip. Preserve original host; [alternative checked host](hello_world_checked.c) and [exact diff](hello_world_checked.patch) were independently accepted for build. [Review consumption](host-review-consumed21.json). Native host CMake configure/build0; binary SHA256 `2d2a32a013e7ab47d194b58a90a629c02b6bb07cb48b85d6ed1b57bc672c6bf3`.

[Inert host13/13](host-inert-result22.json) and [supervisor-method3/3](supervisor-inert-result36.json) are software fixtures only, not card results. Full64-byte greeting/NUL/zero-padding verification; finite poll/deadline; uncertain post-submit failures retain/park original owner instead of unmapping/killing/retrying. Cleanup-error parking is not proof the buffer/handle is still intact after cleanup begins.

[Proposal37](hardware-proposal37.json) remains preserved rejected/false/unissued. [Successor38](hardware-proposal38.json) changes only the runner hash/status for the [diagnostic guard](hardware-runner38.patch): EXITED0 and empty captured load stdout/stderr before host launch. Six synthetic diagnostic cases pass; no hardware results are fabricated. [Frozen successor manifest](prehardware-review-manifest38.json). Runner/proposal staged with exact hash readback and missing-authority rejection before trial creation. [Stage40](hardware-stage40-collection.json).

One default plain-user fpgaconf and one conditional checked-host run are still the proposed scope, with no force, reset/rebind, automatic retry, timeout kill or system permission/config/driver change. Current standalone-VF topology may fail the default xfpga child-accelerator availability check; preserve that result rather than forcing a load.

## Verdict

**PASS at the named example scope**, independently accepted. [Manifest57](end-to-end-review-manifest57.json). Four transientD samples in the successful correction are retained metadata. Prior partial-result review and failed/null receipt are unchanged. Accepted-example publication is performed separately; this is not blanket reset/DRC/CDC/no-hang qualification.
