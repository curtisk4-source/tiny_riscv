`timescale 1ns/1ps

module register_file_tb;

reg clk;
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;
reg [31:0] write_data;
reg reg_write;

wire [31:0] read_data1;
wire [31:0] read_data2;

integer passed;
integer failed;
integer i;

// Device under test
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

// Generate a 10 ns clock period.
always #5 clk = ~clk;

// Compare both read ports against expected values.
task check_read;
	input [31:0] expected1;
	input [31:0] expected2;
	input [255:0] test_name;

	begin
		if (
			(read_data1 === expected1) &&
			(read_data2 === expected2)
		) begin
			$display("PASS: %0s", test_name);
			passed = passed + 1;
		end
		else begin
			$display("FAIL: %0s", test_name);
			$display("Expected read 1: %h | Actual: %h",
				expected1, read_data1);
			$display("Expected read 2: %h | Actual: %h",
				expected2, read_data2);
			failed = failed + 1;
		end
	end
endtask

// Write a value to a register on the active clock edge.
task write_register;
	input [4:0] address;
	input [31:0] value;

	begin
		@(negedge clk);
		rd = address;
		write_data = value;
		reg_write = 1'b1;

		@(posedge clk);
		#1;
		reg_write = 1'b0;
	end
endtask

initial begin
	$dumpfile("register_file.vcd");
	$dumpvars(0, register_file_tb);

	passed = 0;
	failed = 0;

	clk = 0;
	rs1 = 0;
	rs2 = 0;
	rd = 0;
	write_data = 0;
	reg_write = 0;

	// --------------------------------------------------
	// TEST GROUP 1: Register x0
	// --------------------------------------------------

	write_register(5'd0, 32'd100);

	rs1 = 5'd0;
	rs2 = 5'd0;
	#1;
	check_read(32'd0, 32'd0, "x0 remains zero");

	// --------------------------------------------------
	// TEST GROUP 2: Basic register writes and reads
	// --------------------------------------------------

	write_register(5'd1, 32'd10);
	write_register(5'd2, 32'd20);
	write_register(5'd3, 32'd30);

	rs1 = 5'd1;
	rs2 = 5'd2;
	#1;
	check_read(32'd10, 32'd20, "Read x1 and x2");

	rs1 = 5'd3;
	rs2 = 5'd1;
	#1;
	check_read(32'd30, 32'd10, "Read x3 and x1");

	// --------------------------------------------------
	// TEST GROUP 3: Register boundary addresses
	// --------------------------------------------------

	write_register(5'd31, 32'hFFFFFFFF);

	rs1 = 5'd31;
	rs2 = 5'd0;
	#1;
	check_read(32'hFFFFFFFF, 32'd0, "Read x31 and x0");

	write_register(5'd1, 32'h80000000);

	rs1 = 5'd1;
	#1;
	check_read(32'h80000000, 32'hFFFFFFFF,
		"Read minimum signed value and x31");

	// --------------------------------------------------
	// TEST GROUP 4: All registers
	// --------------------------------------------------

	for (i = 1; i < 32; i = i + 1)
		write_register(i, i * 100);

	for (i = 1; i < 32; i = i + 1) begin
		rs1 = i;
		rs2 = i;
		#1;
		check_read(i * 100, i * 100,
			"Register write/read verification");
	end

	// --------------------------------------------------
	// TEST GROUP 5: Disabled write
	// --------------------------------------------------

	@(negedge clk);
	rd = 5'd5;
	write_data = 32'd999;
	reg_write = 1'b0;

	@(posedge clk);
	#1;

	rs1 = 5'd5;
	#1;
	check_read(32'd500, 32'd500,
		"Disabled write preserves register value");

	// --------------------------------------------------
	// TEST GROUP 6: Repeated writes
	// --------------------------------------------------

	write_register(5'd10, 32'd100);
	write_register(5'd10, 32'd200);
	write_register(5'd10, 32'd300);

	rs1 = 5'd10;
	rs2 = 5'd10;
	#1;
	check_read(32'd300, 32'd300,
		"Repeated writes update register");

	// --------------------------------------------------
	// TEST GROUP 7: Independent read ports
	// --------------------------------------------------

	rs1 = 5'd1;
	rs2 = 5'd31;
	#1;
	check_read(32'd100, 32'hFFFFFFFF,
		"Independent simultaneous reads");

	// --------------------------------------------------
	// FINAL RESULTS
	// --------------------------------------------------

	$display("");
	$display("========================================");
	$display("         REGISTER FILE TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	if (failed == 0)
		$display("ALL REGISTER FILE TESTS PASSED!");
	else
		$display("REGISTER FILE TESTS FAILED!");

	$display("========================================");

	$finish;
end


endmodule