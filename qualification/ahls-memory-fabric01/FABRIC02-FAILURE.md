# Fabric02 — failed/spent; no generation

Native qsys-script rc1. The composite footprint exposes eight clock/reset/AXI interfaces but no IRQ/freeze/exception interfaces; top export reports three errors. Success markers appeared afterwards but the runner correctly rejected the native errors. [Manifest](manifest-fabric02.json).

The generated AHLS descriptor declares its IRQ with the component API `interrupt end`, and explicitly enables its IRQ/conduit interfaces. Fabric02 instead reused standalone-script `irq sender` syntax inside the component composition callback. Preserve the exact fabric02 descriptor in `source-fabric02/` and its embedded runner input. Fabric03 uses source-matching `interrupt end` plus ENABLED true for all three exported controls, without dropping any signal or modifying generated AHLS RTL. Whether this resolves the footprint is determined by the successor native run, not assumed.
