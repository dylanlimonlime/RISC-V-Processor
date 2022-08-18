// 2-bit predictor

// Imports here

module predictor_fsm (

	input clk, 
	input rst, 
	input logic [1:0] state,
	input logic br_taken, // br_taken can either be taken = 1, not taken = 0
	output logic branch_prediction,
	output logic [1:0] next_state
); 

// enumerate state machine here
/*
enum int unsigned {

	strongly_taken, //11 
	weakly_taken, //10
	weakly_not_taken, //01 
	strongly_not_taken //00

} state, next_state;
*/

// default behavior
function void set_defaults();
	// set defaults in here
endfunction : set_defaults

/*
always_ff @(posedge clk) begin 
	if(rst)
		state <= 00; //strongly_not_taken; // ??? 
	else
		state <= next_state; 
end
*/

always_comb begin
	unique case(state)
		2'b00: begin
			branch_prediction = 1'b0; end

		2'b01: begin
			branch_prediction = 1'b0; end

		2'b10: begin
			branch_prediction = 1'b1; end

		2'b11: begin
			branch_prediction = 1'b1; end
	endcase 
end

always_comb begin

	unique case(state)
		2'b11: begin 
			if(br_taken)
				next_state = 2'b11; //strongly_taken; 
			else
				next_state = 2'b10; //weakly_taken; 
		end

		2'b10: begin
			if(br_taken)
				next_state = 2'b11; //strongly_taken;
			else
				next_state = 2'b01; //weakly_not_taken;
		end

		2'b01: begin
			if(br_taken)
				next_state = 2'b10; //weakly_taken;
			else
				next_state = 2'b00; //strongly_not_taken;
		end

		2'b00: begin
			if(br_taken)
				next_state = 2'b01; //weakly_not_taken;
			else
				next_state = 2'b00; //strongly_not_taken; 
		end
	endcase
end

endmodule : predictor_fsm
