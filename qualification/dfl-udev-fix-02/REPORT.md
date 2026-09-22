# DFL udev candidate 02 — exact PF0 scope, not activated

## Disposition

**IMPLEMENTED successor / 21 inert tests PASS / native parser and live effects
NOT RUN / review pending.** The installed rule and every effective permission
remain unchanged. Candidate 01 is retained as a **rejected broad-scope draft**:
its `8086:bcce` selector also matches other boards. Its passing 12-test model
did not cover that identity collision; it is not an accepted correction.

## Identity and preservation

The new [candidate](90-intel-fpga-opencl.rules.candidate) changes only the two
DFL node classes associated with one parent satisfying **all**:

- PCI parent kernel name `0000:4f:00.0`;
- vendor/device `8086:bcce`;
- subsystem vendor/device `8086:1771`.

The BDF comes from cached ordinary files `/run/udev/data/c240:0` and `c241:0`
in [source batch03 archive](../source-resume-01/batch03.json.gz). IDs come from
the saved W13 PCIe core16 parameters in
[the scoped contract](../source-resume-01/pcie-saved-contract.json).
**This is snapshot-specific staging evidence, not current live identity.**
N6001 shares the saved IDs; those IDs alone do not identify an IA840F.
The BDF must be revalidated, not silently retargeted, before any application.
No sysfs attribute content, PCI configuration, or FPGA device was accessed.

A forward GOTO skips the old RUN actions only for the exact selected parent
and node. The original file is embedded byte-for-byte as the fallback for all
unrelated devices/events. That preserves unrelated behavior—including its
pre-existing insecure 0666/RUN policy—rather than silently changing other
cards when replacing this filename. No new permissions are granted to those
other devices. Scope expansion to repair them requires its own decision.

At the selected parent only, FME becomes root:root 0600 and port becomes
root:uwb_student00 0660, with no RUN, sysfs chmod, clock/error-control grants,
new group or membership change. This is DFL PF0 node policy, **not VFIO access
for the AHLS VF**, and it does not create/bind a VF or authorize device opens.
See the [separate host-access map](../ahls-host-offline-01/HOST-ACCESS-MAP.md).

The retained original hash is
`ea4f25a85c39f0ba6f390c14ff8d990597c6d56626d4854c028bb165d7f5107e`.
[Diff](candidate.diff) shows precisely the new selector and target branch
around unchanged fallback bytes. The installed systemd 252 manual captured
in `source-resume-01/batch02.json`, command `udev_man`, establishes same-parent
matching across KERNELS/SUBSYSTEMS/ATTRS, alternation, forward GOTO/LABEL and
MODE/GROUP/OWNER semantics. This is grammar/source evidence, not native replay.

## Verification performed

[Command, source hashes, exit status and full output](offline-test-01.json):
`python3 -B qualification/dfl-udev-fix-02/test_rule.py` → **21 tests PASS**.

The inert evaluator parses only the candidate's finite grammar; RUN values
are stored as text and never executed. It verifies selected-node permissions,
optional controls absent, missing required node explicitly failing, add/change
versus remove, and **unchanged original behavior** for wrong BDF/domain/function,
each wrong PCI/subsystem ID, N6000, another board with the same IDs, incomplete
identity, unrelated node and split-parent matches. It also verifies byte-exact
fallback preservation and existing private-group metadata. The model rejects
unknown tokens/operators and missing/backward labels.

These results do not prove udev event timing, current parent attributes,
permissions after other rules, or future hotplug behavior. The installed tool
has no verify subcommand; no `udevadm test`, trigger/reload, service/module
restart, device open or native hardware executable was run.

## Application and rollback remain blocked

Before a separately authorized application: verify current exact parent/card
identity and group, original-file hash and rule ordering; save the original
and node permissions; review the finite narrow activation procedure and its
recovery needs. Replace only `/etc/udev/rules.d/90-intel-fpga-opencl.rules`—do
not add a competing file while leaving its old RUN action active. Verify exact
readback, intended modes, unrelated behavior and event errors. No broad trigger
or FPGA-functional test is part of this candidate.

Rollback restores the original bytes and recorded node permissions via a
separately approved narrow procedure. File restoration alone does not restore
current node metadata. The old 0666 mode is historical rollback state, not
this candidate's desired target policy. There is no executable activation or
rollback script in this package.
