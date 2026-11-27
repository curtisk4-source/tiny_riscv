`timescale 1ns/1ps

module writeback_tb;

reg [31:0] ALUResult;
reg [31:0] ReadData;
reg [31:0] PCPlus4;
reg [31:0] Immediate;
reg [1:0] WritebackSel;

wire [31:0] WriteData;

integer passed;
integer failed;

// Device under test
writeback uut (
	.ALUResult(ALUResult),
	.ReadData(ReadData),
	.PCPlus4(PCPlus4),
	.Immediate(Immediate),
	.WritebackSel(WritebackSel),
	.WriteData(WriteData)
);

// Compare the selected writeback value against the expected value.
task check_writeback;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		if (WriteData === expected) begin
			$display("PASS: %0s | Expected: %h | Actual: %h",
				test_name, expected, WriteData);
			passed = passed + 1;
		end
		else begin
			$display("FAIL: %0s | Expected: %h | Actual: %h",
				test_name, expected, WriteData);
			failed = failed + 1;
		end
	end
endtask

// Apply input values and verify the selected output.
task run_test;
	input [31:0] alu_value;
	input [31:0] memory_value;
	input [31:0] pc_value;
	input [31:0] immediate_value;
	input [1:0] selection;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		ALUResult = alu_value;
		ReadData = memory_value;
		PCPlus4 = pc_value;
		Immediate = immediate_value;
		WritebackSel = selection;

		#10;

		check_writeback(expected, test_name);
	end
endtask

initial begin
	$dumpfile("writeback.vcd");
	$dumpvars(0, writeback_tb);

	passed = 0;
	failed = 0;

	ALUResult = 0;
	ReadData = 0;
	PCPlus4 = 0;
	Immediate = 0;
	WritebackSel = 0;

	// TEST GROUP 1: Normal writeback selection

	run_test(32'd15, 32'd25, 32'd104, 32'd50,
		2'b00, 32'd15, "Select ALU result");

	run_test(32'd15, 32'd25, 32'd104, 32'd50,
		2'b01, 32'd25, "Select memory data");

	run_test(32'd15, 32'd25, 32'd104, 32'd50,
		2'b10, 32'd104, "Select PC plus four");

	run_test(32'd15, 32'd25, 32'd104, 32'd50,
		2'b11, 32'd50, "Select immediate");

	// TEST GROUP 2: Zero-value inputs

	run_test(32'd0, 32'd0, 32'd0, 32'd0,
		2'b00, 32'd0, "ALU result zero");

	run_test(32'd0, 32'd0, 32'd0, 32'd0,
		2'b01, 32'd0, "Memory data zero");

	run_test(32'd0, 32'd0, 32'd0, 32'd0,
		2'b10, 32'd0, "PC plus four zero");

	run_test(32'd0, 32'd0, 32'd0, 32'd0,
		2'b11, 32'd0, "Immediate zero");

	// TEST GROUP 3: Maximum unsigned values

	run_test(32'hFFFFFFFF, 32'h00000000,
		32'h00000000, 32'h00000000,
		2'b00, 32'hFFFFFFFF, "ALU maximum unsigned value");

	run_test(32'h00000000, 32'hFFFFFFFF,
		32'h00000000, 32'h00000000,
		2'b01, 32'hFFFFFFFF, "Memory maximum unsigned value");

	run_test(32'h00000000, 32'h00000000,
		32'hFFFFFFFF, 32'h00000000,
		2'b10, 32'hFFFFFFFF, "PC maximum unsigned value");

	run_test(32'h00000000, 32'h00000000,
		32'h00000000, 32'hFFFFFFFF,
		2'b11, 32'hFFFFFFFF, "Immediate maximum unsigned value");

	// TEST GROUP 4: Signed boundary bit patterns

	run_test(32'h7FFFFFFF, 32'h00000000,
		32'h00000000, 32'h00000000,
		2'b00, 32'h7FFFFFFF, "ALU maximum signed positive");

	run_test(32'h00000000, 32'h80000000,
		32'h00000000, 32'h00000000,
		2'b01, 32'h80000000, "Memory minimum signed negative");

	run_test(32'h00000000, 32'h00000000,
		32'h7FFFFFFF, 32'h00000000,
		2'b10, 32'h7FFFFFFF, "PC maximum signed positive");

	run_test(32'h00000000, 32'h00000000,
		32'h00000000, 32'h80000000,
		2'b11, 32'h80000000, "Immediate minimum signed negative");

	// TEST GROUP 5: Alternating bit patterns

	run_test(32'hAAAAAAAA, 32'h00000000,
		32'h00000000, 32'h00000000,
		2'b00, 32'hAAAAAAAA, "ALU alternating bits A");

	run_test(32'h00000000, 32'h55555555,
		32'h00000000, 32'h00000000,
		2'b01, 32'h55555555, "Memory alternating bits B");

	run_test(32'h00000000, 32'h00000000,
		32'hAAAAAAAA, 32'h00000000,
		2'b10, 32'hAAAAAAAA, "PC alternating bits A");

	run_test(32'h00000000, 32'h00000000,
		32'h00000000, 32'h55555555,
		2'b11, 32'h55555555, "Immediate alternating bits B");

	// TEST GROUP 6: Input changes with fixed selection

	WritebackSel = 2'b00;
	ALUResult = 32'd10;
	#10;
	check_writeback(32'd10, "ALU input initial value");

	ALUResult = 32'd20;
	#10;
	check_writeback(32'd20, "ALU input updated value");

	ALUResult = 32'hFFFFFFFF;
	#10;
	check_writeback(32'hFFFFFFFF, "ALU input maximum value");

	WritebackSel = 2'b01;
	ReadData = 32'd30;
	#10;
	check_writeback(32'd30, "Memory input initial value");

	ReadData = 32'd40;
	#10;
	check_writeback(32'd40, "Memory input updated value");

	WritebackSel = 2'b10;
	PCPlus4 = 32'd100;
	#10;
	check_writeback(32'd100, "PC input initial value");

	PCPlus4 = 32'd200;
	#10;
	check_writeback(32'd200, "PC input updated value");

	WritebackSel = 2'b11;
	Immediate = 32'd300;
	#10;
	check_writeback(32'd300, "Immediate input initial value");

	Immediate = 32'd400;
	#10;
	check_writeback(32'd400, "Immediate input updated value");

	// TEST GROUP 7: Selection changes with fixed inputs

	ALUResult = 32'd11;
	ReadData = 32'd22;
	PCPlus4 = 32'd33;
	Immediate = 32'd44;

	WritebackSel = 2'b00;
	#10;
	check_writeback(32'd11, "Selection transition to ALU");

	WritebackSel = 2'b01;
	#10;
	check_writeback(32'd22, "Selection transition to memory");

	WritebackSel = 2'b10;
	#10;
	check_writeback(32'd33, "Selection transition to PC");

	WritebackSel = 2'b11;
	#10;
	check_writeback(32'd44, "Selection transition to immediate");

	WritebackSel = 2'b00;
	#10;
	check_writeback(32'd11, "Selection transition back to ALU");

	// TEST GROUP 8: Unknown selection handling

	// The RTL default branch must drive zero when the
	// selection contains unknown logic values.

	WritebackSel = 2'bx0;
	#10;
	check_writeback(32'b0, "Unknown selection x0 defaults to zero");

	WritebackSel = 2'b0x;
	#10;
	check_writeback(32'b0, "Unknown selection 0x defaults to zero");

	WritebackSel = 2'bxx;
	#10;
	check_writeback(32'b0, "Unknown selection xx defaults to zero");

	// TEST GROUP 9: Unknown and high-impedance data inputs

	// Verify that unknown data propagates when its input
	// is selected, rather than being silently suppressed.

	ALUResult = 32'hxxxxxxxx;
	WritebackSel = 2'b00;
	#10;
	check_writeback(32'hxxxxxxxx, "Selected ALU unknown data");

	ReadData = 32'hzzzzzzzz;
	WritebackSel = 2'b01;
	#10;
	check_writeback(32'hzzzzzzzz, "Selected memory high impedance data");

	PCPlus4 = 32'hxxxxxxxx;
	WritebackSel = 2'b10;
	#10;
	check_writeback(32'hxxxxxxxx, "Selected PC unknown data");

	Immediate = 32'hzzzzzzzz;
	WritebackSel = 2'b11;
	#10;
	check_writeback(32'hzzzzzzzz, "Selected immediate high impedance data");

	// FINAL RESULTS

	$display("");
	$display("========================================");
	$display("            WRITEBACK TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	$display("========================================");

	if (failed == 0)
		$display("ALL WRITEBACK TESTS PASSED!");
	else
		$display("WRITEBACK TESTS FAILED!");

	$display("========================================");

	$finish;
end


endmodule