module asynchronous_fifo #(

    parameter DEPTH = 8,

    parameter DATA_WIDTH = 8

)(

    input  wire                  wclk, wrst_n, w_en,

    input  wire                  rclk, rrst_n, r_en,

    input  wire [DATA_WIDTH-1:0] data_in,

    output wire [DATA_WIDTH-1:0] data_out,

    output wire                  full, empty

);



    // Local Parameter for pointer width (clog2 calculation)

    localparam PTR_WIDTH = 3; // $clog2(DEPTH)



    // Internal wires for design synchronization and connections

    wire [PTR_WIDTH:0] g_wptr_sync, g_rptr_sync;

    wire [PTR_WIDTH:0] b_wptr, g_wptr;

    wire [PTR_WIDTH:0] b_rptr, g_rptr;



    // 1. Synchronize Read Pointer to Write Domain

    synchronizer #(PTR_WIDTH) sync_wptr (

        .clk(wclk),

        .rst_n(wrst_n),

        .d_in(g_rptr),

        .d_out(g_rptr_sync)

    );



    // 2. Synchronize Write Pointer to Read Domain

    synchronizer #(PTR_WIDTH) sync_rptr (

        .clk(rclk),

        .rst_n(rrst_n),

        .d_in(g_wptr),

        .d_out(g_wptr_sync)

    );



    // 3. Write Pointer Handler Logic

    wptr_handler #(PTR_WIDTH) wptr_h (

        .wclk(wclk),

        .wrst_n(wrst_n),

        .w_en(w_en),

        .g_rptr_sync(g_rptr_sync),

        .b_wptr(b_wptr),

        .g_wptr(g_wptr),

        .full(full)

    );



    // 4. Read Pointer Handler Logic

    rptr_handler #(PTR_WIDTH) rptr_h (

        .rclk(rclk),

        .rrst_n(rrst_n),

        .r_en(r_en),

        .g_wptr_sync(g_wptr_sync),

        .b_rptr(b_rptr),

        .g_rptr(g_rptr),

        .empty(empty)

    );



    // 5. FIFO Memory Core

    fifo_mem #(DEPTH, DATA_WIDTH, PTR_WIDTH) fifo_M (

        .wclk(wclk),

        .w_en(w_en),

        .rclk(rclk),

        .r_en(r_en),

        .b_wptr(b_wptr),

        .b_rptr(b_rptr),

        .full(full),

        .empty(empty),

        .data_in(data_in),

        .data_out(data_out)

    );



endmodule


