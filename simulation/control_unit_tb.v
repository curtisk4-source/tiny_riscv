`timescale 1ns/1ps

module control_unit_tb;

reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;

wire RegWrite;
wire ALUSrc;
wire MemWrite;
wire MemRead;
wire MemToReg;
wire Branch;
wire Jump;

wire [3:0] ALUControl;
wire [2:0] ImmSrc;

integer passed;
integer failed;
integer i;

// Device under test
control_unit uut (
	.opcode(opcode),
	.funct3(funct3),
	.funct7(funct7),
	.RegWrite(RegWrite),
	.ALUSrc(ALUSrc),
	.MemWrite(MemWrite),
	.MemRead(MemRead),
	.MemToReg(MemToReg),
	.Branch(Branch),
	.Jump(Jump),
	.ALUControl(ALUControl),
	.ImmSrc(ImmSrc)
);

// Compare all control outputs against the expected values.
task check_outputs;
	input [8:0] expected_controls;
	input [3:0] expected_alu;
	input [2:0] expected_imm;
	input [8*48-1:0] test_name;

	reg [8:0] actual_controls;

	begin
		actual_controls = {
			RegWrite,
			ALUSrc,
			MemWrite,
			MemRead,
			MemToReg,
			Branch,
			Jump,
			1'b0,
			1'b0
		};

		if (
			actual_controls !== expected_controls ||
			ALUControl !== expected_alu ||
			ImmSrc !== expected_imm
		) begin
			$display("FAIL: %0s", test_name);
			$display("Expected controls: %b | Actual: %b",
				expected_controls, actual_controls);
			$display("Expected ALU: %b | Actual: %b",
				expected_alu, ALUControl);
			$display("Expected Imm: %b | Actual: %b",
				expected_imm, ImmSrc);

			failed = failed + 1;
		end
		else begin
			$display("PASS: %0s", test_name);
			passed = passed + 1;
		end
	end
endtask

// Apply an instruction encoding and verify its decoded controls.
task run_test;
	input [6:0] test_opcode;
	input [2:0] test_funct3;
	input [6:0] test_funct7;
	input [8:0] expected_controls;
	input [3:0] expected_alu;
	input [2:0] expected_imm;
	input [8*48-1:0] test_name;

	begin
		opcode = test_opcode;
		funct3 = test_funct3;
		funct7 = test_funct7;

		#1;

		check_outputs(
			expected_controls,
			expected_alu,
			expected_imm,
			test_name
		);
	end
endtask

initial begin

	$dumpfile("control_unit.vcd");
	$dumpvars(0, control_unit_tb);

	passed = 0;
	failed = 0;

	opcode = 0;
	funct3 = 0;
	funct7 = 0;

	// TEST GROUP 1: R-type arithmetic instructions

	run_test(7'b0110011, 3'b000, 7'b0000000,
		9'b100000000, 4'b0000, 3'b000, "R-type ADD");

	run_test(7'b0110011, 3'b000, 7'b0100000,
		9'b100000000, 4'b0001, 3'b000, "R-type SUB");

	run_test(7'b0110011, 3'b111, 7'b0000000,
		9'b100000000, 4'b0010, 3'b000, "R-type AND");

	run_test(7'b0110011, 3'b110, 7'b0000000,
		9'b100000000, 4'b0011, 3'b000, "R-type OR");

	run_test(7'b0110011, 3'b100, 7'b0000000,
		9'b100000000, 4'b0100, 3'b000, "R-type XOR");

	run_test(7'b0110011, 3'b001, 7'b0000000,
		9'b100000000, 4'b0101, 3'b000, "R-type SLL");

	run_test(7'b0110011, 3'b101, 7'b0000000,
		9'b100000000, 4'b0110, 3'b000, "R-type SRL");

	run_test(7'b0110011, 3'b101, 7'b0100000,
		9'b100000000, 4'b0111, 3'b000, "R-type SRA");

	run_test(7'b0110011, 3'b010, 7'b0000000,
		9'b100000000, 4'b1000, 3'b000, "R-type SLT");

	run_test(7'b0110011, 3'b011, 7'b0000000,
		9'b100000000, 4'b1001, 3'b000, "R-type SLTU");

	// TEST GROUP 2: I-type arithmetic instructions

	run_test(7'b0010011, 3'b000, 7'b0000000,
		9'b110000000, 4'b0000, 3'b000, "I-type ADDI");

	run_test(7'b0010011, 3'b111, 7'b0000000,
		9'b110000000, 4'b0010, 3'b000, "I-type ANDI");

	run_test(7'b0010011, 3'b110, 7'b0000000,
		9'b110000000, 4'b0011, 3'b000, "I-type ORI");

	run_test(7'b0010011, 3'b100, 7'b0000000,
		9'b110000000, 4'b0100, 3'b000, "I-type XORI");

	run_test(7'b0010011, 3'b010, 7'b0000000,
		9'b110000000, 4'b1000, 3'b000, "I-type SLTI");

	run_test(7'b0010011, 3'b011, 7'b0000000,
		9'b110000000, 4'b1001, 3'b000, "I-type SLTIU");

	run_test(7'b0010011, 3'b001, 7'b0000000,
		9'b110000000, 4'b0101, 3'b000, "I-type SLLI");

	run_test(7'b0010011, 3'b101, 7'b0000000,
		9'b110000000, 4'b0110, 3'b000, "I-type SRLI");

	run_test(7'b0010011, 3'b101, 7'b0100000,
		9'b110000000, 4'b0111, 3'b000, "I-type SRAI");

	// TEST GROUP 3: I-type immediate fields

	// Non-shift I-type instructions use funct7 bits as
	// immediate data and must not reject arbitrary values.

	run_test(7'b0010011, 3'b000, 7'b1111111,
		9'b110000000, 4'b0000, 3'b000, "ADDI arbitrary immediate");

	run_test(7'b0010011, 3'b010, 7'b1010101,
		9'b110000000, 4'b1000, 3'b000, "SLTI arbitrary immediate");

	run_test(7'b0010011, 3'b011, 7'b1111111,
		9'b110000000, 4'b1001, 3'b000, "SLTIU arbitrary immediate");

	run_test(7'b0010011, 3'b100, 7'b0101010,
		9'b110000000, 4'b0100, 3'b000, "XORI arbitrary immediate");

	// TEST GROUP 4: Load, store, branch and jump instructions

	run_test(7'b0000011, 3'b010, 7'b0000000,
		9'b110110000, 4'b0000, 3'b000, "LW instruction");

	run_test(7'b0100011, 3'b010, 7'b0000000,
		9'b011000000, 4'b0000, 3'b001, "SW instruction");

	run_test(7'b1100011, 3'b000, 7'b0000000,
		9'b000001000, 4'b0001, 3'b010, "BEQ instruction");

	run_test(7'b1101111, 3'b000, 7'b0000000,
		9'b100000100, 4'b0000, 3'b100, "JAL instruction");

	// TEST GROUP 5: Upper immediate instructions

	run_test(7'b0110111, 3'b000, 7'b0000000,
		9'b110000000, 4'b0000, 3'b011, "LUI instruction");

	run_test(7'b0010111, 3'b000, 7'b0000000,
		9'b110000000, 4'b0000, 3'b011, "AUIPC instruction");

	// TEST GROUP 6: Invalid R-type funct7 encodings

	run_test(7'b0110011, 3'b000, 7'b0000001,
		9'b000000000, 4'b0000, 3'b000, "Invalid ADD funct7");

	run_test(7'b0110011, 3'b000, 7'b1111111,
		9'b000000000, 4'b0000, 3'b000, "Invalid SUB funct7");

	run_test(7'b0110011, 3'b001, 7'b0100000,
		9'b000000000, 4'b0000, 3'b000, "Invalid SLL funct7");

	run_test(7'b0110011, 3'b010, 7'b0100000,
		9'b000000000, 4'b0000, 3'b000, "Invalid SLT funct7");

	run_test(7'b0110011, 3'b011, 7'b0100000,
		9'b000000000, 4'b0000, 3'b000, "Invalid SLTU funct7");

	run_test(7'b0110011, 3'b100, 7'b0100000,
		9'b000000000, 4'b0000, 3'b000, "Invalid XOR funct7");

	run_test(7'b0110011, 3'b101, 7'b0000001,
		9'b000000000, 4'b0000, 3'b000, "Invalid SRL funct7");

	run_test(7'b0110011, 3'b101, 7'b0000001,
		9'b000000000, 4'b0000, 3'b000, "Invalid SRA funct7");

	run_test(7'b0110011, 3'b110, 7'b0100000,
		9'b000000000, 4'b0000, 3'b000, "Invalid OR funct7");

	run_test(7'b0110011, 3'b111, 7'b0100000,
		9'b000000000, 4'b0000, 3'b000, "Invalid AND funct7");

	// TEST GROUP 7: Invalid I-type shift encodings

	run_test(7'b0010011, 3'b001, 7'b0000001,
		9'b000000000, 4'b0000, 3'b000, "Invalid SLLI funct7");

	run_test(7'b0010011, 3'b001, 7'b0100000,
		9'b000000000, 4'b0000, 3'b000, "Invalid SLLI alternate funct7");

	run_test(7'b0010011, 3'b101, 7'b0000001,
		9'b000000000, 4'b0000, 3'b000, "Invalid SRLI funct7");

	run_test(7'b0010011, 3'b101, 7'b0000010,
		9'b000000000, 4'b0000, 3'b000, "Invalid SRAI funct7");

	// TEST GROUP 8: Invalid memory and branch encodings

	run_test(7'b0000011, 3'b000, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid load byte");

	run_test(7'b0000011, 3'b001, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid load halfword");

	run_test(7'b0000011, 3'b011, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid load funct3");

	run_test(7'b0100011, 3'b000, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid store byte");

	run_test(7'b0100011, 3'b001, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid store halfword");

	run_test(7'b0100011, 3'b011, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid store funct3");

	run_test(7'b1100011, 3'b001, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid branch funct3");

	run_test(7'b1100011, 3'b111, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Unsupported branch funct3");

	// TEST GROUP 9: Invalid opcodes

	run_test(7'b1111111, 3'b000, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid opcode all ones");

	run_test(7'b0000000, 3'b000, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid opcode all zeros");

	run_test(7'b1111110, 3'b111, 7'b1111111,
		9'b000000000, 4'b0000, 3'b000, "Invalid opcode arbitrary fields");

	run_test(7'b0000010, 3'b010, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Unsupported opcode");

	// TEST GROUP 10: Decoder output recovery

	// A valid instruction must decode correctly after an
	// invalid instruction without retaining stale controls.

	run_test(7'b1111111, 3'b000, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid before ADD");

	run_test(7'b0110011, 3'b000, 7'b0000000,
		9'b100000000, 4'b0000, 3'b000, "Valid ADD after invalid");

	run_test(7'b1111111, 3'b000, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid before LW");

	run_test(7'b0000011, 3'b010, 7'b0000000,
		9'b110110000, 4'b0000, 3'b000, "Valid LW after invalid");

	run_test(7'b1111111, 3'b000, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Invalid before JAL");

	run_test(7'b1101111, 3'b000, 7'b0000000,
		9'b100000100, 4'b0000, 3'b100, "Valid JAL after invalid");

	// TEST GROUP 11: Exhaustive R-type funct3 coverage

	// Every possible three-bit funct3 encoding is checked.
	// All eight encodings are defined by the R-type decoder.

	for (i = 0; i < 8; i = i + 1) begin
		case (i)
			0: run_test(7'b0110011, 3'b000, 7'b0000000,
				9'b100000000, 4'b0000, 3'b000, "R funct3 exhaustive 000");
			1: run_test(7'b0110011, 3'b001, 7'b0000000,
				9'b100000000, 4'b0101, 3'b000, "R funct3 exhaustive 001");
			2: run_test(7'b0110011, 3'b010, 7'b0000000,
				9'b100000000, 4'b1000, 3'b000, "R funct3 exhaustive 010");
			3: run_test(7'b0110011, 3'b011, 7'b0000000,
				9'b100000000, 4'b1001, 3'b000, "R funct3 exhaustive 011");
			4: run_test(7'b0110011, 3'b100, 7'b0000000,
				9'b100000000, 4'b0100, 3'b000, "R funct3 exhaustive 100");
			5: run_test(7'b0110011, 3'b101, 7'b0000000,
				9'b100000000, 4'b0110, 3'b000, "R funct3 exhaustive 101");
			6: run_test(7'b0110011, 3'b110, 7'b0000000,
				9'b100000000, 4'b0011, 3'b000, "R funct3 exhaustive 110");
			7: run_test(7'b0110011, 3'b111, 7'b0000000,
				9'b100000000, 4'b0010, 3'b000, "R funct3 exhaustive 111");
		endcase
	end

	// TEST GROUP 12: Exhaustive I-type funct3 coverage

	// All eight I-type funct3 encodings are supported.
	// Shift instructions require valid funct7 encodings.

	for (i = 0; i < 8; i = i + 1) begin
		case (i)
			0: run_test(7'b0010011, 3'b000, 7'b0000000,
				9'b110000000, 4'b0000, 3'b000, "I funct3 exhaustive 000");
			1: run_test(7'b0010011, 3'b001, 7'b0000000,
				9'b110000000, 4'b0101, 3'b000, "I funct3 exhaustive 001");
			2: run_test(7'b0010011, 3'b010, 7'b0000000,
				9'b110000000, 4'b1000, 3'b000, "I funct3 exhaustive 010");
			3: run_test(7'b0010011, 3'b011, 7'b0000000,
				9'b110000000, 4'b1001, 3'b000, "I funct3 exhaustive 011");
			4: run_test(7'b0010011, 3'b100, 7'b0000000,
				9'b110000000, 4'b0100, 3'b000, "I funct3 exhaustive 100");
			5: run_test(7'b0010011, 3'b101, 7'b0000000,
				9'b110000000, 4'b0110, 3'b000, "I funct3 exhaustive 101");
			6: run_test(7'b0010011, 3'b110, 7'b0000000,
				9'b110000000, 4'b0011, 3'b000, "I funct3 exhaustive 110");
			7: run_test(7'b0010011, 3'b111, 7'b0000000,
				9'b110000000, 4'b0010, 3'b000, "I funct3 exhaustive 111");
		endcase
	end

	// TEST GROUP 13: Unknown input handling

	// Unknown opcodes must fall through to safe defaults.

	run_test(7'bxxxxxxx, 3'b000, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Unknown opcode");

	run_test(7'b0110011, 3'bxxx, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Unknown R-type funct3");

	run_test(7'b0010011, 3'bxxx, 7'b0000000,
		9'b000000000, 4'b0000, 3'b000, "Unknown I-type funct3");

	run_test(7'b0110011, 3'b000, 7'bxxxxxxx,
		9'b000000000, 4'b0000, 3'b000, "Unknown R-type funct7");

	run_test(7'b0010011, 3'b001, 7'bxxxxxxx,
		9'b000000000, 4'b0000, 3'b000, "Unknown SLLI funct7");

	run_test(7'b0010011, 3'b101, 7'bxxxxxxx,
		9'b000000000, 4'b0000, 3'b000, "Unknown SRLI funct7");

	// TEST GROUP 14: Final decoder recovery

	run_test(7'b0110011, 3'b000, 7'b0000000,
		9'b100000000, 4'b0000, 3'b000, "Final valid ADD");

	// FINAL RESULTS

	$display("");
	$display("========================================");
	$display("          CONTROL UNIT TEST RESULTS");
	$display("========================================");

	$display("Total tests : %0d", passed + failed);
	$display("Passed      : %0d", passed);
	$display("Failed      : %0d", failed);

	$display("========================================");

	if (failed == 0)
		$display("ALL CONTROL UNIT TESTS PASSED!");
	else
		$display("CONTROL UNIT TESTS FAILED!");

	$display("========================================");

	$finish;

end


endmodule