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
	
	assign word_address = Address[9:2];
	
	always @ (posedge clk) begin
		if (MemWrite) begin
			memory[word_address] <= WriteData;
		end
	end
	
	always @ (*) begin
		if (MemRead) begin
			ReadData = memory[word_address];
		end
		else begin
			ReadData = 32'b0;
		end
	end

endmodule