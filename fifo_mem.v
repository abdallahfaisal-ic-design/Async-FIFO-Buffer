
module fifo_mem #(

    parameter DEPTH = 8,

    parameter DATA_WIDTH = 8,

    parameter PTR_WIDTH = 3

)(

    input  wire                  wclk, w_en, rclk, r_en,

    input  wire  [PTR_WIDTH:0]   b_wptr, b_rptr,

    input  wire                  full, empty,

    input  wire  [DATA_WIDTH-1:0] data_in,

    output reg   [DATA_WIDTH-1:0] data_out

);



    reg [DATA_WIDTH-1:0] Fifo [0:DEPTH-1];



    // Write operation

    always @(posedge wclk) begin

        if (w_en && !full) begin

            Fifo[b_wptr[PTR_WIDTH-1:0]] <= data_in;

        end

    end



    // Read operation

    always @(posedge rclk) begin

        if (r_en && !empty) begin

            data_out <= Fifo[b_rptr[PTR_WIDTH-1:0]];

        end

    end



endmodule

