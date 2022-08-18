import rv32i_types::*;

module cmp
(
    input branch_funct3_t cmpop,
    input rv32i_word a, 
	 input rv32i_word b,
    output logic br_en
);
logic [32:0] a_unsigned;
logic [32:0] b_unsigned;
assign a_unsigned = {1'b0,a};
assign b_unsigned = {1'b0,b};

logic signed [31:0] signed_a;
logic signed [31:0] signed_b;
assign signed_a = a;
assign signed_b = b;

always_comb
begin
	 br_en = 1'b0;
    unique case (cmpop)
        beq:  
		  begin
			if(a==b)
				br_en = 1'b1;
		  end
        bne:  
		  begin
			if(a!=b)
				br_en = 1'b1;
		  end
        blt:
		  begin
			if(signed_a < signed_b)
				br_en = 1'b1;
		  end
        bge:
		  begin
			if(signed_a >= signed_b)
				br_en = 1'b1;
		  end
        bltu:  
		  begin
			if(a_unsigned<b_unsigned)
				br_en = 1'b1;
		  end
        bgeu:  
		  begin
			if(a_unsigned>=b_unsigned)
				br_en = 1'b1;
		  end
    endcase
end

endmodule : cmp
