`timescale 1ns/1ps

module immediate_generator_tb;

	reg [31:0] instruction;
	reg [2:0] imm_sel;

	wire [31:0] immediate;

	integer passed;
	integer failed;

	// Instantiate Immediate Generator
	immediate_generator uut (
		.instruction(instruction),
		.imm_sel(imm_sel),
		.immediate(immediate)
	);

	// Task to check immediate output
	task check_immediate;
		input [31:0] expected;
		input [255:0] test_name;

		begin
			if (immediate === expected) begin
				$display("PASS: %s | Immediate = %h",
					test_name, immediate);
				passed = passed + 1;
			end
			else begin
				$display("FAIL: %s | Expected = %h, Got = %h",
					test_name, expected, immediate);
				failed = failed + 1;
			end
		end
	endtask

	initial begin

		$dumpfile("imm_test.vcd");
		$dumpvars(0, immediate_generator_tb);

		passed = 0;
		failed = 0;

		instruction = 0;
		imm_sel = 0;

		// TEST 1: Positive I-type immediate
		// ADDI x0, x0, 2047
		instruction = 32'h7FF00013;
		imm_sel = 3'b000;
		#10;
		check_immediate(32'h000007FF,
			"I-type positive");

		// TEST 2: Negative I-type immediate
		// ADDI x0, x0, -1
		instruction = 32'hFFF00013;
		imm_sel = 3'b000;
		#10;
		check_immediate(32'hFFFFFFFF,
			"I-type negative");

		// TEST 3: Negative S-type immediate
		// SW x0, -1(x0)
		instruction = 32'hFE002FA3;
		imm_sel = 3'b001;
		#10;
		check_immediate(32'hFFFFFFFF,
			"S-type negative");

		// TEST 4: Negative B-type immediate
		// BEQ x0, x0, -2
		instruction = 32'hFE000FE3;
		imm_sel = 3'b010;
		#10;
		check_immediate(32'hFFFFFFFE,
			"B-type negative");

		// TEST 5: Negative U-type immediate
		// LUI x0, 0xFFFFF
		instruction = 32'hFFFFF037;
		imm_sel = 3'b011;
		#10;
		check_immediate(32'hFFFFF000,
			"U-type negative");

		// TEST 6: Negative J-type immediate
		// JAL x0, -2
		instruction = 32'hFFFFF06F;
		imm_sel = 3'b100;
		#10;
		check_immediate(32'hFFFFFFFE,
			"J-type negative");

		// TEST 7: Invalid immediate selection
		instruction = 32'h7FF00013;
		imm_sel = 3'b111;
		#10;
		check_immediate(32'h00000000,
			"Invalid selection");

		// Final results
		$display("-----------------------------");
		$display("IMMEDIATE GENERATOR RESULTS");
		$display("Passed: %0d", passed);
		$display("Failed: %0d", failed);
		$display("-----------------------------");

		if (failed == 0)
			$display("ALL IMMEDIATE TESTS PASSED!");
		else
			$display("SOME IMMEDIATE TESTS FAILED!");

		$finish;

	end

endmodule
