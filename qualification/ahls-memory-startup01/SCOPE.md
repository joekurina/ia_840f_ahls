# Explicit memory-host startup scope

Add a separate production startup executable and shared entry bridge; retain
all existing frontend/core/config sources byte-exact. The launcher must have
no libopae-c dependency and must validate exact CLI/BDF plus the reviewed
DFL-only parsed configuration before loading the entry module. Before dlopen,
set explicit OPAE initialization, remove WITH_ASE and log-file overrides, and
supply a sealed in-memory copy of the validated configuration. The shared bridge
explicitly initializes, calls the unchanged memory frontend, then finalizes
once after successful initialization. No retries or automatic recovery.

Test the actual unchanged frontend through a shared inert API fixture with
constructor/order markers, API faults and invalid arguments/configuration.
A direct-linked inert predecessor with a constructor must show the pre-main
problem as RED. Verify ELF dependencies before every test class. No real OPAE
library/backend, device, FPGA frontend or hardware runtime is executed.

This is startup-ordering implementation, not an installed launcher or a generic
sandbox/security framework. Module/dependency identity, real backend behavior,
live image/driver/IOMMU/clocks/recovery and device-access authorization remain
external prerequisites. Source/own-logic tests do not authorize live execution.
