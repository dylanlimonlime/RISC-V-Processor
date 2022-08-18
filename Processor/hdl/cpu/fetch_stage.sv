`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)
import rv32i_types::*; 

module fetch_stage(
	input clk, 
	input rst,
	input logic flush,
	// Data Inputs 
	input rv32i_word instruction,
	input rv32i_word alu_out, 
	input rv32i_opcode ex_opcode,
	input logic br_en,
	input [31:0] pc_i,
	input [31:0] ex_old_pc_plus4,
	input logic br_out,
	// Control Inputs
	input pcmux::pcmux_sel_t pcmux_sel, 
	input logic load_pc,
	input rv32i_word pc_target,

	//Outputs
	output logic [31:0] pc,
	output logic [31:0] old_pc_plus4,
	output rv32i_opcode opcode, 
	output logic [2:0] funct3, 
	output logic [6:0] funct7,
	output rv32i_reg rs1,
	output rv32i_reg rs2,
	output logic [31:0] i_imm,
	output logic [31:0] u_imm,
	output logic [31:0] b_imm,
	output logic [31:0] s_imm,
	output logic [31:0] j_imm,
	output rv32i_reg rd
); 

logic [31:0] pc_temp;

pcmux::pcmux_sel_t branch_mux_out;
logic [31:0] pc_plus4_in;
rv32i_word pcmux_out;
logic [1:0] br_temp; 

assign br_temp = {1'b0, br_en};
assign old_pc_plus4 = pc + 4;
// pc register
pc_register PC(
	.clk(clk),
	.rst(rst),
	.load(load_pc),
	.in(pcmux_out),
	.out(pc)
); 


always_comb begin: MUXES 
	//pc_temp = pcmux_out;
	// branch mux 
	unique case(ex_opcode == op_br)
		1'b0: branch_mux_out = pcmux_sel; 
		1'b1: branch_mux_out = pcmux::pcmux_sel_t'(br_temp); 
		default: `BAD_MUX_SEL; 
	endcase
	
//	unique case(ex_opcode == op_br && br_temp ==0)
//		1'b0: begin
//			if(br_out) begin
//				pc_plus4_in = pc_target;
//			end else begin
//				pc_plus4_in = pc + 4;
//			end
//		end
//		1'b1: begin
//			if(br_out) begin
//				pc_plus4_in = ex_old_pc_plus4;
//			end else begin
//				pc_plus4_in = pc + 4;
//			end
//		end
//	endcase
//	
//	unique case(branch_mux_out)
//		pcmux::pc_plus4: pcmux_out = pc_plus4_in;
//		pcmux::alu_out: pcmux_out = alu_out; 
//		pcmux::alu_mod2: pcmux_out = {alu_out[31:1],1'b0};
//		default: `BAD_MUX_SEL;  
//	endcase 
	
	unique case(branch_mux_out)
		pcmux::pc_plus4: pcmux_out = pc + 4;
		pcmux::alu_out: pcmux_out = alu_out; 
		pcmux::alu_mod2: pcmux_out = {alu_out[31:1],1'b0};
		default: `BAD_MUX_SEL;  
	endcase 

end

/********** Intruction Register breakup *********/
assign opcode = rv32i_opcode'(instruction[6:0]);
assign funct3 = instruction[14:12];
assign funct7 = instruction[31:25];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign i_imm = {{21{instruction[31]}}, instruction[30:20]};
assign u_imm = {instruction[31:12], 12'b000000000000};
assign b_imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
assign s_imm = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
assign j_imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
assign rd = instruction[11:7];

endmodule : fetch_stage