module cacheline_adapter
(
    input clk,
    input reset_n,

    // Port to LLC (Lowest Level Cache)
    input logic [255:0] line_i,
    output logic [255:0] line_o,
    input logic [31:0] address_i,
    input read_i,
    input write_i,
    output logic resp_o,

    // Port to memory
    input logic [63:0] burst_i,
    output logic [63:0] burst_o,
    output logic [31:0] address_o,
    output logic read_o,
    output logic write_o,
    input resp_i
);

	enum logic [3:0] {Halted, Read_1, Read_2, Read_3, Read_4, Read_response, 
	Write_1, Write_2, Write_3, Write_4, Write_wait_1, Write_wait_2, Write_wait_3, Write_wait_4, Write_store, Write_finish} State, Next_state;
	logic [255:0] buffer;
	logic [255:0] buffer_in;

	always_ff @ (posedge clk)
	begin
		if (!reset_n)
			State <= Halted;
		else
			State <= Next_state;
	end
	
	always_ff @ (posedge clk)
	begin
		if (!reset_n)
		begin
			buffer <= '0;
		end
		else
			buffer <= buffer_in;
	end
	
	always_comb
	begin
		Next_state = State;
		buffer_in = buffer;
		
		line_o = 256'b0;
		resp_o = 1'b0;
		burst_o = 64'b0;
		address_o = 32'b0;
		read_o = 1'b0;
		write_o = 1'b0;
		
		unique case (State)
			Halted:
				begin
					if(read_i == 1'b1)
						Next_state = Read_1;
					else if(write_i == 1'b1)
						Next_state = Write_1;
				end
			Read_1:
				begin
					if(resp_i == 1'b1)
						Next_state = Read_2;
				end
			Read_2:
				begin
					if(resp_i == 1'b1)
						Next_state = Read_3;
				end
			Read_3:
				begin
					if(resp_i == 1'b1)
						Next_state = Read_4;
				end
			Read_4:
				begin
					if(resp_i == 1'b1)
						Next_state = Read_response;
				end
			Read_response:
				begin
					Next_state = Halted;
				end
			Write_1:
				if(resp_i)
					Next_state = Write_2;
			Write_2:
				if(resp_i)
					Next_state = Write_3;
			Write_3:
				if(resp_i)
					Next_state = Write_4;
			Write_4:
				Next_state = Write_finish;
			Write_finish:
				Next_state = Halted;
			default: ;
		endcase
		
		case (State)
			Halted: buffer_in = line_i;
			Read_1: 
				begin
					address_o = address_i;
					burst_o = burst_i;
					read_o = 1'b1;
					buffer_in = {buffer[255:64], burst_i};
				end
			Read_2: 
				begin
					address_o = address_i;
					burst_o = burst_i;
					read_o = 1'b1;
					buffer_in = {buffer[255:128], burst_i, buffer[63:0]};
				end
			Read_3: 
				begin
					address_o = address_i;
					burst_o = burst_i;
					read_o = 1'b1;
					buffer_in = {buffer[255:192], burst_i, buffer[127:0]};
				end
			Read_4: 
				begin
					address_o = address_i;
					burst_o = burst_i;
					read_o = 1'b1;
					buffer_in = {burst_i, buffer[191:0]};
				end
			Read_response:
				begin
					line_o = buffer;
					resp_o = 1'b1;
				end
			Write_1:
				begin
					write_o = 1'b1;
					address_o = address_i;
					burst_o = buffer[63:0];
				end
			Write_2:
				begin
					write_o = 1'b1;
					address_o = address_i;
					burst_o = buffer[127:64];
				end
			Write_3:
				begin
					write_o = 1'b1;
					address_o = address_i;
					burst_o = buffer[191:128];
				end
			Write_4:
				begin
					write_o = 1'b1;
					address_o = address_i;
					burst_o = buffer[255:192];
				end
			Write_finish:
				begin
					resp_o = 1'b1;
				end
			default: ;
		endcase
		
	end

endmodule : cacheline_adapter
