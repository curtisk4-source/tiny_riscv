`timescale 1ns/1ps

module pc_logic_tb;

reg [31:0] PC;
reg [31:0] BranchImmediate;
reg [31:0] JumpImmediate;

reg Branch;
reg Jump;
reg Zero;

wire [31:0] NextPC;

integer passed;
integer failed;

integer i;

// Device under test
pc_logic uut (
	.PC(PC),
	.BranchImmediate(BranchImmediate),
	.JumpImmediate(JumpImmediate),
	.Branch(Branch),
	.Jump(Jump),
	.Zero(Zero),
	.NextPC(NextPC)
);

// Compare the next PC output against the expected address.
task check_next_pc;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		if (NextPC === expected) begin
			$display("PASS: %0s | Expected: %h | Actual: %h",
				test_name, expected, NextPC);
			passed = passed + 1;
		end
		else begin
			$display("FAIL: %0s | Expected: %h | Actual: %h",
				test_name, expected, NextPC);
			failed = failed + 1;
		end
	end
endtask

// Apply control signals and verify the combinational result.
task run_test;
	input [31:0] pc_value;
	input [31:0] branch_offset;
	input [31:0] jump_offset;
	input branch_signal;
	input jump_signal;
	input zero_signal;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		PC = pc_value;
		BranchImmediate = branch_offset;
		JumpImmediate = jump_offset;
		Branch = branch_signal;
		Jump = jump_signal;
		Zero = zero_signal;

		#1;

		check_next_pc(expected, test_name);
	end
endtask

initial begin
	$dumpfile("pc_logic.vcd");
	$dumpvars(0, pc_logic_tb);

	passed = 0;
	failed = 0;

	// --------------------------------------------------
	// TEST GROUP 1: Normal sequential execution
	// --------------------------------------------------

	run_test(32'd100, 32'd20, 32'd40,
		0, 0, 0, 32'd104, "Normal PC increment");

	run_test(32'd0, 32'd20, 32'd40,
		0, 0, 0, 32'd4, "Sequential execution from zero");

	run_test(32'd256, 32'd20, 32'd40,
		0, 0, 0, 32'd260, "Sequential execution at address 256");

	// --------------------------------------------------
	// TEST GROUP 2: Conditional branch behaviour
	// --------------------------------------------------

	run_test(32'd100, 32'd20, 32'd40,
		1, 0, 1, 32'd120, "BEQ taken");

	run_test(32'd100, 32'd20, 32'd40,
		1, 0, 0, 32'd104, "BEQ not taken");

	run_test(32'd100, 32'd0, 32'd40,
		1, 0, 1, 32'd100, "Branch with zero offset");

	run_test(32'd100, 32'd4, 32'd40,
		1, 0, 1, 32'd104, "Branch offset of four");

	// --------------------------------------------------
	// TEST GROUP 3: Jump behaviour
	// --------------------------------------------------

	run_test(32'd100, 32'd20, 32'd40,
		0, 1, 0, 32'd140, "JAL jump");

	run_test(32'd100, 32'd20, 32'd0,
		0, 1, 0, 32'd100, "Jump with zero offset");

	run_test(32'd100, 32'd20, 32'd4,
		0, 1, 0, 32'd104, "Jump offset of four");

	// --------------------------------------------------
	// TEST GROUP 4: Branch and jump priority
	// --------------------------------------------------

	run_test(32'd100, 32'd20, 32'd40,
		1, 1, 1, 32'd140, "Jump priority over taken branch");

	run_test(32'd100, 32'd20, 32'd40,
		1, 1, 0, 32'd140, "Jump priority over untaken branch");

	run_test(32'd100, 32'd20, 32'd40,
		0, 1, 1, 32'd140, "Jump with zero asserted");

	run_test(32'd100, 32'd20, 32'd40,
		1, 0, 0, 32'd104, "Branch without zero");

	// --------------------------------------------------
	// TEST GROUP 5: Negative branch offsets
	// --------------------------------------------------

	run_test(32'd100, 32'hFFFFFFFE, 32'd40,
		1, 0, 1, 32'd98, "Negative branch offset");

	run_test(32'd100, 32'hFFFFFFFC, 32'd40,
		1, 0, 1, 32'd96, "Negative branch offset minus four");

	run_test(32'd100, 32'hFFFFFFFF, 32'd40,
		1, 0, 1, 32'd99, "Negative branch offset minus one");

	// --------------------------------------------------
	// TEST GROUP 6: Negative jump offsets
	// --------------------------------------------------

	run_test(32'd100, 32'd20, 32'hFFFFFFFE,
		0, 1, 0, 32'd98, "Negative jump offset");

	run_test(32'd100, 32'd20, 32'hFFFFFFFC,
		0, 1, 0, 32'd96, "Negative jump offset minus four");

	run_test(32'd100, 32'd20, 32'hFFFFFFFF,
		0, 1, 0, 32'd99, "Negative jump offset minus one");

	// --------------------------------------------------
	// TEST GROUP 7: PC arithmetic boundary values
	// --------------------------------------------------

	run_test(32'hFFFFFFFC, 32'd20, 32'd40,
		0, 0, 0, 32'h00000000, "PC increment overflow");

	run_test(32'hFFFFFFFF, 32'd20, 32'd40,
		0, 0, 0, 32'h00000003, "Maximum PC increment");

	run_test(32'd0, 32'd0, 32'd0,
		1, 0, 1, 32'd0, "Branch from zero");

	run_test(32'd0, 32'hFFFFFFFF, 32'd0,
		1, 0, 1, 32'hFFFFFFFF, "Negative branch from zero");

	run_test(32'hFFFFFFFF, 32'd0, 32'd1,
		0, 1, 0, 32'd0, "Jump address overflow");

	run_test(32'h80000000, 32'd0, 32'hFFFFFFFF,
		0, 1, 0, 32'h7FFFFFFF, "Jump across signed boundary");

	// --------------------------------------------------
	// TEST GROUP 8: Control signal truth table
	// --------------------------------------------------

	// Exercise every binary combination of Branch,
	// Jump, and Zero control signals.
	for (i = 0; i < 8; i = i + 1) begin
		run_test(
			32'd100,
			32'd20,
			32'd40,
			i[2],
			i[1],
			i[0],
			i[1] ? 32'd140 :
				((i[2] && i[0]) ? 32'd120 : 32'd104),
			"Control signal combination"
		);
	end

	// --------------------------------------------------
	// FINAL RESULTS
	// --------------------------------------------------

	$display("");
	$display("========================================");
	$display("           PC LOGIC TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	$display("========================================");

	if (failed == 0)
		$display("ALL PC LOGIC TESTS PASSED!");
	else
		$display("PC LOGIC TESTS FAILED!");

	$display("========================================");

	$finish;
end


endmodule