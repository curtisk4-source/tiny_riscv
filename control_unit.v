module control_unit (
	input wire [6:0] opcode,
	input wire [2:0] funct3,
	input wire [6:0] funct7,
	
	output reg RegWrite,
	output reg ALUSrc,
	output reg MemWrite,
	output reg MemRead,
	output reg MemToReg,
	output reg Branch,
	output reg Jump,
	
	output reg [3:0] ALUControl,
	output reg [2:0] ImmSrc
);

	localparam ALU_ADD	= 4'b0000;
	localparam ALU_SUB	= 4'b0001;
	localparam ALU_AND	= 4'b0010;
	localparam ALU_OR		= 4'b0011;
	localparam ALU_XOR	= 4'b0100;
	localparam ALU_SLL	= 4'b0101;
	localparam ALU_SRL	= 4'b0110;
	localparam ALU_SRA	= 4'b0111;
	localparam ALU_SLT	= 4'b1000;
	localparam ALU_SLTU	= 4'b1001;
	
	localparam IMM_I	= 3'b000;
	localparam IMM_S	= 3'b001;
	localparam IMM_B	= 3'b010;
	localparam IMM_U	= 3'b011;
	localparam IMM_J	= 3'b100;
	
	always @(*) begin
	
		// Default values
		RegWrite	= 0;
		ALUSrc		= 0;
		MemWrite	= 0;
		MemRead		= 0;
		MemToReg	= 0;
		Branch		= 0;
		Jump		= 0;
		ALUControl	= ALU_ADD;
		ImmSrc		= IMM_I;
		
		case (opcode)
			
			// R-Type
			7'b0110011: begin
				RegWrite = 1;
				
				case (funct3)
					
					// ADD / SUB
					3'b000: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_ADD;
						else if (funct7 == 7'b0100000)
							ALUControl = ALU_SUB;
						else begin
							RegWrite = 0;
							ALUControl = ALU_ADD;
						end
					end
					
					// AND
					3'b111: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_AND;
						else
							RegWrite = 0;
					end
					
					// OR
					3'b110: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_OR;
						else
							RegWrite = 0;
					end
					
					// XOR
					3'b100: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_XOR;
						else
							RegWrite = 0;
					end
					
					// SLL
					3'b001: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_SLL;
						else
							RegWrite = 0;
					end
					
					// SRL / SRA
					3'b101: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_SRL;
						else if (funct7 == 7'b0100000)
							ALUControl = ALU_SRA;
						else begin
							RegWrite = 0;
							ALUControl = ALU_ADD;
						end
					end
					
					// SLT
					3'b010: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_SLT;
						else
							RegWrite = 0;
					end
					
					// SLTU
					3'b011: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_SLTU;
						else
							RegWrite = 0;
					end
					
					default: begin
						RegWrite = 0;
						ALUControl = ALU_ADD;
					end
				endcase
			end
			
			// I-Type Arithmetic
			7'b0010011: begin
				RegWrite = 1;
				ALUSrc = 1;
				ImmSrc = IMM_I;
				
				case (funct3)
				
					// ADDI
					3'b000: ALUControl = ALU_ADD;
					
					// ANDI
					3'b111: ALUControl = ALU_AND;
					
					// ORI
					3'b110: ALUControl = ALU_OR;
					
					// XORI
					3'b100: ALUControl = ALU_XOR;
					
					// SLTI
					3'b010: ALUControl = ALU_SLT;
					
					// SLTIU
					3'b011: ALUControl = ALU_SLTU;
					
					// SLLI
					3'b001: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_SLL;
						else begin
							RegWrite = 0;
							ALUSrc = 0;
						end
					end
					
					// SRLI / SRAI
					3'b101: begin
						if (funct7 == 7'b0000000)
							ALUControl = ALU_SRL;
						else if (funct7 == 7'b0100000)
							ALUControl = ALU_SRA;
						else begin
							RegWrite = 0;
							ALUSrc = 0;
						end
					end
					
					default: begin
						RegWrite = 0;
						ALUSrc = 0;
						ALUControl = ALU_ADD;
					end
				
				endcase
			end
			
			// Load (LW)
			7'b0000011: begin
				if (funct3 == 3'b010) begin
					RegWrite = 1;
					ALUSrc = 1;
					MemRead = 1;
					MemToReg = 1;
					ALUControl = ALU_ADD;
					ImmSrc = IMM_I;
				end
			end
			
			// Store (SW)
			7'b0100011: begin
				if (funct3 == 3'b010) begin
					ALUSrc = 1;
					MemWrite = 1;
					ALUControl = ALU_ADD;
					ImmSrc = IMM_S;
				end
			end
			
			// Branch (BEQ)
			7'b1100011: begin
				if (funct3 == 3'b000) begin
					Branch = 1;
					ALUControl = ALU_SUB;
					ImmSrc = IMM_B;
				end
			end
			
			// Jump (JAL)
			7'b1101111: begin
				RegWrite = 1;
				Jump = 1;
				ImmSrc = IMM_J;
			end
			
			// LUI
			7'b0110111: begin
				RegWrite = 1;
				ALUSrc = 1;
				ALUControl = ALU_ADD;
				ImmSrc = IMM_U;
			end
			
			// AUIPC
			7'b0010111: begin
				RegWrite = 1;
				ALUSrc = 1;
				ALUControl = ALU_ADD;
				ImmSrc = IMM_U;
			end
			
			default: begin
				// Unsupported instruction
			end
		
		endcase
	end

endmodule
