//ID_EX buffer
import rv32i_types::*;

module ID_EX_buffer(
	// Inputs
	input clk, 
	input rst, 
	input logic flush,
	input load,
	// Input(s) from Decode Stage 
	input logic [31:0] pc_i, 
	input logic [31:0] old_pc_plus4_i,
	input logic [31:0] rs1_out_i, 
	input logic [31:0] rs2_out_i, 
	input logic [31:0] i_imm_i, 
	input logic [31:0] u_imm_i, 
	input logic [31:0] b_imm_i, 
	input logic [31:0] s_imm_i,
	input logic [31:0] j_imm_i,
	input logic [4:0] rd_i,
	input logic [4:0] rs1_i,
	input logic [4:0] rs2_i,

	//Outputs
	output logic [31:0] pc_o, 
	output logic [31:0] old_pc_plus4_o,
	output logic [31:0] rs1_out_o, 
	output logic [31:0] rs2_out_o, 
	output logic [31:0] i_imm_o, 
	output logic [31:0] u_imm_o, 
	output logic [31:0] b_imm_o, 
	output logic [31:0] s_imm_o,
	output logic [31:0] j_imm_o,
	output rv32i_reg rd_o,
	output logic [4:0] rs1_o,
	output logic [4:0] rs2_o
);

logic [31:0] pc;
logic [31:0] rs1_out; 
logic [31:0] rs2_out; 
logic [31:0] i_imm; 
logic [31:0] u_imm; 
logic [31:0] b_imm;
logic [31:0] s_imm;
logic [31:0] j_imm;
logic [4:0] rd;
logic [4:0] rs1;
logic [4:0] rs2;
logic [31:0] old_pc_plus4; 

always_ff @(posedge clk) begin 
	if(rst) begin
		pc_o <= 32'h00000000; 
		rs1_out_o <= 0;  
		rs2_out_o <= 0;  
		i_imm_o <= 0; 
		u_imm_o <= 0;  
		b_imm_o <= 0;  
		s_imm_o <= 0; 
		j_imm_o <= 0; 
		rd_o <= 0; 
		rs1_o <= 0;
		rs2_o <= 0;
		old_pc_plus4_o <= 0; 
	end else if(load) begin
		pc_o <= pc; 
		rs1_out_o <= rs1_out;  
		rs2_out_o <= rs2_out;  
		i_imm_o <= i_imm; 
		u_imm_o <= u_imm;  
		b_imm_o <= b_imm;  
		s_imm_o <= s_imm; 
		j_imm_o <= j_imm; 
		rd_o <= rd; 
		rs1_o <= rs1;
		rs2_o <= rs2;
		old_pc_plus4_o <= old_pc_plus4;
	end 
end

always_comb begin 
	pc = pc_i; 
	rs1_out = rs1_out_i;  
	rs2_out = rs2_out_i;  
	i_imm = i_imm_i; 
	u_imm = u_imm_i;  
	b_imm = b_imm_i;  
	s_imm = s_imm_i; 
	j_imm = j_imm_i; 
	rd = rd_i;
	rs1 = rs1_i;
	rs2 = rs2_i;
	old_pc_plus4 = old_pc_plus4_i;
	if(flush) begin
		pc = 32'h00000000; 
		rs1_out = 0;  
		rs2_out = 0;  
		i_imm = 0; 
		u_imm = 0;  
		b_imm = 0;  
		s_imm = 0; 
		j_imm = 0; 
		rd = 0; 
		rs1 = 0;
		rs2 = 0;
		old_pc_plus4 = 0;
	end
end
endmodule : ID_EX_buffer