# Work12 header stage and subsequent compile handoff

Status: candidate only; no authorization issued, no vendor stage started, readiness false. Independent spec review followed by quality review must inspect this package before the parent consumes reviews.

## Stage 1: fresh native headers

Remote root: `/home/uwb_student00/ahls/new_BSP/qualification/fim-build-12`.
WORK: `/home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12`.
SOURCE: `/home/uwb_student00/ahls/new_BSP/ofs-agx7-pcie-attach`.
All operations must remain in fresh windows of owned tmux `ia840f_mailbox_monitored_01`, host Agilex7Workstation UID1000. Normal user only.

`header-authorization.draft.json` binds actual PREHEADER inputs, not future outputs. Eight output paths must be absent at launch and emitted nonempty with fresh mtimes. They include all four memory wrapper files, aggregate header, wrapper include Tcl, local-memory header and ASP preset. The entire old memory subtree and old project configuration directory were archived, eliminating stale-memory mtime skips. Non-memory wrapper skips remain allowed against unchanged accepted IPs; deleting the aggregate config directory causes its native configuration exports to be refreshed.

The exact native command is the installed `/opt/altera/26.1.1/quartus/bin/quartus_sh -t /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12/ofs-common/scripts/common/syn/ip_get_cfg/gen_ofs_ip_cfg_db.tcl --project=ofs_top --revision=ofs_top`, cwd WORK/syn/board/ia840f/syn_top. No project-IP enumeration or IP regeneration is authorized here. `run_headers.py` sets exact 26.1.1 PATH/license and WORK OFS_ROOTDIR; standalone invocation must be `python3 -B <remote-root>/run_headers.py` from that project cwd, after issue.

Independent reviews must each set accepted=true and `files` equal the exact `review-package-sha256.json` mapping. Envelope keys: `spec_review`, `quality_review`. No accepted envelope is supplied by preparation. After actual independent acceptance, parent stages an exact envelope and invokes `python3 -B <remote-root>/issue_headers.py <absolute-envelope-path>` inside owned tmux. Issuer verifies current full SOURCE/PIM/dependency/WORK/package bindings, consumes an exclusive lock, backs up changed source, then installs only the three reviewed gate candidate changes and issues header-only authorization. It does not launch Quartus. No SOURCE overlay has yet been integrated.

The callback dispatcher recognizes only the exact header argv in the exact Work12 project cwd, then enforces executable/hash/context plus ancestry of the exclusive live Python runner. Other Work12 callbacks route through the unchanged compile grammar and still require absent compile authorization. Trusted vendor qsys-script children invoked by the source-pinned exporter are not OS-sandboxed. Gates do not defend against an operator editing them or their authorization.

`header-run/` is exclusive. The runner preserves native status, logs, output hashes and postheader WORK inventory; propagates nonzero rc and rejects gate markers, Error/Fatal diagnostics, Critical Warning or absent/stale outputs. Review actual native output before accepting headers. Native QSF migration may occur: preserve SOURCE baseline bytes and retain exact WORK diff, not a false byte-equality claim after project open.

## Stage 2: final compile binding AFTER reviewed header result

The exact unchanged Work11 full-flow grammar, mechanically Work12-retargeted, is `compile-contexts.json` (135 executable/argv/cwd/hash entries). `launch_native_compile.py` is the exact Work11 runner retarget, not executed. Native entry remains `./ofs-common/scripts/common/syn/build_top.sh --stage=compile -k -p ia840f /home/uwb_student00/ahls/new_BSP/work_ia840f_fim_12` from SOURCE, with the runner's 26.1.1 environment, exclusive run directory and native claim.

There is deliberately NO `compile-authorization.draft.json` or issued compile record now. `compile-context-fixture.json` contains preheader bytes solely for inert tests; NEVER issue it or rename it into authorization. Header-generated files, wrapper changes and possible native QSF migration are not known before execution.

After accepted headers, capture complete live WORK inventory anew, SOURCE/PIM/dependencies and tools; verify the header output/status/claim/invocation record hashes and compare corrected memory and non-memory baseline. Create the real compile draft using maintained Work12 compile gate `allowed_commands()` and `work_inventory()`, binding the header result and complete postheader inventory. Reuse Work11 issuer semantics only after updating its old review classification: the original issuer assumes historical Work05 repair subsets and must not be blindly applied to this header-only package. Source integration may already have occurred for Stage 1; do not reapply stale before-source hashes or reuse a consumed authorization. Parent independently reviews the postheader compile draft/issuer/runner then issues once. No further parameter research, DDR simulation or project query is required by this package.

Full compilation is not part of header execution. Preserve hold ON, SEED 2, maximum placement, PLL/PF/BAR/geometry/application/calibration routing. Read full fit/STA/assembly reports and programming-artifact hashes; an exit-zero image does not establish timing/constraint/functional readiness or permission to program hardware.

## Evidence boundaries

`memory-closure-complete.json` supersedes the narrower first `memory-closure.json`: complete QIP *_FILE grammar includes SOURCE_FILE HEX, SDC_ENTITY_FILE and TCL_ENTITY_FILE. It resolves 12 QIPs and 210 references, including all generated HEX/SDC files. Project saved-IP selection is statically evidenced by its existing enumerated IP assignment and matching project includes; this is not a new native project-load result.

Local-to-remote transport initially indented an embedded multiline replacement literal, causing a preparation assertion before draft publication. `assemble.log` preserves this failure; `assemble-resume.log` records exact-byte-checked continuation after transport was corrected to exec the original source string. No authorization or vendor attempt was consumed. Initial staging-receipt/preheader inventory precedes addition of the header gate; final header draft and final-verification inventory supersede it for launch.

No Query04/equivalent, DDR simulation, hardware, installation, permission change, protected-RTL/binary patch, commit or push is authorized or performed.
