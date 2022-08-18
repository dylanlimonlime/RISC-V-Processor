`define BAD_MUX_SEL $fatal("%0t %s %0d: Illegal mux select", $time, `__FILE__, `__LINE__)
import rv32i_types::*;

module mem_stage(
    input [31:0] ALU_out,
    input [31:0] rs2_out,
    input mem_read_i,
    input mem_write_i,
    input [2:0] funct3,
    input rv32i_opcode opcode,
    output logic mem_read,
    output logic mem_write,
    output rv32i_word mem_address,
    output rv32i_word write_data,
    output logic [3:0] mem_byte_enable
);

logic [1:0] address_offset;
store_funct3_t store_funct3;
assign store_funct3 = store_funct3_t'(funct3);

always_comb begin
	 address_offset = ALU_out[1:0];
    mem_address = {ALU_out[31:2], 2'b0};
    mem_read = mem_read_i;
    mem_write = mem_write_i;
    write_data = rs2_out;
    mem_byte_enable = 4'b1111;

    unique case (store_funct3)
        sw: mem_byte_enable = 4'b1111;
        sh: begin
            if(address_offset == 2'b10) begin
                mem_byte_enable = 4'b1100;
                write_data = (rs2_out & 32'h0000FFFF) << 16;
            end
            else begin
                mem_byte_enable = 4'b0011;
                write_data = rs2_out & 32'h0000FFFF;
            end
        end
        sb: begin
            mem_byte_enable = (4'b0001) << address_offset;
            unique case(address_offset)
                2'b00: begin
                    write_data = rs2_out & 32'h000000FF;
                end
                2'b01: begin
                    write_data = (rs2_out & 32'h000000FF) << 8;
                end
                2'b10: begin
                    write_data = (rs2_out & 32'h000000FF) << 16;
                end
                2'b11: begin
                    write_data = (rs2_out & 32'h000000FF) << 24;
                end
					 default: begin
						// Do nothing
					 end
            endcase
        end 
		  default: begin
			// Do nothing
		  end
    endcase
end

endmodule : mem_stage
