# Response to independent spec review 01

This addendum accompanies the unchanged `spec-input-manifest01.json` inputs.
It resolves reporting scope, not hardware safety or acceptance.

1. **Over-broad udev selector:** successor
   [dfl-udev-fix-02](../dfl-udev-fix-02/REPORT.md) binds the snapshot PF0 BDF
   plus all four PCI IDs on one parent. It preserves byte-exact original
   behavior for unrelated events. Its 21 executed inert tests include N6000,
   another board sharing every ID, wrong domain/BDF/function, individual wrong
   IDs and split-parent identity. Candidate01 is retained as rejected.
2. **Required-node failure reporting:** **native acceptance remains UNVERIFIED.**
   The udev rule is event-driven node-permission policy, not a missing-device
   detector. The fixture's `check_access()` intentionally models an additional
   acceptance preflight and raises if a resource set lacks `device_node`;
   neither that function nor `FileNotFoundError` exists in the native rule.
   No claim is made that udev rejects a missing required device.

   A future separately authorized application/acceptance procedure must first
   establish the exact intended parent and nodes, require both expected
   character nodes to exist, then check their intended owner/group/modes and
   relevant event errors after narrow activation. A missing/wrong required
   node is a failure of that external acceptance check; it is not repaired by
   creating a substitute node or broadened matching. It must also compare
   unrelated permissions against preserved before-state. That native
   procedure is neither executed nor claimed proven by the inert model.
   No device open, sysfs register read, or functional MMIO test is required
   for a metadata permission check; any future operation still needs its own
   reviewed scope. The candidate package provides no automatic activation,
   trigger, recovery or rollback execution.
3. **Missing reports:** UART, udev01/02, host and source reports now exist;
   the active feature matrix and plan §9 reflect actual offline/native-compile
   results separately from unperformed hardware tests. The host access map
   identifies the source-proven PF0 VF0 BAR0 path, supported OPAE backend
   branch, exact aligned register set and unverified live binding/clock/reset
   and recovery prerequisites. The native-linked test remains unexecuted.

Fresh independent spec review is requested against the bound artifacts and
this explicit missing-node limitation. Passing an offline milestone will not
flip native udev, FPGA Test, timing, PR, DDR, transfer or durable-boot gates.
