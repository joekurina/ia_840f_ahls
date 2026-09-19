# Work10 EMIF0 targeted combinational duplication — bounded disposition

## Decision

**NO BUILDABLE TARGETED-DUPLICATION CANDIDATE. Stop this branch at the pre-fit mapping gap.** CODE_IDENTIFIER exists in the installed 26.1.1 assignment library and its documented syntax is identifiable, but the available reports do not establish the source node and destination edge at the phase where this assignment is applied. No QSF patch is emitted. This is not a claim that manual duplication is unsupported on all Agilex designs.

There is useful new evidence: the synthesis report identifies the original destination register and an existing Maximum Fan-Out assignment of 8, with 156 inserted logic cells/copies reported for EMIF0 CODE_IDENTIFIER. Thus the synthesis duplication is not merely inferred from CODE_IDENTIFIER spelling. The combinational driver's pre-fit identity remains missing.

## Exact syntax and what it establishes

The official **26.1.1 Pro Settings File Reference** search-index excerpt gives this literal syntax and says the value must be a node name:[1]

```text
set_instance_assignment -name DUPLICATE_ATOM -from <from> -to <to> -entity <entity name> <value>
```

This is a documentation template, **not an executable candidate**. The installed CODE_IDENTIFIER contains both CODE_IDENTIFIER and CODE_IDENTIFIER, plus:

> Directs the Compiler to duplicate the source node, and uses the new duplicate node to fan out to the destination node; the original source node no longer fans out to the destination node. Use the 'Value' field to specify the name of the duplicate node.

Consequently the value is the new node's name, not CODE_IDENTIFIER, a fanout threshold, or a requested copy count. The latter belongs to the separate CODE_IDENTIFIER help. CODE_IDENTIFIER and CODE_IDENTIFIER require a valid connected source/destination pair; naming the final physical output is not evidence that the pair resolves at the assignment's application stage. No entity, wildcard, source alias or destination group is invented here.

**Evidence limitation:** full-page web extraction timed out (504); the browser returned only the site's navigation shell. The exact syntax above is supported by the official search excerpt, corroborated semantically by installed help, not by native project-load acceptance. An additional device-support search returned a truncated 26.1 excerpt, insufficient to certify exact 26.1.1 family/stage/node-type applicability. Installed option presence alone does not close that applicability gap.

## Source/destination mapping: established versus missing

All abbreviated names below share the actual prefix:

```text
local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|msa_0|msa_0|msa_adapter|wrreq_bank_spreading|
```

| Item | Evidence | Disposition |
|---|---|---|
| Failing final physical driver | Full STA line 156242: CODE_IDENTIFIER, fanout 52 | Proven fitted target, not an assignment target |
| Logical-looking fitted atom | Fitter lines 41638–41640 show CODE_IDENTIFIER, CODE_IDENTIFIER, then the same physical output | Links fitted logical and physical representations only; does not prove pre-fit existence |
| Fitted destination | STA lines 156243–156244: CODE_IDENTIFIER, 0.273 ns incoming IC | Exact failing sink |
| Related fitter sink | Fitter lines 41649–41650 show CODE_IDENTIFIER and the register | Similar names across reports do not authorize deleting CODE_IDENTIFIER or other suffixes |
| Original synthesis destination | Synthesis line 98970 names CODE_IDENTIFIER with assignment 8 and 156 inserted cells; line 125592 explicitly reports Info 18058 and source CODE_IDENTIFIER | Original destination provenance established; report abbreviates the duplicate list, so it does not enumerate the exact sink edge/group needed here |
| Pre-fit combinational source | Entire CODE_IDENTIFIER and CODE_IDENTIFIER searched for literal CODE_IDENTIFIER: zero hits in each | Not established; absence from reports is not proof of absence from the netlist |

The original destination name by itself cannot resolve which of its synthesis duplicates should be driven by the new combinational copy, nor prove that any proposed source drives it when CODE_IDENTIFIER takes effect. Do not strip CODE_IDENTIFIER, CODE_IDENTIFIER, CODE_IDENTIFIER, or CODE_IDENTIFIER to manufacture a source/sink mapping.

The Work10 baseline remains EMIF0 setup WNS -0.508 ns, 10 levels, 1.904 ns interconnect and 1.312 ns cell delay. The launch register fanout is 9, distinct from the final combinational driver's fanout 52. Manual launch-register duplication and more destination-register duplication are therefore not substitutes for the requested targeted combinational experiment.

## Finite actionable next step

**Do not allocate a compile to this assignment from the current evidence.** For this branch to reopen, obtain one vendor-supported pre-fit node/edge mapping for the exact Work10 EMIF0 cone, together with confirmation of CODE_IDENTIFIER application stage and eligible node types in Quartus Pro 26.1.1. The required deliverable is a resolvable source atom, explicitly connected destination/group, entity scope if required, and a supported named-copy assignment—not a guessed suffix-stripped name. Existing reports cannot supply that deliverable; no vendor query was authorized for this task, so investigation stops here.

If vendor support cannot expose an addressable mapping through the supported interface for this protected MSA IP, seek a vendor IP fix/guidance rather than editing protected RTL or changing pipeline latency. The separate router-knob investigation is not duplicated or bundled here.

If a valid mapping later arrives, isolate one duplication assignment with Work10 seed 2 and effort settings unchanged. Require no ignored/unmatched assignment, native evidence of the intended source duplication and destination reassignment, and compare both EMIF setup domains, hold, fanout, resources and runtime. An accepted assignment without the intended transformation is ineffective, not a successful fix.

## Evidence, verification and scope

- CODE_IDENTIFIER: bounded installed-help text search and existing report inventory. Installed help alias maps CODE_IDENTIFIER to CODE_IDENTIFIER; no corresponding local help file was located in the inspected help tree.
- CODE_IDENTIFIER: complete-file SHA256 values, exact string hit counts, and line-numbered synthesis/fitter/installed-library excerpts. CODE_IDENTIFIER records verified remote-generated payload SHA256. The first inventory batch is discovery, not a hash-verified transfer.
- Full local Work10 STA and fitter SHA256 values were recomputed and matched CODE_IDENTIFIER: STA CODE_IDENTIFIER; fitter CODE_IDENTIFIER. The independently read remote fitter matches the same hash.
- Remote synthesis report SHA256: CODE_IDENTIFIER; synthesis AE report: CODE_IDENTIFIER.
- Installed library SHA256 matches the prior investigation: CODE_IDENTIFIER.
- Remote operations were read-only Python file scans in owned tmux window CODE_IDENTIFIER, pane CODE_IDENTIFIER, within CODE_IDENTIFIER. Host CODE_IDENTIFIER and UID 1000 were asserted. SSH was used only to interact with tmux. Unique evidence buffers were used; no existing pane was commandeered.
- No vendor tool/query, compile, DDR simulation, hardware access, install, commit, protected-code modification, SOURCE/WORK edit or gate change occurred. All clocks, memory geometry, PF/BAR, pins and protocol constraints remain unchanged by this investigation; this is not a new whole-tree certification.
- Supplied CODE_IDENTIFIER did not exist; the actual prior evidence is CODE_IDENTIFIER. A large terminal response was truncated and failed JSON parsing; transfer was retried through byte-preserving subprocess capture and its remote checksum verified. The local citation helper required CODE_IDENTIFIER, not unavailable bare CODE_IDENTIFIER.

## Sources

[1] https://docs.altera.com/r/docs/683296/26.1.1/quartus-prime-pro-edition-settings-file-reference-manual/duplicate_atom
