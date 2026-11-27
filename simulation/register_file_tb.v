`timescale 1ns/1ps

module register_file_tb;
	reg clk;
	reg [3:0] rs1, rs2, rd;
	reg [31:0] write_data;
	reg reg_write;

	wire [31:0] read_data1, read_data2;

	register_file uut (
		.clk(clk),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.write_data(write_data),
		.reg_write(reg_write),
		.read_data1(read_data1),
		.read_data2(read_data2)
	);

	// Clock generation
	always #5 clk = ~clk;

	initial begin
		clk = 0;
		rs1 = 0;
		rs2 = 0;
		rd = 0;
		write_data = 0;
		reg_write = 0;

		// Write 10 into x1
		#10;
		rd = 1;
		write_data = 10;
		reg_write = 1;

		#10;
		reg_write = 0;

		// Write 20 into x2
		rd = 2;
		write_data = 20;
		reg_write = 1;

		#10;
		reg_write = 0;

		// Read x1 and x2
		rs1 = 1;
		rs2 = 2;

		#10;

		$display("x1 = %d", read_data1);
		$display("x2 = %d", read_data2);

		// Test x0
		rs1 = 0;
		#10;
		$display("x0 = %d", read_data1);

		$finish;
	end

endmodule
