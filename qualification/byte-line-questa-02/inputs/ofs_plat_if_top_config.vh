// TEST FIXTURE ONLY: no generated board/platform class configuration.
// Unit test uses the unmodified generic PIM Avalon interface and log package.
// Disable legacy top-level compatibility include, not interface assertions.
`ifndef BYTE_LINE_TEST_TOP_CONFIG
`define BYTE_LINE_TEST_TOP_CONFIG
`define AFU_TOP_REQUIRES_OFS_PLAT_IF_AFU 1
`endif
