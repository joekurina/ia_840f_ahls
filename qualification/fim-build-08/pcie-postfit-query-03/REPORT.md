# Query03 — focused SPEC re-review requested; NOT LAUNCHED

Successor of query02, with only isolated copies changed. Remote session ia840f_mailbox_monitored_01, owned window query03_prepare, pane %361; host/UID asserted Agilex7Workstation/1000.

- S1: exclusive claim now contains live PID, start ticks, executable, exact argv/cwd and ppid. Callback requires the claimed live runner in its ancestry, retaining original exact STA context and file/link/auth checks. Runner command: python3 -B <query03>/run-query.py, cwd <query03>.
- S2: bounded divider cell/pin directions, explicit aliases/unavailable counts, clock-input fanin traversal stopping at clock targets, driving PLL source name and full source clock/master/period; output target-clock counts include zero. Proposed-only output period uses twice actual input period. Ambiguous/non-CSR input rejects. No generated clock or cut. Fitted mode explicitly unavailable through captured STA APIs, not inferred from 2x. Vendor divide-by-two evidence remains separate.
- S3: exact/hierarchical TRS resource/clock counts, oscillator-type inventory including renamed resources, distinct unrelated oscillator names, successful inventory-end marker.

Grounding: query01/api-help2.log installed 26.1.1 help, lines 450–557 pin/cell APIs, 689–743 clock properties/target collections, 772–858 fanin traversal and get_node_info example. query01/atoms-help.log records unsupported atom API; no guessed fitted-mode property. Existing captured help reused: no new vendor invocation.

Tests: five inert ancestry fixtures (positive descendant; stale ticks, wrong argv, unrelated and absent identities rejected). Actual remote runner and dispatcher both reject missing authorization rc1, before claim/log. Tcl exercised using tkinter Tcl interpreter with mocked collections: divider input period preserved, doubled only as proposed output, zero output clocks and exact alias distinction; unrelated input rejects. Mock results are not fitted-netlist evidence. Native API behavior remains NOT_RUN.

Complete query02 scratch and PIM copied and hash/link inventories verified before retargeting; donor inventories checked unchanged afterward. Full Work08 before/after inventories match. Work09 and maintained gates not edited. Remote tests.json records checks. Export envelope SHA256: 36bdc297d1fa136ef02b64dc881489ceb6ce7c6e1cb14b374be5590623a6596d.

Candidate remains approved=false and ready_for_build=false; no authorization created. Review residual native assumptions: stop-at-clock fanin can return unavailable/ambiguous endpoints, causing rejection; target-associated output clocks are not a claim of all propagated clocks. No PCIe relationship, TRS absence, timing closure or readiness conclusion yet.

Artifacts: candidate.json, query.tcl, run-query.py, ia840f_query03_gate.py, isolated ia840f_experimental_gate.py, tests.json, ancestry-tests.json, query-fixture.tcl, query-fixture-result.txt, hashes.json, prepare-remote.py. Local /home/joe/query03-build.py records preparation/ancestry fixtures. Preparation transport initially exceeded tmux command size; compressed transport succeeded. A final update quoting error was corrected before execution. No vendor tools were launched.
