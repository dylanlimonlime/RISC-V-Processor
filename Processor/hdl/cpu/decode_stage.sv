import rv32i_types::*;

module decode_stage(
    // General Inputs
    input clk,
    input rst,
    // Data Inputs
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input rv32i_opcode opcode,
    input [31:0] regfilemux_out,
    // Control Inputs
    input load_regfile,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    // Outputs
    output rv32i_word rs1_out,
    output rv32i_word rs2_out,
    output rv32i_control_word ctrl
);

logic load_regfile_in;
always_comb begin
    if (rd == 0)
        load_regfile_in = 0;
    else
        load_regfile_in = load_regfile;
	if (rd == 0)
		load_regfile_in = 0;
	else
		load_regfile_in = load_regfile;
end

regfile regile(
    .*,
    .load(load_regfile_in),
    .in(regfilemux_out),
    .src_a(rs1),
    .src_b(rs2),
    .dest(rd),
    .reg_a(rs1_out),
    .reg_b(rs2_out)
);

control_rom control_rom(
    .*
);

endmodule : decode_stage

