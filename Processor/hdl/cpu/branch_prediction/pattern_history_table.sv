// pattern history table
//import rv32i_types::*;

module pht #(
    parameter width = 2,
    parameter idx_size = 4
)
(
    input clk,
    input rst,
    input load,
    //input logic [idx_size-1:0] r_idx,
    input logic [idx_size-1:0] w_idx,
    input logic [width-1:0] pht_in,
    output logic [width-1:0] pht_out
);

localparam size = 2**idx_size;
logic [width-1:0] data[size-1:0];
logic [width-1:0] data_temp[size-1:0];

assign data_temp = data;

assign pht_out = data[w_idx];

always_ff @(posedge clk)
begin
    if(rst)
    begin
        for(int i=0; i<size; i++) begin
            data[i] <= 2'b00;
        end
    end
    
    else if(load)
    begin
        data[w_idx] <= pht_in;
    end
    else
    begin
        data <= data_temp;
    end
    

    /*
    else
    begin
        data[size-1:w_idx+1] <= data[size-1:w_idx+1];
        data[w_idx] <= pht_in;
        data[w_idx-1:0] <= data[w_idx-1:0];
    end
    */

end

endmodule : pht
