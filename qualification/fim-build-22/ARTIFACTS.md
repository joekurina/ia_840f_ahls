# Work22 artifact storage and publication

The [generation/header acceptance](IP-GENERATION-ACCEPTANCE35.md) is a completed evidence gate, not a deployable image or a clean-checkout build recipe. Full compile and later results have separate acceptance.

The publication manifest lists the exact included files and their SHA256/Git blob identities. No file over **2,000,000 bytes**, licensed executable, license content, programming image, embedded transfer payload or internal agent transcript is included.

Raw `*-result.json.gz` transport captures and complete `*-readback/` trees remain local-only. Their collection receipts and per-file plans bind the retained bytes. Reviews may cite those local artifact paths; a missing GitHub file is not a claim that its bytes are included. Only the exact small native-log/status/inventory captures named in the publication manifest are exceptions to the readback-directory exclusion. Generated RTL and complete IP/tool metadata remain local-only; neither a hash nor a source-generation pass qualifies hardware.

Remote original artifacts are under `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-22` and the fresh `work_ia840f_fim_22`. Local verified copies are under this qualification directory. Do not regenerate an unchanged accepted artifact merely because its raw payload is excluded from Git.

`CURRENT.md`, active-job snapshots, compile-only preparation and live compile outputs are deliberately outside the completed-generation acceptance commit. Consult the local current checkpoint and exact operation status before resuming, never an old notification or an immutable report's historical pending wording.
