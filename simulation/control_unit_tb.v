
`timescale 1ns/1ps

module control_unit_tb;

	// Inputs
	reg [6:0] opcode;
	reg [2:0] funct3;
	reg [6:0] funct7;

	// Outputs
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

	// Instantiate Control Unit
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

	// Task for checking outputs
	task check_outputs;
		input [8:0] expected_controls;
		input [3:0] expected_alu;
		input [2:0] expected_imm;
		input [8*20-1:0] test_name;

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

				$display("Expected controls: %b", expected_controls);
				$display("Actual controls:   %b", actual_controls);

				$display("Expected ALU: %b", expected_alu);
				$display("Actual ALU:   %b", ALUControl);

				$display("Expected Imm: %b", expected_imm);
				$display("Actual Imm:   %b", ImmSrc);

				failed = failed + 1;
			end
			else begin
				$display("PASS: %0s", test_name);
				passed = passed + 1;
			end
		end
	endtask

	initial begin

		passed = 0;
		failed = 0;

		opcode = 0;
		funct3 = 0;
		funct7 = 0;

		// TEST 1: ADD
		opcode = 7'b0110011;
		funct3 = 3'b000;
		funct7 = 7'b0000000;

		#10;
		check_outputs(9'b100000000, 4'b0000, 3'b000, "ADD");

		// TEST 2: SUB
		funct7 = 7'b0100000;

		#10;
		check_outputs(9'b100000000, 4'b0001, 3'b000, "SUB");

		// TEST 3: ADDI
		opcode = 7'b0010011;
		funct3 = 3'b000;
		funct7 = 7'b0000000;

		#10;
		check_outputs(9'b110000000, 4'b0000, 3'b000, "ADDI");

		// TEST 4: LW
		opcode = 7'b0000011;
		funct3 = 3'b010;

		#10;
		check_outputs(9'b110110000, 4'b0000, 3'b000, "LW");

		// TEST 5: SW
		opcode = 7'b0100011;

		#10;
		check_outputs(9'b011000000, 4'b0000, 3'b001, "SW");

		// TEST 6: BEQ
		opcode = 7'b1100011;
		funct3 = 3'b000;

		#10;
		check_outputs(9'b000001000, 4'b0001, 3'b010, "BEQ");

		// TEST 7: JAL
		opcode = 7'b1101111;

		#10;
		check_outputs(9'b100000100, 4'b0000, 3'b100, "JAL");

		// TEST 8: LUI
		opcode = 7'b0110111;

		#10;
		check_outputs(9'b110000000, 4'b0000, 3'b011, "LUI");

		// TEST 9: AUIPC
		opcode = 7'b0010111;

		#10;
		check_outputs(9'b110000000, 4'b0000, 3'b011, "AUIPC");

		// TEST 10: AND
		opcode = 7'b0110011;
		funct3 = 3'b111;
		funct7 = 7'b0000000;

		#10;
		check_outputs(9'b100000000, 4'b0010, 3'b000, "AND");

		// TEST 11: OR
		funct3 = 3'b110;

		#10;
		check_outputs(9'b100000000, 4'b0011, 3'b000, "OR");

		// TEST 12: XOR
		funct3 = 3'b100;

		#10;
		check_outputs(9'b100000000, 4'b0100, 3'b000, "XOR");

		// TEST 13: SLT
		funct3 = 3'b010;

		#10;
		check_outputs(9'b100000000, 4'b1000, 3'b000, "SLT");

		// TEST 14: SLTU
		funct3 = 3'b011;

		#10;
		check_outputs(9'b100000000, 4'b1001, 3'b000, "SLTU");


		// INVALID INSTRUCTION TESTS

		// TEST 15: Invalid R-type funct3
		opcode = 7'b0110011;
		funct3 = 3'b101;
		funct7 = 7'b0000001;

		#10;
		check_outputs(9'b000000000, 4'b0000, 3'b000, "Invalid R funct3");

		// TEST 16: Invalid I-type funct3
		opcode = 7'b0010011;
		funct3 = 3'b111;
		funct7 = 7'b0000001;


		funct3 = 3'b001;
		funct7 = 7'b0000001;

		#10;
		check_outputs(9'b000000000, 4'b0000, 3'b000, "Invalid I shift");

		// TEST 17: Invalid opcode
		opcode = 7'b1111111;
		funct3 = 3'b000;
		funct7 = 7'b0000000;

		#10;
		check_outputs(9'b000000000, 4'b0000, 3'b000, "Invalid opcode");

		// TEST 18: Invalid R-type ADD funct7
		opcode = 7'b0110011;
		funct3 = 3'b000;
		funct7 = 7'b0000001;

		#10;
		check_outputs(9'b000000000, 4'b0000, 3'b000, "Invalid ADD funct7");

		// TEST 19: Invalid R-type SRL funct7
		funct3 = 3'b101;
		funct7 = 7'b0000001;

		#10;
		check_outputs(9'b000000000, 4'b0000, 3'b000, "Invalid SRL funct7");


		// FINAL RESULTS
		$display("");
		$display("==============================");
		$display("CONTROL UNIT TEST RESULTS");
		$display("==============================");

		$display("Tests Passed: %0d", passed);
		$display("Tests Failed: %0d", failed);

		if (failed == 0)
			$display("ALL TESTS PASSED!");
		else
			$display("SOME TESTS FAILED!");

		$display("==============================");

		$finish;

	end

endmodule
