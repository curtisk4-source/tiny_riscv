`timescale 1ns/1ps

module data_memory_tb;

reg clk;
reg MemRead;
reg MemWrite;
reg [31:0] Address;
reg [31:0] WriteData;

wire [31:0] ReadData;

integer passed;
integer failed;

// Device under test
data_memory uut (
	.clk(clk),
	.MemRead(MemRead),
	.MemWrite(MemWrite),
	.Address(Address),
	.WriteData(WriteData),
	.ReadData(ReadData)
);

// Generate a 10 ns clock period.
always #5 clk = ~clk;

// Compare the memory output against the expected value.
task check_read;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		if (ReadData === expected) begin
			$display("PASS: %0s | Expected: %h | Actual: %h",
				test_name, expected, ReadData);
			passed = passed + 1;
		end
		else begin
			$display("FAIL: %0s | Expected: %h | Actual: %h",
				test_name, expected, ReadData);
			failed = failed + 1;
		end
	end
endtask

// Write a value to memory on the active clock edge.
task write_memory;
	input [31:0] address;
	input [31:0] data;

	begin
		@(negedge clk);

		Address = address;
		WriteData = data;
		MemRead = 0;
		MemWrite = 1;

		@(posedge clk);
		#1;

		MemWrite = 0;
	end
endtask

// Read a memory location and verify its contents.
task read_memory;
	input [31:0] address;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		@(negedge clk);

		Address = address;
		MemRead = 1;
		MemWrite = 0;

		#1;

		check_read(expected, test_name);
	end
endtask

initial begin
	$dumpfile("data_memory.vcd");
	$dumpvars(0, data_memory_tb);

	clk = 0;
	MemRead = 0;
	MemWrite = 0;
	Address = 0;
	WriteData = 0;

	passed = 0;
	failed = 0;

	// --------------------------------------------------
	// TEST GROUP 1: Basic memory operations
	// --------------------------------------------------

	write_memory(32'h00000000, 32'd10);
	read_memory(32'h00000000, 32'd10,
		"Write and read address zero");

	write_memory(32'h00000004, 32'd25);
	read_memory(32'h00000004, 32'd25,
		"Write and read address four");

	write_memory(32'h00000008, 32'd50);
	read_memory(32'h00000008, 32'd50,
		"Write and read address eight");

	// --------------------------------------------------
	// TEST GROUP 2: Independent memory locations
	// --------------------------------------------------

	read_memory(32'h00000000, 32'd10,
		"Verify first location retention");

	read_memory(32'h00000004, 32'd25,
		"Verify second location retention");

	read_memory(32'h00000008, 32'd50,
		"Verify third location retention");

	// --------------------------------------------------
	// TEST GROUP 3: Overwriting existing data
	// --------------------------------------------------

	write_memory(32'h00000000, 32'd100);
	read_memory(32'h00000000, 32'd100,
		"Overwrite existing memory data");

	write_memory(32'h00000000, 32'd200);
	read_memory(32'h00000000, 32'd200,
		"Repeated memory overwrite");

	// --------------------------------------------------
	// TEST GROUP 4: Boundary data values
	// --------------------------------------------------

	write_memory(32'h00000010, 32'h00000000);
	read_memory(32'h00000010, 32'h00000000,
		"Minimum unsigned data");

	write_memory(32'h00000014, 32'hFFFFFFFF);
	read_memory(32'h00000014, 32'hFFFFFFFF,
		"Maximum unsigned data");

	write_memory(32'h00000018, 32'h7FFFFFFF);
	read_memory(32'h00000018, 32'h7FFFFFFF,
		"Maximum signed positive data");

	write_memory(32'h0000001C, 32'h80000000);
	read_memory(32'h0000001C, 32'h80000000,
		"Minimum signed negative data");

	write_memory(32'h00000020, 32'hAAAAAAAA);
	read_memory(32'h00000020, 32'hAAAAAAAA,
		"Alternating bit pattern A");

	write_memory(32'h00000024, 32'h55555555);
	read_memory(32'h00000024, 32'h55555555,
		"Alternating bit pattern B");

	// --------------------------------------------------
	// TEST GROUP 5: Write enable disabled
	// --------------------------------------------------

	// Attempt to modify an existing location with
	// memory writes disabled.
	@(negedge clk);

	Address = 32'h00000004;
	WriteData = 32'hFFFFFFFF;
	MemRead = 0;
	MemWrite = 0;

	@(posedge clk);
	#1;

	read_memory(32'h00000004, 32'd25,
		"Disabled write preserves existing data");

	// --------------------------------------------------
	// TEST GROUP 6: Read enable disabled
	// --------------------------------------------------

	@(negedge clk);

	Address = 32'h00000004;
	MemRead = 0;
	MemWrite = 0;

	#1;

	check_read(32'd0, "Disabled memory read");

	// --------------------------------------------------
	// TEST GROUP 7: Write with read disabled
	// --------------------------------------------------

	write_memory(32'h00000028, 32'd750);

	// Confirm that the write was successful after
	// re-enabling the read control.
	read_memory(32'h00000028, 32'd750,
		"Write operation with read disabled");

	// --------------------------------------------------
	// TEST GROUP 8: Consecutive memory accesses
	// --------------------------------------------------

	write_memory(32'h0000002C, 32'd111);
	write_memory(32'h00000030, 32'd222);
	write_memory(32'h00000034, 32'd333);

	read_memory(32'h0000002C, 32'd111,
		"First consecutive memory write");

	read_memory(32'h00000030, 32'd222,
		"Second consecutive memory write");

	read_memory(32'h00000034, 32'd333,
		"Third consecutive memory write");

	// --------------------------------------------------
	// TEST GROUP 9: Simultaneous read and write
	// --------------------------------------------------

	// The following test observes the output when both
	// controls are asserted. The expected result depends
	// on the memory implementation's read-during-write
	// semantics, so it is informational rather than
	// included in the PASS/FAIL count.

	@(negedge clk);

	Address = 32'h00000000;
	WriteData = 32'd999;
	MemRead = 1;
	MemWrite = 1;

	@(posedge clk);
	#1;

	$display("INFO: Simultaneous read/write | ReadData: %h",
		ReadData);

	MemWrite = 0;

	// Verify the final stored value.
	read_memory(32'h00000000, 32'd999,
		"Final value after simultaneous read/write");

	// --------------------------------------------------
	// TEST GROUP 10: Unaligned address behaviour
	// --------------------------------------------------

	// Unaligned accesses are implementation-dependent.
	// Observe their behaviour without assuming that
	// addresses are rounded or rejected.

	@(negedge clk);

	Address = 32'h00000001;
	MemRead = 1;
	MemWrite = 0;

	#1;

	$display("INFO: Unaligned address 0x00000001 | Data: %h",
		ReadData);

	Address = 32'h00000002;
	#1;

	$display("INFO: Unaligned address 0x00000002 | Data: %h",
		ReadData);

	Address = 32'h00000003;
	#1;

	$display("INFO: Unaligned address 0x00000003 | Data: %h",
		ReadData);

	// --------------------------------------------------
	// TEST GROUP 11: Out-of-range address behaviour
	// --------------------------------------------------

	// These addresses must be adjusted to match the
	// actual memory depth and address decoding.

	Address = 32'h00000400;
	#1;

	$display("INFO: Out-of-range address 0x00000400 | Data: %h",
		ReadData);

	Address = 32'hFFFFFFFF;
	#1;

	$display("INFO: Maximum unsigned address | Data: %h",
		ReadData);

	// --------------------------------------------------
	// FINAL RESULTS
	// --------------------------------------------------

	$display("");
	$display("========================================");
	$display("          DATA MEMORY TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	$display("========================================");

	if (failed == 0)
		$display("ALL DATA MEMORY TESTS PASSED!");
	else
		$display("DATA MEMORY TESTS FAILED!");

	$display("========================================");

	$finish;
end


endmodule