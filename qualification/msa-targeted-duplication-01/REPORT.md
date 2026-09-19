# Work10 EMIF0 targeted combinational duplication — bounded disposition

## Decision

**NO BUILDABLE TARGETED-DUPLICATION CANDIDATE. Stop this branch at the pre-fit mapping gap.** `DUPLICATE_ATOM` exists in the installed 26.1.1 assignment library and its documented syntax is identifiable, but the available reports do not establish the source node and destination edge at the phase where this assignment is applied. No QSF patch is emitted. This is not a claim that manual duplication is unsupported on all Agilex designs.

There is useful new evidence: the synthesis report identifies the original destination register and an existing Maximum Fan-Out assignment of 8, with 156 inserted logic cells/copies reported for EMIF0 `wrreq_select_bank_fifo_read[1]`. Thus the synthesis duplication is not merely inferred from `~SynDup` spelling. The combinational driver's pre-fit identity remains missing.

## Exact syntax and what it establishes

The official **26.1.1 Pro Settings File Reference** search-index excerpt gives this literal syntax and says the value must be a node name:[1]

```text
set_instance_assignment -name DUPLICATE_ATOM -from <from> -to <to> -entity <entity name> <value>
```

This is a documentation template, **not an executable candidate**. The installed `libdb_acf.so` contains both `DUPLICATE_ATOM` and `Manual Logic Duplication`, plus:

> Directs the Compiler to duplicate the source node, and uses the new duplicate node to fan out to the destination node; the original source node no longer fans out to the destination node. Use the 'Value' field to specify the name of the duplicate node.

Consequently the value is the new node's name, not `ON`, a fanout threshold, or a requested copy count. The latter belongs to the separate `DUPLICATE_REGISTER` help. `-from` and `-to` require a valid connected source/destination pair; naming the final physical output is not evidence that the pair resolves at the assignment's application stage. No entity, wildcard, source alias or destination group is invented here.

**Evidence limitation:** full-page web extraction timed out (504); the browser returned only the site's navigation shell. The exact syntax above is supported by the official search excerpt, corroborated semantically by installed help, not by native project-load acceptance. An additional device-support search returned a truncated 26.1 excerpt, insufficient to certify exact 26.1.1 family/stage/node-type applicability. Installed option presence alone does not close that applicability gap.

## Source/destination mapping: established versus missing

All abbreviated names below share the actual prefix:

```text
local_mem_wrapper|mem_ss_top|mem_ss_sv|mem_ss|mem_ss|msa_0|msa_0|msa_adapter|wrreq_bank_spreading|
```

| Item | Evidence | Disposition |
|---|---|---|
| Failing final physical driver | Full STA line 156242: `i1378~7xsyn~cw_la_lab/laboutb[10]`, fanout 52 | Proven fitted target, not an assignment target |
| Logical-looking fitted atom | Fitter lines 41638–41640 show `i1378~7xsyn|dataa`, `i1378~7xsyn|combout`, then the same physical output | Links fitted logical and physical representations only; does not prove pre-fit existence |
| Fitted destination | STA lines 156243–156244: `wrreq_select_bank_fifo_read[1]~SynDup_8DUPLICATE`, 0.273 ns incoming IC | Exact failing sink |
| Related fitter sink | Fitter lines 41649–41650 show `wrreq_select_bank_fifo_read[1]~SynDup_8|d` and the register | Similar names across reports do not authorize deleting `DUPLICATE` or other suffixes |
| Original synthesis destination | Synthesis line 98970 names `wrreq_select_bank_fifo_read[1]` with assignment 8 and 156 inserted cells; line 125592 explicitly reports Info 18058 and source `drc_bank_spreading.sv:1032` | Original destination provenance established; report abbreviates the duplicate list, so it does not enumerate the exact sink edge/group needed here |
| Pre-fit combinational source | Entire `ofs_top.syn.rpt` and `ofs_top.syn.ae.rpt` searched for literal `i1378`: zero hits in each | Not established; absence from reports is not proof of absence from the netlist |

