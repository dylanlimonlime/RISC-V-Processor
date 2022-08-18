// Eviction Write Buffer

module eviction_write_buffer(

	/* EWB sits between the cache and the main memory */
	/* Should only hold dirty evicted blocks */
	
	input clk, 
	input rst, 
	input logic load, 
	input logic [31:0] address_in,
	input logic [127:0] data_in, 

	output logic [31:0] address_out, 
	output logic [127:0] data_out // or 64-bit? Cacheline Adapter?
);

logic [127:0] data; 
logic [31:0] addr; 

always_ff @(posedge clk) begin 
	if(load)
	begin
		addr = address_in; 
		data = data_in; 
	end
end 

always_comb begin 
	address_out = addr; 
	data_out = data; 
end

endmodule : eviction_write_buffer