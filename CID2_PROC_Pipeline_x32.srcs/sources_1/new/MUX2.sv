`timescale 1ns / 1ps

module MUX2 #(parameter BUS_WIDTH)
    (
    input  logic                 sel,
    input  logic [BUS_WIDTH-1:0] in0,
    input  logic [BUS_WIDTH-1:0] in1,
    
    output logic [BUS_WIDTH-1:0] out0
    );
   
always_comb begin
    case(sel)
        0: out0 = in0;
        1: out0 = in1;
    endcase
end 

endmodule
