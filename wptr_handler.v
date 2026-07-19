000000000000ggrrttt[pppppppppppyr

module wptr_handler #(

    parameter PTR_WIDTH = 3

)(

    input  wire                 wclk, wrst_n, w_en,

    input  wire [PTR_WIDTH:0]   g_rptr_sync,

    output reg  [PTR_WIDTH:0]   b_wptr, g_wptr,

    output reg                  full

);



    wire  [PTR_WIDTH:0] b_wptr_next;

    wire  [PTR_WIDTH:0] g_wptr_next;

    wire               wfull;



    assign b_wptr_next = b_wptr + (w_en && !full);

    assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;



    always @(posedge wclk or negedge wrst_n) begin

        if (!wrst_n) begin

            b_wptr <= 0;

            g_wptr <= 0;

        end else begin

            b_wptr <= b_wptr_next;

            g_wptr <= g_wptr_next;

        end

    end



    // Full condition using Gray code style from your notes

    assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});



    always @(posedge wclk or negedge wrst_n) begin

        if (!wrst_n) 

            full <= 1'b0;

        else         

            full <= wfull;

    end


endmodule
