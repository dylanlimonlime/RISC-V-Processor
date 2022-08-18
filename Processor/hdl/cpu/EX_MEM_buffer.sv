//EX_MEM buffer
import rv32i_types::*;

module EX_MEM_buffer(
	// Inputs
	input clk, 
	input rst, 
	input load,
	
	// Input(s) from Execute Stage 
	input logic [31:0] pc_i, 
	input rv32i_word alu_out_i,
	input logic br_en_i, 
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
	input logic [31:0] cmpmux_out_i,

	// Inputs from read_data (data cache interface signals)
	/*
	input logic [2:0] lw_i, 
	input logic [2:0] lb_i, 
	input logic [2:0] lbu_i,
	input logic [2:0] lh_i,
	input logic [2:0] lhu_i,
	*/


	//Outputs
	output logic [31:0] pc_o, 
	output rv32i_word alu_out_o,
	output logic br_en_o,
	output logic [31:0] rs1_out_o, 
	output logic [31:0] rs2_out_o, 
	output logic [31:0] i_imm_o, 
	output logic [31:0] u_imm_o, 
	output logic [31:0] b_imm_o, 
	output logic [31:0] s_imm_o,
	output logic [31:0] j_imm_o,
	output rv32i_reg rd_o,
	output logic [4:0] rs1_o,
	output logic [4:0] rs2_o,
	output logic [31:0] cmpmux_out_o

	/*
	output logic [2:0] lw_i, 
	output logic [2:0] lb_i, 
	output logic [2:0] lbu_i,
	output logic [2:0] lh_i,
	output logic [2:0] lhu_i
	*/
);

logic [31:0] pc; 
rv32i_word alu_out;
logic br_en;
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
logic [31:0] cmpmux_out;
/*
logic [2:0] lw;
logic [2:0] lb; 
logic [2:0] lbu;
logic [2:0] lh;
logic [2:0] lhu;
*/


always_ff @(posedge clk) begin 
	if(rst) begin
		pc <= 0; 
		alu_out <= 0; 
		br_en <= 0; 
		rs1_out <= 0;  
		rs2_out <= 0;  
		i_imm <= 0; 
		u_imm <= 0;  
		b_imm <= 0;  
		s_imm <= 0; 
		j_imm <= 0; 
		rd <= 0; 
		rs1 <= 0;
		rs2 <= 0;
		cmpmux_out <= 0;
	end else if(load) begin
		pc <= pc_i; 
		alu_out <= alu_out_i; 
		br_en <= br_en_i;
		rs1_out <= rs1_out_i;  
		rs2_out <= rs2_out_i;  
		i_imm <= i_imm_i; 
		u_imm <= u_imm_i;  
		b_imm <= b_imm_i;  
		s_imm <= s_imm_i; 
		j_imm <= j_imm_i; 
		rd <= rd_i; 
		rs1 <= rs1_i;
		rs2 <= rs2_i;
		cmpmux_out <= cmpmux_out_i;
	end 
end

always_comb begin 
	pc_o = pc; 
	alu_out_o = alu_out; 
	br_en_o = br_en;
	rs1_out_o = rs1_out;  
	rs2_out_o = rs2_out;  
	i_imm_o = i_imm; 
	u_imm_o = u_imm;  
	b_imm_o = b_imm;  
	s_imm_o = s_imm; 
	j_imm_o = j_imm; 
	rd_o = rd;
	rs1_o = rs1;
	rs2_o = rs2;
	cmpmux_out_o = cmpmux_out;
end
endmodule : EX_MEM_buffer