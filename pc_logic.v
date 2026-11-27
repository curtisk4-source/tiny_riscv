module pc_logic (
	input wire [31:0] PC,
	input wire [31:0] BranchImmediate,
	input wire [31:0] JumpImmediate,

	input wire Branch,
	input wire Jump,
	input wire Zero,

	output reg [31:0] NextPC
);

	always @ (*) begin

		// JAL
		if (Jump) begin
			NextPC = PC + JumpImmediate;
		end

		// BEQ (Branch Taken)
		else if (Branch && Zero) begin
			NextPC = PC + BranchImmediate;
		end

		// Normal Execution
		else begin
			NextPC = PC + 32'd4;
		end

	end

endmodule
