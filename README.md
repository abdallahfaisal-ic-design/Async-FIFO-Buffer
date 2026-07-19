# Parameterized Asynchronous FIFO Buffer

A Synthesizable Asynchronous FIFO (First-In, First-Out) buffer implemented in Verilog HDL. This design is engineered specifically for reliable Clock Domain Crossing (CDC) scenarios, enabling safe data transfer between mutually asynchronous write and read clock domains.

## Key Technical Features
* **Robust CDC Handling:** Implements multi-stage synchronizers (2-stage flip-flop) to mitigate metastability risks across asynchronous clock boundaries.
* * **Gray Code Pointer Conversion:** Utilizes binary-to-gray and gray-to-binary conversion logic for write and read pointers to ensure only a single bit changes per clock cycle, preventing false full/empty flags.
  * * **Fully Parameterized RTL:** Configurable data word width (`DATA_WIDTH`) and FIFO depth (`ADDRESS_DEPTH`) to adapt easily to various SoC interconnect requirements.
    * * **Accurate Flag Generation:** Advanced concurrent generation of safe `Full` and `Empty` status flags using synchronized gray pointers.
     
      * ## Architecture & Block Breakdown
      * * **FIFO Memory Array:** Dual-port RAM memory block handling concurrent read and write operations.
        * * **Write Pointer & Full Logic:** Computes the write address in binary, converts to Gray code, and evaluates the `FIFO_Full` condition.
          * * **Read Pointer & Empty Logic:** Computes the read address in binary, converts to Gray code, and evaluates the `FIFO_Empty` condition.
            * * **Domain Synchronizers:** Synchronizes pointers from the Write domain to the Read domain, and vice versa.
             
              * ## Simulation & Verification
              * * **HDL Language:** Verilog HDL
                * * **Toolchain:** ModelSim SE
                  * * **Testbench Methodology:** Multi-clock testbench simulating real-world frequency mismatches (fast-write/slow-read and slow-write/fast-read) to rigorously validate data integrity, pointer synchronization, and boundary conditions.
                    * 
