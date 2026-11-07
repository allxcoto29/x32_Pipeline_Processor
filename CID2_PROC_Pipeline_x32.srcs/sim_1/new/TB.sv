`timescale 1ns / 1ps

module TB();

logic clock_tb;
logic reset_tb;

TOP dut (
    .clock(clock_tb),
    .reset(reset_tb)
);

initial begin
    clock_tb = 0;
    forever #2
        clock_tb = ~clock_tb;
end

initial begin
    reset_tb <= 1;
    #10 reset_tb <= 0;
    #100 $stop();
end

initial begin
    dut.DATA_MEM0.mem[0] = 3;
    dut.DATA_MEM0.mem[1] = 4;
end

initial begin
    dut.INSTR_MEM0.mem[0] = 32'b10000111_0010_0000_0000_000000000000;
    dut.INSTR_MEM0.mem[1] = 32'b10000111_0001_0000_0000_000000000001;
    dut.INSTR_MEM0.mem[2] = 32'b00001000_0011_0001_0010_000000000000;
    dut.INSTR_MEM0.mem[3] = 32'b00000100_0100_0011_0011_000000000000;
    dut.INSTR_MEM0.mem[4] = 32'b10001011_0000_0100_0000_000000000010;
    dut.INSTR_MEM0.mem[5] = 32'b00100001_0000_0000_0000_000000001000;
    dut.INSTR_MEM0.mem[6] = 32'b10000001_0101_0000_0000_000001110111;
    dut.INSTR_MEM0.mem[7] = 32'b10000001_0101_0000_0000_000001100110;
    dut.INSTR_MEM0.mem[8] = 32'b00001001_0110_0100_0000_000000000010;
    dut.INSTR_MEM0.mem[9] = 32'b00100101_0000_0000_0000_000000001011;
    dut.INSTR_MEM0.mem[10] = 32'b10000001_0111_0000_0000_000001010101;
    dut.INSTR_MEM0.mem[11] = 32'b11111111_0000_0000_0000_000000000000;
end

endmodule
