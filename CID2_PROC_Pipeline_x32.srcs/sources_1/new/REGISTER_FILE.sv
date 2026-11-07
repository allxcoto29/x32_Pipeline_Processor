`timescale 1ns / 1ps


module REGISTER_FILE
    (
       input logic          clock,
       input logic          reset,
       input logic          w_en,
      
       input logic  [3:0]   w_addr,
       input logic  [15:0]  w_data,
       input logic  [3:0]   r_addr1,
       input logic  [3:0]   r_addr2, 
       
       output logic [15:0]  rdata1,
       output logic [15:0]  rdata2
    );
    
logic [15:0] set [0:15];

always_ff @(posedge clock) begin
    if(reset) begin
        for(int i=0; i<16; i++) begin
            set[i] <= 0;
        end
    end
    else begin
        if(w_en) begin
            set[w_addr] <= w_data;
        end
    end
end 

assign rdata1 = set[r_addr1];
assign rdata2 = set[r_addr2];

endmodule
