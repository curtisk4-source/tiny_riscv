module instruction_memory (
	input wire [31:0] pc,
	output wire [31:0] instruction
);

	// 256 words of 32-bit instruction memory
	reg [31:0] mem [0:255];
	
	initial begin
		$readmemh("program.mem", mem);
	end
	
	assign instruction = mem[pc[9:2]];

endmodule