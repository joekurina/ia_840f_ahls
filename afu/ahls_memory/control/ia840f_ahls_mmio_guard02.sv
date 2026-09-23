// Full-address AXI-Lite admission before the generated low-bit PD router.
// This gate is not a DMA/kernel drain, reset/PR protocol or PCIe ordering proof.
`include "ofs_plat_if.vh"
module ia840f_ahls_mmio_guard (
    ofs_plat_axi_mem_lite_if.to_source upstream,
    ofs_plat_axi_mem_lite_if.to_sink downstream
);
    wire clk = upstream.clk;
    wire reset_n = upstream.reset_n;
    if (upstream.ADDR_WIDTH != 20 || downstream.ADDR_WIDTH != 20 ||
        upstream.DATA_WIDTH != 64 || downstream.DATA_WIDTH != 64 ||
        upstream.RID_WIDTH != 16 || downstream.RID_WIDTH != 16 ||
        upstream.WID_WIDTH != 16 || downstream.WID_WIDTH != 16 ||
        upstream.USER_WIDTH != 1 || downstream.USER_WIDTH != 1) begin : bad_geometry
        IA840F_MMIO_GUARD_UNSUPPORTED_GEOMETRY reject();
    end
    typedef enum logic [1:0] {W_COLLECT, W_SEND, W_WAIT, W_REPLY} wstate_t;
    typedef enum logic [1:0] {R_IDLE, R_SEND, R_WAIT, R_REPLY} rstate_t;
    wstate_t ws;
    rstate_t rs;
    logic have_aw, have_w, sent_aw, sent_w;
    logic [$bits(upstream.aw)-1:0] aw_hold;
    logic [$bits(upstream.w)-1:0] w_hold;
    logic [$bits(upstream.ar)-1:0] ar_hold;
    logic [19:0] wa, ra;
    logic [15:0] wid, rid;
    logic wu, ru;
    logic [2:0] wsize;
    logic [7:0] wstrb;
    logic [1:0] bresp, rresp;
    logic [63:0] rdata;
    logic [31:0] write_faults, read_faults;
    logic [63:0] first_write_fault, first_read_fault;

    function automatic logic fabric_address(input logic [19:0] a);
        return a < 20'h10100; // DMA aperture + the exact 256-byte kernel span
    endfunction
    function automatic logic diagnostic_address(input logic [19:0] a);
        return a >= 20'h20000 && a < 20'h20020;
    endfunction
    function automatic logic [3:0] write_reason(input logic [19:0] addr,
        input logic [2:0] size, input logic [7:0] strb);
        if (!fabric_address(addr) && !diagnostic_address(addr)) return 4'd1;
        if (addr[2:0] != 0 || size != 3 || strb != 8'hff) return 4'd2;
        if (diagnostic_address(addr)) return 4'd3; // read-only telemetry
        return 0;
    endfunction
    function automatic logic [3:0] read_reason(input logic [19:0] a,
                                               input logic [2:0] size);
        if (!fabric_address(a) && !diagnostic_address(a)) return 4'd1;
        if (a[2:0] != 0 || size != 3) return 4'd2;
        return 0;
    endfunction
    function automatic logic [63:0] fault_word(input logic [19:0] a,
        input logic [3:0] reason, input logic [1:0] resp);
        logic [63:0] v;
        v='0;v[63]=1;v[33:32]=resp;v[27:24]=reason;v[19:0]=a;
        return v;
    endfunction
    function automatic logic [63:0] diagnostic_data(input logic [19:0] a);
        case(a)
            20'h20000: return 64'h4d4d494f47524431; // MMIOGRD1
            20'h20008: return {read_faults,write_faults};
            20'h20010: return first_write_fault;
            20'h20018: return first_read_fault;
            default: return 0;
        endcase
    endfunction
    wire [3:0] wreason = write_reason(wa,wsize,wstrb);
    wire [3:0] rreason = read_reason(upstream.ar.addr, upstream.ar.size);
    wire bad_local_write = ws==W_COLLECT && have_aw && have_w && wreason!=0;
    wire bad_downstream_write = ws==W_WAIT && downstream.bvalid && downstream.b.resp!=0;
    wire bad_local_read = upstream.arvalid && upstream.arready && rreason!=0;
    wire bad_downstream_read = rs==R_WAIT && downstream.rvalid && downstream.r.resp!=0;

    // One operation at a time. A status read waits behind a write already
    // presented here, including independently arriving AW and W. This does
    // not order a posted PCIe write that has not yet reached this interface.
    assign upstream.awready = reset_n && ws==W_COLLECT && rs==R_IDLE && !have_aw;
    assign upstream.wready = reset_n && ws==W_COLLECT && rs==R_IDLE && !have_w;
    assign upstream.arready = reset_n && rs==R_IDLE && ws==W_COLLECT &&
        !have_aw && !have_w && !upstream.awvalid && !upstream.wvalid;
    assign downstream.aw = aw_hold;
    assign downstream.w = w_hold;
    assign downstream.ar = ar_hold;
    assign downstream.awvalid = reset_n && ws==W_SEND && !sent_aw;
    assign downstream.wvalid = reset_n && ws==W_SEND && !sent_w;
    assign downstream.bready = reset_n && ws==W_WAIT;
    assign downstream.arvalid = reset_n && rs==R_SEND;
    assign downstream.rready = reset_n && rs==R_WAIT;
    assign upstream.bvalid = reset_n && ws==W_REPLY;
    assign upstream.rvalid = reset_n && rs==R_REPLY;
    always_comb begin
        upstream.b='0;upstream.b.id=wid;upstream.b.user=wu;upstream.b.resp=bresp;
        upstream.r='0;upstream.r.id=rid;upstream.r.user=ru;
        upstream.r.data=rdata;upstream.r.resp=rresp;
    end
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            ws<=W_COLLECT;rs<=R_IDLE;have_aw<=0;have_w<=0;sent_aw<=0;sent_w<=0;
            aw_hold<='0;w_hold<='0;ar_hold<='0;wa<=0;ra<=0;
            wid<=0;rid<=0;wu<=0;ru<=0;wsize<=0;wstrb<=0;
            bresp<=0;rresp<=0;rdata<=0;
            write_faults<=0;read_faults<=0;first_write_fault<=0;first_read_fault<=0;
        end else begin
            if (upstream.awvalid && upstream.awready) begin
                aw_hold<=upstream.aw;wa<=upstream.aw.addr;wid<=upstream.aw.id;
                wu<=upstream.aw.user;wsize<=upstream.aw.size;have_aw<=1;
            end
            if (upstream.wvalid && upstream.wready) begin
                w_hold<=upstream.w;wstrb<=upstream.w.strb;have_w<=1;
            end
            case(ws)
                W_COLLECT: if(have_aw && have_w) begin
                    if(wreason!=0) begin bresp<=(wreason==3 ? 2'b10 : 2'b11);ws<=W_REPLY;end
                    else begin sent_aw<=0;sent_w<=0;ws<=W_SEND;end
                end
                W_SEND: begin
                    if(downstream.awvalid && downstream.awready) sent_aw<=1;
                    if(downstream.wvalid && downstream.wready) sent_w<=1;
                    if((sent_aw || downstream.awready) && (sent_w || downstream.wready)) ws<=W_WAIT;
                end
                W_WAIT: if(downstream.bvalid) begin
                    bresp<=downstream.b.resp;wid<=downstream.b.id;wu<=downstream.b.user;
                    ws<=W_REPLY;
                end
                W_REPLY: if(upstream.bready) begin have_aw<=0;have_w<=0;ws<=W_COLLECT;end
            endcase
            case(rs)
                R_IDLE: if(upstream.arvalid && upstream.arready) begin
                    ar_hold<=upstream.ar;ra<=upstream.ar.addr;rid<=upstream.ar.id;ru<=upstream.ar.user;
                    if(rreason!=0) begin rdata<=0;rresp<=2'b11;rs<=R_REPLY;end
                    else if(diagnostic_address(upstream.ar.addr)) begin
                        rdata<=diagnostic_data(upstream.ar.addr);rresp<=0;rs<=R_REPLY;
                    end else rs<=R_SEND;
                end
                R_SEND: if(downstream.arready) rs<=R_WAIT;
                R_WAIT: if(downstream.rvalid) begin
                    rdata<=downstream.r.data;rresp<=downstream.r.resp;
                    rid<=downstream.r.id;ru<=downstream.r.user;rs<=R_REPLY;
                end
                R_REPLY: if(upstream.rready) rs<=R_IDLE;
            endcase
            if(bad_local_write || bad_downstream_write) begin
                if(write_faults!=32'hffffffff) write_faults<=write_faults+1'b1;
                if(!first_write_fault[63]) first_write_fault<=fault_word(wa,
                    bad_local_write ? wreason : 4'd4,
                    bad_local_write ? (wreason==3 ? 2'b10 : 2'b11) : downstream.b.resp);
            end
            if(bad_local_read || bad_downstream_read) begin
                if(read_faults!=32'hffffffff) read_faults<=read_faults+1'b1;
                if(!first_read_fault[63]) first_read_fault<=fault_word(
                    bad_local_read ? upstream.ar.addr : ra,
                    bad_local_read ? rreason : 4'd4,
                    bad_local_read ? 2'b11 : downstream.r.resp);
            end
        end
    end
endmodule
