`timescale 1ns / 1ps

module TOP
    (
    input logic clock,
    input logic reset
    );
    
logic [7:0] INSTR_MEM_0_ADDR_READ;
logic [31:0] INSTR_MEM_0_INSTR;
INSTR_MEM INSTR_MEM0(
    .instr_mem_addr_read(INSTR_MEM_0_ADDR_READ),
    .instr_mem_instr_out(INSTR_MEM_0_INSTR)
);

logic [7:0] PROCESSOR0_data_mem_addr_write;
logic [15:0] PROCESSOR0_data_mem_data_write;
logic [7:0] PROCESSOR0_data_mem_addr_read;
logic [15:0] PROCESSOR0_data_mem_data_in;
logic MEM_WEN;

PROCESSOR PROCESSOR0
    (
        .clock(clock),
        .reset(reset),
    
        .instr_mem_addr_read(INSTR_MEM_0_ADDR_READ),
        .instr(INSTR_MEM_0_INSTR),
        .mem_wen(MEM_WEN),
        .data_mem_addr_write(PROCESSOR0_data_mem_addr_write),
        .data_mem_addr_read(PROCESSOR0_data_mem_addr_read),
        .data_mem_data_write(PROCESSOR0_data_mem_data_write),
        .data_mem_data_in(PROCESSOR0_data_mem_data_in) 
    );

DATA_MEM DATA_MEM0
(
    .clock(clock),
    .w_en(MEM_WEN),
    .data_mem_addr_write(PROCESSOR0_data_mem_addr_write),
    .data_mem_addr_read(PROCESSOR0_data_mem_addr_read),
    .data_mem_data_write(PROCESSOR0_data_mem_data_write),
    .data_mem_data_out(PROCESSOR0_data_mem_data_in) 
    );
endmodule
