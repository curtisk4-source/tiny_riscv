
module register_file (

	input wire clk,

	// Read addresses
	input wire [3:0] rs1,
	input wire [3:0] rs2,

	// Write addresses and data
	input wire [3:0] rd,
	input wire [31:0] write_data,

	// Write en
	input wire reg_write,

	// Read outputs
	output wire [31:0] read_data1,
	output wire [31:0] read_data2
);

	// 16 32-bit wide registers
	reg [31:0] registers [0:15];

	// Read operations
	assign read_data1 = (rs1 == 4'b0000) ? 32'b0 : registers[rs1];

	assign read_data2 = (rs2 == 4'b0000) ? 32'b0 : registers[rs2];

	always @ (posedge clk) begin
		if (reg_write && rd != 4'b0000) begin
			registers[rd] <= write_data;
		end
	end

endmodule
