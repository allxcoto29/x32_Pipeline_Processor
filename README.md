# x32 Pipeline Processor

A 3-stage pipelined processor written in SystemVerilog. It follows the design from Course 3 of Integrated Digital Circuits 2 (UNSTPB, ETTI).

## Overview

- 3-stage pipeline: FETCH, DECODE, EXECUTE
- Harvard architecture, with separate instruction and data memories
- 16 general-purpose registers, 16 bits each
- 32-bit fixed-length instructions
- 8-bit program counter (256 instruction words)
- 256 x 16-bit data memory
- Z (zero), N (negative) and C (carry) flags
- Jumps flush the pipeline
- Read-after-write hazards are resolved by forwarding, with no stalls

## Pipeline

| Stage   | What happens                                                                                    | Pipeline registers written  |
|---------|-------------------------------------------------------------------------------------------------|-----------------------------|
| FETCH   | The instruction at `PC` is read from instruction memory.                                        | `IR`                        |
| DECODE  | Fields are extracted from `IR` and operands are read from the register file or taken from `const`. | `OPCODE`, `DEST`, `OPERAND1`, `OPERAND2` |
| EXECUTE | The ALU runs, data memory is accessed, and results and flags are written on the next clock edge. | Register file, `Z`, `N`, `C`, data memory |

`CONTROL_BLOCK` sits in EXECUTE. It produces every write-enable signal from the opcode in `OPCODE` and the current flags.

`opcode[0]` picks the second operand. A value of 1 selects the 16-bit constant, and 0 selects `Rs2` from the register file. The result goes into `OPERAND2`. `OPERAND2` also serves as the memory address and the jump target, and `OPERAND1` serves as the data for stores.

## Instruction set

| Instruction           | Opcode        | Operation                |
|-----------------------|---------------|--------------------------|
| `ADD Rd, Rs1, Rs2`    | `000001_00`   | `Rd = Rs1 + Rs2`         |
| `ADD Rd, Rs1, #const` | `000001_01`   | `Rd = Rs1 + const`       |
| `SUB Rd, Rs1, Rs2`    | `000010_00`   | `Rd = Rs1 - Rs2`         |
| `SUB Rd, Rs1, #const` | `000010_01`   | `Rd = Rs1 - const`       |
| `SHR Rd, Rs1, Rs2`    | `000011_00`   | `Rd = Rs1 >> Rs2`        |
| `SHR Rd, Rs1, #const` | `000011_01`   | `Rd = Rs1 >> const`      |
| `SHL Rd, Rs1, Rs2`    | `000100_00`   | `Rd = Rs1 << Rs2`        |
| `SHL Rd, Rs1, #const` | `000100_01`   | `Rd = Rs1 << const`      |
| `AND Rd, Rs1, Rs2`    | `000101_00`   | `Rd = Rs1 & Rs2`         |
| `AND Rd, Rs1, #const` | `000101_01`   | `Rd = Rs1 & const`       |
| `OR Rd, Rs1, Rs2`     | `000110_00`   | `Rd = Rs1 \| Rs2`        |
| `OR Rd, Rs1, #const`  | `000110_01`   | `Rd = Rs1 \| const`      |
| `XOR Rd, Rs1, Rs2`    | `000111_00`   | `Rd = Rs1 ^ Rs2`         |
| `XOR Rd, Rs1, #const` | `000111_01`   | `Rd = Rs1 ^ const`       |
| `MOV Rd, Rs2`         | `100000_00`   | `Rd = Rs2`               |
| `MOV Rd, #const`      | `100000_01`   | `Rd = const`             |
| `JMP #const`          | `001000_01`   | `PC = const`             |
| `JMPZ #const`         | `001001_01`   | `PC = const` if `Z == 1` |
| `JMPN #const`         | `001010_01`   | `PC = const` if `N == 1` |
| `JMPC #const`         | `001011_01`   | `PC = const` if `C == 1` |
| `LOAD Rd, [const]`    | `100001_11`   | `Rd = MEM[const]`        |
| `LOAD Rd, [Rs2]`      | `100001_10`   | `Rd = MEM[Rs2]`          |
| `STORE Rs1, [const]`  | `100010_11`   | `MEM[const] = Rs1`       |
| `STORE Rs1, [Rs2]`    | `100010_10`   | `MEM[Rs2] = Rs1`         |
| `NOP`                 | `000000_00`   | No operation             |
| `HALT`                | `111111_11`   | Stop until reset         |

Only arithmetic and logic instructions update the flags. `C` holds the carry out for `ADD` and the borrow for `SUB`; every other ALU operation clears it.

## Instruction format

```
 31      24 23  20 19  16 15  12 11             0
+----------+------+------+------+----------------+
|  opcode  |  rd  | rs1  | rs2  |     unused     |   register operand
+----------+------+------+------+----------------+
|  opcode  |  rd  | rs1  |        const          |   constant operand
+----------+------+------+-----------------------+
```

- `MOV` and `LOAD` leave `rs1` unused.
- `STORE` leaves `rd` unused.
- `JMPx` uses only `opcode` and `const`, and only the low 8 bits of `const` are used as the target address.
- `NOP` and `HALT` use only `opcode`.

## Hazard handling

**Control hazards.** A jump is resolved in EXECUTE. When it is taken, `jmp_det` loads the target into `PC` and forces `IR` and `OPCODE` to 0, which turns the two instructions already fetched into NOPs. A taken jump therefore costs two cycles.

