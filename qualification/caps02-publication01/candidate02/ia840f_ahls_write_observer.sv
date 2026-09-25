`timescale 1ns/1ps
// Passive native-bank write accounting; no memory-channel output signals.
// TARGET_RETIRED is not a publication, global-drain or reset-safety claim.
// Integrate only with the bound physical-ID-zero AXI path and a reviewed
// core/native mailbox. DMA/link fault inputs here are already synchronized.
module ia840f_ahls_write_observer #(
    parameter integer COUNTER_BITS=64
)(
    input wire clk, rst_n,
    input wire awvalid, awready,
    input wire [7:0] awlen,
    input wire [8:0] awid,
    input wire wvalid, wready, wlast,
    input wire [63:0] wstrb,
    input wire bvalid, bready,
    input wire [1:0] bresp,
    input wire [8:0] bid,
    input wire cmd_valid,
    input wire [1:0] cmd,
    input wire [63:0] cmd_expected, cmd_token,
    input wire dma_write_fault, link_fault,
    output reg cmd_ack,
    output reg armed,
    output wire empty, target_retired,
    output reg [7:0] errors,
    output reg [63:0] first_error, token, expected_bytes, baseline,
    output wire [63:0] aw_total, b_total, expected_w_beats,
    output wire [63:0] w_total, wlast_total, accepted_bytes, retired_bytes
);
    localparam [63:0] COUNT_MAX=64'hffffffffffffffff >> (64-COUNTER_BITS);
    reg [COUNTER_BITS-1:0] a,b,q,w,l,t,c;
    reg [COUNTER_BITS-1:0] an,bn,qn,wn,ln,tn,cn;
    reg [COUNTER_BITS:0] ax,bx,qx,wx,lx,tx;
    reg [7:0] en;
    reg [63:0] fn,token_n,expected_n,base_n;
    reg armed_n,empty_n,retired_n;
    reg [6:0] enabled;
    integer i,k;
    wire af=awvalid && awready;
    wire wf=wvalid && wready;
    wire bf=bvalid && bready;
    assign aw_total=a;
    assign b_total=b;
    assign expected_w_beats=q;
    assign w_total=w;
    assign wlast_total=l;
    assign accepted_bytes=t;
    assign retired_bytes=c;
    assign empty=(a==b) && (q==w) && (l==a);
    assign target_retired=armed && (errors==0) && empty &&
        (accepted_bytes>=baseline) && (retired_bytes>=baseline) &&
        ((accepted_bytes-baseline)==expected_bytes) &&
        ((retired_bytes-baseline)==expected_bytes);

    initial begin
        if(COUNTER_BITS<8 || COUNTER_BITS>64)
            $fatal(1,"COUNTER_BITS must be 8..64");
    end

    always @* begin
        enabled=0;
        for(i=0;i<64;i=i+1) enabled=enabled+{6'd0,wstrb[i]};
        ax={1'b0,a}+af;
        bx={1'b0,b}+bf;
        qx={1'b0,q}+(af ? ({1'b0,awlen}+9'd1) : 9'd0);
        wx={1'b0,w}+wf;
        lx={1'b0,l}+(wf && wlast);
        tx={1'b0,t}+(wf ? enabled : 7'd0);
        an=ax[COUNTER_BITS] ? {COUNTER_BITS{1'b1}} : ax[COUNTER_BITS-1:0];
        bn=bx[COUNTER_BITS] ? {COUNTER_BITS{1'b1}} : bx[COUNTER_BITS-1:0];
        qn=qx[COUNTER_BITS] ? {COUNTER_BITS{1'b1}} : qx[COUNTER_BITS-1:0];
        wn=wx[COUNTER_BITS] ? {COUNTER_BITS{1'b1}} : wx[COUNTER_BITS-1:0];
        ln=lx[COUNTER_BITS] ? {COUNTER_BITS{1'b1}} : lx[COUNTER_BITS-1:0];
        tn=tx[COUNTER_BITS] ? {COUNTER_BITS{1'b1}} : tx[COUNTER_BITS-1:0];
        en=errors;
        if(bf && bresp!=2'b00) en[0]=1;
        if((af && awid!=0) || (bf && bid!=0)) en[1]=1;
        if((bx>ax) || (bx>lx)) en[2]=1;
        if(ax[COUNTER_BITS] || bx[COUNTER_BITS] || qx[COUNTER_BITS] ||
           wx[COUNTER_BITS] || lx[COUNTER_BITS] || tx[COUNTER_BITS]) en[3]=1;
        if(armed && (({1'b0,tn}<{1'b0,baseline}) ||
                    (({1'b0,tn}-{1'b0,baseline})>{1'b0,expected_bytes}))) en[4]=1;
        if(dma_write_fault && (armed || (cmd_valid && cmd==1))) en[5]=1;
        if(link_fault) en[6]=1;
        empty_n=(an==bn) && (qn==wn) && (ln==an);
        cn=c;
        if(empty_n && en==0) cn=tn;
        retired_n=armed && en==0 && empty_n &&
            ({1'b0,tn}>={1'b0,baseline}) && ({1'b0,cn}>={1'b0,baseline}) &&
            (({1'b0,tn}-{1'b0,baseline})=={1'b0,expected_bytes}) &&
            (({1'b0,cn}-{1'b0,baseline})=={1'b0,expected_bytes});
        armed_n=armed;token_n=token;expected_n=expected_bytes;base_n=baseline;
        if(cmd_valid) begin
            case(cmd)
                2'd1: begin
                    if(!armed && en==0 && empty_n && !awvalid && !wvalid && !bvalid &&
                       cmd_expected!=0 && cmd_expected[1:0]==0 &&
                       cmd_expected<=64'h1fffffffc && cmd_expected<=COUNT_MAX &&
                       cmd_token!=0 && cmd_token!=token) begin
                        armed_n=1;token_n=cmd_token;expected_n=cmd_expected;base_n=cn;
                    end else en[7]=1;
                end
                2'd2: begin end // Coherent sampling is the mailbox's responsibility.
                2'd3: begin
                    if(retired_n && !awvalid && !wvalid && !bvalid) armed_n=0;
                    else en[7]=1;
                end
                default: en[7]=1;
            endcase
        end
        // Every error dominates checkpoint advancement, including command faults.
        if(en!=0) cn=c;
        fn=first_error;
        if(!first_error[63] && en!=0) begin
            // Reverse loop leaves the lowest-numbered error as first precedence.
            for(k=7;k>=0;k=k-1) begin
                if(en[k]) begin
                    fn=0;fn[63]=1;fn[7:0]=k+1;
                    if(k==0) begin fn[9:8]=bresp;fn[18:10]=bid;end
                    else if(k==1) begin fn[18:10]=(af && awid!=0) ? awid : bid;end
                end
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            a<=0;b<=0;q<=0;w<=0;l<=0;t<=0;c<=0;
            errors<=0;first_error<=0;armed<=0;token<=0;
            expected_bytes<=0;baseline<=0;cmd_ack<=0;
        end else begin
            a<=an;b<=bn;q<=qn;w<=wn;l<=ln;t<=tn;c<=cn;
            errors<=en;first_error<=fn;armed<=armed_n;token<=token_n;
            expected_bytes<=expected_n;baseline<=base_n;cmd_ack<=cmd_valid;
        end
    end
endmodule
