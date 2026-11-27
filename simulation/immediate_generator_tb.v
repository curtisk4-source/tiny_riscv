`timescale 1ns/1ps

module immediate_generator_tb;

reg [31:0] instruction;
reg [2:0] imm_sel;

wire [31:0] immediate;

integer passed;
integer failed;

// Device under test
immediate_generator uut (
	.instruction(instruction),
	.imm_sel(imm_sel),
	.immediate(immediate)
);

// Compare the generated immediate against the expected value.
task check_immediate;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		if (immediate === expected) begin
			$display("PASS: %0s | Expected: %h | Actual: %h",
				test_name, expected, immediate);
			passed = passed + 1;
		end
		else begin
			$display("FAIL: %0s | Expected: %h | Actual: %h",
				test_name, expected, immediate);
			failed = failed + 1;
		end
	end
endtask

// Generate and verify an I-type immediate.
task test_i_type;
	input [11:0] imm;
	input [255:0] test_name;

	begin
		instruction = {imm, 20'b0};
		imm_sel = 3'b000;
		#1;

		check_immediate({{20{imm[11]}}, imm}, test_name);
	end
endtask

// Generate and verify an S-type immediate.
task test_s_type;
	input [11:0] imm;
	input [255:0] test_name;

	begin
		instruction = {
			imm[11:5],
			12'b0,
			imm[4:0],
			7'b0
		};

		imm_sel = 3'b001;
		#1;

		check_immediate({{20{imm[11]}}, imm}, test_name);
	end
endtask

// Generate and verify a B-type immediate.
task test_b_type;
	input [12:0] imm;
	input [255:0] test_name;

	begin
		instruction = {
			imm[12],
			imm[10:5],
			13'b0,
			imm[4:1],
			imm[11],
			7'b0
		};

		imm_sel = 3'b010;
		#1;

		check_immediate({{19{imm[12]}}, imm}, test_name);
	end
endtask

// Generate and verify a U-type immediate.
task test_u_type;
	input [19:0] imm;
	input [255:0] test_name;

	begin
		instruction = {imm, 12'b0};
		imm_sel = 3'b011;
		#1;

		check_immediate({imm, 12'b0}, test_name);
	end
endtask

// Generate and verify a J-type immediate.
task test_j_type;
	input [20:0] imm;
	input [255:0] test_name;

	begin
		instruction = {
			imm[20],
			imm[10:1],
			imm[11],
			imm[19:12],
			12'b0
		};

		imm_sel = 3'b100;
		#1;

		check_immediate({{11{imm[20]}}, imm}, test_name);
	end
endtask

initial begin
	$dumpfile("immediate_generator.vcd");
	$dumpvars(0, immediate_generator_tb);

	passed = 0;
	failed = 0;

	instruction = 0;
	imm_sel = 0;

	// --------------------------------------------------
	// TEST GROUP 1: I-type immediate
	// --------------------------------------------------

	test_i_type(12'h000, "I-type zero");

	test_i_type(12'h001, "I-type minimum positive");

	test_i_type(12'h7FF, "I-type maximum positive");

	test_i_type(12'h800, "I-type minimum negative");

	test_i_type(12'hFFF, "I-type negative one");

	test_i_type(12'h555, "I-type alternating pattern A");

	test_i_type(12'hAAA, "I-type alternating pattern B");

	// --------------------------------------------------
	// TEST GROUP 2: S-type immediate
	// --------------------------------------------------

	test_s_type(12'h000, "S-type zero");

	test_s_type(12'h001, "S-type minimum positive");

	test_s_type(12'h7FF, "S-type maximum positive");

	test_s_type(12'h800, "S-type minimum negative");

	test_s_type(12'hFFF, "S-type negative one");

	test_s_type(12'h555, "S-type alternating pattern A");

	test_s_type(12'hAAA, "S-type alternating pattern B");

	// --------------------------------------------------
	// TEST GROUP 3: B-type immediate
	// --------------------------------------------------

	test_b_type(13'h0000, "B-type zero");

	test_b_type(13'h0002, "B-type minimum positive");

	test_b_type(13'h0FFE, "B-type maximum positive");

	test_b_type(13'h1000, "B-type minimum negative");

	test_b_type(13'h1FFE, "B-type negative two");

	test_b_type(13'h1FFF, "B-type negative one encoding");

	test_b_type(13'h0554, "B-type alternating pattern A");

	test_b_type(13'h0AAA, "B-type alternating pattern B");

	// --------------------------------------------------
	// TEST GROUP 4: U-type immediate
	// --------------------------------------------------

	test_u_type(20'h00000, "U-type zero");

	test_u_type(20'h00001, "U-type minimum positive");

	test_u_type(20'h7FFFF, "U-type maximum positive");

	test_u_type(20'h80000, "U-type sign boundary");

	test_u_type(20'hFFFFF, "U-type maximum bit pattern");

	test_u_type(20'hAAAAA, "U-type alternating pattern A");

	test_u_type(20'h55555, "U-type alternating pattern B");

	// --------------------------------------------------
	// TEST GROUP 5: J-type immediate
	// --------------------------------------------------

	test_j_type(21'h000000, "J-type zero");

	test_j_type(21'h000002, "J-type minimum positive");

	test_j_type(21'h0FFFFE, "J-type maximum positive");

	test_j_type(21'h100000, "J-type minimum negative");

	test_j_type(21'h1FFFFE, "J-type negative two");

	test_j_type(21'h1FFFFF, "J-type negative one");

	test_j_type(21'h055554, "J-type alternating pattern A");

	test_j_type(21'h0AAAAA, "J-type alternating pattern B");

	// --------------------------------------------------
	// TEST GROUP 6: Immediate selection changes
	// --------------------------------------------------

	instruction = 32'h7FF00013;

	imm_sel = 3'b000;
	#1;
	check_immediate(32'h000007FF,
		"Selection change to I-type");

	imm_sel = 3'b001;
	#1;
	check_immediate(32'h000007E0,
		"Selection change to S-type");

	imm_sel = 3'b010;
	#1;
	check_immediate(32'h000007E0,
		"Selection change to B-type");

	imm_sel = 3'b011;
	#1;
	check_immediate(32'h7FF00000,
		"Selection change to U-type");

	imm_sel = 3'b100;
	#1;
	check_immediate(32'h000FF7FE,
		"Selection change to J-type");

	// --------------------------------------------------
	// TEST GROUP 7: Invalid immediate selections
	// --------------------------------------------------

	imm_sel = 3'b101;
	#1;
	check_immediate(32'h00000000,
		"Invalid selection 101");

	imm_sel = 3'b110;
	#1;
	check_immediate(32'h00000000,
		"Invalid selection 110");

	imm_sel = 3'b111;
	#1;
	check_immediate(32'h00000000,
		"Invalid selection 111");

	// --------------------------------------------------
	// FINAL RESULTS
	// --------------------------------------------------

	$display("");
	$display("========================================");
	$display("    IMMEDIATE GENERATOR TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	$display("========================================");

	if (failed == 0)
		$display("ALL IMMEDIATE TESTS PASSED!");
	else
		$display("IMMEDIATE GENERATOR TESTS FAILED!");

	$display("========================================");

	$finish;
end


endmodule