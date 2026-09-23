# Work19 independent result review 01

## Verdict

**ACCEPT — fidelity of the failed Work19 result evidence and the bounded Python-environment remedy evidence. REJECT — any interpretation of Work19 as an accepted compile or synthesis, license-checkout, fitter, timing, assembly, or hardware success.**

Work19 remains **FAILED / SPENT**. The observed failure is an actual Quartus 25.1 / host-Python OpenSSL loader collision, not an RTL or timing result. The captured no-project native experiment supports removing `LD_LIBRARY_PATH` only for the two identified Python subprocess calls. It does not prove successful execution of a full corrected callback or the complete successor build.

This is result-evidence acceptance, **not a new Work20 launch gate**, authorization, or source/gate approval. Work20's already-authorized native iteration is not reopened by this review.

## Scope and evidence integrity

Local-only inspection of `/home/joe/Projects/Thesis/AHLS/new_bsp/new/qualification`. No SSH, vendor-tool execution, hardware operation, source edit, gate-state update, or git operation was performed. The sole authored project file is this report.

- Read `result-review-freeze01.json` first and independently recomputed every listed SHA256: **9/9 match**. Freeze SHA256: `f2334fdd8a6026e89e518cac9a4f48f6c056d6f9af9560e1c96cbb46df6df574`.
- Read `RESULT.md`, the complete parsed stop/status JSON records, diagnostic source, and the full captured native-log bytes. Scanned all **4,423 lines / 1,417,839 bytes**, rather than relying on the startup tail. Native-log SHA256: `cd10bf85ac3e220ada5627ab47fe6d93ef35a821392f0e9cd4709b6a182f2f4c`.
- Decoded all **6** file payloads in `python-env-diagnostic01.json.gz`; every declared byte count/hash matches, and all six match their `failure-readback01` copies. The embedded issued authorization matches the final status's `2857a86b1afc244af7b7b2d59f0945dfa36dd5a8dd80ba1497e0f3f5fadd1b7e` binding.
- Decoded and checked all **20** Work19 preparation members and **24** Work20 preparation members against their declared size/hash and corresponding `prepared-readback01` files; all match. These are captured preparation checks, not a fresh remote filesystem audit.

## Actual native failure

References below use `failure-readback01/home/uwb_student00/ahls/new_BSP/qualification/fim-build-19/run/native.log` line numbers.

1. The rejection appears immediately at **lines 3–9**, before the main Quartus banner, and repeats during project loading and the post-IP callback. `RESULT.md` correctly identifies an affected post-IP callback but should not be read as saying that was the first failure.
2. **Lines 11–29** identify Quartus **25.1.0 Build 129 03/26/2025 SC Pro Edition**, process 80615, executing `quartus_sh --flow compile ofs_top -c ofs_top` in the Work19 project.
3. `_hashlib` import fails because `/opt/altera/25.1/quartus/linux64/libcrypto.so.3` does not provide `OPENSSL_3.4.0`, required by `/usr/lib64/python3.9/lib-dynload/_hashlib.cpython-39-x86_64-linux-gnu.so`. The traceback occurs before the Python gate can perform its validation; this is an infrastructure failure, not a successful validation of a rejected design.
4. Five Critical Warning **125091** occurrences are at **45, 64, 352, 373, 399**. Quartus downgraded the Tcl exception and continued. The IP-generation success at **337** and post-module shell success at **390–391** do not cancel these failures. Actual synthesis startup follows at **415–419**, with later HDL analysis messages.
5. The captured stream ends during HDL analysis, with a partial final line and no final newline. It is the complete captured file, **not a completed synthesis report**. Additional native warning lines include three 13461 parameter-declaration warnings and two 16752 potential-always-loop warnings; their harmlessness is not established here.

The startup snapshot `status01.json` is dated `2026-09-23T04:49:45.327916+00:00`; its embedded state is still `running`, and its log tail occurs verbatim in the final capture. The later final `run/status.json` supersedes that historical state: start `2026-09-23T04:49:10.181792+00:00`, end `2026-09-23T04:50:39.492267+00:00`, `native_returncode=-15`, `gate_rejection=true`, `native_exit_accepted=false`, `functional_acceptance=false`. `run/native-status.json` independently agrees on `-15`. `accepted_execution=true` records authorization to execute, not result acceptance. The persisted `PENDING REPORT REVIEW` label is historical and does not override this failed-result disposition.

**Exit-status precision:** `native_returncode=-15` is the runner's directly waited `build_top.sh` child status, not an independently captured exit code for every Quartus subprocess. The preserved runner converts negative signal status with `128-rc`, giving **143** here. Thus RESULT's outer143 is consistent with the inspected runner, but the frozen package does not contain a separate outer-shell wait receipt.

## Termination evidence

`stop-failed01.json` records the stop initiated at `2026-09-23T04:50:39.417186+00:00`, six identity-recorded processes, and SIGTERM deliveries to 80643, 80615, 80614, 80607, 80606, and 80598. All six executable/argv/cwd/start-tick identities agree with the earlier startup snapshot. The root is exactly the Work19 `build_top.sh` process; the set includes the native synthesis and flow processes, the Python gate launcher, shell, and tee.

