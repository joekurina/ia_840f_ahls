// Synthetic byte-addressed memory endpoint, NOT a DDR/PCIe device model.
// Serial requests, legal AXI byte lanes, retained responses and deterministic stalls.
`timescale 1ns/1ps
module ahls_axi_memory_model #(
    parameter int BYTES = 65536,
    parameter int ENDPOINT = 0,
    parameter bit LINEAR_HOST = 0
)(ofs_plat_axi_mem_if.to_source mem);
    byte unsigned storage[0:BYTES-1];
    int cycle = 0;
    int ar_count = 0, aw_count = 0, r_count = 0, w_count = 0, b_count = 0;
    int w_bytes = 0;
    int read_stalls = 0, write_stalls = 0;
    bit rd_active = 0, wr_active = 0, b_pending = 0;
    longint unsigned rd_addr, wr_addr;
    int rd_len, wr_len, rd_size, wr_size, rd_burst, wr_burst;
    int rd_index, wr_index, b_delay;
    logic [31:0] rd_id, wr_id, rd_user, wr_user;

    initial for (int i=0; i<BYTES; i++) storage[i] = 8'ha5;

    task automatic write_int(input int addr, input int value);
        for (int j=0; j<4; j++) storage[addr+j] = value[j*8+:8];
    endtask
    function automatic int read_int(input int addr);
        int value;
        for (int j=0; j<4; j++) value[j*8+:8] = storage[addr+j];
        return value;
    endfunction
    function automatic longint unsigned beat_addr(
        input longint unsigned addr, input int len, size, burst, index);
        longint unsigned step, span, base;
        step = 64'd1 << size;
        if (LINEAR_HOST || burst==1) return addr + index*step;
        if (burst==0) return addr;
        span = (len+1)*step;
        base = (addr/span)*span;
        return base + ((addr-base+index*step)%span);
    endfunction
    task automatic validate(input longint unsigned addr,
                            input int len, size, burst);
        longint unsigned last_addr;
        if (size>6 || size<0 || (addr % (64'd1<<size))!=0)
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d address/size addr=%h size=%0d",ENDPOINT,addr,size);
        if (!LINEAR_HOST && (burst==3 ||
            (burst==2 && !((len+1)==2 || (len+1)==4 || (len+1)==8 || (len+1)==16))))
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d illegal AXI burst=%0d len=%0d",ENDPOINT,burst,len);
        last_addr = beat_addr(addr,len,size,burst,len);
        if (addr>=BYTES || last_addr+(64'd1<<size)>BYTES)
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d model range addr=%h last=%h",ENDPOINT,addr,last_addr);
        if (!LINEAR_HOST && burst==1 && (addr>>12)!=((last_addr+(64'd1<<size)-1)>>12))
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d crosses AXI 4KiB",ENDPOINT);
    endtask

    assign mem.arready = mem.reset_n && !rd_active && !mem.rvalid && cycle%3!=0;
    assign mem.awready = mem.reset_n && !wr_active && !b_pending && !mem.bvalid && cycle%4!=0;
    assign mem.wready = mem.reset_n && wr_active && cycle%5!=0 && cycle%5!=1;

    always @(posedge mem.clk) begin : endpoint
        longint unsigned a, line_base;
        int first_lane, last_lane;
        cycle <= cycle+1;
        if (!mem.reset_n) begin
            rd_active <= 0; wr_active <= 0; b_pending <= 0;
            mem.rvalid <= 0; mem.r <= '0;
            mem.bvalid <= 0; mem.b <= '0;
        end else begin
            if (mem.rvalid && !mem.rready) read_stalls <= read_stalls+1;
            if (mem.wvalid && !mem.wready) write_stalls <= write_stalls+1;
            if (mem.rvalid && mem.rready) begin
                mem.rvalid <= 0;
                r_count <= r_count+1;
            end
            if (mem.bvalid && mem.bready) begin
                mem.bvalid <= 0;
                b_count <= b_count+1;
            end
            if (mem.arvalid && mem.arready) begin
                validate(mem.ar.addr,mem.ar.len,mem.ar.size,mem.ar.burst);
                rd_addr <= mem.ar.addr; rd_len <= mem.ar.len;
                rd_size <= mem.ar.size; rd_burst <= mem.ar.burst;
                rd_id <= mem.ar.id; rd_user <= mem.ar.user;
                rd_index <= 0; rd_active <= 1; ar_count <= ar_count+1;
            end
            if (rd_active && (!mem.rvalid || mem.rready) && cycle%4!=0) begin
                a = beat_addr(rd_addr,rd_len,rd_size,rd_burst,rd_index);
                line_base = (a/64)*64;
                for (int j=0; j<64; j++) mem.r.data[j*8+:8] <= storage[line_base+j];
                mem.r.id <= rd_id;
                mem.r.user <= rd_user;
                mem.r.resp <= 2'b00;
                mem.r.last <= rd_index==rd_len;
                mem.rvalid <= 1;
                rd_index <= rd_index+1;
                if (rd_index==rd_len) rd_active <= 0;
            end
            if (mem.awvalid && mem.awready) begin
                validate(mem.aw.addr,mem.aw.len,mem.aw.size,mem.aw.burst);
                wr_addr <= mem.aw.addr; wr_len <= mem.aw.len;
                wr_size <= mem.aw.size; wr_burst <= mem.aw.burst;
                wr_id <= mem.aw.id; wr_user <= mem.aw.user;
                wr_index <= 0; wr_active <= 1; aw_count <= aw_count+1;
            end
            if (mem.wvalid && mem.wready) begin
                a = beat_addr(wr_addr,wr_len,wr_size,wr_burst,wr_index);
                line_base = (a/64)*64;
                first_lane = a%64; last_lane = first_lane+(1<<wr_size)-1;
                for (int j=0; j<64; j++) begin
                    if (mem.w.strb[j]) begin
                        if (j<first_lane || j>last_lane)
                            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d strobe outside active lanes",ENDPOINT);
                        storage[line_base+j] = mem.w.data[j*8+:8];
                    end
                end
                if (mem.w.last !== (wr_index==wr_len))
                    $fatal(1,"AHLS_PATH_FAIL endpoint=%0d WLAST",ENDPOINT);
                wr_index <= wr_index+1; w_count <= w_count+1;
                w_bytes <= w_bytes+$countones(mem.w.strb);
                if (wr_index==wr_len) begin
                    wr_active <= 0; b_pending <= 1; b_delay <= 9+ENDPOINT;
                end
            end
            if (b_pending) begin
                if (b_delay!=0) b_delay <= b_delay-1;
                else begin
                    mem.b.id <= wr_id; mem.b.user <= wr_user; mem.b.resp <= 2'b00;
                    mem.bvalid <= 1; b_pending <= 0;
                end
            end
        end
    end
endmodule
