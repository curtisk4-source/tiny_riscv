`timescale 1ns/1ps

module alu_tb;

	reg [31:0] input_a, input_b;
	reg [3:0] alu_control;

	wire [31:0] result;
	wire zero;

	// Instantiate ALU
	alu uut (
		.input_a(input_a),
		.input_b(input_b),
		.alu_control(alu_control),
		.result(result),
		.zero(zero)
	);

	initial begin

		// ADD: 10 + 5 = 15
		input_a = 10;
		input_b = 5;
		alu_control = 4'b0000;
		#10;
		$display("ADD: %d", result);

		// SUB: 10 - 5 = 5
		alu_control = 4'b0001;
		#10;
		$display("SUB: %d", result);

		// AND
		alu_control = 4'b0010;
		#10;
		$display("AND: %d", result);

		// OR
		alu_control = 4'b0011;
		#10;
		$display("OR: %d", result);

		// XOR
		alu_control = 4'b0100;
		#10;
		$display("XOR: %d", result);

		// SLL:
		alu_control = 4'b0101;
		#10;
		$display("SLL: %d", result);

		// SRL (positive): 10 > 5 = 0
		alu_control = 4'b0110;
		#10;
		$display("SRL: %d", result);

		// SRA (positive): 10 >>> 5 = 0
		alu_control = 4'b0111;
		#10;
		$display("SRA (positive): %d", result);

		// SLT: 10 < 5 = 0
		alu_control = 4'b1000;
		#10;
		$display("SLT: %d", result);

		// SLTU: SLTU 10 < 5 (unsigned) = 0
		alu_control = 4'b1001;
		#10;
		$display("SLTU: %d", result);

		// default: = 0
		alu_control = 4'b1111;
		#10;
		$display("default: %d", result);

		// Zero flag test: 10 - 10 = 0
		input_b = 10;
		alu_control = 4'b0001;
		#10;
		$display("Zero flag: %b", zero);

		// Test SRL & SRA with negative numbers
		input_a = 32'hFFFFFFF0;
		input_b = 2;

		// SRL (negative): 32'hFFFFFFF0 > 2 = 3ffffffc
		alu_control = 4'b0110;
		#10;
		$display("SRL (negative): %h", result);

		// SRA (negative): 32'hFFFFFFF0 >>> 2 = fffffffc
		alu_control = 4'b0111;
		#10;
		$display("SRA (negative): %h", result);

		$finish;

	end

endmodule
