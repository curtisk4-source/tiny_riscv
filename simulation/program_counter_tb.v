`timescale 1ns/1ps

module program_counter_tb;

reg clk;
reg reset;
reg [31:0] next_pc;

wire [31:0] pc;

integer passed;
integer failed;

// Device under test
program_counter uut (
	.clk(clk),
	.reset(reset),
	.next_pc(next_pc),
	.pc(pc)
);

// Generate a 10 ns clock period.
always #5 clk = ~clk;

// Compare the current PC against the expected value.
task check_pc;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		if (pc === expected) begin
			$display("PASS: %0s | Expected: %h | Actual: %h",
				test_name, expected, pc);
			passed = passed + 1;
		end
		else begin
			$display("FAIL: %0s | Expected: %h | Actual: %h",
				test_name, expected, pc);
			failed = failed + 1;
		end
	end
endtask

// Apply a PC update on the next active clock edge.
task update_pc;
	input [31:0] value;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		@(negedge clk);
		next_pc = value;

		@(posedge clk);
		#1;

		check_pc(expected, test_name);
	end
endtask

initial begin
	$dumpfile("program_counter.vcd");
	$dumpvars(0, program_counter_tb);

	clk = 0;
	reset = 0;
	next_pc = 0;

	passed = 0;
	failed = 0;

	// --------------------------------------------------
	// TEST GROUP 1: Initial reset
	// --------------------------------------------------

	reset = 1;

	@(posedge clk);
	#1;

	check_pc(32'h00000000, "Initial reset");

	// --------------------------------------------------
	// TEST GROUP 2: Reset release and normal execution
	// --------------------------------------------------

	@(negedge clk);
	reset = 0;

	update_pc(32'd4, 32'd4, "Initial PC increment");
	update_pc(32'd8, 32'd8, "Second PC increment");
	update_pc(32'd12, 32'd12, "Third PC increment");

	// --------------------------------------------------
	// TEST GROUP 3: Non-sequential PC updates
	// --------------------------------------------------

	update_pc(32'd100, 32'd100, "Forward PC jump");
	update_pc(32'd256, 32'd256, "Large forward jump");
	update_pc(32'd64, 32'd64, "Backward PC jump");
	update_pc(32'd0, 32'd0, "PC update to zero");

	// --------------------------------------------------
	// TEST GROUP 4: Boundary-value testing
	// --------------------------------------------------

	update_pc(32'h00000001, 32'h00000001,
		"Minimum nonzero PC");

	update_pc(32'h7FFFFFFF, 32'h7FFFFFFF,
		"Maximum signed positive PC");

	update_pc(32'h80000000, 32'h80000000,
		"Minimum signed negative pattern");

	update_pc(32'hFFFFFFFF, 32'hFFFFFFFF,
		"Maximum unsigned PC");

	// --------------------------------------------------
	// TEST GROUP 5: Repeated PC values
	// --------------------------------------------------

	update_pc(32'd128, 32'd128, "Initial repeated value");
	update_pc(32'd128, 32'd128, "Repeated identical PC");
	update_pc(32'd128, 32'd128, "Third identical PC");

	// --------------------------------------------------
	// TEST GROUP 6: PC hold behaviour
	// --------------------------------------------------

	@(negedge clk);
	next_pc = 32'd512;

	@(posedge clk);
	#1;

	check_pc(32'd512, "Load PC before hold test");

	@(negedge clk);

	// Keep next_pc unchanged to verify sequential stability.
	@(posedge clk);
	#1;

	check_pc(32'd512, "Hold PC with unchanged input");

	// --------------------------------------------------
	// TEST GROUP 7: Reset during normal execution
	// --------------------------------------------------

	@(negedge clk);
	reset = 1;
	next_pc = 32'd1024;

	@(posedge clk);
	#1;

	check_pc(32'd0, "Reset overrides next PC");

	// --------------------------------------------------
	// TEST GROUP 8: Reset release and recovery
	// --------------------------------------------------

	@(negedge clk);
	reset = 0;

	update_pc(32'd4, 32'd4, "PC recovery after reset");
	update_pc(32'd8, 32'd8, "Second update after reset");

	// --------------------------------------------------
	// TEST GROUP 9: Repeated reset
	// --------------------------------------------------

	@(negedge clk);
	reset = 1;

	@(posedge clk);
	#1;

	check_pc(32'd0, "Repeated reset");

	@(negedge clk);
	reset = 0;

	update_pc(32'd256, 32'd256,
		"Execution after repeated reset");

	// --------------------------------------------------
	// FINAL RESULTS
	// --------------------------------------------------

	$display("");
	$display("========================================");
	$display("       PROGRAM COUNTER TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	$display("========================================");

	if (failed == 0)
		$display("ALL PROGRAM COUNTER TESTS PASSED!");
	else
		$display("PROGRAM COUNTER TESTS FAILED!");

	$display("========================================");

	$finish;
end


endmodule