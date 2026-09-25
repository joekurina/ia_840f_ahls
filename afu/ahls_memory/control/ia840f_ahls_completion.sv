// Finite-work completion adapted from the pinned PIM local_mem_engine_axi:
// producer finished AND complete output extent AND balanced AW/W/B retirement.
// Count after page splitting, before split B responses are suppressed. All
// signals are in one AFU clock domain. This block drives no memory channel.
module ia840f_ahls_completion (
    input wire clk, reset_n,
    input wire start,
    input wire [32:0] expected_bytes,
    input wire producer_done,
    input wire access_fault, dma_write_attempt,
    input wire aw_fire,
    input wire [4:0] awlen,
    input wire w_fire, wlast,
    input wire [63:0] wstrb,
    input wire b_fire,
    input wire [1:0] bresp,
    output logic busy, done,
    output logic [7:0] errors,
    output logic [32:0] accepted_bytes
);
    logic [32:0] target;
    logic producer_finished;
    logic [31:0] aw_count, last_count, b_count;
    logic [33:0] aw_beats, w_count;
    logic byte_inc_valid;
    logic [6:0] byte_inc;

    // A registered balanced population count separates strobe decoding from
    // the running byte counter. This is the HLS partial-store adaptation.
    function automatic logic [6:0] enabled_bytes(input logic [63:0] strobe);
        logic [3:0] octet[8];
        logic [4:0] pair[4];
        logic [5:0] half[2];
        for (int i=0;i<8;i++) begin
            octet[i]=0;
            for(int j=0;j<8;j++) octet[i]=octet[i]+{3'b0,strobe[8*i+j]};
        end
        for(int i=0;i<4;i++) pair[i]={1'b0,octet[2*i]}+{1'b0,octet[2*i+1]};
        for(int i=0;i<2;i++) half[i]={1'b0,pair[2*i]}+{1'b0,pair[2*i+1]};
        return {1'b0,half[0]}+{1'b0,half[1]};
    endfunction

    wire last_fire=w_fire && wlast;
    wire [33:0] bytes_next={1'b0,accepted_bytes}+(byte_inc_valid ? {27'b0,byte_inc} : 34'd0);
    logic [7:0] fault_now;
    always_comb begin
        fault_now=0;
        if(busy) begin
            if(access_fault || dma_write_attempt) fault_now[0]=1;
            if(b_fire && bresp!=0) fault_now[1]=1;
            if(b_fire && ({1'b0,b_count}>={1'b0,aw_count}+33'(aw_fire) ||
                          {1'b0,b_count}>={1'b0,last_count}+33'(last_fire))) fault_now[2]=1;
            if(bytes_next>{1'b0,target}) fault_now[3]=1;
            if((aw_fire && (&aw_count)) || (b_fire && (&b_count)) ||
               (last_fire && (&last_count)) || (w_fire && (&w_count)) ||
               (aw_fire && aw_beats>34'h3ffffffdf)) fault_now[4]=1;
            if(start) fault_now[5]=1;
        end
        if(start && (expected_bytes==0 || expected_bytes[1:0]!=0)) fault_now[6]=1;
    end

    always_ff @(posedge clk) begin
        if(!reset_n) begin
            busy<=0;done<=0;errors<=0;accepted_bytes<=0;target<=0;
            producer_finished<=0;aw_count<=0;last_count<=0;b_count<=0;
            aw_beats<=0;w_count<=0;byte_inc_valid<=0;byte_inc<=0;
        end else begin
            // Errors remain visible; no clear/reset/retry command is provided.
            errors<=errors | fault_now;
            if(start && !busy && errors==0 && fault_now==0) begin
                busy<=1;done<=0;accepted_bytes<=0;target<=expected_bytes;
                producer_finished<=0;aw_count<=0;last_count<=0;b_count<=0;
                aw_beats<=0;w_count<=0;byte_inc_valid<=0;byte_inc<=0;
            end else if(busy) begin
                if(producer_done) producer_finished<=1;
                byte_inc_valid<=w_fire;
                if(w_fire) byte_inc<=enabled_bytes(wstrb);
                if(byte_inc_valid) accepted_bytes<=bytes_next[32:0];
                if(aw_fire) begin
                    aw_count<=aw_count+1'b1;
                    aw_beats<=aw_beats+{29'd0,awlen}+34'd1;
                end
                if(w_fire) w_count<=w_count+1'b1;
                if(last_fire) last_count<=last_count+1'b1;
                if(b_fire) b_count<=b_count+1'b1;
                // Nonempty complete byte credit prevents AW==B from passing
                // before the final buffered HLS output has reached this point.
                if(producer_finished && accepted_bytes==target &&
                   aw_count!=0 && aw_count==b_count && last_count==aw_count &&
                   w_count==aw_beats && !byte_inc_valid &&
                   !aw_fire && !w_fire && !b_fire && errors==0 && fault_now==0) begin
                    done<=1;busy<=0;
                end
            end else byte_inc_valid<=0;
            if(fault_now!=0) done<=0;
        end
    end
endmodule
