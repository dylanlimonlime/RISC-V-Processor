// arbiter.sv
// keeps coherency between caches

module arbiter(
	input clk, 
	input rst, 

	// Arbiter <-> Instruction Cache Interface
	input logic [31:0] inst_address,
  	input logic inst_read,
	output logic inst_resp,
  	output logic [255:0] inst_rdata,

	// Arbiter <-> Data Cache Interface
	output logic data_resp,
	output logic [255:0] data_rdata,
	input logic [31:0] data_address,
	input logic [255:0] data_wdata,
	input logic data_read,
	input logic data_write,

	// Arbiter <-> Physical Memory Interface (Cacheline Adapter)
	output logic [255:0] mem_line_write,
   output logic [31:0] mem_address,
   output logic mem_read,
   output logic mem_write,
	input logic [255:0] mem_line_read,
	input logic mem_resp
);

logic data_rw; 

// enumerate state machine here
enum int unsigned {
	wait_s,
	data_miss,
	inst_miss

} state, next_state;

// default behavior
function void set_defaults();
	mem_line_write = '0;
	mem_address = '0;
	mem_read = '0;
	mem_write = '0;
	inst_resp = '0;
	inst_rdata = '0;
	data_resp = '0;
	data_rdata = '0;
endfunction : set_defaults


always_ff @(posedge clk) begin 
	if(rst)
		state <= wait_s;
	else
		state <= next_state; 
end


always_comb begin
	set_defaults();
	unique case (state)
		wait_s : ;// Do nothing
		inst_miss : begin
			// Outputs
			if(mem_resp)
				inst_resp = 1'b1;
			inst_rdata = mem_line_read;
			// Inputs
			mem_address = inst_address;
			mem_read = inst_read;
		end
		data_miss : begin
			// Outputs
			if(mem_resp)
				data_resp = 1'b1;
			data_rdata = mem_line_read;
			// Inputs
			mem_address = data_address;
			mem_read = data_read;
			mem_write = data_write;
			mem_line_write = data_wdata;
		end
	endcase
end


always_comb begin
	data_rw = data_read | data_write;
	next_state = state;

	unique case (state)
		wait_s : begin
			if(data_rw)
				next_state = data_miss;
			else if(inst_read)
				next_state = inst_miss;
		end
		inst_miss : begin
			if(!mem_resp)
				next_state = inst_miss;
			else
				next_state = wait_s;
		end
		data_miss : begin
			if(!mem_resp)
				next_state = data_miss;
			else
				next_state = wait_s;
		end
	endcase
end

endmodule : arbiter