# Capability persona — completed native setup and mapping; review pending

Setup: outer0,version/setup native/effective0/0;4925inventory entries,7verifiedexports, all preservation/header checks true. Actual OPAE afu_synth_setup against matching Work21release03; no blank-template mode or hardware access.

Synthesis: native/effective/outer0/0/0, full quartus_syn --read_settings_files=on --write_settings_files=off ofs_top -c ofs_pr_afu; PID138522/start15989318,2026-09-23T20:50:21.387511Z to20:54:45.367517Z. All11export payloads independently decoded/size/hash/local-byte verified. ArchiveSHA256 `213bab5472c662ed1da07fda0f66b6931117c18f85471425c9c1e7673f027e9c`. No timeout, descendants or owned survivors; diagnostics/postflight empty, all input/setup/release/tool preservation true.

Native banner:0errors/230warnings. Parsed occurrence ledger:443, including Critical20580 and19854; warning IDs/counts equal the predecessor, not warning clearance. Legacy CSR truncations remain intentionally unchanged and the new host ABI does not rely on those words. [Ledger](warning-ledger-synth01.json).

Fresh fitter prerequisites subsequently captured5373file entries:1133exact accepted runtime-output roles and67protected synthesis paths reused.97PID-qualified clearbox files are new, immutable inputs; no new exclusion. This confirms a usable completed-synthesis copy, not completion or acceptance of fitting. Current fit has its own handoff inCURRENT.md and is excluded from this review.

Full design signoff, reset/CDC/R1/R2/memory lifecycle/electrical/PR and physical OPAE/DDR/numerical/durable-boot criteria remain open. Parent has verified acquisition, not independently accepted this mapped gate yet.
