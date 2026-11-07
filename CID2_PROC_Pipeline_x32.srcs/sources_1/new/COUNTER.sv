`timescale 1ns / 1ps

module COUNTER #(parameter WIDTH = 8)
    (
    input  logic              clock,
    input  logic              reset,
    input  logic [WIDTH-1:0]  in0,
    output logic [WIDTH-1:0]  out0  
    );

always_ff @(posedge clock) begin
    if(reset == 1)
        out0 <= 0;
    else
        out0 <= in0 + 1;  
end

endmodule
