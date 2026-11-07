`timescale 1ns / 1ps

module PROCESSOR
    (
        input logic clock,
        input logic reset,
    
        output logic [7:0] instr_mem_addr_read,
        input  logic [31:0] instr,
        output logic        mem_wen,
        output logic [7:0] data_mem_addr_write,
        output logic [7:0] data_mem_addr_read,
        output logic [15:0] data_mem_data_write,
        input logic  [15:0] data_mem_data_in 
    );

logic CONTROL_BLOCK_0_PC_EN;
logic CONTROL_BLOCK_0_JMP_DET;
logic CONTROL_BLOCK_0_IR_EN;
logic[31:0] IR_0_INSTR_OUT;
logic CONTROL_BLOCK_0_REG_WEN;
logic [15:0] MUX_REGS_WDATA_SEL_0_OUT;
logic [15:0] REGISTER_FILE_0_RDATA1;
logic [15:0] REGISTER_FILE_0_RDATA2;
logic [15:0] OPERAND_2_IN;
logic CONTROL_BLOCK_0_REGS_WDATA_SEL;
logic [3:0] DEST_0_OUT;
logic [15:0] OPERAND2_0_OUT;

PC PC_0 (
    .clock(clock),
    .reset(reset),
    .w_en(CONTROL_BLOCK_0_PC_EN),
    .jmp_det(CONTROL_BLOCK_0_JMP_DET),
    .jmp_value(OPERAND2_0_OUT[7:0]),
    .pc_out(instr_mem_addr_read)
);

logic [31:0] IR_IN_0_OUT;

MUX2 #(.BUS_WIDTH(32)) IR_IN_0(
    .in0(instr),
    .in1(32'b0),
    .sel(CONTROL_BLOCK_0_JMP_DET),
    .out0(IR_IN_0_OUT)
);

REGISTER #(.SIZE(32)) IR_0
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_IR_EN),
        .in(IR_IN_0_OUT),
        .out(IR_0_INSTR_OUT)
    );

REGISTER_FILE REGISTER_FILE_0
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_REG_WEN),
        .w_addr(DEST_0_OUT),
        .w_data(MUX_REGS_WDATA_SEL_0_OUT),
        .r_addr1(IR_0_INSTR_OUT[19:16]),
        .r_addr2(IR_0_INSTR_OUT[15:12]), 
        .rdata1(REGISTER_FILE_0_RDATA1),
        .rdata2(REGISTER_FILE_0_RDATA2)
    );

logic FORWARD_RS1_SEL;
logic FORWARD_RS2_SEL;
logic [15:0] FORWARD_RS1_MUX_OUT;
logic [15:0] FORWARD_RS2_MUX_OUT;

assign FORWARD_RS1_SEL = CONTROL_BLOCK_0_REG_WEN & (DEST_0_OUT == IR_0_INSTR_OUT[19:16]);
assign FORWARD_RS2_SEL = CONTROL_BLOCK_0_REG_WEN & (DEST_0_OUT == IR_0_INSTR_OUT[15:12]);

MUX2 #(.BUS_WIDTH(16)) FORWARD_RS1_MUX
    (
        .in0(REGISTER_FILE_0_RDATA1),
        .in1(MUX_REGS_WDATA_SEL_0_OUT),
        .out0(FORWARD_RS1_MUX_OUT),
        .sel(FORWARD_RS1_SEL)
    );

MUX2 #(.BUS_WIDTH(16)) FORWARD_RS2_MUX
    (
        .in0(REGISTER_FILE_0_RDATA2),
        .in1(MUX_REGS_WDATA_SEL_0_OUT),
        .out0(FORWARD_RS2_MUX_OUT),
        .sel(FORWARD_RS2_SEL)
    );
    
MUX2 #(.BUS_WIDTH(16)) CONST_OR_ADDR
    (
        .in0(FORWARD_RS2_MUX_OUT),
        .in1(IR_0_INSTR_OUT[15:0]),
        .out0(OPERAND_2_IN),
        .sel(IR_0_INSTR_OUT[24])
    );

logic CONTROL_BLOCK_0_OPCODE_EN;
logic CONTROL_BLOCK_0_DEST_EN;
logic CONTROL_BLOCK_0_OP1_EN;
logic CONTROL_BLOCK_0_OP2_EN;
logic [7:0] OPCODE_MUX_OUT;

logic [7:0] OPCODE_0_OUT;
logic [15:0] OPERAND1_0_OUT;

MUX2 #(.BUS_WIDTH(8)) OPCODE_MUX (
    .in0(IR_0_INSTR_OUT[31:24]),
    .in1(8'b0),
    .out0(OPCODE_MUX_OUT),
    .sel(CONTROL_BLOCK_0_JMP_DET)
);

REGISTER #(.SIZE(8)) OPCODE
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_OPCODE_EN),
        .in(OPCODE_MUX_OUT),
        .out (OPCODE_0_OUT)
    );

REGISTER #(.SIZE(4)) DEST
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_DEST_EN),
        .in(IR_0_INSTR_OUT[23:20]),
        .out(DEST_0_OUT) 
    );

REGISTER #(.SIZE(16)) OPERAND1
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_OP1_EN),
        .in(FORWARD_RS1_MUX_OUT),
        .out(OPERAND1_0_OUT) 
    );
    
REGISTER #(.SIZE(16)) OPERAND2
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_OP2_EN),
        .in(OPERAND_2_IN),
        .out(OPERAND2_0_OUT)
    );

assign data_mem_data_write = OPERAND1_0_OUT;
assign data_mem_addr_write = OPERAND2_0_OUT[7:0];
assign data_mem_addr_read  = OPERAND2_0_OUT[7:0];

logic [15:0] ALU_0_RESULT;
logic Z;
logic N;
logic C;

ALU ALU_0 (
    .opcode(OPCODE_0_OUT[7:2]),
    .operand1(OPERAND1_0_OUT),
    .operand2(OPERAND2_0_OUT),
    .result(ALU_0_RESULT),
    .Z(Z),
    .N(N),
    .C(C)
    );

MUX2 #(.BUS_WIDTH(16)) MUX_REGS_WDATA_SEL_0 (
    .in0(ALU_0_RESULT),
    .in1(data_mem_data_in),
    .sel(CONTROL_BLOCK_0_REGS_WDATA_SEL),
    .out0(MUX_REGS_WDATA_SEL_0_OUT)
);

logic CONTROL_BLOCK_0_Z_EN;
logic CONTROL_BLOCK_0_N_EN;
logic CONTROL_BLOCK_0_C_EN;

logic Z_FLAG;
logic N_FLAG;
logic C_FLAG;

REGISTER #(.SIZE(1)) Z_REG_0
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_Z_EN),
        .in(Z),
        .out(Z_FLAG) 
    );

REGISTER #(.SIZE(1)) N_REG_0
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_N_EN),
        .in(N),
        .out(N_FLAG) 
    );

REGISTER #(.SIZE(1)) C_REG_0
    (
        .clock(clock),
        .reset(reset),
        .w_en(CONTROL_BLOCK_0_C_EN),
        .in(C),
        .out(C_FLAG) 
    );

CONTROL_BLOCK CONTROL_BLOCK_0(
    .opcode(OPCODE_0_OUT),
    .Z(Z_FLAG),
    .N(N_FLAG),
    .C(C_FLAG),
    
    .pc_en(CONTROL_BLOCK_0_PC_EN),
    .ir_en(CONTROL_BLOCK_0_IR_EN),
    .opcode_en(CONTROL_BLOCK_0_OPCODE_EN),
    .dest_en(CONTROL_BLOCK_0_DEST_EN),
    .op1_en(CONTROL_BLOCK_0_OP1_EN),
    .op2_en(CONTROL_BLOCK_0_OP2_EN),
    .reg_wen(CONTROL_BLOCK_0_REG_WEN),
    .Z_en(CONTROL_BLOCK_0_Z_EN),
    .N_en(CONTROL_BLOCK_0_N_EN),
    .C_en(CONTROL_BLOCK_0_C_EN),
    .regs_wdata_sel(CONTROL_BLOCK_0_REGS_WDATA_SEL),
    .mem_wen(mem_wen),
    .jmp_det(CONTROL_BLOCK_0_JMP_DET)
    );
endmodule
