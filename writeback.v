module writeback (
	input wire [31:0] ALUResult,
	input wire [31:0] ReadData,
	input wire [31:0] PCPlus4,
	input wire [31:0] Immediate,

	input wire [1:0] WritebackSel,

	output reg [31:0] WriteData
);

	always @ (*) begin

		case (WritebackSel)

			// ALU result
			2'b00:
				WriteData = ALUResult;

			// Data memory
			2'b01:
				WriteData = ReadData;

			// PC + 4 (JAL)
			2'b10:
				WriteData = PCPlus4;

			// Immediate (LUI)
			2'b11:
				WriteData = Immediate;

			default:
				WriteData = 32'b0;

		endcase

	end

endmodule
