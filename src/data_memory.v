module data_memory (
	input wire clk,
	input wire MemRead,
	input wire MemWrite,

	input wire [31:0] Address,
	input wire [31:0] WriteData,

	output reg [31:0] ReadData
);

	reg [31:0] memory [0:255];

	wire [7:0] word_address;

	integer i;

	assign word_address = Address[9:2];

	// Initialize data memory
	initial begin
		for (i = 0; i < 256; i = i + 1)
			memory[i] = 32'b0;
	end

	// Write operation
	always @(posedge clk) begin
		if (MemWrite) begin

			$display("MEM WRITE: Address=%h Data=%0d Index=%0d",
				Address, WriteData, word_address);

			memory[word_address] <= WriteData;

		end
	end

	// Read operation
	always @(*) begin
		if (MemRead)
			ReadData = memory[word_address];
		else
			ReadData = 32'b0;
	end

endmodule