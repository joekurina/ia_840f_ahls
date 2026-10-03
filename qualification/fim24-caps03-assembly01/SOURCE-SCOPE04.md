# Assembly SOURCE/API scope04 — no execution authority

## Qualified predecessor and purpose

The current-FIFO discriminator is accepted with findings after independent327-member result reviews and parent correction/consumption. Actual query63 is complete/spent; no replay or refit is proposed. Reuse accepted final STA/fitted databases for a **standalone persona assembler stage**; GBS packaging remains a separate subsequent offline stage. [CDC acceptance](../fim24-caps03-cdc03/CDC-ACCEPTANCE73.md), [STA numerical acceptance](../fim24-caps03-sta01/NUMERICAL-ACCEPTANCE32.md).

The exact later user approval removing the pre-build pause was recovered from the original user message274635 after pause274629, not inferred from a summary. It does not waive technical stage gates or no-hang requirements. [Recovered approval](../fim24-caps03-cdc03/build-approval-recovered73.json).

## Actual fresh source copy

Remote `/home/uwb_student00/ahls/new_BSP/work_fim24_caps03_assembly01/base01` copies4038 accepted STA entries/1,011,925,993ordinary-file bytes/all733QDB members. Two relative symlink literal targets stay unchanged while resolved roots relocate. Original acceptedSTA/fitted/mapped/setup/release/archive/external/tools/results are reverified. No failed mutable CDC database is reused, no RTL/SDC/image mutation, no runtime gate/controller/admitted manifest or assembler operation exists yet. Existing sourceSTA gate is deliberately still present and would reject assembler use; it is not authority. [Copy03](copy03/index.json), [bound copy](copy03/readback/prepared-copy03.json).

## Installed same-release API

The first no-project help01 call used the hash-bound26.1 launcher but inherited an older Quartus-root selection and displayed25.1.0Build129. Its outer rejection and logs remain intact; they are not26.1 API qualification. The fresh help02 sets explicit `QUARTUS_ROOTDIR_OVERRIDE=/opt/altera/26.1.1/quartus` and a26.1-only tool PATH. Both `--help` and `--help=return_codes` exited0/drained, with no project opening/assembly. Correct native banner is26.1.1Build130 SCProEdition, and launcher/native executable hashes match the accepted current tool bindings. [Rejected help01](help01/index.json), [qualified help02](help02/index.json), [usage](help02/readback/help.log), [return codes](help02/readback/return-codes.log).

Proposed exact assembler invocation, cwd `base01/build/syn/board/ia840f/syn_top`:

```text
/opt/altera/26.1.1/quartus/bin/quartus_asm ofs_top -c ofs_pr_afu
```

Expected native callback identity is the bound26.1.1 `linux64/quartus_asm` with literal project/revision arguments. No full-flow, IP generation, synthesis, fit, STA/Fmax hook, cdb export or programmer is allowed by this future scope. CMake-native configure/custom-target invocation remains required; native success alone is insufficient.

## Minimal runtime changes proposed after SOURCE review

Only the copied PR QSF's two early SOURCE_TCL_SCRIPT_FILE/TEXT_FILE gate references change to a new assembly-specific callback, with two new callback files. Keep36CPUQSF, interfaceUUID, part, imported staticQDB, synthesized/final physical snapshots, PIM/HLS/SDCs/AFU JSON/clocks and source inventories unchanged. New callback will enforce exact executable/hash/argv/cwd plus live owner ancestry, source/snapshot/critical bindings; source/query spent receipts are provenance only. Select stage-owned mutable roles explicitly using the acceptedSTA role map and retained prior assembly observations—not arbitrary `qdb` exclusions. Keep current final-STA reports/user-clock file immutable. [Current PR QSF](copy03/readback/project/ofs_pr_afu.qsf), [historical roles](../ahls-persona-work21-caps01/asm-input-roles01.json), [current copy role basis](copy03/readback/prepared-copy03.json).

Assembler output acceptance must explicitly require **new nonempty SHA-bound `ofs_pr_afu.sof`, `ofs_pr_afu.pmsf`, `ofs_pr_afu.green_region.rbf`**, expected reports/footer/version, callback acceptance, owned drain, all preservation flags and no fatal/rejection diagnostics. Bind before-state images to distinguish inherited static SOF/MSF/PMSF from newly emitted persona outputs. Do not convert or overwrite original static images.

## GBS and deployment boundaries

Bare `quartus_asm` does not execute the PR QSF's POST_FLOW_SCRIPT_FILE `gen_gbs.tcl`; source comments explain it belongs to the full post-flow/explicit script route. Native assembly is therefore not GBS acceptance and the PR-RBF alone is not runtime payload. The selected script constructs packager `create-gbs` using current interface UUID, AFU JSON, completed user_clock_freq numeric100/200MHz metadata and exact green-region RBF. A later separate offline package must use current supported packager schema/CLI, validate container/header/interface/AFU/clock metadata and extract payload byte-for-byte—without rerunning `afu_synth`/fit or opening the project unnecessarily. [Selected gen_gbs](copy03/readback/project/ofs_partial_reconfig/gen_gbs.tcl#L75-L123), [actual user clocks](copy03/readback/project/output_files/user_clock_freq.txt).

Assembly is not hardware, timing, PR/reset or electrical acceptance. Retain+.002nssetup/zerohold-MPW/staticDRC/reset-entry additional3sys7bank0 cycles and four named electrical dispositions. No SDK writer/BMC/reboot/MMIO/runtimePR/FLR/data test is part of this scope. The migration is incomplete. SOURCE review may allow minimal runtime implementation/preparation only; independent QUALITY/fresh exact admission still precede one native assembler operation.
