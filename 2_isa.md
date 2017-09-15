# Tuna Instruction Set Architecture

See [README.md](https://github.com/tuna-arch/tuna/blob/master/README.md)
for a more high-level discussion of the architecture.

Written by [Ellen Dash](https://smallest.dog).

The latest version of this document can be found at [https://github.com/tuna-arch/tuna/blob/master/2_isa.md](https://github.com/tuna-arch/tuna/blob/master/2_isa.md).

[Tuna Instruction Set Architecture](https://github.com/tuna-arch/tuna/blob/master/2_isa.md) by [Ellen Dash](https://smallest.dog) is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).

## System Architecture

Tuna is a [big endian](https://en.wikipedia.org/wiki/Endianness#Big) [register memory architecture](https://en.wikipedia.org/wiki/Register_memory_architecture), designed so implementations can have varying register and address bus sizes.

E.g., prototype/toy systems can have a 16-bit word size for simplicity, whereas more complex system can use a word size of 32 bits, 64 bits, or more, to work efficiently with larger numbers or accomodate more memory.

### Memory

The design in this document offers neither memory protection, virtual memory, nor segmentation. However, extensions can be made to the architecture to accomodate this. This document assumes there are no extensions related to memory.

Without any architecture extensions, the amount of addressable memory is determined by the smallest of the register width and the address bus. That is, if the address bus is narrower than register width, then the address bus dictates the amount of addressable memory; otherwise, the register width dictates the amount of addressable memory.

Register width is in powers of two &mdash; 16 bit, 32 bit, 64 bit, etc. 8 bit and smaller is not recommended, as the largest value an 8 bit register can store is 255.

E.g.,

* 16-bit registers can store addresses 0x0 to 0xFFFF (approximately 65 kilobytes of RAM),
* 32-bit registers can store addresses 0x0 to 0xFFFFFFFF (approximately 4 gigabytes of RAM).

**_The amount of addressible RAM is distinct from how much RAM the system actually has._**

For the rest of the document, and in the assembler, `WORD_SIZE` is defined as the word size in bytes.

### Registers

See the [section on Memory](#Memory) for information on register size and handling memory addresses.

| Register name | Purpose                                                                                 |
|---------------|-----------------------------------------------------------------------------------------|
| r0 (PC)       | Program counter. Yes, you can modify this.                                              |
| r1 (FLAGS)    | Contains information about the last ALU operation (not modified by non-ALU operations). |
| r2            | General purpose register.                                                               |
| r3            | General purpose register.                                                               |
| r4            | General purpose register.                                                               |
| r5            | General purpose register.                                                               |
| r6            | General purpose register.                                                               |
| r7            | General purpose register.                                                               |
| r8            | General purpose register.                                                               |
| r9            | General purpose register.                                                               |
| r10           | General purpose register.                                                               |
| r11           | General purpose register.                                                               |
| r12           | General purpose register.                                                               |
| r13           | General purpose register.                                                               |
| r14           | General purpose register.                                                               |
| r15           | General purpose register.                                                               |
| r16           | General purpose register.                                                               |

The `FLAGS` register stores information from the output of the last ALU operation:

| bit # | name   | value                                  |
|-------|--------|----------------------------------------|
| ---x  | carry  | 1 if carry required                    |
| --x-  | zero   | 1 if last instruction equated to zero  |
| rest  |        | reserved                               |


All commands are formatted as follows, with unused operands set to zero:

    [Immediate Modifier][4-Bit Opcode][WORD-sized Operand][WORD-sized Operand]

The Immediate Modifier affects the behavior of the fetcher stage, and is completely transparent to the rest of the system. If it is 1, the last operand is treated as a value. If it is 0, the last operand is treated as a reference to a register.

### Opcodes/operands and what they do

Each opcode only requires one implementation; the Immediate Modifier changes the behavior of the fetcher stage, and is completely transparent to the rest of the system. The general layout is `opcode destination, source`.

| I.M. | Opcode | Example                | Expression                                                             |
|------|--------|------------------------|------------------------------------------------------------------------|
|  0   | 0000   | `store  REG1, REG2   ` | Store the value stored in REG2 at the memory address stored in REG1.   |
|  1   | 0000   | `storei REG1, VALUE  ` | Store VALUE at the memory address stored in REG1.                      |
|||||
|  0   | 0001   | `mov    REG1, REG2   ` | Copy the value of REG2 to REG1.                                        |
|  1   | 0001   | `movi   REG1, VALUE  ` | Copy VALUE to REG1.                                                    |
|||||
|  0   | 0010   | `movz   REG1, REG2   ` | If the zero flag is set, copy the value of REG2 to REG1; otherwise, do nothing. |
|  1   | 0010   | `movzi  REG1, VALUE  ` | If the zero flag is set, copy VALUE to REG1; otherwise, do nothing.             |
|||||
|  0   | 0011   | `nand  REG1, REG2    ` | REG = (value of REG1) nand (value of REG2)                             |
|  1   | 0011   | `nandi REG1, VALUE   ` | REG = (value of REG1) nand VALUE                                       |
|||||
|  0   | 0100   | `shl   REG1, REG2    ` | REG1 = (value of REG1) << (value of REG2)                              |
|  1   | 0100   | `shli  REG1, VALUE   ` | REG1 = (value of REG1) << VALUE                                        |
|||||
|  0   | 0101   | `shr   REG1, REG2    ` | REG1 = (value of REG1) >> (value of REG2)                              |
|  1   | 0101   | `shri  REG1, VALUE   ` | REG1 = (value of REG1) >> VALUE                                        |
|||||
|  0   | 0110   | `lt    REG1, REG2    ` | status flag = 1 if (value of REG1) < (value of REG2), 0 otherwise.     |
|  1   | 0110   | `lti   REG1, VALUE   ` | status flag = 1 if (value of REG1) < VALUE, 0 otherwise.               |
|||||
|||| TODO: FIGURE OUT I/O. `in`/`out` are copypasta-edits.  |
|  0   | 1110   | in     REG1, REG2      | Read port number specified in REG2 and put the value in REG1.          |
|  1   | 1110   | in     REG1, VALUE     | Read port number specified in REG2 and put the value in REG1.          |
|||||
|  0   | 1111   | out    REG1, REG2      | Write (value of REG2) to port specified in REG1.     |
|  1   | 1111   | out    REG1, VALUE     | Write VALUE to port specified in REG1.               |

#### "Missing" opcodes

These should be macros (or similar) offered by the assembler/compiler, for convenience purposes.

    gt REG1, REG2
        lt REG2, REG1

    not REG1
        nand REG1, REG1

    ; TODO: This should PROBABLY be it's own instruction.
    and REG1, REG2
        nand REG1, REG2
        nand REG1, REG1

    ; TODO: This should PROBABLY be it's own instruction.
    or REG1, REG2
        nand  REG1, REG1
        nand  REG2, REG2
        nand  REG1, REG2

    jmp REG1
        mov  PC, REG1

    ; TODO: ???
    sub REG1, REG2
        nand REG2, REG2   # NOT <value of REG2>
        addi REG2, 1      # 2's compliment (negate and add 1 to subtract)
        add  REG1, REG2   # ADD <value of REG1> and put the result in REG1

    eq REG1, REG2  # Compare two addresses.
    je REG3        # Then jump to the third if they're not equal.
        # Subtract REG2 from REG2.
            nand REG2, REG2 # NOT <value of REG2>
            add  REG2, 1    # 2's compliment (negate and add 1 to subtract)
            add  REG1, REG2 # ADD <value of REG1>
        # At this point, the zero flag is set to 0 if they're equal.
        movz PC, REG3 # Jump if equal.

### Booting

The entire hardware initialization consists of:

* An implementation-specific method for loading the initial program into memory at address 0x0.
* Setting the Program Counter to 0 (zero).
* Beginning to fetch and execute instructions.

Note: Registers may not be zeroed out at boot time. You should do that manually.
