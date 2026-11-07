`timescale 1ns / 1ps

module CONTROL_BLOCK(
    input logic [7:0] opcode,
    input logic       Z,
    input logic       N,
    input logic       C,
    
    output logic pc_en,
    output logic ir_en,
    output logic opcode_en,
    output logic dest_en,
    output logic op1_en,
    output logic op2_en,
    output logic reg_wen,
    output logic Z_en,
    output logic N_en,
    output logic C_en,
    output logic regs_wdata_sel,
    output logic mem_wen,
    output logic jmp_det
    );
always_comb begin
    case(opcode)
        8'b100000_00: begin //MOV Rd Rs2
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 1;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = 0;
        end
        8'b100000_01: begin //MOV Rd Const
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 1;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = 0;
        end
        8'b001000_01: begin //JMP const
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 0;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = 1;
        end
        8'b001001_01: begin
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 0;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = Z;
        end
        8'b001010_01: begin
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 0;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = N;
        end
        8'b001011_01: begin
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 0;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = C;
        end
        8'b100001_11: begin //LOAD Rd, mem[const]
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 1;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 1;
           mem_wen = 0;
           jmp_det = 0;
        end
        8'b100001_10: begin //LOAD Rd, mem[Rs2]
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 1;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 1;
           mem_wen = 0;
           jmp_det = 0;
        end
        8'b100010_11: begin //STORE mem[const], Rs1
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 0;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 1;
           jmp_det = 0; 
        end
        8'b100010_10: begin //STORE mem[Rs2], Rs1
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 0;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 1;
           jmp_det = 0; 
        end
        8'b111111_11: begin //HALT
           pc_en = 0;
           ir_en = 0;
           opcode_en = 0;
           dest_en = 0;
           op1_en = 0;
           op2_en = 0;
           reg_wen = 0;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = 0; 
        end
        8'b000000_00: begin //NOP
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 0;
           Z_en = 0;
           N_en = 0;
           C_en = 0;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = 0; 
        end
        default: begin //ARITMETICO LOGICE Rd = F(Rs1, Rs2)
           pc_en = 1;
           ir_en = 1;
           opcode_en = 1;
           dest_en = 1;
           op1_en = 1;
           op2_en = 1;
           reg_wen = 1;
           Z_en = 1;
           N_en = 1;
           C_en = 1;
           regs_wdata_sel = 0;
           mem_wen = 0;
           jmp_det = 0;
        end
    endcase
end
endmodule
