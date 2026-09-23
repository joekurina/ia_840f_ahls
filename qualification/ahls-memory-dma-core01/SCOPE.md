# AHLS memory + DMA core integration

Native Quartus25.1 generation and connected component analysis/elaboration, not a FIM image or deployment. Add a new fabric variant retaining corrected AHLS DDRIP, two34-bit/512bit bank boundaries, bank output ID18/USER2 and CSR ID16→18. Only DMA input ID16→9 and MMIO/DMA-CSR BRESP forwarding change. Build a flat external-bus core containing actual corrected DMA, real CSR/descriptor/dataFIFO/mux/register slices and generated AHLS fabric. No primary PIM mapper is yet instantiated; standalone build uses an explicitly source-bound geometry projection, not a substitute for actual generated PIM integration. Preserve originals and prior alternatives.

Pending source/native reviews remain acceptance prerequisites, not new launch gates. No MMIO/device access, FPGA programming, driver changes or reboot. DDR vendor simulation SKIPPED BY USER. No functional, mapped-synthesis, fit/STA or hardware acceptance from analysis/elaboration.
