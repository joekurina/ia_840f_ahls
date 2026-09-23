# Copyright 2024-2025 Altera Corporation.
# Derived from pinned AI Suite dla_afu_hw.tcl; see AI-SUITE-LICENSE.md.
package require -exact qsys 17.0
set_module_property NAME ia840f_ahls_memory_fabric
set_module_property DISPLAY_NAME {IA840F AHLS memory fabric}
set_module_property VERSION 1.0
set_module_property GROUP {AHLS IA840F}
set_module_property DESCRIPTION {Two-bank AHLS and DMA interconnect; no physical DDR controller}
set_module_property AUTHOR {IA840F AHLS project}
set_module_property COMPOSITION_CALLBACK compose
proc compose {} {
add_instance clk_1x altera_clock_bridge
set_instance_parameter_value clk_1x EXPLICIT_CLOCK_RATE 0
set_instance_parameter_value clk_1x NUM_CLOCK_OUTPUTS 1
add_instance rst altera_reset_bridge
set_instance_parameter_value rst ACTIVE_LOW_RESET 1
set_instance_parameter_value rst SYNCHRONOUS_EDGES deassert
set_instance_parameter_value rst NUM_RESET_OUTPUTS 1
add_connection clk_1x.out_clk rst.clk
add_interface clock_reset clock sink
set_interface_property clock_reset EXPORT_OF clk_1x.in_clk
add_interface clock_reset_reset reset sink
set_interface_property clock_reset_reset EXPORT_OF rst.in_reset

add_instance k0 mmhost_ia840f_report_di
add_connection clk_1x.out_clk k0.clock
add_connection rst.out_reset k0.resetn

# Preserve all parameters from each donor bridge role except evaluated geometry.
proc add_bound_axi_bridge {name parameters} {
    add_instance $name altera_axi_bridge 19.9.3
    foreach {key value} $parameters {set_instance_parameter_value $name $key $value}
    add_connection clk_1x.out_clk $name.clk
    add_connection rst.out_reset $name.clk_reset
}
set mmio_parameters {
    ACE_LITE_SUPPORT {0}
    ADDR_WIDTH {20}
    AXI_VERSION {AXI4}
    BACKPRESSURE_DURING_RESET {0}
    COMBINED_ACCEPTANCE_CAPABILITY {1}
    COMBINED_ISSUING_CAPABILITY {1}
    DATA_WIDTH {64}
    ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
    ENABLE_OOO {0}
    M0_ID_WIDTH {16}
    NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
    READ_ACCEPTANCE_CAPABILITY {1}
    READ_ADDR_USER_WIDTH {1}
    READ_DATA_REORDERING_DEPTH {1}
    READ_DATA_USER_WIDTH {1}
    READ_ISSUING_CAPABILITY {1}
    S0_ID_WIDTH {16}
    SYNC_RESET {0}
    USE_M0_ARBURST {0}
    USE_M0_ARCACHE {0}
    USE_M0_ARID {1}
    USE_M0_ARLEN {0}
    USE_M0_ARLOCK {0}
    USE_M0_ARQOS {0}
    USE_M0_ARREGION {0}
    USE_M0_ARSIZE {1}
    USE_M0_ARUSER {1}
    USE_M0_AWBURST {0}
    USE_M0_AWCACHE {0}
    USE_M0_AWID {1}
    USE_M0_AWLEN {0}
    USE_M0_AWLOCK {0}
    USE_M0_AWQOS {0}
    USE_M0_AWREGION {0}
    USE_M0_AWSIZE {1}
    USE_M0_AWUSER {1}
    USE_M0_BID {1}
    USE_M0_BRESP {0}
    USE_M0_BUSER {1}
    USE_M0_RID {1}
    USE_M0_RLAST {0}
    USE_M0_RRESP {1}
    USE_M0_RUSER {1}
    USE_M0_WSTRB {1}
    USE_M0_WUSER {1}
    USE_PIPELINE {1}
    USE_S0_ARCACHE {0}
    USE_S0_ARLOCK {0}
    USE_S0_ARPROT {0}
    USE_S0_ARQOS {0}
    USE_S0_ARREGION {0}
    USE_S0_ARUSER {1}
    USE_S0_AWCACHE {0}
    USE_S0_AWLOCK {0}
    USE_S0_AWPROT {0}
    USE_S0_AWQOS {0}
    USE_S0_AWREGION {0}
    USE_S0_AWUSER {1}
    USE_S0_BRESP {1}
    USE_S0_BUSER {1}
    USE_S0_RRESP {1}
    USE_S0_RUSER {1}
    USE_S0_WLAST {0}
    USE_S0_WUSER {1}
    WRITE_ACCEPTANCE_CAPABILITY {1}
    WRITE_ADDR_USER_WIDTH {1}
    WRITE_DATA_USER_WIDTH {1}
    WRITE_ISSUING_CAPABILITY {1}
    WRITE_RESP_USER_WIDTH {1}
}
set dma_csr_parameters {
    ACE_LITE_SUPPORT {0}
    ADDR_WIDTH {16}
    AXI_VERSION {AXI4}
    BACKPRESSURE_DURING_RESET {0}
    COMBINED_ACCEPTANCE_CAPABILITY {1}
    COMBINED_ISSUING_CAPABILITY {1}
    DATA_WIDTH {64}
    ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
    ENABLE_OOO {0}
    M0_ID_WIDTH {18}
    NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
    READ_ACCEPTANCE_CAPABILITY {1}
    READ_ADDR_USER_WIDTH {1}
    READ_DATA_REORDERING_DEPTH {1}
    READ_DATA_USER_WIDTH {1}
    READ_ISSUING_CAPABILITY {1}
    S0_ID_WIDTH {18}
    SYNC_RESET {0}
    USE_M0_ARBURST {0}
    USE_M0_ARCACHE {0}
    USE_M0_ARID {1}
    USE_M0_ARLEN {0}
    USE_M0_ARLOCK {0}
    USE_M0_ARQOS {0}
    USE_M0_ARREGION {0}
    USE_M0_ARSIZE {1}
    USE_M0_ARUSER {1}
    USE_M0_AWBURST {0}
    USE_M0_AWCACHE {0}
    USE_M0_AWID {1}
    USE_M0_AWLEN {0}
    USE_M0_AWLOCK {0}
    USE_M0_AWQOS {0}
    USE_M0_AWREGION {0}
    USE_M0_AWSIZE {1}
    USE_M0_AWUSER {1}
    USE_M0_BID {1}
    USE_M0_BRESP {0}
    USE_M0_BUSER {1}
    USE_M0_RID {1}
    USE_M0_RLAST {0}
    USE_M0_RRESP {1}
    USE_M0_RUSER {1}
    USE_M0_WSTRB {1}
    USE_M0_WUSER {1}
    USE_PIPELINE {1}
    USE_S0_ARCACHE {0}
    USE_S0_ARLOCK {0}
    USE_S0_ARPROT {0}
    USE_S0_ARQOS {0}
    USE_S0_ARREGION {0}
    USE_S0_ARUSER {1}
    USE_S0_AWCACHE {0}
    USE_S0_AWLOCK {0}
    USE_S0_AWPROT {0}
    USE_S0_AWQOS {0}
    USE_S0_AWREGION {0}
    USE_S0_AWUSER {1}
    USE_S0_BRESP {0}
    USE_S0_BUSER {1}
    USE_S0_RRESP {1}
    USE_S0_RUSER {1}
    USE_S0_WLAST {0}
    USE_S0_WUSER {1}
    WRITE_ACCEPTANCE_CAPABILITY {1}
    WRITE_ADDR_USER_WIDTH {1}
    WRITE_DATA_USER_WIDTH {1}
    WRITE_ISSUING_CAPABILITY {1}
    WRITE_RESP_USER_WIDTH {1}
}
set dma_parameters {
    ACE_LITE_SUPPORT {0}
    ADDR_WIDTH {34}
    AXI_VERSION {AXI4}
    BACKPRESSURE_DURING_RESET {0}
    COMBINED_ACCEPTANCE_CAPABILITY {64}
    COMBINED_ISSUING_CAPABILITY {64}
    DATA_WIDTH {512}
    ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
    ENABLE_OOO {0}
    M0_ID_WIDTH {16}
    NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
    READ_ACCEPTANCE_CAPABILITY {64}
    READ_ADDR_USER_WIDTH {2}
    READ_DATA_REORDERING_DEPTH {1}
    READ_DATA_USER_WIDTH {2}
    READ_ISSUING_CAPABILITY {64}
    S0_ID_WIDTH {16}
    SYNC_RESET {0}
    USE_M0_ARBURST {1}
    USE_M0_ARCACHE {1}
    USE_M0_ARID {1}
    USE_M0_ARLEN {1}
    USE_M0_ARLOCK {1}
    USE_M0_ARQOS {1}
    USE_M0_ARREGION {1}
    USE_M0_ARSIZE {1}
    USE_M0_ARUSER {1}
    USE_M0_AWBURST {1}
    USE_M0_AWCACHE {1}
    USE_M0_AWID {1}
    USE_M0_AWLEN {1}
    USE_M0_AWLOCK {1}
    USE_M0_AWQOS {1}
    USE_M0_AWREGION {1}
    USE_M0_AWSIZE {1}
    USE_M0_AWUSER {1}
    USE_M0_BID {1}
    USE_M0_BRESP {1}
    USE_M0_BUSER {1}
    USE_M0_RID {1}
    USE_M0_RLAST {1}
    USE_M0_RRESP {1}
    USE_M0_RUSER {1}
    USE_M0_WSTRB {1}
    USE_M0_WUSER {1}
    USE_PIPELINE {1}
    USE_S0_ARCACHE {1}
    USE_S0_ARLOCK {1}
    USE_S0_ARPROT {1}
    USE_S0_ARQOS {1}
    USE_S0_ARREGION {1}
    USE_S0_ARUSER {1}
    USE_S0_AWCACHE {1}
    USE_S0_AWLOCK {1}
    USE_S0_AWPROT {1}
    USE_S0_AWQOS {1}
    USE_S0_AWREGION {1}
    USE_S0_AWUSER {1}
    USE_S0_BRESP {1}
    USE_S0_BUSER {1}
    USE_S0_RRESP {1}
    USE_S0_RUSER {1}
    USE_S0_WLAST {1}
    USE_S0_WUSER {1}
    WRITE_ACCEPTANCE_CAPABILITY {64}
    WRITE_ADDR_USER_WIDTH {2}
    WRITE_DATA_USER_WIDTH {2}
    WRITE_ISSUING_CAPABILITY {64}
    WRITE_RESP_USER_WIDTH {2}
}
set bank_parameters {
    ACE_LITE_SUPPORT {0}
    ADDR_WIDTH {34}
    AXI_VERSION {AXI4}
    BACKPRESSURE_DURING_RESET {0}
    COMBINED_ACCEPTANCE_CAPABILITY {64}
    COMBINED_ISSUING_CAPABILITY {64}
    DATA_WIDTH {512}
    ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
    ENABLE_OOO {0}
    M0_ID_WIDTH {18}
    NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
    READ_ACCEPTANCE_CAPABILITY {64}
    READ_ADDR_USER_WIDTH {2}
    READ_DATA_REORDERING_DEPTH {1}
    READ_DATA_USER_WIDTH {2}
    READ_ISSUING_CAPABILITY {64}
    S0_ID_WIDTH {18}
    SYNC_RESET {0}
    USE_M0_ARBURST {1}
    USE_M0_ARCACHE {1}
    USE_M0_ARID {1}
    USE_M0_ARLEN {1}
    USE_M0_ARLOCK {1}
    USE_M0_ARQOS {1}
    USE_M0_ARREGION {1}
    USE_M0_ARSIZE {1}
    USE_M0_ARUSER {1}
    USE_M0_AWBURST {1}
    USE_M0_AWCACHE {1}
    USE_M0_AWID {1}
    USE_M0_AWLEN {1}
    USE_M0_AWLOCK {1}
    USE_M0_AWQOS {1}
    USE_M0_AWREGION {1}
    USE_M0_AWSIZE {1}
    USE_M0_AWUSER {1}
    USE_M0_BID {1}
    USE_M0_BRESP {1}
    USE_M0_BUSER {1}
    USE_M0_RID {1}
    USE_M0_RLAST {1}
    USE_M0_RRESP {1}
    USE_M0_RUSER {1}
    USE_M0_WSTRB {1}
    USE_M0_WUSER {1}
    USE_PIPELINE {1}
    USE_S0_ARCACHE {1}
    USE_S0_ARLOCK {1}
    USE_S0_ARPROT {1}
    USE_S0_ARQOS {1}
    USE_S0_ARREGION {1}
    USE_S0_ARUSER {1}
    USE_S0_AWCACHE {1}
    USE_S0_AWLOCK {1}
    USE_S0_AWPROT {1}
    USE_S0_AWQOS {1}
    USE_S0_AWREGION {1}
    USE_S0_AWUSER {1}
    USE_S0_BRESP {1}
    USE_S0_BUSER {1}
    USE_S0_RRESP {1}
    USE_S0_RUSER {1}
    USE_S0_WLAST {1}
    USE_S0_WUSER {1}
    WRITE_ACCEPTANCE_CAPABILITY {64}
    WRITE_ADDR_USER_WIDTH {2}
    WRITE_DATA_USER_WIDTH {2}
    WRITE_ISSUING_CAPABILITY {64}
    WRITE_RESP_USER_WIDTH {2}
}

add_bound_axi_bridge mmio_control $mmio_parameters
add_bound_axi_bridge dma_csr $dma_csr_parameters
proc connect_at {source target base} {
    add_connection $source/$target
    set_connection_parameter_value $source/$target arbitrationPriority 1
    set_connection_parameter_value $source/$target baseAddress $base
    set_connection_parameter_value $source/$target defaultConnection 0
}
# Preserve donor DMA/identity aperture [0,0xffff], separate AHLS at 0x10000.
connect_at mmio_control.m0 dma_csr.s0 0x0
connect_at mmio_control.m0 k0.csr_ring_root_avs 0x10000
add_interface mmio_control axi4 slave
set_interface_property mmio_control EXPORT_OF mmio_control.s0
add_interface dma_csr axi4 master
set_interface_property dma_csr EXPORT_OF dma_csr.m0

# Each independent bank has DMA + the actual AHLS host at bank-local base zero.
# The native interconnect supplies Avalon/AXI conversion and 256-to-512 scaling.
# No address-span extender or guessed combined-bank MMIO window is included.
foreach {bank host} {
    0 avm_mem_gmem0_1_port_0_0_rw
    1 avm_mem_gmem1_2_port_0_0_rw
} {
    add_bound_axi_bridge dma_ddr_in$bank $dma_parameters
    add_bound_axi_bridge bank_out$bank $bank_parameters
    connect_at dma_ddr_in$bank.m0 bank_out$bank.s0 0x0
    connect_at k0.$host bank_out$bank.s0 0x0
    add_interface dma_ddr_in$bank axi4 slave
    set_interface_property dma_ddr_in$bank EXPORT_OF dma_ddr_in$bank.s0
    add_interface bank_out$bank axi4 master
    set_interface_property bank_out$bank EXPORT_OF bank_out$bank.m0
}
foreach {external internal kind direction} {
    kernel_irqs kernel_irqs interrupt end
    freeze freeze conduit end
    device_exception_bus device_exception_bus conduit end
} {
    add_interface $external $kind $direction
    set_interface_property $external ENABLED true
    set_interface_property $external EXPORT_OF k0.$internal
}
# Exception output is constant zero in this generated component, not a checker.
set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {FIFO}
set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {2}
}