Read-only inspection of `stop-failed01.py` confirms exact root executable/argv/cwd/start checks, descendant collection, `pidfd_open`, start-tick rechecking, and signaling through pidfds. The captured result says `termination_confirmed=true` and `remaining_owned_non_zombies=[]`; no successful SIGKILL delivery is recorded. The later diagnostic also records `active_native=[]`.

**Bounded interpretation:** the stop script's final check revisits its captured pidfd-bound identities; it is not an unlimited descendant audit. The later empty Quartus/qsys process census corroborates native-tool termination but is not a claim that every possible process on the workstation was examined. Accept the recorded owned-tree termination, not a general supervisor guarantee or a fresh live-host assertion.

Supplemental stop-script SHA256 (outside the original nine-file freeze): `c94b17af1113af046d64f9deb237a4a0de13028e9264d111b25dd2c875314c4f`. Preserved runner SHA256, bound within preparation: `ada89628fb735a69880760da45b8916fea52b49485c57c43eb06eac61323168c`.

## Bounded remedy evidence

`python-env-diagnostic01.py:6–16` constructs a fresh no-project `quartus_sh -t probe.tcl` run. It invokes the same `/usr/bin/python3` probe twice, changing only the second invocation to `/usr/bin/env -u LD_LIBRARY_PATH /usr/bin/python3`. The captured native output identifies the same Quartus release and records:

- Inherited `LD_LIBRARY_PATH=/opt/altera/25.1/quartus/linux64:/opt/gurobi1301/linux64/lib:/opt/gurobi1301/linux64/lib`.
- **RAW_RC=1** with the same `_hashlib` / `OPENSSL_3.4.0` failure.
- **CLEAN_RC=0** after `import hashlib,uuid,ssl`, with SHA256(`test`) `9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08`, DNS UUID5(`test`) `4be0643f-1d98-573b-97cd-ca98a65347dd`, and `OpenSSL 3.5.8 25 Aug 2026`.
- Diagnostic Quartus process return code **0**, successful script evaluation, and zero reported errors/warnings.

The digest and UUID were independently recomputed locally and match. **RAW_RC/CLEAN_RC are Tcl `catch` statuses**, not separately captured numeric Python wait statuses; raw error versus clean success is directly supported nonetheless. This was a real native diagnostic, not an inert fixture. No vendor/Python/system-library installation change or global environment change is part of the demonstrated remedy.

The diagnostic inventories lines containing `python` in `*.tcl` under the maintained `syn`, `ofs-common/scripts`, `ipss`, and `src` subtrees. It finds exactly the gate invocation and `update_fme_ifc_id.py` invocation. That is a bounded source-call inventory, not a universal inventory of vendor/generated Tcl, shell scripts, or dynamically constructed Python commands.

## Work20 remedy-delta corroboration (read-only)

Work20 preparation archive SHA256: `7d32423bbeac4ef855cbe9acb5447190826a2552d0ee0ac82ff7cda770b4b1d1`. Its package manifest is `31e536c7e66976487561a4ee99c1d243798ae00dc2413b29da8d0482b607b3b7`.

Independent byte comparisons establish:

- `callback-copy/build_gate.tcl:6` changes only `exec python3` to `exec /usr/bin/env -u LD_LIBRARY_PATH python3`. New SHA256: `69a11ed228ea07d7d1f6e9be4cf9bd0548f58e5d05e7f5d9f5e7c48659077fff`.
- `callback-copy/ofs_post_module_script_fim.tcl:76` adds the same prefix only to the FME-ID Python command list. New SHA256: `ab3ccd35a5af39fd6faccdaa69456b26ace04a8791728e276b787f345d7455da`. This branch is post-fit and was not exercised by the failed Work19 synthesis startup.
- Both Python gate files differ only by Work19-to-Work20 work/evidence-root retargets. The full source-inventory delta between the issued Work19 record and Work20 prepared draft is exactly those **four files**.
- Both recorded work inventories contain **5,424** identical member names. Exactly **six** entries differ: those four files plus two fresh-root symlink retargets (`config_env.tcl` and `mem_ss.ip`). All other recorded entries match. PIM inventories and outer/inner tool bindings match. All **135** native contexts match after only the work-root retarget.
- Candidate QSF and SDC are byte-identical across Work19 and Work20: QSF `e2c086964c5202ee4ecb02fc08b132c493cdf5bf419d30313f1a798ed25ca98f`; SDC `3114ebbe41a5ebfba0e2c266135fa45ff3825f884512a90cb394327ceb804814`. The captured preparation verifies copying from preserved Work18 and records original Work18/PIM unchanged. These findings support unchanged design inputs, not new synthesis/timing qualification.

The two callback edits leave the calling Quartus environment and all non-Python Quartus invocations unchanged. They retain existing error reporting and validation logic; they do not fix the broader fact that Quartus may downgrade a later Tcl failure. Actual successor callback behavior remains a native-result question, not grounds for another review framework or a new launch barrier.

## Final disposition

No evidence-integrity mismatch found. Accept the retained failed attempt, its recorded termination, the native reproduction, and the narrowly supported subprocess-environment correction. Preserve Work19 as spent. Do not claim synthesis completion, license-feature acceptance, hold/setup closure, fit/assembly success, DDR/calibration acceptance, or hardware readiness from this package. No further operation is authorized or performed by this review.
