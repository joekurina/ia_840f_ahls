# Transparent baseline: alias accepted

The same complete connected fixture compiled/loaded with a transparent AXI-Lite connection replacing the new guard. The first intentionally invalid write,0x30080, returnedOKAY instead of expectedDECERR at4275ns. Nativevsim0 does not make this pass: fataldiagnostic retained, outer1, unit_passfalse. No change to the actual generated PD router, CSR manager, kernel, DMA or bank path was made for this baseline.

Candidategreen01 changes only the guard source. The exact same fixture, model,529-source set,450-entry compile list, libraries and acceptance conditions apply. No live MMIO operation occurred.
