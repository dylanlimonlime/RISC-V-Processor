// branch history register

// Imports here

module bhr #(parameter width = 4)
(
	input clk, 
	input rst, 
	input logic branch_val,
	input logic load,
	output logic [3:0] bhr_out
);

logic [width-1:0] data = 0;  
logic [width-1:0] branch_outcome;

assign branch_outcome = {data[width-2:0], branch_val}; 

always_ff @(posedge clk)
begin
    if (rst)
    begin
        data <= '0;
    end
    else if (load)
    begin
        data <= branch_outcome;
    end
    else
    begin
        data <= data;
    end
end

always_comb
begin
    bhr_out = data;
end

endmodule : bhr
