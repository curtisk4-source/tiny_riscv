
`timescale 1ns / 1ps

module tiny_riscv_tb;

	// ==========================================
	// CLOCK AND RESET
	// ==========================================

	reg clk;
	reg reset;

	integer errors;
	integer i;

	// ==========================================
	// PROCESSOR INSTANTIATION
	// ==========================================

	tiny_riscv DUT (
		.clk(clk),
		.reset(reset)
	);

	// 10 ns clock period
	always #5 clk = ~clk;

	// ==========================================
	// TESTBENCH
	// ==========================================

	initial begin

		clk = 0;
		reset = 1;
		errors = 0;

		// Initialize instruction memory with NOPs
		// ADDI x0, x0, 0

		#1;

		for (i = 0; i < 256; i = i + 1) begin
			DUT.IMEM.mem[i] = 32'h00000013;
		end

		// ======================================
		// TEST PROGRAM
		// ======================================

		// Arithmetic tests

		DUT.IMEM.mem[0] = 32'h00A00093; // ADDI x1, x0, 10
		DUT.IMEM.mem[1] = 32'h00A00113; // ADDI x2, x0, 10

		// Branch test

		DUT.IMEM.mem[2] = 32'h00208463; // BEQ x1, x2, +8
		DUT.IMEM.mem[3] = 32'h06300193; // ADDI x3, x0, 99 (SKIPPED)
		DUT.IMEM.mem[4] = 32'h00700193; // ADDI x3, x0, 7

		// Jump test

		DUT.IMEM.mem[5] = 32'h008002EF; // JAL x5, +8
		DUT.IMEM.mem[6] = 32'h06300313; // ADDI x6, x0, 99 (SKIPPED)
		DUT.IMEM.mem[7] = 32'h00B00313; // ADDI x6, x0, 11

		// LUI test

		DUT.IMEM.mem[8] = 32'h123453B7; // LUI x7, 0x12345

		// AUIPC test

		DUT.IMEM.mem[9] = 32'h00001417; // AUIPC x8, 0x1

		// Store and load tests

		DUT.IMEM.mem[10] = 32'h00302023; // SW x3, 0(x0)
		DUT.IMEM.mem[11] = 32'h00002203; // LW x4, 0(x0)

		// ======================================
		// RESET PROCESSOR
		// ======================================

		@(posedge clk);
		#1 reset = 0;

		// ======================================
		// EXECUTE PROGRAM
		// ======================================

		repeat (10) begin
			@(posedge clk);
			#1;
		end

		// ======================================
		// DISPLAY RESULTS
		// ======================================

		$display("");
		$display("==================================");
		$display("       TINY RISC-V TESTBENCH");
		$display("==================================");

		$display("");
		$display("REGISTER RESULTS:");

		$display("x1 = %d", DUT.RF.registers[1]);
		$display("x2 = %d", DUT.RF.registers[2]);
		$display("x3 = %d", DUT.RF.registers[3]);
		$display("x4 = %d", DUT.RF.registers[4]);
		$display("x5 = %d", DUT.RF.registers[5]);
		$display("x6 = %d", DUT.RF.registers[6]);

		$display("");
		$display("SPECIAL INSTRUCTION RESULTS:");

		$display("x7 (LUI)   = %h", DUT.RF.registers[7]);
		$display("x8 (AUIPC) = %h", DUT.RF.registers[8]);

		$display("");
		$display("MEMORY RESULTS:");

		$display("Memory[0] = %d", DUT.DMEM.memory[0]);

		$display("");
		$display("PROGRAM COUNTER:");

		$display("PC = %d", DUT.pc);

		// ======================================
		// AUTOMATIC TESTS
		// ======================================

		$display("");
		$display("==================================");
		$display("          TEST RESULTS");
		$display("==================================");

		// ADDI tests

		if (DUT.RF.registers[1] === 32'd10)
			$display("PASS: ADDI x1");
		else begin
			$display("FAIL: ADDI x1");
			errors = errors + 1;
		end

		if (DUT.RF.registers[2] === 32'd10)
			$display("PASS: ADDI x2");
		else begin
			$display("FAIL: ADDI x2");
			errors = errors + 1;
		end

		// BEQ test

		if (DUT.RF.registers[3] === 32'd7)
			$display("PASS: BEQ branch");
		else begin
			$display("FAIL: BEQ branch");
			errors = errors + 1;
		end

		// JAL test

		if (DUT.RF.registers[5] === 32'd24)
			$display("PASS: JAL jump and return address");
		else begin
			$display("FAIL: JAL jump and return address");
			errors = errors + 1;
		end

		// Instruction after JAL should be skipped

		if (DUT.RF.registers[6] === 32'd11)
			$display("PASS: JAL skips instruction");
		else begin
			$display("FAIL: JAL skips instruction");
			errors = errors + 1;
		end

		// LUI test

		if (DUT.RF.registers[7] === 32'h12345000)
			$display("PASS: LUI");
		else begin
			$display("FAIL: LUI");
			errors = errors + 1;
		end

		// AUIPC test

		if (DUT.RF.registers[8] === 32'h00001024)
			$display("PASS: AUIPC");
		else begin
			$display("FAIL: AUIPC");
			errors = errors + 1;
		end

		// SW test

		if (DUT.DMEM.memory[0] === 32'd7)
			$display("PASS: SW");
		else begin
			$display("FAIL: SW");
			errors = errors + 1;
		end

		// LW test

		if (DUT.RF.registers[4] === 32'd7)
			$display("PASS: LW");
		else begin
			$display("FAIL: LW");
			errors = errors + 1;
		end

		// Final PC test

		if (DUT.pc === 32'd48)
			$display("PASS: Program counter");
		else begin
			$display("FAIL: Program counter");
			errors = errors + 1;
		end

		// ======================================
		// FINAL SUMMARY
		// ======================================

		$display("");
		$display("==================================");

		if (errors == 0) begin
			$display("       ALL TESTS PASSED!");
		end
		else begin
			$display("       TESTS FAILED!");
			$display("       Errors: %0d", errors);
		end

		$display("==================================");

		$finish;

	end

endmodule
