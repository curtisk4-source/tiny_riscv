module instruction_memory (
	input wire [31:0] pc,
	output wire [31:0] instruction
);

	reg [31:0] memory [0:1023];

	integer i;

	initial begin
		for (i = 0; i < 1024; i = i + 1)
			memory[i] = 32'h00000013;

		$readmemh("C:/Users/Kevin/OneDrive/Desktop/ECE287/tiny_riscv/software/program.mem", memory);
	end

	assign instruction = memory[pc[11:2]];

endmodule
