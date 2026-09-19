// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


///////////////////////////////////////////////////////////////////////////////
// Memory model representing either the "ping" or the "pong" side of
// the memory device for ping-pong topology. For non-ping-pong topology
// this is simply the top-level wrapper of the memory model.
//
///////////////////////////////////////////////////////////////////////////////
module altera_emif_ddrx_model_per_ping_pong # 
(
   parameter PROTOCOL_ENUM                                                = "",
   parameter MEM_FORMAT_ENUM                                              = "",
   parameter MEM_DISCRETE_CS_WIDTH                                        = 1, 
   parameter MEM_CHIP_ID_WIDTH                                            = 0,
   parameter MEM_RANKS_PER_DIMM                                           = 0,
   parameter MEM_NUM_OF_DIMMS                                             = 0,
   parameter MEM_AC_PAR_EN                                                = 0,
   parameter MEM_DM_EN                                                    = 0,
   parameter MEM_CLAMSHELL_EN                                             = 0,

   parameter PORT_MEM_CKE_WIDTH                                           = 1,
   parameter PORT_MEM_CK_WIDTH                                            = 1,
   parameter PORT_MEM_CK_N_WIDTH                                          = 1,
   parameter PORT_MEM_BA_WIDTH                                            = 1,
   parameter PORT_MEM_BG_WIDTH                                            = 1,
   parameter PORT_MEM_C_WIDTH                                             = 1,
   parameter PORT_MEM_A_WIDTH                                             = 1,
   parameter PORT_MEM_CS_N_WIDTH                                          = 1,
   parameter PORT_MEM_RAS_N_WIDTH                                         = 1,
   parameter PORT_MEM_CAS_N_WIDTH                                         = 1,
   parameter PORT_MEM_WE_N_WIDTH                                          = 1,
   parameter PORT_MEM_ACT_N_WIDTH                                         = 1,
   parameter PORT_MEM_DQS_WIDTH                                           = 1,
   parameter PORT_MEM_DQS_N_WIDTH                                         = 1,
   parameter PORT_MEM_DQ_WIDTH                                            = 1,
   parameter PORT_MEM_DM_WIDTH                                            = 1,
   parameter PORT_MEM_DBI_N_WIDTH                                         = 1,
   parameter PORT_MEM_RESET_N_WIDTH                                       = 1,
   parameter PORT_MEM_PAR_WIDTH                                           = 1,
   parameter PORT_MEM_ALERT_N_WIDTH                                       = 1,
   parameter PORT_MEM_ODT_WIDTH                                           = 1,
   parameter PORT_MEM_RM_WIDTH                                            = 1,
   
   parameter MEM_ROW_ADDR_WIDTH                                           = 1,
   parameter MEM_COL_ADDR_WIDTH                                           = 1,
   parameter MEM_TRTP                                                     = 0,
   parameter MEM_TRCD                                                     = 0,
   parameter MEM_INIT_MRS0                                                = 0,
   parameter MEM_INIT_MRS1                                                = 0,
   parameter MEM_INIT_MRS2                                                = 0,
   parameter MEM_INIT_MRS3                                                = 0,
   parameter MEM_MIRROR_ADDRESSING_EN                                     = 0,
   parameter MEM_VERBOSE                                                  = 1,
   parameter MEM_CFG_GEN_SBE                                              = 0,
   parameter MEM_CFG_GEN_DBE                                              = 0,
   parameter MEM_CLK_FREQUENCY                                            = 0,
   parameter MEM_MICRON_AUTOMATA                                          = 0,

   parameter DIAG_SIM_MEMORY_PRELOAD                                      = 0,
   parameter DIAG_SIM_MEMORY_PRELOAD_MEM_FILE                             = ""
) (
   input  logic                        [PORT_MEM_A_WIDTH-1:0]            mem_a,
   input  logic                        [PORT_MEM_BA_WIDTH-1:0]           mem_ba,
   input  logic                        [PORT_MEM_BG_WIDTH-1:0]           mem_bg,
   input  logic                        [PORT_MEM_C_WIDTH-1:0]            mem_c,
   input  logic                        [PORT_MEM_CK_WIDTH-1:0]           mem_ck,
   input  logic                        [PORT_MEM_CK_N_WIDTH-1:0]         mem_ck_n,
   input  logic                        [PORT_MEM_CKE_WIDTH - 1:0]        mem_cke,
   input  logic                        [PORT_MEM_CS_N_WIDTH - 1:0]       mem_cs_n,
   input  logic                        [PORT_MEM_RAS_N_WIDTH - 1:0]      mem_ras_n,
   input  logic                        [PORT_MEM_CAS_N_WIDTH - 1:0]      mem_cas_n,
   input  logic                        [PORT_MEM_WE_N_WIDTH - 1:0]       mem_we_n,
   input  logic                        [PORT_MEM_ACT_N_WIDTH - 1:0]      mem_act_n,
   input  logic                        [PORT_MEM_RESET_N_WIDTH - 1:0]    mem_reset_n,
   input  logic                        [PORT_MEM_DM_WIDTH - 1:0]         mem_dm,
   inout  tri                          [PORT_MEM_DBI_N_WIDTH - 1:0]      mem_dbi_n,
   inout  tri                          [PORT_MEM_DQ_WIDTH - 1:0]         mem_dq,
   inout  tri                          [PORT_MEM_DQS_WIDTH - 1:0]        mem_dqs,
   inout  tri                          [PORT_MEM_DQS_N_WIDTH - 1:0]      mem_dqs_n,
   output logic                        [PORT_MEM_ALERT_N_WIDTH-1:0]      mem_alert_n,
   input  logic                        [PORT_MEM_PAR_WIDTH-1:0]          mem_par,
   input  logic                        [PORT_MEM_ODT_WIDTH-1:0]          mem_odt,
   input  logic                        [PORT_MEM_RM_WIDTH-1:0]           mem_rm,

   input  logic                        [PORT_MEM_CS_N_WIDTH - 1:0]       toplevel_cs_n,
   input  logic                        [PORT_MEM_ACT_N_WIDTH - 1:0]      toplevel_act_n,
   input  logic                        [PORT_MEM_A_WIDTH-1:0]            toplevel_a,
   input  logic                        [PORT_MEM_BA_WIDTH-1:0]           toplevel_ba,
   input  logic                        [PORT_MEM_BG_WIDTH-1:0]           toplevel_bg,
   input  logic                        [PORT_MEM_C_WIDTH-1:0]            toplevel_c
);
   timeunit 1ps;
   timeprecision 1ps;
   
   localparam MEM_MODEL_DEVICE_DEPTH = (MEM_FORMAT_ENUM == "MEM_FORMAT_RDIMM" || MEM_FORMAT_ENUM == "MEM_FORMAT_LRDIMM" || MEM_FORMAT_ENUM == "MEM_FORMAT_UDIMM"  || MEM_FORMAT_ENUM == "MEM_FORMAT_SODIMM" ) ? MEM_NUM_OF_DIMMS : 1 ;

   wire logic [MEM_MODEL_DEVICE_DEPTH - 1:0] alert_n; 
   assign mem_alert_n = &alert_n;

   /* DDR4 Shared Address/Command Bus: {RAS_n, CAS_n, WE_n} = A[16:14]
   Interpret as RAS/CAS/WE when ACT_n = 1
   Interpret as A[16:14] when ACT_n = 0 
   If DDR4, there should be no RAS/CAS/WE coming in. We copy A[16:14] to those signals here. */
   logic [PORT_MEM_RAS_N_WIDTH-1:0] int_mem_ras_n;
   logic [PORT_MEM_CAS_N_WIDTH-1:0] int_mem_cas_n;
   logic [PORT_MEM_WE_N_WIDTH-1:0] int_mem_we_n;
   initial begin
      assert(!(PROTOCOL_ENUM == "PROTOCOL_DDR4" && PORT_MEM_A_WIDTH < 17)) else $error("mem_a width must be at least 17 for DDR4");
   end
   
   generate
      if (PROTOCOL_ENUM == "PROTOCOL_DDR4") begin
         always_comb begin
            int_mem_ras_n <= {PORT_MEM_RAS_N_WIDTH{mem_a[16]}};
            int_mem_cas_n <= {PORT_MEM_CAS_N_WIDTH{mem_a[15]}};
            int_mem_we_n <= {PORT_MEM_WE_N_WIDTH{mem_a[14]}};
         end
      end else begin
         always_comb begin
            int_mem_ras_n <= mem_ras_n;
            int_mem_cas_n <= mem_cas_n;
            int_mem_we_n <= mem_we_n;
         end
      end
   endgenerate

   generate
      genvar depth;
      for (depth = 0; depth < MEM_MODEL_DEVICE_DEPTH; ++depth) begin : depth_gen
         
         altera_emif_ddrx_model_per_device #(
            .PROTOCOL_ENUM                               (PROTOCOL_ENUM),
            .PORT_MEM_CKE_WIDTH                          (PORT_MEM_CKE_WIDTH),
            .PORT_MEM_BA_WIDTH                           (PORT_MEM_BA_WIDTH),
            .PORT_MEM_BG_WIDTH                           (PORT_MEM_BG_WIDTH),
            .PORT_MEM_C_WIDTH                            (PORT_MEM_C_WIDTH),
            .PORT_MEM_A_WIDTH                            (PORT_MEM_A_WIDTH),
            .PORT_MEM_CS_N_WIDTH                         (PORT_MEM_CS_N_WIDTH / MEM_MODEL_DEVICE_DEPTH),
            .PORT_MEM_DQS_WIDTH                          (PORT_MEM_DQS_WIDTH),
            .PORT_MEM_DQS_N_WIDTH                        (PORT_MEM_DQS_N_WIDTH),
            .PORT_MEM_DQ_WIDTH                           (PORT_MEM_DQ_WIDTH),
            .PORT_MEM_RAS_N_WIDTH                        (PORT_MEM_RAS_N_WIDTH),
            .PORT_MEM_CAS_N_WIDTH                        (PORT_MEM_CAS_N_WIDTH),
            .PORT_MEM_WE_N_WIDTH                         (PORT_MEM_WE_N_WIDTH),
            .PORT_MEM_ACT_N_WIDTH                        (PORT_MEM_ACT_N_WIDTH),
            .PORT_MEM_DM_WIDTH                           (PORT_MEM_DM_WIDTH),
            .PORT_MEM_DBI_N_WIDTH                        (PORT_MEM_DBI_N_WIDTH),
            .PORT_MEM_RESET_N_WIDTH                      (PORT_MEM_RESET_N_WIDTH),
            .PORT_MEM_PAR_WIDTH                          (PORT_MEM_PAR_WIDTH),
            .PORT_MEM_ALERT_N_WIDTH                      (1),
            .PORT_MEM_RM_WIDTH                           (PORT_MEM_RM_WIDTH),
            .MEM_TOPLEVEL_CS_N_WIDTH                     (PORT_MEM_CS_N_WIDTH),
            .MEM_CHIP_ID_WIDTH                           (MEM_CHIP_ID_WIDTH),
            .MEM_ROW_ADDR_WIDTH                          (MEM_ROW_ADDR_WIDTH),
            .MEM_COL_ADDR_WIDTH                          (MEM_COL_ADDR_WIDTH),
            .MEM_TRTP                                    (MEM_TRTP),
            .MEM_TRCD                                    (MEM_TRCD),
            .MEM_INIT_MRS0                               (MEM_INIT_MRS0),
            .MEM_INIT_MRS1                               (MEM_INIT_MRS1),
            .MEM_INIT_MRS2                               (MEM_INIT_MRS2),
            .MEM_INIT_MRS3                               (MEM_INIT_MRS3),
            .MEM_CS_N_IDX                                (PORT_MEM_CS_N_WIDTH/MEM_MODEL_DEVICE_DEPTH*depth),
            .MEM_DEPTH_IDX                               (depth),
            .MEM_VERBOSE                                 (MEM_VERBOSE),
            .MEM_FORMAT_ENUM                             (MEM_FORMAT_ENUM),
            .MEM_RANKS_PER_DIMM                          (MEM_RANKS_PER_DIMM),
            .MEM_DM_EN                                   (MEM_DM_EN),
            .MEM_CLAMSHELL_EN                            (MEM_CLAMSHELL_EN),
            .MEM_MIRROR_ADDRESSING_EN                    (MEM_MIRROR_ADDRESSING_EN),
            .MEM_AC_PAR_EN                               (MEM_AC_PAR_EN),
            .MEM_CFG_GEN_SBE                             (MEM_CFG_GEN_SBE),
            .MEM_CFG_GEN_DBE                             (MEM_CFG_GEN_DBE),
            .MEM_CLK_FREQUENCY                           (MEM_CLK_FREQUENCY),
            .MEM_MICRON_AUTOMATA                         (MEM_MICRON_AUTOMATA),
            .DIAG_SIM_MEMORY_PRELOAD                     (DIAG_SIM_MEMORY_PRELOAD),
            .DIAG_SIM_MEMORY_PRELOAD_MEM_FILE            (DIAG_SIM_MEMORY_PRELOAD_MEM_FILE)
         ) mem_inst (
            .mem_a                                    (mem_a),
            .mem_ba                                   (mem_ba),
            .mem_bg                                   (mem_bg),
            .mem_c                                    (mem_c),
            .mem_ck                                   (mem_ck[0]), 
            .mem_ck_n                                 (mem_ck_n[0]),   
            .mem_cke                                  (mem_cke),
            .mem_cs_n                                 (mem_cs_n[PORT_MEM_CS_N_WIDTH/MEM_MODEL_DEVICE_DEPTH*(depth+1)-1:PORT_MEM_CS_N_WIDTH/MEM_MODEL_DEVICE_DEPTH*depth]),
            .mem_ras_n                                (int_mem_ras_n),
            .mem_cas_n                                (int_mem_cas_n),
            .mem_we_n                                 (int_mem_we_n),
            .mem_act_n                                (mem_act_n),
            .mem_reset_n                              (mem_reset_n),
            .mem_dm                                   (mem_dm),
            .mem_dbi_n                                (mem_dbi_n),
            .mem_dq                                   (mem_dq),
            .mem_dqs                                  (mem_dqs),
            .mem_dqs_n                                (mem_dqs_n),
            .mem_par                                  (mem_par),
            .mem_alert_n                              (alert_n[depth]),
            .mem_odt                                  (mem_odt[0]),
            .mem_rm                                   (mem_rm),
            .toplevel_cs_n                            (toplevel_cs_n[PORT_MEM_CS_N_WIDTH/MEM_MODEL_DEVICE_DEPTH*(depth+1)-1:PORT_MEM_CS_N_WIDTH/MEM_MODEL_DEVICE_DEPTH*depth]),
            .toplevel_ras_n                           (int_mem_ras_n),
            .toplevel_cas_n                           (int_mem_cas_n),
            .toplevel_we_n                            (int_mem_we_n),
            .toplevel_act_n                           (toplevel_act_n),
            .toplevel_a                               (toplevel_a),
            .toplevel_ba                              (toplevel_ba),
            .toplevel_bg                              (toplevel_bg),
            .toplevel_c                               (toplevel_c)
         );
      end
   endgenerate 
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "JZkiwbCa0s7s4ucJbGOAHlDTAEap7qqD7R/VLOGKIsW8fIuuj6xk21AVzHEzURWZEvVhs7zDu3mUwQPqg/drpNz/zJUSBsE5guCIVVHsJMl5yh3vGDpOWuqEuluiI6sfAHAEBQfZ0r93WuRcdDRzQDa0lC4W8MsxEkTr+LZ679behOWHdWmtbj4Rp3JUUwz+M8ar6tt0veYGdhgCVrBzKX2fRncjOED7B+m1khtNpRBNITe7kA5XSuP7XB/6cqYrDNC6oq/myIWSbBCy2LCdYu/YuOyjQ2fLOF/O6ojKoFXX5SDUzkPOq6NbjJLhpajwgRP2YpVCCAa10cUAxqV30yFJhgCsY+XwZngeR07AVm4GyaOYqc8+dZkcQ6z9PIGCzIg1oJvayl6mOQ+w4mLcFfytHHOMxcc0gSHSpZJCGNC3H83PvaYXi2l8bzN1lPTOZ0fKTVLS4O+Mi1a4A5A2rCKQxlpBZohHs4xaM26dGkbcibzKQBRWV5Y8psnuATa1glYYXcW+a0/ev2a/KAwcPAOfBWOXW7G5WTSkE0v2nIVCP0Io3rl9bTE286/bNMhdnCKgN+hANNbQvGFjPNW8qcEgEuyw4yIPFdJbEP/vM0meO7Pmba+Isst72+W4PXYeZZv+EnFUGpvwajbRdiO9zpOAQkPiHNJdsu/3LSO3w71PrEdiZ4fWKlAFICaYZnIvBjuinYEL8Vt0ABdIQmj+fGumHnnaldiv8rq5yDC5mYi6SiLYPZ3zxZYoFtSs9Xi4jJrFDN+g+OD6TdStrWbNLhJ6ANGzYUe0HgCBw91HigWt+0XmWmZ5kTCu/A/891KYFzLjwCSsld5CxSIIlAheZW/gvQbCLqoottK+s7jW/+osVO9HW5yaeKkvb9IHY8DS9ychilYotque6RPti5DqH3J1du5kpifQowsLfazEO81EuewUILMV4WtIABwyVMilKPJuEa9aQciI454bvYzzg02ofiCISDPDXqd+Jh15GMwfhwbX8YrIGGxOm+8MTXW4"
`endif