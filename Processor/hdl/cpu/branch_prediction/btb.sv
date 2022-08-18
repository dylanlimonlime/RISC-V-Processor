//branch target buffer
//assuming only needed for WT and ST, thus target will always be the branch

module btb #(
    parameter width = 2,
    parameter idx_size = 4
)
(
    input clk,
    input rst,
    input load,
    input btb_load,
    //input logic [idx_size-1:0] r_idx,
    input logic [idx_size-1:0] w_idx,
    input logic [31:0] pc_in,
    input logic [31:0] alu_out,
    input logic [width-1:0] state,
    output logic [31:0] pc_target
);

localparam size = 2**idx_size;

logic [idx_size-1:0] r_idx;
logic [31:0] pc_data[size-1:0];
logic [31:0] pc_target_data[size-1:0];
logic [31:0] pc_target_in;

//assign pc_target_data = pc_target;

always_comb
begin
    if(pc_in == pc_data[r_idx])
    begin
        pc_target = pc_target_data[r_idx];
    end
    else
    begin
        pc_target = pc_in+4;
    end
end
 
always_ff @(posedge clk)
begin
    if(rst)
    begin
        r_idx <= 0;
        for(int i=0; i<size; i++) begin
            pc_data[i] <= 32'b0;
            pc_target_data[i] <= 32'b0;
        end
    end
    else if (btb_load) begin
        r_idx <= r_idx;
        pc_data[w_idx] <= pc_in;
    end
    else if (load)
    begin
        r_idx <= w_idx;
        pc_target_data[w_idx] <= alu_out;
    end
    else
    begin
        r_idx <= r_idx;
        pc_data <= pc_data;
        pc_target_data <= pc_target_data;
    end
end

endmodule : btb
