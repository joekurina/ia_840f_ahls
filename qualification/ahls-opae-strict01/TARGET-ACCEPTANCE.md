# Parent acceptance — strict-core AHLS-image build

**ACCEPT WITH FINDINGS, native compile/link and static-ELF integration only.**
The complete [FINAL review](target-independent-review01.md) was read and matched
returned SHA256 `7ce6daa350dea2a4a948124da17ede8209a42d36a886a70b672b55883055a87f`.
All 60 frozen files / 3,269,737 bytes were rehashed; all 33 archive exports were
decoded and matched against local bytes. Native/effective/outer are 0/0/0 and
all 16 inner command/log pairs match at rc0. Preservation flags are true, with
no timeout, owned survivor or postflight error. [Parent verification](target-parent-review-verification01.json).

Accept the actual native SDK opae-c build inside the unchanged AHLS SIF, with
original plugin-manager bytes plus the appended strict include exposed through
a read-only source overlay. Only the copied core library changed; the bound
SDK, original predecessor and other copied libraries remain preserved. The new
entry imports the private strict API and 21 FPGA exports, not fpgaInitialize;
all three bridge exports and -z defs linking are present. The unchanged launcher
remains byte-identical to its predecessor. [Scope](TARGET-SCOPE01.md),
[results](TARGET-RESULTS01.md), [unit acceptance](UNIT-ACCEPTANCE.md).

Retain all review limitations and observations:
- GCC11.4 native linking is distinct from GCC14.2 UBSan inert behavior. This is
  not an AHLS FPGA compile, backend rebuild, installation or runtime execution.
- Core/backend trailing-colon RUNPATHs and SDK prefix searches remain; absolute
  config module text is not exclusive loader resolution. Legacy constructors
  and APIs are preserved, not globally replaced. Module/dependency identity,
  combined startup selection, lifecycle and partial-state cleanup are unqualified.
- Optional dependency messages and unused RUN_LDCONFIG and
  FETCHCONTENT_FULLY_DISCONNECTED are retained, not accepted as safety controls.
- Preservation covers bound inventory domains, not every filesystem member.
  The overlay digest is asserted in the inner code and corroborated by mounts
  and native compilation, not separately emitted as a measured result field.
  Future changed collectors should record that field and require export roles.
- Resource limits, finite name checks and process-group observations are not
  a sandbox, aggregate-memory limit or universal failure/descendant guarantee.
  Native outer status covers Apptainer/inner Python; the individual commands
  have separate inner receipts. Remote source bytes were not reacquired here.

No unchanged build or test was rerun. No executable, real OPAE/backend, FPGA or
device was accessed. No deployment, BDF isolation, live discovery/MMIO,
DDR/DMA/numerical AHLS, reset/drain/fence, full signoff or QSPI boot acceptance.
Vendor DDR simulation: SKIPPED BY USER. Frozen pending text stays historical.
