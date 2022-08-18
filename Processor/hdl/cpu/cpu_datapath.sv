import rv32i_types::*;

module cpu_datapath(
    input clk,
    input rst,
    
    input [31:0] instruction,
	input i_mem_resp,

	input d_mem_resp,
	input [31:0] d_rdata,
	output rv32i_word pc,
	output logic i_read,
	output logic d_mem_read,
	output logic d_mem_write,
	output rv32i_word d_mem_address,
	output rv32i_word d_wdata,
	output rv32i_mem_wmask d_wmask
	

);

/************* WIRES *************/

//Fetch
logic load_IF_ID;
logic flush_IF_ID;
logic [31:0] if_pc;
logic [31:0] if_old_pc_plus4;
logic [2:0] if_funct3;
logic [6:0] if_funct7;
rv32i_opcode if_opcode;
rv32i_reg if_rs1, if_rs2; 
logic [31:0] if_i_imm, if_u_imm, if_b_imm, if_s_imm, if_j_imm;
rv32i_reg if_rd;

//Decode
logic flush_ID_EX;
logic [31:0] id_pc;
logic [31:0] id_old_pc_plus4;
logic [2:0] id_funct3;
logic [6:0] id_funct7;
rv32i_opcode id_opcode;
rv32i_reg id_rs1, id_rs2; 
logic [31:0] id_i_imm, id_u_imm, id_b_imm, id_s_imm, id_j_imm;
rv32i_reg id_rd;
logic [31:0] id_rs1_out, id_rs2_out;
rv32i_control_word ctrl_word_out;
logic load_ID_EX;

//Execute
logic [31:0] ex_pc;
logic [31:0] ex_old_pc_plus4;
logic [31:0] ex_i_imm, ex_u_imm, ex_b_imm, ex_s_imm, ex_j_imm;
rv32i_reg ex_rd;
rv32i_word ex_cmpmux_out;
logic[31:0] ex_rs1_out, ex_rs2_out;
rv32i_reg ex_rs1, ex_rs2; 
logic ex_br_en;
rv32i_word ex_alu_out;
rv32i_control_word ex_ctrl_word;
logic ex_ctrl_mux_sel;
logic [1:0] forwardA, forwardB;
logic hazard_load_pc_out;
logic load_EX_ctrl;
logic load_EX_MEM;
rv32i_word forwardA_out;
rv32i_word forwardB_out;

//Memory
logic [31:0] mem_pc;
logic [31:0] mem_i_imm, mem_u_imm, mem_b_imm, mem_s_imm, mem_j_imm;
rv32i_reg mem_rd;
rv32i_word mem_cmpmux_out;
logic[31:0] mem_rs1_out, mem_rs2_out;
rv32i_reg mem_rs1, mem_rs2; 
logic mem_br_en;
rv32i_word mem_alu_out;
rv32i_word mem_read_data;
rv32i_control_word mem_ctrl_word;
logic mem_ctrl_mux_sel;
logic load_MEM_ctrl;
logic load_MEM_WB;

//Writeback
logic [31:0] wb_pc;
logic [31:0] wb_i_imm, wb_u_imm, wb_b_imm, wb_s_imm, wb_j_imm;
rv32i_reg wb_rd;
rv32i_word wb_cmpmux_out;
logic[31:0] wb_rs1_out, wb_rs2_out;
rv32i_reg wb_rs1, wb_rs2; 
logic wb_br_en;
rv32i_word wb_alu_out;
rv32i_word regfilemux_out;
rv32i_word wb_read_data;
rv32i_control_word wb_ctrl_word;
logic wb_ctrl_mux_sel;
logic load_WB_ctrl;

//branch prediction
logic br_out;
rv32i_word pc_target;


/************** Assigns **********/
assign mem_read_data = d_rdata; //mem_resp is always high
assign pc = if_pc;
assign i_read = 1'b1; //CHANGE FOR CP2

