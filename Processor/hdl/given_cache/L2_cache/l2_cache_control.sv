module l2_cache_control (
  input clk,

  /* CPU memory data signals */
  input  logic mem_read,
	input  logic mem_write,
	output logic mem_resp,

  /* Physical memory data signals */
  input  logic pmem_resp,
	output logic pmem_read,
	output logic pmem_write,

  /* Control signals */
  output logic tag_load,
  output logic valid_load,
  output logic dirty_load,
  output logic dirty_in,
  input logic dirty_out,

  input logic hit,
  output logic [1:0] writing
);

endmodule : l2_cache_control
