`timescale 1ns/1ps

module tb_tiny_riscv;

	reg clk;
	reg reset;

	tiny_riscv uut (
		.clk(clk),
		.reset(reset)
	);

	always #5 clk = ~clk;

	initial begin

		$dumpfile("cpu.vcd");
		$dumpvars(0, tb_tiny_riscv);

		clk = 0;
		reset = 1;

		#20;
		reset = 0;

		// Allow the program to execute
		#300;

		$display("");
		$display("==============================");
		$display("     RISC-V SIMULATION");
		$display("==============================");

		$display("Register x15 = %0d", uut.RF.registers[15]);

		$display("Memory[240] = %0d", uut.DMEM.memory[240]);
		$display("Memory[241] = %0d", uut.DMEM.memory[241]);
		$display("Memory[242] = %0d", uut.DMEM.memory[242]);

		if (uut.DMEM.memory[240] == 30)
			$display("TEST PASSED!");
		else
			$display("TEST FAILED!");

		$display("==============================");
		$finish;

	end

endmodule