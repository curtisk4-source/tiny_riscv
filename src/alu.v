
module alu (
	input wire [31:0] input_a,
	input wire [31:0] input_b,

	input wire [3:0] alu_control,

	output reg [31:0] result,
	output wire zero
);

	always @ (*) begin

		case(alu_control)

			// ADD
			4'b0000:
				result = input_a + input_b;

			// SUB
			4'b0001:
				result = input_a - input_b;

			// AND
			4'b0010:
				result = input_a & input_b;

			// OR
			4'b0011:
				result = input_a | input_b;

			// XOR
			4'b0100:
				result = input_a ^ input_b;

			// SHIFT LEFT (SLL)
			4'b0101:
				result = input_a << input_b[4:0];

			// SHIFT RIGHT LOGICAL (SRL)
			4'b0110:
				result = input_a >> input_b[4:0];

			// SHIFT RIGHT ARITHMETIC (SRA)
			4'b0111:
				result = $signed(input_a) >>> input_b[4:0];

			// SET LESS THAN SIGNED (SLT)
			4'b1000:
				result = ($signed(input_a) < $signed(input_b)) ? 32'd1 : 32'd0;

			// SET LESS THAN UNSIGNED (SLTU)
			4'b1001:
				result = (input_a < input_b) ? 32'd1 : 32'd0;

			default:
				result = 32'b0;

		endcase

	end

	assign zero = (result == 32'b0);

endmodule
