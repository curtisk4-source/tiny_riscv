`timescale 1ns/1ps

module program_counter_tb;

	reg clk;
	reg reset;
	reg [31:0] next_pc;

	wire [31:0] pc;

	integer passed;
	integer failed;

	// Instantiate Program Counter
	program_counter uut (
		.clk(clk),
		.reset(reset),
		.next_pc(next_pc),
		.pc(pc)
	);

	// Generate clock: 10ns period
	always #5 clk = ~clk;

	// Task to check PC output
	task check_pc;
		input [31:0] expected;
		input [255:0] test_name;

		begin
			if (pc === expected) begin
				$display("PASS: %s | PC = %h",
					test_name, pc);
				passed = passed + 1;
			end
			else begin
				$display("FAIL: %s | Expected = %h, Got = %h",
					test_name, expected, pc);
				failed = failed + 1;
			end
		end
	endtask

	initial begin

		$dumpfile("pc_test.vcd");
		$dumpvars(0, program_counter_tb);

		clk = 0;
		reset = 0;
		next_pc = 0;

		passed = 0;
		failed = 0;

		// TEST 1: Reset PC
		reset = 1;
		@(posedge clk);
		#1;
		check_pc(32'd0, "Reset PC");

		// Release reset
		@(negedge clk);
		reset = 0;

		// TEST 2: PC = 4
		next_pc = 32'd4;
		@(posedge clk);
		#1;
		check_pc(32'd4, "PC update to 4");

		// TEST 3: PC = 8
		@(negedge clk);
		next_pc = 32'd8;
		@(posedge clk);
		#1;
		check_pc(32'd8, "PC update to 8");

		// TEST 4: PC = 100
		@(negedge clk);
		next_pc = 32'd100;
		@(posedge clk);
		#1;
		check_pc(32'd100, "PC update to 100");

		// TEST 5: Simulated jump
		@(negedge clk);
		next_pc = 32'd256;
		@(posedge clk);
		#1;
		check_pc(32'd256, "Jump to 256");

		// TEST 6: Reset again
		@(negedge clk);
		reset = 1;
		@(posedge clk);
		#1;
		check_pc(32'd0, "Reset again");

		// Final results
		$display("-----------------------------");
		$display("PC TEST RESULTS");
		$display("Passed: %0d", passed);
		$display("Failed: %0d", failed);
		$display("-----------------------------");

		if (failed == 0)
			$display("ALL PC TESTS PASSED!");
		else
			$display("SOME PC TESTS FAILED!");

		$finish;

	end

endmodule