/************* BUFFERS **********/
IF_ID_buffer IF_ID(
    .*,
	.flush(flush_IF_ID),
	.load(load_IF_ID),
	.pc_i(if_pc), 
	.old_pc_plus4_i(if_old_pc_plus4),
    .opcode_i(if_opcode), 
	.funct3_i(if_funct3), 
	.funct7_i(if_funct7),
    .rs1_i(if_rs1), 
	.rs2_i(if_rs2), 
	.i_imm_i(if_i_imm), 
	.u_imm_i(if_u_imm), 
	.b_imm_i(if_b_imm), 
	.s_imm_i(if_s_imm),
	.j_imm_i(if_j_imm),
	.rd_i(if_rd), 
	.pc_o(id_pc), 
	.old_pc_plus4_o(id_old_pc_plus4),
  	.opcode_o(id_opcode), 
	.funct3_o(id_funct3), 
	.funct7_o(id_funct7),
	.rs1_o(id_rs1), 
	.rs2_o(id_rs2), 
	.i_imm_o(id_i_imm), 
	.u_imm_o(id_u_imm), 
	.b_imm_o(id_b_imm), 
	.s_imm_o(id_s_imm),
	.j_imm_o(id_j_imm),
	.rd_o(id_rd)
);

ID_EX_buffer ID_EX(
    .*,
	.flush(flush_ID_EX),
	.load(load_ID_EX),
    .pc_i(id_pc),
	 .old_pc_plus4_i(id_old_pc_plus4),
	.rs1_out_i(id_rs1_out), 
	.rs2_out_i(id_rs2_out),
	.rs1_i(id_rs1),
	.rs2_i(id_rs2),
	.i_imm_i(id_i_imm), 
	.u_imm_i(id_u_imm), 
	.b_imm_i(id_b_imm), 
	.s_imm_i(id_s_imm),
	.j_imm_i(id_j_imm),
	.rd_i(id_rd),
   .pc_o(ex_pc), 
	.old_pc_plus4_o(ex_old_pc_plus4),	
	.rs1_out_o(ex_rs1_out), 
	.rs2_out_o(ex_rs2_out), 
	.rs1_o(ex_rs1),
	.rs2_o(ex_rs2),
	.i_imm_o(ex_i_imm), 
	.u_imm_o(ex_u_imm), 
	.b_imm_o(ex_b_imm), 
	.s_imm_o(ex_s_imm),
	.j_imm_o(ex_j_imm),
	.rd_o(ex_rd)
);

EX_MEM_buffer EX_MEM(
    .*,
	.load(load_EX_MEM),
    .pc_i(ex_pc), 
	.alu_out_i(ex_alu_out),
    .br_en_i(ex_br_en), 
	.rs1_out_i(forwardA_out), 
	.rs2_out_i(forwardB_out), 
	.rs1_i(ex_rs1),
	.rs2_i(ex_rs2),
	.i_imm_i(ex_i_imm), 
	.u_imm_i(ex_u_imm), 
	.b_imm_i(ex_b_imm), 
	.s_imm_i(ex_s_imm),
	.j_imm_i(ex_j_imm),
	.rd_i(ex_rd), 
	.cmpmux_out_i(ex_cmpmux_out),
    .pc_o(mem_pc), 
	.alu_out_o(mem_alu_out),
	.br_en_o(mem_br_en),
	.rs1_out_o(mem_rs1_out), 
	.rs2_out_o(mem_rs2_out), 
	.rs1_o(mem_rs1),
	.rs2_o(mem_rs2),
	.i_imm_o(mem_i_imm), 
	.u_imm_o(mem_u_imm), 
	.b_imm_o(mem_b_imm), 
	.s_imm_o(mem_s_imm),
	.j_imm_o(mem_j_imm),
	.rd_o(mem_rd),
	.cmpmux_out_o(mem_cmpmux_out)
);

