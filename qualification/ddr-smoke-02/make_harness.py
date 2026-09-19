#!/usr/bin/env python3
"""Render explicit wiring from captured real module ports; no HDL execution."""
from pathlib import Path
import re,json
P=Path(__file__).resolve().parent
s=(P/'evidence/mem_ss.v').read_text().split(');',1)[0]
ports=re.findall(r'\b(input|output|inout)\s+wire\s*(\[[^\]]+\])?\s*(\w+)',s)
assert len(ports)==len(set(x[2] for x in ports))
o=['`timescale 1ns/1ps','module tb_mem_ss_smoke;','  bit [1:0] done = 0;','  bit traffic_enabled = 0;']
for d,w,n in ports:o.append(f'  {"logic" if d=="input" and "alert" not in n else "wire"} {w} {n};')
o+=['  mem_ss dut (',',\n'.join(f'    .{n}({n})' for d,w,n in ports),'  );']
for c,model in enumerate(['ed_sim_mem','ed_sim_mem_group1']):
 m=(P/f'evidence/{model}.v').read_text().split(');',1)[0]
 mp=re.findall(r'\b(input|output|inout)\s+wire\s*(\[[^\]]+\])?\s*(\w+)',m)
 assert len(mp)==16
 o += [f'  {model} memory{c} (',',\n'.join(f'    .{n}(mem{c}_ddr4_{n[4:]})' for d,w,n in mp),'  );']
 o += [f'  initial mem{c}_pll_ref_clk = 0;',f'  always #15.00015 mem{c}_pll_ref_clk = ~mem{c}_pll_ref_clk;',f'  initial mem{c}_oct_rzqin = 1\'b0;']
