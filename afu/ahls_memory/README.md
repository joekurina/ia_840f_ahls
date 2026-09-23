# IA840F AHLS memory sample — additive integration

This separate candidate preserves the existing scalar AFU. Its kernel comes from [hls-samples2026.1.0 DDRIP](https://github.com/altera-fpga/hls-samples/blob/0abae6d78af5daca3fe5d67e617ab037e58aff89/Tutorials/Features/hls_flow_interfaces/mmhost/part3_ddr_hosts/src/mmhost.cpp), with only the two address-width properties changed32→34 to address16GiB per bank. The upstream256-bit buses, alignment32, burst8 and arithmetic are retained; the eventual Platform Designer interconnect must explicitly adapt native FIM data width. [Upstream CMake](https://github.com/altera-fpga/hls-samples/blob/0abae6d78af5daca3fe5d67e617ab037e58aff89/Tutorials/Features/hls_flow_interfaces/mmhost/CMakeLists.txt) supplies the native report-flow flags.

The source's SYCL main is a compile harness, **not** the deployed OPAE host. Never run the report output as a hardware test. A real host must DMA x/y to bank0, pass bank-local pointers to generated CSRs, invoke the IP, DMA z from bank1 and compare every element. Actual generated port names/register semantics are acceptance inputs, never guessed.

Build after sourcing HLS IP Gen2026.1.0:

```sh
cmake -S . -B build
cmake --build build --target report --parallel 1
```

This generates IP/report artifacts only. No FIM is changed, no persona is built or flashed, and no physical-DDR or OPAE success is implied. The AI Suite donor DMA address-width and aperture adaptations remain separate source work.
