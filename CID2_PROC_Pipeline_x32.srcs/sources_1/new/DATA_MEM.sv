`timescale 1ns / 1ps

module DATA_MEM(
    input logic         clock,
    input logic         w_en,
    input logic [7:0]  data_mem_addr_write,
    input logic [7:0]  data_mem_addr_read,
    input logic [15:0]  data_mem_data_write,
    output logic [15:0] data_mem_data_out 
    );

logic [15:0] mem [0:255];

always_ff @(posedge clock) begin
    if(w_en) begin
       mem[data_mem_addr_write] <= data_mem_data_write;
    end
end

assign data_mem_data_out = mem [data_mem_addr_read];
endmodule
