module instruction_memory (
	input wire [31:0] pc,
	output wire [31:0] instruction
);

	// 256 words of 32-bit instruction memory
	reg [31:0] mem [0:255];

	integer i;

	initial begin

		// Initialize unused memory with RISC-V NOP instructions
		for (i = 0; i < 256; i = i + 1)
			mem[i] = 32'h00000013;

		// Load compiled RISC-V program
		$readmemh("program.mem", mem);

	end

	assign instruction = mem[pc[9:2]];

endmodule