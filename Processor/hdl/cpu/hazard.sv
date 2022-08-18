/*** Imports ***/
import rv32i_types::*;

module hazard(
	input clk,
	input rst,
	input br_en,
	input rv32i_opcode decode_opcode,
	input rv32i_opcode ex_ctrl_opcode,
	input [2:0] ex_ctrl_funct3,
	input logic mem_ctrl_dwrite,
	input logic mem_ctrl_dread,
	input logic data_mem_resp, 
	input logic inst_mem_resp,
	input logic load_pc_i,
	input [4:0] if_id_rs1,
   input [4:0] if_id_rs2,
   input [4:0] id_ex_rd,
	input br_out,
	output logic flush_IF_ID,
	output logic flush_ID_EX,
	output logic load_IF_ID,
	output logic load_ID_EX,
	output logic load_EX_MEM,
	output logic load_MEM_WB,
	output logic load_EX_ctrl,
	output logic load_MEM_ctrl,
	output logic load_WB_ctrl,
	output logic load_pc_o,
	output logic ex_ctrl_mux_sel,
	output logic mem_ctrl_mux_sel,
	output logic wb_ctrl_mux_sel
);

// Local Variables 
logic load_conflict;
logic rs1_conflict;
logic rs2_conflict;
logic all_conflict;

arith_funct3_t arith_funct3;
// Set Defaults

function void set_defaults ();
	flush_IF_ID = 1'b0;
	flush_ID_EX = 1'b0;
	load_IF_ID = 1'b1;
	load_ID_EX = 1'b1;
	load_EX_MEM = 1'b1;
	load_MEM_WB = 1'b1;
	load_EX_ctrl = 1'b1;
	load_MEM_ctrl = 1'b1;
	load_WB_ctrl = 1'b1;
	load_pc_o = load_pc_i;
	ex_ctrl_mux_sel = 1'b0;
	mem_ctrl_mux_sel = 1'b0;
	wb_ctrl_mux_sel = 1'b0;
endfunction : set_defaults


always_comb begin
// Handle Untaken Branches Here
	set_defaults();
	arith_funct3 = arith_funct3_t'(ex_ctrl_funct3);
	
	rs1_conflict = ((if_id_rs1 == id_ex_rd)&(if_id_rs1 != 0)&(decode_opcode != op_lui)&(decode_opcode != op_auipc)&(decode_opcode != op_jal));
	rs2_conflict = ((if_id_rs2 == id_ex_rd)&((decode_opcode == op_reg)|(decode_opcode == op_br)|(decode_opcode == op_store))&(if_id_rs2 != 0));
	load_conflict = ((ex_ctrl_opcode == op_load)|(ex_ctrl_opcode == op_lui)|(arith_funct3 == slt)|(arith_funct3 == sltu))&(rs1_conflict|rs2_conflict);
	//if((br_en != br_out) & (ex_ctrl_opcode == op_br)) 
	if(br_en & (ex_ctrl_opcode == op_br))
	begin 
		// flush two instructions on branch mispredict
		flush_IF_ID = 1'b1;
		flush_ID_EX = 1'b1;
		ex_ctrl_mux_sel = 1'b1;
	end
	
	if((ex_ctrl_opcode == op_jal) | (ex_ctrl_opcode == op_jalr))
	begin
		flush_IF_ID = 1'b1;
		flush_ID_EX = 1'b1;
		ex_ctrl_mux_sel = 1'b1;
	end
	
// Handle Loads
	if(load_conflict)
	begin
		if(!flush_IF_ID) begin
			load_IF_ID = 1'b0; 
			load_pc_o = 1'b0; 
		end
		ex_ctrl_mux_sel = 1'b1;
	end
	
// Handle mem read/writes
	if((mem_ctrl_dwrite | mem_ctrl_dread) & !data_mem_resp)
	begin
		if(!flush_IF_ID) begin
			load_IF_ID = 1'b0;
			load_pc_o = 1'b0;
		end	
		load_ID_EX = 1'b0;
		load_EX_MEM = 1'b0;
		load_MEM_WB = 1'b0;
		load_EX_ctrl = 1'b0;
		load_MEM_ctrl = 1'b0;
		load_WB_ctrl = 1'b0;
	end
	
	if(!inst_mem_resp) begin
		if(!flush_IF_ID) begin
			load_IF_ID = 1'b0; 
			load_pc_o = 1'b0; 
		end
		ex_ctrl_mux_sel = 1'b1; 
	end
	
	all_conflict = (mem_ctrl_dwrite | mem_ctrl_dread) & !data_mem_resp & !inst_mem_resp & flush_IF_ID;
end

endmodule : hazard