o += ['''  // Actual reset controller is clocked from EMIF0 ref_clk_out and reset by
  // EMIF0 pll_locked (evidence/mem_ss_inner.v). Implementation is encrypted.
  // Initial cold assertion is a REVIEW ITEM; no warm/repeated reset is issued.
  initial begin
    app_ss_rst_req = 0;
    app_ss_cold_rst_n = 0;
    repeat (100) @(negedge mem0_pll_ref_clk);
    app_ss_cold_rst_n = 1;
    wait (mem0_ss_app_usr_reset_n === 1'b1 &&
          mem1_ss_app_usr_reset_n === 1'b1 &&
          mem0_local_cal_success === 1'b1 &&
          mem1_local_cal_success === 1'b1 &&
          ss_app_cold_rst_ack_n === 1'b1);
    traffic_enabled = 1;
  end
  initial begin
    #500000;
    if (!traffic_enabled) $fatal(1, "DDR_SMOKE_FAIL startup_timeout_500us");
  end
  initial begin
    #1000000;
    $fatal(1, "DDR_SMOKE_FAIL watchdog_1ms");
  end
  always @(mem0_local_cal_fail or mem1_local_cal_fail)
    if (mem0_local_cal_fail === 1'b1 || mem1_local_cal_fail === 1'b1)
      $fatal(1, "DDR_SMOKE_FAIL calibration_failure");
  initial begin
    wait (done === 2'b11);
    $display("DDR_SMOKE_PASS channels=2 writes=4 reads=4 bits_checked=2048");
    $finish;
  end
  function automatic logic [511:0] pattern(input int channel, input int word_index);
    for (int lane=0; lane<16; lane++)
      pattern[lane*32 +: 32] = 32'hA5963C69 ^ (32'h10204081 * (lane+1)) ^
                               (channel ? 32'hD3B75E19 : 32'h29C4A6F0) ^
                               (word_index ? 32'hF0E1D2C3 : 32'h13579BDF);
  endfunction
''']
for c in range(2):
 a=f'i{c}_app_ss_mm_'; b=f'i{c}_ss_app_mm_';clk=f'mem{c}_ss_app_usr_clk'
 body='''
  task automatic write_C(input int index);
    bit aw_done, w_done, b_done;
    int cycles;
    logic [8:0] expected_id;
    expected_id = 9'(C*16 + index + 1);
    aw_done=0; w_done=0; b_done=0; cycles=0;
    @(negedge CLK);
    Aawaddr=34'(index*64); Aawid=expected_id; Aawvalid=1;
    Awdata=pattern(C,index); Awvalid=1;
    // AW and W remain independent. No requirement on their acceptance order.
    while (!b_done && cycles < 4096) begin
      @(posedge CLK);
      cycles++;
      if (Aawvalid && Bawready === 1'b1) aw_done=1;
      if (Awvalid && Bwready === 1'b1) w_done=1;
      if (Abready && Bbvalid === 1'b1) begin
        if ($isunknown({Bbid,Bbresp,Bbuser}) || Bbid !== expected_id || Bbresp !== 2'b00)
          $fatal(1,"DDR_SMOKE_FAIL channel=C write index=%0d id/resp/XZ",index);
        b_done=1;
      end
      @(negedge CLK);
      if (aw_done) Aawvalid=0;
      if (w_done) Awvalid=0;
      Abready=aw_done && w_done && !b_done;
    end
    Abready=0;
    if (!b_done) $fatal(1,"DDR_SMOKE_FAIL channel=C write_timeout index=%0d",index);
  endtask
  task automatic read_C(input int index);
    bit ar_done, r_done;
    int cycles;
    logic [8:0] expected_id;
    expected_id = 9'(C*16 + index + 5);
    ar_done=0; r_done=0; cycles=0;
    @(negedge CLK);
    Aaraddr=34'(index*64); Aarid=expected_id; Aarvalid=1;
    while (!r_done && cycles < 4096) begin
      @(posedge CLK);
      cycles++;
      if (Aarvalid && Barready === 1'b1) ar_done=1;
      if (Arready && Brvalid === 1'b1) begin
        if ($isunknown({Brid,Brresp,Brlast,Brdata}) ||
            Brid !== expected_id || Brresp !== 2'b00 || Brlast !== 1'b1 ||
            Brdata !== pattern(C,index))
          $fatal(1,"DDR_SMOKE_FAIL channel=C read index=%0d id/resp/last/data/XZ",index);
        r_done=1;
      end
      @(negedge CLK);
      if (ar_done) Aarvalid=0;
      Arready=ar_done && !r_done;
    end
    Arready=0;
    if (!r_done) $fatal(1,"DDR_SMOKE_FAIL channel=C read_timeout index=%0d",index);
  endtask
  initial begin
INIT
    wait (traffic_enabled);
    write_C(0); write_C(1);
    read_C(0); read_C(1);
    $display("DDR_SMOKE_CHANNEL_DONE channel=C writes=2 reads=2");
    done[C]=1;
  end
  always @(posedge CLK) if (traffic_enabled) begin
    if (memC_ss_app_usr_reset_n !== 1'b1 || memC_local_cal_success !== 1'b1 ||
        memC_local_cal_fail !== 1'b0)
      $fatal(1,"DDR_SMOKE_FAIL channel=C status_lost_or_XZ");
  end
'''
 init=[]
 for d,w,n in ports:
  if d=='input' and n.startswith(a):
   val="'0"
   if n.endswith(('awsize','arsize')):val="3'd6"
   if n.endswith(('awburst','arburst')):val="2'b01"
   if n.endswith(('wstrb','wlast')):val="'1"
   init.append(f'    {n}={val};')
 body=body.replace('INIT','\n'.join(init)).replace('CLK',clk).replace('memC',f'mem{c}').replace('write_C',f'write_{c}').replace('read_C',f'read_{c}')
 body=re.sub(r'\bC\b',str(c),body)
 body=re.sub(r'\bA(?=[a-z])',a,body);body=re.sub(r'\bB(?=[a-z])',b,body)
 o.append(body)
o += ['endmodule','']
(P/'tb_mem_ss_smoke.sv').write_text('\n'.join(o))
(P/'ports.json').write_text(json.dumps(ports,indent=2)+'\n')
print('rendered actual DUT ports',len(ports),'two real 16-pin models')