**Read-after-write hazards.** An instruction writes the register file at the end of EXECUTE, while the next instruction reads its operands in DECODE during that same cycle. Two forwarding multiplexers (`FORWARD_RS1_MUX` and `FORWARD_RS2_MUX`) catch this case. When `reg_wen` is 1 and `DEST` matches `rs1` or `rs2` of the instruction in DECODE, they pass the value being written (an ALU result or LOAD data) straight to `OPERAND1` or `OPERAND2`. Dependent instructions can therefore run back to back, with no NOPs between them.

**HALT.** When `HALT` reaches EXECUTE, every enable signal drops to 0. The pipeline freezes with `HALT` held in `OPCODE` until reset.

## Modules

| File                | Module          | Description                                                                 |
|---------------------|-----------------|-----------------------------------------------------------------------------|
| `TOP.sv`            | `TOP`           | Connects the processor to the instruction and data memories.                |
| `PROCESSOR.sv`      | `PROCESSOR`     | Pipeline datapath: pipeline registers, multiplexers, ALU, flags, forwarding. |
| `PC.sv`             | `PC`            | Program counter: increments, or loads the jump target when `jmp_det` is 1.  |
| `REGISTER.sv`       | `REGISTER`      | Parameterized register with write enable and synchronous reset.             |
| `REGISTER_FILE.sv`  | `REGISTER_FILE` | 16 x 16-bit register file: 2 asynchronous read ports, 1 synchronous write port. |
| `MUX2.sv`           | `MUX2`          | Parameterized 2-to-1 multiplexer.                                           |
| `ALU.sv`            | `ALU`           | Arithmetic and logic unit. Outputs the result and Z, N, C.                  |
| `CONTROL_BLOCK.sv`  | `CONTROL_BLOCK` | Produces the enable and select signals from the opcode and flags.           |
| `INSTR_MEM.sv`      | `INSTR_MEM`     | 256 x 32-bit instruction memory, asynchronous read.                         |
| `DATA_MEM.sv`       | `DATA_MEM`      | 256 x 16-bit data memory: synchronous write, asynchronous read.             |
| `COUNTER.sv`        | `COUNTER`       | Not used. Disabled in the project.                                          |
| `TB.sv`             | `TB`            | Testbench.                                                                  |

## Control signals

| Instruction in EXECUTE | jmp_det | pipeline enables | reg_wen | Z/N/C_en | regs_wdata_sel | mem_wen |
|------------------------|---------|------------------|---------|----------|----------------|---------|
| Arithmetic and logic   | 0       | 1                | 1       | 1        | 0              | 0       |
| MOV                    | 0       | 1                | 1       | 0        | 0              | 0       |
| LOAD                   | 0       | 1                | 1       | 0        | 1              | 0       |
| STORE                  | 0       | 1                | 0       | 0        | 0              | 1       |
| JMP / JMPx             | 1 / flag | 1               | 0       | 0        | 0              | 0       |
| NOP                    | 0       | 1                | 0       | 0        | 0              | 0       |
| HALT                   | 0       | 0                | 0       | 0        | 0              | 0       |

The pipeline enables are `pc_en`, `ir_en`, `opcode_en`, `dest_en`, `op1_en` and `op2_en`.

## Project structure

```
CID2_PROC_Pipeline_x32.xpr                   Vivado project
CID2_PROC_Pipeline_x32.srcs/
    sources_1/new/                           Design sources
    sim_1/new/TB.sv                          Testbench
```

## Simulation

Tools: AMD Vivado 2026.1 with its built-in simulator (xsim). The target part is `xc7s50csga324-1`.

1. Open `CID2_PROC_Pipeline_x32.xpr` in Vivado.
2. Run **Simulation > Run Behavioral Simulation**. The top module is `TB`.
3. Inspect `dut.PROCESSOR0.REGISTER_FILE_0.set` and `dut.DATA_MEM0.mem` in the waveform or object window.

The testbench uses a 4 ns clock and holds reset high for the first 10 ns. It calls `$stop` at 110 ns. The program and data memory are loaded directly from the testbench through hierarchical references.

### Test program

Data memory starts with `MEM[0] = 3` and `MEM[1] = 4`.

| Addr | Instruction        | Purpose                                         |
|------|--------------------|-------------------------------------------------|
| 0    | `LOAD R2, [0]`     | `R2 = 3`                                        |
| 1    | `LOAD R1, [1]`     | `R1 = 4`                                        |
| 2    | `SUB R3, R1, R2`   | `R3 = 1`; uses R1 from the LOAD just before it  |
| 3    | `ADD R4, R3, R3`   | `R4 = 2`; uses R3 from the instruction just before it, as both operands |
| 4    | `STORE R4, [2]`    | `MEM[2] = 2`; uses R4 from the instruction just before it |
| 5    | `JMP 8`            | Unconditional jump                              |
| 6    | `MOV R5, #0x77`    | Skipped                                         |
| 7    | `MOV R5, #0x66`    | Skipped                                         |
| 8    | `SUB R6, R4, #2`   | `R6 = 0`, sets `Z`                              |
| 9    | `JMPZ 11`          | Taken                                           |
| 10   | `MOV R7, #0x55`    | Skipped                                         |
| 11   | `HALT`             | Stop                                            |

Expected final state: `R1 = 4`, `R2 = 3`, `R3 = 1`, `R4 = 2`, `R5 = 0`, `R6 = 0`, `R7 = 0`, `MEM[2] = 2`.

## Limitations

- Each operation takes one cycle in EXECUTE. There is no multi-cycle execution and no stall mechanism apart from HALT.
- There is no branch prediction. Every taken jump costs two cycles.
- The jump target and memory addresses are 8 bits wide, the low byte of `OPERAND2`.
- Both memories are initialized only from the testbench. There is no memory file loading.
