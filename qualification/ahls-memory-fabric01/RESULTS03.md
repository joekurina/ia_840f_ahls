# Connected AHLS memory fabric — native generation and elaboration

**Completed native results; independent acceptance PENDING.** No mapped synthesis, complete DMA/PIM AFU, timing, numerical, DDR or hardware claim.

## Native outcomes

- Fabric01 failed/spent at the donor component-only `set_interconnect_requirement` used in system-script scope. Fabric02 failed/spent because component IRQ/control exports were incomplete. Both native rc1 receipts remain preserved; no generation ran for either. [Fabric01](FABRIC01-FAILURE.md), [fabric02](FABRIC02-FAILURE.md).
- API01 is only a finite interpreter-name query. Its compatibility completion tokens `PD_VALIDATE_OK`/`PD_IMPORT_COMPLETE` were printed by the diagnostic itself; **they do not represent system validation or import**. It created no design and its return code is not HDL evidence. [API result](api01-result.json).
- Fresh **fabric03**: actual Quartus25.1 Build129 import/validate/save and synthesis-HDL generation both native/effective rc0, no rejected step, timeout or surviving owned group. [Manifest](manifest-fabric03.json).
- Fresh **connected elab01**: `quartus_syn --analysis_and_elaboration`, native/effective/outer rc0, runner accepted; no native errors, copied/original255 inputs and bound tools preserved, QSF unchanged. [Manifest](manifest-connected-elab01.json), [inputs](connected-elab-inputs01.json).

## Parent observations

- Generated fabric has **11 exported interfaces /243 declared ports**, including IRQ, freeze and64-bit exception bus. Both bank paths expose34-bit byte addresses,512-bit data,64 write strobes. The kernel itself retains34-bit/256-bit Avalon hosts. [Port ledger](top-ports03.json), [native metadata](native-interfaces03.json).
- All **155 HLS synthesis sources** match the previously accepted import inventory exactly, including the corrected write-ack source. No generated kernel RTL was changed for this fabric. [Metadata ledger](native-interfaces03.json), [prior import](../ahls-memory-pd25-import01/RESULT-ACCEPTANCE.md).
- The two generated QIPs resolve **254 dependency edges /253 distinct targets**; including both QIPs gives255 bound elaboration inputs. Four missing local capture members were obtained read-only with matching native inventory hashes. [Closure](qip-dependencies03.json), [capture](sources04.json).
- Work21 source capture confirms two channels through `mem_ss_param_pkg::NUM_PORTS=2`,34-bit byte addresses and512-bit FIM data. These are source definitions, not current deployed image or live DDR proof. [Capture bindings](preflight01.json), [geometry02](geometry02.json), [geometry03](geometry03.json), [count source](sources04.json).
- Fabric import appended two known power-format defaults, LAST_QUARTUS_VERSION, the generated component IP_FILE and system QSYS_FILE to the initial QSF. Tcl inputs remain exact. Connected elaboration predeclared the two known defaults and retained its QSF byte-for-byte; no historical receipt was rewritten. [Native metadata comparison](native-interfaces03.json), [elaboration manifest](manifest-connected-elab01.json).
- The elaboration log has **57 diagnostic occurrences**, the same ID histogram as standalone-kernel elaboration; the generic banner still says **0 errors /1 warning**. The discrepancy is not waived. Full warning meaning must be reviewed in the actual connected hierarchy, not inferred solely from equal counts. [Warning ledger](connected-warning-ledger01.json).

## Retained integration boundaries

The fabric exports DMA endpoints but does **not** instantiate the donor DMA engines, PIM primary mapper or physical bank CDC yet. The intended top must own host channel0 exactly once, reconcile PIM ID/user widths, bind full-device reset release, preserve34-bit addresses/strobes/burst semantics and establish complete-kernel/downstream-write visibility. DMACSR at0 and kernelCSR at0x10000 are source-relative allocations, not live PF/VF/BAR authorization. The exception bus remains constant zero and cannot verify computation. DRC Reset Release and Work21 signoff findings remain open. DDR simulation **SKIPPED BY USER**.

No FPGA/device access, driver change, programming or reboot occurred. Current sources are additive under `afu/ahls_memory/fabric/`; original scalar AFU, installed vendor tools, original AHLS sources, maintained FIM and Work21 are preserved. No new source-launch approval gate is created by result review.

## Raw archives

- `result-fabric03.json.gz`: SHA256 `69db8ef91de72f4ce100c5acd8ac65922d980cd6e5538393093abd56e44b8ce0`.
- `result-connected-elab01.json.gz`: SHA256 `8e21614a83dbc3b70ebcde9785eea85a39995883bec35f91ba6e18af9e6607b5`.

Generated HDL/reports/raw transfers stay local and hash-referenced. Artifact cap2,000,000bytes; named project evidence is published only after independent acceptance. Failed attempts are never overwritten.
