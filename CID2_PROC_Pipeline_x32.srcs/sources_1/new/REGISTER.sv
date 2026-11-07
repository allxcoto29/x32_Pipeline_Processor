`timescale 1ns / 1ps

module REGISTER #(parameter SIZE=16)
    (
        input logic             clock,
        input logic             reset,
        input logic             w_en,
        input logic  [SIZE-1:0] in,
        
        output logic [SIZE-1:0] out 
    );

always_ff @(posedge clock) begin
    if (reset) begin
        out <= 0;
    end 
    else begin
        if(w_en) begin
            out <= in;
        end
        else begin
            out <= out;
        end
    end

end
endmodule
