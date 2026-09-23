# Fabric01 — failed/spent; no generation

Native qsys-script rc1: `invalid command name "set_interconnect_requirement"`. The standalone system API cannot execute the donor's component-composition command. The finite api01 query exposed no matching interconnect command names; that query is not HDL evidence. [Failed native manifest](manifest-fabric01.json), [API result](api01-result.json).

Sources, copied inputs and tools remained unchanged; no timeout or owned-group survivor. No generation was run. Do not rerun fabric01.

Fresh fabric02 retains the donor's component-composition mechanism: `_hw.tcl` registers the same interconnect in a COMPOSITION_CALLBACK, and the top-level system script instantiates and exports that component. All bridge parameters, clock/reset connections, addresses and data paths from fabric01 remain. The donor interconnect requirements are retained, not dropped. ABI metadata verification moves to generated XML because component and system Tcl scopes differ. Literal `,$` keeps the standard catalog. No live hardware operation is involved.
