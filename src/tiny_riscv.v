
module tiny_riscv (
	input wire clk,
	input wire reset
);

	// ==========================================
	// PROGRAM COUNTER
	// ==========================================

	wire [31:0] pc;
	wire [31:0] next_pc;
	wire [31:0] pc_plus4;

	assign pc_plus4 = pc + 32'd4;

	// ==========================================
	// INSTRUCTION MEMORY
	// ==========================================

	wire [31:0] instruction;

	instruction_memory IMEM (
		.pc(pc),
		.instruction(instruction)
	);

	// ==========================================
	// INSTRUCTION DECODER
	// ==========================================

	wire [6:0] opcode;
	wire [4:0] rd_field;
	wire [4:0] rs1_field;
	wire [4:0] rs2_field;
	wire [2:0] funct3;
	wire [6:0] funct7;

	assign opcode = instruction[6:0];
	assign rd_field = instruction[11:7];
	assign rs1_field = instruction[19:15];
	assign rs2_field = instruction[24:20];
	assign funct3 = instruction[14:12];
	assign funct7 = instruction[31:25];

	// Register file uses 4-bit addresses.
	wire [4:0] rd;
	wire [4:0] rs1;
	wire [4:0] rs2;

	assign rd = rd_field;
	assign rs1 = rs1_field;
	assign rs2 = rs2_field;

	// ==========================================
	// CONTROL UNIT
	// ==========================================

	wire RegWrite;
	wire ALUSrc;
	wire MemWrite;
	wire MemRead;
	wire MemToReg;
	wire Branch;
	wire Jump;

	wire [3:0] ALUControl;
	wire [2:0] ImmSrc;

	control_unit CU (
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

	// ==========================================
	// REGISTER FILE
	// ==========================================

	wire [31:0] reg_data1;
	wire [31:0] reg_data2;
	wire [31:0] writeback_data;

	register_file RF (
		.clk(clk),

		.rs1(rs1),
		.rs2(rs2),

		.rd(rd),
		.write_data(writeback_data),

		.reg_write(RegWrite),

		.read_data1(reg_data1),
		.read_data2(reg_data2)
	);

	// ==========================================
	// IMMEDIATE GENERATOR
	// ==========================================

	wire [31:0] immediate;

	immediate_generator IG (
		.instruction(instruction),
		.imm_sel(ImmSrc),
		.immediate(immediate)
	);

	// ==========================================
	// ALU INPUT MULTIPLEXERS
	// ==========================================

	wire [31:0] alu_input_a;
	wire [31:0] alu_input_b;

	// AUIPC uses PC as its first ALU input.
	// LUI uses zero as its first ALU input.

	assign alu_input_a =
		(opcode == 7'b0010111) ? pc :
		(opcode == 7'b0110111) ? 32'b0 :
		reg_data1;

	// Select register data or immediate.
	assign alu_input_b =
		(ALUSrc) ? immediate : reg_data2;

	// ==========================================
	// ALU
	// ==========================================

	wire [31:0] alu_result;
	wire zero;

	alu ALU (
		.input_a(alu_input_a),
		.input_b(alu_input_b),
		.alu_control(ALUControl),

		.result(alu_result),
		.zero(zero)
	);

	// ==========================================
	// DATA MEMORY
	// ==========================================

	wire [31:0] memory_data;

	data_memory DMEM (
		.clk(clk),

		.MemRead(MemRead),
		.MemWrite(MemWrite),

		.Address(alu_result),
		.WriteData(reg_data2),

		.ReadData(memory_data)
	);

	// ==========================================
	// WRITEBACK CONTROL
	// ==========================================

	wire [1:0] WritebackSel;

	reg [1:0] writeback_select;

	always @(*) begin

		case (opcode)

			// Load instructions
			7'b0000011:
				writeback_select = 2'b01;

			// JAL
			7'b1101111:
				writeback_select = 2'b10;

			// LUI
			7'b0110111:
				writeback_select = 2'b11;

			// All other supported instructions
			default:
				writeback_select = 2'b00;

		endcase

	end

	assign WritebackSel = writeback_select;

	// ==========================================
	// WRITEBACK
	// ==========================================

	writeback WB (
		.ALUResult(alu_result),
		.ReadData(memory_data),
		.PCPlus4(pc_plus4),
		.Immediate(immediate),

		.WritebackSel(WritebackSel),

		.WriteData(writeback_data)
	);

	// ==========================================
	// PC LOGIC
	// ==========================================

	pc_logic PCL (
		.PC(pc),
		.BranchImmediate(immediate),
		.JumpImmediate(immediate),

		.Branch(Branch),
		.Jump(Jump),
		.Zero(zero),

		.NextPC(next_pc)
	);

	// ==========================================
	// PROGRAM COUNTER UPDATE
	// ==========================================

	program_counter PC (
		.clk(clk),
		.reset(reset),

		.next_pc(next_pc),
		.pc(pc)
	);

endmodule