MEM_WB_buffer MEM_WB(
	.*,
	.load(load_MEM_WB),
	.pc_i(mem_pc), 
	.alu_out_i(mem_alu_out),
	.br_en_i(mem_br_en), 
	.rs1_out_i(mem_rs1_out), 
	.rs2_out_i(mem_rs2_out), 
	.rs1_i(mem_rs1),
	.rs2_i(mem_rs2),
	.i_imm_i(mem_i_imm), 
	.u_imm_i(mem_u_imm), 
	.b_imm_i(mem_b_imm), 
	.s_imm_i(mem_s_imm),
	.j_imm_i(mem_j_imm),
	.rd_i(mem_rd),
	.cmpmux_out_i(mem_cmpmux_out),
	.read_data_i(mem_read_data),
	.pc_o(wb_pc), 
	.alu_out_o(wb_alu_out),
	.br_en_o(wb_br_en),
	.rs1_out_o(wb_rs1_out), 
	.rs2_out_o(wb_rs2_out), 
	.rs1_o(wb_rs1),
	.rs2_o(wb_rs2),
	.i_imm_o(wb_i_imm), 
	.u_imm_o(wb_u_imm), 
	.b_imm_o(wb_b_imm), 
	.s_imm_o(wb_s_imm),
	.j_imm_o(wb_j_imm),
	.rd_o(wb_rd),
	.cmpmux_out_o(wb_cmpmux_out),
	.read_data_o(wb_read_data)
);

/************* STAGES ***********/


//fetch stage still needs to to take in instruction and output opcode/funct3/funct7/imm values
fetch_stage IF(
    .*,
	.flush(flush_IF_ID),
	.instruction(instruction),
	.alu_out(ex_alu_out),
	.ex_opcode(ex_ctrl_word.opcode),
	//.br_en(br_out),
	.br_en(ex_br_en),
	.ex_old_pc_plus4(ex_old_pc_plus4),
	.br_out(br_out),
	//.br_en(ex_br_en),
	.pcmux_sel(ex_ctrl_word.pcmux_sel), 
	.load_pc(hazard_load_pc_out),
	.pc_i(ex_pc),
	.pc_target(pc_target),
    .pc(if_pc),
	.opcode(if_opcode), 
	.old_pc_plus4(if_old_pc_plus4),
	.funct3(if_funct3), 
	.funct7(if_funct7),
	.rs1(if_rs1),
	.rs2(if_rs2),
	.i_imm(if_i_imm),
	.u_imm(if_u_imm),
	.b_imm(if_b_imm),
	.s_imm(if_s_imm),
	.j_imm(if_j_imm),
	.rd(if_rd)
);

decode_stage ID(
    .*,
    .funct3(id_funct3),
    .funct7(id_funct7),
    .opcode(id_opcode),
    .regfilemux_out(regfilemux_out),
    .load_regfile(wb_ctrl_word.load_regfile),
    .rs1(id_rs1),
    .rs2(id_rs2),
    .rd(wb_rd),
    .rs1_out(id_rs1_out),
    .rs2_out(id_rs2_out),
    .ctrl(ctrl_word_out)
);

execute_stage EX(
	.ex_alu_out(mem_alu_out),
	.regfilemux_out(regfilemux_out),
    .i_imm(ex_i_imm),
    .u_imm(ex_u_imm),
    .b_imm(ex_b_imm),
    .s_imm(ex_s_imm),
    .j_imm(ex_j_imm),
    .rs1_out(ex_rs1_out),
    .rs2_out(ex_rs2_out),
	.mem_rs1_out(mem_rs1_out),
	.wb_rs1_out(wb_rs1_out),
	.mem_cmpmux_out(mem_cmpmux_out),
	.wb_cmpmux_out(wb_cmpmux_out),
    .pc(ex_pc),
    .alumux1_sel(ex_ctrl_word.alumux1_sel),
    .alumux2_sel(ex_ctrl_word.alumux2_sel),
    .cmpmux_sel(ex_ctrl_word.cmpmux_sel),
    .cmpop(ex_ctrl_word.cmpop),
    .aluop(ex_ctrl_word.aluop),
	.forwardA(forwardA),
	.forwardB(forwardB),
    .br_en(ex_br_en),
    .alu_out(ex_alu_out),
	.cmpmux_out(ex_cmpmux_out),
	.forwardA_out,
	.forwardB_out
);

