import rv32i_types::*;
module control_word_reg(
    input clk,
    input rst,
    input load,
    input sel,
    input rv32i_control_word in,
    output rv32i_control_word out
);

rv32i_control_word data;
rv32i_control_word data_in;

always_ff @(posedge clk)
begin
    if (rst)
    begin
        data <= 0;
    end
    else if (load)
    begin
        data <= data_in;
    end
    else
    begin
        data <= data;
    end
end

always_comb
begin
    /*
    default_ctrl.opcode = 7'b0;
    default_ctrl.funct3 = 0;
    default_ctrl.funct7 = 0;
    default_ctrl.aluop = 0;
    default_ctrl.cmpop = 0;
    default_ctrl.alumux1_sel = 0;
    default_ctrl.alumux2_sel = 0;
    default_ctrl.cmpmux_sel = 0;
    default_ctrl.mem_read = 0;
    default_ctrl.mem_write = 0;
    default_ctrl.load_pc = 0;
    default_ctrl.pcmux_sel = 0;
    default_ctrl.load_regfile = 0;
    default_ctrl.regfilemux_sel = 0;
    */
    unique case(sel)
        1'b0:   data_in = in;
        1'b1:   data_in = 0;
    endcase
	 out = data;
end

endmodule : control_word_reg
