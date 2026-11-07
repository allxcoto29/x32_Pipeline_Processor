`timescale 1ns / 1ps

module ALU(
    input logic  [5:0]   opcode,
    input logic  [15:0]  operand1,
    input logic  [15:0]  operand2,
    
    output logic [15:0]  result,
    output logic         Z,
    output logic         N,
    output logic         C
    );

logic carry;

always_comb begin
    carry = 0;
    case(opcode)
        6'b000001: begin
            {carry, result} = operand1 + operand2;
        end
        6'b000010: begin
            {carry, result} = operand1 - operand2;
        end
        6'b000011: begin
            result = operand1 >> operand2;
        end
        6'b000100: begin
            result = operand1 << operand2;
        end
        6'b000101: begin 
            result = operand1 & operand2;
        end
        6'b000110: begin
            result = operand1 | operand2;
        end
        6'b000111: begin
            result = operand1 ^ operand2;
        end
        6'b100000: begin
            result = operand2;
        end
        6'b001000: begin
            result = operand2;
        end
        6'b001001: begin
            result = operand2;
        end
        6'b001010: begin
            result = operand2;
        end
        6'b001011: begin
            result = operand2;
        end
        6'b100001: begin
            result = operand2;
        end
        6'b100010: begin
            result = operand2;
        end
        default: begin
            result = 0;
        end
    endcase

end
    
assign Z = (result == 0);
assign N = (result[15] == 1);
assign C = (carry == 1);

endmodule
