
`timescale 1ns/1ps

module tiny_riscv_tb;

	reg clk;
	reg reset;

	tiny_riscv uut (
		.clk(clk),
		.reset(reset)
	);

	always #5 clk = ~clk;

	initial begin

		$dumpfile("cpu.vcd");
		$dumpvars(0, tiny_riscv_tb);

		clk = 0;
		reset = 1;

		#20;
		reset = 0;

		// Allow the program to execute
		#500;

		$display("");
		$display("==============================");
		$display("	RISC-V SIMULATION");
		$display("==============================");

		// Display register values
		$display("Register x1 = %0d", uut.RF.registers[1]);
		$display("Register x2 = %0d", uut.RF.registers[2]);
		$display("Register x3 = %0d", uut.RF.registers[3]);

		// Display register values in hexadecimal
		$display("Register x1 (hex) = %h", uut.RF.registers[1]);
		$display("Register x2 (hex) = %h", uut.RF.registers[2]);
		$display("Register x3 (hex) = %h", uut.RF.registers[3]);

		// Display CPU debug information
		$display("");
		$display("===== CPU DEBUG =====");
		$display("PC = %h", uut.pc);
		$display("Instruction = %h", uut.instruction);
		$display("ALU Result = %h", uut.alu_result);
		$display("Next PC = %h", uut.next_pc);
		$display("RegWrite = %b", uut.RegWrite);
		$display("=====================");

		// Check compiled C program
		if (
			uut.RF.registers[14] == 10 &&
			uut.RF.registers[15] == 30 &&
			uut.DMEM.memory[242] == 10 &&
			uut.DMEM.memory[241] == 20 &&
			uut.DMEM.memory[240] == 30
		)
			$display("C PROGRAM TEST PASSED!");
		else
			$display("C PROGRAM TEST FAILED!");
		$display("=====================");
			
		$display("");
		$display("===== STACK DEBUG =====");

		$display("SP (x2) = %h", uut.RF.registers[2]);
		$display("FP (x8) = %h", uut.RF.registers[8]);

		$display("");
		$display("===== DATA MEMORY =====");

		$display("Memory[248] = %0d", uut.DMEM.memory[248]);
		$display("Memory[249] = %0d", uut.DMEM.memory[249]);
		$display("Memory[250] = %0d", uut.DMEM.memory[250]);
		$display("Memory[251] = %0d", uut.DMEM.memory[251]);
		$display("Memory[252] = %0d", uut.DMEM.memory[252]);
		$display("Memory[253] = %0d", uut.DMEM.memory[253]);
		$display("Memory[254] = %0d", uut.DMEM.memory[254]);
		$display("Memory[255] = %0d", uut.DMEM.memory[255]);

		$display("");
		$display("===== REGISTER DEBUG =====");

		$display("x14 (a4) = %0d", uut.RF.registers[14]);
		$display("x15 (a5) = %0d", uut.RF.registers[15]);
		
		$finish;

	end

endmodule
