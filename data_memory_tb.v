`timescale 1ns/1ps

module data_memory_tb;

    // Inputs
    reg clk;
    reg MemRead;
    reg MemWrite;
    reg [31:0] Address;
    reg [31:0] WriteData;

    // Output
    wire [31:0] ReadData;

    // Instantiate Data Memory
    data_memory uut (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .Address(Address),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    // Generate clock (10ns period)
    always #5 clk = ~clk;

    initial begin

        // Initialize signals
        clk = 0;
        MemRead = 0;
        MemWrite = 0;
        Address = 0;
        WriteData = 0;

        // --------------------------------
        // TEST 1: Write 10 to address 0
        // --------------------------------

        @(negedge clk);
        Address = 32'h00000000;
        WriteData = 32'd10;
        MemWrite = 1;

        @(negedge clk);
        MemWrite = 0;

        // Read address 0
        MemRead = 1;
        #1;

        $display("TEST 1: Read address 0");
        $display("Expected: 10 | Actual: %d", ReadData);

        if (ReadData === 32'd10)
            $display("PASSED");
        else
            $display("FAILED");


        // --------------------------------
        // TEST 2: Write 25 to address 4
        // --------------------------------

        @(negedge clk);
        MemRead = 0;
        Address = 32'h00000004;
        WriteData = 32'd25;
        MemWrite = 1;

        @(negedge clk);
        MemWrite = 0;

        // Read address 4
        MemRead = 1;
        #1;

        $display("\nTEST 2: Read address 4");
        $display("Expected: 25 | Actual: %d", ReadData);

        if (ReadData === 32'd25)
            $display("PASSED");
        else
            $display("FAILED");


        // --------------------------------
        // TEST 3: Read address 0 again
        // --------------------------------

        Address = 32'h00000000;
        #1;

        $display("\nTEST 3: Read address 0 again");
        $display("Expected: 10 | Actual: %d", ReadData);

        if (ReadData === 32'd10)
            $display("PASSED");
        else
            $display("FAILED");


        // --------------------------------
        // TEST 4: Disable memory read
        // --------------------------------

        MemRead = 0;
        #1;

        $display("\nTEST 4: MemRead disabled");
        $display("Expected: 0 | Actual: %d", ReadData);

        if (ReadData === 32'd0)
            $display("PASSED");
        else
            $display("FAILED");


        // --------------------------------
        // END SIMULATION
        // --------------------------------

        $display("\nSimulation complete!");
        $finish;

    end

endmodule
