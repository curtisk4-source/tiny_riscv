`timescale 1ns/1ps

module tb_instruction_memory;

	reg [31:0] pc;
	wire [31:0] instruction;

	// Instantiate instruction memory
	instruction_memory uut (
		.pc(pc),
		.instruction(instruction)
	);

	initial begin

		$dumpfile("instruction_memory.vcd");
		$dumpvars(0, tb_instruction_memory);

		// Test instruction 0
		pc = 32'h00000000;
		#10;
		$display("PC = %h | Instruction = %h",
			pc, instruction);

		if (instruction !== 32'h00A00093)
			$display("FAIL: Instruction 0");
		else
			$display("PASS: Instruction 0");

		// Test instruction 1
		pc = 32'h00000004;
		#10;
		$display("PC = %h | Instruction = %h",
			pc, instruction);

		if (instruction !== 32'h01400113)
			$display("FAIL: Instruction 1");
		else
			$display("PASS: Instruction 1");

		// Test instruction 2
		pc = 32'h00000008;
		#10;
		$display("PC = %h | Instruction = %h",
			pc, instruction);

		if (instruction !== 32'h002081B3)
			$display("FAIL: Instruction 2");
		else
			$display("PASS: Instruction 2");

		$display("Instruction Memory Testing Complete");

		$finish;
	end

endmodule
