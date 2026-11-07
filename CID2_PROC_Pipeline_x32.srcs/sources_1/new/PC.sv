`timescale 1ns / 1ps

module PC
    (
    input logic         clock,
    input logic         reset,
    input logic         w_en,
    input logic         jmp_det,
    input logic  [7:0]  jmp_value,
    output logic [7:0]  pc_out
    );

always_ff @(posedge clock) begin
    if(reset) begin
        pc_out <= 0;
    end
    else if(w_en) begin
        if(jmp_det) begin
            pc_out <= jmp_value;
        end
        else begin
            pc_out <= pc_out + 1;
        end
    end
    else begin
        pc_out <= pc_out;
    end
end

endmodule
