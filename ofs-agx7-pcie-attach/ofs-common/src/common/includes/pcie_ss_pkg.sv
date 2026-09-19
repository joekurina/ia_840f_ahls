// Copyright 2021 Intel Corporation
// SPDX-License-Identifier: MIT

// -----------------------------------------------------------------------------
// Create Date  : Sept 2020
// Module Name  : pcie_ss_pkg.sv
// Project      : IOFS
// Description  : Interface and parameter definitions for the HE-LB
// -----------------------------------------------------------------------------
//
//
//  RX (Host -> HE direction)
//            All completions are Data Mover Format (tag = tdata[127:118])
//            All requests are Power User Format (tag = tdata[47:40])
//  TX (HE -> Host direction)
//            All completions are in power user format (tag = tdata[80:72])
//            All requests are in Data Mover format (tag = {tdata[23], tdata[19], tdata [47:40]}


package pcie_ss_pkg;
   import pcie_ss_hdr_pkg::*;

localparam TDATA_WIDTH = ofs_pcie_ss_cfg_pkg::TDATA_WIDTH;
localparam TUSER_WIDTH = ofs_pcie_ss_cfg_pkg::TUSER_WIDTH;


// ---------------------------------------------------------------------------
// Format flit, possibly with a header, as a single line
// ---------------------------------------------------------------------------
// synthesis translate_off

function automatic string func_pcie_ss_flit_to_string(
  input logic sop,
  input logic eop,
  input logic is_pu_mode, // Power user mode? (usually tuser_vendor[0] == 1'b0)
  input logic [TDATA_WIDTH-1:0] data,
  input logic [(TDATA_WIDTH/8)-1:0] keep
  );

  // Map "data" to a hex string with underscores every 64 bits
  string data_str = $sformatf("%x", data[63:0]);

  // Prepend hex strings from 64 bits at a time, walking through the large data vector
  for (int i = 64; i < $bits(data); i = i + 64) begin
    data_str = $sformatf("%x_%s", data[i +: 64], data_str);
  end

  return $sformatf("%t %s keep 0x%x data 0x%s", $time,
                   pcie_ss_hdr_pkg::func_flit_to_string(sop, eop, is_pu_mode,
                                                        pcie_ss_hdr_pkg::PCIe_PUReqHdr_t'(data)),
                   keep,
                   data_str);

endfunction // func_pcie_ss_flit_to_string

// synthesis translate_on

// ---------------------------------------------------------------------------
// Task : Display PCIe Cycle/Data in a multi-line format
// ---------------------------------------------------------------------------
task display_cycle; 

  input string              str;
  input logic               rx_tx; //0-tx, 1-rx
  input logic               sop;
  input logic               eop; 
  input logic               [TDATA_WIDTH-1:0] data;
                            
  // synthesis translate_off
  PCIe_ReqHdr_t             ReqHdr;
  PCIe_CplHdr_t             CplHdr;
  PCIe_PUCplHdr_t           PUCpl;
  logic [23:0]              len;
  logic [ 9:0]              tag;
  logic [63:0]              addr;
  logic  [2:0]              cpl_sts;
  logic  [1:0]              tag_index ;
  logic                     cmp_header;  
  logic                     dat_header; 
  string                    fmttype;
  string                    s_rx_tx;
  logic [TDATA_WIDTH-1:0]   d; 
  reg   [1023:0][63:0]      ram; 

  begin 
  
    ReqHdr     = data[255:0];
    CplHdr     = data[255:0];
    PUCpl      = data[255:0];
    d          = data;
    s_rx_tx    = rx_tx ? "RX" : "TX" ; 
    dat_header = pcie_ss_hdr_pkg::func_has_data(ReqHdr.fmt_type);
    cmp_header = pcie_ss_hdr_pkg::func_is_completion(ReqHdr.fmt_type);
    fmttype    = pcie_ss_hdr_pkg::func_fmttype_to_string(ReqHdr.fmt_type);
    
    casex ({ReqHdr.vf_active, ReqHdr.vf_num[1:0]})
            4'b100:     tag_index = 2'b00    ;                   
            4'b101:     tag_index = 2'b01    ;                   
            4'b110:     tag_index = 2'b10    ;                   
            default:    tag_index = 2'b11    ;                   
    endcase
    
    if (sop) //Print Header
    begin
        if (cmp_header) begin // completion header
        
            len      =  rx_tx
                     ? {14'b0, PUCpl.length}
                     : {CplHdr.length_h, CplHdr.length_m, CplHdr.length_l};
            tag      = {tag_index, rx_tx ?  data[125:118]     // Rx: completions are Data Mover tag = tdata[127:118]
                                         :  data[125:118]} ;  // Tx: completions are in power   tag = tdata[80:72]?
            addr     =  ram[tag];            
        end
        else begin // request header
        
            len      = {ReqHdr.length_h   , ReqHdr.length_m   , ReqHdr.length_l   };
            tag      = {tag_index, rx_tx ?  data[ 47: 40]     // Rx: requests are Power User Format(tag = tdata[47:40]
                                         :  data[ 47: 40]} ;  // Tx: requests are Data Mover format(tag = tdata[23], tdata[19], tdata [47:40]
            addr     = {ReqHdr.host_addr_h, ReqHdr.host_addr_m, ReqHdr.host_addr_l};
            ram[tag] =  addr ;            
        end
        
        $display ("T=%t %0s_%2s:%3h %8h %8h %0s  \t[%8h %8h %8h %8h] PF%1h_VF%1h/%1h L=%4h",
                  $time,str, s_rx_tx, tag, addr[63:32], addr[31:0], fmttype, data[127:96], data[95:64], 
                        data[63:32], data[31:0], ReqHdr.pf_num, ReqHdr.vf_num, ReqHdr.vf_active, len);
    end
  end
  // synthesis translate_on
endtask: display_cycle

endpackage: pcie_ss_pkg
