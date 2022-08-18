//IF_ID buffer
import rv32i_types::*;

module IF_ID_buffer(
	// Inputs
	input clk, 
	input rst, 

	input logic flush,
	input logic load,
	// Input(s) from Fetch Stage 
	input logic [31:0] pc_i, 
	input logic [31:0] old_pc_plus4_i, 

	// Inputs from IR
	input rv32i_opcode opcode_i, 
	input logic [2:0] funct3_i, 
	input logic [6:0] funct7_i,

	input rv32i_reg rs1_i, 
	input rv32i_reg rs2_i, 
	input logic [31:0] i_imm_i, 
	input logic [31:0] u_imm_i, 
	input logic [31:0] b_imm_i, 
	input logic [31:0] s_imm_i,
	input logic [31:0] j_imm_i,
	input logic [4:0] rd_i, 

	//Outputs
	output logic [31:0] pc_o, 
	output logic [31:0] old_pc_plus4_o,
	output rv32i_opcode opcode_o, 
	output logic [2:0] funct3_o, 
	output logic [6:0] funct7_o,
	output rv32i_reg rs1_o, 
	output rv32i_reg rs2_o, 
	output logic [31:0] i_imm_o, 
	output logic [31:0] u_imm_o, 
	output logic [31:0] b_imm_o, 
	output logic [31:0] s_imm_o,
	output logic [31:0] j_imm_o,
	output rv32i_reg rd_o
);

logic [31:0] pc;
rv32i_opcode opcode;
logic [2:0] funct3;
logic [6:0] funct7;
rv32i_reg rs1; 
rv32i_reg rs2;
logic [31:0] i_imm; 
logic [31:0] u_imm;
logic [31:0] b_imm;
logic [31:0] s_imm;
logic [31:0] j_imm;
logic [4:0] rd;
logic [31:0] old_pc_plus4;

always_ff @(posedge clk) begin 
	if(rst) begin
		pc_o <= 32'h00000000;
		opcode_o <= rv32i_opcode'(0);
		funct3_o <= 0;
		funct7_o <= 0;
		rs1_o <= 0;  
		rs2_o <= 0;  
		i_imm_o <= 0; 
		u_imm_o <= 0;  
		b_imm_o <= 0;  
		s_imm_o <= 0; 
		j_imm_o <= 0; 
		rd_o <= 0; 
		old_pc_plus4_o <= 0; 
	end else if(load) begin
		pc_o <= pc; 
		opcode_o <= opcode;
		funct3_o <= funct3;
		funct7_o <= funct7;
		rs1_o <= rs1;  
		rs2_o <= rs2;  
		old_pc_plus4_o <= old_pc_plus4; 
		i_imm_o <= i_imm; 
		u_imm_o <= u_imm;  
		b_imm_o <= b_imm;  
		s_imm_o <= s_imm; 
		j_imm_o <= j_imm; 
		rd_o <= rd; 
	end 
end

always_comb begin 
	pc = pc_i; 
	old_pc_plus4 = old_pc_plus4_i;
	opcode = opcode_i;
	funct3 = funct3_i;
	funct7 = funct7_i;
	rs1 = rs1_i;  
	rs2 = rs2_i;  
	i_imm = i_imm_i; 
	u_imm = u_imm_i;  
	b_imm = b_imm_i;  
	s_imm = s_imm_i; 
	j_imm = j_imm_i; 
	rd = rd_i;
	if(flush) begin
		pc = 32'h00000000;
		opcode = rv32i_opcode'(0);
		funct3 = 0;
		funct7 = 0;
		rs1 = 0;  
		rs2 = 0;  
		i_imm = 0; 
		u_imm = 0;  
		b_imm = 0;  
		s_imm = 0; 
		j_imm = 0; 
		rd = 0;
		old_pc_plus4 = 0;
	end
end
endmodule : IF_ID_buffer