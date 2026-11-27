`timescale 1ns/1ps

module tb_instruction_memory;

reg [31:0] pc;
wire [31:0] instruction;

integer passed;
integer failed;
integer i;

// Device under test
instruction_memory uut (
	.pc(pc),
	.instruction(instruction)
);

// Verify the instruction returned for a given address.
task check_instruction;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		if (instruction === expected) begin
			$display("PASS: %0s | PC: %h | Instruction: %h",
				test_name, pc, instruction);
			passed = passed + 1;
		end
		else begin
			$display("FAIL: %0s | PC: %h", test_name, pc);

			$display("Expected: %h | Actual: %h",
				expected, instruction);

			failed = failed + 1;
		end
	end
endtask

// Apply an address and verify the resulting instruction.
task read_instruction;
	input [31:0] address;
	input [31:0] expected;
	input [255:0] test_name;

	begin
		pc = address;
		#1;
		check_instruction(expected, test_name);
	end
endtask

initial begin
	$dumpfile("instruction_memory.vcd");
	$dumpvars(0, tb_instruction_memory);

	passed = 0;
	failed = 0;

	pc = 0;

	#1;

	// --------------------------------------------------
	// TEST GROUP 1: Program initialization
	// --------------------------------------------------

	read_instruction(32'h00000000, 32'h00A00093,
		"Instruction at address zero");

	read_instruction(32'h00000004, 32'h01400113,
		"Instruction at address four");

	read_instruction(32'h00000008, 32'h002081B3,
		"Instruction at address eight");

	// --------------------------------------------------
	// TEST GROUP 2: Consecutive instruction addresses
	// --------------------------------------------------

	pc = 32'h00000000;
	#1;

	check_instruction(32'h00A00093,
		"First sequential instruction");

	pc = 32'h00000004;
	#1;

	check_instruction(32'h01400113,
		"Second sequential instruction");

	pc = 32'h00000008;
	#1;

	check_instruction(32'h002081B3,
		"Third sequential instruction");

	// --------------------------------------------------
	// TEST GROUP 3: Repeated instruction reads
	// --------------------------------------------------

	read_instruction(32'h00000000, 32'h00A00093,
		"Repeated read of instruction zero");

	read_instruction(32'h00000000, 32'h00A00093,
		"Second repeated read of instruction zero");

	read_instruction(32'h00000008, 32'h002081B3,
		"Repeated read of instruction two");

	// --------------------------------------------------
	// TEST GROUP 4: Address changes
	// --------------------------------------------------

	pc = 32'h00000000;
	#1;

	check_instruction(32'h00A00093,
		"Initial address selection");

	pc = 32'h00000004;
	#1;

	check_instruction(32'h01400113,
		"Combinational address update");

	pc = 32'h00000008;
	#1;

	check_instruction(32'h002081B3,
		"Second combinational address update");

	// --------------------------------------------------
	// TEST GROUP 5: Unaligned addresses
	// --------------------------------------------------

	// These tests document the current implementation's
	// behaviour for addresses that are not word-aligned.
	// Expected values depend on the RTL address indexing.

	pc = 32'h00000001;
	#1;

	$display("INFO: Unaligned address 0x00000001 returned %h",
		instruction);

	pc = 32'h00000002;
	#1;

	$display("INFO: Unaligned address 0x00000002 returned %h",
		instruction);

	pc = 32'h00000003;
	#1;

	$display("INFO: Unaligned address 0x00000003 returned %h",
		instruction);

	// --------------------------------------------------
	// TEST GROUP 6: Address boundary conditions
	// --------------------------------------------------

	pc = 32'hFFFFFFFC;
	#1;

	$display("INFO: Maximum aligned address returned %h",
		instruction);

	pc = 32'hFFFFFFFF;
	#1;

	$display("INFO: Maximum unsigned address returned %h",
		instruction);

	pc = 32'h0000000C;
	#1;

	$display("INFO: First address after initialized program returned %h",
		instruction);

	// --------------------------------------------------
	// TEST GROUP 7: Unknown output detection
	// --------------------------------------------------

	// Valid initialized addresses must not produce
	// unknown instruction values.
	read_instruction(32'h00000000, 32'h00A00093,
		"Unknown-value check at address zero");

	read_instruction(32'h00000004, 32'h01400113,
		"Unknown-value check at address four");

	read_instruction(32'h00000008, 32'h002081B3,
		"Unknown-value check at address eight");

	// --------------------------------------------------
	// FINAL RESULTS
	// --------------------------------------------------

	$display("");
	$display("========================================");
	$display("       INSTRUCTION MEMORY TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	$display("========================================");

	if (failed == 0)
		$display("ALL INSTRUCTION MEMORY TESTS PASSED!");
	else
		$display("INSTRUCTION MEMORY TESTS FAILED!");

	$display("========================================");

	$finish;
end


endmodule