

`timescale 1ns/1ps



module asynchronous_fifo_tb;



    // Parameters matching the DUT configuration

    parameter DEPTH      = 8;

    parameter DATA_WIDTH = 8;



    // Write Domain Signals

    reg                   wclk;

    reg                   wrst_n;

    reg                   w_en;

    reg  [DATA_WIDTH-1:0] data_in;

    wire                  full;



    // Read Domain Signals

    reg                   rclk;

    reg                   rrst_n;

    reg                   r_en;

    wire [DATA_WIDTH-1:0] data_out;

    wire                  empty;



    // Expected data queue for self-checking verification

    reg [DATA_WIDTH-1:0] expected_queue [0:DEPTH-1];

    integer write_ptr = 0;

    integer read_ptr  = 0;

    integer i;



    // Instantiate the Top Module (DUT)

    asynchronous_fifo #(

        .DEPTH(DEPTH),

        .DATA_WIDTH(DATA_WIDTH)

    ) uut (

        .wclk(wclk),

        .wrst_n(wrst_n),

        .w_en(w_en),

        .rclk(rclk),

        .rrst_n(rrst_n),

        .r_en(r_en),

        .data_in(data_in),

        .data_out(data_out),

        .full(full),

        .empty(empty)

    );



    // --- Clock Generation ---

    // Fast Write Clock (~100 MHz) and Slower Read Clock (~50 MHz)

    always #5  wclk = ~wclk; 

    always #10 rclk = ~rclk; 



    // --- Main Stimulus ---

    initial begin

        // Initialize all inputs

        wclk    = 0;

        wrst_n  = 0;

        w_en    = 0;

        data_in = 0;

        

        rclk    = 0;

        rrst_n  = 0;

        r_en    = 0;



        // Apply Reset for both domains

        #25;

        @(posedge wclk) wrst_n = 1;

        @(posedge rclk) rrst_n = 1;

        $display("[TB_INFO] ---------- Reset Released ----------");

        

        // Verify initial conditions

        #10;

        if (empty !== 1'b1 || full !== 1'b0) begin

            $display("[TB_ERROR] Initial flags incorrect! Empty: %b, Full: %b", empty, full);

            $finish;

        end



        // ========================================================

        // TEST SCENARIO 1: Burst Write Until Full

        // ========================================================

        $display("[TB_INFO] Starting Burst Write Operations...");

        

        for (i = 0; i < DEPTH; i = i + 1) begin

            @(posedge wclk);

            if (!full) begin

                w_en = 1'b1;

                data_in = 8'hA0 + i; // Generate unique data pattern (A0, A1, A2...)

                expected_queue[write_ptr] = data_in;

                write_ptr = write_ptr + 1;

                $display("[WRITE] Time: %0t | Data In: %h", $time, data_in);

            end

        end

        

        @(posedge wclk);

        w_en = 1'b0; // Stop writing

        data_in = 0;

        

        // Wait a few clocks for CDC synchronization to update flags

        repeat(5) @(posedge wclk);

        

        if (full === 1'b1) begin

            $display("[TB_SUCCESS] FIFO is FULL as expected.");

        end else begin

            $display("[TB_ERROR] FIFO failed to report FULL flag!");

        end



        // ========================================================

        // TEST SCENARIO 2: Burst Read Until Empty with Self-Checking

        // ========================================================

        $display("[TB_INFO] Starting Burst Read Operations...");

        

        while (!empty) begin

            @(posedge rclk);

            r_en = 1'b1;

            

            // Sample data on the next clock edge where read execution completes

            @(posedge rclk);

            if (data_out === expected_queue[read_ptr]) begin

                $display("[READ]  Time: %0t | Data Out: %h | MATCHED", $time, data_out);

            end else begin

                $display("[READ_ERROR] Mismatch! Expected: %h, Got: %h", expected_queue[read_ptr], data_out);

            end

            read_ptr = read_ptr + 1;

        end

        

        @(posedge rclk);

        r_en = 1'b0; // Stop reading

        

        // Wait for CDC synchronization

        repeat(5) @(posedge rclk);

        

        if (empty === 1'b1) begin

            $display("[TB_SUCCESS] FIFO is EMPTY as expected.");

            $display("[TB_RESULT] ########## ALL TESTS PASSED ##########");

        end else begin

            $display("[TB_ERROR] FIFO failed to report EMPTY flag!");

        end



        #50;

        $finish;

    end



    // --- Optional: Timeout Monitor ---

    initial begin

        #1000;

        $display("[TB_TIMEOUT] Simulation stalled or took too long.");

        $finish;

    end



endmodule
