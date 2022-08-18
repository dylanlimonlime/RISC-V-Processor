module mp4(
    input clk,
    input rst,
    input pmem_resp,
    input [63:0] pmem_rdata,
    output logic pmem_read,
    output logic pmem_write,
    output logic [31:0] pmem_address,
    output [63:0] pmem_wdata
);
//    //magic memory i/o
//    input clk,
//	input rst,
//  
//    //I Cache Ports 
//    output logic inst_read,
//    output logic [31:0] inst_addr,
//    input logic inst_resp,
//    input logic [31:0] inst_rdata,
//
//    //D Cache Ports 
//    output logic data_read,
//    output logic data_write,
//    output logic [3:0] data_mbe,
//    output logic [31:0] data_addr,
//    output logic [31:0] data_wdata,
//    input logic data_resp,
//    input logic [31:0] data_rdata

    
    //CPU <-> Inst Cache
    logic inst_read;
    logic [31:0] inst_addr;
    logic inst_resp;
    logic [31:0] inst_rdata;

    //CPU <-> Data Cache
    logic data_read;
    logic data_write;
    logic [3:0] data_mbe;
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic data_resp;
    logic [31:0] data_rdata;

    // Arbiter <-> Inst Cache
    logic [31:0] arb_inst_address;
  	logic arb_inst_read;
	logic arb_inst_resp;
  	logic [255:0] arb_inst_rdata;

	// Arbiter <-> Data Cache
	logic arb_data_resp;
	logic [255:0] arb_data_rdata;
	logic [31:0] arb_data_address;
	logic [255:0] arb_data_wdata;
	logic arb_data_read;
	logic arb_data_write;

    // Port to LLC (Lowest Level Cache)
    logic [255:0] line_i;
    logic [255:0] line_o;
    logic [31:0] address_i;
    logic read_i;
    logic write_i;
    logic resp_o;

cpu_datapath cpu(
    .clk(clk),
    .rst(rst),
    .instruction(inst_rdata),
    .pc(inst_addr),
    .i_read(inst_read),
    .i_mem_resp(inst_resp),
    .d_mem_resp(data_resp),
    .d_rdata(data_rdata),
    .d_mem_read(data_read),
    .d_mem_write(data_write),
    .d_mem_address(data_addr),
    .d_wdata(data_wdata),
    .d_wmask(data_mbe)
);


cache inst_cache(
    .clk,
    .pmem_resp(arb_inst_resp),
    .pmem_rdata(arb_inst_rdata),
    .pmem_address(arb_inst_address),
    .pmem_wdata(), // Unconnected
    .pmem_read(arb_inst_read),
    .pmem_write(), // Unconnected
    .mem_read(inst_read),
    .mem_write('0),
    .mem_byte_enable_cpu('0),
    .mem_address(inst_addr),
    .mem_wdata_cpu('0),
    .mem_resp(inst_resp),
    .mem_rdata_cpu(inst_rdata)
);

cache data_cache(
    .clk,
    .pmem_resp(arb_data_resp),
    .pmem_rdata(arb_data_rdata),
    .pmem_address(arb_data_address),
    .pmem_wdata(arb_data_wdata),
    .pmem_read(arb_data_read),
    .pmem_write(arb_data_write),
    .mem_read(data_read),
    .mem_write(data_write),
    .mem_byte_enable_cpu(data_mbe),
    .mem_address(data_addr),
    .mem_wdata_cpu(data_wdata),
    .mem_resp(data_resp),
    .mem_rdata_cpu(data_rdata)
);

arbiter cache_arbiter(
    .clk,
    .rst,
    // Arbiter <-> Instruction Cache Interface
    .inst_address(arb_inst_address),
  	.inst_read(arb_inst_read),
	.inst_resp(arb_inst_resp),
  	.inst_rdata(arb_inst_rdata),

	// Arbiter <-> Data Cache Interface
	.data_resp(arb_data_resp),
	.data_rdata(arb_data_rdata),
	.data_address(arb_data_address),
	.data_wdata(arb_data_wdata),
	.data_read(arb_data_read),
	.data_write(arb_data_write),

    // Arbiter <-> Physical Memory Interface (Cacheline Adapter)
	.mem_line_write(line_i),
    .mem_address(address_i),
    .mem_read(read_i),
    .mem_write(write_i),
	.mem_line_read(line_o),
	.mem_resp(resp_o)
);

cacheline_adapter adapter (
    .clk(clk),
    .reset_n(!rst),
    // Port to LLC (Lowest Level Cache)
    .line_i(line_i),
    .line_o(line_o),
    .address_i(address_i),
    .read_i(read_i),
    .write_i(write_i),
    .resp_o(resp_o),
    // Port to memory
    .burst_i(pmem_rdata),
	.burst_o(pmem_wdata),
	.address_o(pmem_address),
	.read_o(pmem_read),
	.write_o(pmem_write),
	.resp_i(pmem_resp)
);

//L2 Cache
/*
module l2_cache (
  .input clk(),
  .pmem_resp(),
  .pmem_rdata(),
  .pmem_address(),
  .pmem_wdata(),
  .pmem_read(),
  .pmem_write(),
  .mem_read(),
  .mem_write(),
  .lm_byte_enable_cpu(),
  .mem_address(),
  .mem_wdata_cpu(),
  .mem_resp(),
  .mem_rdata_cpu()
);
*/

endmodule : mp4