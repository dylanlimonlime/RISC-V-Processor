// Forwarding Logic 

// Imports Here
import rv32i_types::*;

module forwarding(
	input clk,
	input rst,
	input rv32i_reg ex_mem_rd, 
	input rv32i_reg id_ex_rs1,
	input rv32i_reg id_ex_rs2,
	input rv32i_reg mem_wb_rd,
	input rv32i_reg id_ex_rd,
	input rv32i_opcode ex_ctrl_opcode,
	input logic ex_mem_write,
	input logic mem_wb_write,
	output logic [1:0] forwardA, 
	output logic [1:0] forwardB
); 

// Local Variables
logic uses_rs1;
logic uses_rs2;
logic ex_hazard_A;
logic ex_hazard_B;
logic mem_hazard_A;
logic mem_hazard_B;

// forwardA Logic
always_comb begin
	
	uses_rs1 = (ex_ctrl_opcode != op_lui)&(ex_ctrl_opcode != op_auipc)&(ex_ctrl_opcode != op_jal);
	uses_rs2 = (ex_ctrl_opcode == op_reg)|(ex_ctrl_opcode == op_br)|(ex_ctrl_opcode == op_store);
	ex_hazard_A = ex_mem_write & (ex_mem_rd != 0) & (ex_mem_rd == id_ex_rs1) & uses_rs1;
	mem_hazard_A = mem_wb_write & (mem_wb_rd != 0) & (mem_wb_rd == id_ex_rs1) & uses_rs1;
	ex_hazard_B = ex_mem_write & (ex_mem_rd != 0) & (ex_mem_rd == id_ex_rs2) & uses_rs2;
	mem_hazard_B = mem_wb_write & (mem_wb_rd != 0) & (mem_wb_rd == id_ex_rs2) & uses_rs2;
	
	if(ex_hazard_A)
		forwardA = 2'b10;
	else if(mem_hazard_A)
		forwardA = 2'b01; 
	else
		forwardA = 2'b00; 

	// forwardB Logic
	if(ex_hazard_B)
		forwardB = 2'b10; 
	else if(mem_hazard_B)
		forwardB = 2'b01; 
	else
		forwardB = 2'b00;
end

endmodule : forwarding
