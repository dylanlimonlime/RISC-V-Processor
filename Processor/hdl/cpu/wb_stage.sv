`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)
import rv32i_types::*;

module wb_stage(
    input [31:0] read_data,
    input [31:0] alu_out,
    input [31:0] pc,
    input br_en,
    input [31:0] u_imm,
    //input [4:0] rd_i,
    input regfilemux::regfilemux_sel_t regfilemux_sel,
    //output logic [4:0] rd,
    output rv32i_word regfilemux_out
);

logic [1:0] address_offset;
rv32i_word lb_out;
rv32i_word lbu_out;
rv32i_word lh_out;
rv32i_word lhu_out;

always_comb begin
    //rd = rd_i;
    address_offset = alu_out[1:0];

    if(address_offset == 2'b10) begin
		lhu_out = (read_data & 32'hFFFF0000) >> 16;
		lh_out = {{16{read_data[31]}}, read_data[31:16]};
	end
	else begin
		lhu_out = read_data & 32'h0000FFFF;
		lh_out = {{16{read_data[15]}}, read_data[15:0]};
	end
		
	unique case(address_offset)
		2'b00: begin
			lbu_out = read_data & 32'h000000FF;
			lb_out = {{24{read_data[7]}}, read_data[7:0]};
		end
		2'b01: begin
			lbu_out = (read_data & 32'h0000FF00) >> 8;
			lb_out = {{24{read_data[15]}}, read_data[15:8]};
		end
		2'b10: begin
			lbu_out = (read_data & 32'h00FF0000) >> 16;
			lb_out = {{24{read_data[23]}}, read_data[23:16]};
		end
		2'b11: begin
			lbu_out = (read_data & 32'hFF000000) >> 24;
			lb_out = {{24{read_data[31]}}, read_data[31:24]};
		end
		default: begin
			lbu_out = '0;
			lb_out = '0;
		end
	endcase

    unique case (regfilemux_sel)
		regfilemux::alu_out: regfilemux_out = alu_out;
		regfilemux::br_en: regfilemux_out = {31'b0, br_en};
		regfilemux::u_imm: regfilemux_out = u_imm;
		regfilemux::lw: regfilemux_out = read_data;
		regfilemux::pc_plus4: regfilemux_out = pc + 4;
		regfilemux::lb: regfilemux_out = lb_out;
		regfilemux::lbu: regfilemux_out = lbu_out;
		regfilemux::lh: regfilemux_out = lh_out;
		regfilemux::lhu: regfilemux_out = lhu_out;
		default: `BAD_MUX_SEL;
	endcase
end

endmodule : wb_stage