The original destination name by itself cannot resolve which of its synthesis duplicates should be driven by the new combinational copy, nor prove that any proposed source drives it when `DUPLICATE_ATOM` takes effect. Do not strip `~7xsyn`, `~cw_la_lab`, `~SynDup_8`, or `DUPLICATE` to manufacture a source/sink mapping.

The Work10 baseline remains EMIF0 setup WNS -0.508 ns, 10 levels, 1.904 ns interconnect and 1.312 ns cell delay. The launch register fanout is 9, distinct from the final combinational driver's fanout 52. Manual launch-register duplication and more destination-register duplication are therefore not substitutes for the requested targeted combinational experiment.

## Finite actionable next step

**Do not allocate a compile to this assignment from the current evidence.** For this branch to reopen, obtain one vendor-supported pre-fit node/edge mapping for the exact Work10 EMIF0 cone, together with confirmation of `DUPLICATE_ATOM` application stage and eligible node types in Quartus Pro 26.1.1. The required deliverable is a resolvable source atom, explicitly connected destination/group, entity scope if required, and a supported named-copy assignment—not a guessed suffix-stripped name. Existing reports cannot supply that deliverable; no vendor query was authorized for this task, so investigation stops here.

If vendor support cannot expose an addressable mapping through the supported interface for this protected MSA IP, seek a vendor IP fix/guidance rather than editing protected RTL or changing pipeline latency. The separate router-knob investigation is not duplicated or bundled here.

If a valid mapping later arrives, isolate one duplication assignment with Work10 seed 2 and effort settings unchanged. Require no ignored/unmatched assignment, native evidence of the intended source duplication and destination reassignment, and compare both EMIF setup domains, hold, fanout, resources and runtime. An accepted assignment without the intended transformation is ineffective, not a successful fix.

## Evidence, verification and scope

- `remote-static-01.json`: bounded installed-help text search and existing report inventory. Installed help alias maps `DUPLICATE_ATOM` to `logicops/logicops/def_duplicate_atom.htm`; no corresponding local help file was located in the inspected help tree.
- `remote-static-02.json`: complete-file SHA256 values, exact string hit counts, and line-numbered synthesis/fitter/installed-library excerpts. `transfer-02.json` records verified remote-generated payload SHA256. The first inventory batch is discovery, not a hash-verified transfer.
- Full local Work10 STA and fitter SHA256 values were recomputed and matched `msa-timing-next-01/verification.json`: STA `8e6002a2c4c7974f0382a9b458c8be9ca87034a120d4972da3c14081367aded4`; fitter `118b90656eb59450598906fb3f191b5ba10ab7f9f0464a6f006dfafe284ac173`. The independently read remote fitter matches the same hash.
- Remote synthesis report SHA256: `ac9260f77d253dbf9c7124e03dc248209f1ff1fbfd42829a397e52ab71d04dfc`; synthesis AE report: `03b9900bdedd29b2235444cce1038970431c597f6cc7fdcab3f7517c488261c2`.
- Installed library SHA256 matches the prior investigation: `ff83ee6769849c55ebb83a6c6567e3d2f9e063210deee7b83bc6698221929f16`.
- Remote operations were read-only Python file scans in owned tmux window `msa-targeted-duplication-01`, pane `%385`, within `ia840f_mailbox_monitored_01`. Host `Agilex7Workstation` and UID 1000 were asserted. SSH was used only to interact with tmux. Unique evidence buffers were used; no existing pane was commandeered.
- No vendor tool/query, compile, DDR simulation, hardware access, install, commit, protected-code modification, SOURCE/WORK edit or gate change occurred. All clocks, memory geometry, PF/BAR, pins and protocol constraints remain unchanged by this investigation; this is not a new whole-tree certification.
- Supplied `exactemif0-path.txt` did not exist; the actual prior evidence is `emif0-path.txt`. A large terminal response was truncated and failed JSON parsing; transfer was retried through byte-preserving subprocess capture and its remote checksum verified. The local citation helper required `python3`, not unavailable bare `python`.

## Sources

[1] https://docs.altera.com/r/docs/683296/26.1.1/quartus-prime-pro-edition-settings-file-reference-manual/duplicate_atom
