# u03 implementation handoff — NOT_APPROVED

Only u03 is owned by this work. Consumed u02 and all surrounding records are
preserved; before/after evidence records their bytes and metadata.

The preflight production change is exactly ROOT u02 -> u03, requested tmux
format tabs -> printable pipes, expected stdout tabs -> pipes. No identity value
changes. No relaxed whitespace parsing or fallback. The same exact byte equality
and failure remain before any bwrap query or fixture claim.

The copied runner is renamed run_local_u03.py, its output directory is fresh,
and its misleading docstring is corrected: it invokes the CLI with the unapproved
template but does not reach host/tool discovery or a preflight fixture claim.
The runner adds test_tmux_identity to the unchanged existing regression groups.
The existing root expectation is updated; payload, B1/B2, roles and limits remain.

No installed-tool, remote, namespace, vendor or staging action was performed.
Only local inert tests and Python 3.9 grammar validation are in scope. Actual
interpreter version and exact results are recorded by the runner. Future tmux
pipe output is an expectation, not remotely verified evidence. This correction
does not establish sandbox qualification or readiness.

Independent spec review, then independent quality review, remain required before
any parent decision. No review verdict, filled input, approval or execution
decision is created by the implementer. NOT_APPROVED; authorization=false,
ready_for_build=false, vendor_run=false.
