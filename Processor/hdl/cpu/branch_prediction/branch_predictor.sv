//datapath for branch prediction
import rv32i_types::*;

module br_pred(
    input clk,
    input rst,
    input logic flush,
    //input load,
    input rv32i_opcode ex_ctrl_opcode,
    input rv32i_opcode if_opcode,
    input logic branch_taken, 
    input rv32i_word alu_out,
    input rv32i_word pc_in,
    output rv32i_word pc_target,
    output logic br_out //prediction
    //output rv32i_word pc_pred
);

/************** WIRES ************/
logic load;
logic [3:0] bhr_out;
logic [1:0] next_state;
logic [1:0] state;
logic br_do;
logic btb_load;

//assign br_out = (br_do && ~flush);
assign br_out = br_do; // br_do == FSM prediction value 

always_comb begin
    load = 1'b0;
    btb_load = 1'b0;
    if(ex_ctrl_opcode == op_br) begin
       load = 1'b1; 
    end else begin
        load = 1'b0;
    end
    if (if_opcode == op_br) begin
        btb_load = 1'b1;
    end
    else begin
        load = 1'b0;
    end
end

/**** Branch history table********/
bhr #(.width(4)) BHR(
    .clk(clk), 
    .rst(rst), 
    .branch_val(branch_taken),
    .load(load),
    .bhr_out(bhr_out)
);

/**** Pattern histroy table*******/
pht #(.width(2), .idx_size(4)) PHT(
    .clk(clk),
    .rst(rst),
    .load(load),
    //.r_idx(),
    .w_idx(bhr_out),
    .pht_in(next_state),
    .pht_out(state)
);

/**************** BTB *************/
btb #(.width(2), .idx_size(4)) BTB(
    .clk(clk),
    .rst(rst),
    .load(load),
    .btb_load(btb_load),
    .w_idx(bhr_out),
    .pc_in(pc_in),
    .alu_out(alu_out),
    .state(state),
    .pc_target(pc_target)
);

/************** FSM ***************/
predictor_fsm FSM(
    .clk(clk), 
	.rst(rst),
    .state(state),
	.br_taken(branch_taken),
    .branch_prediction(br_do),
    .next_state(next_state)
);

endmodule : br_pred