mem_stage MEM(
    .ALU_out(mem_alu_out),
    .rs2_out(mem_rs2_out),
    .mem_read_i(mem_ctrl_word.mem_read),
    .mem_write_i(mem_ctrl_word.mem_write),
    .funct3(mem_ctrl_word.funct3),
    .opcode(mem_ctrl_word.opcode),
    .mem_read(d_mem_read),
    .mem_write(d_mem_write),
    .mem_address(d_mem_address),
    .write_data(d_wdata),
    .mem_byte_enable(d_wmask)
);

wb_stage WB(
    .read_data(wb_read_data),
    .alu_out(wb_alu_out),
    .pc(wb_pc),
    .br_en(wb_br_en),
    .u_imm(wb_u_imm),
    .regfilemux_sel(wb_ctrl_word.regfilemux_sel),
    .regfilemux_out(regfilemux_out)
);

/***************** CONTROL WORD REGISTERS ********************/
control_word_reg EX_ctrl(
	.*,
	.sel(ex_ctrl_mux_sel),
	.load(load_EX_ctrl),
	.in(ctrl_word_out),
	.out(ex_ctrl_word)
);


control_word_reg MEM_ctrl(
	.*,
	.sel(mem_ctrl_mux_sel),
	.load(load_MEM_ctrl),			//need stall signals
    .in(ex_ctrl_word),
    .out(mem_ctrl_word)
);

control_word_reg WB_ctrl(
	.*,
	.sel(wb_ctrl_mux_sel),
	.load(load_WB_ctrl),			//need stall signals
    .in(mem_ctrl_word),
    .out(wb_ctrl_word)
);


/********** HAZARDS ************************/

hazard hazard(
	.clk(clk),
	.rst(rst),
	.br_en(ex_br_en),
	.br_out(br_out),
	.decode_opcode(ctrl_word_out.opcode),
	.ex_ctrl_opcode(ex_ctrl_word.opcode),
	.ex_ctrl_funct3(ex_ctrl_word.funct3),
	.mem_ctrl_dwrite(mem_ctrl_word.mem_write),
	.mem_ctrl_dread(mem_ctrl_word.mem_read),
	.data_mem_resp(d_mem_resp),
	.inst_mem_resp(i_mem_resp),
	.load_pc_i(1'b1),
	.if_id_rs1(id_rs1),
	.if_id_rs2(id_rs2),
	.id_ex_rd(ex_rd),
	.flush_IF_ID(flush_IF_ID),
	.flush_ID_EX(flush_ID_EX),
	.load_IF_ID(load_IF_ID),
	.load_ID_EX,
	.load_EX_MEM,
	.load_MEM_WB,
	.load_EX_ctrl,
	.load_MEM_ctrl,
	.load_WB_ctrl,
	.load_pc_o(hazard_load_pc_out),
	.ex_ctrl_mux_sel(ex_ctrl_mux_sel),
	.mem_ctrl_mux_sel(mem_ctrl_mux_sel),
	.wb_ctrl_mux_sel(wb_ctrl_mux_sel)
);

forwarding forwarding(
	.clk(clk),
	.rst(rst),
	.ex_mem_rd(mem_rd), 
	.id_ex_rs1(ex_rs1),
	.id_ex_rs2(ex_rs2),
	.mem_wb_rd(wb_rd),
	.id_ex_rd(ex_rd),
	.ex_ctrl_opcode(ex_ctrl_word.opcode),
	.ex_mem_write(mem_ctrl_word.load_regfile),
	.mem_wb_write(wb_ctrl_word.load_regfile),
	.forwardA(forwardA), 
	.forwardB(forwardB)
); 

/******** branch prediction *********/

br_pred br_pred(
	 .clk(clk),
    .rst(rst),
    .flush(flush_ID_EX),
    .ex_ctrl_opcode(ex_ctrl_word.opcode),
	.if_opcode(if_opcode),
    .branch_taken(ex_br_en),
	.alu_out(ex_alu_out),
	.pc_in(if_pc),
	.pc_target(pc_target), 
    .br_out(br_out)
);


endmodule : cpu_datapath
