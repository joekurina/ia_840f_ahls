# DFL udev candidate — staged, not activated

## Status

**IMPLEMENTED candidate; OFFLINE FIXTURE CHECKS PASS; native parser/event and
LIVE verification NOT RUN.** The installed rule and all effective permissions
remain unchanged. These distinctions are deliberate: an inert subset model is
not a native udev event replay.

## Diagnosis and source binding

The actual rule is local/unpackaged
`/etc/udev/rules.d/90-intel-fpga-opencl.rules` (rpm -qf returns not owned).
Original bytes are preserved at
[the captured path](../source-resume-01/remote/etc/udev/rules.d/90-intel-fpga-opencl.rules),
SHA256 `ea4f25a85c39f0ba6f390c14ff8d990597c6d56626d4854c028bb165d7f5107e`.
The rule uses KERNEL `dfl-fme.[0-9]*`/`dfl-port.[0-9]*`, ACTION `add|change`,
GROUP root, MODE 0666, followed by a shell RUN chmod over sysfs globs and
`/dev/%k`. See [batch01](../source-resume-01/batch01.json).

The exact port operand `dfl*/userclk/frequency` has **no matching pathname**
at the collected port path; `errors/*` has four paths. The character node
exists. Thus the unmatched user-clock glob is a concrete failing operand in
this snapshot. This does not retrospectively prove it was the only failure at
boot. Collection used directory/node metadata only: **no sysfs attribute or
device content was read**. See `batch04.json` →
`inventory.chmod_operand_paths`; node stat and cached udev IDs are in
[batch03 archive](../source-resume-01/batch03.json.gz).

Both nodes were root:root mode 0666 at collection. `uwb_student00` is the
intended developer, with existing private primary group `uwb_student00` GID
1000. No group or membership change is proposed (`batch01.json` id/getent).
The captured installed udev manual confirms MODE/GROUP node semantics,
lexical ordering, `/etc` precedence for equal names, and the same-parent rule
for multiple ATTRS matches. The installed help has no `verify` subcommand.
No `udevadm test`, reload, trigger, module reprobe, or restart was run.

## Exact candidate

[Candidate](90-intel-fpga-opencl.rules.candidate), [diff](candidate.diff).
Replace the discovered rule file, not layer an additional rule over the old
RUN action. Match only PCI vendor 8086/device bcce and the named DFL node
classes. Port becomes root:uwb_student00 **0660**; FME stays root:root **0600**.
There are no shell RUN actions, wildcard chmods, or sysfs permission grants.
Administrative clock/error controls and PR are not ordinary CSR-test privileges.

**This candidate only scopes the existing PF0 DFL nodes.** It does not make
PF0 VF0 exist, bind a VF, grant VFIO access, or turn the management port into
the AHLS AFU. The [host routing report](../ahls-host-offline-01/HOST-ACCESS-MAP.md)
tracks the distinct AFU/backend path. Do not claim the candidate establishes
non-root AHLS enumeration.

## Regression and rollback

[Exact command/result](offline-test-01.json):
`python3 -B qualification/dfl-udev-fix-01/test_rule.py` → **12/12 PASS**.
Tests cover required node present/absent, optional controls absent, wrong
vendor/device, remove/change events, same-parent matching, least-privilege
modes, no control-side effects, original preservation, and group existence.
A missing required device node raises an explicit fixture failure, not success.

Before any application, independently recheck original hash, current node/card
identity and matching parent metadata. Back up the original at a distinct
ordinary-file path. A reviewed exact activation operation must be authorized
separately, with its effect on affected device ownership and permissions
explicit. Do not issue a broad trigger. Read back the installed bytes, metadata
permissions, and relevant event logs without opening FPGA devices.

Rollback restores the byte-exact original file and, through an independently
approved narrow event/metadata procedure, the recorded prior permissions.
Restoring the file alone does not revert current node permissions. Restoring
0666 is a rollback to a pre-existing insecure state, not the desired policy.
No activation or rollback command is automatically run by these fixtures.
