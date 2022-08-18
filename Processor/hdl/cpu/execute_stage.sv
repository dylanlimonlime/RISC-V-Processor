`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)
import rv32i_types::*;

module execute_stage(
    // Data Inputs
	input rv32i_word ex_alu_out,
	input rv32i_word regfilemux_out,
    input [31:0] i_imm,
    input [31:0] u_imm,
    input [31:0] b_imm,
    input [31:0] s_imm,
    input [31:0] j_imm,
    input [31:0] rs1_out,
    input [31:0] rs2_out,
    input [31:0] pc,
    // Control Inputs
    input alumux::alumux1_sel_t alumux1_sel,
    input alumux::alumux2_sel_t alumux2_sel,
    input cmpmux::cmpmux_sel_t cmpmux_sel,
    input branch_funct3_t cmpop,
    input alu_ops aluop,
	input logic [1:0] forwardA,
	input logic [1:0] forwardB,
	 input [31:0] mem_rs1_out,
	 input [31:0] wb_rs1_out,
	 input [31:0] mem_cmpmux_out,
	 input [31:0] wb_cmpmux_out,
    // Outputs
    output logic br_en,
    output rv32i_word alu_out,
	 output rv32i_word cmpmux_out,
	 output rv32i_word forwardA_out,
	 output rv32i_word forwardB_out
);

rv32i_word alumux1_out;
rv32i_word alumux2_out;
//rv32i_word forwardA_out;
//rv32i_word forwardB_out;

rv32i_word cmp_forwardA_out;
rv32i_word cmp_forwardB_out;

//logic [1:0] forwardA_alu;
//logic [1:0] forwardB_alu;

branch_funct3_t cmpop_in;
always_comb begin
	unique case (cmpop)
		beq: cmpop_in = cmpop;
		bne: cmpop_in = cmpop;
		blt: cmpop_in = cmpop;
		bge: cmpop_in = cmpop;
		bltu: cmpop_in = cmpop;
		bgeu: cmpop_in = cmpop;
		default: cmpop_in = beq;
    endcase
end

alu ALU(
	.aluop,
	.a(alumux1_out),
	.b(alumux2_out),
	.f(alu_out)
);

cmp CMP(
	.cmpop(cmpop_in),
	.a(cmp_forwardA_out),
	.b(cmpmux_out),
	.br_en
);

always_comb begin : MUXES
	unique case(forwardA)
		2'b00: cmp_forwardA_out = rs1_out;
		2'b01: cmp_forwardA_out = regfilemux_out;
		2'b10: cmp_forwardA_out = ex_alu_out;
	endcase
	
//	unique case(forwardB)
//		2'b00: cmp_forwardB_out = cmpmux_out;
//		2'b01: cmp_forwardB_out = regfilemux_out;
//		2'b10: cmp_forwardB_out = ex_alu_out;
//	endcase
	
	unique case(forwardA)
		2'b00: forwardA_out = rs1_out;
		2'b01: forwardA_out = regfilemux_out;
		2'b10: forwardA_out = ex_alu_out;
	endcase

	unique case(forwardB)
		2'b00: forwardB_out = rs2_out;
		2'b01: forwardB_out = regfilemux_out;
		2'b10: forwardB_out = ex_alu_out;
	endcase

    unique case (cmpmux_sel)
		cmpmux::rs2_out: cmpmux_out = forwardB_out;
		cmpmux::i_imm: cmpmux_out = i_imm;
		default: `BAD_MUX_SEL;
	endcase
	
	unique case (alumux1_sel)
		alumux::rs1_out: alumux1_out = forwardA_out;
		alumux::pc_out: alumux1_out = pc;
		default: `BAD_MUX_SEL;
	endcase
	
	unique case (alumux2_sel)
		alumux::i_imm: alumux2_out = i_imm;
		alumux::u_imm: alumux2_out = u_imm;
		alumux::b_imm: alumux2_out = b_imm;
		alumux::s_imm: alumux2_out = s_imm;
		alumux::j_imm: alumux2_out = j_imm;
		alumux::rs2_out: alumux2_out = forwardB_out;
		default: `BAD_MUX_SEL;
	endcase
end

endmodule : execute_stage
