`timescale 1ns/1ps

module alu_tb;

reg [31:0] input_a;
reg [31:0] input_b;
reg [3:0] alu_control;

wire [31:0] result;
wire zero;

integer passed;
integer failed;

// Device under test
alu uut (
	.input_a(input_a),
	.input_b(input_b),
	.alu_control(alu_control),
	.result(result),
	.zero(zero)
);

// Compare the ALU result and zero flag against expected values.
task check_result;
	input [31:0] expected_result;
	input expected_zero;
	input [255:0] test_name;

	begin
		if (
			(result === expected_result) &&
			(zero === expected_zero)
		) begin
			$display("PASS: %0s | Result: %h | Zero: %b",
				test_name, result, zero);
			passed = passed + 1;
		end
		else begin
			$display("FAIL: %0s", test_name);

			$display("Expected result: %h | Actual: %h",
				expected_result, result);

			$display("Expected zero: %b | Actual: %b",
				expected_zero, zero);

			failed = failed + 1;
		end
	end
endtask

// Apply operands and ALU control, then verify the result.
task run_test;
	input [31:0] operand_a;
	input [31:0] operand_b;
	input [3:0] control;
	input [31:0] expected_result;
	input expected_zero;
	input [255:0] test_name;

	begin
		input_a = operand_a;
		input_b = operand_b;
		alu_control = control;

		#10;

		check_result(
			expected_result,
			expected_zero,
			test_name
		);
	end
endtask

initial begin
	$dumpfile("alu.vcd");
	$dumpvars(0, alu_tb);

	passed = 0;
	failed = 0;

	input_a = 0;
	input_b = 0;
	alu_control = 0;

	// --------------------------------------------------
	// TEST GROUP 1: Addition
	// --------------------------------------------------

	run_test(32'd10, 32'd5, 4'b0000,
		32'd15, 1'b0, "ADD positive operands");

	run_test(32'd0, 32'd0, 4'b0000,
		32'd0, 1'b1, "ADD zero operands");

	run_test(32'd0, 32'd15, 4'b0000,
		32'd15, 1'b0, "ADD zero and positive");

	run_test(32'd15, 32'd0, 4'b0000,
		32'd15, 1'b0, "ADD positive and zero");

	run_test(32'hFFFFFFFF, 32'd1, 4'b0000,
		32'h00000000, 1'b1, "ADD unsigned overflow");

	run_test(32'h7FFFFFFF, 32'd1, 4'b0000,
		32'h80000000, 1'b0, "ADD signed overflow");

	run_test(32'h80000000, 32'h80000000, 4'b0000,
		32'h00000000, 1'b1, "ADD minimum signed values");

	run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b0000,
		32'hFFFFFFFE, 1'b0, "ADD negative bit patterns");

	run_test(32'h80000000, 32'h00000001, 4'b0000,
		32'h80000001, 1'b0, "ADD minimum signed value and one");

	// --------------------------------------------------
	// TEST GROUP 2: Subtraction
	// --------------------------------------------------

	run_test(32'd10, 32'd5, 4'b0001,
		32'd5, 1'b0, "SUB positive operands");

	run_test(32'd5, 32'd10, 4'b0001,
		32'hFFFFFFFB, 1'b0, "SUB negative result");

	run_test(32'd10, 32'd10, 4'b0001,
		32'd0, 1'b1, "SUB equal operands");

	run_test(32'd0, 32'd0, 4'b0001,
		32'd0, 1'b1, "SUB zero operands");

	run_test(32'd0, 32'd1, 4'b0001,
		32'hFFFFFFFF, 1'b0, "SUB unsigned underflow");

	run_test(32'h7FFFFFFF, 32'hFFFFFFFF, 4'b0001,
		32'h80000000, 1'b0, "SUB signed overflow");

	run_test(32'h80000000, 32'd1, 4'b0001,
		32'h7FFFFFFF, 1'b0, "SUB minimum signed boundary");

	run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b0001,
		32'd0, 1'b1, "SUB identical maximum bit patterns");

	// --------------------------------------------------
	// TEST GROUP 3: Bitwise AND
	// --------------------------------------------------

	run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b0010,
		32'hFFFFFFFF, 1'b0, "AND all ones");

	run_test(32'hAAAAAAAA, 32'h55555555, 4'b0010,
		32'h00000000, 1'b1, "AND alternating bit patterns");

	run_test(32'hFFFFFFFF, 32'h00000000, 4'b0010,
		32'h00000000, 1'b1, "AND with zero");

	run_test(32'hFFFFFFFF, 32'h12345678, 4'b0010,
		32'h12345678, 1'b0, "AND identity");

	run_test(32'h80000000, 32'h80000000, 4'b0010,
		32'h80000000, 1'b0, "AND most significant bit");

	// --------------------------------------------------
	// TEST GROUP 4: Bitwise OR
	// --------------------------------------------------

	run_test(32'h00000000, 32'h00000000, 4'b0011,
		32'h00000000, 1'b1, "OR zero operands");

	run_test(32'hAAAAAAAA, 32'h55555555, 4'b0011,
		32'hFFFFFFFF, 1'b0, "OR alternating bit patterns");

	run_test(32'hFFFFFFFF, 32'h00000000, 4'b0011,
		32'hFFFFFFFF, 1'b0, "OR with zero");

	run_test(32'h00000000, 32'h12345678, 4'b0011,
		32'h12345678, 1'b0, "OR identity");

	run_test(32'h80000000, 32'h00000001, 4'b0011,
		32'h80000001, 1'b0, "OR boundary bits");

	// --------------------------------------------------
	// TEST GROUP 5: Bitwise XOR
	// --------------------------------------------------

	run_test(32'hAAAAAAAA, 32'h55555555, 4'b0100,
		32'hFFFFFFFF, 1'b0, "XOR alternating bit patterns");

	run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b0100,
		32'h00000000, 1'b1, "XOR identical operands");

	run_test(32'h12345678, 32'h00000000, 4'b0100,
		32'h12345678, 1'b0, "XOR with zero");

	run_test(32'h80000000, 32'h00000001, 4'b0100,
		32'h80000001, 1'b0, "XOR boundary bits");

	// --------------------------------------------------
	// TEST GROUP 6: Logical left shift
	// --------------------------------------------------

	run_test(32'd1, 32'd0, 4'b0101,
		32'h00000001, 1'b0, "SLL shift by zero");

	run_test(32'd1, 32'd1, 4'b0101,
		32'h00000002, 1'b0, "SLL shift by one");

	run_test(32'd1, 32'd4, 4'b0101,
		32'h00000010, 1'b0, "SLL shift by four");

	run_test(32'd1, 32'd31, 4'b0101,
		32'h80000000, 1'b0, "SLL maximum shift amount");

	run_test(32'hFFFFFFFF, 32'd1, 4'b0101,
		32'hFFFFFFFE, 1'b0, "SLL all ones");

	run_test(32'h80000000, 32'd1, 4'b0101,
		32'h00000000, 1'b1, "SLL discarded most significant bit");

	run_test(32'd1, 32'd32, 4'b0101,
		32'h00000001, 1'b0, "SLL shift amount 32");

	// --------------------------------------------------
	// TEST GROUP 7: Logical right shift
	// --------------------------------------------------

	run_test(32'hFFFFFFFF, 32'd0, 4'b0110,
		32'hFFFFFFFF, 1'b0, "SRL shift by zero");

	run_test(32'hFFFFFFFF, 32'd1, 4'b0110,
		32'h7FFFFFFF, 1'b0, "SRL shift by one");

	run_test(32'h80000000, 32'd1, 4'b0110,
		32'h40000000, 1'b0, "SRL most significant bit");

	run_test(32'hFFFFFFFF, 32'd31, 4'b0110,
		32'h00000001, 1'b0, "SRL maximum shift amount");

	run_test(32'h80000000, 32'd31, 4'b0110,
		32'h00000001, 1'b0, "SRL minimum signed value");

	run_test(32'hFFFFFFFF, 32'd32, 4'b0110,
		32'hFFFFFFFF, 1'b0, "SRL shift amount 32");

	// --------------------------------------------------
	// TEST GROUP 8: Arithmetic right shift
	// --------------------------------------------------

	run_test(32'h00000010, 32'd1, 4'b0111,
		32'h00000008, 1'b0, "SRA positive operand");

	run_test(32'hFFFFFFF0, 32'd1, 4'b0111,
		32'hFFFFFFF8, 1'b0, "SRA negative operand");

	run_test(32'hFFFFFFF0, 32'd2, 4'b0111,
		32'hFFFFFFFC, 1'b0, "SRA negative shift by two");

	run_test(32'h80000000, 32'd1, 4'b0111,
		32'hC0000000, 1'b0, "SRA minimum signed value");

	run_test(32'h80000000, 32'd31, 4'b0111,
		32'hFFFFFFFF, 1'b0, "SRA maximum shift amount");

	run_test(32'h7FFFFFFF, 32'd31, 4'b0111,
		32'h00000000, 1'b1, "SRA maximum positive value");

	run_test(32'hFFFFFFFF, 32'd0, 4'b0111,
		32'hFFFFFFFF, 1'b0, "SRA shift by zero");

	run_test(32'hFFFFFFFF, 32'd32, 4'b0111,
		32'hFFFFFFFF, 1'b0, "SRA shift amount 32");

	// --------------------------------------------------
	// TEST GROUP 9: Signed comparison
	// --------------------------------------------------

	run_test(32'd5, 32'd10, 4'b1000,
		32'd1, 1'b0, "SLT smaller positive operand");

	run_test(32'd10, 32'd5, 4'b1000,
		32'd0, 1'b1, "SLT larger positive operand");

	run_test(32'd5, 32'd5, 4'b1000,
		32'd0, 1'b1, "SLT equal operands");

	run_test(32'hFFFFFFFF, 32'd1, 4'b1000,
		32'd1, 1'b0, "SLT negative and positive");

	run_test(32'd1, 32'hFFFFFFFF, 4'b1000,
		32'd0, 1'b1, "SLT positive and negative");

	run_test(32'h80000000, 32'h7FFFFFFF, 4'b1000,
		32'd1, 1'b0, "SLT minimum and maximum signed");

	run_test(32'h7FFFFFFF, 32'h80000000, 4'b1000,
		32'd0, 1'b1, "SLT maximum and minimum signed");

	run_test(32'hFFFFFFFF, 32'h80000000, 4'b1000,
		32'd0, 1'b1, "SLT negative boundary comparison");

	// --------------------------------------------------
	// TEST GROUP 10: Unsigned comparison
	// --------------------------------------------------

	run_test(32'd5, 32'd10, 4'b1001,
		32'd1, 1'b0, "SLTU smaller positive operand");

	run_test(32'd10, 32'd5, 4'b1001,
		32'd0, 1'b1, "SLTU larger positive operand");

	run_test(32'd5, 32'd5, 4'b1001,
		32'd0, 1'b1, "SLTU equal operands");

	run_test(32'hFFFFFFFF, 32'd1, 4'b1001,
		32'd0, 1'b1, "SLTU maximum unsigned value");

	run_test(32'd1, 32'hFFFFFFFF, 4'b1001,
		32'd1, 1'b0, "SLTU unsigned boundary comparison");

	run_test(32'h80000000, 32'h7FFFFFFF, 4'b1001,
		32'd0, 1'b1, "SLTU high-bit comparison");

	run_test(32'h7FFFFFFF, 32'h80000000, 4'b1001,
		32'd1, 1'b0, "SLTU lower unsigned boundary");

	run_test(32'h00000000, 32'hFFFFFFFF, 4'b1001,
		32'd1, 1'b0, "SLTU zero and maximum");

	// --------------------------------------------------
	// TEST GROUP 11: Unsupported ALU control values
	// --------------------------------------------------

	run_test(32'd10, 32'd5, 4'b1010,
		32'd0, 1'b1, "Unsupported control 1010");

	run_test(32'd10, 32'd5, 4'b1011,
		32'd0, 1'b1, "Unsupported control 1011");

	run_test(32'd10, 32'd5, 4'b1100,
		32'd0, 1'b1, "Unsupported control 1100");

	run_test(32'd10, 32'd5, 4'b1101,
		32'd0, 1'b1, "Unsupported control 1101");

	run_test(32'd10, 32'd5, 4'b1110,
		32'd0, 1'b1, "Unsupported control 1110");

	run_test(32'd10, 32'd5, 4'b1111,
		32'd0, 1'b1, "Unsupported control 1111");

	// --------------------------------------------------
	// TEST GROUP 12: Zero flag verification
	// --------------------------------------------------

	run_test(32'd10, 32'd10, 4'b0001,
		32'd0, 1'b1, "Zero flag after subtraction");

	run_test(32'd10, 32'd5, 4'b0001,
		32'd5, 1'b0, "Zero flag after nonzero subtraction");

	run_test(32'hAAAAAAAA, 32'h55555555, 4'b0010,
		32'd0, 1'b1, "Zero flag after AND");

	run_test(32'hFFFFFFFF, 32'hFFFFFFFF, 4'b0100,
		32'd0, 1'b1, "Zero flag after XOR");

	run_test(32'd0, 32'd0, 4'b0000,
		32'd0, 1'b1, "Zero flag after addition");

	run_test(32'd1, 32'd1, 4'b1000,
		32'd0, 1'b1, "Zero flag after SLT false");

	run_test(32'd1, 32'd2, 4'b1001,
		32'd1, 1'b0, "Zero flag after SLTU true");

	// --------------------------------------------------
	// FINAL RESULTS
	// --------------------------------------------------

	$display("");
	$display("========================================");
	$display("               ALU TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	$display("========================================");

	if (failed == 0)
		$display("ALL ALU TESTS PASSED!");
	else
		$display("ALU TESTS FAILED!");

	$display("========================================");

	$finish;
end


endmodule