# PCIe Shim Library

This tree holds a collection of shims that transform PCIe TLP AXI streams. The shims typically act as both a sink and a source, modifying a TLP AXI-S as part of a pipeline. Where a shim belongs in the AFU/FIM hierarchy generally depends on whether the transformation operates on multiplexed PCIe functions or on a single function.

* [pcie\_bus\_width/ofs_fim_pcie_bus_width.sv](pcie_bus_width/ofs_fim_pcie_bus_width.sv) maps between TLP AXI streams of different widths. The ratio between the widths must be a multiple of the smaller size. The ofs_fim_pcie_bus_width\(\) module is a wrapper around separate modules for growing or shrinking the bus. The mapping is typically used for supporting 128 or 256 bit buses in modules that expect at least 512 bits.
* [pcie\_dm\_req\_splitter](pcie_dm_req_splitter) converts large PCIe DM-encoded read and write requests into smaller chunks. Split read completions are reassembled into a single packet to match the original request. The splitter is typically instantiated between an AFU and a PF/VF MUX in order to manage QoS across multiple functions within the MUX.
* [pcie\_hdr\_out\_of\_band](pcie_hdr_out_of_band) provides one module that breaks TLP headers and data into separate streams and another that combines separate headers and data into a single stream, allowing algorithms to operate on data streams aligned to the bus width.

The full shim library can be loaded into a project project using [files\_quartus.tcl](files_quartus.tcl) or, for simulation, [files\_sim.f](files_sim.f).

Some shims have [tests](tests).
