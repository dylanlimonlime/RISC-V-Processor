import rv32i_types::*;

module control_rom
(
    input rv32i_opcode opcode,
	input logic [6:0] funct7,
    input logic [2:0] funct3,
    output rv32i_control_word ctrl
);

rv32i_opcode opcode_funct7;
arith_funct3_t arith_funct3;
branch_funct3_t branch_funct3;
load_funct3_t load_funct3;
store_funct3_t store_funct3;
alu_ops alu_funct3;

assign opcode_funct7 = rv32i_opcode'(funct7);
assign arith_funct3 = arith_funct3_t'(funct3);
assign branch_funct3 = branch_funct3_t'(funct3);
assign load_funct3 = load_funct3_t'(funct3);
assign store_funct3 = store_funct3_t'(funct3);
assign alu_funct3 = alu_ops'(funct3);

function void loadPC(pcmux::pcmux_sel_t sel);
    ctrl.load_pc = 1'b1;
    ctrl.pcmux_sel = sel;
endfunction

function void loadRegfile(regfilemux::regfilemux_sel_t sel);
	ctrl.load_regfile = 1'b1;
	ctrl.regfilemux_sel = sel;
endfunction

function void setALU(alumux::alumux1_sel_t sel1,
                     alumux::alumux2_sel_t sel2,
                     logic setop = 1'b0, 
                     alu_ops op = alu_add);
    ctrl.alumux1_sel = sel1;
    ctrl.alumux2_sel = sel2;
    if (setop)
        ctrl.aluop = op;
endfunction

function automatic void setCMP(cmpmux::cmpmux_sel_t sel, branch_funct3_t op);
	ctrl.cmpmux_sel = sel;
	ctrl.cmpop = op;
endfunction

always_comb
begin
    /* Default Assignments */
    ctrl.opcode = opcode;
    ctrl.funct3 = funct3;
    ctrl.funct7 = funct7;
    ctrl.aluop = alu_funct3;
    ctrl.cmpop = branch_funct3;
    ctrl.alumux1_sel = alumux::rs1_out;
    ctrl.alumux2_sel = alumux::i_imm;
    ctrl.cmpmux_sel = cmpmux::rs2_out;
    ctrl.mem_read = 1'b0;
    ctrl.mem_write = 1'b0;
    ctrl.load_pc = 1'b0;
    ctrl.pcmux_sel = pcmux::pc_plus4;
    ctrl.load_regfile = 1'b0;
    ctrl.regfilemux_sel = regfilemux::alu_out;

    case(opcode)
        op_auipc: begin
            loadPC(pcmux::pc_plus4);
            setALU(alumux::pc_out, alumux::u_imm, 1'b1, alu_add);
			loadRegfile(regfilemux::alu_out);
        end
        
        op_lui: begin
            loadPC(pcmux::pc_plus4);
			loadRegfile(regfilemux::u_imm);
        end

        op_br: begin
            loadPC(pcmux::pc_plus4); // Logic handled in fetch
			setALU(alumux::pc_out, alumux::b_imm, 1'b1, alu_add);
        end

        op_imm: begin
            loadPC(pcmux::pc_plus4);
			unique case (arith_funct3)
				add:
				begin
					setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
				sll:
				begin
					setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
				slt:
				begin
					loadRegfile(regfilemux::br_en);
					setCMP(cmpmux::i_imm, blt);
				end
				sltu:
				begin
					loadRegfile(regfilemux::br_en);
					setCMP(cmpmux::i_imm, bltu);
				end
				axor:
				begin
					setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
				sr:
				begin
					loadRegfile(regfilemux::alu_out);
					if(opcode_funct7 == 7'b0)
						setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_srl);
					else
						setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_sra);
				end
				aor:
				begin
					setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
				aand:
				begin
					setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
			endcase
        end

        op_load: begin
            loadPC(pcmux::pc_plus4);
            setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
            ctrl.mem_read = 1'b1;
            unique case (load_funct3)
				lb  : loadRegfile(regfilemux::lb);
				lh  : loadRegfile(regfilemux::lh);
				lw  : loadRegfile(regfilemux::lw);
				lbu : loadRegfile(regfilemux::lbu);
				lhu : loadRegfile(regfilemux::lhu);
			endcase
        end

        op_store: begin
			loadPC(pcmux::pc_plus4);
            setALU(alumux::rs1_out, alumux::s_imm, 1'b1, alu_add);
            ctrl.mem_write = 1'b1;
        end

        op_reg: begin
            loadPC(pcmux::pc_plus4);
			unique case (arith_funct3)
				add:
				begin
					if(opcode_funct7 == 7'b0)
						setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_add);
					else
						setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sub);
					loadRegfile(regfilemux::alu_out);
				end
				sll:
				begin
					setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
				slt:
				begin
					loadRegfile(regfilemux::br_en);
					setCMP(cmpmux::rs2_out, blt);
				end
				sltu:
				begin
					loadRegfile(regfilemux::br_en);
					setCMP(cmpmux::rs2_out, bltu);
				end
				axor:
				begin
					setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
				sr:
				begin
					loadRegfile(regfilemux::alu_out);
					if(opcode_funct7 == 7'b0)
						setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_srl);
					else
						setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_sra);
				end
				aor:
				begin
					setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
				aand:
				begin
					setALU(alumux::rs1_out, alumux::rs2_out, 1'b1, alu_funct3);
					loadRegfile(regfilemux::alu_out);
				end
			endcase
        end

        op_jal: begin
            loadRegfile(regfilemux::pc_plus4);
			setALU(alumux::pc_out, alumux::j_imm, 1'b1, alu_add);
			loadPC(pcmux::alu_out);
        end

        op_jalr: begin
            loadRegfile(regfilemux::pc_plus4);
			setALU(alumux::rs1_out, alumux::i_imm, 1'b1, alu_add);
			loadPC(pcmux::alu_mod2);
        end

        default: begin
            ctrl = 0;   /* Unknown opcode, set control word to zero */
        end
    endcase

end

endmodule : control_rom
