`timescale 1ns/1ps

module pc_logic_tb;

	reg [31:0] PC;
	reg [31:0] BranchImmediate;
	reg [31:0] JumpImmediate;

	reg Branch;
	reg Jump;
	reg Zero;

	wire [31:0] NextPC;

	// Instantiate PC Logic
	pc_logic uut (
		.PC(PC),
		.BranchImmediate(BranchImmediate),
		.JumpImmediate(JumpImmediate),
		.Branch(Branch),
		.Jump(Jump),
		.Zero(Zero),
		.NextPC(NextPC)
	);

	initial begin

		// Initialize inputs
		PC = 32'd100;
		BranchImmediate = 32'd20;
		JumpImmediate = 32'd40;
		Branch = 0;
		Jump = 0;
		Zero = 0;

		// TEST 1: Normal Execution
		#10;
		$display("TEST 1: Normal Execution");
		$display("Expected: 104 | Actual: %d", NextPC);

		if (NextPC === 32'd104)
			$display("PASSED");
		else
			$display("FAILED");

		// TEST 2: BEQ Taken
		Branch = 1;
		Zero = 1;

		#10;
		$display("\nTEST 2: BEQ Taken");
		$display("Expected: 120 | Actual: %d", NextPC);

		if (NextPC === 32'd120)
			$display("PASSED");
		else
			$display("FAILED");

		// TEST 3: BEQ Not Taken
		Zero = 0;

		#10;
		$display("\nTEST 3: BEQ Not Taken");
		$display("Expected: 104 | Actual: %d", NextPC);

		if (NextPC === 32'd104)
			$display("PASSED");
		else
			$display("FAILED");

		// TEST 4: JAL
		Branch = 0;
		Jump = 1;

		#10;
		$display("\nTEST 4: JAL");
		$display("Expected: 140 | Actual: %d", NextPC);

		if (NextPC === 32'd140)
			$display("PASSED");
		else
			$display("FAILED");

		// TEST 5: JAL Priority
		Branch = 1;
		Zero = 1;

		#10;
		$display("\nTEST 5: JAL Priority");
		$display("Expected: 140 | Actual: %d", NextPC);

		if (NextPC === 32'd140)
			$display("PASSED");
		else
			$display("FAILED");

		// End simulation
		$display("\nSimulation complete!");
		$finish;

	end

endmodule
