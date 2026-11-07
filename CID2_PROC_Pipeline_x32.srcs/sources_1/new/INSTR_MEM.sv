`timescale 1ns / 1ps

module INSTR_MEM(
    input logic [7:0] instr_mem_addr_read,
    output logic [31:0] instr_mem_instr_out
);

logic [31:0] mem [0:255];

assign instr_mem_instr_out = mem [instr_mem_addr_read];

endmodule
