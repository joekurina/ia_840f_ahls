// Synthetic byte-addressed memory endpoint, NOT a DDR/PCIe device model.
// Serial requests, legal AXI byte lanes, retained responses and deterministic stalls.
`timescale 1ns/1ps
module ahls_axi_memory_model #(
    parameter int BYTES = 65536,
    parameter int ENDPOINT = 0,
    parameter bit LINEAR_HOST = 0,
    parameter logic [63:0] BASE = 0
)(ofs_plat_axi_mem_if.to_source mem);
    byte unsigned storage[0:BYTES-1];
    int cycle = 0;
    int aw_stalls=0, ar_stalls=0, last_w_stalls=0, b_stalls=0;
    int forced_last_hold=0;
    int response_delay_cycles=9+ENDPOINT;
    bit inject_next_b_error=0;
    longint unsigned read_lines[$], write_lines[$];
    longint unsigned read_lo[2],read_hi[2];
    int read_regions=0;
    longint unsigned write_lo=0,write_hi=0;
    byte unsigned expected_storage[0:BYTES-1];
    bit expected_write[0:BYTES-1],seen_write[0:BYTES-1];
    int reference_bytes=0,accepted_reference_bytes=0;
    bit aw_held=0,w_held=0,ar_held=0;
    logic [$bits(mem.aw)-1:0] held_aw;
    logic [$bits(mem.w)-1:0] held_w;
    logic [$bits(mem.ar)-1:0] held_ar;

    int ar_count = 0, aw_count = 0, r_count = 0, w_count = 0, b_count = 0;
    int w_bytes = 0;
    int read_stalls = 0, write_stalls = 0;
    bit rd_active = 0, wr_active = 0, b_pending = 0;
    longint unsigned rd_addr, wr_addr;
    int rd_len, wr_len, rd_size, wr_size, rd_burst, wr_burst;
    int rd_index, wr_index, b_delay;
    logic [31:0] rd_id, wr_id, rd_user, wr_user;

    task automatic begin_phase();
        if(read_lines.size() || write_lines.size() || rd_active || wr_active || b_pending || mem.bvalid || mem.rvalid)
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d previous phase not empty",ENDPOINT);
        read_regions=0;write_lo=0;write_hi=0;reference_bytes=0;accepted_reference_bytes=0;
        for(int i=0;i<BYTES;i++)begin expected_write[i]=0;seen_write[i]=0;end
    endtask
    task automatic allow_read(input longint unsigned addr,input int bytes);
        if(read_regions>=2 || addr<BASE || addr+bytes>BASE+BYTES)$fatal(1,"read window range");
        read_lo[read_regions]=addr;read_hi[read_regions]=addr+bytes;read_regions++;
    endtask
    task automatic allow_write(input longint unsigned addr,input int bytes);
        if(addr<BASE || addr+bytes>BASE+BYTES)$fatal(1,"write window range");
        write_lo=addr;write_hi=addr+bytes;
    endtask
    task automatic expect_byte(input longint unsigned addr,input byte unsigned value);
        int idx;
        if(addr<BASE || addr>=BASE+BYTES)$fatal(1,"expected byte range");
        idx=int'(addr-BASE);
        if(expected_write[idx])$fatal(1,"duplicate expected byte");
        expected_write[idx]=1;expected_storage[idx]=value;reference_bytes++;
    endtask
    task automatic expect_read_span(input longint unsigned addr,input int bytes);
        longint unsigned lo,hi;
        lo=addr & ~64'd63;hi=(addr+bytes+63)&~64'd63;
        for(longint unsigned a=lo;a<hi;a+=64)read_lines.push_back(a);
    endtask
    task automatic expect_write_span(input longint unsigned addr,input int bytes);
        longint unsigned lo,hi;
        lo=addr & ~64'd63;hi=(addr+bytes+63)&~64'd63;
        for(longint unsigned a=lo;a<hi;a+=64)write_lines.push_back(a);
    endtask
    task automatic check_writes_complete(input int bytes);
        if(reference_bytes!=bytes || accepted_reference_bytes!=bytes || write_lines.size() ||
           wr_active || b_pending || mem.bvalid || aw_count!=b_count)
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d write credit ref=%0d seen=%0d wanted=%0d AW=%0d B=%0d",ENDPOINT,reference_bytes,accepted_reference_bytes,bytes,aw_count,b_count);
        for(int i=0;i<BYTES;i++)if(expected_write[i] && !seen_write[i])$fatal(1,"missing expected byte");
    endtask
    task automatic check_reads_complete();
        if(read_lines.size() || rd_active || mem.rvalid)$fatal(1,"read ledger not empty");
    endtask

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
        if (size!=6 || (addr % 64)!=0)
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d address/size addr=%h size=%0d",ENDPOINT,addr,size);
        if (!LINEAR_HOST && (burst==3 ||
            (burst==2 && !((len+1)==2 || (len+1)==4 || (len+1)==8 || (len+1)==16))))
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d illegal AXI burst=%0d len=%0d",ENDPOINT,burst,len);
        last_addr = beat_addr(addr,len,size,burst,len);
        if (addr<BASE || addr>=BASE+BYTES || last_addr+(64'd1<<size)>BASE+BYTES)
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d model range addr=%h last=%h",ENDPOINT,addr,last_addr);
        if (!LINEAR_HOST && burst==1 && (addr>>12)!=((last_addr+(64'd1<<size)-1)>>12))
            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d crosses AXI 4KiB",ENDPOINT);
    endtask

    assign mem.arready = mem.reset_n && !rd_active && !mem.rvalid && cycle%3!=0;
    assign mem.awready = mem.reset_n && !wr_active && !b_pending && !mem.bvalid && cycle%4!=0;
    assign mem.wready = mem.reset_n && wr_active && cycle%5!=0 && cycle%5!=1 && !(wr_index==wr_len && forced_last_hold>0);

    always @(posedge mem.clk) begin : endpoint
        longint unsigned a, line_base;
        int first_lane, last_lane;
        longint unsigned expected_line;
        bit allowed;
        cycle <= cycle+1;
        if (!mem.reset_n) begin
            rd_active <= 0; wr_active <= 0; b_pending <= 0;
            mem.rvalid <= 0; mem.r <= '0;
            mem.bvalid <= 0; mem.b <= '0;
        end else begin
            if(aw_held && (!mem.awvalid || mem.aw!==held_aw))$fatal(1,"AW unstable under stall");
            if(w_held && (!mem.wvalid || mem.w!==held_w))$fatal(1,"W unstable under stall");
            if(ar_held && (!mem.arvalid || mem.ar!==held_ar))$fatal(1,"AR unstable under stall");
            aw_held<=mem.awvalid&&!mem.awready;held_aw<=mem.aw;
            w_held<=mem.wvalid&&!mem.wready;held_w<=mem.w;
            ar_held<=mem.arvalid&&!mem.arready;held_ar<=mem.ar;
            if(mem.awvalid&&!mem.awready)aw_stalls<=aw_stalls+1;
            if(mem.arvalid&&!mem.arready)ar_stalls<=ar_stalls+1;
            if(mem.bvalid&&!mem.bready)b_stalls<=b_stalls+1;
            if(mem.wvalid&&!mem.wready && mem.w.last)last_w_stalls<=last_w_stalls+1;
            if(wr_active && wr_index==wr_len && mem.wvalid && forced_last_hold>0)forced_last_hold<=forced_last_hold-1;
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
                if($isunknown({mem.ar.addr,mem.ar.len,mem.ar.size,mem.ar.burst,mem.ar.id}))$fatal(1,"unknown AR");
                validate(mem.ar.addr,mem.ar.len,mem.ar.size,mem.ar.burst);
                for(int i=0;i<=int'(mem.ar.len);i++)begin
                    a=beat_addr(mem.ar.addr,mem.ar.len,mem.ar.size,mem.ar.burst,i);
                    if(!read_lines.size())$fatal(1,"uncredited AR endpoint=%0d addr=%h",ENDPOINT,a);
                    expected_line=read_lines.pop_front();
                    if(a!==expected_line)$fatal(1,"AR address ledger endpoint=%0d actual=%h expected=%h",ENDPOINT,a,expected_line);
                    allowed=0;for(int r=0;r<read_regions;r++)if(a>=read_lo[r]&&a+64<=read_hi[r])allowed=1;
                    if(!allowed)$fatal(1,"AR outside reserved read envelope endpoint=%0d addr=%h",ENDPOINT,a);
                end
                rd_addr <= mem.ar.addr; rd_len <= mem.ar.len;
                rd_size <= mem.ar.size; rd_burst <= mem.ar.burst;
                rd_id <= mem.ar.id; rd_user <= mem.ar.user;
                rd_index <= 0; rd_active <= 1; ar_count <= ar_count+1;
            end
            if (rd_active && (!mem.rvalid || mem.rready) && cycle%4!=0) begin
                a = beat_addr(rd_addr,rd_len,rd_size,rd_burst,rd_index);
                line_base = (a/64)*64;
                for (int j=0; j<64; j++) mem.r.data[j*8+:8] <= storage[line_base-BASE+j];
                mem.r.id <= rd_id;
                mem.r.user <= rd_user;
                mem.r.resp <= 2'b00;
                mem.r.last <= rd_index==rd_len;
                mem.rvalid <= 1;
                rd_index <= rd_index+1;
                if (rd_index==rd_len) rd_active <= 0;
            end
            if (mem.awvalid && mem.awready) begin
                if($isunknown({mem.aw.addr,mem.aw.len,mem.aw.size,mem.aw.burst,mem.aw.id}))$fatal(1,"unknown AW");
                validate(mem.aw.addr,mem.aw.len,mem.aw.size,mem.aw.burst);
                for(int i=0;i<=int'(mem.aw.len);i++)begin
                    a=beat_addr(mem.aw.addr,mem.aw.len,mem.aw.size,mem.aw.burst,i);
                    if(!write_lines.size())$fatal(1,"uncredited AW endpoint=%0d addr=%h",ENDPOINT,a);
                    expected_line=write_lines.pop_front();
                    if(a!==expected_line)$fatal(1,"AW address ledger endpoint=%0d actual=%h expected=%h",ENDPOINT,a,expected_line);
                    if(a<write_lo || a+64>write_hi)$fatal(1,"AW outside reserved envelope");
                end
                forced_last_hold<=3+ENDPOINT;
                wr_addr <= mem.aw.addr; wr_len <= mem.aw.len;
                wr_size <= mem.aw.size; wr_burst <= mem.aw.burst;
                wr_id <= mem.aw.id; wr_user <= mem.aw.user;
                wr_index <= 0; wr_active <= 1; aw_count <= aw_count+1;
            end
            if (mem.wvalid && mem.wready) begin
                a = beat_addr(wr_addr,wr_len,wr_size,wr_burst,wr_index);
                line_base = (a/64)*64;
                first_lane = a%64; last_lane = first_lane+(1<<wr_size)-1;
                if($isunknown(mem.w.strb) || $isunknown(mem.w.last))$fatal(1,"unknown W control");
                for (int j=0; j<64; j++) begin
                    if (mem.w.strb[j]) begin
                        if(!expected_write[line_base-BASE+j] || seen_write[line_base-BASE+j])$fatal(1,"unexpected/duplicate write byte endpoint=%0d addr=%h",ENDPOINT,line_base+j);
                        if(mem.w.data[j*8+:8]!==expected_storage[line_base-BASE+j])$fatal(1,"write data oracle endpoint=%0d addr=%h actual=%h expected=%h",ENDPOINT,line_base+j,mem.w.data[j*8+:8],expected_storage[line_base-BASE+j]);
                        seen_write[line_base-BASE+j]=1;accepted_reference_bytes++;
                        if (j<first_lane || j>last_lane)
                            $fatal(1,"AHLS_PATH_FAIL endpoint=%0d strobe outside active lanes",ENDPOINT);
                        storage[line_base-BASE+j] = mem.w.data[j*8+:8];
                    end
                end
                if (mem.w.last !== (wr_index==wr_len))
                    $fatal(1,"AHLS_PATH_FAIL endpoint=%0d WLAST",ENDPOINT);
                wr_index <= wr_index+1; w_count <= w_count+1;
                w_bytes <= w_bytes+$countones(mem.w.strb);
                if (wr_index==wr_len) begin
                    wr_active <= 0; b_pending <= 1; b_delay <= response_delay_cycles;
                end
            end
            if (b_pending) begin
                if (b_delay!=0) b_delay <= b_delay-1;
                else begin
                    mem.b.id <= wr_id; mem.b.user <= wr_user; mem.b.resp <= inject_next_b_error ? 2'b10 : 2'b00;
                    inject_next_b_error<=0;
                    mem.bvalid <= 1; b_pending <= 0;
                end
            end
        end
    end
endmodule
