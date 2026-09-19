# Public BAR2 evidence: AXI Streaming PCIe IP

Source: [Altera AXI Multichannel DMA IP for PCI Express User Guide, 26.1, section 4.2.1](https://docs.altera.com/r/docs/817911/26.1/axi-multichannel-dma-ip-for-pci-express-user-guide/aligning-axi-mcdma-ip-settings-with-axi-streaming-ip-for-pci-express).

The retrieved full document explicitly identifies AXI Streaming PCIe IP as `intel_pcie_ss_axi`. Section 4.2.1 maps MCDMA BAR2 address width to AXI Streaming BAR2 type/size, including 64-bit prefetchable memory, and discusses multiple PF and SR-IOV alignment. This is direct public documentation of BAR2 capability in the named AXI Streaming IP, stronger than merely finding matching parameter names in a different F-Tile endpoint component.

Scope limitation: this MCDMA guide describes Agilex 7 I-Series R-Tile. Its design-example table explicitly says only R-Tile is supported. It does not establish the IA840F target's exact 26.1.1 parameter spellings, component validation, forwarding or enabled PF1 topology. Do not import the MCDMA example's BAR0/BAR4 defaults over BittWare's configuration. This evidence does not select MCDMA as the active DMA implementation.

Read-only lookup found no matching component-definition filenames under local `/opt`; a targeted AHLS project-tree filename search found interface/custom-component Tcl files, not the missing wrapper definition. These are bounded searches, not a claim that the definition is absent from every possible local or public location. Exact public searches located documentation but not the wrapper source.

The remaining source prerequisite is the 26.1.1 `intel_pcie_ss_axi` component definition, registered BAR parameter names/allowed values and relevant forwarding dependencies for the IA840F target. A user-supplied source-only copy can be inspected without executing Quartus or accessing the workstation. No tool installation, workstation operation, configuration, generation, build or test occurred.

See [the local source trace](pcie-bar2-source-trace.md). No RTL, preset or execution gate changed in this pass.
