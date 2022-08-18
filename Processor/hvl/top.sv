import rv32i_types::*;
module mp4_tb;
`timescale 1ns/10ps

/********************* Do not touch for proper compilation *******************/
// Instantiate Interfaces
tb_itf itf();
rvfi_itf rvfi(itf.clk, itf.rst);

// Instantiate Testbench
source_tb tb(
    .magic_mem_itf(itf),
    .mem_itf(itf),
    .sm_itf(itf),
    .tb_itf(itf),
    .rvfi(rvfi)
);

// For local simulation, add signal for Modelsim to display by default
// Note that this signal does nothing and is not used for anything
bit f;

/****************************** End do not touch *****************************/

/************************ Signals necessary for monitor **********************/
// This section not required until CP2

assign rvfi.commit = 0; // Set high when a valid instruction is modifying regfile or PC
//assign rvfi.halt = dut.cpu.IF.load_pc & (dut.cpu.IF.pcmux_out == dut.cpu.IF.pc+4);   // Set high when you detect an infinite loop
logic halt_condition;

int repeat_min;
int miss_count;
logic delayed_halt;
logic [31:0] cur_pc;
logic [31:0] prev_pc;
logic [31:0] prev_prev_pc;
logic [31:0] prev_prev_prev_pc;
//assign halt_condition = (cur_pc == prev_prev_prev_pc);
assign halt_condition = (dut.cpu.IF.load_pc)&(dut.cpu.IF.pcmux_out == dut.cpu.IF.pc-8);

initial rvfi.order = 0;
always @(posedge itf.clk iff rvfi.commit) rvfi.order <= rvfi.order + 1; // Modify for OoO

always_comb begin
//	if(repeat_min == 200)
//		rvfi.halt = 1;
	if(delayed_halt) begin
		rvfi.halt = 1;
		$finish;
	end
end

always @(posedge itf.clk) begin
//	cur_pc <= dut.cpu.IF.pc;
//	prev_pc <= cur_pc;
//	prev_prev_pc <= prev_pc;
//	prev_prev_prev_pc <= prev_prev_pc;
	if(itf.rst) begin
		repeat_min <= 0;
		miss_count <= 0;
		cur_pc <= -1;
		delayed_halt <= 0;
	end
	else if(halt_condition) begin
//		repeat_min <= repeat_min+1;
//		miss_count <= 0;
//		if(repeat_min == 200) begin
//			$finish;
//		end
		cur_pc <= dut.cpu.IF.pcmux_out;
	end
	if(cur_pc == dut.cpu.wb_pc) begin
		repeat (3) @(posedge itf.clk);
		delayed_halt = 1;
	end
//	else if(!halt_condition) begin
//		repeat_min <= 0;
//		miss_count <= miss_count + 1;
//		if(miss_count == 2) begin
//			repeat_min <= 0;
//			miss_count <= 0;
//		end
//	end
//	if(rvfi.halt) begin
//		repeat (20) @(posedge itf.clk);
//		$finish;
//	end
end

/*
The following signals need to be set:
Instruction and trap:
    rvfi.inst
    rvfi.trap

Regfile:
    rvfi.rs1_addr
    rvfi.rs2_add
    rvfi.rs1_rdata
    rvfi.rs2_rdata
    rvfi.load_regfile
    rvfi.rd_addr
    rvfi.rd_wdata

PC:
    rvfi.pc_rdata
    rvfi.pc_wdata

Memory:
    rvfi.mem_addr
    rvfi.mem_rmask
    rvfi.mem_wmask
    rvfi.mem_rdata
    rvfi.mem_wdata

Please refer to rvfi_itf.sv for more information.
*/

/**************************** End RVFIMON signals ****************************/

/********************* Assign Shadow Memory Signals Here *********************/
// This section not required until CP2
/*
The following signals need to be set:
icache signals:
    itf.inst_read
    itf.inst_addr
    itf.inst_resp
    itf.inst_rdata

dcache signals:
    itf.data_read
    itf.data_write
    itf.data_mbe
    itf.data_addr
    itf.data_wdata
    itf.data_resp
    itf.data_rdata

Please refer to tb_itf.sv for more information.
*/

/*********************** End Shadow Memory Assignments ***********************/

// Set this to the proper value
assign itf.registers = dut.cpu.ID.regile.data;

/*********************** Instantiate your design here ************************/
/*
The following signals need to be connected to your top level:
Clock and reset signals:
    itf.clk
    itf.rst

Burst Memory Ports:
    itf.mem_read
    itf.mem_write
    itf.mem_wdata
    itf.mem_rdata
    itf.mem_addr
    itf.mem_resp

Please refer to tb_itf.sv for more information.
*/

//mp4 dut(
//    //I Cache Ports 
//    .clk(itf.clk),
//    .rst(itf.rst),
//    .inst_read(itf.inst_read),
//    .inst_addr(itf.inst_addr),
//    .inst_resp(itf.inst_resp),
//    .inst_rdata(itf.inst_rdata),
//
//     //D Cache Ports itf.
//    .data_read(itf.data_read),
//    .data_write(itf.data_write),
//    .data_mbe(itf.data_mbe),
//    .data_addr(itf.data_addr),
//    .data_wdata(itf.data_wdata),
//    .data_resp(itf.data_resp),
//    .data_rdata(itf.data_rdata)
//);

mp4 dut(
	.clk(itf.clk),
	.rst(itf.rst),
	.pmem_resp(itf.mem_resp),
	.pmem_rdata(itf.mem_rdata),
	.pmem_read(itf.mem_read),
	.pmem_write(itf.mem_write),
	.pmem_address(itf.mem_addr),
	.pmem_wdata(itf.mem_wdata)
);

assign itf.inst_read = dut.inst_read;
assign itf.inst_addr = dut.inst_addr;
assign itf.inst_resp = dut.inst_resp;
assign itf.inst_rdata = dut.inst_rdata;
assign itf.data_read = dut.data_read;
assign itf.data_write = dut.data_write;
assign itf.data_mbe = dut.data_mbe;
assign itf.data_addr = dut.data_addr;
assign itf.data_wdata = dut.data_wdata;
assign itf.data_resp = dut.data_resp;
assign itf.data_rdata = dut.data_rdata;
/***************************** End Instantiation *****************************/

endmodule
