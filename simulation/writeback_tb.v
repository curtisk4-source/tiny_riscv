`timescale 1ns/1ps

module writeback_tb;

	reg [31:0] ALUResult;
	reg [31:0] ReadData;
	reg [31:0] PCPlus4;
	reg [31:0] Immediate;
	reg [1:0] WritebackSel;

	wire [31:0] WriteData;

	// Instantiate Writeback
	writeback uut (
		.ALUResult(ALUResult),
		.ReadData(ReadData),
		.PCPlus4(PCPlus4),
		.Immediate(Immediate),
		.WritebackSel(WritebackSel),
		.WriteData(WriteData)
	);

	initial begin

		// Initialize inputs
		ALUResult = 32'd15;
		ReadData = 32'd25;
		PCPlus4 = 32'd104;
		Immediate = 32'd50;
		WritebackSel = 2'b00;

		// TEST 1: ALU Result
		#10;
		$display("TEST 1: ALU Result");
		$display("Expected: 15 | Actual: %d", WriteData);

		if (WriteData === 32'd15)
			$display("PASSED");
		else
			$display("FAILED");

		// TEST 2: Data Memory
		WritebackSel = 2'b01;

		#10;
		$display("\nTEST 2: Data Memory");
		$display("Expected: 25 | Actual: %d", WriteData);

		if (WriteData === 32'd25)
			$display("PASSED");
		else
			$display("FAILED");

		// TEST 3: PC + 4
		WritebackSel = 2'b10;

		#10;
		$display("\nTEST 3: PC + 4");
		$display("Expected: 104 | Actual: %d", WriteData);

		if (WriteData === 32'd104)
			$display("PASSED");
		else
			$display("FAILED");

		// TEST 4: Immediate
		WritebackSel = 2'b11;

		#10;
		$display("\nTEST 4: Immediate");
		$display("Expected: 50 | Actual: %d", WriteData);

		if (WriteData === 32'd50)
			$display("PASSED");
		else
			$display("FAILED");

		// End simulation
		$display("\nSimulation complete!");
		$finish;

	end

endmodule
